{
    Copyright (c) 2004 by Joost van der Sluis
    Modified 2006-2007 by Martin Schreiber

    SQL database & dataset

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit msqldb;

{$mode objfpc}
{$H+}
{$M+}   // ### remove this!!!
{$interfaces corba}

interface

uses sysutils,classes,db,msebufdataset,msetypes;

type TSchemaType = (stNoSchema,stTables,stSysTables,stProcedures,stColumns,
                    stProcedureParams,stIndexes,stPackages);
     TConnOption = (sqSupportParams);
     TConnOptions= set of TConnOption;

type
 tmseparams = class(tparams)
  public
   function  parsesql(const sql: string; const docreate: boolean; 
          const  parameterstyle : tparamstyle; var parambinding: tparambinding; 
           var replacestring : string): string; overload;
   function  parsesql(const sql: string; const docreate: boolean;
        parameterstyle : tparamstyle; var parambinding: tparambinding): string;
                                                overload;
   function  parsesql(const sql: string; const docreate: boolean;
                            const parameterstyle : tparamstyle): string; overload;
   function  parsesql(const sql: string; const docreate: boolean): string; overload;
 end;
 
  TSQLConnection = class;
  TSQLTransaction = class;
  TSQLQuery = class;

  TStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

  TSQLHandle = Class(TObject)
  end;

  TSQLCursor = Class(TSQLHandle)
  public
    FPrepared      : Boolean;
    FInitFieldDef  : Boolean;
    FStatementType : TStatementType;
    fblobs: stringarty;
    ftrans: pointer;
   function addblobdata(const adata: pointer; const alength: integer): integer;
                                           overload;
   function addblobdata(const adata: string): integer; overload;
   procedure blobfieldtoparam(const afield: tfield; const aparam: tparam;
                    const asstring: boolean = false);
  end;


const
 StatementTokens : Array[TStatementType] of string = ('(none)', 'select',
                  'insert', 'update', 'delete',
                  'create', 'get', 'put', 'execute',
                  'start','commit','rollback', '?'
                 );


{ TSQLConnection }
type

  { TSQLConnection }

  TSQLConnection = class (TDatabase)
  private
    FPassword            : string;
    FTransaction         : TSQLTransaction;
    FUserName            : string;
    FHostName            : string;
    FCharSet             : string;
    FRole                : String;

    procedure SetTransaction(Value : TSQLTransaction);
    procedure GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
  protected
    FConnOptions         : TConnOptions;

    function StrToStatementType(s : string) : TStatementType; virtual;
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetAsSQLText(Field : TField) : string; overload; virtual;
    function GetAsSQLText(Param : TParam) : string; overload; virtual;
    function GetHandle : pointer; virtual; virtual;

    Function AllocateCursorHandle : TSQLCursor; virtual; abstract;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); virtual; abstract;
    Function AllocateTransactionHandle : TSQLHandle; virtual; abstract;

    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); virtual; abstract;
    procedure Execute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
                                 const AParams : TParams); virtual; abstract;
    function Fetch(cursor : TSQLCursor) : boolean; virtual; abstract;
    procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); virtual; abstract;
    procedure UnPrepareStatement(cursor : TSQLCursor); virtual; abstract;

    procedure FreeFldBuffers(cursor : TSQLCursor); virtual; abstract;
    function loadfield(const cursor: tsqlcursor; const afield: tfield;
      const buffer: pointer; var bufsize: integer): boolean; virtual; abstract;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    function GetTransactionHandle(trans : TSQLHandle): pointer; virtual; abstract;
    function Commit(trans : TSQLHandle) : boolean; virtual; abstract;
    function RollBack(trans : TSQLHandle) : boolean; virtual; abstract;
    function StartdbTransaction(trans : TSQLHandle; aParams : string) : boolean; virtual; abstract;
    procedure CommitRetaining(trans : TSQLHandle); virtual; abstract;
    procedure RollBackRetaining(trans : TSQLHandle); virtual; abstract;
    function getblobdatasize: integer; virtual; abstract;

    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string); virtual;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; virtual;
    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream; virtual;
  public
    property Handle: Pointer read GetHandle;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure EndTransaction; override;
    property ConnOptions: TConnOptions read FConnOptions;
    procedure ExecuteDirect(const SQL : String); overload; virtual;
    procedure ExecuteDirect(SQL : String; const ATransaction : TSQLTransaction); 
                                                       overload; virtual;
    procedure GetTableNames(List : TStrings; SystemTables : Boolean = false); virtual;
    procedure GetProcedureNames(List : TStrings); virtual;
    procedure GetFieldNames(const TableName : string; List :  TStrings); virtual;
  published
    property Password : string read FPassword write FPassword;
    property Transaction : TSQLTransaction read FTransaction write SetTransaction;
    property UserName : string read FUserName write FUserName;
    property CharSet : string read FCharSet write FCharSet;
    property HostName : string Read FHostName Write FHostName;

    property Connected: boolean read getconnected write setconnected default false;
    Property Role :  String read FRole write FRole;
    property DatabaseName;
    property KeepConnection;
    property LoginPrompt;
    property Params;
    property OnLogin;
  end;

{ TSQLTransaction }

  TCommitRollbackAction = (caNone, caCommit, caCommitRetaining, caRollback,
    caRollbackRetaining);

  TSQLTransaction = class (TDBTransaction)
  private
    FTrans               : TSQLHandle;
    FAction              : TCommitRollbackAction;
    FParams              : TStringList;
   procedure setparams(const avalue: TStringList);
  protected
    function GetHandle : Pointer; virtual;
    Procedure SetDatabase (Value : TDatabase); override;
    procedure disconnect(const sender: tsqlquery);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Commit; virtual;
    procedure CommitRetaining; virtual;
    procedure Rollback; virtual;
    procedure RollbackRetaining; virtual;
    procedure StartTransaction; override;
    property Handle: Pointer read GetHandle;
    procedure EndTransaction; override;
  published
    property Action : TCommitRollbackAction read FAction write FAction;
    property Database;
    property Params : TStringList read FParams write setparams;
  end;

{ TSQLQuery }
const
 blobidsize = sizeof(integer);
type
 iblobconnection = interface
                ['{947B58E1-0CA4-436D-A06F-2174D8CA676F}']
  procedure writeblobdata(const atransaction: tsqltransaction;
              const tablename: string; const acursor: tsqlcursor;
              const adata: pointer; const alength: integer;
              const afield: tfield;  const aparam: tparam;
              out newid: string); //''  -> null, id binary otherwise
              //returns blobid or data in param
  procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                              const aparam: tparam);
  function blobscached: boolean;
 end;

  TSQLQuery = class (tmsebufdataset)
  private
    FCursor              : TSQLCursor;
    FUpdateable          : boolean;
    FSQL                 : TStringList;
    FSQLUpdate,
    FSQLInsert,
    FSQLDelete           : TStringList;
    FIsEOF               : boolean;
    FLoadingFieldDefs    : boolean;
    FIndexDefs           : TIndexDefs;
    FUpdateMode          : TUpdateMode;
    FParams              : TmseParams;
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

    fblobintf: iblobconnection;
   
