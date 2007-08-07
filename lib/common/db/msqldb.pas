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

uses 
 sysutils,classes,db,msebufdataset,msetypes,msedb,mseclasses,msedatabase,
 msestrings;

type 
 TSchemaType = (stNoSchema,stTables,stSysTables,stProcedures,stColumns,
                    stProcedureParams,stIndexes,stPackages);
 sqlconnoptionty = (sco_supportparams,sco_emulateretaining);
 sqlconnoptionsty = set of sqlconnoptionty;

type
  tcustomsqlconnection = class;
  TSQLTransaction = class;
  TSQLQuery = class;

  TStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

  TSQLHandle = Class(TObject)
  end;
  
  icursorclient = interface(iblobchache)
  end; 

  TSQLCursor = Class(TSQLHandle)
   private
    fblobs: stringarty;
    fblobcount: integer;
    fowner: icursorclient;
   protected
   public
    FPrepared      : Boolean;
    FInitFieldDef  : Boolean;
    FStatementType : TStatementType;
    ftrans: pointer;
    fname: ansistring;
//    property query: tsqlquery read fquery;
    constructor create(const aowner: icursorclient; const aname: ansistring);
                   //aowner can be nil
    procedure close; virtual;
    function wantblobfetch: boolean;
    function getcachedblob(const blobid: integer): tstream;
    function addblobdata(const adata: pointer; const alength: integer): integer;
                                            overload;
    procedure addblobcache(const aid: int64; const adata: string);
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


