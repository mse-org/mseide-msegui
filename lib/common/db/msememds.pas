{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msememds;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,memds,msedb,msestrings,mseapplication;
type
 tmsememdataset = class(tmemdataset,imselocate,idscontroller,igetdscontroller,
                               iactivatorclient)
  private
   fcontroller: tdscontroller;
   ftagpo: pointer;
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
   function getnumboolean: boolean;
   function getfloatdate: boolean;
   function getint64currency: boolean;
   function getfiltereditkind: filtereditkindty;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   procedure doidleapplyupdates;
   function getrestorerecno: boolean;
   procedure setrestorerecno(const avalue: boolean);
   function updatesortfield(const afield: tfield; const adescend: boolean): boolean;
  protected
   procedure setactive (const value : boolean); reintroduce;
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure openlocal;
   procedure internalopen; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
   procedure internalclose; override;
   function  getcanmodify: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function islastrecord: boolean;
   procedure begindisplaydata;
   procedure enddisplaydata;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const afields: array of tfield;
       const akeys: array of const; const aisnull: array of boolean;
       const akeyoptions: array of locatekeyoptionsty;
       const aoptions: locaterecordoptionsty = []): locateresultty; reintroduce;
{
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
}
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
 end;
 
implementation

{ tmsememdataset }

constructor tmsememdataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsememdataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsememdataset.locate(const afields: array of tfield;
                   const akeys: array of const; const aisnull: array of boolean;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,afields,akeys,aisnull,akeyoptions,aoptions);
end;
{
function tmsememdataset.locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsememdataset.locate(const key: msestring;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;
}
procedure tmsememdataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsememdataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsememdataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsememdataset.setactive(const value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited setactive(value);
 end;
end;

procedure tmsememdataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsememdataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsememdataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsememdataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsememdataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsememdataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsememdataset.cancel;
begin
 fcontroller.cancel;
end;

function tmsememdataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsememdataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsememdataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsememdataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsememdataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsememdataset.internalopen;
begin
 if getrecordsize = 0 then begin
  createtable;
 end;
 fcontroller.internalopen;
end;

procedure tmsememdataset.inheritedpost;
begin
 inherited post;
end;

procedure tmsememdataset.post;
begin
 fcontroller.post;
end;

procedure tmsememdataset.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsememdataset.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsememdataset.openlocal;
begin
 inherited internalopen;
end;

procedure tmsememdataset.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsememdataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsememdataset.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tmsememdataset.getnumboolean: boolean;
begin
 result:= true;
end;

function tmsememdataset.getfloatdate: boolean;
begin
 result:= false;
end;

function tmsememdataset.getint64currency: boolean;
begin
 result:= false;
end;

function tmsememdataset.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmsememdataset.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmsememdataset.endfilteredit;
begin
 //dummy
end;

procedure tmsememdataset.doidleapplyupdates;
begin
 //dummy
end;

function tmsememdataset.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;

procedure tmsememdataset.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

function tmsememdataset.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmsememdataset.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmsememdataset.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

procedure tmsememdataset.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

function tmsememdataset.updatesortfield(const afield: tfield;
               const adescend: boolean): boolean;
begin
 result:= false;
end;

procedure tmsememdataset.begindisplaydata;
begin
 //dummy
end;

procedure tmsememdataset.enddisplaydata;
begin
 //dummy
end;

end.
