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
 msepropertyeditors,mseformatstr,mserepps,msedrawtext,
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
 treptabulators1 = class(treptabulators);
 treptabulatoritem1 = class(treptabulatoritem);

 treptabulatoreditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;

 treptabulatorseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   procedure itemfocused(const sender: tarrayelementeditor) override;
   procedure resetactivetab();
  public
   destructor destroy(); override;
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
   if ifilink <> nil then begin
    mstr1:= msestring(ifilink.name);
   end
   else begin
    mstr1:= value;
   end;
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

destructor treptabulatorseditor.destroy();
begin
 resetactivetab();
 inherited;
end;

procedure treptabulatorseditor.resetactivetab();
var
 i1,i2: int32;
 p1: treptabulators1;
begin
 for i1:= 0 to high(fprops) do begin
  p1:= treptabulators1(getpointervalue(i1));
  for i2:= 0 to p1.count - 1 do begin
   with treptabulatoritem1(p1.fitems[i2]) do begin
    exclude(fstate,tas_editactive);
   end;
  end;
  p1.fband.invalidate();
 end;
end;

function treptabulatorseditor.geteditorclass: propertyeditorclassty;
begin
 result:= treptabulatoreditor;
end;

procedure treptabulatorseditor.itemfocused(const sender: tarrayelementeditor);
var
 i1: int32;
 p1: treptabulators1;
begin
 resetactivetab();
 for i1:= 0 to high(fprops) do begin
  p1:= treptabulators1(getpointervalue(i1));
  if p1.count > sender.index then begin
   with treptabulatoritem1(p1.fitems[sender.index]) do begin
    include(fstate,tas_editactive);
   end;
  end;
 end;
 inherited;
end;

initialization
 register;
end.
