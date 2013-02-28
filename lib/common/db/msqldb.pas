{
    Copyright (c) 2004 by Joost van der Sluis

    SQL database & dataset

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  Modified 2006-2013 by Martin Schreiber

 **********************************************************************}

unit msqldb;

{$ifdef FPC}
{$mode objfpc}{$interfaces corba}{$goto on}{$H+}
{$endif}

interface

uses 
 sysutils,classes,mclasses,mdb,msebufdataset,msetypes,msedb,mseclasses,
 msedatabase,msestrings,msearrayutils,msedatalist,
 mseapplication,mseglob,msetimer,msearrayprops,msemacros;

type
 TSchemaType = (stNoSchema,stTables,stSysTables,stProcedures,stColumns,
                    stProcedureParams,stIndexes,stPackages);
 sqlconnoptionty = (sco_supportparams,sco_emulateretaining,sco_nounprepared);
 sqlconnoptionsty = set of sqlconnoptionty;

// TSQLQuery = class;

 TStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

const
 updatestatementtypes: array[tupdatekind] of tstatementtype =
        //(ukModify, ukInsert, ukDelete)
          (stupdate, stinsert, stdelete);
 StatementTokens : Array[TStatementType] of msestring =
                 ('(none)', 'select',
                  'insert', 'update', 'delete',
                  'create', 'get', 'put', 'execute',
                  'start','commit','rollback', '?'
                 );
 datareturningtypes = [stselect,stexecprocedure];

type
 tcustomsqlconnection = class;
 TSQLTransaction = class;
 tmacroproperty = class;
 tsqlstringlist = class(tmsestringdatalist)
  private
   fmacros: tmacroproperty;
   function gettext: msestring;
   procedure settext(const avalue: msestring);
   procedure readstrings(reader: treader);
//   procedure writestrings(writer: twriter);
   procedure setmacros(const avalue: tmacroproperty);
  protected
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create; override;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
   property text: msestring read gettext write settext;
  published
   property macros: tmacroproperty read fmacros write setmacros;
 end;

 tsqlmacroitem = class;
 
 tmacrostringlist = class(tsqlstringlist)
  private
   fowner: tsqlstringlist;
  protected
   procedure dochange; override;
  public
   constructor create(const aowner: tsqlstringlist); reintroduce;
 end;
 
 tsqlmacroitem = class(townedpersistent)
  private
   fname: msestring;
   fvalue: tmacrostringlist;
   factive: boolean;
   procedure setvalue(const avalue: tmacrostringlist);
   procedure setactive(const avalue: boolean);
  protected
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
  published
   property name: msestring read fname write fname;
   property value: tmacrostringlist read fvalue write setvalue;
   property active: boolean read factive write setactive default true;
 end;
  
 tmacroproperty = class(townedpersistentarrayprop)
  private
   foptions: macrooptionsty;
   function getitems(const aindex: integer): tsqlmacroitem;
   procedure setitems(const aindex: integer; const avalue: tsqlmacroitem);
  protected
   procedure dochange(const aindex: integer); override;
  public
   constructor create(const aowner: tsqlstringlist); reintroduce;
   property items[const aindex: integer]: tsqlmacroitem read getitems 
                     write setitems; default;
   function itembyname(const aname: msestring): tsqlmacroitem;
   function itembynames(const anames: array of msestring): tsqlmacroitem;
   class function getitemclasstype: persistentclassty; override;
               //used in dumpunitgroups
  published
   property options: macrooptionsty read foptions write foptions 
                                           default [mao_caseinsensitive];
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

 econnectionerror = class(edatabaseerror)
  private
   ferror: integer;
   ferrormessage: msestring;
   fsender: tcustomsqlconnection;
  public
   constructor create(const asender: tcustomsqlconnection;
              const amessage: ansistring;
              const aerrormessage: msestring; const aerror: integer);
   property sender: tcustomsqlconnection read fsender;
   property error: integer read ferror;
   property errormessage: msestring read ferrormessage;
 end;
 
 tdbcontroller = class(tactivatorcontroller)
  private
   fdatabasename: filenamety;
