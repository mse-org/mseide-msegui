{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesdfdata;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,sdfdata,msedb,msestrings;
type
 tmsefixedformatdataset = class(tfixedformatdataset,imselocate,
                             idscontroller,igetdscontroller)
  private
   ffilename: filenamety;
   fcontroller: tdscontroller;
   procedure setfilename(const avalue: filenamety);
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
//   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   function inheritedmoveby(const distance: integer): integer;
   procedure inheritedinternalinsert;
   procedure inheritedinternaldelete;
   procedure inheritedinternalopen;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure internalopen; override;
   procedure internalinsert; override;
   procedure internaldelete; override;

   procedure DoAfterCancel; override;
   procedure DoAfterClose; override;
   procedure DoAfterDelete; override;
   procedure DoAfterEdit; override;
   procedure DoAfterInsert; override;
   procedure DoAfterOpen; override;
   procedure DoAfterPost; override;
   procedure DoAfterScroll; override;
   procedure DoAfterRefresh; override;
   procedure DoBeforeCancel; override;
   procedure DoBeforeClose; override;
   procedure DoBeforeDelete; override;
   procedure DoBeforeEdit; override;
   procedure DoBeforeInsert; override;
   procedure DoBeforeOpen; override;
   procedure DoBeforePost; override;
   procedure DoBeforeScroll; override;
   procedure DoBeforeRefresh; override;
   procedure DoOnCalcFields; override;
   procedure DoOnNewRecord; override;

  public
//   procedure Resync(Mode: TResyncMode); override;

   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property FileName: filenamety read ffilename write setfilename;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
 tmsesdfdataset = class(tsdfdataset,imselocate,idscontroller,igetdscontroller)
  private
   ffilename: filenamety;
   fcontroller: tdscontroller;
   procedure setfilename(const avalue: filenamety);
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
//   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   function inheritedmoveby(const distance: integer): integer;
   procedure inheritedinternalinsert;
   procedure inheritedinternaldelete;
   procedure inheritedinternalopen;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure internalopen; override;
   procedure internalinsert; override;
   procedure internaldelete; override;

   procedure DoAfterCancel; override;
   procedure DoAfterClose; override;
   procedure DoAfterDelete; override;
   procedure DoAfterEdit; override;
   procedure DoAfterInsert; override;
   procedure DoAfterOpen; override;
   procedure DoAfterPost; override;
   procedure DoAfterScroll; override;
   procedure DoAfterRefresh; override;
   procedure DoBeforeCancel; override;
   procedure DoBeforeClose; override;
   procedure DoBeforeDelete; override;
   procedure DoBeforeEdit; override;
   procedure DoBeforeInsert; override;
   procedure DoBeforeOpen; override;
   procedure DoBeforePost; override;
   procedure DoBeforeScroll; override;
   procedure DoBeforeRefresh; override;
   procedure DoOnCalcFields; override;
   procedure DoOnNewRecord; override;

  public
//   procedure Resync(Mode: TResyncMode); override;

   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty= []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
  function moveby(const distance: integer): integer;
  published
   property FileName: filenamety read ffilename write setfilename;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
implementation
uses
 msefileutils;

{ tmsefixedformatdataset }

constructor tmsefixedformatdataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsefixedformatdataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsefixedformatdataset.locate(const key: integer; const field: tfield;
                    const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsefixedformatdataset.locate(const key: string;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsefixedformatdataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsefixedformatdataset.setfilename(const avalue: filenamety);
begin
 ffilename:= tomsefilepath(avalue);
 inherited filename:= tosysfilepath(filepath(avalue,fk_default,true));
end;

procedure tmsefixedformatdataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsefixedformatdataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsefixedformatdataset.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsefixedformatdataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsefixedformatdataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsefixedformatdataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsefixedformatdataset.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;
{
procedure tmsefixedformatdataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsefixedformatdataset.Resync(Mode: TResyncMode);
begin
 fcontroller.resync(mode);
end;
}
procedure tmsefixedformatdataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsefixedformatdataset.cancel;
begin
 fcontroller.cancel;
end;

function tmsefixedformatdataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsefixedformatdataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsefixedformatdataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

procedure tmsefixedformatdataset.DoAfterCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterPost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoAfterRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforePost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoBeforeRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoOnCalcFields;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.DoOnNewRecord;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsefixedformatdataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsefixedformatdataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsefixedformatdataset.inheritedpost;
begin
 inherited post;
end;

procedure tmsefixedformatdataset.post;
begin
 fcontroller.post;
end;

function tmsefixedformatdataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsefixedformatdataset.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsefixedformatdataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

{ tmsesdfdataset }

constructor tmsesdfdataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsesdfdataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsesdfdataset.locate(const key: integer; const field: tfield;
                               const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsesdfdataset.locate(const key: string;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsesdfdataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsesdfdataset.setfilename(const avalue: filenamety);
begin
 ffilename:= tomsefilepath(avalue);
 inherited filename:= tosysfilepath(filepath(avalue,fk_default,true));
end;

procedure tmsesdfdataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsesdfdataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesdfdataset.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsesdfdataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsesdfdataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsesdfdataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsesdfdataset.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{
procedure tmsesdfdataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsesdfdataset.Resync(Mode: TResyncMode);
begin
 fcontroller.resync(mode);
end;
}
procedure tmsesdfdataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsesdfdataset.cancel;
begin
 fcontroller.cancel;
end;

function tmsesdfdataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsesdfdataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsesdfdataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

procedure tmsesdfdataset.DoAfterCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterPost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoAfterRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforePost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoBeforeRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoOnCalcFields;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.DoOnNewRecord;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesdfdataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsesdfdataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsesdfdataset.inheritedpost;
begin
 inherited post;
end;

procedure tmsesdfdataset.post;
begin
 fcontroller.post;
end;

function tmsesdfdataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsesdfdataset.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsesdfdataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

end.
