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
 
 sqlquerystatety = (sqs_userapplayrecupdate,sqs_updateabort,sqs_updateerror,
                    sqs_calcfieldsdone);
 sqlquerystatesty = set of sqlquerystatety;
 applyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; const updatekind: tupdatekind;
                        var asql: string; var done: boolean) of object;
 updateerroreventty = procedure(const sender: tmsesqlquery;
                          const aupdatekind: tupdatekind;
                          var aupdateaction: tupdateaction) of object;
                          
 tblobbuffer = class(tmemorystream)
  private
   fowner: tmsesqlquery;
   ffield: tfield;
  public
   constructor create(const aowner: tmsesqlquery; const afield: tfield);
   destructor destroy; override;
 end;
 
 blobinfoty = record
  field: tfield;
  data: pointer;
  datalength: integer;
 end;
 blobinfoarty = array of blobinfoty;

 imsesqlconnection = interface(inullinterface)
                ['{947B58E1-0CA4-436D-A06F-2174D8CA676F}']
  procedure writeblob(const atransaction: tsqltransaction; const tablename: string;
                         const ablob: blobinfoty; const aparam: tparam);
              //returns blobid in param
 end;
   
 tmsesqlquery = class(tsqlquery,imselocate,idscontroller,igetdscontroller)
  private
   fsqlonchangebefore: tnotifyevent;
   fcontroller: tdscontroller;
   fmstate: sqlquerystatesty;
   fonapplyrecupdate: applyrecupdateeventty;
   fwantedreadonly: boolean;
   ffailedcount: integer;
   fapplyindex: integer; //take care about canceled updates while applying
   fblobbuffer: blobinfoarty;
   fconnintf: imsesqlconnection;
   fblobwritten: boolean;
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
   function getindexdefs: TIndexDefs;
   procedure setindexdefs(const avalue: TIndexDefs);
   function getetstatementtype: TStatementType;
   procedure setstatementtype(const avalue: TStatementType);
   procedure afterapply;
   procedure internalapplyupdate(const maxerrors: integer; 
                    var arec: trecupdatebuffer; var response: tresolverresponse);
   procedure internalApplyUpdates(MaxErrors: Integer);
   procedure freeblob(const ablob: blobinfoty);
   procedure freeblobs;
   procedure addblob(const ablob: tblobbuffer);
   
                    //for workarounds
   procedure cancelrecupdate(var arec: trecupdatebuffer);
   function GetRecordUpdateBuffer : boolean;
   function GetFieldSize(FieldDef : TFieldDef) : longint;
   Procedure ApplyRecUpdate1(UpdateKind : TUpdateKind);
   
  protected
   procedure ClearCalcFields(Buffer: PChar); override;
   function  AllocRecordBuffer: PChar; override;
   function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
   procedure SetFieldData(Field: TField; Buffer: Pointer); override;
   function GetRecord(Buffer: PChar; GetMode: TGetMode;
                  DoCheck: Boolean): TGetResult; override;
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
   procedure GetCalcFields(Buffer: PChar); override;
       //idscontroller
//   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   function inheritedmoveby(const distance: integer): integer;  
   procedure inheritedinternalinsert;
   procedure inheritedinternalopen;
   
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
   procedure applyupdates(maxerrors: integer); override;
   procedure applyupdate; //applies current record
   procedure cancel; override;
   procedure cancelupdates; override;
   procedure cancelupdate; //cancels current record
   function moveby(const distance: integer): integer;
   function createblobbuffer(const afield: tfield): tblobbuffer;
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
   property IndexDefs : TIndexDefs read getindexdefs write setindexdefs;
               //must be writable because it is streamed
   property StatementType : TStatementType read getetstatementtype 
                                  write setstatementtype;
               //must be writable because it was streamed in FPC 2.0.4
 end;

 idbparaminfo = interface(inullinterface)['{D0EDEE1E-A4CC-DA11-9F9B-00C0CA1308FF}']
  function getdestdataset: tsqlquery;
 end;
 
 tfieldparamlink = class;

 setparameventty = procedure(const sender: tfieldparamlink;
                        var done: boolean) of object;  
                        
 tparamsourcedatalink = class(tfielddatalink)
  private
   fowner: tfieldparamlink;
   fparamset: boolean;
  protected
   procedure recordchanged(afield: tfield); override;
  public
   constructor create(const aowner: tfieldparamlink);
   procedure loaded;
 end;
 
 fieldparamlinkoptionty = (fplo_autorefresh);
 fieldparamlinkoptionsty = set of fieldparamlinkoptionty;
