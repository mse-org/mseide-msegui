{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqlite3ds;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,sqlite3ds,msedb;
type
 tmsesqlite3dataset = class(tsqlite3dataset,imselocate,idscontroller,igetdscontroller)
  private
   fcontroller: tdscontroller;
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
   procedure inheritedresync(const mode: tresyncmode);
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
   procedure setactive (value : boolean);
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
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
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
implementation

type
 tsqlite3dscontroller = class(tdscontroller)
  public
   constructor create(const aowner: tdataset; const aintf: idscontroller;
                      const arecnooffset: integer = 0;
                      const acancelresync: boolean = true);
  published
   property options default defaultdscontrolleroptions + [dso_utf8];
 end;
 
{ tsqlite3dscontroller }

constructor tsqlite3dscontroller.create(const aowner: tdataset;
               const aintf: idscontroller; const arecnooffset: integer = 0;
               const acancelresync: boolean = true);
begin
 inherited;
 options:= options + [dso_utf8];
end;

{ tmsesqlite3dataset }

constructor tmsesqlite3dataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tsqlite3dscontroller.create(self,idscontroller(self));
end;

destructor tmsesqlite3dataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsesqlite3dataset.locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsesqlite3dataset.locate(const key: string;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsesqlite3dataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsesqlite3dataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsesqlite3dataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesqlite3dataset.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsesqlite3dataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsesqlite3dataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsesqlite3dataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsesqlite3dataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsesqlite3dataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsesqlite3dataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsesqlite3dataset.cancel;
begin
 fcontroller.cancel;
end;

function tmsesqlite3dataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsesqlite3dataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsesqlite3dataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsesqlite3dataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsesqlite3dataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsesqlite3dataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsesqlite3dataset.inheritedpost;
begin
 inherited post;
end;

procedure tmsesqlite3dataset.post;
begin
 fcontroller.post;
end;

procedure tmsesqlite3dataset.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsesqlite3dataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsesqlite3dataset.openlocal;
begin
 inherited internalopen;
end;

procedure tmsesqlite3dataset.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsesqlite3dataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsesqlite3dataset.getblobdatasize: integer;
begin
 result:= 0; //no blobid
end;

end.

