{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqldb;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,sqldb,msedb,mseclasses,msetypes,mseguiglob;
  
type

// TUpdateAction = (uaFail, uaAbort, uaSkip, uaRetry, uaApplied);

 tmsesqltransaction = class(tsqltransaction)
  private
   fcontroller: ttacontroller;
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure setcontroller(const avalue: ttacontroller);
  protected
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property Active : boolean read getactive write setactive;
   property controller: ttacontroller read fcontroller write setcontroller;
 end;

 tmsesqlquery = class;
 
 sqlquerystatety = (sqs_userapplayrecupdate,sqs_updateabort);
 sqlquerystatesty = set of sqlquerystatety;
 applyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; const updatekind: tupdatekind;
                        var asql: string; var done: boolean) of object;
 updateerroreventty = procedure(const sender: tmsesqlquery;
                          const aupdatekind: tupdatekind;
                          var aupdateaction: tupdateaction) of object;
 
 tmsesqlquery = class(tsqlquery,imselocate,idscontroller,igetdscontroller)
  private
   fsqlonchangebefore: tnotifyevent;
   fcontroller: tdscontroller;
   fstate: sqlquerystatesty;
   fonapplyrecupdate: applyrecupdateeventty;
   fwantedreadonly: boolean;
   procedure setcontroller(const avalue: tdscontroller);
   procedure setactive(value : boolean); {override;}
   function getactive: boolean;
   procedure setonapplyrecupdate(const avalue: applyrecupdateeventty);
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   function getparsesql: boolean;
   procedure setparsesql(const avalue: boolean);
   function recupdatesql(updatekind : tupdatekind): string;
   function getcontroller: tdscontroller;
  protected
   procedure updateindexdefs; override;
   procedure sqlonchange(sender: tobject);
   procedure loaded; override;
   procedure internalopen; override;
   procedure internalclose; override;
   procedure internalinsert; override;
   procedure internalpost; override;
   procedure applyrecupdate(updatekind: tupdatekind); override;
   function  getcanmodify: boolean; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
       //idscontroller
//   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   function inheritedmoveby(const distance: integer): integer;  
   procedure inheritedinternalinsert;
   
   procedure dataevent(event: tdataevent; info: ptrint); override;
   
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
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure appendrecord(const values: array of const);
   procedure post; override;
   procedure applyupdates(maxerror: integer); override;
   procedure cancel; override;
   procedure cancelupdates; override;
   function moveby(const distance: integer): integer;
  published
   property FieldDefs;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
   property onapplyrecupdate: applyrecupdateeventty read fonapplyrecupdate
                                  write setonapplyrecupdate;
   property ParseSQL: boolean read getparsesql write setparsesql default true;
   property ReadOnly: boolean read getreadonly write setreadonly default false;
   property UpdateMode default upWhereKeyOnly;
   property UsePrimaryKeyAsKey default true;
 end;

 idbparaminfo = interface(inullinterface)['{D0EDEE1E-A4CC-DA11-9F9B-00C0CA1308FF}']
  function getdestdataset: tsqlquery;
 end;
 
 tfieldparamlink = class;

 setparameventty = procedure(const sender: tfieldparamlink;
                        var done: boolean) of object;  
                        
 tparamdatalink = class(tfielddatalink)
  private
   fowner: tfieldparamlink;
  protected
   procedure recordchanged(afield: tfield); override;
  public
   constructor create(const aowner: tfieldparamlink);
 end;
 
 tfieldparamlink = class(tmsecomponent,idbeditinfo,idbparaminfo)
  private
   fdatalink: tparamdatalink;
   fdatasource: tdatasource;
   fparamname: string;
   fonsetparam: setparameventty;
   fonaftersetparam: notifyeventty;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   function getvisualcontrol: boolean;
   procedure setvisualcontrol(const avalue: boolean);
   function getdestdataset: tsqlquery;
   procedure setdestdataset(const avalue: tsqlquery);
  protected
   //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function param: tparam;
   function field: tfield;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visualcontrol: boolean read getvisualcontrol 
                    write setvisualcontrol default false;
   property destdataset: tsqlquery read getdestdataset write setdestdataset;
   property paramname: string read fparamname write fparamname;
   property onsetparam: setparameventty read fonsetparam write fonsetparam;
   property onaftersetparam: notifyeventty read fonaftersetparam
                                  write fonaftersetparam;
 end;
 