const
 defaultfieldparamlinkoptions = [fplo_autorefresh];
 
type  
 tfieldparamlink = class(tmsecomponent,idbeditinfo,idbparaminfo)
  private
   fsourcedatalink: tparamsourcedatalink;
   fdestdatasource: tdatasource;
   fparamname: string;
   fonsetparam: setparameventty;
   fonaftersetparam: notifyeventty;
   foptions: fieldparamlinkoptionsty;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   function getvisualcontrol: boolean;
   procedure setvisualcontrol(const avalue: boolean);
   function getdestdataset: tsqlquery;
   procedure setdestdataset(const avalue: tsqlquery);
  protected
   procedure loaded; override;
   //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
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
   property options: fieldparamlinkoptionsty read foptions write foptions
                      default defaultfieldparamlinkoptions;
   property onsetparam: setparameventty read fonsetparam write fonsetparam;
   property onaftersetparam: notifyeventty read fonaftersetparam
                                  write fonaftersetparam;
 end;

 tsequencelink = class;
 
 tsequencedatalink = class(tfielddatalink)
  private
   fowner: tsequencelink;
  protected
   procedure updatedata; override;
  public
   constructor create(const aowner: tsequencelink);
 end;
  
 tsequencelink = class(tmsecomponent,idbeditinfo)
  private
   fsequencename: string;
   fdatabase: tdatabase;
   fdbintf: idbcontroller;
   fdatalink: tfielddatalink;
   procedure checkintf;
   procedure setdatabase(const avalue: tdatabase);
   procedure setsequencename(const avalue: string);
   function getaslargeint: largeint;
   procedure setaslargeint(const avalue: largeint);
   function getasinteger: integer;
   procedure setasinteger(const avalue: integer);
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property aslargeint: largeint read getaslargeint write setaslargeint;
   property asinteger: integer read getasinteger write setasinteger;
   function assql: string;
  published
   property database: tdatabase read fdatabase write setdatabase;
   property datasource: tdatasource read getdatasource write setdatasource;
   property datafield: string read getdatafield write setdatafield;
   property sequencename: string read fsequencename write setsequencename;
 end;
 
implementation
uses
 msestrings,dbconst,msesysutils,typinfo,sysutils,msedatalist;
 
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

    FFieldBufPositions : array of longint;
    
    FAllPacketsFetched : boolean;
    FOnUpdateError  : TResolverErrorEvent;

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
  
function GetFieldIsNull(NullMask : pbyte;x : longint) : boolean; //inline;
begin
  result := ord(NullMask[x div 8]) and (1 shl (x mod 8)) > 0
end;

procedure unSetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) and not (1 shl (x mod 8));
end;

procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
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
 freeblobs;
 fcontroller.free;
 inherited;
end;

function tmsesqlquery.getindexdefs: TIndexDefs;
begin
 result:= inherited indexdefs;
end;

procedure tmsesqlquery.setindexdefs(const avalue: TIndexDefs);
begin
 inherited indexdefs.assign(avalue);
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

procedure tmsesqlquery.inheritedinternalopen;
begin
 inherited internalopen;
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
 if database <> nil then begin
  getcorbainterface(database,typeinfo(imsesqlconnection),fconnintf);
 end;
 fcontroller.internalopen;
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
var
 int1: integer;
begin
 with tbufdatasetcracker(self) do begin
  for int1:= high(fupdatebuffer) downto 0 do begin
   with fupdatebuffer[int1] do begin
    if bookmarkdata <> nil then begin
     freerecordbuffer(oldvaluesbuffer);
    end;
   end;
  end;
  fupdatebuffer:= nil;
  inherited;
  ffirstrecbuf:= nil;
  bindfields(false);
  fconnintf:= nil;
 end;
end;

