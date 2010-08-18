unit msezeos;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,ZDataset,msedb,ZStoredProcedure,msestrings,msedbgraphics;
type
 tmsezgraphicfield = class(tmsegraphicfield)
  public
   constructor create(aowner: tcomponent); override;
 end;
 
 tmsezreadonlyquery = class(tzreadonlyquery,imselocate,idscontroller,
                               igetdscontroller,isqlpropertyeditor)
   private
   fcontroller: tdscontroller;
   ftagpo: pointer;
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
   function isutf8: boolean;
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
   function  getcanmodify: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function islastrecord: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
{
   function locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
}
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property AutocalcFields default false;
 end;
 
 tmsezquery = class(tzquery,imselocate,idscontroller,igetdscontroller,
                          isqlpropertyeditor)
   private
   fcontroller: tdscontroller;
   ftagpo: pointer;
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
   function isutf8: boolean;
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
   function  getcanmodify: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function islastrecord: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
{
   function locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
}
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property AutocalcFields default false;
 end;
 
 tmseztable = class(tztable,imselocate,idscontroller,igetdscontroller)
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
   function  getcanmodify: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function islastrecord: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
{
   function locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
}
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property AutocalcFields default false;
 end;

 tmsezstoredproc = class(tzstoredproc,imselocate,idscontroller,igetdscontroller)
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
   function  getcanmodify: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function islastrecord: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
{
   function locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
}
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
   property tagpo: pointer read ftagpo write ftagpo;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property AutocalcFields default false;
 end;
 
implementation

{ tmsezreadonlyquery }

constructor tmsezreadonlyquery.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1);
end;

destructor tmsezreadonlyquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsezreadonlyquery.locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,akeys,afields,akeyoptions,aoptions);
end;
{
function tmsezreadonlyquery.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezreadonlyquery.locate(const key: msestring;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;
}
procedure tmsezreadonlyquery.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsezreadonlyquery.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsezreadonlyquery.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsezreadonlyquery.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsezreadonlyquery.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsezreadonlyquery.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsezreadonlyquery.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsezreadonlyquery.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsezreadonlyquery.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsezreadonlyquery.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsezreadonlyquery.cancel;
begin
 fcontroller.cancel;
end;

function tmsezreadonlyquery.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsezreadonlyquery.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsezreadonlyquery.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsezreadonlyquery.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsezreadonlyquery.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsezreadonlyquery.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsezreadonlyquery.inheritedpost;
begin
 inherited post;
end;

procedure tmsezreadonlyquery.post;
begin
 fcontroller.post;
end;

procedure tmsezreadonlyquery.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsezreadonlyquery.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsezreadonlyquery.openlocal;
begin
 inherited internalopen;
end;

procedure tmsezreadonlyquery.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsezreadonlyquery.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsezreadonlyquery.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tmsezreadonlyquery.getnumboolean: boolean;
begin
 result:= true;
end;

function tmsezreadonlyquery.isutf8: boolean;
begin
 result:= fcontroller.isutf8;
end;

function tmsezreadonlyquery.getfloatdate: boolean;
begin
 result:= false;
end;

function tmsezreadonlyquery.getint64currency: boolean;
begin
 result:= false;
end;

function tmsezreadonlyquery.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmsezreadonlyquery.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmsezreadonlyquery.endfilteredit;
begin
 //dummy
end;

procedure tmsezreadonlyquery.doidleapplyupdates;
begin
 //dummy
end;

function tmsezreadonlyquery.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;

procedure tmsezreadonlyquery.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

function tmsezreadonlyquery.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmsezreadonlyquery.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmsezreadonlyquery.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

procedure tmsezreadonlyquery.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{ tmsezquery }

constructor tmsezquery.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1);
end;

destructor tmsezquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsezquery.locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,akeys,afields,akeyoptions,aoptions);
end;
{
function tmsezquery.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezquery.locate(const key: msestring;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;
}
procedure tmsezquery.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsezquery.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsezquery.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsezquery.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsezquery.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsezquery.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsezquery.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsezquery.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsezquery.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsezquery.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsezquery.cancel;
begin
 fcontroller.cancel;
end;

function tmsezquery.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsezquery.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsezquery.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsezquery.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsezquery.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsezquery.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsezquery.inheritedpost;
begin
 inherited post;
end;

procedure tmsezquery.post;
begin
 fcontroller.post;
end;

procedure tmsezquery.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsezquery.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsezquery.openlocal;
begin
 inherited internalopen;
end;

procedure tmsezquery.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsezquery.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsezquery.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tmsezquery.getnumboolean: boolean;
begin
 result:= true;
end;

function tmsezquery.isutf8: boolean;
begin
 result:= fcontroller.isutf8;
end;

function tmsezquery.getfloatdate: boolean;
begin
 result:= false;
end;

function tmsezquery.getint64currency: boolean;
begin
 result:= false;
end;

function tmsezquery.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmsezquery.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmsezquery.endfilteredit;
begin
 //dummy
end;

procedure tmsezquery.doidleapplyupdates;
begin
 //dummy
end;

function tmsezquery.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;

procedure tmsezquery.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

function tmsezquery.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmsezquery.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmsezquery.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

procedure tmsezquery.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{ tmseztable }

constructor tmseztable.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1);
end;