//   fintf: idbcontroller;
   foptions: databaseoptionsty;
//   factioncount: integer;
//   factionwait: boolean;   
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
 tcustomsqlconnection = class(TmDatabase,idbcontroller,iactivatorclient)
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
//   frecnos: integerarty;
   ftransactionwrite: tsqltransaction;
   procedure setcontroller(const avalue: tdbcontroller);
   procedure settransaction(const avalue : tsqltransaction);
   procedure settransactionwrite(const avalue: tsqltransaction);
   procedure GetDBInfo(const SchemaType : TSchemaType;
             const SchemaObjectName, ReturnField : string;             
             out list: msestringarty);
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
                                 overload; virtual; abstract;
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
   procedure GetTableNames(out List: msestringarty;
                       SystemTables: Boolean = false); virtual;
   procedure GetProcedureNames(out List: msestringarty); virtual;
   procedure GetFieldNames(const TableName: string;
               out List: msestringarty); virtual;
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
    procedure disconnect(const sender: itransactionclient; 
                                              const auxclients: integer);
    procedure finalizetransaction; override;
    procedure doendtransaction(const aaction: tcommitrollbackaction);
    procedure dobeforestop;
    procedure doafterstop;
    procedure checkpendingaction;
    procedure savepointevent(const akind: savepointeventkindty; const alevel: integer);
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
   fonbeforeexecute: sqlstatementeventty;
   fonafterexecute: sqlstatementeventty;
   fonerror: sqlstatementerroreventty;
   procedure setsql(const avalue: tsqlstringlist);
   procedure setdatabase1(const avalue: tcustomsqlconnection);
   procedure setparams(const avalue: tmseparams);
   procedure settransaction1(const avalue: tsqltransaction);
   procedure setoptions(const avalue: sqlstatementoptionsty);
    //itransactionclient
   function getname: string;
   function getactive: boolean; virtual;
   procedure settransaction(const avalue: tmdbtransaction);
   procedure settransactionwrite(const avalue: tmdbtransaction);
   procedure checkbrowsemode;
   procedure refreshtransaction;
   procedure savepointevent(const sender: tmdbtransaction;
                    const akind: savepointeventkindty; const alevel: integer);
   //idbclient
   procedure setdatabase(const avalue: tmdatabase);
   function gettransaction: tmdbtransaction;
   function getrecno: integer;
   procedure setrecno(value: integer);
   procedure disablecontrols;
   procedure enablecontrols;
   function moveby(distance: longint): longint;
//   procedure readoptionsold(areader: treader);
//   procedure readoptions(areader: treader);
//   procedure writeoptions(awriter: twriter);
  protected
   fsql: tsqlstringlist;
   fdatabase: tcustomsqlconnection;
   ftransaction: tsqltransaction;
   fparams: tmseparams;
   foptions: sqlstatementoptionsty;
//   procedure defineproperties(afiler: tfiler); override;
   
   procedure setactive(avalue: boolean); virtual;
   procedure execute; virtual; abstract;
   procedure dobeforeexecute(const adatabase: tcustomsqlconnection;
                              const atransaction: tsqltransaction);
   procedure doafterexecute(const adatabase: tcustomsqlconnection;
                             const atransaction: tsqltransaction);
   procedure doerror(const adatabase: tcustomsqlconnection;
              const atransaction: tsqltransaction; const e: exception;
              var handled: boolean);
   procedure dosqlchange(const sender: tobject); virtual;
   property onbeforeexecute: sqlstatementeventty read fonbeforeexecute 
                                                     write fonbeforeexecute;
   property onafterexecute: sqlstatementeventty read fonafterexecute 
                                                     write fonafterexecute;
   property onerror: sqlstatementerroreventty read fonerror write fonerror;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean;
   property params : tmseparams read fparams write setparams;
   property sql: tsqlstringlist read fsql write setsql;
   property database: tcustomsqlconnection read fdatabase write setdatabase1;
   property transaction: tsqltransaction read ftransaction write settransaction1;
                  //can be nil
   property options: sqlstatementoptionsty read foptions 
                                 write setoptions {stored false} default [] ;
 end;

 msesqlscripteventty = procedure(const sender: tmsesqlscript) of object;
   
 tmsesqlscript = class(tcustomsqlstatement)
  private
   fstatementnr: integer;
   fstatementcount: integer;