type
 
 econnectionerror = class(edatabaseerror)
  private
   ferror: integer;
   ferrormessage: msestring;
   fsender: tcustomsqlconnection;
  public
   constructor create(const asender: tcustomsqlconnection; const amessage: ansistring;
              const aerrormessage: msestring; const aerror: integer);
   property sender: tcustomsqlconnection read fsender;
   property error: integer read ferror;
   property errormessage: msestring read ferrormessage;
 end;
 
 tmsesqlscript = class;
 tcustomsqlconnection = class (TmDatabase)
  private
    FPassword            : string;
    FTransaction         : TSQLTransaction;
    FUserName            : string;
    FHostName            : string;
    FCharSet             : string;
    FRole                : String;

   fafterconnect: tmsesqlscript;
   fbeforedisconnect: tmsesqlscript;
   fdatasets1: datasetarty;
   frecnos: integerarty;
   procedure SetTransaction(Value : TSQLTransaction);
   procedure GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);
   function getconnected: boolean;
   procedure setafteconnect(const avalue: tmsesqlscript);
   procedure setbeforedisconnect(const avalue: tmsesqlscript);
   procedure closeds;
   procedure reopends;
  protected
    FConnOptions: sqlconnoptionsty;
   
  procedure finalizetransaction(const atransaction: tsqlhandle); virtual; 
   procedure setconnected(const avalue: boolean);
   procedure notification(acomponent: tcomponent; operation: toperation); override;
   
    function StrToStatementType(s : string) : TStatementType; virtual;
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetAsSQLText(Field : TField) : string; overload; virtual;
    function GetAsSQLText(Param : TParam) : string; overload; virtual;
    function GetHandle : pointer; virtual;
    procedure updateprimarykeyfield(const afield: tfield); virtual;

    Function AllocateTransactionHandle : TSQLHandle; virtual; abstract;

    procedure Execute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
                                 const AParams : TParams); virtual; abstract;
    function GetTransactionHandle(trans : TSQLHandle): pointer; virtual; abstract;
    function Commit(trans : TSQLHandle) : boolean; virtual; abstract;
    function RollBack(trans : TSQLHandle) : boolean; virtual; abstract;
    function StartdbTransaction(const trans : TSQLHandle;
                     const aParams : string) : boolean; virtual; abstract;
    procedure internalcommitretaining(trans : tsqlhandle); virtual; abstract;
    procedure internalrollbackretaining(trans : tsqlhandle); virtual; abstract;
    
    procedure CommitRetaining(trans : TSQLHandle); virtual;
    procedure RollBackRetaining(trans : TSQLHandle); virtual;
    function getblobdatasize: integer; virtual; abstract;
    function getnumboolean: boolean; virtual;

    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                          const TableName : string); virtual;
    function getprimarykeyfield(const atablename: string;
                      const acursor: tsqlcursor): string; virtual;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; virtual;
    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream; virtual;
    
    procedure closeds(out activeds: integerarty);
    procedure reopends(const activeds: integerarty);
  public
    procedure updateutf8(var autf8: boolean); virtual;
    procedure FreeFldBuffers(cursor : TSQLCursor); virtual; abstract;
    Function AllocateCursorHandle(const aowner: icursorclient; 
                const aname: ansistring): TSQLCursor; virtual; abstract;
                //aowner can be nil
                        //aowner used as blob cache
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); virtual; abstract;
    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); virtual; abstract;
    procedure UnPrepareStatement(cursor : TSQLCursor); virtual; abstract;
    procedure AddFieldDefs(const cursor: TSQLCursor;
                        const FieldDefs: TfieldDefs); virtual; abstract;
    function Fetch(cursor : TSQLCursor) : boolean; virtual; abstract;
    function loadfield(const cursor: tsqlcursor; 
             const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer): boolean; virtual; abstract;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
           //buffer can be nil
           //false if null
    function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; virtual;
                              //null based
    
    procedure Close;
    procedure Open;
    property Handle: Pointer read GetHandle;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure EndTransaction; override;
    property ConnOptions: sqlconnoptionsty read FConnOptions;
    procedure executedirect(const asql: string); overload;
    procedure executedirect(const asql: string;
         atransaction: tsqltransaction;
         const aparams: tparams = nil); overload;
    procedure GetTableNames(List : TStrings; SystemTables : Boolean = false); virtual;
    procedure GetProcedureNames(List : TStrings); virtual;
    procedure GetFieldNames(const TableName : string; List :  TStrings); virtual;
    function getinsertid: int64; virtual;
    
    property Password : string read FPassword write FPassword;
    property Transaction : TSQLTransaction read FTransaction write SetTransaction;
    property UserName : string read FUserName write FUserName;
    property CharSet : string read FCharSet write FCharSet;
    property HostName : string Read FHostName Write FHostName;

    property Connected: boolean read getconnected write setconnected default false;
    Property Role :  String read FRole write FRole;
    property afterconnect: tmsesqlscript read fafterconnect write setafteconnect;
    property beforedisconnect: tmsesqlscript read fbeforedisconnect write setbeforedisconnect;
  end;

 tsqlconnection = class(tcustomsqlconnection)
  published
    property Password;
    property Transaction;
    property UserName;
    property CharSet;
    property HostName;

    property Connected;
    Property Role;
    property DatabaseName;
    property KeepConnection;
    property LoginPrompt;
    property Params;
    property afterconnect;
    property beforedisconnect;
    property OnLogin;
 end;
 
  TCommitRollbackAction = (caNone, caCommit, caCommitRetaining, caRollback,
    caRollbackRetaining);
  transactionoptionty = (tao_fake,tao_catcherror);
  transactionoptionsty = set of transactionoptionty;
  sqltransactioneventty = procedure(const sender: tsqltransaction) of object;
  commiterroreventty = procedure(const sender: tsqltransaction;
               const aexception: exception; var handled: boolean) of object;
  
  TSQLTransaction = class (TmDBTransaction)
   private
    FTrans: TSQLHandle;
    FAction: TCommitRollbackAction;
    FParams: TStringList;
    fstartcount: integer;
    foptions: transactionoptionsty;
    fonbeforestart: sqltransactioneventty;
    fonafterstart: sqltransactioneventty;
    fonbeforecommit: sqltransactioneventty;
    fonaftercommit: sqltransactioneventty;
    fonbeforecommitretaining: sqltransactioneventty;
    fonaftercommitretaining: sqltransactioneventty;
    fonbeforerollbackretaining: sqltransactioneventty;
    fonafterrollbackretaining: sqltransactioneventty;
    fonbeforerollback: sqltransactioneventty;
    fonafterrollback: sqltransactioneventty;
    foncommiterror: commiterroreventty;
    procedure setparams(const avalue: TStringList);
    function getdatabase: tcustomsqlconnection;
    procedure setdatabase1(const avalue: tcustomsqlconnection);
    function docommit(const retaining: boolean): boolean;
   protected
    function GetHandle : Pointer; virtual;
    Procedure SetDatabase (Value : tmdatabase); override;
    procedure disconnect(const sender: tsqlquery);
   public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function Commit: boolean; virtual; //true if ok
    function CommitRetaining: boolean; virtual;
    procedure Rollback; virtual;
    procedure RollbackRetaining; virtual;
    procedure StartTransaction; override;
    property Handle: Pointer read GetHandle;
    procedure EndTransaction; override;
   published
    property options: transactionoptionsty read foptions write foptions;
    property Action : TCommitRollbackAction read FAction write FAction;
    property Database: tcustomsqlconnection read getdatabase write setdatabase1;
    property Params : TStringList read FParams write setparams;
    property oncommiterror: commiterroreventty read foncommiterror 
                               write foncommiterror;
    property onbeforestart: sqltransactioneventty read fonbeforestart 
                                     write fonbeforestart;
    property onafterstart: sqltransactioneventty read fonafterstart 
                                     write fonafterstart;
    property onbeforecommit: sqltransactioneventty read fonbeforecommit
                                     write fonbeforecommit;
    property onaftercommit: sqltransactioneventty read fonaftercommit 
                                     write fonaftercommit;
    property onbeforecommitretaining: sqltransactioneventty 
              read fonbeforecommitretaining write fonbeforecommitretaining;
    property onaftercommitretaining: sqltransactioneventty
                   read fonaftercommitretaining write fonaftercommitretaining;
    property onbeforerollback: sqltransactioneventty read fonbeforerollback 
                                     write fonbeforerollback;
    property onafterrollback: sqltransactioneventty read fonafterrollback 
                                     write fonafterrollback;
    property onbeforerollbackretaining: sqltransactioneventty 
                            read fonbeforerollbackretaining
                            write fonbeforerollbackretaining;
    property onafterrollbackretaining: sqltransactioneventty 
                            read fonafterrollbackretaining
                            write fonafterrollbackretaining;
  end;
 
 sqlscripteventty = procedure(const sender: tmsesqlscript;
                                const adatabase: tcustomsqlconnection;
                                const atransaction: tsqltransaction) of object;
 sqlscripterroreventty = procedure(const sender: tmsesqlscript;
                                const adatabase: tcustomsqlconnection;
             const atransaction: tsqltransaction; const e: exception) of object;

 tmsesqlscript = class(tmsecomponent)
  private
   fsql: tstringlist;
   fdatabase: tcustomsqlconnection;
   ftransaction: tsqltransaction;
   fparams: tmseparams;
   fstatementnr: integer;
   fonbeforeexecute: sqlscripteventty;
   fonafterexecute: sqlscripteventty;
   fonerror: sqlscripterroreventty;
   procedure setsql(const avalue: tstringlist);
   procedure setdatabase(const avalue: tcustomsqlconnection);
   procedure settransaction(const avalue: tsqltransaction);
   procedure setparams(const avalue: tmseparams);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
   procedure dobeforeexecute(const adatabase: tcustomsqlconnection;
                              const atransaction: tsqltransaction);
   procedure doafterexecute(const adatabase: tcustomsqlconnection;
                             const atransaction: tsqltransaction);
   procedure doerror(const adatabase: tcustomsqlconnection;
                            const atransaction: tsqltransaction; const e: exception);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure execute(adatabase: tcustomsqlconnection = nil;
                        atransaction: tsqltransaction = nil); overload;
   property statementnr: integer read fstatementnr; //null based
  published
   property params : tmseparams read fparams write setparams;
   property sql: tstringlist read fsql write setsql;
   property database: tcustomsqlconnection read fdatabase write setdatabase;
   property transaction: tsqltransaction read ftransaction write settransaction;
                  //can be nil
   property onbeforeexecute: sqlscripteventty read fonbeforeexecute 
                                                     write fonbeforeexecute;
   property onafterexecute: sqlscripteventty read fonafterexecute 
                                                     write fonafterexecute;
   property onerror: sqlscripterroreventty read fonerror write fonerror;
 end;
 
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

 tmsemasterparamsdatalink = class(tmasterparamsdatalink)
  protected
   procedure domasterchange; override;
 end;
 
 isqlclient = interface(idatabaseclient)
  function getsqltransaction: tsqltransaction;
  procedure setsqltransaction(const avalue: tsqltransaction);
  procedure unprepare;
 end;
 
  TSQLQuery = class (tmsebufdataset,isqlclient,icursorclient)
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
    FMasterLink          : TmseMasterParamsDatalink;
//    FSchemaInfo          : TSchemaInfo;

    FUpdateQry,
    FDeleteQry,
    FInsertQry           : TSQLQuery;

    fblobintf: iblobconnection;
   
//   fIsPrepared: boolean;
   fbeforeexecute: tmsesqlscript;
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
   function getdatabase1: tcustomsqlconnection;
   procedure setdatabase1(const avalue: tcustomsqlconnection);