procedure tmsesqlquery.setonapplyrecupdate(const avalue: applyrecupdateeventty);
begin
 checkinactive;
 if assigned(avalue) and not (csdesigning in componentstate) then begin
  include(fmstate,sqs_userapplayrecupdate);
 end
 else begin
  exclude(fmstate,sqs_userapplayrecupdate);
 end;
 fonapplyrecupdate:= avalue;
 if not assigned(avalue) and not inherited parsesql then begin
  tsqlquerycracker(self).freadonly:= true;
 end;
end;

function tmsesqlquery.getcanmodify: Boolean;
begin
 result:= inherited getcanmodify or not readonly and 
               (sqs_userapplayrecupdate in fmstate);
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

Procedure TmseSQLQuery.ApplyRecUpdate1(UpdateKind : TUpdateKind);

var
    s : string;

  procedure UpdateWherePart(var sql_where : string;x : integer);

  begin
   with tsqlquerycracker(self) do begin
    if (pfInKey in Fields[x].ProviderFlags) or
       ((FUpdateMode = upWhereAll) and (pfInWhere in Fields[x].ProviderFlags)) or
       ((FUpdateMode = UpWhereChanged) and (pfInWhere in Fields[x].ProviderFlags) and (fields[x].value <> fields[x].oldvalue)) then
      sql_where := sql_where + '(' + fields[x].FieldName + '= :OLD_' + fields[x].FieldName + ') and ';
   end;
  end;

  function ModifyRecQuery : string;

  var x          : integer;
      sql_set    : string;
      sql_where  : string;

  begin
   with tsqlquerycracker(self) do begin
    sql_set := '';
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      begin
      UpdateWherePart(sql_where,x);

      if (pfInUpdate in Fields[x].ProviderFlags) then
        sql_set := sql_set + fields[x].FieldName + '=:' + fields[x].FieldName + ',';
      end;

    setlength(sql_set,length(sql_set)-1);
    setlength(sql_where,length(sql_where)-5);
    result := 'update ' + FTableName + ' set ' + sql_set + ' where ' + sql_where;
   end;
  end;

  function InsertRecQuery : string;

  var x          : integer;
      sql_fields : string;
      sql_values : string;

  begin
   with tsqlquerycracker(self) do begin
    sql_fields := '';
    sql_values := '';
    for x := 0 to Fields.Count -1 do begin
     with fields[x] do begin
      if not IsNull and 
         (pfInUpdate in ProviderFlags) then begin //fpc bug 7565
       sql_fields := sql_fields + FieldName + ',';
       sql_values := sql_values + ':' + FieldName + ',';
      end;
     end;
    end;
    setlength(sql_fields,length(sql_fields)-1);
    setlength(sql_values,length(sql_values)-1);

    result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' + sql_values + ')';
   end;
  end;

  function DeleteRecQuery : string;

  var x          : integer;
      sql_where  : string;

  begin
   with tsqlquerycracker(self) do begin
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      UpdateWherePart(sql_where,x);

    setlength(sql_where,length(sql_where)-5);

    result := 'delete from ' + FTableName + ' where ' + sql_where;
   end;
  end;

var qry : tsqlquery;
    x   : integer;
    Fld : TField;
 int1: integer;
    
begin
 with tsqlquerycracker(self) do begin
    case UpdateKind of
      ukModify : begin
                 qry := FUpdateQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(ModifyRecQuery);
                 end;
      ukInsert : begin
                 qry := FInsertQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(InsertRecQuery);
                 end;
      ukDelete : begin
                 qry := FDeleteQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(DeleteRecQuery);
                 end;
    end;
  with qry do
    begin
    for x := 0 to Params.Count-1 do with params[x] do if leftstr(name,4)='OLD_' then
      begin
      Fld := self.FieldByName(copy(name,5,length(name)-4));
      AssignFieldValue(Fld,Fld.OldValue);
      end
    else
      begin
      Fld := self.FieldByName(name);
      if fld is tblobfield and (fconnintf <> nil) then begin
       for int1:= 0 to high(fblobbuffer) do begin
        if fblobbuffer[int1].field = fld then begin
         fblobwritten:= true;
         fconnintf.writeblob(tsqltransaction(transaction),ftablename,
         fblobbuffer[int1],params[x]);
         break;
        end;
       end;
      end
      else begin
       AssignFieldValue(Fld,Fld.Value);
      end;
      end;
    execsql;
    end;
 end;
end;

