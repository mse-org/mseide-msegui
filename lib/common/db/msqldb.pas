{
    Copyright (c) 2004 by Joost van der Sluis
    Modified 2006-2011 by Martin Schreiber

    SQL database & dataset

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit msqldb;

{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
{$mode objfpc}{$interfaces corba}{$goto on}
{$H+}
//{$M+}   // ### remove this!!!


interface

uses 
 sysutils,classes,db,msebufdataset,msetypes,msedb,mseclasses,msedatabase,
 msestrings,msedatalist,mseapplication,mseglob,msetimer,msesysenv;

type 
 TSchemaType = (stNoSchema,stTables,stSysTables,stProcedures,stColumns,
                    stProcedureParams,stIndexes,stPackages);
 sqlconnoptionty = (sco_supportparams,sco_emulateretaining,sco_nounprepared);
 sqlconnoptionsty = set of sqlconnoptionty;

type
 tcustomsqlconnection = class;
 TSQLTransaction = class;
 TSQLQuery = class;
 tsqlstringlist = class;
 
 tmacroproperty = class(tdoublemsestringdatalist)
  private
   foptions: macrooptionsty;
   fowner: tsqlstringlist;
  protected
   procedure dochange; override;
  public
   constructor create(const aowner: tsqlstringlist); reintroduce;
  published
   property options: macrooptionsty read foptions write foptions 
                                           default [mao_caseinsensitive];
 end;
  
 TStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

 tsqlstringlist = class(tmsestringdatalist)
  private
   fmacros: tmacroproperty;
   function gettext: msestring;
   procedure settext(const avalue: msestring);
   procedure readstrings(reader: treader);
   procedure writestrings(writer: twriter);
   procedure setmacros(const avalue: tmacroproperty);
  protected
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create; override;
   destructor destroy; override;
   property text: msestring read gettext write settext;
  published
   property macros: tmacroproperty read fmacros write setmacros;
 end;

// updatesqloptionty = (uso_refresh);
// updatesqloptionsty = set of updatesqloptionty;
          //moved to field providerflags pf1_refresh 
{
 tupdatesqlstringlist = class(tsqlstringlist)
  private
//   foptions: updatesqloptionsty;
  published
//   property options: updatesqloptionsty read foptions write foptions default [];
 end;
}  
  TSQLHandle = Class(TObject)
  end;
  
  icursorclient = interface(iblobchache)
   function stringmemo: boolean; //memo fields are text(0) fields
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
    frowsaffected: integer;
    frowsreturned: integer;
//    property query: tsqlquery read fquery;
    constructor create(const aowner: icursorclient; const aname: ansistring);
                   //aowner can be nil
    procedure close; virtual;
    function wantblobfetch: boolean;
    function stringmemo: boolean;
    function getcachedblob(const blobid: integer): tstream;
    function addblobdata(const adata: pointer; const alength: integer): integer;
                                            overload;
    procedure addblobcache(const aid: int64; const adata: string);
    function addblobdata(const adata: string): integer; overload;
    procedure blobfieldtoparam(const afield: tfield; const aparam: tparam;
                     const asstring: boolean = false);
  end;


const
 StatementTokens : Array[TStatementType] of msestring = 
                 ('(none)', 'select',
                  'insert', 'update', 'delete',
                  'create', 'get', 'put', 'execute',
                  'start','commit','rollback', '?'
                 );
 datareturningtypes = [stselect,stexecprocedure];

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
 
 tdbcontroller = class(tactivatorcontroller)
  private
   fdatabasename: filenamety;
   fintf: idbcontroller;
   foptions: databaseoptionsty;
   factioncount: integer;
   factionwait: boolean;   
   procedure setoptions(const avalue: databaseoptionsty);
  protected
   procedure setowneractive(const avalue: boolean); override;
  public
   constructor create(const aowner: tmdatabase; const aintf: idbcontroller);
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
  published
   property options: databaseoptionsty read foptions write setoptions default [];
 end;

 tmsesqlscript = class;
 tcustomsqlconnection = class(TmDatabase,idbcontroller)
  private
    FPassword            : string;
    FTransaction         : TSQLTransaction;
    FUserName            : string;
    FHostName            : string;
    FCharSet             : string;
    FRole                : String;

   fafterconnect: tmsesqlscript;
   fbeforedisconnect: tmsesqlscript;
//   fdatasets1: datasetarty;
   frecnos: integerarty;
   ftransactionwrite: tsqltransaction;
   procedure setcontroller(const avalue: tdbcontroller);
   procedure settransaction(const avalue : tsqltransaction);
   procedure settransactionwrite(const avalue: tsqltransaction);
   procedure GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);
//   function getconnected: boolean;
   procedure setafteconnect(const avalue: tmsesqlscript);
   procedure setbeforedisconnect(const avalue: tmsesqlscript);
//   procedure closeds;
//   procedure reopends;
  protected
   FConnOptions: sqlconnoptionsty;
   fcontroller: tdbcontroller;
   function connectionmessage(atext: pchar): msestring;
   procedure finalizetransaction(const atransaction: tsqlhandle); virtual; 
//   procedure setconnected(const avalue: boolean);
   procedure notification(acomponent: tcomponent; operation: toperation); override;
   
    function StrToStatementType(s : msestring) : TStatementType; virtual;
    procedure DoInternalConnect; override;
    procedure doafterinternalconnect; override;
    procedure dobeforeinternaldisconnect; override;
    procedure DoInternalDisconnect; override;
    function GetAsSQLText(const Field : TField) : string; overload; virtual;
    function GetAsSQLText(const Param : TParam) : string; overload; virtual;
    function GetHandle : pointer; virtual;
    procedure updateprimarykeyfield(const afield: tfield;
                                   const atransaction: tsqltransaction); virtual;

    Function AllocateTransactionHandle : TSQLHandle; virtual; abstract;

    procedure internalexecute(const cursor: tsqlcursor; const atransaction: tsqltransaction;
               const aparams : tmseparams; const autf8: boolean); virtual; abstract;
    procedure internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string); virtual;

    procedure Execute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
               const AParams : TmseParams; const autf8: boolean);
    procedure Executeunprepared(const cursor: TSQLCursor;
                               const atransaction: tsqltransaction;
                               const AParams : TmseParams;
                               const asql: msestring; const autf8: boolean);
    function GetTransactionHandle(trans : TSQLHandle): pointer; virtual; abstract;
    function Commit(trans : TSQLHandle) : boolean; virtual; abstract;
    function RollBack(trans : TSQLHandle) : boolean; virtual; abstract;
    function StartdbTransaction(const trans : TSQLHandle;
                     const aParams: tstringlist) : boolean; virtual; abstract;
    procedure internalcommitretaining(trans : tsqlhandle); virtual; abstract;
    procedure internalrollbackretaining(trans : tsqlhandle); virtual; abstract;
    
    procedure CommitRetaining(trans : TSQLHandle); virtual;
    procedure RollBackRetaining(trans : TSQLHandle); virtual;
    function getblobdatasize: integer; virtual; abstract;
    function getnumboolean: boolean; virtual;
    function getfloatdate: boolean; virtual;
    function getint64currency: boolean; virtual;

    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                          const aTableName : string); virtual;
    function getprimarykeyfield(const atablename: string;
                             const acursor: tsqlcursor): string; virtual;
    function GetSchemaInfoSQL(SchemaType : TSchemaType;
              SchemaObjectName, SchemaPattern : string) : string; virtual;
    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream; virtual;
    
    procedure closeds(out activeds: integerarty);
    procedure reopends(const activeds: integerarty);
    function identquotechar: ansistring; virtual;
    procedure beginupdate; virtual;
    procedure endupdate; virtual;
    function internalExecuteDirect(const aSQL: mseString;
          ATransaction: TSQLTransaction;
          const aparams: tmseparams; aparamvars: array of variant;
          aisutf8: boolean; const noprepare: boolean): integer;
   //idbcontroller
   procedure setinheritedconnected(const avalue: boolean);
   function readsequence(const sequencename: string): string; virtual;
   function sequencecurrvalue(const sequencename: string): string; virtual;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string; virtual;                    
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updateutf8(var autf8: boolean); virtual;
   function isutf8: boolean;
   function todbstring(const avalue: msestring): string;
   procedure FreeFldBuffers(cursor : TSQLCursor); virtual; abstract;
   Function AllocateCursorHandle(const aowner: icursorclient; 
               const aname: ansistring): TSQLCursor; virtual; abstract;
               //aowner can be nil
                       //aowner used as blob cache
   Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); virtual; abstract;
   procedure preparestatement(const cursor: tsqlcursor; 
                 const atransaction : tsqltransaction;
                 const asql: msestring; const aparams : tmseparams); 
                                virtual; abstract; overload;
   procedure UnPrepareStatement(cursor : TSQLCursor); virtual; abstract;
   procedure AddFieldDefs(const cursor: TSQLCursor;
                       const FieldDefs: TfieldDefs); virtual; abstract;
   function Fetch(cursor : TSQLCursor) : boolean; virtual; abstract;
   function loadfield(const cursor: tsqlcursor; 
            const datatype: tfieldtype; const fieldnum: integer; //null based
     const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean; virtual; abstract;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
          //buffer can be nil
          //false if null
   function fetchblob(const cursor: tsqlcursor;
                             const fieldnum: integer): ansistring; virtual;
                             //null based
   
   procedure Close;
   procedure Open;
   property Handle: Pointer read GetHandle;
   procedure StartTransaction; override;
   procedure EndTransaction; override;
   property ConnOptions: sqlconnoptionsty read FConnOptions;
   function executedirect(const asql: msestring;
                   const aisutf8: boolean = false): integer; overload;
              //returns rowsaffected or -1 if not supported
   function executedirect(const asql: msestring;
        atransaction: tsqltransaction;
        const aparams: tmseparams = nil;
        const aisutf8: boolean = false;
        const anoprepare: boolean = false): integer; overload;
   function ExecuteDirect(const aSQL: mseString;
         ATransaction: TSQLTransaction;
         const aparams: array of variant;
         const aisutf8: boolean = false;
         const anoprepare: boolean = false): integer; overload;
   procedure GetTableNames(List : TStrings; SystemTables : Boolean = false); virtual;
   procedure GetProcedureNames(List : TStrings); virtual;
   procedure GetFieldNames(const TableName : string; List :  TStrings); virtual;
   function getinsertid(const atransaction: tsqltransaction): int64; virtual;
   function fieldtosql(const afield: tfield): string;
   function fieldtooldsql(const afield: tfield): string;
   function paramtosql(const aparam: tparam): string;
   
   property Password : string read FPassword write FPassword;
   property Transaction : TSQLTransaction read FTransaction write SetTransaction;
   property transactionwrite : tsqltransaction read ftransactionwrite 
                                                  write settransactionwrite;
   property UserName : string read FUserName write FUserName;
   property CharSet : string read FCharSet write FCharSet;
   property HostName : string Read FHostName Write FHostName;

   property Connected: boolean read getconnected write setconnected default false;
   Property Role :  String read FRole write FRole;
   property afterconnect: tmsesqlscript read fafterconnect write setafteconnect;
   property beforedisconnect: tmsesqlscript read fbeforedisconnect write setbeforedisconnect;
   property controller: tdbcontroller read fcontroller write setcontroller;
  end;

 tsqlconnection = class(tcustomsqlconnection)
  published
    property Password;
    property Transaction;
    property transactionwrite;
    property UserName;
    property CharSet;
    property HostName;
    property controller;

    property Connected;
    Property Role;
    property DatabaseName;
    property KeepConnection;
//    property LoginPrompt;
    property Params;
    property afterconnect;
    property beforedisconnect;
//    property OnLogin;
 end;
 
  TCommitRollbackAction = (caNone, caCommit, caCommitRetaining, caRollback,
    caRollbackRetaining);
  transactionoptionty = (tao_fake,tao_catcherror,tao_refreshdatasets);
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
    fonbeforestop: sqltransactioneventty;
    fonafterstop: sqltransactioneventty;
    fpendingaction: tcommitrollbackaction;
    fpendingrefresh: boolean;
    procedure setparams(const avalue: TStringList);
    function getdatabase: tcustomsqlconnection;
    procedure setdatabase1(const avalue: tcustomsqlconnection);
    function docommit(const retaining: boolean): boolean;
    procedure setpendingaction(const avalue: tcommitrollbackaction);
   protected
    fsavepointlevel: integer;
    function GetHandle : Pointer; virtual;
    Procedure SetDatabase (Value : tmdatabase); override;
    procedure disconnect(const sender: tsqlquery);
    procedure finalizetransaction; override;
    procedure doendtransaction(const aaction: tcommitrollbackaction);
    procedure dobeforestop;
    procedure doafterstop;
    procedure checkpendingaction;
   public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure refresh(aaction: tcommitrollbackaction = canone);
                 //canone -> action property
                 //closes transaction, calls refreshdatasets
    function Commit(const checksavepoint: boolean = true): boolean; virtual; //true if ok
    function CommitRetaining(const checksavepoint: boolean = true): boolean; virtual;
    procedure Rollback; virtual;
    procedure RollbackRetaining; virtual;
    procedure StartTransaction; override;
    property Handle: Pointer read GetHandle;
    procedure EndTransaction; override;
    function savepointbegin: integer;
    procedure savepointrollback(alevel: integer = -1);
                     //-1 -> toplevel
    procedure savepointrelease;
    property savepointlevel: integer read fsavepointlevel;
    property trans: tsqlhandle read ftrans;
    property pendingaction: tcommitrollbackaction read fpendingaction 
                                                      write setpendingaction;
              //will be executed on savepointlevel 0
    property pendingrefresh: boolean read fpendingrefresh 
                                           write fpendingrefresh;
   published
    property options: transactionoptionsty read foptions write foptions default [];
    property Action : TCommitRollbackAction read FAction write FAction default canone;
    property Database: tcustomsqlconnection read getdatabase write setdatabase1;
    property Params : TStringList read FParams write setparams;
    property oncommiterror: commiterroreventty read foncommiterror 
                               write foncommiterror;
    property onbeforestart: sqltransactioneventty read fonbeforestart 
                                     write fonbeforestart;
    property onafterstart: sqltransactioneventty read fonafterstart 
                                     write fonafterstart;
    property onbeforestop: sqltransactioneventty read fonbeforestop 
                                     write fonbeforestop;
    property onafterstop: sqltransactioneventty read fonafterstop 
                                     write fonafterstop;
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

 tcustomsqlstatement = class;
 
 sqlstatementeventty = procedure(const sender: tcustomsqlstatement;
                                const adatabase: tcustomsqlconnection;
                                const atransaction: tsqltransaction) of object;
 sqlstatementerroreventty = procedure(const sender: tcustomsqlstatement;
                                const adatabase: tcustomsqlconnection;
             const atransaction: tsqltransaction; const e: exception;
             var handled: boolean) of object;

 sqlstatementoptionty = (sso_utf8,sso_autocommit,sso_autocommitret,
                         sso_noprepare,
                         sso_savepoint //for tmsesqlscript
                         );
 sqlstatementoptionsty = set of sqlstatementoptionty;

 tcustomsqlstatement = class(tmsecomponent,itransactionclient,idatabaseclient)
  private
   fsql: tsqlstringlist;
   fdatabase: tcustomsqlconnection;
   ftransaction: tsqltransaction;
   fparams: tmseparams;
   fonbeforeexecute: sqlstatementeventty;
   fonafterexecute: sqlstatementeventty;
   fonerror: sqlstatementerroreventty;
   foptions: sqlstatementoptionsty;
   fterm: msechar;
   fcharescapement: boolean;
   procedure setsql(const avalue: tsqlstringlist);
   procedure setdatabase1(const avalue: tcustomsqlconnection);
   procedure setparams(const avalue: tmseparams);
   procedure settransaction1(const avalue: tsqltransaction);
   procedure setoptions(const avalue: sqlstatementoptionsty);
   //itransactionclient
   function getname: string;
   function getactive: boolean;
   procedure setactive(avalue: boolean); virtual;
   procedure settransaction(const avalue: tmdbtransaction);
   procedure settransactionwrite(const avalue: tmdbtransaction);
   procedure checkbrowsemode;
   procedure refreshtransaction;
   //idbclient
   procedure setdatabase(const avalue: tmdatabase);
   function gettransaction: tmdbtransaction;
   function getrecno: integer;
   procedure setrecno(value: integer);
   procedure disablecontrols;
   procedure enablecontrols;
   function moveby(distance: longint): longint;
  protected
   
   procedure dobeforeexecute(const adatabase: tcustomsqlconnection;
                              const atransaction: tsqltransaction);
   procedure doafterexecute(const adatabase: tcustomsqlconnection;
                             const atransaction: tsqltransaction);
   procedure doerror(const adatabase: tcustomsqlconnection;
              const atransaction: tsqltransaction; const e: exception;
              var handled: boolean);
   procedure dosqlchange(const sender: tobject); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean; overload;
//   function isutf8(const adatabase): boolean; overload;
  published
   property params : tmseparams read fparams write setparams;
   property sql: tsqlstringlist read fsql write setsql;
   property term: msechar read fterm write fterm default ';';
   property charescapement: boolean read fcharescapement 
                                      write fcharescapement default false;
   property database: tcustomsqlconnection read fdatabase write setdatabase1;
   property transaction: tsqltransaction read ftransaction write settransaction1;
                  //can be nil
   property options: sqlstatementoptionsty read foptions 
                                 write setoptions default [];
   property onbeforeexecute: sqlstatementeventty read fonbeforeexecute 
                                                     write fonbeforeexecute;
   property onafterexecute: sqlstatementeventty read fonafterexecute 
                                                     write fonafterexecute;
   property onerror: sqlstatementerroreventty read fonerror write fonerror;
 end;

 msesqlscripteventty = procedure(const sender: tmsesqlscript) of object;
   
 tmsesqlscript = class(tcustomsqlstatement)
  private
   fstatementnr: integer;
   fstatementcount: integer;
//   fstatements: msestringarty;
   fonbeforestatement: msesqlscripteventty;
   fonafterstatement: msesqlscripteventty;
  protected
  public
   procedure execute(adatabase: tcustomsqlconnection = nil;
                        atransaction: tsqltransaction = nil); overload;
   property statementnr: integer read fstatementnr; //null based
   property statementcount: integer read fstatementcount;
//   property fstatements: msestringarty read fstatements;
  published
   property onbeforestatement: msesqlscripteventty read fonbeforestatement
                                                       write fonbeforestatement;
   property onafterstatement: msesqlscripteventty read fonafterstatement
                                                       write fonafterstatement;
 end;

 tsqlstatement = class(tcustomsqlstatement)
  private
   FCursor: TSQLCursor;
   fstatementtype: tstatementtype;
   procedure setactive(avalue: boolean); override;
  protected
   procedure dosqlchange(const sender: tobject); override;
   procedure prepare;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure unprepare;
   procedure execute; overload;
   procedure execute(const aparams: array of variant); overload;
   function rowsaffected: integer;
                  //-1 if not supported
  published
   property statementtype : tstatementtype read fstatementtype 
                 write fstatementtype default stnone;
 end;
  
const
 blobidsize = sizeof(integer);
type
 iblobconnection = interface(inullinterface)
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
 
 tsqlmasterparamsdatalink = class(tmasterparamsdatalink)
  private
   fquery: tsqlquery;
   frefreshlock: integer;
//   fdelayus: integer;
   ftimer: tsimpletimer;
  protected
   procedure domasterdisable; override;
   procedure domasterchange; override;
   procedure CheckBrowseMode; override;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure checkrefresh; //makes pending delayed refresh
   procedure dorefresh(const sender: tobject);
  public
   constructor create(const aowner: tsqlquery); reintroduce;
   destructor destroy; override;
//  published
//   property delayus: integer read fdelayus write fdelayus default -1;
 end;
 
 isqlclient = interface(idatabaseclient)
  function getsqltransaction: tsqltransaction;
  procedure setsqltransaction(const avalue: tsqltransaction);
  function getsqltransactionwrite: tsqltransaction;
  procedure setsqltransactionwrite(const avalue: tsqltransaction);
  procedure unprepare;
 end;
 
 sqlquerystatety = (sqs_userapplyrecupdate,sqs_updateabort,sqs_updateerror);
 sqlquerystatesty = set of sqlquerystatety;
 
 TSQLQuery = class (tmsebufdataset,isqlclient,icursorclient)
 private
   FCursor: TSQLCursor;
   FUpdateable: boolean;
   FSQL: tsqlstringlist;
//   FSQLUpdate,FSQLInsert: tupdatesqlstringlist;
//   FSQLDelete: tsqlstringlist;
   FIsEOF: boolean;
   FLoadingFieldDefs: boolean;
   FIndexDefs: TIndexDefs;
   FUpdateMode: TUpdateMode;
   FParams: TmseParams;
   FusePrimaryKeyAsKey: Boolean;
   FSQLBuf: mseString;
   FSQLprepbuf: mseString;
   FFromPart: mseString;
   FWhereStartPos: integer;
   FWhereStopPos: integer;
   FParseSQL: boolean;
   fstatementtype: tstatementtype;
   FMasterLink: TsqlMasterParamsDatalink;
   fapplyqueries: array[tupdatekind] of tsqlquery;
   fapplysql: array[tupdatekind] of tsqlstringlist;
//   FUpdateQry,FDeleteQry,FInsertQry: TSQLQuery;
   fupdaterowsaffected: integer;
   fblobintf: iblobconnection;   
   fbeforeexecute: tmsesqlscript;
   faftercursorclose: tmsesqlscript;
   fmasterdelayus: integer;
   procedure FreeFldBuffers;
   function GetIndexDefs : TIndexDefs;
//   function GetStatementType : TStatementType;
   procedure SetIndexDefs(AValue : TIndexDefs);
   procedure SetReadOnly(AValue : Boolean);
   procedure SetParseSQL(AValue : Boolean);
   procedure setstatementtype(const avalue: tstatementtype);
   procedure SetUsePrimaryKeyAsKey(AValue : Boolean);
   procedure SetUpdateMode(AValue : TUpdateMode);
   procedure OnChangeSQL(const Sender : TObject);
   procedure OnChangeModifySQL(const Sender : TObject);
   procedure Execute;
   Procedure SQLParser(var ASQL: msestring);
   procedure ApplyFilter;
   Function AddFilter(SQLstr : string) : string;
   function getdatabase1: tcustomsqlconnection;
   procedure setdatabase1(const avalue: tcustomsqlconnection);
   procedure setparams(const avalue: TmseParams);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure setFSQL(const avalue: tsqlstringlist);
   procedure setFSQLUpdate(const avalue: tsqlstringlist);
   procedure setFSQLInsert(const avalue: tsqlstringlist);
   procedure setFSQLDelete(const avalue: tsqlstringlist);
   procedure setbeforeexecute(const avalue: tmsesqlscript);
   procedure setaftercursorclose(const avalue: tmsesqlscript);
   function getsqltransaction: tsqltransaction;
   procedure setsqltransaction(const avalue: tsqltransaction);
   function getsqltransactionwrite: tsqltransaction;
   procedure setsqltransactionwrite(const avalue: tsqltransaction);
   procedure resetparsing;
   procedure dorefresh;
//   procedure setmasterlink(const avalue: tsqlmasterparamsdatalink);
//   procedure setmasterdelayus(const avalue: integer);
   procedure settablename(const avalue: string);
  protected
   fmstate: sqlquerystatesty;
   FTableName: string;
   FReadOnly: boolean;
   fprimarykeyfield: tfield;                   
   futf8: boolean;
   foptionsmasterlink: optionsmasterlinkty;
   procedure settransactionwrite(const avalue: tmdbtransaction); override;
   procedure checkpendingupdates; virtual;
   procedure notification(acomponent: tcomponent; operation: toperation); override;   
   // abstract & virtual methods of TBufDataset
   function Fetch : boolean; override;
   function getblobdatasize: integer; override;
   function getnumboolean: boolean; virtual;
   function getfloatdate: boolean; virtual;
   function getint64currency: boolean; virtual;
   function blobscached: boolean; override;
   function loadfield(const afieldno: integer; const afieldtype: tfieldtype;
           const buffer: pointer; var bufsize: integer): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
   // abstract & virtual methods of TDataset
//   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   function isutf8: boolean; override;
   procedure UpdateIndexDefs; override;
   procedure SetDatabase(const Value: tmdatabase); override;
   Procedure SetTransaction(const Value : tmdbtransaction); override;
   procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
   procedure InternalClose; override;
   procedure InternalInitFieldDefs; override;
   procedure connect(const aexecute: boolean);
   procedure freemodifyqueries;
   procedure freequery;
   procedure disconnect{(const aexecute: boolean)};
   procedure InternalOpen; override;
   procedure internalrefresh; override;
   procedure refreshtransaction; override;
   procedure dobeforeedit; override;
   procedure dobeforeinsert; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   
   function  GetCanModify: Boolean; override;
   procedure updatewherepart(var sql_where : string; const afield: tfield);
   Procedure internalApplyRecUpdate(UpdateKind : TUpdateKind);
   procedure dobeforeapplyupdate; override;
   procedure ApplyRecUpdate(UpdateKind : TUpdateKind); override;
   Function IsPrepared: Boolean; virtual;
   Procedure SetActive (Value : Boolean); override;
   procedure SetFiltered(Value: Boolean); override;
   procedure SetFilterText(const Value: string); override;
   Function GetDataSource : TDatasource; override;
   Procedure SetDataSource(AValue : TDatasource);    
   //icursorclient
   function stringmemo: boolean; virtual;
        //memo fields are text(0) fields
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure applyupdate(const cancelonerror: boolean); override;
    procedure applyupdates(const maxerrors: integer;
                   const cancelonerror: boolean); override;
    function refreshrecquery(const update: boolean): string;
    procedure checktablename;
    function updaterecquery{(const refreshfieldvalues: boolean)} : string;
    function insertrecquery{(const refreshfieldvalues: boolean)} : string;
    function deleterecquery : string;
    function writetransaction: tsqltransaction;
                   //self.transaction if self.transactionwrite = nil
    procedure Prepare; virtual;
    procedure UnPrepare; virtual;
    procedure ExecSQL; virtual;
    function executedirect(const asql: string): integer; 
              //uses writetransaction of tsqlquery

    function rowsreturned: integer; //-1 if not supported
    function rowsaffected: integer; //-1 if not supported
    property updaterowsaffected: integer read fupdaterowsaffected;
    procedure SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string); virtual;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    property Prepared : boolean read IsPrepared;
    property connected: boolean read getconnected write setconnected;
              //sum of rowsaffected of insert, update and delete query,
              //reset by close, applyupdate and applyupdates, -1 if not supported.
  published
    property ReadOnly : Boolean read FReadOnly write SetReadOnly default false;
    property ParseSQL : Boolean read FParseSQL write SetParseSQL default true;
    property params : tmseparams read fparams write setparams;
                       //before SQL
    property SQL : tsqlstringlist read FSQL write setFSQL;
    property SQLUpdate : tsqlstringlist read Fapplysql[ukmodify] 
                                                         write setFSQLUpdate;
    property SQLInsert : tsqlstringlist read Fapplysql[ukinsert] 
                                                         write setFSQLInsert;
    property SQLDelete : tsqlstringlist read Fapplysql[ukdelete]
                                                         write setFSQLDelete;
    property beforeexecute: tmsesqlscript read fbeforeexecute write setbeforeexecute;
    property aftercursorclose: tmsesqlscript read faftercursorclose 
                                                 write setaftercursorclose;
    property IndexDefs : TIndexDefs read GetIndexDefs;
    property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode;
    property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey;
    property tablename: string read ftablename write settablename;
    property StatementType : TStatementType read fstatementtype 
                           write setstatementtype default stnone;
    Property DataSource : TDatasource Read GetDataSource Write SetDatasource;
    property masterdelayus: integer read fmasterdelayus
                                write fmasterdelayus default -1;
    property optionsmasterlink: optionsmasterlinkty read foptionsmasterlink 
                                      write foptionsmasterlink default [];
 //   property masterlink: tsqlmasterparamsdatalink read fmasterlink 
 //                     write setmasterlink;
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
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property AutoCalcFields;
//    property Database;

    property Transaction: tsqltransaction read getsqltransaction write setsqltransaction;
    property transactionwrite: tsqltransaction read getsqltransactionwrite
                                    write setsqltransactionwrite;
  end;