//   fstatements: msestringarty;
   fonbeforestatement: msesqlscripteventty;
   fonafterstatement: msesqlscripteventty;
   fterm: msechar;
   fcharescapement: boolean;
  protected
   procedure execute; overload; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure execute(adatabase: tcustomsqlconnection = nil;
                        atransaction: tsqltransaction = nil); overload;
   property statementnr: integer read fstatementnr; //null based
   property statementcount: integer read fstatementcount;
//   property fstatements: msestringarty read fstatements;
  published
   property term: msechar read fterm write fterm default ';';
   property charescapement: boolean read fcharescapement 
                                      write fcharescapement default false;
   property onbeforestatement: msesqlscripteventty read fonbeforestatement
                                                       write fonbeforestatement;
   property onafterstatement: msesqlscripteventty read fonafterstatement
                                                       write fonafterstatement;
   property params;
   property sql;
   property database;
   property transaction;
                  //can be nil
   property options;
   property onbeforeexecute;
   property onafterexecute;
   property onerror;
 end;

 tcursorsqlstatement = class(tcustomsqlstatement)
  private
  protected
   fcursor: tsqlcursor;
   fstatementtype: tstatementtype;
   procedure internalclose;
   function getactive: boolean; override;
   procedure setactive(avalue: boolean); override;
   procedure dosqlchange(const sender: tobject); override;
   function isprepared: boolean;
   procedure prepare; virtual;
   procedure checkautocommit; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure unprepare; virtual;
   procedure execute; overload; override;
   procedure execute(const aparams: array of variant); overload;
   function rowsaffected: integer;
                  //-1 if not supported
   property statementtype : tstatementtype read fstatementtype 
                 write fstatementtype default stnone;
 end;

 tsqlstatement = class(tcursorsqlstatement)
  published
   property params;
   property sql;
   property database;
   property transaction;
                  //can be nil
   property options;
   property statementtype;
   property onbeforeexecute;
   property onafterexecute;
   property onerror;
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
 
 isqlclient = interface(idatabaseclient)
  function getsqltransaction: tsqltransaction;
  procedure setsqltransaction(const avalue: tsqltransaction);
  function getsqltransactionwrite: tsqltransaction;
  procedure setsqltransactionwrite(const avalue: tsqltransaction);
  procedure unprepare;
 end;
 
procedure updateparams(const aparams: tmseparams; const autf8: boolean);
procedure doexecute(const aparams: tmseparams; const atransaction: tmdbtransaction;
                    const acursor: tsqlcursor; adatabase: tmdatabase;
                    const autf8: boolean);
procedure checksqlconnection(const aname: ansistring; const avalue: tmdatabase);
procedure checksqltransaction(const aname: ansistring; const avalue: tmdbtransaction);
procedure dosetsqldatabase(const sender: isqlclient; const avalue: tmdatabase;
                 var acursor: tsqlcursor; var dest: tmdatabase);

function splitsql(const asql: msestring; const term: msechar = ';';
                  const charescapement: boolean = false): msestringarty;

//function splitsqlstatements(const asqltext: msestring): msestringarty;

implementation
uses 
 {$ifdef FPC}dbconst{$else}dbconst_del{$endif},strutils,msereal,msestream,
 msebits,msefileutils,mseformatstr,typinfo,msesysutils,msesqlresult;