//   procedure checkdatabase;
   procedure setparams(const avalue: TmseParams);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure setFSQL(const avalue: TStringlist);
   procedure setFSQLUpdate(const avalue: TStringlist);
   procedure setFSQLInsert(const avalue: TStringlist);
   procedure setFSQLDelete(const avalue: TStringlist);
   procedure setbeforeexecute(const avalue: tmsesqlscript);
   function getsqltransaction: tsqltransaction;
   procedure setsqltransaction(const avalue: tsqltransaction);
  protected
   FTableName           : string;
   FReadOnly            : boolean;
   fprimarykeyfield: tfield;
      
   procedure notification(acomponent: tcomponent; operation: toperation); override;
   
   // abstract & virtual methods of TBufDataset
   function Fetch : boolean; override;
   function getblobdatasize: integer; override;
   function getnumboolean: boolean; virtual;
   function blobscached: boolean; override;
   function loadfield(const afield: tfield; const buffer: pointer;
                    var bufsize: integer): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
   // abstract & virtual methods of TDataset
   procedure UpdateIndexDefs; override;
   procedure SetDatabase(const Value: tmdatabase); override;
   Procedure SetTransaction(const Value : tmdbtransaction); override;
   procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
   procedure InternalClose; override;
   procedure InternalInitFieldDefs; override;
   procedure connect(const aexecute: boolean);
   procedure freequery;
   procedure disconnect;
   procedure InternalOpen; override;
   function closetransactiononrefresh: boolean; virtual;
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
    property connected: boolean read getconnected write setconnected;
  published
    property ReadOnly : Boolean read FReadOnly write SetReadOnly;
    property params : tmseparams read fparams write setparams;
                       //before SQL
    property SQL : TStringlist read FSQL write setFSQL;
    property SQLUpdate : TStringlist read FSQLUpdate write setFSQLUpdate;
    property SQLInsert : TStringlist read FSQLInsert write setFSQLInsert;
    property SQLDelete : TStringlist read FSQLDelete write setFSQLDelete;
    property beforeexecute: tmsesqlscript read fbeforeexecute write setbeforeexecute;
    property IndexDefs : TIndexDefs read GetIndexDefs;
    property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode;
    property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey;
    property StatementType : TStatementType read GetStatementType;
    property ParseSQL : Boolean read FParseSQL write SetParseSQL;
    Property DataSource : TDatasource Read GetDataSource Write SetDatasource;
    property database: tcustomsqlconnection read getdatabase1 write setdatabase1;
    
//    property SchemaInfo : TSchemaInfo read FSchemaInfo default stNoSchema;
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
//    property Database;

    property Transaction: tsqltransaction read getsqltransaction write setsqltransaction;
  end;

procedure updateparams(const aparams: tparams);
procedure doexecute(const aparams: tparams; const atransaction: tmdbtransaction;
                    const acursor: tsqlcursor; adatabase: tmdatabase);
procedure checksqlconnection(const aname: ansistring; const avalue: tmdatabase);
procedure dosetsqldatabase(const sender: isqlclient; const avalue: tmdatabase;
                 var acursor: tsqlcursor; var dest: tmdatabase);

implementation
uses 
 dbconst,strutils,msedatalist,msereal,msestream,msegui;
 
procedure updateparams(const aparams: tparams);
var
 int1: integer;
begin
 if aparams <> nil then begin
  for int1:= 0 to aparams.count - 1 do begin
   with aparams[int1] do begin
    if not isnull and (datatype in [ftFloat,ftDate,ftTime,ftDateTime]) and
                               isemptyreal(asfloat) then begin
     clear;
    end;
   end;
  end;
 end;
end;

procedure doexecute(const aparams: tparams; const atransaction: tmdbtransaction;
                    const acursor: tsqlcursor; adatabase: tmdatabase);
begin
 updateparams(aparams);
 acursor.ftrans:= tsqltransaction(atransaction).handle;
 tcustomsqlconnection(adatabase).execute(acursor,tsqltransaction(atransaction),aParams);
end;

procedure checksqlconnection(const aname: ansistring; const avalue: tmdatabase);
begin
 if (avalue <> nil) and not (avalue is tcustomsqlconnection) then begin
  exception.create(aname+': Database must be tcustomsqlconnection.');
 end;
end;

procedure checksqltransaction(const aname: ansistring; const avalue: tmdbtransaction);
begin
 if (avalue <> nil) and not (avalue is tsqltransaction) then begin
  exception.create(aname+': Transaction must be tsqltransaction.');
 end;
end;

procedure dosetsqldatabase(const sender: isqlclient; const avalue: tmdatabase;
              var acursor: tsqlcursor; var dest: tmdatabase);
begin
 if (dest <> avalue) then begin
  checksqlconnection(sender.getname,avalue);
  sender.unprepare;
  if acursor <> nil then begin
   tcustomsqlconnection(dest).deallocatecursorhandle(acursor);
  end;  
  dosetdatabase(sender,avalue,dest);
  if (avalue <> nil) and (sender.getsqltransaction = nil) and 
                    (avalue <> nil) then begin
   sender.setsqltransaction(tcustomsqlconnection(avalue).transaction);
  end;
 end;
end;

(*
type
 TDBTransactioncracker = Class(TComponent)
  Private
    FActive        : boolean;
    FDatabase      : tmdatabase;
    FDataSets      : TList;
    FOpenAfterRead : boolean;
 end;
{$ifdef mse_FPC_2_2}
  TDatabasecracker = class(TCustomConnection)
  private
    FConnected : Boolean;
    FDataBaseName : String;
    FDataSetxx : TList;
    FTransactionsxx : TList;
    FDirectory : String;
    FKeepConnection : Boolean;
    FParams : TStrings;
    FSQLBased : Boolean;
    FOpenAfterRead : boolean;
  end;
{$else}
  TDatabasecracker = class(TComponent)
  private
    FConnected : Boolean;
    FDataBaseName : String;
    FDataSetsxx : TList;
    FTransactionsxx : TList;
    FDirectory : String;
    FKeepConnection : Boolean;
    FLoginPrompt : Boolean;
    FOnLogin : TLoginEvent;
    FParams : TStrings;
    FSQLBased : Boolean;
    FOpenAfterRead : boolean;
  end;
{$endif}
*)
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

{ tcustomsqlconnection }

function tcustomsqlconnection.StrToStatementType(s : string) : TStatementType;

var T : TStatementType;

begin
  S:=Lowercase(s);
  For t:=stselect to strollback do
    if (S=StatementTokens[t]) then
      Exit(t);
end;

procedure tcustomsqlconnection.SetTransaction(Value : TSQLTransaction);
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

procedure tcustomsqlconnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                  const TableName : string);

begin
 //dummy
end;

procedure tcustomsqlconnection.DoInternalConnect;
begin
  if (DatabaseName = '') then
    DatabaseError(SErrNoDatabaseName,self);
end;

procedure tcustomsqlconnection.DoInternalDisconnect;
begin
end;

destructor tcustomsqlconnection.Destroy;
begin
  inherited Destroy;
end;

procedure tcustomsqlconnection.StartTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.StartTransaction;
end;

procedure tcustomsqlconnection.EndTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.EndTransaction;
end;

procedure tcustomsqlconnection.executedirect(const asql: string);
begin
 executedirect(asql,ftransaction);
end;