procedure updateparams(const aparams: tmseparams; const autf8: boolean);
procedure doexecute(const aparams: tmseparams; const atransaction: tmdbtransaction;
                    const acursor: tsqlcursor; adatabase: tmdatabase;
                    const autf8: boolean);
procedure checksqlconnection(const aname: ansistring; const avalue: tmdatabase);
procedure dosetsqldatabase(const sender: isqlclient; const avalue: tmdatabase;
                 var acursor: tsqlcursor; var dest: tmdatabase);
procedure querytoupdateparams(const source: tsqlquery; const dest: tparams);

function splitsql(const asql: msestring; const term: msechar = ';';
                  const charescapement: boolean = false): msestringarty;

//function splitsqlstatements(const asqltext: msestring): msestringarty;

implementation
uses 
 dbconst,strutils,msereal,msestream,msebits,msefileutils,mseformatstr,typinfo;
type
 tdataset1 = class(tdataset);
 tmdatabase1 = class(tmdatabase);
{
  TDataSetcracker = class(TComponent)
  Private
    FOpenAfterRead : boolean;
    FActiveRecord: Longint;
    FAfterCancel: TDataSetNotifyEvent;
    FAfterClose: TDataSetNotifyEvent;
    FAfterDelete: TDataSetNotifyEvent;
    FAfterEdit: TDataSetNotifyEvent;
    FAfterInsert: TDataSetNotifyEvent;
    FAfterOpen: TDataSetNotifyEvent;
    FAfterPost: TDataSetNotifyEvent;
    FAfterRefresh: TDataSetNotifyEvent;
    FAfterScroll: TDataSetNotifyEvent;
    FAutoCalcFields: Boolean;
    FBOF: Boolean;
    FBeforeCancel: TDataSetNotifyEvent;
    FBeforeClose: TDataSetNotifyEvent;
    FBeforeDelete: TDataSetNotifyEvent;
    FBeforeEdit: TDataSetNotifyEvent;
    FBeforeInsert: TDataSetNotifyEvent;
    FBeforeOpen: TDataSetNotifyEvent;
    FBeforePost: TDataSetNotifyEvent;
    FBeforeRefresh: TDataSetNotifyEvent;
    FBeforeScroll: TDataSetNotifyEvent;
    FBlobFieldCount: Longint;
    FBookmarkSize: Longint;
    FBuffers : TBufferArray;
    FBufferCount: Longint;
    FCalcBuffer: PChar;
    FCalcFieldsSize: Longint;
    FConstraints: TCheckConstraints;
    FDisableControlsCount : Integer;
    FDisableControlsState : TDatasetState;
  end;  
}  
procedure updateparams(const aparams: tmseparams; const autf8: boolean);
var
 int1: integer;