//   fIsPrepared: boolean;
    procedure FreeFldBuffers;
    procedure InitUpdates(ASQL : string);
    function GetIndexDefs : TIndexDefs;
    function GetStatementType : TStatementType;
    procedure SetIndexDefs(AValue : TIndexDefs);
    procedure SetReadOnly(AValue : Boolean);
    procedure SetParseSQL(AValue : Boolean);
    procedure SetUsePrimaryKeyAsKey(AValue : Boolean);
    procedure SetUpdateMode(AValue : TUpdateMode);
    procedure OnChangeSQL(Sender : TObject);
    procedure OnChangeModifySQL(Sender : TObject);
    procedure Execute;
    Procedure SQLParser(var ASQL : string);
    procedure ApplyFilter;
    Function AddFilter(SQLstr : string) : string;
   function getdatabase1: tsqlconnection;
   procedure setdatabase1(const avalue: tsqlconnection);
   procedure checkdatabase;
   procedure setparams(const avalue: TmseParams);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure fetchallblobs;
  protected
    FTableName           : string;
    FReadOnly            : boolean;
    // abstract & virtual methods of TBufDataset
    function Fetch : boolean; override;
    function getblobdatasize: integer; override;
    function loadfield(const afield: tfield; const buffer: pointer;
                     var bufsize: integer): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    // abstract & virtual methods of TDataset
    procedure UpdateIndexDefs; override;
    procedure SetDatabase(Value : TDatabase); override;
    Procedure SetTransaction(Value : TDBTransaction); override;
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
    procedure InternalClose; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    procedure internalrefresh; override;
    function  GetCanModify: Boolean; override;
    Procedure internalApplyRecUpdate(UpdateKind : TUpdateKind);
    procedure ApplyRecUpdate(UpdateKind : TUpdateKind); override;
    Function IsPrepared: Boolean; virtual;
    Procedure SetActive (Value : Boolean); override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterText(const Value: string); override;
    Function GetDataSource : TDatasource; override;
    Procedure SetDataSource(AValue : TDatasource); 
    procedure fetchblobs; virtual;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Prepare; virtual;
    procedure UnPrepare; virtual;
    procedure ExecSQL; virtual;
    procedure executedirect(const asql: string); //uses transaction of tsqlquery
    procedure SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string); virtual;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    property Prepared : boolean read IsPrepared;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property connected: boolean read getconnected write setconnected;
  published
    // redeclared data set properties
    property Active;
    property Filter;
    property Filtered;
//    property FilterOptions;
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
    property database: tsqlconnection read getdatabase1 write setdatabase1;
//    property Database;

    property Transaction;
    property ReadOnly : Boolean read FReadOnly write SetReadOnly;
    property params : tmseparams read fparams write setparams;
                       //before SQL
    property SQL : TStringlist read FSQL write FSQL;
    property SQLUpdate : TStringlist read FSQLUpdate write FSQLUpdate;
    property SQLInsert : TStringlist read FSQLInsert write FSQLInsert;
    property SQLDelete : TStringlist read FSQLDelete write FSQLDelete;
    property IndexDefs : TIndexDefs read GetIndexDefs;
    property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode;
    property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey;
    property StatementType : TStatementType read GetStatementType;
    property ParseSQL : Boolean read FParseSQL write SetParseSQL;
    Property DataSource : TDatasource Read GetDataSource Write SetDatasource;
//    property SchemaInfo : TSchemaInfo read FSchemaInfo default stNoSchema;
  end;

implementation
uses 
 dbconst,strutils,mseclasses,msedatalist,msereal,msedb;

type
 TDBTransactioncracker = Class(TComponent)
  Private
    FActive        : boolean;
    FDatabase      : TDatabase;
    FDataSets      : TList;
    FOpenAfterRead : boolean;
 end;

  TDatabasecracker = class(TComponent)
  private
    FConnected : Boolean;
    FDataBaseName : String;
    FDataSets : TList;
    FTransactions : TList;
    FDirectory : String;
    FKeepConnection : Boolean;
    FLoginPrompt : Boolean;
    FOnLogin : TLoginEvent;
    FParams : TStrings;
    FSQLBased : Boolean;
    FOpenAfterRead : boolean;
  end;
//copied from dsparams.inc 
//todo: not needed for FPC 2.1.1

