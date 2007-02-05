unit editform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,msedbedit,mselookupbuffer,
 msedataedits,msedb;

type
 teditfo = class(tmseform)
   btnOk: tbutton;
   btnCancel: tbutton;
   seName: tdbstringedit;
   cbPlanets: tenumeditlb;
   cbContinents: tenumeditlb;
   cbCountries: tdbenumeditlb;
   cbOccupations: tdbenumeditlb;
   cbFeatures: tdbenumeditlb;
   reSexPotention: tdbrealedit;
   beHappy: tdbbooleantextedit;
   lblDateFormatHint: tlabel;
   lblSexPotentionHint: tlabel;
   cdeDateOfBirth: tdbcalendardatetimeedit;
   procedure editfocreated(const sender: TObject);
   procedure editfodestroyed(const sender: TObject);
   procedure countryentered(const sender: TObject);
   procedure occupationentered(const sender: TObject);
   procedure featureentered(const sender: TObject);
   procedure continentchanged(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure planetchanged(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure continentsfilter(const sender: tcustomlookupbuffer;
                   const physindex: Integer; var valid: Boolean);
   procedure countriesfilter(const sender: tcustomlookupbuffer;
                   const physindex: Integer; var valid: Boolean);
   procedure sexpotentioncheckvalue(const sender: tdataedit;
                   const quiet: Boolean; var accept: Boolean);

 end;
var
 editfo: teditfo;
 
implementation

uses
 editform_mfm,
 refsdatamodule,
 main,
 sysutils,
 msewidgets
;

  
procedure teditfo.editfocreated(const sender: TObject);
  var
  int1: integer;
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  
  if refsdatamo.lbufCountries.findphys(0,integer(cbCountries.value),int1) then begin
    cbContinents.value:= refsdatamo.lbufCountries.integervaluephys(1,int1);
  end;

  if refsdatamo.lbufContinents.findphys(0,integer(cbContinents.value),int1) then begin
    cbPlanets.value:= refsdatamo.lbufContinents.integervaluephys(1,int1);
  end;
  
  lblDateFormatHint.caption:= '( ' + uppercase(ShortDateFormat) + ' )';
end;

procedure teditfo.editfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure teditfo.countryentered(const sender: TObject);
begin
  mainfo.fldCountry.value:= cbCountries.text;
end;

procedure teditfo.occupationentered(const sender: TObject);
begin
  mainfo.fldOccupation.value:= cbOccupations.text;
end;

procedure teditfo.featureentered(const sender: TObject);
begin
  mainfo.fldFeature.value:= cbFeatures.text;
end;

procedure teditfo.continentchanged(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
  if avalue <> (sender as tenumeditlb).value then begin
    mainfo.fldCountry.clear;
    mainfo.fldCountryId.clear;
  end;
end;

procedure teditfo.planetchanged(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
  if avalue <> (sender as tenumeditlb).value then begin
    cbContinents.value:= -1;
    mainfo.fldCountry.clear;
    mainfo.fldCountryId.clear;
  end;
end;

procedure teditfo.continentsfilter(const sender: tcustomlookupbuffer;
               const physindex: Integer; var valid: Boolean);
begin
  valid:= 
  (cbPlanets.value = -1) 
  or 
  (sender.integervalue[1,physindex] =  cbPlanets.value);
end;

procedure teditfo.countriesfilter(const sender: tcustomlookupbuffer;
               const physindex: Integer; var valid: Boolean);
begin

  if cbPlanets.value = -1 then begin
    if cbContinents.value = -1 then begin
      valid:= true;
    end else begin
      valid:= sender.integervalue[1,physindex] = cbContinents.value;
    end;
  end else begin
    if cbContinents.value = -1 then begin
      valid:= false;
    end else begin
      valid:= sender.integervalue[1,physindex] = cbContinents.value;
    end;
  end;

end;

procedure teditfo.sexpotentioncheckvalue(const sender: tdataedit;
               const quiet: Boolean; var accept: Boolean);
var
  f1: double;
begin
  try
    f1:=  StrToFloat(sender.text);
    if (f1 < 0) or (f1 > 100) then begin 
      accept:= false;
      showmessage('Percent of people sexual potention should be in range 0..100','Invalid Input',150);
    end;
  except 
    on EConvertError do begin
      if sender.text <> '' then begin
        accept:= false;
        showmessage('Percent value 0..100% step 0'+ DecimalSeparator +'01 expected here','Invalid Input',150); 
      end;
    end;
  end;

end;


               

end.