Procedure tcustomsqlconnection.ExecuteDirect(const aSQL: String;
          ATransaction: TSQLTransaction;
          const aparams: tparams = nil);

var 
 Cursor: TSQLCursor;
begin
 if atransaction = nil then begin
  atransaction:= ftransaction;
 end;
  if not assigned(ATransaction) then
    DatabaseError(SErrTransactionnSet);
  connected:= true;
//  if not Connected then Open;
  if not ATransaction.Active then ATransaction.StartTransaction;

  try
    Cursor := AllocateCursorHandle(nil,name);
    cursor.ftrans:= atransaction.handle;
//    SQL := TrimRight(SQL);

    if trimright(asql) = '' then
      DatabaseError(SErrNoStatement);

    Cursor.FStatementType := stNone;

    PrepareStatement(cursor,ATransaction,aSQL,aparams);
    cursor.ftrans:= atransaction.handle;
    execute(cursor,atransaction,aparams);
    UnPrepareStatement(Cursor);
  finally;
    DeAllocateCursorHandle(Cursor);
  end;
end;

procedure tcustomsqlconnection.GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);

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


procedure tcustomsqlconnection.GetTableNames(List: TStrings; SystemTables: Boolean);
begin
  if not systemtables then GetDBInfo(stTables,'','table_name',List)
    else GetDBInfo(stSysTables,'','table_name',List);
end;

procedure tcustomsqlconnection.GetProcedureNames(List: TStrings);
begin
  GetDBInfo(stProcedures,'','proc_name',List);
end;

procedure tcustomsqlconnection.GetFieldNames(const TableName: string; List: TStrings);
begin
  GetDBInfo(stColumns,TableName,'column_name',List);
end;

function tcustomsqlconnection.GetAsSQLText(Field : TField) : string;

begin
 result:= fieldtosql(field);
 {
  if (not assigned(field)) or field.IsNull then Result := 'Null'
  else case field.DataType of
    ftString   : Result := '''' + field.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Field.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Field.AsDateTime) + ''''
  else
    Result := field.asstring;
  end; 
  }
end;

function tcustomsqlconnection.GetAsSQLText(Param: TParam) : string;

begin
 result:= paramtosql(param);
 {
  if (not assigned(param)) or param.IsNull then Result := 'Null'
  else case param.DataType of
    ftString   : Result := '''' + param.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Param.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Param.AsDateTime) + ''''
  else
    Result := Param.asstring;
  end;
 }
end;


function tcustomsqlconnection.GetHandle: pointer;
begin
  Result := nil;
end;