type
 tdataset1 = class(tdataset);
 tmdatabase1 = class(tmdatabase);

procedure updateparams(const aparams: tmseparams; const autf8: boolean);
var
 int1: integer;
begin
 if aparams <> nil then begin
  aparams.isutf8:= autf8;
  for int1:= 0 to aparams.count - 1 do begin
   with aparams[int1] do begin
    if not isnull and (datatype in [ftFloat,ftcurrency,ftDate,ftTime,ftDateTime]) and
                               (asfloat = emptyreal) then begin
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

//var
// po3: pmsechar;
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
// po3: pdoublemsestringty;
begin
 result:= '';
 if count > 0 then begin
  normalizering;
  int2:= 0;
  po1:= pointer(fdatapo);
  for int1:= 0 to count - 1 do begin
   inc(int2,length(pmsestringaty(po1)^[int1]));
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
//   po3:= fmacros.datapo;
   for int1:= 0 to high(ar1) do begin
    with fmacros[int1] do begin
     ar1[int1].name:= name;
     if active then begin
      ar1[int1].value:= value.text;
     end
     else begin
      ar1[int1].value:= '';
     end;
//     value:= po3^.b;
//     name:= po3^.a;
//     value:= po3^.b;
    end;
//    inc(po3);
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
{
procedure tsqlstringlist.writestrings(writer: twriter);
begin
 //dummy
end;
}
procedure tsqlstringlist.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('Strings',{$ifdef FPC}@{$endif}readstrings,
                                                nil{@writestrings},false);
end;

procedure tsqlstringlist.setmacros(const avalue: tmacroproperty);
begin
 fmacros.assign(avalue);
end;

procedure tsqlstringlist.assign(source: tpersistent);
begin
 beginupdate;
 try
  inherited;
  if source is tsqlstringlist then begin
   fmacros.assign(tsqlstringlist(source).macros);
  end;
 finally
  endupdate;
 end;
end;

{ tdbcontroller }

constructor tdbcontroller.create(const aowner: tmdatabase; const aintf: idbcontroller);
begin
// fintf:= aintf;
 inherited create(aowner,aintf);
end;

procedure tdbcontroller.setowneractive(const avalue: boolean);
//var
// bo1: boolean;
begin
 idbcontroller(fintf).setinheritedconnected(avalue);
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
  foptions:= databaseoptionsty(setsinglebit(
  {$ifdef FPC}longword{$else}byte{$endif}(avalue),
    {$ifdef FPC}longword{$else}byte{$endif}(foptions),
    {$ifdef FPC}longword{$else}byte{$endif}(mask)));
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
    if (S=StatementTokens[t]) then begin
     result:= t;
     Exit;
    end;
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
 bo1,bo2: boolean; 
 int1: integer;
// str1: ansistring;
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
   if params1 <> nil then begin
    bo2:= params1.isutf8;
    params1.isutf8:= aisutf8;
   end;
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
    if params1 <> nil then begin
     params1.isutf8:= bo2;
    end;
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

procedure tcustomsqlconnection.GetDBInfo(const SchemaType: TSchemaType; 
            const SchemaObjectName, ReturnField : string;
            out list: msestringarty);
var 
 res: tsqlresult;
 col1: tdbcol;
 int1: integer;
begin
 if not assigned(Transaction) then begin
  DatabaseError(SErrConnTransactionnSet);
 end;
 res:= tsqlresult.create(nil);
 try
  with res do begin
   database:= Self;
   sql.text:= GetSchemaInfoSQL(SchemaType, SchemaObjectName, '');
   active:= true;
   col1:= cols.colbyname(returnfield);
   if rowsreturned >= 0 then begin
    setlength(list,rowsreturned);
   end
   else begin
    list:= nil;
   end;
   int1:= 0;
   while not eof do begin
    if high(list) < int1 then begin
     setlength(list,2*high(list)+18);
    end;
    list[int1]:= col1.asmsestring;
    inc(int1);
    next;
   end;
  end;
  setlength(list,int1);
 finally
  res.free;
 end;