procedure tmsesqlquery.applyrecupdate(updatekind: tupdatekind);
var
 bo1: boolean;
 str1: string;
begin
 try
  if sqs_userapplayrecupdate in fmstate then begin
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
//   inherited;
  applyrecupdate1(updatekind);
  end;
 except
  include(fmstate,sqs_updateerror);
  raise;
 end;
end;

procedure tmsesqlquery.post;
begin
 inherited;
 if dso_autoapply in fcontroller.options then begin
  applyupdates;
 end;
end;

procedure tmsesqlquery.internalapplyupdate(const maxerrors: integer; 
               var arec: trecupdatebuffer; var response: tresolverresponse);
               
 procedure checkcancel;
 begin
  if dso_cancelupdateonerror in fcontroller.options then begin
   cancelrecupdate(arec);
   arec.bookmarkdata:= nil;
   resync([]);
  end;
 end;
 
var
 EUpdErr: EUpdateError;

begin
 with arec do begin
  Response:= rrApply;
  try
   ApplyRecUpdate(UpdateKind);
  except
   on E: EDatabaseError do begin
    Inc(fFailedCount);
    if longword(ffailedcount) > longword(MaxErrors) then begin
     Response:= rrAbort
    end
    else begin
     Response:= rrSkip;
    end;
    EUpdErr:= EUpdateError.Create(SOnUpdateError,E.Message,0,0,E);
    if assigned(OnUpdateError) then begin
     OnUpdateError(Self,Self,EUpdErr,UpdateKind,Response);
    end
    else begin
     if Response = rrAbort then begin
      checkcancel;
      Raise EUpdErr;
     end;
    end;
    eupderr.free;
   end
   else begin
    raise;
   end;
  end;
  if response = rrApply then begin
   FreeRecordBuffer(OldValuesBuffer);
   BookmarkData := nil;
  end
  else begin
   checkcancel;
  end;
 end;
end;

procedure tmsesqlquery.internalApplyUpdates(MaxErrors: Integer);

var
 SaveBookmark: pchar;
//    r            : Integer;
// FailedCount: integer;
// EUpdErr: EUpdateError;
 Response: TResolverResponse;
 StoreRecBuf: PBufRecLinkItem;

begin
 with tbufdatasetcracker(self) do begin
  CheckBrowseMode;
  StoreRecBuf := FCurrentRecBuf;
  try
   fapplyindex := 0;
   fFailedCount := 0;
   Response := rrApply;
   while (fapplyindex <= high(FUpdateBuffer)) and (Response <> rrAbort) do begin
    with FUpdateBuffer[fapplyindex] do begin
     if assigned(BookmarkData) then begin
      InternalGotoBookmark(@BookmarkData);
      Resync([rmExact,rmCenter]);
      internalapplyupdate(maxerrors,FUpdateBuffer[fapplyindex],response);
     end;
     inc(fapplyindex);
    end;
   end;
   if ffailedcount = 0 then begin
    SetLength(FUpdateBuffer,0);
   end;
  finally 
   FCurrentRecBuf := StoreRecBuf;
   Resync([]);
  end;
 end;
end;

procedure tmsesqlquery.afterapply;
begin
 if (dso_autocommitret in fcontroller.options) and (transaction <> nil) then begin
  tsqltransaction(transaction).commitretaining;
 end;
end;

procedure tmsesqlquery.applyupdates(maxerrors: integer);
var
 bm1: pchar;
begin
 fblobwritten:= false;
 checkbrowsemode;
 disablecontrols;
 try
  fmstate:= fmstate - [sqs_updateabort,sqs_updateerror];
  internalapplyupdates(maxerrors);
 finally
  if (sqs_updateerror in fmstate) and 
              (dso_cancelupdatesonerror in fcontroller.options) then begin
   cancelupdates;
  end;
  enablecontrols;
  dataevent(dedatasetchange,0);
 end;
 afterapply;
 if fblobwritten then begin
  active:= false;
  active:= true;
 end;
end;

procedure tmsesqlquery.applyupdate; //applies current record
var
 response: tresolverresponse;
 var int1: integer;