destructor tmseztable.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmseztable.locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,akeys,afields,akeyoptions,aoptions);
end;
{
function tmseztable.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmseztable.locate(const key: msestring;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;
}
procedure tmseztable.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmseztable.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmseztable.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmseztable.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmseztable.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmseztable.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmseztable.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmseztable.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmseztable.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmseztable.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmseztable.cancel;
begin
 fcontroller.cancel;
end;

function tmseztable.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmseztable.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmseztable.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmseztable.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmseztable.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmseztable.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmseztable.inheritedpost;
begin
 inherited post;
end;

procedure tmseztable.post;
begin
 fcontroller.post;
end;

procedure tmseztable.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmseztable.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmseztable.openlocal;
begin
 inherited internalopen;
end;

procedure tmseztable.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmseztable.internalclose;
begin
 fcontroller.internalclose;
end;

function tmseztable.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tmseztable.getnumboolean: boolean;
begin
 result:= true;
end;

function tmseztable.getfloatdate: boolean;
begin
 result:= false;
end;

function tmseztable.getint64currency: boolean;
begin
 result:= false;
end;

function tmseztable.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmseztable.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmseztable.endfilteredit;
begin
 //dummy
end;

procedure tmseztable.doidleapplyupdates;
begin
 //dummy
end;

function tmseztable.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;

procedure tmseztable.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

function tmseztable.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmseztable.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmseztable.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

procedure tmseztable.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{ tmsezstoredproc }

constructor tmsezstoredproc.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsezstoredproc.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsezstoredproc.locate(const akeys: array of const;
                   const afields: array of tfield;
                   const akeyoptions: array of locatekeyoptionsty;
                   const aoptions: locaterecordoptionsty = []): locateresultty;
begin
 result:= locaterecord(self,akeys,afields,akeyoptions,aoptions);
end;
{
function tmsezstoredproc.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezstoredproc.locate(const key: msestring;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;
}
procedure tmsezstoredproc.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsezstoredproc.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsezstoredproc.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsezstoredproc.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsezstoredproc.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsezstoredproc.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsezstoredproc.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsezstoredproc.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsezstoredproc.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsezstoredproc.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsezstoredproc.cancel;
begin
 fcontroller.cancel;
end;

function tmsezstoredproc.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsezstoredproc.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsezstoredproc.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsezstoredproc.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsezstoredproc.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsezstoredproc.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsezstoredproc.inheritedpost;
begin
 inherited post;
end;

procedure tmsezstoredproc.post;
begin
 fcontroller.post;
end;

procedure tmsezstoredproc.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsezstoredproc.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsezstoredproc.openlocal;
begin
 inherited internalopen;
end;

procedure tmsezstoredproc.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsezstoredproc.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsezstoredproc.getblobdatasize: integer;
begin
 result:= 0; //no blobs
end;

function tmsezstoredproc.getnumboolean: boolean;
begin
 result:= true;
end;

function tmsezstoredproc.getfloatdate: boolean;
begin
 result:= false;
end;

function tmsezstoredproc.getint64currency: boolean;
begin
 result:= false;
end;

function tmsezstoredproc.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tmsezstoredproc.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tmsezstoredproc.endfilteredit;
begin
//dummy
end;

procedure tmsezstoredproc.doidleapplyupdates;
begin
 //dummy
end;

function tmsezstoredproc.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify and inherited getcanmodify;
end;

procedure tmsezstoredproc.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

function tmsezstoredproc.getrestorerecno: boolean;
begin
 result:= false;
end;

procedure tmsezstoredproc.setrestorerecno(const avalue: boolean);
begin
 //dummy
end;

function tmsezstoredproc.islastrecord: boolean;
begin
 result:= eof or (recno = recordcount);
end;

procedure tmsezstoredproc.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

{ tmsezgraphicfield }

constructor tmsezgraphicfield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftblob);
end;

end.