function SkipComments(var p: PChar) : boolean;
begin
  result := false;
  case p^ of
    '''': // single quote delimited string
      begin
        Inc(p);
        Result := True;
        while not (p^ in [#0, '''']) do
        begin
          if p^='\' then Inc(p,2) // make sure we handle \' and \\ correct
          else Inc(p);
        end;
        if p^='''' then Inc(p); // skip final '
      end;
    '"':  // double quote delimited string
      begin
        Inc(p);
        Result := True;
        while not (p^ in [#0, '"']) do
        begin
          if p^='\'  then Inc(p,2) // make sure we handle \" and \\ correct
          else Inc(p);
        end;
        if p^='"' then Inc(p); // skip final "
      end;
    '-': // possible start of -- comment
      begin
        Inc(p);
        if p^='-' then // -- comment
        begin
          Result := True;
          repeat // skip until at end of line
            Inc(p);
          until p^ in [#10, #0];
        end
      end;
    '/': // possible start of /* */ comment
      begin
        Inc(p);
        if p^='*' then // /* */ comment
        begin
          Result := True;
          repeat
            Inc(p);
            if p^='*' then // possible end of comment
            begin
              Inc(p);
              if p^='/' then Break; // end of comment
            end;
          until p^=#0;
          if p^='/' then Inc(p); // skip final /
        end;
      end;
  end; {case}
end;

function compblobcache(const a,b): integer;
var
 lint1: int64;
begin
 lint1:= blobcacheinfoty(a).id - blobcacheinfoty(b).id;
 result:= 0;
 if lint1 < 0 then begin
  result:= -1;
 end
 else begin
  if lint1 > 0 then begin
   result:= 1;
  end;
 end;
end;

{ TSQLConnection }

function TSQLConnection.StrToStatementType(s : string) : TStatementType;

var T : TStatementType;

begin
  S:=Lowercase(s);
  For t:=stselect to strollback do
    if (S=StatementTokens[t]) then
      Exit(t);
end;

procedure TSQLConnection.SetTransaction(Value : TSQLTransaction);
begin
  if FTransaction<>value then
    begin
    if Assigned(FTransaction) and FTransaction.Active then
      DatabaseError(SErrAssTransaction);
    if Assigned(Value) then
      Value.Database := Self;
    FTransaction := Value;
    end;
end;

procedure TSQLConnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string);

begin
// Empty abstract
end;

procedure TSQLConnection.DoInternalConnect;
begin
  if (DatabaseName = '') then
    DatabaseError(SErrNoDatabaseName,self);
end;

procedure TSQLConnection.DoInternalDisconnect;
begin
end;

destructor TSQLConnection.Destroy;
begin
  inherited Destroy;
end;

procedure TSQLConnection.StartTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.StartTransaction;
end;

procedure TSQLConnection.EndTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.EndTransaction;
end;

Procedure TSQLConnection.ExecuteDirect(const SQL: String);

begin
 ExecuteDirect(SQL,FTransaction);
end;

Procedure TSQLConnection.ExecuteDirect(SQL: String;
                                        const ATransaction: TSQLTransaction);

var Cursor : TSQLCursor;

begin
  if not assigned(ATransaction) then
    DatabaseError(SErrTransactionnSet);

  if not Connected then Open;
  if not ATransaction.Active then ATransaction.StartTransaction;

  try
    Cursor := AllocateCursorHandle;
    cursor.ftrans:= atransaction.handle;
    SQL := TrimRight(SQL);

    if SQL = '' then
      DatabaseError(SErrNoStatement);

    Cursor.FStatementType := stNone;

    PrepareStatement(cursor,ATransaction,SQL,Nil);
    cursor.ftrans:= atransaction.handle;
    execute(cursor,atransaction,Nil);
    UnPrepareStatement(Cursor);
  finally;
    DeAllocateCursorHandle(Cursor);
  end;
end;

procedure TSQLConnection.GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);

var qry : TSQLQuery;

begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet);

  qry := TSQLQuery.Create(nil);
  qry.transaction := Transaction;
  qry.database := Self;
  with qry do
    begin
    ParseSQL := False;
    SetSchemaInfo(SchemaType,SchemaObjectName,'');
    open;
    List.Clear;
    while not eof do
      begin
      List.Append(fieldbyname(ReturnField).asstring);
      Next;
      end;
    end;
  qry.free;
end;


procedure TSQLConnection.GetTableNames(List: TStrings; SystemTables: Boolean);
begin
  if not systemtables then GetDBInfo(stTables,'','table_name',List)
    else GetDBInfo(stSysTables,'','table_name',List);
end;

procedure TSQLConnection.GetProcedureNames(List: TStrings);
begin
  GetDBInfo(stProcedures,'','proc_name',List);
end;

procedure TSQLConnection.GetFieldNames(const TableName: string; List: TStrings);
begin
  GetDBInfo(stColumns,TableName,'column_name',List);
end;

function TSQLConnection.GetAsSQLText(Field : TField) : string;

begin
  if (not assigned(field)) or field.IsNull then Result := 'Null'
  else case field.DataType of
    ftString   : Result := '''' + field.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Field.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Field.AsDateTime) + ''''
  else
    Result := field.asstring;
  end; {case}
end;

function TSQLConnection.GetAsSQLText(Param: TParam) : string;

begin
  if (not assigned(param)) or param.IsNull then Result := 'Null'
  else case param.DataType of
    ftString   : Result := '''' + param.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Param.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Param.AsDateTime) + ''''
  else
    Result := Param.asstring;
  end; {case}
end;


function TSQLConnection.GetHandle: pointer;
begin
  Result := nil;
end;

function TSQLConnection.GetSchemaInfoSQL( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string;

begin
 result:= ''; //compiler warning
 DatabaseError(SMetadataUnavailable);
end;

function TSQLConnection.CreateBlobStream(const Field: TField;
              const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;

begin
 result:= nil; //compiler warning
 DatabaseErrorFmt(SUnsupportedFieldType,['Blob']);
end;

function TSQLConnection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure TSQLConnection.setconnected(const avalue: boolean);
var
 int1: integer;
begin
 with tdatabasecracker(self) do begin
  If aValue <> FConnected then begin
   If aValue then begin
    if csReading in ComponentState then begin
     FOpenAfterRead:= true;
     exit;
    end
    else begin
     DoInternalConnect;
    end;
   end
   else begin
//    Closedatasets;
    for int1:= fdatasets.count - 1 downto 0 do begin
     with tsqlquery(fdatasets[int1]) do begin
      if (transaction = nil) or (transaction.active) then begin
       close; //not disconnected
      end;
     end;
    end;
    Closetransactions;
    DoInternalDisConnect;
    if csloading in ComponentState then begin
     FOpenAfterRead := false;
    end;
   end;
   FConnected:= aValue;
  end;
 end;
end;

{ TSQLTransaction }
procedure TSQLTransaction.EndTransaction;

begin
  rollback;
end;

function TSQLTransaction.GetHandle: pointer;
begin
  Result := (Database as tsqlconnection).GetTransactionHandle(FTrans);
end;

procedure TSQLTransaction.Commit;
begin
  if active then
    begin
    closedatasets;
    if (Database as tsqlconnection).commit(FTrans) then
      begin
      closeTrans;
      FreeAndNil(FTrans);
      end;
    end;
end;

procedure TSQLTransaction.CommitRetaining;
begin
  if active then
    (Database as tsqlconnection).commitRetaining(FTrans);
end;

procedure TSQLTransaction.Rollback;
begin
 if active then begin
  closedatasets;
  if (Database as tsqlconnection).RollBack(FTrans) then begin
   CloseTrans;
   FreeAndNil(FTrans);
  end;
 end;
end;

procedure tsqltransaction.disconnect(const sender: tsqlquery);
var
 int1: integer;
begin
 with tdbtransactioncracker(self) do begin
  int1:= 1;
  if sender.fupdateqry <> nil then begin
   inc(int1,3); //insert,update,delete
  end;
  if fdatasets.count > int1 then begin
   databaseerror('Offline mode needs exclusive transaction.',sender);
  end;
  fdatasets.remove(sender);
  with sender do begin
   if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
        (database as TSQLconnection).UnPrepareStatement(FCursor);
   end;
  end;
  try
   active:= false;
  finally
   fdatasets.insert(0,sender);
  end;
 end;
end;

procedure TSQLTransaction.RollbackRetaining;
begin
  if active then
    (Database as tsqlconnection).RollBackRetaining(FTrans);
end;

procedure TSQLTransaction.StartTransaction;

var db : TSQLConnection;

begin
  if Active then
    DatabaseError(SErrTransAlreadyActive);

  db := (Database as tsqlconnection);

  if Db = nil then
    DatabaseError(SErrDatabasenAssigned);

  if not Db.Connected then
    Db.Open;
  if not assigned(FTrans) then FTrans := Db.AllocateTransactionHandle;

  if Db.StartdbTransaction(FTrans,FParams.CommaText) then OpenTrans;
end;

constructor TSQLTransaction.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FParams := TStringList.Create;
end;

destructor TSQLTransaction.Destroy;
var
 bo1: boolean;
begin
 bo1:= active;
 Rollback;
 if not bo1 then begin
  closedatasets; //close disconnected
 end;
 FreeAndNil(FParams);
 inherited Destroy;
end;

Procedure TSQLTransaction.SetDatabase(Value : TDatabase);

begin
  If Value<>Database then
    begin
    CheckInactive;
    If Assigned(Database) then
      with Database as TSqlConnection do
        if Transaction = self then Transaction := nil;
    inherited SetDatabase(Value);
    end;
end;

procedure TSQLTransaction.setparams(const avalue: TStringList);
begin
 fparams.assign(avalue);
end;

{ TSQLQuery }
procedure TSQLQuery.OnChangeSQL(Sender : TObject);

var ParamName : String;

begin
  UnPrepare;
  if (FSQL <> nil) then
    begin
    FParams.ParseSQL(FSQL.Text,True);
    If Assigned(FMasterLink) then
      FMasterLink.RefreshParamNames;
    end;
end;

procedure TSQLQuery.OnChangeModifySQL(Sender : TObject);

begin
  CheckInactive;
end;

Procedure TSQLQuery.SetTransaction(Value : TDBTransaction);

begin
  if (value <> nil) and not (value is tsqltransaction) then begin
   exception.create(name+': Transaction must be tsqltransaction.');
  end;
  UnPrepare;
  inherited;
end;

procedure TSQLQuery.SetDatabase(Value : TDatabase);
var 
 db: tsqlconnection;
begin
 if (Database <> Value) then begin
  if (value <> nil) and not (value is tsqlconnection) then begin
   exception.create(name+': Database must be tsqlconnection.');
  end;
  UnPrepare;
  if assigned(FCursor) then begin
   TSQLConnection(database).DeAllocateCursorHandle(FCursor);
  end;
  db:= value as tsqlconnection;
  inherited setdatabase(value);
  if assigned(value) and (Transaction = nil) and 
                  (Assigned(db.Transaction)) then begin
   transaction:= Db.Transaction;
  end;
 end;
end;

Function TSQLQuery.IsPrepared : Boolean;

begin
  Result := Assigned(FCursor) and FCursor.FPrepared;
end;

Function TSQLQuery.AddFilter(SQLstr : string) : string;

begin
  if FWhereStartPos = 0 then
    SQLstr := SQLstr + ' where (' + Filter + ')'
  else if FWhereStopPos > 0 then
    system.insert(' and ('+Filter+') ',SQLstr,FWhereStopPos+1)
  else
    system.insert(' where ('+Filter+') ',SQLstr,FWhereStartPos);
  Result := SQLstr;
end;

procedure tsqlquery.applyfilter;
var
 s: string;
begin
 freefldbuffers;
 tsqlconnection(database).unpreparestatement(fcursor);
 fiseof := false;
 inherited internalclose;
 s:= fsqlbuf;
 if filtered and (filter <> '') then begin
  s:= addfilter(s);
 end;
 tsqlconnection(database).preparestatement(fcursor,
                                  tsqltransaction(transaction),s,fparams);
 execute;
 inherited internalopen;
 first;
end;

Procedure TSQLQuery.SetActive (Value : Boolean);

begin
  inherited SetActive(Value);
// The query is UnPrepared, so that if a transaction closes all datasets
// they also get unprepared
  if not Value and IsPrepared then UnPrepare;
end;


procedure TSQLQuery.SetFiltered(Value: Boolean);

begin
 if Value and not FParseSQL and (filter <> '') then begin
  DatabaseErrorFmt(SNoParseSQL,['Filtering ']);
 end;
 if (Filtered <> Value) then begin
  inherited setfiltered(Value);
  if active then begin
   if filter <> '' then begin 
    ApplyFilter;
   end
   else begin
    resync([]);
   end;
  end;
 end;   
end;

procedure TSQLQuery.SetFilterText(const Value: string);
begin
  if Value <> Filter then
    begin
    inherited SetFilterText(Value);
    if active then ApplyFilter;
    end;
end;

procedure TSQLQuery.Prepare;
var
  db    : tsqlconnection;
  sqltr : tsqltransaction;

begin
  if not IsPrepared then
    begin
    db := (Database as tsqlconnection);
    sqltr := (transaction as tsqltransaction);
    if not assigned(Db) then
      DatabaseError(SErrDatabasenAssigned);
    if not assigned(sqltr) then
      DatabaseError(SErrTransactionnSet);

    if not Db.Connected then db.Open;
    if not sqltr.Active then sqltr.StartTransaction;

//    if assigned(fcursor) then FreeAndNil(fcursor);
    if not assigned(fcursor) then FCursor := Db.AllocateCursorHandle;
    fcursor.ftrans:= sqltr.handle;
    
    FSQLBuf := TrimRight(FSQL.Text);

    if FSQLBuf = '' then
      DatabaseError(SErrNoStatement);

    SQLParser(FSQLBuf);

    if filtered and (filter <> '') then
      Db.PrepareStatement(Fcursor,sqltr,AddFilter(FSQLBuf),FParams)
    else
      Db.PrepareStatement(Fcursor,sqltr,FSQLBuf,FParams);

    if (FCursor.FStatementType = stSelect) then
      begin
      FCursor.FInitFieldDef := True;
      if not ReadOnly then InitUpdates(FSQLBuf);
      end;
    end;
end;

procedure TSQLQuery.UnPrepare;

begin
 if connected then begin
  CheckInactive;
 end;
  if IsPrepared then with Database as TSQLConnection do
    UnPrepareStatement(FCursor);
end;

procedure TSQLQuery.FreeFldBuffers;
begin
  if assigned(FCursor) then (Database as tsqlconnection).FreeFldBuffers(FCursor);
end;

function TSQLQuery.Fetch : boolean;
begin
 if not (Fcursor.FStatementType in [stSelect]) then begin
  result:= false;
  Exit;
 end;
 if not FIsEof then begin
  FIsEOF:= not tsqlconnection(database).Fetch(Fcursor);
 end;
 Result := not FIsEOF;
end;

procedure TSQLQuery.Execute;
var
 int1: integer;
begin
 If (FParams.Count>0) and Assigned(FMasterLink) then begin
  FMasterLink.CopyParamsFromMaster(False);
 end;
 for int1:= 0 to fparams.count - 1 do begin
  with fparams[int1] do begin
   if not isnull and (datatype in [ftFloat,ftDate,ftTime,ftDateTime]) and
                              isemptyreal(asfloat) then begin
    clear;
   end;
  end;
 end;
 fcursor.ftrans:= tsqltransaction(transaction).handle;
 tsqlconnection(database).execute(Fcursor,tsqltransaction(transaction),FParams);
end;

function tsqlquery.loadfield(const afield: tfield; const buffer: pointer;
                     var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
begin
 result:= tSQLConnection(database).LoadField(FCursor,aField,buffer,bufsize)
end;

procedure TSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure TSQLQuery.InternalClose;
begin
 if fcursor <> nil then begin
  fcursor.fblobs:= nil;
 end;
 fblobintf:= nil;
  if StatementType = stSelect then FreeFldBuffers;
// Database and FCursor could be nil, for example if the database is not
// assigned, and .open is called
  if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
        (database as TSQLconnection).UnPrepareStatement(FCursor);
  end;
  if DefaultFields then
    DestroyFields;
  FIsEOF := False;
  FreeAndNil(FUpdateQry);
  FreeAndNil(FInsertQry);
  FreeAndNil(FDeleteQry);
//  FRecordSize := 0;
  inherited internalclose;
end;

procedure TSQLQuery.InternalInitFieldDefs;
begin
  if FLoadingFieldDefs then
    Exit;

  FLoadingFieldDefs := True;

  try
    FieldDefs.Clear;

    (Database as tsqlconnection).AddFieldDefs(fcursor,FieldDefs);
  finally
    FLoadingFieldDefs := False;
  end;
end;

procedure TSQLQuery.SQLParser(var ASQL : string);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppGroup,ppOrder,ppComment,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pchar;
  S                       : string;
  ParsePart               : TParsePart;
  StrLength               : Integer;

begin
    PSQL:=Pchar(ASQL);
    ParsePart := ppStart;

    CurrentP := PSQL-1;
    PhraseP := PSQL;

    FWhereStartPos := 0;
    FWhereStopPos := 0;

    repeat begin
	inc(CurrentP);

        if SkipComments(CurrentP) then
         if ParsePart = ppStart then PhraseP := CurrentP;
       	if CurrentP^ in [' ',#13,#10,#9,#0,'(',')',';'] then begin { if(1) }
	    if (CurrentP-PhraseP > 0) or (CurrentP^ in [';',#0]) then begin { if(2) }
		strLength := CurrentP-PhraseP;
		Setlength(S,strLength);
		
		if strLength > 0 then Move(PhraseP^,S[1],(strLength));
		s := uppercase(s);

		case ParsePart of
		    ppStart  : begin
			FCursor.FStatementType := (Database as tsqlconnection).StrToStatementType(s);
		
			if FCursor.FStatementType = stSelect then 
			    ParsePart := ppSelect
			else 
			    break;
			    
			if not FParseSQL then break;
		        PStatementPart := CurrentP;
		    end; {ppStart}
		    ppSelect : begin
			if s = 'FROM' then begin
			    ParsePart := ppFrom;
			    PhraseP := CurrentP;
			    PStatementPart := CurrentP;
			end;
		    end; {ppSelect}
		    ppFrom   : begin
			
			if (s = 'WHERE') or (s = 'GROUP') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then begin
			    if (s = 'WHERE') then begin
			        ParsePart := ppWhere;
			        StrLength := PhraseP-PStatementPart;
			    end else if (s = 'GROUP') then begin
			        ParsePart := ppGroup;
			        StrLength := PhraseP-PStatementPart
			    end else if (s = 'ORDER') then begin
			        ParsePart := ppOrder;
			        StrLength := PhraseP-PStatementPart
			    end else begin
			        ParsePart := ppBogus;
			        StrLength := CurrentP-PStatementPart;
			    end;
			    
			    Setlength(FFromPart,StrLength);
			    Move(PStatementPart^,FFromPart[1],(StrLength));
			    FFrompart := trim(FFrompart);
			    FWhereStartPos := PStatementPart-PSQL+StrLength+1;
			    PStatementPart := CurrentP;
			end;
			
		    end; {ppFrom}
		    ppWhere  : begin
			if (s = 'GROUP') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then begin
			    ParsePart := ppBogus;
			    FWhereStartPos := PStatementPart-PSQL;
				
			    if (s = 'GROUP') or (s = 'ORDER') then
			        FWhereStopPos := PhraseP-PSQL+1
			    else
			        FWhereStopPos := CurrentP-PSQL+1;
			    end;
			end;
		    end; {ppWhere}
		    
		end; {case}
		
		PhraseP := CurrentP+1;
	    end; { if(2) }
	end; { if(1) }
    until CurrentP^=#0; {repeat}

    if (FWhereStartPos > 0) and (FWhereStopPos > 0) then begin
	system.insert('(',ASQL,FWhereStartPos+1);
	inc(FWhereStopPos);
	system.insert(')',ASQL,FWhereStopPos);
    end;
//writeln(ASQL);
end;
(*
procedure TSQLQuery.SQLParser(var ASQL : string);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppOrder,ppComment,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pchar;
  S                       : string;
  ParsePart               : TParsePart;
  StrLength               : Integer;

begin
  PSQL:=Pchar(ASQL);
  ParsePart := ppStart;

  CurrentP := PSQL-1;
  PhraseP := PSQL;

  FWhereStartPos := 0;
  FWhereStopPos := 0;

  repeat
    begin
    inc(CurrentP);

    if CurrentP^ in [' ',#13,#10,#9,#0,'(',')',';'] then
      begin
      if (CurrentP-PhraseP > 0) or (CurrentP^ in [';',#0]) then
        begin
        strLength := CurrentP-PhraseP;
        Setlength(S,strLength);
        if strLength > 0 then Move(PhraseP^,S[1],(strLength));
        s := uppercase(s);

        case ParsePart of
          ppStart  : begin
                     FCursor.FStatementType := (Database as tsqlconnection).StrToStatementType(s);
                     if FCursor.FStatementType = stSelect then ParsePart := ppSelect
                       else break;
                     if not FParseSQL then break;
                     PStatementPart := CurrentP;
                     end;
          ppSelect : begin
                     if s = 'FROM' then
                       begin
                       ParsePart := ppFrom;
                       PhraseP := CurrentP;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppFrom   : begin
                     if (s = 'WHERE') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       if (s = 'WHERE') then
                         begin
                         ParsePart := ppWhere;
                         StrLength := PhraseP-PStatementPart;
                         end
                       else if (s = 'ORDER') then
                         begin
                         ParsePart := ppOrder;
                         StrLength := PhraseP-PStatementPart
                         end
                       else
                         begin
                         ParsePart := ppBogus;
                         StrLength := CurrentP-PStatementPart;
                         end;
                       Setlength(FFromPart,StrLength);
                       Move(PStatementPart^,FFromPart[1],(StrLength));
                       FFrompart := trim(FFrompart);
                       FWhereStartPos := PStatementPart-PSQL+StrLength+1;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppWhere  : begin
                     if (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       ParsePart := ppBogus;
                       FWhereStartPos := PStatementPart-PSQL;
                       if s = 'ORDER' then
                         FWhereStopPos := PhraseP-PSQL+1
                       else
                         FWhereStopPos := CurrentP-PSQL+1;
                       end;
                     end;
        end; {case}
        end;
      PhraseP := CurrentP+1;
      end
    end;
  until CurrentP^=#0;
  if (FWhereStartPos > 0) and (FWhereStopPos > 0) then
    begin
    system.insert('(',ASQL,FWhereStartPos+1);
    inc(FWhereStopPos);
    system.insert(')',ASQL,FWhereStopPos);
    end
end;
*)
procedure TSQLQuery.InitUpdates(ASQL : string);
begin
 if pos(',',FFromPart) > 0 then begin
  FUpdateable := False 
           // select-statements from more then one table are not updateable
 end
 else begin
  FUpdateable := True;
  FTableName := FFromPart;
 end;
end;

procedure TSQLQuery.InternalOpen;

  procedure InitialiseModifyQuery(var qry : TSQLQuery; aSQL: TSTringList);  
  begin
   qry:= TSQLQuery.Create(nil);
   with qry do begin
    ParseSQL:= False;
    DataBase:= Self.DataBase;
    Transaction:= Self.Transaction;
    SQL.Assign(aSQL);
   end;
  end; //initialisemodifyquery

var
 tel,fieldc: integer;
 f: TField;
 s: string;
 IndexFields: TStrings;
begin
 if database <> nil then begin
  getcorbainterface(database,typeinfo(iblobconnection),fblobintf);
 end;
 if not streamloading then begin  
  try
   Prepare;
   if FCursor.FStatementType in [stSelect] then begin
    Execute;
    if FCursor.FInitFieldDef then InternalInitFieldDefs;
    if DefaultFields then begin
     CreateFields;
     if FUpdateable then begin
      if FusePrimaryKeyAsKey then begin
       UpdateIndexDefs;
       for tel := 0 to indexdefs.count-1 do  begin
        if ixPrimary in indexdefs[tel].options then begin
   // Todo: If there is more then one field in the key, that must be parsed
         IndexFields := TStringList.Create;
         ExtractStrings([';'],[' '],pchar(indexdefs[tel].fields),IndexFields);
         for fieldc := 0 to IndexFields.Count-1 do begin
          F := Findfield(IndexFields[fieldc]);
          if F <> nil then begin
           F.ProviderFlags := F.ProviderFlags + [pfInKey];
          end;
         end;
         IndexFields.Free;
        end;
       end;
      end;
     end;
    end;
    if FUpdateable then begin
     InitialiseModifyQuery(FDeleteQry,FSQLDelete);
     InitialiseModifyQuery(FUpdateQry,FSQLUpdate);
     InitialiseModifyQuery(FInsertQry,FSQLInsert);
    end;
   end
   else begin
    DatabaseError(SErrNoSelectStatement,Self);
   end;
  except
   on E:Exception do
    raise;
  end;
 end;
 inherited;
end;

procedure tsqlquery.internalrefresh;
var
 int1: integer;
begin
 int1:= recno;
 disablecontrols;
 try
//  transaction.active:= false;
  active:= false;
  active:= true;
  setrecno1(int1,true);
 finally
  enablecontrols;
 end;
end;

procedure TSQLQuery.ExecSQL;
begin
 try
  Prepare;
  Execute;
 finally
   // FCursor has to be assigned, or else the prepare went wrong before PrepareStatment was
   // called, so UnPrepareStatement shoudn't be called either
  if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
   (database as TSQLConnection).UnPrepareStatement(Fcursor);
  end;
 end;
end;

constructor TSQLQuery.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FParams := TmseParams.create(self);
  FSQL := TStringList.Create;
  FSQL.OnChange := @OnChangeSQL;

  FSQLUpdate := TStringList.Create;
  FSQLUpdate.OnChange := @OnChangeModifySQL;
  FSQLInsert := TStringList.Create;
  FSQLInsert.OnChange := @OnChangeModifySQL;
  FSQLDelete := TStringList.Create;
  FSQLDelete.OnChange := @OnChangeModifySQL;

  FIndexDefs := TIndexDefs.Create(Self);
  FReadOnly := false;
  FParseSQL := True;
// Delphi has upWhereAll as default, but since strings and oldvalue's don't work yet
// (variants) set it to upWhereKeyOnly
  FUpdateMode := upWhereKeyOnly;
  FUsePrimaryKeyAsKey := True;
end;

destructor TSQLQuery.Destroy;
begin
  if Active then Close;
  UnPrepare;
  if assigned(FCursor) then (Database as TSQLConnection).DeAllocateCursorHandle(FCursor);
  FreeAndNil(FMasterLink);
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FSQLInsert);
  FreeAndNil(FSQLDelete);
  FreeAndNil(FSQLUpdate);
  FreeAndNil(FIndexDefs);
  inherited Destroy;
end;

procedure TSQLQuery.SetReadOnly(AValue : Boolean);

begin
  CheckInactive;
  if not AValue then
    begin
    if FParseSQL then FReadOnly := False
      else DatabaseErrorFmt(SNoParseSQL,['Updating ']);
    end
  else FReadOnly := True;
end;

procedure TSQLQuery.SetParseSQL(AValue : Boolean);

begin
  CheckInactive;
  if not AValue then
    begin
    FReadOnly := True;
    Filtered := False;
    FParseSQL := False;
    end
  else
    FParseSQL := True;
end;

procedure TSQLQuery.SetUsePrimaryKeyAsKey(AValue : Boolean);

begin
  if not Active then FusePrimaryKeyAsKey := AValue
  else
    begin
    // Just temporary, this should be possible in the future
    DatabaseError(SActiveDataset);
    end;
end;

Procedure TSQLQuery.UpdateIndexDefs;

begin
  if assigned(DataBase) then
    TSQLConnection(database).UpdateIndexDefs(FIndexDefs,FTableName);
end;

Procedure TSQLQuery.internalApplyRecUpdate(UpdateKind : TUpdateKind);
var
 s: string;

 procedure UpdateWherePart(var sql_where : string; const afield: tfield);
 begin
  with afield do begin
   if (pfInKey in ProviderFlags) or
     ((FUpdateMode = upWhereAll) and (pfInWhere in ProviderFlags)) or
     ((FUpdateMode = UpWhereChanged) and 
     (pfInWhere in ProviderFlags) and 
     (value <> oldvalue)) then begin
    sql_where := sql_where + '(' + FieldName + 
              '= :OLD_' + FieldName + ') and ';
   end;
  end;
 end;

 function ModifyRecQuery : string;
 var 
  x: integer;
  sql_set: string;
  sql_where: string;
  field1: tfield;
 begin
  sql_set := '';
  sql_where := '';
  for x := 0 to Fields.Count -1 do begin
   field1:= fields[x];
   with field1 do begin
    if fieldkind = fkdata then begin
     UpdateWherePart(sql_where,field1);
     if (pfInUpdate in ProviderFlags) then begin
      sql_set:= sql_set + FieldName + '=:' + FieldName + ',';
     end;
    end;
   end;
  end;
  setlength(sql_set,length(sql_set)-1);
  setlength(sql_where,length(sql_where)-5);
  result := 'update ' + FTableName + ' set ' + sql_set + ' where ' + sql_where;
 end;

 function InsertRecQuery : string;
 var 
  x: integer;
  sql_fields: string;
  sql_values: string;
 begin
  sql_fields := '';
  sql_values := '';
  for x := 0 to Fields.Count -1 do begin
   with fields[x] do begin
    if (fieldkind = fkdata) and not IsNull and 
                           (pfInUpdate in ProviderFlags) then begin 
     sql_fields:= sql_fields + FieldName + ',';
     sql_values:= sql_values + ':' + FieldName + ',';
    end;
   end;
  end;
  setlength(sql_fields,length(sql_fields)-1);
  setlength(sql_values,length(sql_values)-1);
  result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' +
                      sql_values + ')';
 end;

 function DeleteRecQuery : string;
 var 
  x: integer;
  sql_where: string;
  field1: tfield;
 begin
  sql_where := '';
  for x := 0 to Fields.Count -1 do begin
   field1:= fields[x];
   if field1.fieldkind = fkdata then begin
    UpdateWherePart(sql_where,field1);
   end;
  end;
  setlength(sql_where,length(sql_where)-5);
  result := 'delete from ' + FTableName + ' where ' + sql_where;
 end;

var
 qry: tsqlquery;
 x: integer;
 Fld : TField;
 param1: tparam;
 int1: integer;
 blobspo: pblobinfoarty;
 str1: string;
 bo1: boolean;
 freeblobar: pointerarty;
    
begin
 blobspo:= getintblobpo;
 case UpdateKind of
  ukModify: begin
   qry:= FUpdateQry;
   if trim(qry.sql.Text) = '' then begin
    qry.SQL.Add(ModifyRecQuery);
   end;
  end;
  ukInsert: begin
   qry:= FInsertQry;
   if trim(qry.sql.Text) = '' then begin
    qry.SQL.Add(InsertRecQuery);
   end;
  end;
  ukDelete : begin
   qry := FDeleteQry;
   if trim(qry.sql.Text) = '' then begin
    qry.SQL.Add(DeleteRecQuery);
   end;
  end;
 end;
 with qry do begin
  transaction.active:= true;
  freeblobar:= nil;
  try
   for x := 0 to Params.Count-1 do begin
    param1:= params[x];
    with param1 do begin
     if leftstr(name,4)='OLD_' then begin
      Fld:= self.FieldByName(copy(name,5,length(name)-4));
      oldfieldtoparam(fld,param1);
 //     AssignFieldValue(Fld,Fld.OldValue);
     end
     else begin
      Fld:= self.FieldByName(name);
      if fld is tblobfield and (self.fblobintf <> nil) then begin
       if fld.isnull then begin
        clear;
        datatype:= fld.datatype;
       end
       else begin
        bo1:= false;
        for int1:= 0 to high(blobspo^) do begin
         if blobspo^[int1].field = fld then begin
          self.fblobintf.writeblobdata(tsqltransaction(self.transaction),
               self.ftablename,self.fcursor,
               blobspo^[int1].data,blobspo^[int1].datalength,fld,params[x],str1);
          if str1 <> '' then begin
           self.setdatastringvalue(fld,str1);
           additem(freeblobar,fld);
          end;
          bo1:= true;
          break;
         end;
        end;
        if not bo1 then begin
         self.fblobintf.setupblobdata(fld,self.fcursor,params[x]);
        end;
       end;
      end
      else begin
       self.fieldtoparam(fld,param1);
 //      AssignFieldValue(Fld,Fld.Value);
      end;
     end;
    end;
   end;
   execsql;
  finally
   for int1:= high(freeblobar) downto 0 do begin
    deleteblob(blobspo^,tfield(freeblobar[int1]));
   end;  
  end;
 end;
end;

Procedure TSQLQuery.ApplyRecUpdate(UpdateKind : TUpdateKind);
begin
 internalapplyrecupdate(updatekind);
end;

{
Procedure TSQLQuery.ApplyRecUpdate(UpdateKind : TUpdateKind);

var
    s : string;

  procedure UpdateWherePart(var sql_where : string;x : integer);

  begin
    if (pfInKey in Fields[x].ProviderFlags) or
       ((FUpdateMode = upWhereAll) and (pfInWhere in Fields[x].ProviderFlags)) or
       ((FUpdateMode = UpWhereChanged) and (pfInWhere in Fields[x].ProviderFlags) and (fields[x].value <> fields[x].oldvalue)) then
      sql_where := sql_where + '(' + fields[x].FieldName + '= :OLD_' + fields[x].FieldName + ') and ';
  end;

  function ModifyRecQuery : string;

  var x          : integer;
      sql_set    : string;
      sql_where  : string;

  begin
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

  function InsertRecQuery : string;

  var x          : integer;
      sql_fields : string;
      sql_values : string;

  begin
    sql_fields := '';
    sql_values := '';
    for x := 0 to Fields.Count -1 do
      begin
      if not fields[x].IsNull then
        begin
        sql_fields := sql_fields + fields[x].FieldName + ',';
        sql_values := sql_values + ':' + fields[x].FieldName + ',';
        end;
      end;
    setlength(sql_fields,length(sql_fields)-1);
    setlength(sql_values,length(sql_values)-1);

    result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' + sql_values + ')';
  end;

  function DeleteRecQuery : string;

  var x          : integer;
      sql_where  : string;

  begin
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      UpdateWherePart(sql_where,x);

    setlength(sql_where,length(sql_where)-5);

    result := 'delete from ' + FTableName + ' where ' + sql_where;
  end;

var qry : TSQLQuery;
    x   : integer;
    Fld : TField;
    
begin
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
      AssignFieldValue(Fld,Fld.Value);
      end;
    execsql;
    end;
end;
}

Function TSQLQuery.GetCanModify: Boolean;

begin
 if not connected then begin
  result:= active and not freadonly;
 end
 else begin
  if (fcursor <> nil) and (FCursor.FStatementType = stSelect) then begin
   Result:= Active and  FUpdateable and (not FReadOnly)
  end
  else begin
   Result:= False;
  end;
 end;
end;

function TSQLQuery.GetIndexDefs : TIndexDefs;

begin
  Result := FIndexDefs;
end;

procedure TSQLQuery.SetIndexDefs(AValue : TIndexDefs);

begin
  FIndexDefs := AValue;
end;

procedure TSQLQuery.SetUpdateMode(AValue : TUpdateMode);

begin
  FUpdateMode := AValue;
end;

procedure TSQLQuery.SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string);

begin
  ReadOnly := True;
  SQL.Clear;
  SQL.Add((DataBase as tsqlconnection).GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaPattern));
end;

function TSQLQuery.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
var
 info: blobcacheinfoty; 
 int1: integer;
 blob1: blobinfoty;
begin
 result:= inherited createblobstream(field,mode);
 if result = nil then begin
  if (bs_blobsfetched in fbstate) and (mode = bmread) then begin
   if field.getdata(@info.id) and
           findarrayvalue(info,fblobcache,length(fblobcache),@compblobcache,
                                        sizeof(blobcacheinfoty),int1) then begin
    with fblobcache[int1] do begin
     blob1.data:= pointer(data);
     blob1.datalength:= length(data);
    end;
    result:= tblobcopy.create(blob1);
   end;
  end
  else begin
   result:= tsqlconnection(database).CreateBlobStream(Field,Mode,fcursor);
  end;
 end;
end;

function TSQLQuery.GetStatementType : TStatementType;

begin
  if assigned(FCursor) then Result := FCursor.FStatementType
    else Result := stNone;
end;

Procedure TSQLQuery.SetDataSource(AVAlue : TDatasource);

Var
  DS : TDatasource;

begin
  DS:=DataSource;
  If (AValue<>DS) then
    begin
    If Assigned(DS) then
      DS.RemoveFreeNotification(Self);
    If Assigned(AValue) then
      begin
      AValue.FreeNotification(Self);  
      FMasterLink:=TMasterParamsDataLink.Create(Self);
      FMasterLink.Datasource:=AValue;
      end
    else
      FreeAndNil(FMasterLink);  
    end;
end;

Function TSQLQuery.GetDataSource : TDatasource;

begin
  If Assigned(FMasterLink) then
    Result:=FMasterLink.DataSource
  else
    Result:=Nil;
end;

procedure TSQLQuery.Notification(AComponent: TComponent; Operation: TOperation); 

begin
  Inherited;
  If (Operation=opRemove) and (AComponent=DataSource) then
    DataSource:=Nil;
end;

function TSQLQuery.getblobdatasize: integer;
begin
 result:= tsqlconnection(database).getblobdatasize;
end;

function TSQLQuery.getdatabase1: tsqlconnection;
begin
 result:= tsqlconnection(inherited database);
end;

procedure TSQLQuery.setdatabase1(const avalue: tsqlconnection);
begin
 inherited database:= avalue;
end;

procedure TSQLQuery.checkdatabase;
begin
 if inherited database = nil then begin
  databaseerror(serrdatabasenassigned);
 end;
end;

procedure TSQLQuery.executedirect(const asql: string);
begin
 checkdatabase;
 database.executedirect(asql,tsqltransaction(transaction)); 
end;

procedure TSQLQuery.setparams(const avalue: TmseParams);
begin
 fparams.assign(avalue);
end;

function tsqlquery.getconnected: boolean;
begin
 result:= (transaction <> nil) and transaction.active;
end;

procedure TSQLQuery.fetchblobs;
var
 datapobefore: pintrecordty;
 statebefore: tdatasetstate;
 int1,int2,int3: integer;
 ind1: pointerarty;
 fieldar1: fieldarty;
 ar1: integerarty;
 stream1: tmemorystream;
begin
 if (fblobintf <> nil) and not fblobintf.blobscached then begin
  setlength(fieldar1,fields.count);
  int2:= 0;
  for int1:= 0 to high(fieldar1) do begin
   fieldar1[int2]:= fields[int1];
   if fieldar1[int2].isblob then begin
    inc(int2);
   end;
  end;
  if int2 > 0 then begin
   setlength(fieldar1,int2);
   setlength(ar1,int2);
   for int1:= 0 to high(ar1) do begin
    ar1[int1]:= fieldar1[int1].fieldno-1;
   end;
   fblobcache:= nil;
   datapobefore:= fcurrentbuf;
   ind1:= findexes[0].ind;
   statebefore:= settempstate(dscurvalue);
   int3:= 0;
   try
    for int1:= 0 to recordcount - 1 do begin
     fcurrentbuf:= ind1[int1];
     for int2:= 0 to high(fieldar1) do begin
      if not getfieldisnull(fcurrentbuf^.header.fielddata.nullmask,
                                                        ar1[int2]) then begin
       if high(fblobcache) < int3 then begin
        setlength(fblobcache,high(fblobcache)*2+258);
       end;
       stream1:= tmemorystream(createblobstream(fieldar1[int2],bmread));
       if stream1.size > 0 then begin
        with fblobcache[int3] do begin
         fieldar1[int2].getdata(@id);
         setlength(data,stream1.size);
         move(stream1.memory^,data[1],length(data));
        end;
        inc(int3);
       end;
       stream1.free;
      end;
     end;
    end;
    setlength(fblobcache,int3);
    sortarray(fblobcache,@compblobcache,sizeof(blobcacheinfoty));
    include(fbstate,bs_blobsfetched);
   finally
    fcurrentbuf:= datapobefore;
    restorestate(statebefore);
   end;
  end;
 end;
end;

procedure tsqlquery.fetchallblobs;
begin
 if not fallpacketsfetched then begin
  fetchall;
  fetchblobs;
 end;
end;

procedure TSQLQuery.setconnected(const avalue: boolean);
begin
 if not (bs_opening in fbstate) then begin
  checkactive;
 end;
 if avalue then begin
  transaction.active:= true;
 end
 else begin
  if transaction.active then begin
   fetchallblobs;
   tsqltransaction(transaction).disconnect(self);
  end;
 end;
end;

{ TSQLCursor }

function TSQLCursor.addblobdata(const adata: pointer;
               const alength: integer): integer;
begin
 result:= length(fblobs);
 setlength(fblobs,result+1);
 setlength(fblobs[result],alength);
{$ifdef FPC} {$checkpointer off} {$endif} //adata can be foreign memory
 move(adata^,fblobs[result][1],alength);
{$ifdef FPC} {$checkpointer default} {$endif}
end;

function TSQLCursor.addblobdata(const adata: string): integer;
begin
 result:= addblobdata(pointer(adata),length(adata));
end;

procedure TSQLCursor.blobfieldtoparam(const afield: tfield;
               const aparam: tparam; const asstring: boolean = false);
var
 blobid: integer;
begin
 if afield.getdata(@blobid) then begin
  if asstring then begin
   aparam.asstring:= fblobs[blobid];
  end
  else begin
   aparam.asblob:= fblobs[blobid];
  end;
 end
 else begin
  aparam.clear;
 end;
end;

{ tmseparams }

function tmseparams.parsesql(const sql: string; const docreate: boolean;
               const parameterstyle: tparamstyle;
               var parambinding: tparambinding;
               var replacestring: string): string;

type
  // used for ParamPart
  TStringPart = record
    Start,Stop:integer;
  end;

const
  ParamAllocStepSize = 8;

var
  IgnorePart:boolean;
  p,ParamNameStart,BufStart:PChar;
  ParamName:string;
  QuestionMarkParamCount,ParameterIndex,NewLength:integer;
  ParamCount:integer; // actual number of parameters encountered so far;
                      // always <= Length(ParamPart) = Length(Parambinding)
                      // Parambinding will have length ParamCount in the end
  ParamPart:array of TStringPart; // describe which parts of buf are parameters
  NewQueryLength:integer;
  NewQuery:string;
  NewQueryIndex,BufIndex,CopyLen,i:integer;    // Parambinding will have length ParamCount in the end
  b:integer;
  tmpParam:TParam;

begin
//  if DoCreate then Clear;        //2006-11-23 mse

  // Parse the SQL and build ParamBinding
  ParamCount:=0;
  NewQueryLength:=Length(SQL);
  SetLength(ParamPart,ParamAllocStepSize);
  SetLength(Parambinding,ParamAllocStepSize);
  QuestionMarkParamCount:=0; // number of ? params found in query so far

  ReplaceString := '$';
  if ParameterStyle = psSimulated then
    while pos(ReplaceString,SQL) > 0 do ReplaceString := ReplaceString+'$';

  p:=PChar(SQL);
  BufStart:=p; // used to calculate ParamPart.Start values
  repeat
    case p^ of
      '''': // single quote delimited string
        begin
          Inc(p);
          while not (p^ in [#0, '''']) do
          begin
            if p^='\' then Inc(p,2) // make sure we handle \' and \\ correct
            else Inc(p);
          end;
          if p^='''' then Inc(p); // skip final '
        end;
      '"':  // double quote delimited string
        begin
          Inc(p);
          while not (p^ in [#0, '"']) do
          begin
            if p^='\'  then Inc(p,2) // make sure we handle \" and \\ correct
            else Inc(p);
          end;
          if p^='"' then Inc(p); // skip final "
        end;
      '-': // possible start of -- comment
        begin
          Inc(p);
          if p='-' then // -- comment
          begin
            repeat // skip until at end of line
              Inc(p);
            until p^ in [#10, #0];
          end
        end;
      '/': // possible start of /* */ comment
        begin
          Inc(p);
          if p^='*' then // /* */ comment
          begin
            repeat
              Inc(p);
              if p^='*' then // possible end of comment
              begin
                Inc(p);
                if p^='/' then Break; // end of comment
              end;
            until p^=#0;
            if p^='/' then Inc(p); // skip final /
          end;
        end;
      ':','?': // parameter
        begin
          IgnorePart := False;
          if p^=':' then
          begin // find parameter name
            Inc(p);
            if p^=':' then  // ignore ::, since some databases uses this as a cast (wb 4813)
            begin
              IgnorePart := True;
              Inc(p);
            end
            else
            begin
              ParamNameStart:=p;
              while not (p^ in (SQLDelimiterCharacters+[#0])) do
                Inc(p);
              ParamName:=Copy(ParamNameStart,1,p-ParamNameStart);
            end;
          end
          else
          begin
            Inc(p);
            ParamNameStart:=p;
            ParamName:='';
          end;

          if not IgnorePart then
          begin
            Inc(ParamCount);
            if ParamCount>Length(ParamPart) then
            begin
              NewLength:=Length(ParamPart)+ParamAllocStepSize;
              SetLength(ParamPart,NewLength);
              SetLength(ParamBinding,NewLength);
            end;

            if DoCreate then
              begin
              // Check if this is the first occurance of the parameter
              tmpParam := FindParam(ParamName);
              // If so, create the parameter and assign the Parameterindex
              if not assigned(tmpParam) then
                ParameterIndex := CreateParam(ftUnknown, ParamName, ptInput).Index
              else  // else only assign the ParameterIndex
                ParameterIndex := tmpParam.Index;
              end
            // else find ParameterIndex
            else
              begin
                if ParamName<>'' then
                  ParameterIndex:=ParamByName(ParamName).Index
                else
                begin
                  ParameterIndex:=QuestionMarkParamCount;
                  Inc(QuestionMarkParamCount);
                end;
              end;
            if ParameterStyle in [psPostgreSQL,psSimulated] then
              begin
              if ParameterIndex > 8 then
                inc(NewQueryLength,2)
              else
                inc(NewQueryLength,1)
              end;

            // store ParameterIndex in FParamIndex, ParamPart data
            ParamBinding[ParamCount-1]:=ParameterIndex;
            ParamPart[ParamCount-1].Start:=ParamNameStart-BufStart;
            ParamPart[ParamCount-1].Stop:=p-BufStart+1;

            // update NewQueryLength
            Dec(NewQueryLength,p-ParamNameStart);
          end;
        end;
      #0:Break;
    else
      Inc(p);
    end;
  until false;

  SetLength(ParamPart,ParamCount);
  SetLength(ParamBinding,ParamCount);

  if ParamCount>0 then
  begin
    // replace :ParamName by ? for interbase and by $x for postgresql/psSimulated
    // (using ParamPart array and NewQueryLength)
    if (ParameterStyle = psSimulated) and (length(ReplaceString) > 1) then
      inc(NewQueryLength,(paramcount)*(length(ReplaceString)-1));

    SetLength(NewQuery,NewQueryLength);
    NewQueryIndex:=1;
    BufIndex:=1;
    for i:=0 to High(ParamPart) do
    begin
      CopyLen:=ParamPart[i].Start-BufIndex;
      Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen);
      Inc(NewQueryIndex,CopyLen);
      case ParameterStyle of
        psInterbase : NewQuery[NewQueryIndex]:='?';
        psPostgreSQL,
        psSimulated : begin
                        ParamName := IntToStr(ParamBinding[i]+1);
                        for b := 1 to length(ReplaceString) do
                          begin
                          NewQuery[NewQueryIndex]:='$';
                          Inc(NewQueryIndex);
                          end;
                        NewQuery[NewQueryIndex]:= paramname[1];
                        if length(paramname)>1 then
                          begin
                          Inc(NewQueryIndex);
                          NewQuery[NewQueryIndex]:= paramname[2]
                          end;
                      end;
      end;
      Inc(NewQueryIndex);
      BufIndex:=ParamPart[i].Stop;
    end;
    CopyLen:=Length(SQL)+1-BufIndex;
    Move(SQL[BufIndex],NewQuery[NewQueryIndex],CopyLen);
  end
  else
    NewQuery:=SQL;
    
  Result := NewQuery;
end;

function  tmseparams.parsesql(const sql: string; const docreate: boolean;
        parameterstyle : tparamstyle; var parambinding: tparambinding): string;
var
 rs: string;
begin
 result := parsesql(sql,docreate,parameterstyle,parambinding,rs);
end;

function tmseparams.parsesql(const sql: string; const docreate: boolean;
               const parameterstyle: tparamstyle): string;
var
 pb: tparambinding;
 rs: string;
begin
 result:= parsesql(sql,docreate,parameterstyle,pb,rs);
end;

function tmseparams.parsesql(const sql: string; const docreate: boolean): string;
var
 pb: TParamBinding;
 rs: string;
begin
 result:= parsesql(sql,docreate,psinterbase,pb,rs);
end;

end.