end;

(*
procedure tcustomsqlconnection.GetDBInfo(const SchemaType : TSchemaType; 
            const SchemaObjectName, ReturnField : string; List: TStrings);

var 
 qry: TSQLQuery;

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
*)

procedure tcustomsqlconnection.GetTableNames(out List: msestringarty;
                                                          SystemTables: Boolean);
begin
  if not systemtables then GetDBInfo(stTables,'','table_name',List)
    else GetDBInfo(stSysTables,'','table_name',List);
end;

procedure tcustomsqlconnection.GetProcedureNames(out List: msestringarty);
begin
  GetDBInfo(stProcedures,'','proc_name',List);
end;

procedure tcustomsqlconnection.GetFieldNames(const TableName: string;
                                                   out List: msestringarty);
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
     
function tcustomsqlconnection.GetSchemaInfoSQL( SchemaType : TSchemaType;
            SchemaObjectName, SchemaPattern : string) : string;

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
//var
// int1: integer;
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
 fsavepointlevel:= -1;
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

procedure tsqltransaction.doendtransaction(
                         const aaction: tcommitrollbackaction);
begin
 case aaction of
  cacommit: commit;
  cacommitretaining: commitretaining;
  carollbackretaining: rollbackretaining;
  else rollback;        //canone,carollback
 end;
end;

procedure tsqltransaction.endtransaction;

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
   savepointevent(spek_committrans,0);
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
 end
 else begin
  savepointevent(spek_committrans,0);
 end;
 fsavepointlevel:= -1;
 dofinish;
 result:= true;
end;

function TSQLTransaction.Commit(const checksavepoint: boolean = true): boolean;
//var
// bo1: boolean;
begin
 result:= true;
 if active then begin
  if checksavepoint and (fsavepointlevel >= 0) then begin
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
  if checksavepoint and (fsavepointlevel >= 0) then begin
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
  savepointevent(spek_rollbacktrans,0);
  closedatasets;
  try
   if not (tao_fake in foptions) then begin
    tcustomsqlconnection(database).RollBack(FTrans);
   end;
  finally
   fsavepointlevel:= -1;
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
   savepointevent(spek_rollbacktrans,0);
  finally
   fsavepointlevel:= -1;
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

procedure tsqltransaction.disconnect(const sender: itransactionclient;
                                     const auxclients: integer);
//var
// int1: integer;
// intf1: itransactionclient;
// k1: tupdatekind;
begin
{
 int1:= 1;
 if (self = sender.getwritetransaction) then begin
  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   if sender.fapplyqueries[k1] <> nil then begin
    inc(int1);
   end;
  end;
}
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
// end;
 if high(fdatasets) > auxclients then begin 
  databaseerror('Offline mode needs exclusive transaction.',
                                       sender.getcomponentinstance);
 end;
// intf1:= itransactionclient(sender);
 removeitem(pointerarty(fdatasets),pointer(sender));
 try
  active:= false;
 finally
  insertitem(pointerarty(fdatasets),0,pointer(sender));
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
 inc(fsavepointlevel);
 result:= fsavepointlevel;
 mstr1:= 'sp'+inttostrmse(result);
 database.executedirect('SAVEPOINT '+mstr1+';',self,nil,false,true);
 savepointevent(spek_begin,result);
end;

procedure tsqltransaction.checkpendingaction;
var
 act1: tcommitrollbackaction;
 bo1: boolean;
begin
 if (fpendingaction <> canone) and (fsavepointlevel < 0) and active then begin
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
  alevel:= fsavepointlevel;
 end;
 if alevel >= 0 then begin
  database.executedirect('ROLLBACK TO '+'sp'+inttostrmse(alevel)+';',
                                                     self,nil,false,true); 
  fsavepointlevel:= alevel-1;
  savepointevent(spek_rollback,alevel);
  checkpendingaction;
 end;
end;

