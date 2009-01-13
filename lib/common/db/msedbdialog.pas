{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msedbdialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,msefiledialog,db,mseinplaceedit,msedbedit,msegui,msewidgetgrid,
 msedatalist,mseeditglob,msegrids,msetypes,msedb,msemenus,mseedit,
 msedataedits,mseevent,msestrings,msecolordialog,msegraphutils;
 
type
 tdbfilenameedit = class(tcustomfilenameedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringeditwidgetdatalink;
   procedure setdatalink(const avalue: tstringeditwidgetdatalink);
   procedure readdatasource(reader: treader);
   procedure readdatafield(reader: treader);
   procedure readoptionsdb(reader: treader);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   function getoptionsedit: optionseditty; override;
   procedure dochange; override;

   function getrowdatapo(const info: cellinfoty): pointer; override;
   //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tstringeditwidgetdatalink read fdatalink write setdatalink;
   property frame;
   property passwordchar;
   property maxlength;
   property onsetvalue;
   property controller;
 end;
 
 tdbcoloredit = class(tcustomcoloredit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
   procedure readdatasource(reader: treader);
   procedure readdatafield(reader: treader);
   procedure readoptionsdb(reader: treader);
  protected   
   procedure defineproperties(filer: tfiler); override;

   function internaldatatotext1(
                 const avalue: integer): msestring; override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   function getoptionsedit: optionseditty; override;
   procedure dochange; override;

   function getrowdatapo(const info: cellinfoty): pointer; override;
   //idbeditfieldlink
   procedure valuetofield; virtual;
   procedure fieldtovalue; virtual;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property dropdown;
   property onsetvalue;
   property frame;
 end;
 
implementation
uses
 typinfo; 
type
 teditwidgetdatalink1 = class(teditwidgetdatalink);
 treader1 = class(treader);
 
{ tdbfilenameedit }

constructor tdbfilenameedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringeditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbfilenameedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbfilenameedit.dochange;
begin
 fdatalink.dataentered;
 inherited;
end;

procedure tdbfilenameedit.modified;
begin
 fdatalink.modified;
 inherited;
end;

function tdbfilenameedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;

procedure tdbfilenameedit.valuetofield;
begin
 if value = '' then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.asmsestring:= value;
 end;
end;

procedure tdbfilenameedit.fieldtovalue;
begin
 value:= fdatalink.asmsestring;
end;

function tdbfilenameedit.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getstringbuffer(fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

function tdbfilenameedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbfilenameedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbfilenameedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datasource;
end;

procedure tdbfilenameedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdbfilenameedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 teditwidgetdatalink1(fdatalink).nullcheckneeded(result);
end;

procedure tdbfilenameedit.setdatalink(const avalue: tstringeditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbfilenameedit.readdatasource(reader: treader);
begin
 treader1(reader).readpropvalue(
         fdatalink,getpropinfo(typeinfo(teditwidgetdatalink),'datasource'));
end;

procedure tdbfilenameedit.readdatafield(reader: treader);
begin
 fdatalink.fieldname:= reader.readstring;
end;

procedure tdbfilenameedit.readoptionsdb(reader: treader);
begin
 treader1(reader).readpropvalue(
         fdatalink,getpropinfo(typeinfo(teditwidgetdatalink),'options'));
end;

procedure tdbfilenameedit.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datasource',{$ifdef FPC}@{$endif}readdatasource,nil,false);
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
 filer.defineproperty('optionsdb',{$ifdef FPC}@{$endif}readoptionsdb,nil,false);
               //move values to datalink
end;

procedure tdbfilenameedit.editnotification(var info: editnotificationinfoty);
var
 int1: integer;
begin
 inherited;
 if info.action = ea_textedited then begin
  if fdatalink.cuttext(text,int1) then begin
   text:= copy(text,1,int1);
  end;
 end;
end;

procedure tdbfilenameedit.recchanged;
begin
 teditwidgetdatalink1(fdatalink).recordchanged(nil);
end;

{ tdbcoloredit }

constructor tdbcoloredit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.create(idbeditfieldlink(self));
 inherited;
 valuedefault:= colorty(-1);
end;

destructor tdbcoloredit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbcoloredit.dochange;
begin
 fdatalink.dataentered;
 inherited;
end;

procedure tdbcoloredit.modified;
begin
 fdatalink.modified;
 inherited;
end;

function tdbcoloredit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
 frame.readonly:= oe_readonly in result;
end;

procedure tdbcoloredit.valuetofield;
begin
 if value = colorty(-1) then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asinteger:= value;
 end;
end;

procedure tdbcoloredit.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= fvaluedefault;
 end
 else begin
  value:= fdatalink.field.asinteger;
 end;
end;

function tdbcoloredit.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).
                    getintegerbuffer(fdatalink.field,cell.row);
   if result = nil then begin
    result:= @fvaluedefault;
   end;
  end
  else begin
   result:= @fvaluedefault;
  end;
 end;
end;

function tdbcoloredit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbcoloredit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbcoloredit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datasource;
end;

procedure tdbcoloredit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdbcoloredit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbcoloredit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbcoloredit.readdatasource(reader: treader);
begin
 treader1(reader).readpropvalue(
         fdatalink,getpropinfo(typeinfo(teditwidgetdatalink),'datasource'));
end;

procedure tdbcoloredit.readdatafield(reader: treader);
begin
 fdatalink.fieldname:= reader.readstring;
end;

procedure tdbcoloredit.readoptionsdb(reader: treader);
begin
 treader1(reader).readpropvalue(
         fdatalink,getpropinfo(typeinfo(teditwidgetdatalink),'options'));
end;

procedure tdbcoloredit.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datasource',{$ifdef FPC}@{$endif}readdatasource,nil,false);
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
 filer.defineproperty('optionsdb',{$ifdef FPC}@{$endif}readoptionsdb,nil,false);
               //move values to datalink
end;

procedure tdbcoloredit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

function tdbcoloredit.internaldatatotext1(const avalue: integer): msestring;
begin
 if avalue = -1 then begin
  result:= '';
 end
 else begin
  result:= inherited internaldatatotext1(avalue);
 end;
end;

end.
