{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbf;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,dbf,msedb,msestrings,dbf_idxfile;
 
type
 tmsedbf = class(tdbf,imselocate,idscontroller,igetdscontroller)
  private
   ffilepath: filenamety;
   fcontroller: tdscontroller;
   procedure setfilepath(const avalue: filenamety);
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
   function getnumboolean: boolean;
   function getfloatdate: boolean;
   function getint64currency: boolean;
   function getfiltereditkind: filtereditkindty;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   procedure doidleapplyupdates;
  protected
   procedure setactive (value : boolean); {override;}
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
   function locate(const key: msestring; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   function moveby(const distance: integer): integer;
   procedure cancel; override;
   procedure post; override;
  published
   property FilePath: filenamety read ffilepath write setfilepath;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
implementation
uses
 msefileutils;
 
{ tmsedbf }

constructor tmsedbf.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1);
end;

destructor tmsedbf.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsedbf.locate(const key: integer; const field: tfield;
                           const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsedbf.locate(const key: msestring; const field: tfield;
                        const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsedbf.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsedbf.setfilepath(const avalue: filenamety);
begin
 ffilepath:= tomsefilepath(avalue);
 inherited filepath:= tosysfilepath(msefileutils.filepath(avalue,fk_default,true));
end;

procedure tmsedbf.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsedbf.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

function tmsedbf.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsedbf.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsedbf.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

procedure tmsedbf.cancel;
begin
 fcontroller.cancel;
end;

function tmsedbf.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsedbf.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsedbf.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{
procedure tmsedbf.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsedbf.Resync(Mode: TResyncMode);
begin
 fcontroller.resync(mode);
end;
}
procedure tmsedbf.inheritedcancel;
begin
 inherited cancel;
end;

function tmsedbf.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

function tmsedbf.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsedbf.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsedbf.internalinsert;
begin
 fcontroller.internalinsert;
end;

procedure tmsedbf.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsedbf.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsedbf.inheritedpost;
begin
 inherited post;
end;

procedure tmsedbf.post;
begin
 fcontroller.post;
end;

procedure tmsedbf.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsedbf.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsedbf.openlocal;
begin
 inherited internalopen;
end;

procedure tmsedbf.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsedbf.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsedbf.getblobdatasize: integer;
begin
 result:= 0; //no blobid?
end;

function tmsedbf.getnumboolean: boolean;
begin
 result:= false;
end;

function tmsedbf.getfloatdate: boolean;
begin
 result:= false;
end;

function tmsedbf.getint64currency: boolean;
begin
 result:= false;
end;

function tmsedbf.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmsedbf.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmsedbf.endfilteredit;
begin
 //dummy
end;

procedure tmsedbf.doidleapplyupdates;
begin
 //dummy
end;

end.
