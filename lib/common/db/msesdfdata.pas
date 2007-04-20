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
   procedure inheritedinternalclose;
   function getblobdatasize: integer;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure openlocal;
   procedure internalopen; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
   procedure internalclose; override;
  public
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
   procedure inheritedinternalclose;
   function getblobdatasize: integer;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure openlocal;
   procedure internalopen; override;
   procedure internalclose; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
  public
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

procedure tmsefixedformatdataset.openlocal;
begin
 inherited internalopen;
end;

procedure tmsefixedformatdataset.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsefixedformatdataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsefixedformatdataset.getblobdatasize: integer;
begin
 result:= 0; //no blobs
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

procedure tmsesdfdataset.openlocal;
begin
 inherited internalopen;
end;

procedure tmsesdfdataset.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsesdfdataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsesdfdataset.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

end.
