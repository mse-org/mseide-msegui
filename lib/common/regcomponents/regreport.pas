{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regreport;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
 
implementation
uses
 classes,msereport,msedesignintf,formdesigner,reportdesigner,msepropertyeditors,
 sysutils,msestrings,regreport_bmp,regdb;
const
 reportintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createreport;
   initnewcomponent: {$ifdef FPC}@{$endif}initreportcomponent;
   getscale: {$ifdef FPC}@{$endif}getreportscale);
type
 treptabulatoreditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 treptabulatorseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
   
procedure Register;
begin
 registercomponents('Rep',[{treportpage,}tbandarea,tbandgroup,
                    trecordband,
                    trepvaluedisp,treppagenumdisp,trepprintdatedisp,
                    trepstringdisplb,trepintegerdisplb,treprealdisplb,
                    trepdatetimedisplb,
                    trepspacer]); 
 
 registerdesignmoduleclass(treport,reportintf,treportdesignerfo);
 registerpropertyeditor(typeinfo(treptabulators),nil,'',treptabulatorseditor);
 registerpropertyeditor(typeinfo(tcustomrecordband),treptabulators,'linksource',
                           tlocallinkcomponentpropertyeditor);
 registerpropertyeditor(typeinfo(string),tcustomreplookupdisp,'keydatafield',
        tdbfieldnamepropertyeditor);
 registerpropertyeditor(typeinfo(string),tcustomrecordband,'visidatafield',
        tdbfieldnamepropertyeditor);
 registerpropertyeditor(typeinfo(string),tcustomrecordband,'visigroupfield',
        tdbfieldnamepropertyeditor);
 registerpropertyeditor(typeinfo(tcustomrecordband),tcustomrecordband,'nextband',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(tcustomrecordband),tcustomrecordband,'nextbandifempty',
                                 tsisterwidgetpropertyeditor);
end;

{ treptabulatoreditor }

function treptabulatoreditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 with treptabulatoritem(getordvalue) do begin
  if datafield = '' then begin
   mstr1:= value;
  end
  else begin
   mstr1:= datafield;
  end;
  result:= '<'+formatfloat('0.0',pos)+'><'+mstr1+'>';
 end;
end;

{ treptabulatorseditor }

function treptabulatorseditor.geteditorclass: propertyeditorclassty;
begin
 result:= treptabulatoreditor;
end;

initialization
 registerclass(treportpage);
 register;
end.
