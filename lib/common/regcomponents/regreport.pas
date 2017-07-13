{ MSEide Copyright (c) 1999-2016 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit regreport;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
 
implementation
uses
 classes,mclasses,msereport,msedesignintf,formdesigner,reportdesigner,
 msepropertyeditors,mseformatstr,mserepps,
 sysutils,msetypes{msestrings},regreport_bmp,regdb,mselookupbuffer;
const
 reportintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createreport;
   initnewcomponent: {$ifdef FPC}@{$endif}initreportcomponent;
   getscale: {$ifdef FPC}@{$endif}getreportscale;
   sourcetoform: nil);
 reppageformintf: designmoduleintfty = 
  (createfunc: @createreppageform;
   initnewcomponent: nil;
   getscale: @getreppageformscale;
   sourcetoform: nil);

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
 registerclass(treport);
 registerclass(treportpage);
 registerclass(treppageform);
 registercomponents('Rep',[treportpage,tbandarea,ttilearea,tbandgroup,
                    trecordband,
                    trepvaluedisp,treppagenumdisp,trepprintdatedisp,
                    {trepstringdisplb,trepintegerdisplb,treprealdisplb,
                    trepdatetimedisplb,}
                    trepspacer,treppsdisp]); 
 registercomponenttabhints(['Rep'],['Report components']);

 registerdesignmoduleclass(treport,@reportintf,treportdesignerfo);
 registerdesignmoduleclass(treppageform,@reppageformintf,treportdesignerfo);
 registerpropertyeditor(typeinfo(treptabulators),nil,'',treptabulatorseditor);
 registerpropertyeditor(typeinfo(tcustomrecordband),treptabulators,'linksource',
                           tlocallinkcomponentpropertyeditor);
// registerpropertyeditor(typeinfo(string),tcustomreplookupdisp,'keydatafield',
//        tdbfieldnamepropertyeditor);
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
 with treptabulatoritem(getpointervalue) do begin
  if datafield = '' then begin
   mstr1:= value;
  end
  else begin
   mstr1:= '';
   if datasource <> nil then begin
    mstr1:= msestring(datasource.name+'.');
   end;
   mstr1:= mstr1+msestring(datafield);
   if (lookupbuffer <> nil) and (lookupbuffer is tdblookupbuffer) and 
    (lookupvaluefieldno >= 0) then begin
    with tdblookupbuffer(lookupbuffer) do begin
     case lookupkind of
      lk_text: begin
       if lookupvaluefieldno < lookupbuffer.fieldcounttext then begin
        mstr1:= mstr1+'><'+msestring(textfields[lookupvaluefieldno]);
       end;
      end;
      lk_integer: begin
       if lookupvaluefieldno < lookupbuffer.fieldcountinteger then begin
        mstr1:= mstr1+'><'+msestring(integerfields[lookupvaluefieldno]);
       end;
      end;
      lk_float,lk_date,lk_time,lk_datetime: begin
       if lookupvaluefieldno < lookupbuffer.fieldcountfloat then begin
        mstr1:= mstr1+'><'+msestring(floatfields[lookupvaluefieldno]);
       end;
      end;
     end;
    end;
   end;
  end;
  result:= '<'+formatfloatmse(pos,'0.0')+'><'+mstr1+'>';
 end;
end;

{ treptabulatorseditor }

function treptabulatorseditor.geteditorclass: propertyeditorclassty;
begin
 result:= treptabulatoreditor;
end;

initialization
 register;
end.
