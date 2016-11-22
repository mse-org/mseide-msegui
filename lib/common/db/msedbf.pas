{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbf;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
{$warnings off}
 classes,mclasses,mdb,mdbf,msedb,msestrings,dbf_idxfile,mseapplication;
{$warnings on}
 
type
 tmsedbf = class(tdbf,imselocate,idscontroller,igetdscontroller,
            iactivatorclient)
  private
   ffilepath: filenamety;
   fcontroller: tdscontroller;
   ftagpo: pointer;
   procedure setfilepath(const avalue: filenamety);
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
//   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   procedure inheriteddelete();
   procedure inheritedinsert();
   function inheritedmoveby(const distance: integer): integer;
   procedure inheritedinternalinsert;
   procedure inheritedinternaldelete;
   procedure inheritedinternalopen;
   procedure inheritedinternalclose;
   function getblobdatasize: integer;
   function getnumboolean: boolean;
   function getfloatdate: boolean;
   function getint64currency: boolean;
   function getsavepointoptions(): savepointoptionsty;
   function getfiltereditkind: filtereditkindty;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   procedure clearfilter;
//   procedure doidleapplyupdates;
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
   procedure internalclose; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
   function  getcanmodify: boolean; override;
//   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
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
   function moveby(const distance: integer): integer;
   procedure cancel; override;
   procedure post; override;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property FilePath: filenamety read ffilepath write setfilepath;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property AutocalcFields default false;
   property FilterOptions default [];
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
{
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
}
function tmsedbf.locate(const afields: array of tfield;
                   const akeys: array of const; const aisnull: array of boolean;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= msedb.locaterecord(self,afields,akeys,aisnull,akeyoptions,aoptions);
end;

procedure tmsedbf.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsedbf.setfilepath(const avalue: filenamety);
begin
 ffilepath:= tomsefilepath(avalue);
 inherited filepath:= ansistring(
           tosysfilepath(msefileutils.filepath(avalue,fk_default,true)));
end;

procedure tmsedbf.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsedbf.setactive(const value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited setactive(value);
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

function tmsedbf.getsavepointoptions(): savepointoptionsty;
begin
 result:= [];
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

procedure tmsedbf.clearfilter;
begin
 //dummy
end;
{
procedure tmsedbf.doidleapplyupdates;
begin
 //dummy
end;
}
function tmsedbf.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;
{
procedure tmsedbf.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;
}
function tmsedbf.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmsedbf.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmsedbf.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

function tmsedbf.updatesortfield(const afield: tfield;
               const adescend: boolean): boolean;
begin
 result:= false;
end;

procedure tmsedbf.begindisplaydata;
begin
 //dummy
end;

procedure tmsedbf.enddisplaydata;
begin
 ///dummy
end;

procedure tmsedbf.inheriteddelete;
begin
 inherited delete();
end;

procedure tmsedbf.inheritedinsert;
begin
 inherited insert();
end;

end.