begin
 fblobwritten:= false;
 checkbrowsemode;
 with tbufdatasetcracker(self) do begin
  if (fupdatebuffer <> nil) and (fcurrentrecbuf <> nil) then begin
   for int1:= high(fupdatebuffer) downto 0 do begin
    if fupdatebuffer[int1].bookmarkdata = fcurrentrecbuf then begin
     ffailedcount:= 0;
     internalapplyupdate(0,fupdatebuffer[int1],response);
     if response = rrapply then begin
      afterapply;
      deleteitem(fupdatebuffer,typeinfo(trecordsupdatebuffer),int1);
      fcurrentupdatebuffer:= bigint; //invalid
     end;
    end;
   end;
  end;
 end;
 if fblobwritten then begin
  active:= false;
  active:= true;
 end;
end;

procedure tmsesqlquery.cancelrecupdate(var arec: trecupdatebuffer);
     //copied from bufdataset.inc
begin
 with tbufdatasetcracker(self),arec do begin
  if bookmarkdata <> nil then begin
   case updatekind of
    ukmodify: begin
     move(pchar(OldValuesBuffer+sizeof(TBufRecLinkItem))^,
            pchar(BookmarkData+sizeof(TBufRecLinkItem))^,FRecordSize);
     FreeRecordBuffer(OldValuesBuffer);
    end;
    ukdelete: begin
     if assigned(PBufRecLinkItem(BookmarkData)^.prior) then  begin
              // or else it was the first record
      PBufRecLinkItem(BookmarkData)^.prior^.next:= BookmarkData
     end
     else begin
      FFirstRecBuf:= BookmarkData;
     end;
     PBufRecLinkItem(BookmarkData)^.next^.prior:= BookmarkData;
     inc(FBRecordCount);
    end;
    ukInsert: begin
     if assigned(PBufRecLinkItem(BookmarkData)^.prior) then begin
      // or else it was the first record
      PBufRecLinkItem(BookmarkData)^.prior^.next:= 
                           PBufRecLinkItem(BookmarkData)^.next;
     end
     else begin
      FFirstRecBuf := PBufRecLinkItem(BookmarkData)^.next;
     end;
     PBufRecLinkItem(BookmarkData)^.next^.prior:= 
                                   PBufRecLinkItem(BookmarkData)^.prior;
     // resync won't work if the currentbuffer is freed...
     if FCurrentRecBuf = BookmarkData then begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
     end;
     FreeRecordBuffer(BookmarkData);
     dec(FBRecordCount);
    end;
   end;
  end;
 end;
end;


procedure tmsesqlquery.cancelupdates;
var 
 int1: integer;
begin
 cancel;
 checkbrowsemode;
 with tbufdatasetcracker(self) do begin
  if fupdatebuffer <> nil then begin
   for int1:= high(fupdatebuffer) downto 0 do begin
    cancelrecupdate(fupdatebuffer[int1]);
   end;
   fupdatebuffer:= nil;
   resync([]);
  end;
 end;
end;

procedure tmsesqlquery.cancelupdate;
var 
 int1: integer;
begin
 cancel;
 checkbrowsemode;
 with tbufdatasetcracker(self) do begin
  if (fupdatebuffer <> nil) and (fcurrentrecbuf <> nil) then begin
   for int1:= high(fupdatebuffer) downto 0 do begin
    if fupdatebuffer[int1].bookmarkdata = fcurrentrecbuf then begin
     cancelrecupdate(fupdatebuffer[int1]);
     deleteitem(fupdatebuffer,typeinfo(trecordsupdatebuffer),int1);
     if int1 <= fapplyindex then begin
      dec(fapplyindex);
     end;
     resync([]);
     break;
    end;
   end;
  end;
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
 if dso_autoapply in fcontroller.options then begin
  applyupdates;
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

function tmsesqlquery.getetstatementtype: TStatementType;
begin
 result:= inherited statementtype;
end;

procedure tmsesqlquery.setstatementtype(const avalue: TStatementType);
begin
 //dummy
end;

function tmsesqlquery.GetRecordUpdateBuffer : boolean;
var 
 x: integer;
 CurrBuff: PChar;

begin
 with tbufdatasetcracker(self) do begin
  GetBookmarkData(ActiveBuffer,@CurrBuff);
  if (FCurrentUpdateBuffer >= length(FUpdateBuffer)) or 
       (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData <> CurrBuff) then begin
   for x:= 0 to high(FUpdateBuffer) do begin
    if FUpdateBuffer[x].BookmarkData = CurrBuff then begin
     FCurrentUpdateBuffer:= x;
     break;
    end;
   end;
  end;
  Result:= (FCurrentUpdateBuffer < length(FUpdateBuffer))  and 
     (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData = CurrBuff);
 end;