procedure TSQLTransaction.savepointrelease;
begin
 checkactive;
 if fsavepointlevel >= 0 then begin
  database.executedirect('RELEASE SAVEPOINT '+'sp'+
             inttostrmse(fsavepointlevel)+';',self,nil,false,true); 
  dec(fsavepointlevel);
  savepointevent(spek_release,fsavepointlevel+1);
  checkpendingaction;
 end;
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

procedure TSQLTransaction.savepointevent(const akind: savepointeventkindty;
                                                        const alevel: integer);
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
   fdatasets[int1].savepointevent(self,akind,alevel);
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
   fwritedatasets[int1].savepointevent(self,akind,alevel);
  end;
  dec(int1);
 end;
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
 fsql.onchange:= {$ifdef FPC}@{$endif}dosqlchange;
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
           {$ifdef FPC}longword{$else}byte{$endif}(avalue),
           {$ifdef FPC}longword{$else}byte{$endif}(foptions),
           {$ifdef FPC}longword{$else}byte{$endif}(mask)));
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

procedure tcustomsqlstatement.savepointevent(const sender: tmdbtransaction;
               const akind: savepointeventkindty; const alevel: integer);
begin
 //dummy
end;
{
procedure tcustomsqlstatement.readoptionsold(areader: treader);
begin
 if self is tsqlresult then begin
  if areader.readset(typeinfo(sqlresultoptionty)) <> 0 then begin
   options:= [sso_utf8];
  end
  else begin
   options:= sqlstatementoptionsty(areader.readset(
                               typeinfo(sqlstatementoptionty)));
  end;
 end;
end;

procedure tcustomsqlstatement.readoptions(areader: treader);
begin
 options:= sqlstatementoptionsty(areader.readset(
                               typeinfo(sqlstatementoptionty)));
end;

procedure tcustomsqlstatement.writeoptions(awriter: twriter);
begin
 awriter.writeset(integer(options),typeinfo(sqlstatementoptionty));
end;

procedure tcustomsqlstatement.defineproperties(afiler: tfiler);
begin
 inherited;
 afiler.defineproperty('options',@readoptionsold,nil,false);
 afiler.defineproperty('optionsnew',@readoptions,@writeoptions,foptions <> []);
end;
}

{ tmsesqlscript }

constructor tmsesqlscript.create(aowner: tcomponent);
begin
 fterm:= ';';
 inherited;
end;

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

procedure tmsesqlscript.execute;
begin
 execute(nil,nil);
end;

{ tcursorsqlstatement }

constructor tcursorsqlstatement.create(aowner: tcomponent);
begin
 inherited;
end;

destructor tcursorsqlstatement.destroy;
begin
 internalclose;
// setactive(false);
 inherited;
end;

procedure tcursorsqlstatement.internalclose;
begin
 unprepare;
 if fcursor <> nil then begin
  fdatabase.deallocatecursorhandle(fcursor);
 end;
end;

procedure tcursorsqlstatement.dosqlchange(const sender: tobject);
begin
 unprepare;
 inherited;
end;

procedure tcursorsqlstatement.prepare;
var
 mstr1: msestring;
begin
 if (fcursor = nil) or not fcursor.fprepared then begin
  checkdatabase(name,fdatabase);
  checktransaction(name,ftransaction);
  mstr1:= trim(fsql.text);
  if mstr1 = '' then begin
   raise edatabaseerror.create(name+': Empty query.');
  end;
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
   fdatabase.PrepareStatement(Fcursor,ftransaction,mstr1,FParams);
//   fcursor.fprepared:= true;
  end;
 end;
end;

function tcursorsqlstatement.isprepared: boolean;
begin
 result:= (fcursor <> nil) and fcursor.fprepared;
end;

procedure tcursorsqlstatement.unprepare;
begin
 if (fcursor <> nil) and fcursor.fprepared then begin
  fdatabase.unpreparestatement(fcursor);
  //fcursor.fprepared:= false;
 end;
