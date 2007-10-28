{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msedbdialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,msefiledialog,db,mseinplaceedit,msedbedit,msegui,msewidgetgrid,
 msedatalist,mseeditglob,msegrids,msetypes,msedb,msemenus,mseedit,
 msedataedits,mseevent,msestrings;
 
type
 tdbfilenameedit = class(tcustomfilenameedit,idbeditfieldlink,idbeditinfo,
                                      ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource; overload;
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
  protected

   procedure editnotification(var info: editnotificationinfoty); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   function getoptionsedit: optionseditty; override;

   function getrowdatapo(const info: cellinfoty): pointer; override;
   //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
   //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function checkvalue(const quiet: boolean = false): boolean; override;
   property datalink: teditwidgetdatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;

   property frame;
   property passwordchar;
   property maxlength;
//   property value;
   property onsetvalue;
   property controller;
 end;
 
implementation
type
 teditwidgetdatalink1 = class(teditwidgetdatalink);
 
{ tdbfilenameedit }

constructor tdbfilenameedit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbfilenameedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbfilenameedit.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbfilenameedit.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbfilenameedit.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbfilenameedit.setdatasource(const avalue: tdatasource);
begin
 teditwidgetdatalink1(fdatalink).setwidgetdatasource(avalue);
end;

function tdbfilenameedit.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= inherited checkvalue(quiet) and fdatalink.dataentered;
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

procedure tdbfilenameedit.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= textfields;
end;

function tdbfilenameedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus) and 
            teditwidgetdatalink1(fdatalink).nullcheckneeded;
end;

function tdbfilenameedit.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
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

end.