function tcustomsqlconnection.GetSchemaInfoSQL( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string;

begin
 result:= ''; //compiler warning
 DatabaseError(SMetadataUnavailable);
end;

function tcustomsqlconnection.CreateBlobStream(const Field: TField;
              const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;

begin
 result:= nil; //compiler warning
 DatabaseErrorFmt(SUnsupportedFieldType,['Blob']);
end;

procedure tcustomsqlconnection.closeds(out activeds: integerarty);
var
 int1: integer;
begin
 setlength(activeds,datasetcount);
 for int1:= 0 to high(activeds) do begin
  with datasets[int1] do begin
   if active then begin
    activeds[int1]:= datasets[int1].recno;
    active:= false;
   end
   else begin
    activeds[int1]:= -2;
   end;
  end;
 end;
end;

procedure tcustomsqlconnection.reopends(const activeds: integerarty);
var
 int1: integer;
begin
 for int1:= 0 to high(activeds) do begin
  if activeds[int1] >= -1 then begin
   with datasets[int1] do begin
    active:= true;
    disablecontrols;
    if activeds[int1] >= 0 then begin
     try
      moveby(maxint);
      recno:= activeds[int1];
     except
     end;
    end;
    enablecontrols;
   end;
  end;
 end;
end;

function tcustomsqlconnection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tcustomsqlconnection.setconnected(const avalue: boolean);
var
 int1: integer;
begin
// with tdatabasecracker(self) do begin
  If aValue <> FConnected then begin
   If aValue then begin
    if csReading in ComponentState then begin
     FOpenAfterRead:= true;
     exit;
    end
    else begin
     DoInternalConnect;
     if fafterconnect <> nil then begin
      fconnected:= true; //avoid recursion
//      fafterconnect.execute(self,ftransaction);
      fafterconnect.execute(self);
     end;
    end;
   end
   else begin
//    Closedatasets;
    if fbeforedisconnect <> nil then begin
//     fbeforedisconnect.execute(self,ftransaction);
     fbeforedisconnect.execute(self);
     ftransaction.commit;
    end;
    for int1:= datasetcount - 1 downto 0 do begin
     with tsqlquery(datasets[int1]) do begin
      if (transaction = nil) or (transaction.active) then begin
       close; //not disconnected
      end;
     end;
    end;
    Closetransactions;
    for int1:= 0 to transactioncount - 1 do begin
     with tsqltransaction(transactions[int1]) do begin
      if ftrans <> nil then begin
       finalizetransaction(ftrans);
      end;
     end;
    end;
    DoInternalDisConnect;
    if csloading in ComponentState then begin
     FOpenAfterRead := false;
    end;
   end;
   FConnected:= aValue;
  end;
// end;
end;

procedure tcustomsqlconnection.setafteconnect(const avalue: tmsesqlscript);
begin
 if fafterconnect <> nil then begin
  fafterconnect.removefreenotification(self);
 end;
 fafterconnect:= avalue;
 if fafterconnect <> nil then begin
  fafterconnect.freenotification(self);
 end;
end;

procedure tcustomsqlconnection.setbeforedisconnect(const avalue: tmsesqlscript);
begin
 if fbeforedisconnect <> nil then begin
  fbeforedisconnect.removefreenotification(self);
 end;
 fbeforedisconnect:= avalue;
 if fbeforedisconnect <> nil then begin
  fbeforedisconnect.freenotification(self);
 end;
end;

procedure tcustomsqlconnection.notification(acomponent: tcomponent;
               operation: toperation);
var
 int1: integer;
begin
 if operation = opremove then begin
  if acomponent = fafterconnect then begin
   fafterconnect:= nil;
  end;
  if acomponent = fbeforedisconnect then begin
   fbeforedisconnect:= nil;
  end;
  int1:= finditem(pointerarty(fdatasets1),acomponent);
  if int1 >= 0 then begin
   fdatasets1[int1]:= nil;
  end;
 end;
 inherited;
end;

procedure tcustomsqlconnection.Close;
begin
 connected:= false;
end;

procedure tcustomsqlconnection.Open;
begin
 connected:= true;
end;

procedure tcustomsqlconnection.updateprimarykeyfield(const afield: tfield);
begin
 //dummy
end;

function tcustomsqlconnection.getprimarykeyfield(const atablename: string;
                               const acursor: tsqlcursor): string;
begin
 result:= '';
end;

function tcustomsqlconnection.getnumboolean: boolean;
begin
 result:= true;
end;

function tcustomsqlconnection.getinsertid: int64;
begin
 databaseerror('Connection has no insert ID''s.');
end;

procedure tcustomsqlconnection.closeds;
var
 int1: integer;
begin
 setlength(fdatasets1,datasetcount);
 setlength(frecnos,length(fdatasets1));
 for int1:= high(fdatasets1) downto 0 do begin
  fdatasets1[int1]:= datasets[int1];
  with fdatasets1[int1] do begin
   freenotification(self);
   if active then begin
    frecnos[int1]:= recno;
   end
   else begin
    frecnos[int1]:= -2;
   end;
  end;
 end;
 for int1:= high(fdatasets1) downto 0 do begin
  if (fdatasets1[int1] <> nil) and 
                 (tmdbdataset(fdatasets1[int1]).database = self) then begin
   with fdatasets1[int1] do begin
    active:= false;
   end;
  end;
 end;
end;

procedure tcustomsqlconnection.reopends;
var
 int1: integer;
begin
 for int1:= 0 to high(fdatasets1) do begin
  if fdatasets1[int1] <> nil then begin
   if frecnos[int1] >= -1 then begin
    with tmdbdataset(fdatasets1[int1]) do begin
     if database = self then begin
      disablecontrols;
      active:= true;
      if frecnos[int1] >= 0 then begin
       try
        moveby(frecnos[int1]-recno);
       except
       end;
      end;
      enablecontrols;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomsqlconnection.CommitRetaining(trans: TSQLHandle);
begin
 if sco_emulateretaining in fconnoptions then begin
  closeds; //cursors are lost
  try
   try
    internalcommitretaining(trans);
   finally
    reopends;
   end;
  finally
   fdatasets1:= nil;
   frecnos:= nil;
  end;
 end
 else begin
  internalcommitretaining(trans);
 end;
end;

procedure tcustomsqlconnection.RollBackRetaining(trans: TSQLHandle);
begin
 if sco_emulateretaining in fconnoptions then begin
  closeds; //cursors are lost
  try
   try
    internalrollbackretaining(trans);
   finally
    reopends;
   end;
  finally
   fdatasets1:= nil;
   frecnos:= nil;
  end;
 end
 else begin
  internalrollbackretaining(trans);
 end;
end;

procedure tcustomsqlconnection.finalizetransaction(const atransaction: tsqlhandle);
begin
 //dummy
end;

function tcustomsqlconnection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
begin
 raise edatabaseerror.create(name+': fetchblob not supported.');
end;

procedure tcustomsqlconnection.updateutf8(var autf8: boolean);
begin
 //dummy
end;

{ TSQLTransaction }

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
 freeandnil(ftrans);
end;

procedure TSQLTransaction.StartTransaction;
var 
 db: tcustomsqlconnection;
 int1: integer;
begin
 if Active then begin
  DatabaseError(SErrTransAlreadyActive);
 end;
 db:= tcustomsqlconnection(database);
 if Db = nil then begin
  DatabaseError(SErrDatabasenAssigned);
 end;
 inc(fstartcount);
 int1:= fstartcount;
 if checkcanevent(self,tmethod(fonbeforestart)) then begin
  fonbeforestart(self);
 end;
 if not Db.Connected then begin
  Db.Open;
 end;
 if int1 <> fstartcount then begin
  exit;
 end;
 if not assigned(FTrans) then begin
  FTrans:= Db.AllocateTransactionHandle;
 end;
 if (tao_fake in foptions) or 
                 Db.StartdbTransaction(FTrans,FParams.CommaText) then begin
  OpenTrans;
 end;
 if checkcanevent(self,tmethod(fonafterstart)) then begin
  fonafterstart(self);
 end;
end;

procedure TSQLTransaction.EndTransaction;

begin
 case faction of
  caCommit: commit;
  caCommitRetaining: commitretaining;
  caRollbackRetaining: rollbackretaining;
  else rollback;        //canone,caRollback
 end;
end;

function TSQLTransaction.GetHandle: pointer;
begin
  Result := (Database as tcustomsqlconnection).GetTransactionHandle(FTrans);
end;

function tsqltransaction.docommit(const retaining: boolean): boolean;
 procedure dofinish;
 begin
  if not retaining then begin
   closetrans;
   closedatasets;
  end;
 end;
var
 bo1: boolean;
begin
 if not (tao_fake in foptions) then begin
  try
   if retaining then begin
    tcustomsqlconnection(database).commitretaining(FTrans);
   end
   else begin
    tcustomsqlconnection(database).commit(FTrans);
   end;
  except
   on e: exception do begin
    bo1:= false;
    if checkcanevent(self,tmethod(foncommiterror)) then begin
     foncommiterror(self,e,bo1);
    end;
    if not bo1 then begin
     if tao_catcherror in foptions then begin
      application.handleexception(self);
      exit;
     end
     else begin
      dofinish;
      raise;
     end;
    end;
   end;
  end;
 end;
 dofinish;
end;

function TSQLTransaction.Commit: boolean;
var
 bo1: boolean;
begin
 result:= true;
 if active then begin
  if checkcanevent(self,tmethod(fonbeforecommit)) then begin
   fonbeforecommit(self);
  end;
  result:= docommit(false);
  if result and checkcanevent(self,tmethod(fonaftercommit)) then begin
   fonaftercommit(self);
  end;
 end;
end;

function TSQLTransaction.CommitRetaining: boolean;
begin
 result:= true;
 if active then begin
  if checkcanevent(self,tmethod(fonbeforecommitretaining)) then begin
   fonbeforecommitretaining(self);
  end;
  result:= docommit(true);
  if result and checkcanevent(self,tmethod(fonaftercommitretaining)) then begin
   fonaftercommitretaining(self);
  end;
 end;
end;

procedure TSQLTransaction.Rollback;
begin
 if active then begin
  if checkcanevent(self,tmethod(fonbeforerollback)) then begin
   fonbeforerollback(self);
  end;
  closedatasets;
  if (tao_fake in foptions) or tcustomsqlconnection(database).RollBack(FTrans) then begin
   CloseTrans;
  end;
  if checkcanevent(self,tmethod(fonafterrollback)) then begin
   fonafterrollback(self);
  end;
 end;
end;

procedure TSQLTransaction.RollbackRetaining;
begin
 if active then begin
  if checkcanevent(self,tmethod(fonbeforerollbackretaining)) then begin
   fonbeforerollback(self);
  end;
  if not (tao_fake in foptions) then begin
   tcustomsqlconnection(database).RollBackRetaining(FTrans);
  end;
  if checkcanevent(self,tmethod(fonafterrollbackretaining)) then begin
   fonafterrollback(self);
  end;
 end;
end;

procedure tsqltransaction.disconnect(const sender: tsqlquery);
var
 int1: integer;
 intf1: itransactionclient;
begin
 int1:= 1;
 if sender.fupdateqry <> nil then begin
  inc(int1,3); //insert,update,delete
 end;
 if high(fdatasets) >= int1 then begin 
  databaseerror('Offline mode needs exclusive transaction.',sender);
 end;
 intf1:= itransactionclient(sender);
 removeitem(pointerarty(fdatasets),intf1);
 try
  active:= false;
 finally
  insertitem(pointerarty(fdatasets),0,intf1);
 end;
 {
 if fdatasets.count > int1 then begin
  databaseerror('Offline mode needs exclusive transaction.',sender);
 end;
 fdatasets.remove(sender);
 try
  active:= false;
 finally
  fdatasets.insert(0,sender);
 end;
 }
end;

Procedure TSQLTransaction.SetDatabase(Value : tmdatabase);

begin
 If Value <> Database then begin
  CheckInactive;
  If Assigned(Database) then begin
   with Database as tcustomsqlconnection do begin
    if ftrans <> nil then begin
     finalizetransaction(ftrans);
    end;
    if Transaction = self then begin 
     Transaction:= nil;
    end;
   end; 
  end;
  inherited SetDatabase(Value);
 end;
end;

function tsqltransaction.getdatabase: tcustomsqlconnection;
begin
 result:= tcustomsqlconnection(inherited database);
end;

procedure tsqltransaction.setdatabase1(const avalue: tcustomsqlconnection);
begin
 setdatabase(avalue);
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

Procedure TSQLQuery.SetTransaction(const Value : tmdbtransaction);
begin
 if ftransaction <> value then begin
  checksqltransaction(name,value);
  UnPrepare;
  inherited;
 end;
end;

procedure TSQLQuery.SetDatabase(const Value : tmdatabase);
begin
 dosetsqldatabase(isqlclient(self),value,fcursor,fdatabase);
{
 if (fDatabase <> Value) then begin
  checksqlconnection(name,value);
  UnPrepare;
  if assigned(FCursor) then begin
   tcustomsqlconnection(database).DeAllocateCursorHandle(FCursor);
  end;
  dosetsqldatabase(isqlclient(self),tcustomsqlconnection(value),
                                          tcustomsqlconnection(fdatabase));
  }
  {
  inherited setdatabase(value);
  with tcustomsqlconnection(value) do begin
   if (value <> nil) and (self.Transaction = nil) and 
                   (Transaction <> nil) then begin
    self.transaction:= Transaction;
   end;
  end;
  }
// end;
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
 tcustomsqlconnection(database).unpreparestatement(fcursor);
 fiseof := false;
 inherited internalclose;
 s:= fsqlbuf;
 if filtered and (filter <> '') then begin
  s:= addfilter(s);
 end;
 tcustomsqlconnection(database).preparestatement(fcursor,
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
 db: tcustomsqlconnection;
 sqltr: tsqltransaction;

begin
 if not IsPrepared then begin
  db:= tcustomsqlconnection(database);
  sqltr:= tsqltransaction(transaction);
  checkdatabase(name,db);
  checktransaction(name,sqltr);

  if not Db.Connected then begin
   db.Open;
  end;
  if not sqltr.Active then begin
   sqltr.StartTransaction;
  end;

  if not assigned(fcursor) then begin
   FCursor:= Db.AllocateCursorHandle(icursorclient(self),name);
  end;
  fcursor.ftrans:= sqltr.handle;
  
  FSQLBuf:= TrimRight(FSQL.Text);

  if FSQLBuf = '' then begin
    DatabaseError(SErrNoStatement);
  end;
  SQLParser(FSQLBuf);

  if filtered and (filter <> '') then begin
   Db.PrepareStatement(Fcursor,sqltr,AddFilter(FSQLBuf),FParams)
  end
  else begin
   Db.PrepareStatement(Fcursor,sqltr,FSQLBuf,FParams);
  end;

  if (FCursor.FStatementType = stSelect) then begin
   FCursor.FInitFieldDef := True;
   if not ReadOnly then begin
    InitUpdates(FSQLBuf);
   end;
  end;
 end;
end;

procedure TSQLQuery.UnPrepare;

begin
 if connected then begin
  CheckInactive;
 end;
 if IsPrepared and not (bs_refreshing in fbstate) then begin
  with tcustomsqlconnection(Database) do begin
   UnPrepareStatement(FCursor);
  end;
 end;
end;

procedure TSQLQuery.FreeFldBuffers;
begin
 if not (bs_refreshing in fbstate) and assigned(FCursor) then begin
  tcustomsqlconnection(database).FreeFldBuffers(FCursor);
 end;
end;

function TSQLQuery.Fetch : boolean;
begin
 if not (Fcursor.FStatementType in [stSelect]) then begin
  result:= false;
  Exit;
 end;
 if not FIsEof then begin
  FIsEOF:= not tcustomsqlconnection(database).Fetch(Fcursor);
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
 doexecute(fparams,ftransaction,fcursor,fdatabase);
end;

function tsqlquery.loadfield(const afield: tfield; const buffer: pointer;
                     var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
begin
 result:= tcustomsqlconnection(database).LoadField(FCursor,aField.datatype,
         afield.fieldno-1,buffer,bufsize)
end;

procedure TSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure tsqlquery.freequery;
begin
 if not (bs_refreshing in fbstate) then begin
  if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
        (database as tcustomsqlconnection).UnPrepareStatement(FCursor);
  end;
  FreeAndNil(FUpdateQry);
  FreeAndNil(FInsertQry);
  FreeAndNil(FDeleteQry);
 end;
end;

procedure TSQLQuery.disconnect;
begin
 if bs_connected in fbstate then begin
  if fcursor <> nil then begin
   fcursor.close;
  end;
  freequery;
  exclude(fbstate,bs_connected);
 end;
end;

procedure TSQLQuery.InternalClose;
begin
// Database and FCursor could be nil, for example if the database is not
// assigned, and .open is called
 disconnect;
 fblobintf:= nil;
 fprimarykeyfield:= nil;
 if StatementType = stSelect then FreeFldBuffers;
 if DefaultFields then
   DestroyFields;
 FIsEOF := False;
//  FRecordSize := 0;
 inherited internalclose;
end;

procedure TSQLQuery.InternalInitFieldDefs;
begin
  if FLoadingFieldDefs then
    Exit;

  FLoadingFieldDefs := True;

  try
//    FieldDefs.Clear;
    tcustomsqlconnection(database).AddFieldDefs(fcursor,FieldDefs);
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
			FCursor.FStatementType := (Database as tcustomsqlconnection).StrToStatementType(s);
		
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
                     FCursor.FStatementType := (Database as tcustomsqlconnection).StrToStatementType(s);
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

procedure TSQLQuery.connect(const aexecute: boolean);

  procedure InitialiseModifyQuery(var qry : TSQLQuery; aSQL: TSTringList);  
  begin
   if qry = nil then begin
    qry:= TSQLQuery.Create(nil);
    with qry do begin
     ParseSQL:= False;
     DataBase:= Self.DataBase;
     Transaction:= Self.Transaction;
     SQL.Assign(aSQL);
    end;
   end;
  end; //initialisemodifyquery

var
 tel,fieldc: integer;
 f: TField;
 s: string;
 IndexFields: TStrings;
 str1: string;
 
begin
 if database <> nil then begin
  getcorbainterface(database,typeinfo(iblobconnection),fblobintf);
 end;
 if not streamloading then begin  
  try
   Prepare;
   if FCursor.FStatementType in [stSelect] then begin
    if aexecute then begin
     if fbeforeexecute <> nil then begin
      fbeforeexecute.execute(database,tsqltransaction(transaction));
     end;
     Execute;
     if FCursor.FInitFieldDef then InternalInitFieldDefs;
    end;
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
    if database <> nil then begin
     str1:= tcustomsqlconnection(database).getprimarykeyfield(ftablename,fcursor);
     if (str1 <> '') then begin
      fprimarykeyfield:= fields.findfield(str1);
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
  include(fbstate,bs_connected);
 end;
end;

procedure tsqlquery.internalopen;
begin
 connect(true);
 inherited;
end;
 
procedure tsqlquery.internalrefresh;
var
 int1: integer;
begin
 int1:= recno;
// disablecontrols;            //there is no updtestate in enablecontols
// try
  include(fbstate,bs_refreshing);
  try
   active:= false;
   if closetransactiononrefresh then begin
    transaction.active:= false;
    transaction.active:= true;
   end;
   active:= true;
   setrecno1(int1,true);
  finally
   exclude(fbstate,bs_refreshing);
   if not active then begin
    freefieldbuffers;
    freequery;
   end;
  end;
// finally
//  enablecontrols;
// end;
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
   (database as tcustomsqlconnection).UnPrepareStatement(Fcursor);
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
  if assigned(FCursor) then (Database as tcustomsqlconnection).DeAllocateCursorHandle(FCursor);
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
 findexdefs.clear;
 if assigned(DataBase) and (ftablename <> '') then begin
  tcustomsqlconnection(database).UpdateIndexDefs(FIndexDefs,FTableName);
 end;
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
  if sql_where = '' then begin
   databaseerror('No "where" part in SQLUpdate statement.',self);
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
  if sql_where = '' then begin
   databaseerror('No "where" part in SQLDelete statement.',self);
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
   if (updatekind = ukinsert) and (self.fprimarykeyfield <> nil) then begin
    tcustomsqlconnection(database).updateprimarykeyfield(self.fprimarykeyfield);
   end;
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
  SQL.Add((DataBase as tcustomsqlconnection).GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaPattern));
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
   info.id:= 0; //fieldsize can be 32 bit
   if field.getdata(@info.id) and findcachedblob(info) then begin
    blob1.data:= pointer(info.data);
    blob1.datalength:= length(info.data);
    result:= tblobcopy.create(blob1);
   end;
  end
  else begin
   if database = nil then begin
    if mode = bmwrite then begin
     result:= createblobbuffer(field);
    end;
   end
   else begin
    result:= tcustomsqlconnection(database).CreateBlobStream(Field,
                                        Mode,fcursor);
   end;
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
      FMasterLink:=TmseMasterParamsDataLink.Create(Self);
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

procedure tsqlquery.notification(acomponent: tcomponent; operation: toperation); 
begin
 inherited;
 if operation = opremove then begin
  if acomponent = datasource then begin
   datasource:= nil;
  end;
  if acomponent = fbeforeexecute then begin
   fbeforeexecute:= nil;
  end;
 end;
end;

function TSQLQuery.getblobdatasize: integer;
begin
 if database = nil then begin
  result:= sizeof(int64); //max
 end
 else begin
  result:= tcustomsqlconnection(database).getblobdatasize;
 end;
end;

function TSQLQuery.getdatabase1: tcustomsqlconnection;
begin
 result:= tcustomsqlconnection(inherited database);
end;

procedure TSQLQuery.setdatabase1(const avalue: tcustomsqlconnection);
begin
 inherited database:= avalue;
end;
{
procedure TSQLQuery.checkdatabase;
begin
 docheckdatabase(name,fdatabase);
 if inherited database = nil then begin
  databaseerror(serrdatabasenassigned);
 end;
end;
}
procedure TSQLQuery.executedirect(const asql: string);
begin
 checkdatabase(name,fdatabase);
 database.executedirect(asql,tsqltransaction(transaction)); 
end;

procedure TSQLQuery.setparams(const avalue: TmseParams);
begin
 fparams.assign(avalue);
end;

function tsqlquery.getconnected: boolean;
begin
 result:= bs_connected in fbstate;
// result:= (transaction <> nil) and transaction.active;
end;

function tsqlquery.blobscached: boolean;
begin
 result:= (fblobintf <> nil) and fblobintf.blobscached;
end;

procedure TSQLQuery.setconnected(const avalue: boolean);
begin         //todo: check connect disconnect sequence
 if not (bs_opening in fbstate) then begin
  checkactive;
 end;
 if avalue <> connected then begin
  if avalue then begin
   closelogger;
   connect(false);
  end
  else begin
   if transaction.active then begin
    fetchallblobs;
    tsqltransaction(transaction).disconnect(self);
    disconnect;
    unprepare;
    tcustomsqlconnection(database).DeAllocateCursorHandle(FCursor);
    startlogger;
   end;
  end;
 end;
end;

procedure TSQLQuery.setFSQL(const avalue: TStringlist);
begin
 fsql.assign(avalue);
end;

procedure TSQLQuery.setFSQLUpdate(const avalue: TStringlist);
begin
 fsqlupdate.assign(avalue);
end;

procedure TSQLQuery.setFSQLInsert(const avalue: TStringlist);
begin
 fsqlinsert.assign(avalue);
end;

procedure TSQLQuery.setFSQLDelete(const avalue: TStringlist);
begin
 fsqldelete.assign(avalue);
end;

procedure TSQLQuery.setbeforeexecute(const avalue: tmsesqlscript);
begin
 if fbeforeexecute <> nil then begin
  fbeforeexecute.removefreenotification(self);
 end;
 fbeforeexecute:= avalue;
 if fbeforeexecute <> nil then begin
  fbeforeexecute.freenotification(self);
 end;
end;

function TSQLQuery.closetransactiononrefresh: boolean;
begin
 result:= false;
end;

function TSQLQuery.getnumboolean: boolean;
begin
 result:= tcustomsqlconnection(database).getnumboolean;
end;

function TSQLQuery.getsqltransaction: tsqltransaction;
begin
 result:= tsqltransaction(inherited transaction);
end;

procedure TSQLQuery.setsqltransaction(const avalue: tsqltransaction);
begin
 inherited transaction:= avalue;
end;

{ TSQLCursor }

constructor TSQLCursor.create(const aowner: icursorclient; const aname: ansistring);
begin
 fowner:= aowner;
 fname:= aname;
 inherited create;
end;

function TSQLCursor.addblobdata(const adata: pointer;
                                            const alength: integer): integer;
begin
 if fowner = nil then begin
  result:= fblobcount;
  inc(fblobcount);
  if result > high(fblobs) then begin
   setlength(fblobs,2*result+256);
  end;
  setlength(fblobs[result],alength);
 {$ifdef FPC} {$checkpointer off} {$endif} //adata can be foreign memory
  move(adata^,fblobs[result][1],alength);
 {$ifdef FPC} {$checkpointer default} {$endif}
 end
 else begin
  result:= fowner.addblobcache(adata,alength);
 end;
end;

function TSQLCursor.addblobdata(const adata: string): integer;
begin
 result:= addblobdata(pointer(adata),length(adata));
end;

procedure TSQLCursor.addblobcache(const aid: int64; const adata: string);
begin
 fowner.addblobcache(aid,adata);
end;

procedure TSQLCursor.blobfieldtoparam(const afield: tfield;
               const aparam: tparam; const asstring: boolean = false);
var
 blobid: integer;
 str1: string;
begin
 if afield.getdata(@blobid) then begin
  if fowner = nil then begin
   str1:= fblobs[blobid];
  end
  else begin
   str1:= fowner.getblobcache[blobid].data;
  end;
  if asstring then begin
   aparam.asstring:= str1;
  end
  else begin
   aparam.asblob:= str1;
  end;
 end
 else begin
  aparam.clear;
 end;
end;

function TSQLCursor.getcachedblob(const blobid: integer): tstream;
begin
 if fowner = nil then begin
  result:= tstringcopystream.create(fblobs[blobid]);
 end
 else begin
  result:= tstringcopystream.create(fowner.getblobcache[blobid].data);
 end;
end;

procedure TSQLCursor.close;
begin
 fblobs:= nil;
 fblobcount:= 0;
end;

function TSQLCursor.wantblobfetch: boolean;
begin
 result:= (fowner <> nil) and fowner.blobsarefetched;
end;

{ tmsesqlscript }

constructor tmsesqlscript.create(aowner: tcomponent);
begin
 fparams:= tmseparams.create(self);
 fsql:= tstringlist.create;
 inherited;
end;

destructor tmsesqlscript.destroy;
begin
 fparams.free;
 fsql.free;
 inherited;
end;

procedure tmsesqlscript.setsql(const avalue: tstringlist);
begin
 fsql.assign(avalue);
end;

procedure tmsesqlscript.setdatabase(const avalue: tcustomsqlconnection);
begin
 if fdatabase <> nil then begin
  fdatabase.removefreenotification(self);
 end;
 fdatabase:= avalue;
 if fdatabase <> nil then begin
  fdatabase.freenotification(self);
 end;
end;

procedure tmsesqlscript.settransaction(const avalue: tsqltransaction);
begin
 if ftransaction <> nil then begin
  ftransaction.removefreenotification(self);
 end;
 ftransaction:= avalue;
 if ftransaction <> nil then begin
  ftransaction.freenotification(self);
 end;
end;

function splitsql(const asql: string): stringarty;
var
 po1,po2: pchar;
 
 procedure addstatement;
 begin
  setlength(result,high(result)+2);
  setlength(result[high(result)],po1-po2);
  move(po2^,result[high(result)][1],length(result[high(result)]));
 end;
 
begin
 result:= nil;
 po1:= pchar(asql);
 po2:= po1;
 while true do begin            //todo: skip comments
  case po1^ of
   #0: begin
    break;
   end;
   ';': begin
    inc(po1);
    addstatement;
    po2:= po1;
   end;
   '''': begin
    inc(po1);
    while (po1^ <> '''') and (po1^ <> #0) do begin
     inc(po1);
    end;
    if po1^ = '''' then begin
     inc(po1);
    end;
   end;
   else begin
    inc(po1);
   end;
  end;
 end;
 {
 if po1 <> po2 then begin
  addstatement;
 end;
 }
end;

procedure tmsesqlscript.execute(adatabase: tcustomsqlconnection = nil;
                 atransaction: tsqltransaction = nil);
var
 str1: string;
 ar1: stringarty;
 int1: integer;
begin
 if adatabase = nil then begin
  adatabase:= fdatabase;
 end;
 if atransaction = nil then begin
  atransaction:= ftransaction;
 end; 
 if adatabase = nil then begin
  databaseerror(serrdatabasenassigned,self);
 end;
 dobeforeexecute(adatabase,atransaction);
 try
  str1:= fsql.text;
  ar1:= splitsql(str1);
  if high(ar1) < 0 then begin
   databaseerror(serrnostatement,self);
  end;
  for int1:= 0 to high(ar1) do begin
   fstatementnr:= int1;
   adatabase.executedirect(ar1[int1],atransaction,fparams);
  end;
  doafterexecute(adatabase,atransaction);
 except
  on e: exception do begin  
   doerror(adatabase,atransaction,e);
  end;
 end;
end;

procedure tmsesqlscript.notification(acomponent: tcomponent;
                                             operation: toperation);
begin
 if operation = opremove then begin
  if (acomponent = fdatabase) then begin
   fdatabase:= nil;
  end;
  if (acomponent = ftransaction) then begin
   ftransaction:= nil;
  end;
 end;
 inherited;
end;

procedure tmsesqlscript.setparams(const avalue: tmseparams);
begin
 fparams.assign(avalue);
end;

procedure tmsesqlscript.dobeforeexecute(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction);
begin
 if canevent(tmethod(fonbeforeexecute)) then begin
  fonbeforeexecute(self,adatabase,atransaction);
 end;
end;

procedure tmsesqlscript.doafterexecute(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction);
begin
 if canevent(tmethod(fonafterexecute)) then begin
  fonafterexecute(self,adatabase,atransaction);
 end;
end;

procedure tmsesqlscript.doerror(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction; const e: exception);
begin
 if canevent(tmethod(fonerror)) then begin
  fonerror(self,adatabase,atransaction,e);
 end;
end;

{ tmsemasterparamsdatalink }

procedure tmsemasterparamsdatalink.domasterchange;
begin
 if assigned(onmasterchange) then begin
  onmasterchange(self); 
 end;
 if assigned(params) and assigned(detaildataset) and detaildataset.active then begin
  detaildataset.refresh;
 end;
end;

{ econnectionerror }

constructor econnectionerror.create(const asender: tcustomsqlconnection; 
   const amessage: ansistring; const aerrormessage: msestring; const aerror: integer);
begin
 fsender:= sender;
 ferror:= aerror;
 ferrormessage:= aerrormessage;
 inherited create(asender.name+': '+amessage);
end;

end.