implementation
uses
 msestrings,dbconst,msesysutils,typinfo;
 
type 
  TBufDatasetcracker = class(TDBDataSet)
  private
    FCurrentRecBuf  : PBufRecLinkItem;
    FLastRecBuf     : PBufRecLinkItem;
    FFirstRecBuf    : PBufRecLinkItem;
    FBRecordCount   : integer;

    FPacketRecords  : integer;
    FRecordSize     : Integer;
    FNullmaskSize   : byte;
    FOpen           : Boolean;
    FUpdateBuffer   : TRecordsUpdateBuffer;
    FCurrentUpdateBuffer : integer;

  end;
  
  TSQLQuerycracker = class (Tbufdataset)
  private
    FCursor              : TSQLCursor;
    FUpdateable          : boolean;
    FTableName           : string;
    FSQL                 : TStringList;
    FUpdateSQL,
    FInsertSQL,
    FDeleteSQL           : TStringList;
    FIsEOF               : boolean;
    FLoadingFieldDefs    : boolean;
    FIndexDefs           : TIndexDefs;
    FReadOnly            : boolean;
    FUpdateMode          : TUpdateMode;
    FParams              : TParams;
    FusePrimaryKeyAsKey  : Boolean;
    FSQLBuf              : String;
    FFromPart            : String;
    FWhereStartPos       : integer;
    FWhereStopPos        : integer;
    FParseSQL            : boolean;
    FMasterLink          : TMasterParamsDatalink;
//    FSchemaInfo          : TSchemaInfo;

    FUpdateQry,
    FDeleteQry,
    FInsertQry           : TSQLQuery;
  end;
  
{ tmsesqltransaction }

constructor tmsesqltransaction.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= ttacontroller.create(self);
end;

