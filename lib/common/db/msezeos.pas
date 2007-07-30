unit msezeos;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,ZDataset,msedb,ZStoredProcedure;
type
 tmsezreadonlyquery = class(tzreadonlyquery,imselocate,idscontroller,
                               igetdscontroller,isqlpropertyeditor)
   private
   fcontroller: tdscontroller;
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
  protected
   procedure setactive (value : boolean);{ override;}
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
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
 tmsezquery = class(tzquery,imselocate,idscontroller,igetdscontroller,
                          isqlpropertyeditor)
   private
   fcontroller: tdscontroller;
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
  protected
   procedure setactive (value : boolean);{ override;}
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
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
 tmseztable = class(tztable,imselocate,idscontroller,igetdscontroller)
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
   function getnumboolean: boolean;
  protected
   procedure setactive (value : boolean);{ override;}
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
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;

 tmsezstoredproc = class(tzstoredproc,imselocate,idscontroller,igetdscontroller)
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
   function getnumboolean: boolean;
  protected
   procedure setactive (value : boolean);{ override;}
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
                   const aoptions: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const aoptions: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
implementation

{ tmsezreadonlyquery }

constructor tmsezreadonlyquery.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsezreadonlyquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsezreadonlyquery.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezreadonlyquery.locate(const key: string;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

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

{ tmsezquery }

constructor tmsezquery.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsezquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsezquery.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezquery.locate(const key: string;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

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

{ tmseztable }

constructor tmseztable.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmseztable.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmseztable.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmseztable.locate(const key: string;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

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

function tmsezstoredproc.locate(const key: integer; const field: tfield;
                   const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

function tmsezstoredproc.locate(const key: string;
        const field: tfield; const aoptions: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,aoptions);
end;

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

end.