end;

procedure tcursorsqlstatement.checkautocommit;
begin
 if not (csdesigning in componentstate) then begin
  if sso_autocommit in foptions then begin
   ftransaction.commit;
  end
  else begin
   if sso_autocommitret in foptions then begin
    ftransaction.commitretaining;
   end;
  end;
 end;
end;

procedure tcursorsqlstatement.execute;
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
  checkautocommit;
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

function tcursorsqlstatement.getactive: boolean;
begin
 result:= fcursor <> nil;
end;

procedure tcursorsqlstatement.setactive(avalue: boolean);
begin
 if not avalue then begin
  internalclose;
 end;
end;

procedure tcursorsqlstatement.execute(const aparams: array of variant);
var
 int1: integer;
begin
 for int1:= 0 to high(aparams) do begin
  fparams[int1].value:= aparams[int1];
 end;
 execute;
end;

function tcursorsqlstatement.rowsaffected: integer;
begin
 if fcursor = nil then begin
  result:= -1;
 end
 else begin
  result:= fcursor.frowsaffected;
 end;
end;

{ econnectionerror }

constructor econnectionerror.create(const asender: tcustomsqlconnection; 
   const amessage: ansistring; const aerrormessage: msestring;
    const aerror: integer);
begin
 fsender:= sender;
 ferror:= aerror;
 ferrormessage:= aerrormessage;
 inherited create(asender.name+': '+amessage);
end;

{ tsqlmacroitem }

constructor tsqlmacroitem.create(aowner: tobject);
begin
 factive:= true;
 fvalue:= tmacrostringlist.create(tsqlstringlist(aowner));
 inherited;
end;

destructor tsqlmacroitem.destroy;
begin
 fvalue.free;
 inherited;
end;

procedure tsqlmacroitem.setvalue(const avalue: tmacrostringlist);
begin
 fvalue.assign(avalue);
end;

procedure tsqlmacroitem.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  tsqlstringlist(fowner).dochange;
 end;
end;

procedure tsqlmacroitem.assign(source: tpersistent);
begin
 if source is tsqlmacroitem then begin
  with tsqlmacroitem(source) do begin
   self.name:= name;
   self.value:= value;
   self.active:= active;
  end;
 end;
end;

{ tmacroproperty }

constructor tmacroproperty.create(const aowner: tsqlstringlist);
begin
 fowner:= aowner;
 foptions:= [mao_caseinsensitive];
 inherited create(aowner,tsqlmacroitem);
end;

procedure tmacroproperty.dochange(const aindex: integer);
begin
 inherited;
 tsqlstringlist(fowner).dochange;
end;

function tmacroproperty.getitems(const aindex: integer): tsqlmacroitem;
begin
 result:= tsqlmacroitem(inherited getitems(aindex));
end;

procedure tmacroproperty.setitems(const aindex: integer;
               const avalue: tsqlmacroitem);
begin
 inherited;
end;

class function tmacroproperty.getitemclasstype: persistentclassty;
begin
 result:= tsqlmacroitem;
end;

function tmacroproperty.itembyname(const aname: msestring): tsqlmacroitem;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if tsqlmacroitem(fitems[int1]).name = aname then begin
   result:= tsqlmacroitem(fitems[int1]);
   break;
  end;
 end;
 if result = nil then begin
  raise exception.create('Macro "'+aname+'" not found.');
 end;
end;

function tmacroproperty.itembynames(const anames: array of msestring): tsqlmacroitem;
var
 int1: integer;
begin
 result:= nil;
 if length(anames) > 0 then begin
  result:= itembyname(anames[0]);
  for int1:= 1 to high(anames) do begin
   result:= result.value.macros.itembyname(anames[int1]);
  end;
 end;
end;

{ tmacrostringlist }

constructor tmacrostringlist.create(const aowner: tsqlstringlist);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tmacrostringlist.dochange;
begin
 inherited;
 fowner.dochange;
end;

end.