destructor tmsesqltransaction.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsesqltransaction.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesqltransaction.setactive(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited active:= avalue;
 end;
end;

procedure tmsesqltransaction.setcontroller(const avalue: ttacontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsesqltransaction.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

{ tmsesqlquery }

constructor tmsesqlquery.create(aowner: tcomponent);
begin
 inherited;
// updatemode:= upwhereall;
 if params = nil then begin
  params:= tparams.create(self); //for 2.0.2
 end;
 fsqlonchangebefore:= sql.onchange;
 sql.onchange:= {$ifdef FPC}@{$endif}sqlonchange;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1);
end;

destructor tmsesqlquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

procedure tmsesqlquery.updateindexdefs;
begin
 indexdefs.clear;
 inherited;
end;

function tmsesqlquery.locate(const key: integer; const field: tfield;
                      const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;
                     
function tmsesqlquery.locate(const key: string; const field: tfield; 
                      const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsesqlquery.appendrecord(const values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsesqlquery.sqlonchange(sender: tobject);
begin
 if (csdesigning in componentstate) and active then begin
  active:= false;
  fsqlonchangebefore(sender);
  active:= true;
 end
 else begin
  fsqlonchangebefore(sender);
 end;
end;

procedure tmsesqlquery.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsesqlquery.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.loaded;
begin
 if not fwantedreadonly and assigned(fonapplyrecupdate) then begin
  readonly:= false;
 end;
 inherited;
 fcontroller.loaded;
end;

function tmsesqlquery.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesqlquery.internalopen;

 procedure initmodifyquery(var aquery: tsqlquery; const asql: tstringlist);
 begin
  if aquery = nil then begin
   aquery:= tsqlquery.create(nil);
   with aquery do begin
    parsesql:= false;
    database:= self.database;
    transaction:= self.transaction;
    sql.Assign(asql);
   end;
  end;
 end;

begin
 inherited;
 bindfields(true);
     //queries are nil if not defaultfields
 with tsqlquerycracker(self) do begin
  if fupdateable then begin
   initmodifyquery(fdeleteqry,deletesql);
   initmodifyquery(fupdateqry,updatesql);
   initmodifyquery(finsertqry,insertsql);
  end;
 end;  
end;

procedure tmsesqlquery.internalclose;
begin
 inherited;
 tbufdatasetcracker(self).ffirstrecbuf:= nil;
 bindfields(false);
end;

procedure tmsesqlquery.setonapplyrecupdate(const avalue: applyrecupdateeventty);
begin
 checkinactive;
 if assigned(avalue) and not (csdesigning in componentstate) then begin
  include(fstate,sqs_userapplayrecupdate);
 end
 else begin
  exclude(fstate,sqs_userapplayrecupdate);
 end;
 fonapplyrecupdate:= avalue;
 if not assigned(avalue) and not inherited parsesql then begin
  tsqlquerycracker(self).freadonly:= true;
 end;
end;

function tmsesqlquery.getcanmodify: Boolean;
begin
 result:= inherited getcanmodify or not readonly and 
               (sqs_userapplayrecupdate in fstate);
end;

function tmsesqlquery.recupdatesql(updatekind: tupdatekind): string;

 procedure updatewherepart(var sql_where: string; x: integer);
 begin
  if (pfinkey in fields[x].providerflags) or
       ((pfinwhere in fields[x].providerflags) and 
        ((updatemode = upwhereall) or
         (updatemode = upwherechanged) and (pfinwhere in fields[x].providerflags)
                 and fieldchanged(fields[x])
        )
       ) then begin
   sql_where:= sql_where + '(' + fields[x].fieldname + '=' + 
            fieldtooldsql(fields[x]) + ') and ';
   end;
  end;

  function modifyrecquery : string;
  var
   x: integer;
   sql_set: string;
   sql_where: string;
  begin
   sql_set := '';
   sql_where := '';
   for x := 0 to fields.count -1 do begin
    updatewherepart(sql_where,x);
    if (pfinupdate in fields[x].providerflags) then begin
     sql_set := sql_set + fields[x].fieldname + '=' + fieldtosql(fields[x]) + ',';
    end;
   end;
   setlength(sql_set,length(sql_set)-1);
   setlength(sql_where,length(sql_where)-5);
   result:= 'update ' + tsqlquerycracker(self).ftablename + 
         ' set ' + sql_set + ' where ' + sql_where;
  end;

  function insertrecquery: string;
  var 
   x: integer;
   sql_fields: string;
   sql_values: string;

  begin
   sql_fields := '';
   sql_values := '';
   for x := 0 to fields.count -1 do begin
    if not fields[x].IsNull then begin
     sql_fields := sql_fields + fields[x].fieldname + ',';
     sql_values := sql_values + fieldtosql(fields[x]) + ',';
    end;
   end;
   setlength(sql_fields,length(sql_fields)-1);
   setlength(sql_values,length(sql_values)-1);
   result := 'insert into ' + tsqlquerycracker(self).ftablename + 
               ' (' + sql_fields + ') values (' + sql_values + ')';
  end;

  function deleterecquery : string;
  var
   x: integer;
   sql_where: string;
  begin
   sql_where := '';
   for x := 0 to fields.Count -1 do begin
    updatewherepart(sql_where,x);
   end;
   setlength(sql_where,length(sql_where)-5);
   result := 'delete from ' + tsqlquerycracker(self).ftablename +
                     ' where ' + sql_where;
  end;

begin
 result:= '';
 case updatekind of
  ukmodify: result:= modifyrecquery;
  ukinsert: result:= insertrecquery;
  ukdelete: result:= deleterecquery;
 end;
end;

procedure tmsesqlquery.applyrecupdate(updatekind: tupdatekind);
var
 bo1: boolean;
 str1: string;
begin
 if sqs_userapplayrecupdate in fstate then begin
  bo1:= false;
  fonapplyrecupdate(self,updatekind,str1,bo1);
  if not bo1 then begin
   if str1 = '' then begin
    inherited;
   end
   else begin
{$ifdef debugsqlquery}  
    debugwriteln(getenumname(typeinfo(tupdatekind),ord(updatekind))+' '+str1);
{$endif}  
    tsqlconnection(database).executedirect(str1,tsqltransaction(transaction));
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tmsesqlquery.post;
begin
 inherited;
 if dso_autoapply in fcontroller.options then begin
  applyupdates;
 end;
end;

procedure tmsesqlquery.applyupdates(maxerror: integer);
begin
 disablecontrols;
 try
  exclude(fstate,sqs_updateabort);
  inherited;
 finally
  enablecontrols;
 end;
 dataevent(dedatasetchange,0);
 if (dso_autocommitret in fcontroller.options) and (transaction <> nil) then begin
  tsqltransaction(transaction).commitretaining;
 end;
end;

function tmsesqlquery.getreadonly: boolean;
begin
 result:= inherited readonly;
end;

function tmsesqlquery.getparsesql: boolean;
begin
 result:= inherited parsesql;
end;

procedure tmsesqlquery.setreadonly(const avalue: boolean);
begin
 checkinactive;
 fwantedreadonly:= avalue;
 if not avalue then begin
  if not (inherited parsesql or assigned(fonapplyrecupdate)) then begin
   databaseerrorfmt(snoparsesql,['Updating ']);
  end;
 end;
 tsqlquerycracker(self).freadonly:= avalue;
end;

procedure tmsesqlquery.setparsesql(const avalue: boolean);
var
 bo1: boolean;
begin
 bo1:= inherited readonly;
 inherited parsesql:= avalue;
 if not bo1 and assigned(fonapplyrecupdate) then begin
  tsqlquerycracker(self).freadonly:= false;
 end;
end;

function tmsesqlquery.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

procedure tmsesqlquery.cancel;
begin
 fcontroller.cancel;
end;

procedure tmsesqlquery.cancelupdates;
begin
 cancel;
 inherited;
end;

procedure tmsesqlquery.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;
{
procedure tmsesqlquery.Resync(Mode: TResyncMode);
begin
 fcontroller.resync(mode);
end;

procedure tmsesqlquery.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;
}
function tmsesqlquery.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsesqlquery.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsesqlquery.inheritedcancel;
begin
 inherited cancel;
end;

function tmsesqlquery.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

function tmsesqlquery.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsesqlquery.internalinsert;
begin
 fcontroller.internalinsert;
end;

procedure tmsesqlquery.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsesqlquery.DoAfterCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterPost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoAfterRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforePost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoBeforeRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoOnCalcFields;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.DoOnNewRecord;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsesqlquery.internalpost;
begin        //workaround for FPC bug 7266
 with tbufdatasetcracker(self) do begin
  if (state = dsinsert) and (ffirstrecbuf = flastrecbuf) then begin
   setbookmarkdata(activebuffer,@ffirstrecbuf);
   inherited;
  end
  else begin
   inherited;
  end;
 end;
end;

{ tparamdatalink }

constructor tparamdatalink.create(const aowner: tfieldparamlink);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tparamdatalink.recordchanged(afield: tfield);
var
 bo1: boolean;
begin
 inherited;
 if active and (field <> nil) and
               ((afield = nil) or (afield = self.field)) then begin
  with fowner do begin
   bo1:= false;
   if assigned(fonsetparam) and not (csdesigning in componentstate) then begin
    fonsetparam(fowner,bo1);
   end;
   if not bo1 and (fparamname <> '') and (fdatasource.dataset <> nil) then begin
    fieldtoparam(self.field,param);
   end;
   if assigned(fonaftersetparam) and not (csdesigning in componentstate) then begin
    fonaftersetparam(fowner);
   end;
  end;
 end;
end;

{ tfieldparamlink }

constructor tfieldparamlink.create(aowner: tcomponent);
begin
 fdatalink:= tparamdatalink.create(self);
 fdatasource:= tdatasource.create(nil);
 inherited;
end;

destructor tfieldparamlink.destroy;
begin
 inherited;
 fdatalink.free;
 fdatasource.free;
end;

function tfieldparamlink.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tfieldparamlink.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tfieldparamlink.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tfieldparamlink.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

function tfieldparamlink.getvisualcontrol: boolean;
begin
 result:= fdatalink.visualcontrol;
end;

procedure tfieldparamlink.setvisualcontrol(const avalue: boolean);
begin
 fdatalink.visualcontrol:= avalue;
end;

function tfieldparamlink.getdestdataset: tsqlquery;
begin
 result:= tsqlquery(fdatasource.dataset);
end;

procedure tfieldparamlink.setdestdataset(const avalue: tsqlquery);
begin
 fdatasource.dataset:= avalue;
end;

function tfieldparamlink.param: tparam;
begin
 if fdatasource.dataset = nil then begin
  databaseerror(name+': No destdataset');
 end
 else begin
  result:= tsqlquery(fdatasource.dataset).params.findparam(fparamname);
  if result = nil then begin
   databaseerror(name+': param "'+fparamname+'" not found');
  end;
 end;
end;

function tfieldparamlink.field: tfield;
begin
 result:= fdatalink.field;
end;

procedure tfieldparamlink.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 fieldtypes:= nil;
end;

end.