end;

function tmsesqlquery.GetFieldSize(FieldDef : TFieldDef) : longint;
begin
 case FieldDef.DataType of
  ftString,ftFixedChar: result:= FieldDef.Size + 1;
  ftSmallint,ftInteger,ftword: result:= sizeof(longint);
  ftBoolean: result:= sizeof(wordbool);
  ftBCD: result:= sizeof(currency);
  ftFloat: result:= sizeof(double);
  ftLargeInt: result:= sizeof(largeint);
  ftTime,ftDate,ftDateTime: result:= sizeof(TDateTime)
  else Result := 10
 end;
end;

function tmsesqlquery.AllocRecordBuffer: PChar;
begin
 with tbufdatasetcracker(self) do begin
  result := AllocMem(FRecordsize + sizeof(TBufBookmark) + calcfieldssize);
 end;
end;

function tmsesqlquery.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var 
 CurrBuff : pchar;
begin
 Result := False;
 with tbufdatasetcracker(self) do begin
  if state = dscalcfields then begin
   currbuff:= calcbuffer;
  end
  else begin
   CurrBuff := ActiveBuffer;
  end;
  If Field.Fieldno > 0 then begin 
        // If = 0, then calculated field or something similar
   if state = dsOldValue then begin
    if not GetRecordUpdateBuffer then begin
        // There is no old value available
     exit;
    end;
    currbuff := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer+
                            sizeof(TBufRecLinkItem);
   end
   else begin
    if not assigned(CurrBuff) then begin
     exit;
    end;
   end;
   if GetFieldIsnull(pbyte(CurrBuff),Field.Fieldno-1) then begin
    exit;
   end;
   inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
   if assigned(buffer) then begin
    Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
   end;
   Result := True;
  end
  else begin //calc or lookup field
   if currbuff <> nil then begin
    currbuff:= currbuff + FRecordsize + sizeof(TBufBookmark) + field.offset;
    if (currbuff + field.datasize)^ <> #0 then begin
     result:= true;
     if buffer <> nil then begin
      move(currbuff^,buffer^,field.datasize);
     end;
    end;
   end;
  end;
 end;
end;

procedure tmsesqlquery.SetFieldData(Field: TField; Buffer: Pointer);

var 
 CurrBuff : pointer;
 NullMask : pbyte;

begin
 with tbufdatasetcracker(self) do begin
