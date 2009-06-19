{ MSEgui Copyright (c) 2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselocaldataset;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,msestrings,msebufdataset,msedb;

const
 defaultlocaldsoptions = defaultdscontrolleroptions + [dso_local,dso_utf8]; 
type
 tlocaldscontroller = class(tdscontroller)
  protected
   procedure setoptions(const avalue: datasetoptionsty); override;   
  public
   constructor create(const aowner: tdataset; const aintf: idscontroller;
                      const arecnooffset: integer = 0;
                      const acancelresync: boolean = true);
  published
   property options default defaultlocaldsoptions;
 end;
 
 tlocaldataset = class(tmsebufdataset,imselocate,idscontroller,igetdscontroller)
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
//   function getblobdatasize: integer;
   function getnumboolean: boolean;
   function getfloatdate: boolean;
   function getint64currency: boolean;
   function getfiltereditkind: filtereditkindty;
   procedure beginfilteredit(const akind: filtereditkindty);
   procedure endfilteredit;
   procedure doidleapplyupdates;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
//   procedure openlocal;
   procedure internalopen; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
   procedure internalclose; override;
   function  getcanmodify: boolean; override;
   function islocal: boolean; override;
   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);

   function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
   function fetch : boolean; override;
   function getblobdatasize: integer; override;
   function blobscached: boolean; override;
   function loadfield(const afieldno: integer; const afieldtype: tfieldtype{const afield: tfield}; 
                const buffer: pointer;
                    var bufsize: integer): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: msestring; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive default false;
   property FieldDefs;
   property BeforeOpen;
   property AfterOpen;
   property BeforeClose;
   property AfterClose;
   property BeforeInsert;
   property AfterInsert;
   property BeforeEdit;
   property AfterEdit;
   property BeforePost;
   property AfterPost;
   property BeforeCancel;
   property AfterCancel;
   property BeforeDelete;
   property AfterDelete;
   property BeforeScroll;
   property AfterScroll;
   property OnCalcFields;
   property OnDeleteError;
   property OnEditError;
   property OnFilterRecord;
   property OnNewRecord;
   property OnPostError;
   property AutoCalcFields;
 end;
 
implementation

{ tlocaldscontroller }

constructor tlocaldscontroller.create(const aowner: tdataset;
               const aintf: idscontroller; const arecnooffset: integer = 0;
               const acancelresync: boolean = true);
begin
 inherited;
 foptions:= defaultlocaldsoptions;
end;

procedure tlocaldscontroller.setoptions(const avalue: datasetoptionsty);
begin
 inherited setoptions(avalue + [dso_local]);
end;

{ tlocaldataset }

constructor tlocaldataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tlocaldscontroller.create(self,idscontroller(self),-1,false);
end;

destructor tlocaldataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tlocaldataset.locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tlocaldataset.locate(const key: msestring;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tlocaldataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tlocaldataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tlocaldataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tlocaldataset.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tlocaldataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tlocaldataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

procedure tlocaldataset.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

function tlocaldataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tlocaldataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tlocaldataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tlocaldataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tlocaldataset.cancel;
begin
 fcontroller.cancel;
end;

function tlocaldataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tlocaldataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tlocaldataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tlocaldataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tlocaldataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tlocaldataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tlocaldataset.inheritedpost;
begin
 inherited post;
end;

procedure tlocaldataset.post;
begin
 fcontroller.post;
end;

procedure tlocaldataset.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tlocaldataset.internaldelete;
begin
 fcontroller.internaldelete;
end;
{
procedure tlocaldataset.openlocal;
begin
 inherited internalopen;
end;
}
procedure tlocaldataset.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tlocaldataset.internalclose;
begin
 fcontroller.internalclose;
end;

function tlocaldataset.getblobdatasize: integer;
begin
 result:= sizeof(int64); //max
end;

function tlocaldataset.getnumboolean: boolean;
begin
 result:= true;
end;

function tlocaldataset.getfloatdate: boolean;
begin
 result:= true;
end;

function tlocaldataset.getint64currency: boolean;
begin
 result:= true;
end;

function tlocaldataset.getfiltereditkind: filtereditkindty;
begin
 result:= fek_filter;
end;

procedure tlocaldataset.beginfilteredit(const akind: filtereditkindty);
begin
 //dummy
end;

procedure tlocaldataset.endfilteredit;
begin
 //dummy
end;

procedure tlocaldataset.doidleapplyupdates;
begin
 //dummy
end;

function tlocaldataset.getcanmodify: boolean;
begin
 result:= fcontroller.getcanmodify;
end;

function tlocaldataset.fetch: boolean;
begin
 result:= false;
end;

function tlocaldataset.blobscached: boolean;
begin
 result:= false;
end;

function tlocaldataset.islocal: boolean;
begin
 result:= true;
end;

function tlocaldataset.loadfield(const afieldno: integer;
               const afieldtype: tfieldtype; const buffer: pointer;
               var bufsize: integer): boolean;
begin
 result:= false;
end;

function tlocaldataset.CreateBlobStream(Field: TField;
               Mode: TBlobStreamMode): TStream;
var
 info: blobcacheinfoty; 
 int1: integer;
 blob1: blobinfoty;
begin
 result:= inherited createblobstream(field,mode);
 if result = nil then begin
  if (bs_blobsfetched in fbstate) and (mode = bmread) then begin
   info.id:= 0; //fieldsize can be 32 bit
   if field.getdata(@info.id) and findcachedblob(info) then begin
    blob1.data:= pointer(info.data);
    blob1.datalength:= length(info.data);
    result:= tblobcopy.create(blob1);
   end;
  end
  else begin
   if mode = bmwrite then begin
    result:= createblobbuffer(field);
   end;
  end;
 end;
end;

procedure tlocaldataset.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;

end.