begin
 if aparams <> nil then begin
  aparams.isutf8:= autf8;
  for int1:= 0 to aparams.count - 1 do begin
   with aparams[int1] do begin
    if not isnull and (datatype in [ftFloat,ftcurrency,ftDate,ftTime,ftDateTime]) and
                               isemptyreal(asfloat) then begin
     clear;
    end;
   end;
  end;
 end;
end;

procedure doexecute(const aparams: tmseparams; const atransaction: tmdbtransaction;
                    const acursor: tsqlcursor; adatabase: tmdatabase;
                    const autf8: boolean);
begin
 updateparams(aparams,autf8);
 acursor.ftrans:= tsqltransaction(atransaction).handle;
 tcustomsqlconnection(adatabase).execute(acursor,tsqltransaction(atransaction),
                         aParams,autf8);
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
  if (avalue <> nil) then begin
   if (sender.getsqltransaction = nil) then begin
    sender.setsqltransaction(tcustomsqlconnection(avalue).transaction);
   end;
   if (sender.getsqltransactionwrite = nil) then begin
    sender.setsqltransactionwrite(tcustomsqlconnection(avalue).transactionwrite);
   end;
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
function SkipComments(var p: PmseChar) : boolean;
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
(*
function splitsqlstatements(const asqltext: msestring): msestringarty;
var
 count: integer;
 po1,po2: pmsechar;
 mstr1: msestring;
begin
 result:= nil;
 count:= 0;
 po1:= pmsechar(asqltext);
 po2:= po1;
 while po1^ <> #0 do begin
  case po1^ of
   '''': begin // single quote delimited string
    inc(po1);
    while (po1^ <> #0) and (po1 <> '''') do begin
     if po1^ = '\' then begin
      inc(po1,2) // make sure we handle \' and \\ correct
     end
     else begin
      inc(ppo1);
     end;
    end;
    if po1^ = '''' then begin
     inc(po1);
    end; // skip final '
   end;
   '"': begin // double quote delimited string
    inc(po1);
    while (po1^ <> #0) and (po1 <> '"') do begin
     if po1^ = '\' then begin
      inc(po1,2) // make sure we handle \' and \\ correct
     end
     else begin
      inc(po1);
     end;
    end;
    if po1^ = '"' then begin
     inc(po1);
    end; // skip final "
   end;
   '-': begin// possible start of -- comment
    inc(po1);
    if po1^ = '-' then begin// -- comment
     repeat // skip until at end of line
      inc(po1);
     until po1^ = #0 or po1^ = #10;
    end;
   end;
   '/': begin // possible start of /* */ comment
    inc(po1);
    if po1^ = '*' then begin // /* */ comment
     repeat
      inc(po1);
      if po1 = '*' then begin// possible end of comment
       inc(po1);
       if po1^ = '/' then begin 
        break;  // end of comment
       end;
      end;
     until po1^ = #0;
     if po1^ = '/' then begin 
      inc(p);             // skip final /
     end;
    end;
   end;
   ';': begin
    setlength(str1,po1-po2);
    move(po2^,str1[1],length(str1)*sizeof(msechar));
    po2:= po1;
    additem(result,str1,count);
   end;
   else begin
    inc(po1);
   end;
  end; {case}
 end;
 setlength(result,count);
end;
*)

function splitsql(const asql: msestring;
                  const term: msechar = ';';
                  const charescapement: boolean = false): msestringarty;
var
 po1,po2: pmsechar;
 
 procedure addstatement;
 begin
  setlength(result,high(result)+2);
  setlength(result[high(result)],po1-po2);
  move(po2^,result[high(result)][1],length(result[high(result)])*sizeof(msechar));
 end;
 
 procedure checkescape(var apo: pmsechar);
 begin
  if charescapement and (apo^ = '\') then begin
   inc(apo);
   if (apo^ <> #0) then begin
    inc(apo);
   end;
  end
  else begin
   inc(apo);
  end;
 end;

var
 po3: pmsechar;
  
begin
 result:= nil;
 po1:= pmsechar(asql);
 po2:= po1;
 while po1^ <> #0 do begin          
  if po1^ = term then begin
   po1^:= ';';
   inc(po1);
   addstatement;
   (po1-1)^:= term;
   po2:= po1;
  end
  else begin
   case po1^ of
    '''': begin
     inc(po1);
     while (po1^ <> '''') and (po1^ <> #0) do begin
      checkescape(po1);
     end;
     if po1^ = '''' then begin
      inc(po1);
     end;
    end;
    '"': begin
     inc(po1);
     while (po1^ <> '"') and (po1^ <> #0) do begin
      checkescape(po1);
     end;
     if po1^ = '"' then begin
      inc(po1);
     end;
    end;
    '-': begin// possible start of -- comment
     inc(po1);
     if po1^ = '-' then begin // -- comment
      repeat                  // skip until at end of line
       inc(po1);
      until (po1^ = #0) or (po1^ = #10);
     end;
    end;
    '/': begin // possible start of /* */ comment
     inc(po1);
     if po1^ = '*' then begin // /* */ comment
      repeat
       inc(po1);
       if po1^ = '*' then begin// possible end of comment
        inc(po1);
        if po1^ = '/' then begin 
         break;  // end of comment
        end;
       end;
      until po1^ = #0;
      if po1^ = '/' then begin 
       inc(po1);             // skip final /
      end;
     end;
    end;
    else begin 
     inc(po1);
    end;
   end;           //case
  end;
 end;
 {
 if po1 <> po2 then begin //no terminating ';'
  po3:= po1;
  while po3 > po2 do begin //remove trailing space //////what about newline?
   dec(po3);
   if po3^ <> ' ' then begin
    break;
   end;
  end;
  if po3 <> po2 then begin //not empty
   addstatement;
  end;
 end;
 }
end;

procedure querytoupdateparams(const source: tsqlquery; const dest: tparams);
var
 x: integer;
 param1,param2: tparam;
 fld: tfield;
begin
 for x := 0 to dest.Count-1 do begin
  param1:= dest[x];
  with param1 do begin
   if leftstr(name,4)='OLD_' then begin
    Fld:= source.FieldByName(copy(name,5,length(name)-4));
    source.oldfieldtoparam(fld,param1);
//     AssignFieldValue(Fld,Fld.OldValue);
   end
   else begin
    fld:= source.findfield(name);
    if fld = nil then begin     //search for param
     param2:= source.params.findparam(name);
     if param2 = nil then begin
      source.fieldbyname(name); //raise exception
     end
     else begin
      value:= param2.value;
     end;
    end
    else begin             //use field
     source.fieldtoparam(fld,param1);
    end;
   end;
  end;
 end;
end;
   
   { tsqlstringlist }

constructor tsqlstringlist.create;
begin
 fmacros:= tmacroproperty.create(self);
 inherited;
end;

destructor tsqlstringlist.destroy;
begin
 inherited;
 fmacros.free;
end;

function tsqlstringlist.gettext: msestring;
var
 int1,int2: integer;
 po1: pmsestring;
 po2: pmsechar;
 mstr1: msestring;
 ar1: macroinfoarty;
 po3: pdoublemsestringty;
begin
 result:= '';
 if count > 0 then begin
  normalizering;
  int2:= 0;
  po1:= pointer(fdatapo);
  for int1:= 0 to count - 1 do begin
   inc(int2,length(po1[int1]));
  end;
  mstr1:= lineend;
  setlength(result,int2+(count-1)*length(mstr1));
  if result <> '' then begin
   int2:= 0;
   po2:= pmsechar(result);
   for int1:= 0 to count - 2 do begin
    move(po1^[1],po2^,length(po1^)*sizeof(msechar));
    inc(po2,length(po1^));
    move(mstr1[1],po2^,length(mstr1)*sizeof(msechar));
    inc(po2,length(mstr1));
    inc(po1);
   end;
   move(po1^[1],po2^,length(po1^)*sizeof(msechar)); //last line
  end;
  if fmacros.count <> 0 then begin
   setlength(ar1,fmacros.count);
   po3:= fmacros.datapo;
   for int1:= 0 to high(ar1) do begin
    with ar1[int1] do begin
     name:= po3^.a;
     value:= po3^.b;
    end;
    inc(po3);
   end;    
   result:= expandmacros(result,ar1,fmacros.foptions);
  end;
 end;
end;

procedure tsqlstringlist.settext(const avalue: msestring);
begin
 asarray:= breaklines(avalue);
end;

procedure tsqlstringlist.readstrings(reader: treader);
var
 ar1: stringarty;
 int1: integer;
 bo1: boolean;
begin
 reader.readlistbegin;
 while not reader.endoflist do begin
  additem(ar1,reader.readstring);
 end;
 reader.readlistend;
 bo1:= true;
 for int1:= 0 to high(ar1) do begin
  if not checkutf8(ar1[int1]) then begin
   bo1:= false;
   break;
  end;
 end;
 clear;
 if bo1 then begin
  for int1:= 0 to high(ar1) do begin
   add(utf8tostring(ar1[int1]));
  end;
 end
 else begin
  add(ar1[int1]);
 end;
end;

procedure tsqlstringlist.writestrings(writer: twriter);
begin
 //dummy
end;

procedure tsqlstringlist.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Strings',@readstrings,@writestrings,false);
end;

procedure tsqlstringlist.setmacros(const avalue: tmacroproperty);
begin
 fmacros.assign(avalue);
end;

{ tdbcontroller }

constructor tdbcontroller.create(const aowner: tmdatabase; const aintf: idbcontroller);
begin
 fintf:= aintf;
 inherited create(aowner);
end;

procedure tdbcontroller.setowneractive(const avalue: boolean);
var
 bo1: boolean;
begin
 fintf.setinheritedconnected(avalue);
 {
 if avalue then begin
  with tmdatabase(fowner) do begin
   if checkcanevent(fowner,tmethod(fonbeforeconnect)) then begin
    fonbeforeconnect(tmdatabase(fowner));
   end;
   try
    fintf.setinheritedconnected(avalue);
   except
    on e: exception do begin
     if checkcanevent(fowner,tmethod(fonconnecterror)) then begin
      bo1:= false;
      fonconnecterror(tmdatabase(fowner),e,bo1);
      if not bo1 then begin
       raise;
      end;
     end;
    end;
   end;
   if checkcanevent(fowner,tmethod(fonafterconnect)) then begin
    fonafterconnect(tmdatabase(fowner));
   end;
  end;
 end
 else begin
  fintf.setinheritedconnected(avalue);
//  tmdatabase(fowner).connected:= avalue;
 end;
 }
end;

function tdbcontroller.getdatabasename: filenamety;
begin
 result:= fdatabasename;
end;

procedure tdbcontroller.setdatabasename(const avalue: filenamety);
var
 str1: filenamety;
begin
 str1:= trim(avalue);
 if (str1 <> '') and (str1[1] = '''') and 
                    (str1[length(str1)] = '''') then begin
  fdatabasename:= str1;
  tmdatabase(fowner).databasename:= copy(str1,2,length(str1)-2);
 end
 else begin
  fdatabasename:= tomsefilepath(str1);
  tmdatabase(fowner).databasename:= 
                   tosysfilepath(filepath(str1,fk_default,true));
 end;
end;

procedure tdbcontroller.setoptions(const avalue: databaseoptionsty);
const
 mask: databaseoptionsty = [dbo_utf8,dbo_noutf8];
begin
 if foptions <> avalue then begin
//  tmdatabase1(fowner).checkdisconnected;
  foptions:= databaseoptionsty(setsinglebit(longword(avalue),
                longword(foptions),longword(mask)));
 end;
end;

{ tcustomsqlconnection }

constructor tcustomsqlconnection.create(aowner: tcomponent);
begin
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
 inherited;
end;

destructor tcustomsqlconnection.destroy;
begin
 inherited;
 fcontroller.free;
end;

function tcustomsqlconnection.connectionmessage(atext: pchar): msestring;
begin
 if dbo_utf8message in fcontroller.foptions then begin
  result:= utf8tostring(atext);
 end
 else begin
  result:= atext;
 end;
end;

procedure tcustomsqlconnection.setinheritedconnected(const avalue: boolean);
begin
 connected:= avalue;
end;

function tcustomsqlconnection.readsequence(const sequencename: string): string;
begin
 result:= ''; //dummy
end;

function tcustomsqlconnection.sequencecurrvalue(const sequencename: string): string;
begin
 result:= ''; //dummy
end;

function tcustomsqlconnection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= ''; //dummy
end;

procedure tcustomsqlconnection.updateutf8(var autf8: boolean);
begin
 if dbo_utf8 in fcontroller.options then begin
  autf8:= true;
 end;
 if dbo_noutf8 in fcontroller.options then begin
  autf8:= false;
 end;
end;

function tcustomsqlconnection.isutf8: boolean;
begin
 result:= false;
 updateutf8(result);
end;

function tcustomsqlconnection.StrToStatementType(s: msestring) : TStatementType;

var T : TStatementType;

begin
 result:= stnone;
  S:= mseLowercase(s);
  For t:= stselect to strollback do
    if (S=StatementTokens[t]) then
      Exit(t);
end;

procedure tcustomsqlconnection.settransaction(const avalue : tsqltransaction);
begin
 if ftransaction <> avalue then begin
  if assigned(ftransaction) and ftransaction.active then begin
   databaseerror(serrasstransaction);
  end;
  if assigned(avalue) then begin
   avalue.database:= self;
  end;
  ftransaction:= avalue;
 end;
end;

procedure tcustomsqlconnection.settransactionwrite(const avalue : tsqltransaction);
begin
 if ftransactionwrite <> avalue then begin
  if assigned(ftransactionwrite) and ftransactionwrite.active then begin
   databaseerror(serrasstransaction);
  end;
  if assigned(avalue) then begin
   avalue.database:= self;
  end;
  ftransactionwrite:= avalue;
 end;
end;


procedure tcustomsqlconnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                  const aTableName : string);

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
 //dummy
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

function tcustomsqlconnection.executedirect(const asql: msestring;
                          const aisutf8: boolean = false): integer;
begin
 result:= executedirect(asql,ftransaction,[],aisutf8);
end;

function tcustomsqlconnection.internalExecuteDirect(const aSQL: mseString;
          ATransaction: TSQLTransaction;
          const aparams: tmseparams; aparamvars: array of variant;
          aisutf8: boolean; const noprepare: boolean): integer;
var 
 Cursor: TSQLCursor;
 params1: tmseparams;
 bo1: boolean; 
 int1: integer;
 str1: ansistring;
begin
 if atransaction = nil then begin
  atransaction:= ftransaction;
 end;
 bo1:= (aparams = nil) and (high(aparamvars) >= 0);
 if bo1 then begin
  params1:= tmseparams.create;
  params1.parsesql(asql,true);
  for int1:= 0 to high(aparamvars) do begin
   params1[int1].value:= aparamvars[int1];
  end;
 end
 else begin
  params1:= aparams;
 end;
 try
  if not assigned(ATransaction) then begin
   DatabaseError(SErrTransactionnSet);
  end;
  connected:= true;
  if not ATransaction.Active then begin
   ATransaction.StartTransaction;
  end;
  try
   Cursor:= AllocateCursorHandle(nil,name);
   cursor.ftrans:= atransaction.handle;
   if trimright(asql) = '' then begin
    DatabaseError(SErrNoStatement);
   end;   
   Cursor.FStatementType := stNone;
   if not noprepare then begin
    PrepareStatement(cursor,ATransaction,aSQL,params1);
   end;
   cursor.ftrans:= atransaction.handle;
   updateutf8(aisutf8);
   try
    if noprepare then begin
     executeunprepared(cursor,atransaction,params1,asql,aisutf8);
    end
    else begin
     execute(cursor,atransaction,params1,aisutf8);
    end;
    result:= cursor.frowsaffected;
   finally
    UnPrepareStatement(Cursor);
   end;
  finally;
    DeAllocateCursorHandle(Cursor);
  end;
 finally
  if bo1 then begin
   params1.free;
  end;
 end;
end;

function tcustomsqlconnection.ExecuteDirect(const aSQL: mseString;
          ATransaction: TSQLTransaction;
          const aparams: tmseparams = nil;
          const aisutf8: boolean = false;
          const anoprepare: boolean = false): integer;
begin
 result:= internalexecutedirect(asql,atransaction,aparams,[],aisutf8,
              anoprepare and not (sco_nounprepared in fconnoptions));
end;

function tcustomsqlconnection.ExecuteDirect(const aSQL: mseString;
          ATransaction: TSQLTransaction;
          const aparams: array of variant;
          const aisutf8: boolean = false;
          const anoprepare: boolean = false): integer;
begin
 result:= internalexecutedirect(asql,atransaction,nil,aparams,aisutf8,
               anoprepare and not (sco_nounprepared in fconnoptions));
end;

procedure tcustomsqlconnection.GetDBInfo(const SchemaType : TSchemaType; 
            const SchemaObjectName, ReturnField : string; List: TStrings);

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

function tcustomsqlconnection.GetAsSQLText(const Field: TField): string;
begin
 result:= msedb.fieldtosql(field);
end;

function tcustomsqlconnection.GetAsSQLText(const Param: TParam): string;
begin
 result:= msedb.paramtosql(param);
end;


function tcustomsqlconnection.GetHandle: pointer;
begin
  Result := nil;
end;

procedure tcustomsqlconnection.Execute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
               const AParams : TmseParams; const autf8: boolean);
begin
 if aparams <> nil then begin
  aparams.updatevalues;
 end;
 beforeaction;
 try
  internalexecute(cursor,atransaction,aparams,autf8);
 finally
  afteraction;
 end;
end;

procedure tcustomsqlconnection.internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string);
begin
 raise edatabaseerror.create(name+': executeunprepared not supported.');
end;

procedure tcustomsqlconnection.Executeunprepared(const cursor: TSQLCursor;
                               const atransaction: tsqltransaction;
                               const AParams : TmseParams;
                               const asql: msestring; const autf8: boolean);
var
 mstr1: msestring;
 str1: ansistring;
begin
 if aparams <> nil then begin
  aparams.updatevalues;
 end;
 beforeaction;
 try
  if (aparams <> nil) and (aparams.count > 0) then begin
   mstr1:= aparams.expandvalues(asql);
  end
  else begin
   mstr1:= asql;
  end;
  if autf8 then begin
   str1:= stringtoutf8(mstr1);
  end
  else begin
   str1:= mstr1;
  end;
  internalexecuteunprepared(cursor,atransaction,str1);
 finally
  afteraction;
 end;
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
 setlength(activeds,length(datasets));
 for int1:= 0 to high(activeds) do begin
  with datasets[int1] do begin
   if getactive then begin
    activeds[int1]:= datasets[int1].getrecno;
    setactive(false);
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
    setactive(true);
    disablecontrols;
    if activeds[int1] >= 0 then begin
     try
      moveby(maxint);
      setrecno(activeds[int1]);
     except
     end;
    end;
    enablecontrols;
   end;
  end;
 end;
end;
{
function tcustomsqlconnection.getconnected: boolean;
begin
 result:= inherited connected;
end;
}
procedure tcustomsqlconnection.doafterinternalconnect;
begin
 inherited;
 if fafterconnect <> nil then begin
  fafterconnect.execute(self);
 end;
end;

procedure tcustomsqlconnection.dobeforeinternaldisconnect;
var
 int1: integer;
begin
 if fbeforedisconnect <> nil then begin
  fbeforedisconnect.execute(self);
 end;
 for int1:= high(datasets) downto 0 do begin
  with datasets[int1] do begin
   if (gettransaction = nil) or (gettransaction.active) then begin
    setactive(false); //not disconnected
   end;
  end;
 end;
 {
 for int1:= datasetcount - 1 downto 0 do begin
  with tsqlquery(datasets[int1]) do begin
   if (transaction = nil) or (transaction.active) then begin
    close; //not disconnected
   end;
  end;
 end;
 }
end;
{
procedure tcustomsqlconnection.setconnected(const avalue: boolean);
var
 int1: integer;
 bo1: boolean;
begin
 if avalue <> fconnected then begin
  if avalue then begin
   if csreading in componentstate then begin
    fopenafterread:= true;
    exit;
   end
   else begin
    if assigned(onbeforeconnect) then begin
     onbeforeconnect(self);
    end;
    try
     dointernalconnect;
     doafterinternalconnect;
     if assigned(onafterconnect) then begin
       onafterconnect(self);
     end;
    except
     on e: exception do begin
      if assigned(onconnecterror) then begin
       bo1:= false;
       onconnecterror(self,e,bo1);
       if not bo1 then begin
        raise;
       end
       else begin
        if not connected then begin
         abort;
        end;
       end;
      end
      else begin
       raise;
      end;
     end;
    end;
   end;
  end
  else begin
   if assigned(onbeforedisconnect) then begin
    onbeforedisconnect(self);
   end;
   dobeforeinternaldisconnect;
   for int1:= datasetcount - 1 downto 0 do begin
    with tsqlquery(datasets[int1]) do begin
     if (transaction = nil) or (transaction.active) then begin
      close; //not disconnected
     end;
    end;
   end;
   closetransactions;
   dointernaldisconnect;
   if csloading in componentstate then begin
    fopenafterread := false;
   end;
  end;
  fconnected:= avalue;
 end;
end;
}
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
  {
  int1:= finditem(pointerarty(fdatasets1),acomponent);
  if int1 >= 0 then begin
   fdatasets1[int1]:= nil;
  end;
  }
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

procedure tcustomsqlconnection.updateprimarykeyfield(const afield: tfield;
                      const atransaction: tsqltransaction);
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

function tcustomsqlconnection.getfloatdate: boolean;
begin
 result:= false;
end;

function tcustomsqlconnection.getint64currency: boolean;
begin
 result:= false;
end;

function tcustomsqlconnection.getinsertid(const atransaction: tsqltransaction): int64;
begin
 databaseerror('Connection has no insert ID''s.');
 result:= 0; //compiler warning
end;
{
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
}
procedure tcustomsqlconnection.CommitRetaining(trans: TSQLHandle);
begin
 internalcommitretaining(trans);
 {
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
 }
end;

procedure tcustomsqlconnection.RollBackRetaining(trans: TSQLHandle);
begin
 internalrollbackretaining(trans);
{
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
}
end;

procedure tcustomsqlconnection.finalizetransaction(const atransaction: tsqlhandle);
begin
 //dummy
end;

function tcustomsqlconnection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
begin
 raise edatabaseerror.create(name+': fetchblob not supported.');
 result:= ''; //compiler warning
end;

function tcustomsqlconnection.todbstring(const avalue: msestring): string;
begin
 if isutf8 then begin
  result:= stringtoutf8(avalue);
 end
 else begin
  result:= avalue;
 end;
end;

function tcustomsqlconnection.identquotechar: ansistring;
begin
 result:= '"';
end;

procedure tcustomsqlconnection.beginupdate;
begin
 //dummy
end;

procedure tcustomsqlconnection.endupdate;
begin
 //dummy
end;

function tcustomsqlconnection.fieldtosql(const afield: tfield): string;
begin
 result:= getassqltext(afield);
end;

function tcustomsqlconnection.fieldtooldsql(const afield: tfield): string;
var
 statebefore: tdatasetstate;
begin
 statebefore:= afield.dataset.state;
 tdataset1(afield.dataset).settempstate(dsoldvalue);
 result:= fieldtosql(afield);
 tdataset1(afield.dataset).restorestate(statebefore);
end;

function tcustomsqlconnection.paramtosql(const aparam: tparam): string;
begin
 result:= getassqltext(aparam);
end;

procedure tcustomsqlconnection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
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
 inherited Destroy;
 FreeAndNil(FParams);
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
 if (int1 <> fstartcount) or not db.connected then begin
  exit;
 end;
 if not assigned(FTrans) then begin
  FTrans:= Db.AllocateTransactionHandle;
 end;
 if (tao_fake in foptions) or 
                 Db.StartdbTransaction(FTrans,FParams) then begin
  OpenTrans;
 end;
 if checkcanevent(self,tmethod(fonafterstart)) then begin
  fonafterstart(self);
 end;
end;

procedure TSQLTransaction.doendtransaction(
                         const aaction: tcommitrollbackaction);
begin
 case aaction of
  caCommit: commit;
  caCommitRetaining: commitretaining;
  caRollbackRetaining: rollbackretaining;
  else rollback;        //canone,caRollback
 end;
end;

procedure TSQLTransaction.EndTransaction;

begin
 doendtransaction(faction);
end;

procedure tsqltransaction.refresh(aaction: tcommitrollbackaction = canone);
                 //canone -> action property
                 //closes transaction, calls refreshdatasets
var
 int1: integer;
begin
 int1:= bigint;
 while true do begin
  if int1 > high(fdatasets) then begin
   int1:= high(fdatasets);
  end;
  if int1 < 0 then begin
   break;
  end;
  if fdatasets[int1].getactive then begin
   fdatasets[int1].checkbrowsemode;
  end;
  dec(int1);
 end;
 int1:= bigint;
 while true do begin
  if int1 > high(fwritedatasets) then begin
   int1:= high(fwritedatasets);
  end;
  if int1 < 0 then begin
   break;
  end;
  if fwritedatasets[int1].getactive then begin
   fwritedatasets[int1].checkbrowsemode;
  end;
  dec(int1);
 end;
 if aaction = canone then begin
  aaction:= action;
 end;
// if aaction in [cacommit,cacommitretaining] then begin
//  aaction:= cacommitretaining;
// end
// else begin
//  aaction:= carollbackretaining;
// end;
 try
//  inc(fcloselock);
//  try
   begintrackactivestate;
   try
    doendtransaction(aaction);
//  finally
//   dec(fcloselock);
//  end;
    if not active then begin
     starttransaction;
     int1:= bigint;
     while true do begin
      if int1 > high(fdatasetsactive) then begin
       int1:= high(fdatasetsactive);
      end;
      if int1 < 0 then begin
       break;
      end;
      if fdatasetsactive[int1] then begin
       fdatasets[int1].setactive(true);
      end;
      dec(int1);
     end;
     int1:= bigint;
     while true do begin
      if int1 > high(fwritedatasetsactive) then begin
       int1:= high(fwritedatasetsactive);
      end;
      if int1 < 0 then begin
       break;
      end;
      if fwritedatasetsactive[int1] then begin
       fwritedatasets[int1].setactive(true);
      end;
      dec(int1);
     end;     
    end
    else begin
     if (tao_refreshdatasets in foptions) or (aaction <> cacommit) then begin
      refreshdatasets;
     end;
    end;
   finally
    endtrackactivestate;
   end;
 except
  closedatasets;
  raise;
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
  end
  else begin
   if //(fcloselock = 0) and //refresh will not be performed later
       ((tao_refreshdatasets in foptions) {or 
      (sco_emulateretaining in 
              tcustomsqlconnection(database).connoptions)} ) then begin
              //no refresh for emulateretaining 2009-06-16 mse
    refreshdatasets(true,true);
   end;
  end;
 end;
 
var
 bo1: boolean;
begin
 result:= false;
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
 fsavepointlevel:= 0;
 dofinish;
 result:= true;
end;

function TSQLTransaction.Commit(const checksavepoint: boolean = true): boolean;
var
 bo1: boolean;
begin
 result:= true;
 if active then begin
  if checksavepoint and (fsavepointlevel > 0) then begin
   pendingaction:= cacommit;
   exit;
  end;
  dobeforestop;
  if checkcanevent(self,tmethod(fonbeforecommit)) then begin
   fonbeforecommit(self);
  end;
  result:= docommit(false);
  if result and checkcanevent(self,tmethod(fonaftercommit)) then begin
   fonaftercommit(self);
  end;
  doafterstop;
 end;
end;

function TSQLTransaction.CommitRetaining(
                     const checksavepoint: boolean = true): boolean;
begin
 result:= true;
 if active then begin
  if checksavepoint and (fsavepointlevel > 0) then begin
   pendingaction:= cacommitretaining;
   exit;
  end;
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
  dobeforestop;
  if checkcanevent(self,tmethod(fonbeforerollback)) then begin
   fonbeforerollback(self);
  end;
  closedatasets;
  try
   if not (tao_fake in foptions) then begin
    tcustomsqlconnection(database).RollBack(FTrans);
   end;
  finally
   fsavepointlevel:= 0;
   CloseTrans;
   if checkcanevent(self,tmethod(fonafterrollback)) then begin
    fonafterrollback(self);
   end;
   doafterstop;
  end;
 end;
end;

procedure TSQLTransaction.RollbackRetaining;
begin
 if active then begin
  if checkcanevent(self,tmethod(fonbeforerollbackretaining)) then begin
   fonbeforerollback(self);
  end;
  try
   if not (tao_fake in foptions) then begin
    tcustomsqlconnection(database).RollBackRetaining(FTrans);
   end;
  finally
   fsavepointlevel:= 0;
  end;
//  if (tao_refreshdatasets in foptions) or
//       (sco_emulateretaining in 
//             tcustomsqlconnection(database).connoptions) then begin
//  if fcloselock = 0 then begin //refresh will not be performed later
   refreshdatasets;
//  end;
//  end;
  if checkcanevent(self,tmethod(fonafterrollbackretaining)) then begin
   fonafterrollback(self);
  end;
 end;
end;

procedure tsqltransaction.disconnect(const sender: tsqlquery);
var
 int1: integer;
 intf1: itransactionclient;
 k1: tupdatekind;
begin
 int1:= 1;
 if (self <> sender.ftransactionwrite) then begin
  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   if sender.fapplyqueries[k1] <> nil then begin
    inc(int1);
   end;
  end;
  {
  if sender.fupdateqry <> nil then begin
   inc(int1);
  end;
  if sender.fdeleteqry <> nil then begin
   inc(int1);
  end;
  if sender.finsertqry <> nil then begin
   inc(int1);
  end;
  }
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
   finalizetransaction;
   with tcustomsqlconnection(database) do begin
    if Transaction = self then begin 
     Transaction:= nil;
    end;
    if Transactionwrite = self then begin 
     Transactionwrite:= nil;
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

procedure TSQLTransaction.finalizetransaction;
begin
 if (database <> nil) and (ftrans <> nil) then begin
  tsqlconnection(database).finalizetransaction(ftrans);
 end; 
end;

function TSQLTransaction.savepointbegin: integer;
var
 mstr1: msestring;
begin
 active:= true;
 result:= fsavepointlevel;
 mstr1:= 'sp'+inttostrmse(result);
 database.executedirect('SAVEPOINT '+mstr1+';',self,nil,false,true);
 inc(fsavepointlevel);
end;

procedure tsqltransaction.checkpendingaction;
var
 act1: tcommitrollbackaction;
 bo1: boolean;
begin
 if (fpendingaction <> canone) and (fsavepointlevel = 0) and active then begin
  act1:= fpendingaction;
  bo1:= fpendingrefresh;
  fpendingaction:= canone;
  fpendingrefresh:= false;
  if bo1 then begin
   refresh(act1);
  end
  else begin
   doendtransaction(act1);
  end;
 end;
end;

procedure TSQLTransaction.savepointrollback(alevel: integer = -1);
begin
 checkactive;
 if alevel = -1 then begin
  alevel:= fsavepointlevel-1;
 end;
 database.executedirect('ROLLBACK TO '+'sp'+inttostrmse(alevel)+';',
                                                    self,nil,false,true); 
 fsavepointlevel:= alevel;
 checkpendingaction;
end;

procedure TSQLTransaction.savepointrelease;
begin
 checkactive;
 database.executedirect('RELEASE SAVEPOINT '+'sp'+
            inttostrmse(fsavepointlevel-1)+';',self,nil,false,true); 
 dec(fsavepointlevel);
 checkpendingaction;
end;

procedure TSQLTransaction.dobeforestop;
begin
 if checkcanevent(self,tmethod(fonbeforestop)) then begin
  fonbeforestop(self);
 end;
end;

procedure TSQLTransaction.doafterstop;
begin
 if checkcanevent(self,tmethod(fonafterstop)) then begin
  fonafterstop(self);
 end;
end;

procedure TSQLTransaction.setpendingaction(const avalue: tcommitrollbackaction);
begin
 fpendingaction:= avalue;
 if not (avalue in [cacommitretaining,carollbackretaining]) then begin
  fpendingrefresh:= false;
 end;
end;

{ TSQLQuery }

constructor TSQLQuery.Create(AOwner : TComponent);
var
 k1: tupdatekind;
begin
 fmasterdelayus:= -1;
  inherited Create(AOwner);
  FParams := TmseParams.create(self);
  FSQL := TsqlStringList.Create;
  FSQL.OnChange := @OnChangeSQL;

  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   fapplysql[k1]:= tsqlstringlist.create;
   fapplysql[k1].onchange:= @onchangemodifysql;
  end;
  {
  FSQLUpdate := TupdatesqlStringList.Create;
  FSQLUpdate.OnChange := @OnChangeModifySQL;
  FSQLInsert := TupdatesqlStringList.Create;
  FSQLInsert.OnChange := @OnChangeModifySQL;
  FSQLDelete := TsqlStringList.Create;
  FSQLDelete.OnChange := @OnChangeModifySQL;
}
  FIndexDefs := TIndexDefs.Create(Self);
  FReadOnly := false;
  FParseSQL := True;
  fstatementtype:= stnone;
// Delphi has upWhereAll as default, but since strings and oldvalue's don't work yet
// (variants) set it to upWhereKeyOnly
  FUpdateMode := upWhereKeyOnly;
  FUsePrimaryKeyAsKey := True;
end;

destructor TSQLQuery.Destroy;
var
 k1: tupdatekind;
begin
  if Active then Close;
  UnPrepare;
  if assigned(FCursor) then (Database as tcustomsqlconnection).DeAllocateCursorHandle(FCursor);
  FreeAndNil(FMasterLink);
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   freeandnil(fapplyqueries[k1]);
   freeandnil(fapplysql[k1]);
  end;
  {
  FreeAndNil(FSQLInsert);
  FreeAndNil(FSQLDelete);
  FreeAndNil(FSQLUpdate);
  }
  FreeAndNil(FIndexDefs);
  {
  freeandnil(finsertqry);
  freeandnil(fupdateqry);
  freeandnil(fdeleteqry);
  }
  inherited Destroy;
end;

procedure TSQLQuery.OnChangeSQL(const Sender : TObject);

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

procedure TSQLQuery.OnChangeModifySQL(const Sender : TObject);

begin
 if not (csdesigning in componentstate) then begin
  CheckInactive;
 end;
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
 if filtered and (filter <> '') then begin
  fsqlprepbuf:= addfilter(fsqlbuf);
 end
 else begin
  fsqlprepbuf:= fsqlbuf;
 end;
 if not (dso_noprepare in getdsoptions) then begin
  tcustomsqlconnection(database).preparestatement(fcursor,
                             tsqltransaction(transaction),fsqlprepbuf,fparams);
 end;
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
 int1: integer;

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
   fsqlprepbuf:= AddFilter(FSQLBuf);
  end
  else begin
   fsqlprepbuf:= fsqlbuf;
  end;
  if not (dso_noprepare in getdsoptions) then begin
   Db.PrepareStatement(Fcursor,sqltr,fsqlprepBuf,FParams);
  end;
//  ftablename:= '';
  if (FCursor.FStatementType in datareturningtypes) then begin
   FCursor.FInitFieldDef := True;
   fupdateable:= not readonly and 
         (
         (sqs_userapplyrecupdate in fmstate) or
         (fapplysql[ukmodify].count > 0) and 
         (fapplysql[ukinsert].count > 0) and 
         (fapplysql[ukdelete].count > 0)
         );
   if fparsesql and (pos(',',FFromPart) <= 0) then begin
            //don't change tablename otherwise
    ftablename:= ffrompart;
    int1:= pos(' ',ftablename);
    if int1 > 0 then begin
     setlength(ftablename,int1-1); //use real name only
    end;
//    fupdateable:= not readonly;
   end;
   fupdateable:= fupdateable or not readonly and (ftablename <> ''); 
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
 if not (Fcursor.FStatementType in datareturningtypes) then begin
  result:= false;
  Exit;
 end;
 if not FIsEof then begin
  FIsEOF:= not tcustomsqlconnection(database).Fetch(Fcursor);
  if fiseof then begin
   fcursor.close;
  end;
 end;
 Result := not FIsEOF;
end;

procedure TSQLQuery.Execute;
var
// int1: integer;
 bo1: boolean;
begin
 If (FParams.Count>0) and Assigned(FMasterLink) then begin
  FMasterLink.CopyParamsFromMaster(False);
 end;
 bo1:= isutf8;
 updateparams(fparams,bo1);
 fcursor.ftrans:= tsqltransaction(ftransaction).handle;
 if dso_noprepare in getdsoptions then begin
  tcustomsqlconnection(fdatabase).executeunprepared(fcursor,
               tsqltransaction(ftransaction),fParams,fsqlprepbuf,bo1);
 end
 else begin
  tcustomsqlconnection(fdatabase).execute(fcursor,
              tsqltransaction(ftransaction),fParams,bo1);
 end;
// doexecute(fparams,ftransaction,fcursor,fdatabase,isutf8);
end;

function tsqlquery.loadfield(const afieldno: integer;
                     const afieldtype: tfieldtype; const buffer: pointer;
                     var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
begin
 result:= tcustomsqlconnection(database).LoadField(FCursor,aFieldtype,
         afieldno,buffer,bufsize,isutf8)
end;

procedure TSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure tsqlquery.freemodifyqueries;
var
 k1: tupdatekind;
begin
 fbstate:= fbstate - [bs_refreshinsert,bs_refreshupdate];
 for k1:= low(tupdatekind) to high(tupdatekind) do begin
  freeandnil(fapplyqueries[k1]);
 end;
 {
 FreeAndNil(FUpdateQry);
 FreeAndNil(FInsertQry);
 FreeAndNil(FDeleteQry);
 }
end;

procedure tsqlquery.freequery;
begin
 if not (bs_refreshing in fbstate) then begin
  if ({not }IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
        tcustomsqlconnection(database).UnPrepareStatement(FCursor);
  end;
  if ftransactionwrite = nil then begin
   freemodifyqueries;
  end;
 end;
end;

procedure TSQLQuery.disconnect{(const aexecute: boolean)};
begin
 if bs_connected in fbstate then begin
  if fcursor <> nil then begin
   fcursor.close;
  end;
  freequery;
  if not (bs_refreshing in fbstate) then begin
//   freefldbuffers;
   database.deallocatecursorhandle(fcursor);
  end;
  exclude(fbstate,bs_connected);
//  if aexecute then begin
   if faftercursorclose <> nil then begin
    faftercursorclose.execute(database,tsqltransaction(transaction));
   end;
//  end;
 end;
end;

procedure TSQLQuery.InternalClose;
begin
// Database and FCursor could be nil, for example if the database is not
// assigned, and .open is called
 try
  disconnect{(true)};
 finally
  if not (bs_refreshing in fbstate) then begin
   freemodifyqueries;
   fprimarykeyfield:= nil;
   if DefaultFields then begin
    DestroyFields;
   end;
  end;
  fupdaterowsaffected:= 0;
  fblobintf:= nil;
//  if StatementType in datareturningtypes then FreeFldBuffers;
  FIsEOF := False;
  inherited internalclose;
 end;
end;

procedure TSQLQuery.InternalInitFieldDefs;
begin
 if FLoadingFieldDefs then begin
  Exit;
 end;
 FLoadingFieldDefs := True;
 try
  tcustomsqlconnection(database).AddFieldDefs(fcursor,FieldDefs);
 finally
  FLoadingFieldDefs := False;
 end;
end;

procedure tsqlquery.resetparsing;
begin
 FWhereStartPos := 0;
 FWhereStopPos := 0;
 ffrompart:= '';
// ftablename:= '';
end;

procedure TSQLQuery.SQLParser(var ASQL: msestring);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppGroup,ppOrder,ppComment,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pmsechar;
  S                       : msestring;
  ParsePart               : TParsePart;
  StrLength               : Integer;

begin
 PSQL:=Pmsechar(ASQL);
 ParsePart := ppStart;

 CurrentP := PSQL-1;
 PhraseP := PSQL;
 resetparsing;

 repeat begin
 	inc(CurrentP);

        if SkipComments(CurrentP) then
         if ParsePart = ppStart then PhraseP := CurrentP;
       	if CurrentP^ in [' ',#13,#10,#9,#0,'(',')',';'] then begin { if(1) }
	    if (CurrentP-PhraseP > 0) or (CurrentP^ in [';',#0]) then begin { if(2) }
		strLength := CurrentP-PhraseP;
		Setlength(S,strLength);
		
		if strLength > 0 then Move(PhraseP^,S[1],strLength*sizeof(msechar));
		s := uppercase(s);

		case ParsePart of
		    ppStart  : begin
			FCursor.FStatementType := 
			 (Database as tcustomsqlconnection).StrToStatementType(s);
		
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
			    Move(PStatementPart^,FFromPart[1],StrLength*sizeof(msechar));
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

 if (FWhereStartPos > 0) and (FWhereStopPos > 0) and 
              filtered and (filter <> '') then begin
 	system.insert('(',ASQL,FWhereStartPos+1);
 	inc(FWhereStopPos);
 	system.insert(')',ASQL,FWhereStopPos);
 end;
 if not fparsesql and (fstatementtype <> stnone) then begin
  fCursor.FStatementType := fstatementtype;
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
{
procedure TSQLQuery.InitUpdates(ASQL : string);
begin
 if pos(',',FFromPart) > 0 then begin
  FUpdateable:= (fsqlupdate.count > 0) and (fsqlinsert.count > 0) and 
                         (fsqldelete.count > 0);
           // select-statements from more then one table are not updateable
 end
 else begin
  FUpdateable := True;
  FTableName := FFromPart;
 end;
end;
}
procedure TSQLQuery.connect(const aexecute: boolean);

  procedure InitialiseModifyQuery(var qry : TSQLQuery; aSQL: TsqlSTringList);  
  begin
   if qry = nil then begin
    qry:= TSQLQuery.Create(nil);
    with qry do begin
     ParseSQL:= False;
     DataBase:= Self.DataBase;
     Transaction:= self.writetransaction;
     SQL.Assign(aSQL);
    end;
   end;
  end; //initialisemodifyquery

var
 tel,fieldc: integer;
 f: TField;
 s: string;
 ar1: stringarty;
 IndexFields: stringarty;
 str1: string;
 int1: integer;
 k1: tupdatekind;
 
begin
 if database <> nil then begin
  getcorbainterface(database,typeinfo(iblobconnection),fblobintf);
 end;
 if not streamloading then begin  
  try
   Prepare;
   if FCursor.FStatementType in datareturningtypes then begin
    indexfields:= nil;
    if FUpdateable then begin
     if FusePrimaryKeyAsKey and not (bs_refreshing in fbstate) then begin
      UpdateIndexDefs;  //must be before execute because 
                        //of MS SQL ODBC one statement per connection limitation
      for tel := 0 to indexdefs.count-1 do  begin
       if ixPrimary in indexdefs[tel].options then begin
        ar1:= nil;
        splitstringquoted(indexdefs[tel].fields,ar1,'"',';');
        stackarray(ar1,indexfields);
       end;
      end;
     end;
    end;

    if aexecute then begin
     if fbeforeexecute <> nil then begin
      fbeforeexecute.execute(database,tsqltransaction(transaction));
     end;
     Execute;
     if FCursor.FInitFieldDef and not (bs_refreshing in fbstate) then begin
      InternalInitFieldDefs;
     end;
    end;
    if not (bs_refreshing in fbstate) then begin
     if DefaultFields and aexecute then begin
      CreateFields;
     end;
     for int1:= 0 to high(indexfields) do begin
      F := Findfield(IndexFields[int1]);
      if F <> nil then begin
       F.ProviderFlags := F.ProviderFlags + [pfInKey];
      end;
     end;
     if (database <> nil) and (ftablename <> '') then begin
      str1:= tcustomsqlconnection(database).getprimarykeyfield(
                                                      ftablename,fcursor);
      if (str1 <> '') then begin
       fprimarykeyfield:= fields.findfield(str1);
      end;
     end;
     if fupdateable then begin
      for k1:= low(tupdatekind) to high(tupdatekind) do begin
       InitialiseModifyQuery(Fapplyqueries[k1],Fapplysql[k1]);       
      end;
     end;
     {
     if FUpdateable or (fsqldelete.count > 0) then begin
      InitialiseModifyQuery(FDeleteQry,FSQLDelete);
     end;
     if FUpdateable or (fsqlupdate.count > 0) then begin
      InitialiseModifyQuery(FUpdateQry,FSQLUpdate);
     end;
     if FUpdateable or (fsqlinsert.count > 0) then begin
      InitialiseModifyQuery(FInsertQry,FSQLInsert);
     end;
     }
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

procedure tsqlquery.dorefresh;
var
 int1: integer;
begin
 int1:= recno;
 include(fbstate,bs_refreshing);
 try
  active:= false;
  active:= true;
  if (recno <> int1) and (bs_restorerecno in fbstate) then begin
   setrecno1(int1,true);
  end;
 finally
  exclude(fbstate,bs_refreshing);
  if not active then begin
   freefieldbuffers;
   freequery;
  end;
 end;
end;

procedure tsqlquery.refreshtransaction;
var
 opt1: datasetoptionsty;
 bo1: boolean;
begin
 opt1:= getdsoptions;
 if not (dso_notransactionrefresh in opt1) then begin
  if dso_recnotransactionrefresh in opt1 then begin
   bo1:= bs_restorerecno in fbstate;
   include(fbstate,bs_restorerecno);
   try
    dorefresh;
   finally
    if not bo1 then begin
     exclude(fbstate,bs_restorerecno);
    end;
   end;
  end
  else begin
   dorefresh;
  end;
 end;
end;
 
procedure tsqlquery.internalrefresh;
begin
 if dso_refreshtransaction in getdsoptions then begin
  if transaction.savepointlevel = 0 then begin
   transaction.refresh;
  end
  else begin
   transaction.pendingrefresh:= true;
  end;
 end
 else begin
  dorefresh;
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
   (database as tcustomsqlconnection).UnPrepareStatement(Fcursor);
  end;
 end;
end;

procedure TSQLQuery.SetReadOnly(AValue : Boolean);

begin
 CheckInactive;
 freadonly:= avalue;
//  if not AValue then
//    begin
//    if FParseSQL then FReadOnly := False
//      else DatabaseErrorFmt(SNoParseSQL,['Updating ']);
//    end
//  else FReadOnly := True;
end;

procedure TSQLQuery.SetParseSQL(AValue : Boolean);

begin
 CheckInactive;
 if fparsesql <> avalue then begin
  fparsesql:= avalue;
  if not AValue then begin
   Filtered:= False;
   resetparsing;
  end;
  unprepare; //refresh sqlparser
 end;
end;

procedure tsqlquery.setstatementtype(const avalue: tstatementtype);
begin
 CheckInactive;
 if fstatementtype <> avalue then begin
  fstatementtype:= avalue;
  unprepare; //refresh sqlparser
 end;
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

procedure tsqlquery.updatewherepart(var sql_where : string; const afield: tfield);
var
 quotechar: string;
begin
 if database <> nil then begin
  quotechar:= database.identquotechar;
 end
 else begin
  quotechar:= '"';
 end;
 with afield do begin
  if (pfInKey in ProviderFlags) or
    ((FUpdateMode = upWhereAll) and (pfInWhere in ProviderFlags)) or
    ((FUpdateMode = UpWhereChanged) and 
    (pfInWhere in ProviderFlags) and 
    (value <> oldvalue)) then begin
   sql_where := sql_where + '(' + quotechar+FieldName+quotechar+ 
             '= :OLD_' + FieldName + ') and ';
  end;
 end;
end;

function tsqlquery.refreshrecquery(const update: boolean): string;
var
 int1,int2: integer;
 intf1: imsefield;
 field1: tfield;
 flags1: providerflags1ty;
begin
 result:= '';
 int2:= 0;
 for int1:= 0 to fields.count - 1 do begin
  field1:= fields[int1];
  if (field1.fieldkind = fkdata) and 
    getcorbainterface(field1,typeinfo(imsefield),intf1) then begin
   flags1:= intf1.getproviderflags1;
   if (pf1_refreshupdate in flags1) and update or 
      (pf1_refreshinsert in flags1) and not update then begin
    if int2 = 0 then begin
     result:= 'returning ';
    end;
    result:= result + field1.fieldname + ',';
    inc(int2);
   end;
  end;
 end;
 if int2 > 0 then begin
  if update then begin
   include(fbstate,bs_refreshupdate);
  end
  else begin
   include(fbstate,bs_refreshinsert);
  end;
  setlength(result,length(result)-1);
 end
 else begin
 end;
end;

procedure tsqlquery.checktablename;
begin
 if ftablename = '' then begin
  databaseerror('No table name in apply recupdate statement',self);
 end;
end;

function tsqlquery.updaterecquery{(const refreshfieldvalues: boolean)} : string;
var 
 x: integer;
 sql_set: string;
 sql_where: string;
 field1: tfield;
 quotechar: string;
begin
 checktablename;
 quotechar:= database.identquotechar;
 sql_set:= '';
 sql_where:= '';
 for x := 0 to Fields.Count -1 do begin
  field1:= fields[x];
  with field1 do begin
   if fieldkind = fkdata then begin
    UpdateWherePart(sql_where,field1);
    if (pfInUpdate in ProviderFlags) then begin
     sql_set:= sql_set + quotechar+FieldName+quotechar + '=:' + FieldName + ',';
    end;
   end;
  end;
 end;
 if sql_set = '' then begin
  databaseerror('No "set" part in SQLUpdate statement.',self);
 end;
 if sql_where = '' then begin
  databaseerror('No "where" part in SQLUpdate statement.',self);
 end;
 setlength(sql_set,length(sql_set)-1);
 setlength(sql_where,length(sql_where)-5);
 result := 'update ' + FTableName + ' set ' + sql_set + ' where ' + sql_where;
// if refreshfieldvalues then begin
  result:= result + refreshrecquery(true);
// end;
end;


function tsqlquery.insertrecquery{(const refreshfieldvalues: boolean)} : string;
var 
 x: integer;
 sql_fields: string;
 sql_values: string;
 quotechar: string;
begin
 checktablename;
 quotechar:= database.identquotechar;
 sql_fields := '';
 sql_values := '';
 for x := 0 to Fields.Count -1 do begin
  with fields[x] do begin
   if (fieldkind = fkdata) {and not IsNull} and 
                          (pfInUpdate in ProviderFlags) then begin 
    sql_fields:= sql_fields + quotechar+FieldName+quotechar+ ',';
    sql_values:= sql_values + ':' + FieldName + ',';
   end;
  end;
 end;
 if sql_fields = '' then begin
  databaseerror('No "values" part in SQLInsert statement.',self);
 end;
 setlength(sql_fields,length(sql_fields)-1);
 setlength(sql_values,length(sql_values)-1);
 result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' +
                     sql_values + ')';
// if refreshfieldvalues then begin
  result:= result + ' '+refreshrecquery(false);
// end;
end;

function tsqlquery.deleterecquery : string;
var 
 x: integer;
 sql_where: string;
 field1: tfield;
begin
 checktablename;
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

Procedure TSQLQuery.internalApplyRecUpdate(UpdateKind : TUpdateKind);
var
 s: string;
 
//todo: optimize, use tsqlstatement and tsqlresult instead of tsqlquery

var
// qry: tsqlquery;
 x: integer;
 Fld : TField;
 param1,param2: tparam;
 int1: integer;
 blobspo: pblobinfoarty;
 str1: string;
 bo1: boolean;
 freeblobar: pointerarty;
 statementtypebefore: tstatementtype;
// refreshfieldvalues: boolean;
 oldisnew: boolean;
    
begin
 oldisnew:= (updatekind = ukinsert) and (bs_inserttoupdate in fbstate);
 if oldisnew then begin
  updatekind:= ukmodify;
 end;
 blobspo:= getintblobpo;
 if fapplyqueries[updatekind] = nil then begin
  databaseerror(name+': No rec apply query for '+
                   getenumname(typeinfo(tupdatekind),ord(updatekind))+'.');
 end;
(*
 case UpdateKind of
  ukModify: begin
//   refreshfieldvalues:= uso_refresh in fsqlupdate.options;
   qry:= FUpdateQry;
   if qry.sql.count = 0 then begin
    qry.SQL.Add(updateRecQuery{(refreshfieldvalues)});
   end;
  end;
  ukInsert: begin
//   refreshfieldvalues:= uso_refresh in fsqlinsert.options;
   qry:= FInsertQry;
   if qry.sql.count = 0 then begin
    qry.SQL.Add(InsertRecQuery{(refreshfieldvalues)});
   end;
  end
  else begin               //ukDelete
//   refreshfieldvalues:= false;
   qry := FDeleteQry;
   if qry.sql.count = 0 then begin
    qry.SQL.Add(DeleteRecQuery);
   end;
  end;
 end;
*)
 with fapplyqueries[updatekind] do begin
  if sql.count = 0 then begin
   case updatekind of
    ukinsert: begin
     sql.add(self.insertrecquery);
    end;
    ukmodify: begin
     sql.add(self.updaterecquery);
    end;
    ukdelete: begin
     sql.add(self.deleterecquery);
    end;
   end;
  end;  
  futf8:= self.isutf8;
  transaction.active:= true;
  freeblobar:= nil;
  try
   for x := 0 to Params.Count-1 do begin
    param1:= params[x];
    with param1 do begin
     str1:= name;
     bo1:= pos('OLD_',str1) = 1;
     if bo1 then begin
      str1:= copy(str1,5,bigint);
     end;
     if bo1 and not oldisnew then begin
      Fld:= self.FieldByName(str1);
      oldfieldtoparam(fld,param1);
 //     AssignFieldValue(Fld,Fld.OldValue);
     end
     else begin
      fld:= self.findfield(str1);
      if fld = nil then begin     //search for param
       param2:= self.params.findparam(str1);
       if param2 = nil then begin
        fieldbyname(str1); //raise exception
       end
       else begin
        value:= param2.value;
       end;
      end
      else begin             //use field
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
       end;
      end;
     end;
    end;
   end;
   if (updatekind = ukmodify) and 
                          (bs_refreshupdate in self.fbstate) or
      (updatekind = ukinsert) and 
                          (bs_refreshinsert in self.fbstate) then begin
    parsesql:= false;
    statementtypebefore:= statementtype;
    try
     statementtype:= stselect;
     active:= true;
     if not eof then begin
      for int1:= 0 to {qry.}fieldcount - 1 do begin
       with fields[int1] do begin
        fld:= self.fields.fieldbyname(fieldname);
//        if not(fld is tblobfield) then begin
         fld.value:= value;
//        end;
       end;
      end;
     end;
    finally
     active:= false;
     statementtype:= statementtypebefore;
    end;
   end
   else begin
    execsql;
   end;
   if not (bs_refreshinsert in fbstate) and (updatekind = ukinsert) and 
                                        (self.fprimarykeyfield <> nil) then begin
    tcustomsqlconnection(database).updateprimarykeyfield(
                   self.fprimarykeyfield,{qry.}transaction);
   end;
   if self.fupdaterowsaffected >= 0 then begin
    if self.fcursor.frowsaffected < 0 then begin
     self.fupdaterowsaffected:= -1;
    end
    else begin
     inc(self.fupdaterowsaffected,fcursor.frowsaffected);
    end;
   end;
  finally
   for int1:= high(freeblobar) downto 0 do begin
    deleteblob(blobspo^,tfield(freeblobar[int1]),true);
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
  if (fcursor <> nil) and 
                     (FCursor.FStatementType in datareturningtypes) then begin
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
{
function TSQLQuery.GetStatementType : TStatementType;

begin
  if assigned(FCursor) then Result := FCursor.FStatementType
    else Result := stNone;
end;
}
Procedure TSQLQuery.SetDataSource(AVAlue : TDatasource);
Var
 DS : TDatasource;
begin
 DS:=DataSource;
 If (AValue<>DS) then begin
  If Assigned(DS) then begin
   DS.RemoveFreeNotification(Self);
  end;
  If Assigned(AValue) then begin
   AValue.FreeNotification(Self);  
   FMasterLink:= TsqlMasterParamsDataLink.Create(Self);
   FMasterLink.Datasource:= AValue;
  end
  else begin
   FreeAndNil(FMasterLink);  
  end;
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
  if acomponent = faftercursorclose then begin
   faftercursorclose:= nil;
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
function TSQLQuery.executedirect(const asql: string): integer;
begin
 checkdatabase(name,fdatabase);
 result:= database.executedirect(asql,writetransaction); 
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
    disconnect{(false)};
    unprepare;
    tcustomsqlconnection(database).DeAllocateCursorHandle(FCursor);
    startlogger;
   end;
  end;
 end;
end;

procedure TSQLQuery.setFSQL(const avalue: TsqlStringlist);
begin
 fsql.assign(avalue);
end;

procedure TSQLQuery.setFSQLUpdate(const avalue: TsqlStringlist);
begin
 fapplysql[ukmodify].assign(avalue);
end;

procedure TSQLQuery.setFSQLInsert(const avalue: TsqlStringlist);
begin
 fapplysql[ukinsert].assign(avalue);
end;

procedure TSQLQuery.setFSQLDelete(const avalue: TsqlStringlist);
begin
 fapplysql[ukdelete].assign(avalue);
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

procedure TSQLQuery.setaftercursorclose(const avalue: tmsesqlscript);
begin
 if faftercursorclose <> nil then begin
  faftercursorclose.removefreenotification(self);
 end;
 faftercursorclose:= avalue;
 if faftercursorclose <> nil then begin
  faftercursorclose.freenotification(self);
 end;
end;

function TSQLQuery.getnumboolean: boolean;
begin
 result:= tcustomsqlconnection(database).getnumboolean;
end;

function TSQLQuery.getfloatdate: boolean;
begin
 result:= tcustomsqlconnection(database).getfloatdate;
end;

function TSQLQuery.getint64currency: boolean;
begin
 result:= tcustomsqlconnection(database).getint64currency;
end;

function TSQLQuery.getsqltransaction: tsqltransaction;
begin
 result:= tsqltransaction(inherited transaction);
end;

procedure TSQLQuery.setsqltransaction(const avalue: tsqltransaction);
begin
 inherited transaction:= avalue;
end;

function TSQLQuery.getsqltransactionwrite: tsqltransaction;
begin
 result:= tsqltransaction(inherited transactionwrite);
end;

procedure TSQLQuery.settransactionwrite(const avalue: tmdbtransaction);
begin
 if avalue <> ftransactionwrite then begin
  checkpendingupdates;
 end;
 inherited;
end;

procedure TSQLQuery.setsqltransactionwrite(const avalue: tsqltransaction);
begin
 inherited transactionwrite:= avalue;
end;

procedure TSQLQuery.applyupdate(const cancelonerror: boolean);
begin
 fupdaterowsaffected:= 0;
 inherited;
end;

procedure TSQLQuery.applyupdates(const maxerrors: integer;
               const cancelonerror: boolean);
begin
 fupdaterowsaffected:= 0;
 if fdatabase = nil then begin
  inherited;
 end
 else begin
  tcustomsqlconnection(fdatabase).beginupdate;
  try
   inherited;
  finally
   tcustomsqlconnection(fdatabase).endupdate;
  end;
 end;
end;

function TSQLQuery.writetransaction: tsqltransaction;
begin
 result:= tsqltransaction(ftransactionwrite);
 if result = nil then begin
  result:= transaction;
 end;
end;

procedure TSQLQuery.dobeforeapplyupdate;
begin
 inherited;
 if writetransaction <> nil then begin
  writetransaction.active:= true;
 end;
end;

function TSQLQuery.rowsreturned: integer;
begin
 if active then begin
  result:= fcursor.frowsreturned;
 end
 else begin
  result:= -1;
 end;
end;

function TSQLQuery.rowsaffected: integer;
begin
 if active then begin
  result:= fcursor.frowsaffected;
 end
 else begin
  result:= -1;
 end;
end;

procedure TSQLQuery.checkpendingupdates;
begin
 //dummy
end;

function TSQLQuery.stringmemo: boolean;
begin
 result:= false;
 //dummy
end;

function TSQLQuery.isutf8: boolean;
begin
 result:= futf8;
// if fdatabase <> nil then begin
//  tcustomsqlconnection(fdatabase).updateutf8(result);
// end;
end;
{
procedure TSQLQuery.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 fmasterlinkoptions:= [];
 if dso_syncmasteredit in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncedit);
 end;
 if dso_syncmasterinsert in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncinsert);
 end;
 if dso_syncmasterdelete in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncdelete);
 end;
 if dso_delayeddetailpost in aoptions then begin
  include(fmasterlinkoptions,mdlo_delayeddetailpost);
 end;
 if dso_syncinsertfields in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncinsertfields);
 end;
end;
}
{
procedure TSQLQuery.setmasterlink(const avalue: tsqlmasterparamsdatalink);
begin
 fmasterlink.assign(avalue);
end;
}
procedure TSQLQuery.dobeforeedit;
begin
 if (fmasterlink <> nil) then begin
  fmasterlink.checkrefresh;
 end;
 inherited;
end;

procedure TSQLQuery.dobeforeinsert;
begin
 if (fmasterlink <> nil) then begin
  fmasterlink.checkrefresh;
 end;
 inherited;
end;

procedure TSQLQuery.settablename(const avalue: string);
begin
 checkinactive;
 ftablename:= avalue;
end;

procedure TSQLQuery.dataevent(event: tdataevent; info: ptrint);
var
 int1: integer;
 sf,df: tfield;
 str1: string;
begin
 case event of
  deupdaterecord: begin
   if (mdlo_syncfields in foptionsmasterlink) and (fmasterlink <> nil) and
              fmasterlink.active then begin
    for int1:= 0 to fparams.count - 1 do begin
     str1:= fparams[int1].name;
     if (str1 <> '') then begin
      df:= findfield(str1);
      if df <> nil then begin
       sf:= fmasterlink.dataset.findfield(str1);
       if sf <> nil then begin
        df.value:= sf.value;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

{ TSQLCursor }

constructor TSQLCursor.create(const aowner: icursorclient; const aname: ansistring);
begin
 fowner:= aowner;
 fname:= aname;
 frowsaffected:= -1;
 frowsreturned:= -1; 
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
   if afield.datatype = ftmemo then begin
    aparam.asmemo:= str1;
   end
   else begin
    aparam.asblob:= str1;
   end;
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

function TSQLCursor.stringmemo: boolean;
begin
 result:= (fowner <> nil) and fowner.stringmemo;
end;

{ tcustomsqlstatement }

constructor tcustomsqlstatement.create(aowner: tcomponent);
begin
 fparams:= tmseparams.create(self);
 fsql:= tsqlstringlist.create;
 fterm:= ';';
 fsql.onchange:= @dosqlchange;
 inherited;
end;

destructor tcustomsqlstatement.destroy;
begin
 database:= nil;
 transaction:= nil;
 fparams.free;
 fsql.free;
 inherited;
end;

procedure tcustomsqlstatement.setsql(const avalue: tsqlstringlist);
begin
 fsql.assign(avalue);
end;

procedure tcustomsqlstatement.setdatabase1(const avalue: tcustomsqlconnection);
begin
 setdatabase(avalue);
end;

procedure tcustomsqlstatement.setparams(const avalue: tmseparams);
begin
 fparams.assign(avalue);
end;

procedure tcustomsqlstatement.dobeforeexecute(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction);
begin
 if canevent(tmethod(fonbeforeexecute)) then begin
  fonbeforeexecute(self,adatabase,atransaction);
 end;
end;

procedure tcustomsqlstatement.doafterexecute(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction);
begin
 if canevent(tmethod(fonafterexecute)) then begin
  fonafterexecute(self,adatabase,atransaction);
 end;
end;

procedure tcustomsqlstatement.doerror(const adatabase: tcustomsqlconnection;
               const atransaction: tsqltransaction; const e: exception;
               var handled: boolean);
begin
 if canevent(tmethod(fonerror)) then begin
  fonerror(self,adatabase,atransaction,e,handled);
 end;
end;

procedure tcustomsqlstatement.dosqlchange(const sender: tobject);
begin
 fparams.parsesql(fsql.text,true);
end;

procedure tcustomsqlstatement.settransaction1(const avalue: tsqltransaction);
begin
 settransaction(avalue);
end;

function tcustomsqlstatement.getname: string;
begin
 result:= name;
end;

function tcustomsqlstatement.getactive: boolean;
begin
 result:= false;
end;

procedure tcustomsqlstatement.setactive(avalue: boolean);
begin
 //dummy
end;

procedure tcustomsqlstatement.settransaction(const avalue: tmdbtransaction);
begin
 dosettransaction(itransactionclient(self),avalue,
                                        tmdbtransaction(ftransaction),false);
end;

procedure tcustomsqlstatement.settransactionwrite(const avalue: tmdbtransaction);
begin
 //dummy
end;

procedure tcustomsqlstatement.refreshtransaction;
begin
 //dummy
end;

procedure tcustomsqlstatement.setdatabase(const avalue: tmdatabase);
var
 intf1: idbcontroller;
 bo1: boolean;
begin
 dosetdatabase(idatabaseclient(self),avalue,tmdatabase(fdatabase));
 if (avalue <> nil) then begin
  if (ftransaction = nil) then begin
   transaction:= tsqlconnection(avalue).transaction;
  end;
  if mseclasses.getcorbainterface(
                          database,typeinfo(idbcontroller),intf1) then begin
   bo1:= sso_utf8 in foptions;
   intf1.updateutf8(bo1);
   if bo1 then begin
    foptions:= foptions + [sso_utf8];
   end
   else begin
    foptions:= foptions - [sso_utf8];
   end;
  end;
 end;
end;

function tcustomsqlstatement.isutf8: boolean;
begin
 result:= sso_utf8 in foptions;
end;
{
function tcustomsqlstatement.isutf8(const adatabase): boolean;
begin
 result:= sso_utf8 in foptions;
end;
}
procedure tcustomsqlstatement.setoptions(const avalue: sqlstatementoptionsty);
const
 mask: sqlstatementoptionsty = [sso_autocommit,sso_autocommitret];
begin
 if foptions <> avalue then begin
  foptions:= sqlstatementoptionsty(setsinglebit(
           longword(avalue),longword(foptions),longword(mask)));
 end;
end;

function tcustomsqlstatement.gettransaction: tmdbtransaction;
begin
 result:= ftransaction;
end;

function tcustomsqlstatement.getrecno: integer;
begin
 result:= -1;
end;

procedure tcustomsqlstatement.setrecno(value: integer);
begin
 //dummy
end;

procedure tcustomsqlstatement.disablecontrols;
begin
 //dummy
end;

procedure tcustomsqlstatement.enablecontrols;
begin
 //dummy
end;

function tcustomsqlstatement.moveby(distance: longint): longint;
begin
 result:= 0;
end;

procedure tcustomsqlstatement.checkbrowsemode;
begin
 //dummy
end;

{ tmsesqlscript }

procedure tmsesqlscript.execute(adatabase: tcustomsqlconnection = nil;
                 atransaction: tsqltransaction = nil);
var
 str1: msestring;
 ar1: msestringarty;
 int1,int2: integer;
 bo1: boolean;
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
 if sso_savepoint in foptions then begin
  int2:= atransaction.savepointbegin;
 end;
 try
  dobeforeexecute(adatabase,atransaction);
  updateparams(fparams,isutf8{(adatabase)});
  str1:= fsql.text;
  ar1:= splitsql(str1,fterm,fcharescapement);
  fstatementcount:= length(ar1);
  if high(ar1) < 0 then begin
   databaseerror(serrnostatement,self);
  end;
  for int1:= 0 to high(ar1) do begin
   fstatementnr:= int1;
   if canevent(tmethod(fonbeforestatement)) then begin
    fonbeforestatement(self);
   end;
   try
    adatabase.executedirect(ar1[int1],atransaction,fparams,isutf8,
                           sso_noprepare in foptions);
   except
    on e: exception do begin  
     bo1:= false;
     doerror(adatabase,atransaction,e,bo1);
     if not bo1 then begin
      raise;
     end;
    end;
   end;
   if canevent(tmethod(fonafterstatement)) then begin
    fonafterstatement(self);
   end;
  end;
  if sso_autocommit in foptions then begin
   atransaction.commit;
  end
  else begin
   if sso_autocommitret in foptions then begin
    atransaction.commitretaining;
   end;
  end;
  doafterexecute(adatabase,atransaction);
  if sso_savepoint in foptions then begin
   atransaction.savepointrelease;
  end;
 except
  if sso_savepoint in foptions then begin
   atransaction.savepointrollback(int2);
  end;
  raise;
 end;
end;

{ tsqlstatement }

constructor tsqlstatement.create(aowner: tcomponent);
begin
 inherited;
end;

destructor tsqlstatement.destroy;
begin
 setactive(false);
 inherited;
end;

procedure tsqlstatement.dosqlchange(const sender: tobject);
begin
 unprepare;
 inherited;
end;

procedure tsqlstatement.prepare;
begin
 if (fcursor = nil) or not fcursor.fprepared then begin
  checkdatabase(name,fdatabase);
  checktransaction(name,ftransaction);
  if not fdatabase.Connected then begin
   fdatabase.Open;
  end;
  if not ftransaction.Active then begin
   ftransaction.StartTransaction;
  end;
  if not assigned(fcursor) then begin
   FCursor:= fdatabase.AllocateCursorHandle(nil,name);
  end;
  fcursor.ftrans:= ftransaction.handle;
  fcursor.fstatementtype:= fstatementtype;
  if not (sso_noprepare in foptions) then begin
   fdatabase.PrepareStatement(Fcursor,ftransaction,fsql.text,FParams);
  end;
 end;
end;

procedure tsqlstatement.unprepare;
begin
 if (fcursor <> nil) and fcursor.fprepared then begin
  fdatabase.unpreparestatement(fcursor);
 end;
end;

procedure tsqlstatement.execute;
var
 bo1: boolean;
begin
 dobeforeexecute(fdatabase,ftransaction);
 prepare;
 updateparams(fparams,isutf8);
 fcursor.ftrans:= tsqltransaction(ftransaction).handle;
 try
  if sso_noprepare in foptions then begin
   tcustomsqlconnection(fdatabase).executeunprepared(fcursor,
            tsqltransaction(ftransaction),fparams,fsql.text,isutf8);
  end
  else begin
   tcustomsqlconnection(fdatabase).execute(fcursor,tsqltransaction(ftransaction),
                             fparams,isutf8);
  end;
//  fcursor.close;
  if sso_autocommit in foptions then begin
   ftransaction.commit;
  end
  else begin
   if sso_autocommitret in foptions then begin
    ftransaction.commitretaining;
   end;
  end;
  doafterexecute(fdatabase,ftransaction);
 except
  on e: exception do begin  
   bo1:= false;
   doerror(fdatabase,ftransaction,e,bo1);
   if not bo1 then begin
    raise;
   end;
  end;
 end;
end;

procedure tsqlstatement.setactive(avalue: boolean);
begin
 if not avalue then begin
  unprepare;
  if fcursor <> nil then begin
   fdatabase.deallocatecursorhandle(fcursor);
  end;
 end;
end;

procedure tsqlstatement.execute(const aparams: array of variant);
var
 int1: integer;
begin
 for int1:= 0 to high(aparams) do begin
  fparams[int1].value:= aparams[int1];
 end;
 execute;
end;

function tsqlstatement.rowsaffected: integer;
begin
 if fcursor = nil then begin
  result:= -1;
 end
 else begin
  result:= fcursor.frowsaffected;
 end;
end;

{ tsqlmasterparamsdatalink }

constructor tsqlmasterparamsdatalink.create(const aowner: tsqlquery);
begin
 fquery:= aowner;
 inherited create(aowner);
end;

destructor tsqlmasterparamsdatalink.destroy;
begin
 freeandnil(ftimer);
 inherited;
end;

procedure tsqlmasterparamsdatalink.dorefresh(const sender: tobject);
begin
 if Assigned(Params) and Assigned(DetailDataset) and 
                                 DetailDataset.Active then begin
  detaildataset.refresh;
 end;
end;

procedure tsqlmasterparamsdatalink.checkrefresh;
begin
 if ftimer <> nil then begin
  ftimer.firependingandstop; //cancel wait
 end;
end;

procedure tsqlmasterparamsdatalink.domasterchange;
var
 intf: igetdscontroller;
begin
 if (frefreshlock = 0) and 
    (not getcorbainterface(dataset,typeinfo(igetdscontroller),intf) or
      not intf.getcontroller.posting) then begin
  if assigned(onmasterchange) then begin
   onmasterchange(self); 
  end;
  if assigned(params) and assigned(detaildataset) and 
                (detaildataset.state = dsbrowse) then begin
   if fquery.masterdelayus < 0 then begin
    freeandnil(ftimer);
    dorefresh(nil);
   end
   else begin
    if ftimer = nil then begin
     ftimer:= tsimpletimer.create(fquery.masterdelayus,@dorefresh,true,
                                                               [to_single]);
    end
    else begin
     ftimer.interval:= fquery.masterdelayus; //single shot
     ftimer.enabled:= true;
    end;
   end;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.domasterdisable;
var
 intf: imasterlink;
begin
 if not getcorbainterface(dataset,typeinfo(imasterlink),intf) or
          not intf.refreshing then begin
  if assigned(onmasterdisable) then begin
   onmasterdisable(self);
  end;
  if assigned(detaildataset) and detaildataset.active then begin
   detaildataset.close;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.DataEvent(Event: TDataEvent; Info: Ptrint);
begin
 inherited;
 with tsqlquery(detaildataset) do begin
  case ord(event) of
   ord(deupdaterecord): begin
    if state in [dsinsert] then begin
     updaterecord;
     if modified then begin
      dataset.modified:= true;
     end;
    end;
   end;
   ord(deupdatestate): begin
    if (mdlo_syncedit in foptionsmasterlink) and
        (dataset.state = dsedit) and not (state = dsedit) then begin
     edit;
    end;
    if (mdlo_syncinsert in foptionsmasterlink) and
        (dataset.state = dsinsert) and not (state = dsinsert) then begin
     insert;
    end;
   end;
   de_afterdelete: begin
    if (mdlo_syncdelete in foptionsmasterlink) then begin
     delete;
    end;
   end;
   de_afterpost: begin
    if (mdlo_delayeddetailpost in foptionsmasterlink) then begin
     if (mdlo_inserttoupdate in foptionsmasterlink) and
      (state = dsinsert) then begin    
      include(fbstate,bs_inserttoupdate);
      try
       detaildataset.checkbrowsemode;
      finally
       exclude(fbstate,bs_inserttoupdate);
      end;
     end
     else begin
      detaildataset.checkbrowsemode;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.CheckBrowseMode;
label
 endlab;
var
 intf: igetdscontroller;
 detailoptions: optionsmasterlinkty;
begin
 inc(frefreshlock);
 try
  detailoptions:= tsqlquery(detaildataset).foptionsmasterlink;
  if detailoptions * 
        [mdlo_syncedit,mdlo_syncinsert] <> [] then begin
   if getcorbainterface(dataset,typeinfo(igetdscontroller),intf) and
                                      intf.getcontroller.canceling then begin
    detaildataset.cancel;
    exit;
   end
   else begin
    if mdlo_delayeddetailpost in detailoptions then begin
     exit;
    end;
    if detaildataset.state = dsinsert then begin
     dataset.updaterecord;
     if dataset.modified then begin
      detaildataset.post;
      goto endlab;
     end;
    end;
   end;
  end;
  inherited;
 endlab:
  if (dataset.state in [dsedit,dsinsert]) and 
        (detailoptions * [mdlo_syncedit,mdlo_syncinsert] <> []) then begin
   dataset.updaterecord; //synchronize fields
  end;
  if getcorbainterface(detaildataset,typeinfo(igetdscontroller),intf) then begin
   with intf.getcontroller do begin
    if (dataset.state = dsinsert) and assigned(onupdatemasterinsert) then begin
     onupdatemasterinsert(detaildataset,dataset);
    end;
    if (dataset.state = dsedit) and assigned(onupdatemasteredit) then begin
     onupdatemasteredit(detaildataset,dataset);
    end;
   end;
  end;
 finally
  dec(frefreshlock);
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

{ tmacroproperty }

constructor tmacroproperty.create(const aowner: tsqlstringlist);
begin
 fowner:= aowner;
 foptions:= [mao_caseinsensitive];
 inherited create;
end;

procedure tmacroproperty.dochange;
begin
 inherited;
 fowner.dochange;
end;

end.