//  if not (state in [dsEdit, dsInsert, dsFilter]) then begin
  if not (state in dswritemodes) then begin
   DatabaseErrorFmt(SNotInEditState,[NAme],self);
   exit;
  end;
  if state = dscalcfields then begin
   currbuff:= calcbuffer;
  end
  else begin
   CurrBuff := ActiveBuffer;
  end;
  If Field.Fieldno > 0 then begin // If = 0, then calculated field or something
   if state = dsFilter then begin 
    // Set the value into the 'temporary' FLastRecBuf buffer for Locate and Lookup
      CurrBuff := pointer(FLastRecBuf) + sizeof(TBufRecLinkItem)
   end;
   NullMask := CurrBuff;
   inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
   if assigned(buffer) then begin
    Move(Buffer^, CurrBuff^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
    unSetFieldIsNull(NullMask,Field.FieldNo-1);
   end
   else begin
    SetFieldIsNull(NullMask,Field.FieldNo-1);
   end;     
   if not (State in [dsCalcFields, dsFilter, dsNewValue]) then begin
    DataEvent(deFieldChange, Ptrint(Field));
   end;
  end
  else begin //calc or lookup field
   currbuff:= currbuff + FRecordsize + sizeof(TBufBookmark) + field.offset;
   if buffer <> nil then begin
    pchar(currbuff+field.datasize)^:= #1;
    move(buffer^,currbuff^,field.datasize);
   end
   else begin
    pchar(currbuff+field.datasize)^:= #0;
   end;
  end;
 end;
end;

procedure tmsesqlquery.GetCalcFields(Buffer: PChar);
begin
 include(fmstate,sqs_calcfieldsdone);
 inherited;
end;

function tmsesqlquery.GetRecord(Buffer: PChar; GetMode: TGetMode;
               DoCheck: Boolean): TGetResult;
begin
 exclude(fmstate,sqs_calcfieldsdone);
 result:= inherited getrecord(buffer,getmode,docheck);
 if (result = grok) and not (sqs_calcfieldsdone in fmstate) then begin
  getcalcfields(buffer);
 end;
end;

procedure tmsesqlquery.ClearCalcFields(Buffer: PChar);
begin
 with tbufdatasetcracker(self) do begin
  fillchar((buffer+FRecordsize + sizeof(TBufBookmark))^,calcfieldssize,0);
 end;
end;

function tmsesqlquery.createblobbuffer(const afield: tfield): tblobbuffer;
var
 int1: integer;
begin
 for int1:= 0 to high(fblobbuffer) do begin
  if fblobbuffer[int1].field = afield then begin
   freeblob(fblobbuffer[int1]);
   deleteitem(fblobbuffer,typeinfo(blobinfoarty),int1);
  end;
 end;
 result:= tblobbuffer.create(self,afield);
end;

procedure tmsesqlquery.freeblob(const ablob: blobinfoty);
begin
 with ablob do begin
  if datalength > 0 then begin
   freemem(data);
  end;
 end;
end;

procedure tmsesqlquery.freeblobs;
var
 int1: integer;
begin
 for int1:= 0 to high(fblobbuffer) do begin
  freeblob(fblobbuffer[int1]);
 end;
 fblobbuffer:= nil;
end;

procedure tmsesqlquery.addblob(const ablob: tblobbuffer);
begin
 setlength(fblobbuffer,high(fblobbuffer)+2);
 with fblobbuffer[high(fblobbuffer)],ablob do begin
  data:= memory;
  datalength:= size;
  field:= ffield;
 end;
end;

{ tparamsourcedatalink }

constructor tparamsourcedatalink.create(const aowner: tfieldparamlink);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tparamsourcedatalink.recordchanged(afield: tfield);
var
 bo1: boolean;
begin
 if not (csloading in fowner.componentstate) then begin
  inherited;
  if active and (field <> nil) and
                ((afield = nil) or (afield = self.field)) then begin
   with fowner do begin
    if not (csdesigning in componentstate) then begin
     fparamset:= true;
     bo1:= false;
     if assigned(fonsetparam) then begin
      fonsetparam(fowner,bo1);
     end;
     if not bo1 and (fparamname <> '') and (dataset <> nil) then begin
      fieldtoparam(self.field,param);
     end;
     if assigned(fonaftersetparam) then begin
      fonaftersetparam(fowner);
     end;
     if (fplo_autorefresh in foptions) and (destdataset <> nil) and 
                          destdataset.active then begin
      destdataset.active:= false;
      destdataset.active:= true;     
     end;
    end;
   end;
  end;
 end;
end;

procedure tparamsourcedatalink.loaded;
begin
 if not fparamset then begin
  recordchanged(nil);
 end;
end;

{ tfieldparamlink }

constructor tfieldparamlink.create(aowner: tcomponent);
begin
 foptions:= defaultfieldparamlinkoptions;
 fsourcedatalink:= tparamsourcedatalink.create(self);
 fdestdatasource:= tdatasource.create(nil);
 inherited;
end;

destructor tfieldparamlink.destroy;
begin
 inherited;
 fsourcedatalink.free;
 fdestdatasource.free;
end;

function tfieldparamlink.getdatafield: string;
begin
 result:= fsourcedatalink.fieldname;
end;

procedure tfieldparamlink.setdatafield(const avalue: string);
begin
 fsourcedatalink.fieldname:= avalue;
end;

function tfieldparamlink.getdatasource: tdatasource;
begin
 result:= fsourcedatalink.datasource;
end;

procedure tfieldparamlink.setdatasource(const avalue: tdatasource);
begin
 fsourcedatalink.datasource:= avalue;
end;

function tfieldparamlink.getvisualcontrol: boolean;
begin
 result:= fsourcedatalink.visualcontrol;
end;

procedure tfieldparamlink.setvisualcontrol(const avalue: boolean);
begin
 fsourcedatalink.visualcontrol:= avalue;
end;

function tfieldparamlink.getdestdataset: tsqlquery;
begin
 result:= tsqlquery(fdestdatasource.dataset);
end;

procedure tfieldparamlink.setdestdataset(const avalue: tsqlquery);
begin
 fdestdatasource.dataset:= avalue;
end;

function tfieldparamlink.param: tparam;
begin
 if fdestdatasource.dataset = nil then begin
  databaseerror(name+': No destdataset');
 end
 else begin
  result:= tsqlquery(fdestdatasource.dataset).params.findparam(fparamname);
  if result = nil then begin
   databaseerror(name+': param "'+fparamname+'" not found');
  end;
 end;
end;

function tfieldparamlink.field: tfield;
begin
 result:= fsourcedatalink.field;
end;

procedure tfieldparamlink.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 fieldtypes:= nil;
end;

procedure tfieldparamlink.loaded;
begin
 inherited;
 fsourcedatalink.loaded;
end;

function tfieldparamlink.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

{ tsequencedatalink }

constructor tsequencedatalink.create(const aowner: tsequencelink);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tsequencedatalink.updatedata;
begin
 inherited;
 if (field <> nil) and field.isnull and (dataset <> nil) and 
                                               (dataset.modified) then begin
  if field is tlargeintfield then begin
   field.aslargeint:= fowner.aslargeint;
  end
  else begin
   field.asinteger:= fowner.asinteger;
  end;
 end;
end;

{ tsequencelink }

constructor tsequencelink.create(aowner: tcomponent);
begin
 fdatalink:= tsequencedatalink.create(self);
 inherited;
end;

destructor tsequencelink.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tsequencelink.setdatabase(const avalue: tdatabase);
begin
 if fdatabase <> avalue then begin
  fdbintf:= nil;
  if fdatabase <> nil then begin
   fdatabase.removefreenotification(self);
  end;
  if avalue <> nil then begin
   avalue.freenotification(self);
   mseclasses.getcorbainterface(avalue,typeinfo(idbcontroller),fdbintf);
  end;
  fdatabase:= avalue;
 end;
end;

procedure tsequencelink.setsequencename(const avalue: string);
begin
 fsequencename:= avalue;
end;

procedure tsequencelink.notification(acomponent: tcomponent;
               operation: toperation);
begin
 inherited;
 if (acomponent = fdatabase) and (operation = opremove) then begin
  fdatabase:= nil;
 end;
end;

procedure tsequencelink.checkintf;
begin
 if fdbintf = nil then begin
  raise edatabaseerror.create('Database has no idscontroller interface.');
 end;
end;

function tsequencelink.getaslargeint: largeint;
var                       //todo: optimize
 ds1: tsqlquery;
begin
 checkintf;
 ds1:= tsqlquery.create(nil);
 try
  ds1.parsesql:= false;
  ds1.sql.add(fdbintf.readsequence(fsequencename));
  ds1.database:= fdatabase;
  ds1.active:= true;
  result:= ds1.fields[0].aslargeint;
 finally
  ds1.free;
 end;
end;

procedure tsequencelink.setaslargeint(const avalue: largeint);
begin
 checkintf;
 fdbintf.executedirect(
   fdbintf.writesequence(fsequencename,avalue));
end;

function tsequencelink.getasinteger: integer;
begin
 result:= getaslargeint;
end;

procedure tsequencelink.setasinteger(const avalue: integer);
begin
 setaslargeint(avalue); 
end;

function tsequencelink.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tsequencelink.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
 if (csdesigning in componentstate) and (fdatabase = nil) and 
      (fdatalink.dataset is tdbdataset) then begin
  database:= tdbdataset(fdatalink.dataset).database;
 end;
end;

function tsequencelink.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tsequencelink.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

procedure tsequencelink.getfieldtypes(out propertynames: stringarty;
               out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

function tsequencelink.assql: string;
begin
 result:= inttostr(aslargeint);
end;

function tsequencelink.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

{ tblobbuffer }

constructor tblobbuffer.create(const aowner: tmsesqlquery;
               const afield: tfield);
begin
 fowner:= aowner;
 ffield:= afield;
 inherited create;
end;

destructor tblobbuffer.destroy;
begin
 fowner.addblob(self);
 setpointer(nil,0);
 inherited;
end;

end.
