{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

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
 classes,mseguiglob,msefiledialog,db,mseinplaceedit,msedbedit,msegui,
 msewidgetgrid,
 msedatalist,mseeditglob,msegrids,msetypes,msedb,msemenus,mseedit,
 msedataedits,mseevent,msestrings,msecolordialog,msegraphutils,msedialog,
 mseglob;
 
type
 tdbfilenameedit = class(tcustomfilenameedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringeditwidgetdatalink;
   procedure setdatalink(const avalue: tstringeditwidgetdatalink);
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
   function getrowdatapo(const arow: integer): pointer; override;
   function getfieldlink: tcustomeditwidgetdatalink;
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

   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield; virtual;
   procedure fieldtovalue; virtual;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
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

 tdbdialogstringedit = class(tdbstringedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: stringdialogexeceventty;
   procedure setonexecute(const avalue: stringdialogexeceventty);
  protected
   fcontroller: tstringdialogcontroller;
   function createdialogcontroller: tstringdialogcontroller; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: stringdialogexeceventty read getonexecute write setonexecute;
 end;

 tdbmemodialogedit = class(tdbdialogstringedit)
  protected
   function createdialogcontroller: tstringdialogcontroller; override;
  public
 end;

 tdbdialogrealedit = class(tdbrealedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: realdialogexeceventty;
   procedure setonexecute(const avalue: realdialogexeceventty);
  protected
   fdialogcontroller: trealdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: realdialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;

 tdbdialogdatetimeedit = class(tdbdatetimeedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: datetimedialogexeceventty;
   procedure setonexecute(const avalue: datetimedialogexeceventty);
  protected
   fdialogcontroller: tdatetimedialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: datetimedialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;

 tdbdialogintegeredit = class(tdbintegeredit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: integerdialogexeceventty;
   procedure setonexecute(const avalue: integerdialogexeceventty);
  protected
   fdialogcontroller: tintegerdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: integerdialogexeceventty read getonexecute 
                                                        write setonexecute;
 end;
  
implementation
uses
 typinfo,msememodialog; 
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

function tdbfilenameedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
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
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbfilenameedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdbfilenameedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
{$warnings off}
 teditwidgetdatalink1(fdatalink).nullcheckneeded(result);
{$warnings on}
end;

procedure tdbfilenameedit.setdatalink(const avalue: tstringeditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbfilenameedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
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
{$warnings off}
 teditwidgetdatalink1(fdatalink).recordchanged(nil);
{$warnings on}
end;

function tdbfilenameedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
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
  value:= fvaluedefault1;
 end
 else begin
  value:= fdatalink.field.asinteger;
 end;
end;

function tdbcoloredit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).
                   getintegerbuffer(fdatalink.field,arow);
  if result = nil then begin
   result:= @fvaluedefault;
  end;
 end
 else begin
  result:= @fvaluedefault;
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
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
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

procedure tdbcoloredit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
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

function tdbcoloredit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

{ tdbdialogstringedit }

constructor tdbdialogstringedit.create(aowner: tcomponent);
begin
 inherited;
 if fcontroller = nil then begin
  fcontroller:= createdialogcontroller;
 end;
end;

destructor tdbdialogstringedit.destroy;
begin
 inherited;
 fcontroller.free;
end;

function tdbdialogstringedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdbdialogstringedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdbdialogstringedit.getonexecute: stringdialogexeceventty;
begin
 result:= fcontroller.onexecute;
end;

procedure tdbdialogstringedit.setonexecute(const avalue: stringdialogexeceventty);
begin
 fcontroller.onexecute:= avalue;
end;

function tdbdialogstringedit.createdialogcontroller: tstringdialogcontroller;
begin
 result:= tstringdialogcontroller.create(self);
end;

{ tdbmemodialogedit }

function tdbmemodialogedit.createdialogcontroller: tstringdialogcontroller;
begin
 result:= tmemodialogcontroller.create(self);
end;

{ tdbdialogrealedit }

constructor tdbdialogrealedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= trealdialogcontroller.create(self);
 end;
end;

destructor tdbdialogrealedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdbdialogrealedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdbdialogrealedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdbdialogrealedit.getonexecute: realdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdbdialogrealedit.setonexecute(const avalue: realdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tdbdialogdatetimeedit }

constructor tdbdialogdatetimeedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tdatetimedialogcontroller.create(self);
 end;
end;

destructor tdbdialogdatetimeedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdbdialogdatetimeedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdbdialogdatetimeedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdbdialogdatetimeedit.getonexecute: datetimedialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdbdialogdatetimeedit.setonexecute(const avalue: datetimedialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tdbdialogintegeredit }

constructor tdbdialogintegeredit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tintegerdialogcontroller.create(self);
 end;
end;

destructor tdbdialogintegeredit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdbdialogintegeredit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdbdialogintegeredit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdbdialogintegeredit.getonexecute: integerdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdbdialogintegeredit.setonexecute(const avalue: integerdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

end.
