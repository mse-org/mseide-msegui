{******************************************************************************
 *                                                                            *
 *  (c) 2005 Hexis BV                                                         *
 *                                                                            *
 *  File:        odbcconn.pas                                                 *
 *  Author:      Bram Kuijvenhoven (bkuijvenhoven@eljakim.nl)                 *
 *  Description: ODBC SQLDB unit                                              *
 *  License:     (modified) LGPL                                              *
 *                                                                            *
 *  Modified 2006-2013 by Martin Schreiber                                    *
 ******************************************************************************}

unit modbcconn;

{$ifdef FPC}{$mode objfpc}{$H+}{$endif}

interface

uses
 classes,mclasses,SysUtils, msqldb, mdb, odbcsqldyn,msetypes,msedb,msestrings;

type

  // forward declarations
  TODBCConnection = class;

  { TODBCCursor }

  TODBCCursor = class(TSQLCursor)
  protected
   fconnection: todbcconnection;
   ffieldnames: stringarty;
   FSTMTHandle:SQLHSTMT; // ODBC Statement Handle
   FQuery:string;        // last prepared query, with :ParamName converted to ?
   FParamIndex:TParamBinding; // maps the i-th parameter in the query to the TParams passed to PrepareStatement
   FParamBuf:array of pointer; // buffers that can be used to bind the i-th parameter in the query
//    FBlobStreams:TList;   // list of Blob TMemoryStreams stored in field buffers (we need this currently as we can't hook into the freeing of TBufDataset buffers)
   fcurrentblobbuffer: ansistring;
  public
   constructor Create(const aowner: icursorclient; const aname: ansistring;
                                      const Connection:TODBCConnection);
   destructor Destroy; override;
   procedure close; override;
  end;

  { TODBCHandle } // this name is a bit confusing, but follows the standards for naming classes in sqldb

  TODBCHandle = class(TSQLHandle)
  protected
  end;

  { TODBCEnvironment }

  TODBCEnvironment = class
  private
   finitialized: boolean;
  protected
    FENVHandle:SQLHENV; // ODBC Environment Handle
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TODBCConnection }

  TODBCConnection = class(TSQLConnection,iblobconnection)
  private
    FDriver: string;
    FEnvironment:TODBCEnvironment;
    FDBCHandle:SQLHDBC; // ODBC Connection Handle
    FFileDSN: string;

    procedure SetParameters(ODBCCursor:TODBCCursor; AParams:TmseParams);
    procedure FreeParamBuffers(ODBCCursor:TODBCCursor);
  protected
   procedure ODBCCheckResult(
                           LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT;
                           AHandle: SQLHANDLE; ErrorMsg: string); overload;

   procedure ODBCCheckResult(
                       LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT;
                                    AHandle: SQLHANDLE; ErrorMsg: string;
                                    const values: array of const); overload;
    // Overrides from TSQLConnection
    function GetHandle:pointer; override;
    // - Connect/disconnect
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    // - Handle (de)allocation
    function AllocateTransactionHandle:TSQLHandle; override;
    // - Statement handling

    // - Transaction handling
    function GetTransactionHandle(trans:TSQLHandle):pointer; override;
    function StartDBTransaction(const trans:TSQLHandle; 
                 const AParams: tstringlist):boolean; override;
    function Commit(trans:TSQLHandle):boolean; override;
    function Rollback(trans:TSQLHandle):boolean; override;
    procedure internalCommitRetaining(trans:TSQLHandle); override;
    procedure internalRollbackRetaining(trans:TSQLHandle); override;
    // - Statement execution
    procedure updaterowcount(const acursor: todbccursor);
    procedure internalExecute(const cursor:TSQLCursor; 
             const ATransaction:TSQLTransaction; const AParams:TmseParams;
             const autf8: boolean); override;
    procedure internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string); override;


    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream; override;
    // - UpdateIndexDefs
    procedure UpdateIndexDefs(var IndexDefs:TIndexDefs;
                          const aTableName:string); override;
    // - Schema info
    function GetSchemaInfoSQL(SchemaType:TSchemaType; SchemaObjectName, SchemaObjectPattern:string):string; override;

    // Internal utility functions
    function CreateConnectionString:string;
    function getblobdatasize: integer; override;

          //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
             const tablename: string; const acursor: tsqlcursor;
             const adata: pointer; const alength: integer;
             const afield: tfield; const aparam: tparam;
             out newid: string);
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                                   const aparam: tparam);
   function blobscached: boolean;
  public
   function AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor; override;
   procedure DeAllocateCursorHandle(var cursor:TSQLCursor); override;
   procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
   procedure UnPrepareStatement(cursor:TSQLCursor); override;
    // - Result retrieving
   procedure AddFieldDefs(const cursor:TSQLCursor; 
                              const FieldDefs:TFieldDefs); override;
   function Fetch(cursor:TSQLCursor):boolean; override;
   function loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    procedure FreeFldBuffers(cursor:TSQLCursor); override;
    property Environment:TODBCEnvironment read FEnvironment;
  published
    property Driver:string read FDriver write FDriver;    // will be passed as DRIVER connection parameter
    property FileDSN:string read FFileDSN write FFileDSN; // will be passed as FILEDSN parameter
    // Redeclare properties from TSQLConnection
    property Password;     // will be passed as PWD connection parameter
    property Transaction;
    property UserName;     // will be passed as UID connection parameter
    property CharSet;
    property HostName;     // ignored
    // Redeclare properties from TmDatabase
    property Connected;
    property Role;
    property DatabaseName; // will be passed as DSN connection parameter
    property KeepConnection;
//    property LoginPrompt;  // if true, ODBC drivers might prompt for more details that are not in the connection string
    property Params;       // will be added to connection string
//    property OnLogin;
  end;

  EODBCException = class(Exception)
    // currently empty; perhaps we can add fields here later that describe the error instead of one simple message string
  end;

implementation

uses
  Math, {$ifdef FPC}DBConst{$else}dbconst_del{$endif},msedatabase;
  
{$define ODBCVER3}

(* odbc type nums
internal enum SQL_TYPE : short
        {
                BIGINT				= (-5),
                BINARY				= (-2),
                BIT				= (-7),
                CHAR				= 1,
                DATE				= 9,
                DECIMAL                         = 3,
                DOUBLE				= 8,
                GUID				= (-11),
                INTEGER				= 4,
                INTERVAL_DAY			= (100 + 3),
                INTERVAL_DAY_TO_HOUR		= (100 + 8),
                INTERVAL_DAY_TO_MINUTE		= (100 + 9),
                INTERVAL_DAY_TO_SECOND		= (100 + 10),
                INTERVAL_HOUR			= (100 + 4),
                INTERVAL_HOUR_TO_MINUTE		= (100 + 11),
                INTERVAL_HOUR_TO_SECOND		= (100 + 12),
                INTERVAL_MINUTE			= (100 + 5),
                INTERVAL_MINUTE_TO_SECOND	= (100 + 13),
                INTERVAL_MONTH			= (100 + 2),
                INTERVAL_SECOND			= (100 + 6),
                INTERVAL_YEAR			= (100 + 1),
                INTERVAL_YEAR_TO_MONTH		= (100 + 7),
                LONGVARBINARY                   = (-4),
                LONGVARCHAR                     = (-1),
                NUMERIC                         = 2,
                REAL				= 7,
                SMALLINT			= 5,
                TIME				= 10,
                TIMESTAMP			= 11,
                TINYINT				= (-6),
                TYPE_DATE			= 91,
                TYPE_TIME			= 92,
                TYPE_TIMESTAMP			= 93,
                VARBINARY                       = (-3),
                VARCHAR                         = 12,
                WCHAR				= (-8),
                WLONGVARCHAR                    = (-10),
                WVARCHAR                        = (-9),
                UNASSIGNED                      = Int16.MaxValue
        }

        internal enum SQL_C_TYPE : short
        {
                BINARY				= (-2),
                BIT				= (-7),
                BOOKMARK			= (4 +(-22)),
                CHAR				= 1,
                DATE				= 9,
                DEFAULT				= 99,
                DOUBLE				= 8,
                FLOAT				= 7,
                GUID				= (-11),
                INTERVAL_DAY			= (100 + 3),
                INTERVAL_DAY_TO_HOUR		= (100 + 8),
                INTERVAL_DAY_TO_MINUTE		= (100 + 9),
                INTERVAL_DAY_TO_SECOND		= (100 + 10),
                INTERVAL_HOUR			= (100 + 4),
                INTERVAL_HOUR_TO_MINUTE	        = (100 + 11),
                INTERVAL_HOUR_TO_SECOND	        = (100 + 12),
                INTERVAL_MINUTE			= (100 + 5),
                INTERVAL_MINUTE_TO_SECOND	= (100 + 13),
                INTERVAL_MONTH			= (100 + 2),
                INTERVAL_SECOND			= (100 + 6),
                INTERVAL_YEAR			= (100 + 1),
                INTERVAL_YEAR_TO_MONTH		= (100 + 7),
                LONG				= 4,
                NUMERIC				= 2,
                SBIGINT				= ((-5)+(-20)),
                SHORT				= 5,
                SLONG				= (4 +(-20)),
                SSHORT				= (5 +(-20)),
                STINYINT			= ((-6)+(-20)),
                TCHAR				= 1,
                TIME				= 10,
                TIMESTAMP			= 11,
                TINYINT				= (-6),
                TYPE_DATE			= 91,
                TYPE_TIME			= 92,
                TYPE_TIMESTAMP			= 93,
                UBIGINT				= ((-5)+(-22)),
                ULONG				= (4 +(-22)),
                USHORT				= (5 +(-22)),
                UTINYINT			= ((-6)+(-22)),
                WCHAR				= (-8),
                UNASSIGNED                      = Int16.MaxValue
        }
}
*)

const

{$ifdef ODBCVER3}
  SQL_C_WCHAR = SQL_WCHAR;
{$endif}

 blobidsize = sizeof(integer);
 maxstrlen = 3000;
 maxprecision = 18;
var
 DefaultEnvironment:TODBCEnvironment = nil;
//  ODBCLoadCount:integer = 0; // ODBC is loaded when > 0; modified by TODBCEnvironment.Create/Destroy

{ Generic ODBC helper functions }

function ODBCSucces(const Res:SQLRETURN):boolean;
begin
  Result:=(Res=SQL_SUCCESS) or (Res=SQL_SUCCESS_WITH_INFO) or 
             (res = SQL_NO_DATA);
end;

function ODBCResultToStr(Res:SQLRETURN):string;
begin
  case Res of
    SQL_SUCCESS:          Result:='SQL_SUCCESS';
    SQL_SUCCESS_WITH_INFO:Result:='SQL_SUCCESS_WITH_INFO';
    SQL_ERROR:            Result:='SQL_ERROR';
    SQL_INVALID_HANDLE:   Result:='SQL_INVALID_HANDLE';
    SQL_NO_DATA:          Result:='SQL_NO_DATA';
    SQL_NEED_DATA:        Result:='SQL_NEED_DATA';
    SQL_STILL_EXECUTING:  Result:='SQL_STILL_EXECUTING';
  else
    Result:='';
  end;
end;

procedure todbcconnection.ODBCCheckResult(
                           LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT;
                           AHandle: SQLHANDLE; ErrorMsg: string);

  // check return value from SQLGetDiagField/Rec function itself
  procedure Check(const Res:SQLRETURN);
  begin
    case Res of
      SQL_INVALID_HANDLE:
        raise EODBCException.Create('Invalid handle passed to SQLGetDiagRec/Field');
      SQL_ERROR:
        raise EODBCException.Create('An invalid parameter was passed to SQLGetDiagRec/Field');
      SQL_NO_DATA:
        raise EODBCException.Create('A too large RecNumber was passed to SQLGetDiagRec/Field');
    end;
  end;

var
  NativeError: SQLINTEGER;
  reccount: sqlinteger;
  TextLength:SQLSMALLINT;
  Res:SQLRETURN;
  SqlState,MessageText,TotalMessage:string;
  RecNumber:SQLSMALLINT;
  firstmessage: string;
  firsterror: integer;
begin
  // check result
  if ODBCSucces(LastReturnCode) then begin
    Exit; // no error; all is ok
  end;

  // build TotalMessage for exception to throw
  TotalMessage:=Format('%s ODBC error details:',[ErrorMsg]);
  // retrieve status records
  check(sqlgetdiagfield(handletype,ahandle,0,SQL_DIAG_NUMBER,@reccount,
                                  sizeof(reccount),textlength));
             //unixODBC crashes with too big rec number

  SetLength(SqlState,5); // SqlState buffer
  firsterror:= 0;
  for RecNumber:=1 to reccount do begin
    // dummy call to get correct TextLength
    Res:=SQLGetDiagRec(HandleType,AHandle,RecNumber,@(SqlState[1]),
                                          NativeError,nil,0,TextLength);
    if Res=SQL_NO_DATA then begin
      Break; // no more status records
    end;
    Check(Res);
    if TextLength>0 then begin
      // if TextLength=0 we don't need another call;
      // also our string buffer would not point to a #0, but be a nil pointer
      // allocate large enough buffer
      SetLength(MessageText,4*TextLength); 
           //reserve for multi-byte-encodings, ODBC bug?
           // note: ansistrings of Length>0 are always terminated by a #0 character, so this is safe
      // actual call
      check(SQLGetDiagRec(HandleType,AHandle,RecNumber,@(SqlState[1]),
              NativeError,@(MessageText[1]),Length(MessageText)+1,TextLength));
    end
    else begin
     messagetext:= '';
    end;
    if firsterror = 0 then begin
     firsterror:= nativeerror;
     firstmessage:= strpas(pchar(messagetext));
    end;
    // add to TotalMessage
    TotalMessage:=TotalMessage + 
      Format(' Record %d: SqlState: %s; NativeError: %d; Message: %s;',
                            [RecNumber,SqlState,NativeError,
                                strpas(pchar(MessageText))]); 
       //string termination by #0, textlength seems to be unreliable
  end;
  // raise error
//  raise EODBCException.Create(TotalMessage);
  raise econnectionerror.create(self,connectionmessage(pchar(totalmessage)),
                              firstmessage,firsterror);
end;

procedure todbcconnection.ODBCCheckResult(
                       LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT;
                                    AHandle: SQLHANDLE; ErrorMsg: string;
                                    const values: array of const);
begin
 if not ODBCSucces(LastReturnCode) then begin
  odbccheckresult(lastreturncode,handletype,ahandle,format(errormsg,values));
 end;
end;

{ TODBCConnection }

// Creates a connection string using the current value of the fields
function TODBCConnection.CreateConnectionString: string;

  // encloses a param value with braces if necessary, i.e. when any of the characters []{}(),;?*=!@ is in the value
  function EscapeParamValue(const s:string):string;
  var
    NeedEscape:boolean;
    i:integer;
  begin
    NeedEscape:=false;
    for i:=1 to Length(s) do
      if s[i] in ['[',']','{','}','(',')',',','*','=','!','@'] then
      begin
        NeedEscape:=true;
        Break;
      end;
    if NeedEscape then
      Result:='{'+s+'}'
    else
      Result:=s;
  end;

var
  i: Integer;
  Param: string;
  EqualSignPos:integer;
begin
  Result:='';
  if charset <> '' then begin
   result:= result + 'CHARSET='+charset+';';
  end;
  if DatabaseName<>'' then Result:=Result + 'DSN='+EscapeParamValue(DatabaseName)+';';
  if Driver      <>'' then Result:=Result + 'DRIVER='+EscapeParamValue(Driver)+';';
  if UserName    <>'' then Result:=Result + 'UID='+EscapeParamValue(UserName)+';PWD='+EscapeParamValue(Password)+';';
  if FileDSN     <>'' then Result:=Result + 'FILEDSN='+EscapeParamValue(FileDSN)+'';
  for i:=0 to Params.Count-1 do
  begin
    Param:=Params[i];
    EqualSignPos:=Pos('=',Param);
    if EqualSignPos=0 then
      raise EODBCException.CreateFmt('Invalid parameter in Params[%d]; can''t find a ''='' in ''%s''',[i, Param])
    else if EqualSignPos=1 then
      raise EODBCException.CreateFmt('Invalid parameter in Params[%d]; no identifier before the ''='' in ''%s''',[i, Param])
    else
      Result:=Result + EscapeParamValue(Copy(Param,1,EqualSignPos-1))+'='+EscapeParamValue(Copy(Param,EqualSignPos+1,MaxInt))+';';
  end;
end;

procedure TODBCConnection.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const acursor: tsqlcursor;
               const adata: pointer; const alength: integer;
               const afield: tfield; const aparam: tparam;
               out newid: string);
var
 str1: string;
 int1: integer;
begin
 setlength(str1,alength);
 move(adata^,str1[1],alength);
 if afield.datatype = ftmemo then begin
  aparam.asmemo:= str1;
 end
 else begin
  aparam.asblob:= str1;
 end;
 int1:= acursor.addblobdata(str1);
 setlength(newid,sizeof(int1));
 move(int1,newid[1],sizeof(int1));
end;

procedure TODBCConnection.setupblobdata(const afield: tfield; 
                      const acursor: tsqlcursor; const aparam: tparam);
begin
// acursor.blobfieldtoparam(afield,aparam,afield.datatype = ftmemo);
 acursor.blobfieldtoparam(afield,aparam,false);
end;

function TODBCConnection.getblobdatasize: integer;
begin
 result:= sizeof(integer);
end;

function TODBCConnection.blobscached: boolean;
begin
 result:= true;
end;

procedure TODBCConnection.SetParameters(ODBCCursor: TODBCCursor; AParams: TmseParams);

 procedure bindnum(i: integer; valuetype: SQLSMALLINT; parametertype: SQLSMALLINT;
                   buf: pointer);
 begin
  ODBCCursor.FParamBuf[i]:=Buf;          
  ODBCCheckResult(
    SQLBindParameter(ODBCCursor.FSTMTHandle, // StatementHandle
                     i+1,                    // ParameterNumber
                     SQL_PARAM_INPUT,        // InputOutputType
                     valuetype,              // ValueType
                     parametertype,          // ParameterType
                     1,                      // ColumnSize
                     0,                      // DecimalDigits
                     Buf,                    // ParameterValuePtr
                     0,                      // BufferLength
                     nil),                   // StrLen_or_IndPtr
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not bind parameter %d',[i]
  );
 end;

 procedure bindstr(i: integer; valuetype: SQLSMALLINT; parametertype: SQLSMALLINT;
                         buf: pointer; strlen: sqlinteger; buflen: sqlinteger
                   );
 begin
  psqlinteger(buf)^:= buflen;
  ODBCCursor.FParamBuf[i]:=Buf;
  ODBCCheckResult(
    SQLBindParameter(ODBCCursor.FSTMTHandle, // StatementHandle
                     i+1,                    // ParameterNumber
                     SQL_PARAM_INPUT,        // InputOutputType
                     valuetype,              // ValueType
                     parametertype,          // ParameterType
                     strlen,                 // ColumnSize
                     0,                      // DecimalDigits
                     pchar(buf)+SizeOf(SQLINTEGER), // ParameterValuePtr
                     buflen,                 // BufferLength
                     buf),                   // StrLen_or_IndPtr
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not bind parameter %d',[i]);
 end;

 procedure bindnull(i: integer; valuetype: sqlsmallint; parametertype: sqlsmallint);
 var
  buf: psqllen;
 begin
  getmem(buf,sizeof(sqllen));
  ODBCCursor.FParamBuf[i]:= Buf;
  buf^:= SQL_NULL_DATA;
  ODBCCheckResult(
    SQLBindParameter(ODBCCursor.FSTMTHandle, // StatementHandle
                     i+1,                    // ParameterNumber
                     SQL_PARAM_INPUT,        // InputOutputType
                     valuetype,              // ValueType
                     parametertype,          // ParameterType
                     1,                      // ColumnSize
                     0,                      // DecimalDigits
                     nil,                    // ParameterValuePtr
                     0,                      // BufferLength
                     buf),                   // StrLen_or_IndPtr
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not bind parameter %d',[i]);
 end;
   
var
  ParamIndex:integer;
  Buf:pointer;
  I:integer;
//  IntVal:longint;
//  largeintval: int64;
  StrVal:string;
{$ifdef mswindows}
  wideStrVal: msestring;
  buflen: SQLINTEGER;
{$endif}
//  doubleval: double;
  StrLen{,buflen}: SQLINTEGER;
//  isnull1: boolean;
  datatype1: tfieldtype;

begin
  // Note: it is assumed that AParams is the same as the one passed to PrepareStatement, in the sense that
  //       the parameters have the same order and names

 if Length(ODBCCursor.FParamIndex)>0 then begin
  if not Assigned(AParams) then begin
   raise EODBCException.CreateFmt(
   'The query has parameter markers in it, but no actual parameters were passed',
                              []);
  end;
 end;
 SetLength(ODBCCursor.FParamBuf, Length(ODBCCursor.FParamIndex));
 for i:=0 to High(ODBCCursor.FParamIndex) do begin
  ParamIndex:= ODBCCursor.FParamIndex[i];
  if (ParamIndex<0) or (ParamIndex>=AParams.Count) then begin
   raise EODBCException.CreateFmt(
     'Parameter %d in query does not have a matching parameter set',[i]);
  end;
  with AParams[ParamIndex] do begin
//   isnull1:= isnull;
   datatype1:= datatype;
   case datatype1 of
    ftInteger,ftboolean,ftword,ftsmallint: begin
     if isnull then begin
      bindnull(i,SQL_C_LONG,SQL_INTEGER);
     end
     else begin
      GetMem(buf,sizeof(longint));
      plongint(buf)^:= AsInteger;
      bindnum(i,SQL_C_LONG,SQL_INTEGER,buf);
     end;
    end;
    ftlargeint: begin
     if isnull then begin
      bindnull(i,SQL_C_SBIGINT,SQL_BIGINT);
     end
     else begin
      GetMem(buf,sizeof(int64));
      pint64(buf)^:= Aslargeint;
      bindnum(i,SQL_C_SBIGINT,SQL_BIGINT,buf);
     end;
    end;
    ftfloat,ftcurrency,ftbcd: begin
     if isnull then begin
      bindnull(i,SQL_C_CHAR,SQL_CHAR);
     end
     else begin
      GetMem(buf,sizeof(double));
      pdouble(buf)^:= Asfloat;
      bindnum(i,SQL_C_DOUBLE,SQL_DOUBLE,buf);
     end;
    end;
    fttime,ftdate,ftdatetime: begin
     if isnull then begin
      bindnull(i,SQL_C_TYPE_TIMESTAMP,SQL_TYPE_TIMESTAMP);
     end
     else begin
      GetMem(buf,sizeof(sql_timestamp_struct));
      datetime2timestampstruct(psql_timestamp_struct(buf)^,Asdatetime);
      bindnum(i,SQL_C_TYPE_TIMESTAMP,SQL_TYPE_TIMESTAMP,buf);
     end;
    end;
    ftguid: begin
     if isnull then begin
      bindnull(i,SQL_C_GUID,SQL_GUID);
     end
     else begin
      GetMem(buf,sizeof(tguid));
      pguid(buf)^:= dbstringtoguid(asstring);
      bindnum(i,SQL_C_guid,SQL_guid,buf);
     end;
    end;
    ftblob,ftmemo: begin
     if isnull then begin
      bindnull(i,SQL_C_CHAR,SQL_CHAR);
     end
     else begin
      StrVal:= asstring;
      StrLen:= Length(StrVal);
      GetMem(buf,StrLen+sizeof(sqlinteger));
      Move(StrVal[1],(pchar(buf)+sizeof(sqlinteger))^,StrLen);
      if datatype1 = ftmemo then begin
       bindstr(i,SQL_C_CHAR,SQL_LONGVARCHAR,buf,strlen,strlen)
      end
      else begin
       bindstr(i,SQL_C_BINARY,SQL_LONGVARBINARY,buf,strlen,strlen)
      end;
     end;
    end;
    ftstring,ftfixedchar
         {$ifndef mswindows},ftwidestring,ftfixedwidechar{$endif}: begin
     if isnull then begin
      bindnull(i,SQL_C_CHAR,SQL_CHAR);
     end
     else begin
      StrVal:= AParams.AsdbString(paramindex);
      StrLen:= Length(StrVal);
      GetMem(buf,StrLen+sizeof(sqlinteger));
      Move(StrVal[1],(pchar(buf)+sizeof(sqlinteger))^,StrLen);
      if strlen > maxstrlen then begin
       bindstr(i,SQL_C_CHAR,SQL_LONGVARCHAR,buf,strlen,strlen)
      end
      else begin
       bindstr(i,SQL_C_CHAR,SQL_CHAR,buf,strlen,strlen)
      end;
     end;
    end;
    ftbytes,ftvarbytes: begin
     if isnull then begin
      bindnull(i,SQL_C_BINARY,SQL_VARBINARY);
     end
     else begin
      StrVal:= AParams[paramindex].AsString;
      StrLen:= Length(StrVal);
      GetMem(buf,StrLen+sizeof(sqlinteger));
      Move(StrVal[1],(pchar(buf)+sizeof(sqlinteger))^,StrLen);
      if strlen > maxstrlen then begin
       bindstr(i,SQL_C_BINARY,SQL_LONGVARBINARY,buf,strlen,strlen)
      end
      else begin
       bindstr(i,SQL_C_BINARY,SQL_VARBINARY,buf,strlen,strlen)
      end;
     end;
    end;
    {$ifdef mswindows}
    ftwidestring,ftfixedwidechar: begin
     if isnull then begin
      bindnull(i,SQL_C_WCHAR,SQL_WCHAR);
     end
     else begin
      widestrval:= aparams[paramindex].aswidestring;
      strlen:= length(widestrval);
      buflen:= strlen*sizeof(msechar);
      getmem(buf,buflen+sizeof(sqlinteger));
      move(widestrval[1],(pchar(buf)+sizeof(sqlinteger))^,buflen);
      if strlen > maxstrlen then begin
       bindstr(i,SQL_C_WCHAR,SQL_WLONGVARCHAR,buf,strlen,buflen);
      end
      else begin
       bindstr(i,SQL_C_WCHAR,SQL_WCHAR,buf,strlen,buflen);
      end;
 //     bindstr(i,SQL_C_WCHAR,SQL_WCHAR,buf,buflen,buflen);
     end;
    end;
    {$endif}
    else begin
     if isnull then begin
      bindnull(i,SQL_C_CHAR,SQL_CHAR); //dummy
     end
     else begin
      raise EDataBaseError.CreateFmt(
       'Parameter %d is of type %s, which not supported yet',
       [ParamIndex, Fieldtypenames[AParams[ParamIndex].DataType]]);      
     end;
    end;
   end;
  end;
 end;
end;

procedure TODBCConnection.FreeParamBuffers(ODBCCursor: TODBCCursor);
var
  i:integer;
begin
 for i:=0 to High(ODBCCursor.FParamBuf) do begin
  FreeMem(ODBCCursor.FParamBuf[i]);
 end;
 ODBCCursor.FParamBuf:= nil;
end;

function TODBCConnection.GetHandle: pointer;
begin
  // I'm not sure whether this is correct; perhaps we should return nil
  // note that FDBHandle is a LongInt, because ODBC handles are integers, not pointers
  // I wonder how this will work on 64 bit platforms then (FK)
  Result:=pointer(FDBCHandle);
end;

procedure TODBCConnection.DoInternalConnect;
const
  BufferLength = 1024; // should be at least 1024 according to the ODBC specification
var
  ConnectionString: string;
  OutConnectionString: string;
  ActualLength: SQLSMALLINT;
begin
  // Do not call the inherited method as it checks for a non-empty DatabaseName, and we don't even use DatabaseName!
  // inherited DoInternalConnect;

  // make sure we have an environment
  if not Assigned(FEnvironment) then
  begin
    if DefaultEnvironment = nil then
      DefaultEnvironment:= TODBCEnvironment.Create;
    FEnvironment:=DefaultEnvironment;
  end;

  // allocate connection handle
  ODBCCheckResult(
    SQLAllocHandle(SQL_HANDLE_DBC,Environment.FENVHandle,FDBCHandle),
    SQL_HANDLE_ENV,Environment.FENVHandle,'Could not allocate ODBC Connection handle.'
  );

  // connect
  ConnectionString:=CreateConnectionString;
  SetLength(OutConnectionString,BufferLength); // allocate completed connection string buffer (using the ansistring #0 trick)
  try
   ODBCCheckResult(
     SQLDriverConnect(FDBCHandle,              // the ODBC connection handle
                     nil,                      // no parent window (would be required for prompts)
                     PChar(ConnectionString),  // the connection string
                     Length(ConnectionString), // connection string length
                     @(OutConnectionString[1]),// buffer for storing the completed connection string
                     BufferLength,             // length of the buffer
                     ActualLength,             // the actual length of the completed connection string
                     SQL_DRIVER_NOPROMPT),     // don't prompt for password etc.
    SQL_HANDLE_DBC,FDBCHandle,
    'Could not connect with connection string "%s".',[ConnectionString]
   );
  except
   SQLFreeHandle(SQL_HANDLE_DBC, FDBCHandle);
   fdbchandle:= nil;
   raise;
  end;

// commented out as the OutConnectionString is not used further at the moment
//  if ActualLength<BufferLength-1 then
//    SetLength(OutConnectionString,ActualLength); // fix completed connection string length

  // set connection attributes (none yet)
end;

procedure TODBCConnection.DoInternalDisconnect;
var
  Res:SQLRETURN;
begin
  inherited;

  // disconnect
  ODBCCheckResult(
    SQLDisconnect(FDBCHandle),
    SQL_HANDLE_DBC,FDBCHandle,'Could not disconnect.'
  );

  // deallocate connection handle
  Res:=SQLFreeHandle(SQL_HANDLE_DBC, FDBCHandle);
  if Res=SQL_ERROR then
    ODBCCheckResult(Res,SQL_HANDLE_DBC,FDBCHandle,
                           'Could not free connection handle.');
  fdbchandle:= nil;
end;

function TODBCConnection.AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor;
begin
  Result:=TODBCCursor.Create(aowner,aname,self);
end;

procedure TODBCConnection.DeAllocateCursorHandle(var cursor: TSQLCursor);
begin
  // make sure we don't deallocate the cursor if the connection was lost already
  if not Connected then
    pointer((cursor as TODBCCursor).FSTMTHandle):= pointer(SQL_INVALID_HANDLE);

  FreeAndNil(cursor); // the destructor of TODBCCursor frees the ODBC Statement handle
end;

function TODBCConnection.AllocateTransactionHandle: TSQLHandle;
begin
  Result:=nil; // not yet supported; will move connection handles to transaction handles later
end;

procedure todbcconnection.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);
var
  ODBCCursor:TODBCCursor;
  str1: string;
begin
  ODBCCursor:= TODBCCursor(cursor);

  // Parameter handling
  // Note: We can only pass ? parameters to ODBC, so we should convert named parameters like :MyID
  //       ODBCCursor.FParamIndex will map th i-th ? token in the (modified) query to an index for AParams

  // Parse the SQL and build FParamIndex
  if assigned(AParams) and (AParams.count > 0) then begin
   str1:= todbstring(AParams.ParseSQL(asql,false,false,false,psInterbase,
                            ODBCCursor.FParamIndex));
  end
  else begin
   str1:= todbstring(asql);
  end;
  // prepare statement
  ODBCCheckResult(
    SQLPrepare(ODBCCursor.FSTMTHandle, PChar(str1), Length(str1)),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not prepare statement.'
  );

  ODBCCursor.FQuery:= str1;
  ODBCCursor.fprepared:= true;
end;

procedure TODBCConnection.UnPrepareStatement(cursor: TSQLCursor);
begin
 with todbccursor(cursor) do begin
  FQuery:= '';
  fprepared:= false;
 end;
end;

function TODBCConnection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
 result:= nil;
  // Tranactions not implemented yet
end;

function TODBCConnection.StartDBTransaction(const trans: TSQLHandle; 
                   const AParams: tstringlist): boolean;
begin
 result:= true;
  // Tranactions not implemented yet
end;

function TODBCConnection.Commit(trans: TSQLHandle): boolean;
begin
 result:= true;
  // Tranactions not implemented yet
end;

function TODBCConnection.Rollback(trans: TSQLHandle): boolean;
begin
 result:= true;
  // Tranactions not implemented yet
end;

procedure TODBCConnection.internalCommitRetaining(trans: TSQLHandle);
begin
  // Tranactions not implemented yet
end;

procedure TODBCConnection.internalRollbackRetaining(trans: TSQLHandle);
begin
  // Tranactions not implemented yet
end;

procedure todbcconnection.updaterowcount(const acursor: todbccursor);
var
 len1: sqllen;
 int1: sqlsmallint;
begin
 with acursor do begin
  if odbcsucces(sqlgetdiagfield(sql_handle_stmt,fstmthandle,0,
              sql_diag_cursor_row_count,@len1,0,int1)) then begin
   frowsreturned:= len1;
  end;
  if odbcsucces(sqlgetdiagfield(sql_handle_stmt,fstmthandle,0,
              sql_diag_row_count,@len1,0,int1)) then begin
   frowsaffected:= len1;
  end;
 end;
end;

procedure TODBCConnection.internalExecute(const cursor: TSQLCursor;
      const ATransaction: TSQLTransaction; const AParams: TmseParams;
      const autf8: boolean);
var
  ODBCCursor:TODBCCursor;
  Res: SQLRETURN;
begin
  ODBCCursor:= TODBCCursor(cursor);
  odbccursor.frowsreturned:= -1;
  odbccursor.frowsaffected:= -1;


  // set parameters
    if Assigned(APArams) and (AParams.count > 0) then begin
     SetParameters(ODBCCursor, AParams);
    end;

  // execute the statement
  res:= SQLExecute(ODBCCursor.FSTMTHandle);
  ODBCCheckResult(res,
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not execute statement.'
  );
  updaterowcount(odbccursor);
  // free parameter buffers
  FreeParamBuffers(ODBCCursor);
end;

procedure todbcconnection.internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string);
var
  ODBCCursor:TODBCCursor;
  Res: SQLRETURN;
begin
  ODBCCursor:= TODBCCursor(cursor);
  odbccursor.frowsreturned:= -1;
  odbccursor.frowsaffected:= -1;
  res:= SQLExecdirect(ODBCCursor.FSTMTHandle,pchar(asql),length(asql));
  ODBCCheckResult(res,
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not execute statement.'
  );
  updaterowcount(odbccursor);
end;

function TODBCConnection.Fetch(cursor: TSQLCursor): boolean;
var
  ODBCCursor:TODBCCursor;
  Res:SQLRETURN;
begin
  ODBCCursor:= TODBCCursor(cursor);

  // fetch new row
  Res:=SQLFetch(ODBCCursor.FSTMTHandle);
  if Res<>SQL_NO_DATA then
    ODBCCheckResult(Res,SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
     'Could not fetch new row from result set');

  // result is true iff a new row was available
  Result:=Res<>SQL_NO_DATA;
end;

function todbcconnection.loadfield(const cursor: tsqlcursor;
       const datatype: tfieldtype; const fieldnum: integer; //null based
       const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
           
//todo: optimize

const
  DEFAULT_BLOB_BUFFER_SIZE = 1024;
var
  ODBCCursor:TODBCCursor;
  StrLenOrInd:SQLINTEGER;
  ODBCDateStruct:SQL_DATE_STRUCT;
  ODBCTimeStruct:SQL_TIME_STRUCT;
  ODBCTimeStampStruct:SQL_TIMESTAMP_STRUCT;
  DateTime:TDateTime;
//  BlobBuffer:pointer;
  BlobBufferSize,BytesRead:SQLINTEGER;
//  BlobMemoryStream:TMemoryStream;
  Res:SQLRETURN;
  targettype: sqlsmallint;
  fno: integer;
  int1: integer;
  str1: string;
  
  buffer1: pointer;
  bufsize1: integer;
  memolen1: integer;
  dummybuf: array [0..31] of byte;  
  do1: double;
  cu1: currency;
  
begin
 ODBCCursor:= TODBCCursor(cursor);

 // load the field using SQLGetData
 // Note: optionally we can implement the use of SQLBindCol later for even more speed
 // TODO: finish this

 res:= 0; //ok
 fno:= fieldnum+1;
 bufsize1:= bufsize;
 if buffer = nil then begin
  buffer1:= @dummybuf;
  bufsize1:= 0;
 end
 else begin
  bufsize1:= bufsize;
  buffer1:= buffer;
 end;
 
 case DataType of
  ftFixedChar,ftString: begin // are both mapped to TStringField
   Res:= SQLGetData(ODBCCursor.FSTMTHandle, fno,
         SQL_C_CHAR, buffer1, bufsize1{aField.Size}, @StrLenOrInd);
   bufsize1:= strlenorind;                         
   if bufsize1 > bufsize then begin
    bufsize1:= -bufsize1;
   end;
  end;
  ftwidestring,ftFixedWideChar: begin
   Res:= SQLGetData(ODBCCursor.FSTMTHandle, fno,
         SQL_C_WCHAR, buffer1, bufsize1{aField.Size}, @StrLenOrInd);
   bufsize1:= strlenorind;                         
   if bufsize1 > bufsize then begin
    bufsize1:= -bufsize1;
   end;
  end;
  ftSmallint: begin          // mapped to TSmallintField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SSHORT, buffer1,
                 SizeOf(Smallint), @StrLenOrInd);
  end;
  ftInteger,ftWord: begin    // mapped to TLongintField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SLONG, buffer1,
                 SizeOf(Longint), @StrLenOrInd);
  end;
  ftLargeint: begin          // mapped to TLargeintField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SBIGINT, buffer1,
                 SizeOf(Largeint), @StrLenOrInd);
  end;
  ftFloat,ftcurrency: begin             // mapped to TFloatField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_DOUBLE, buffer1,
                 SizeOf(Double), @StrLenOrInd);
  end;
  ftbcd: begin             
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_DOUBLE, @do1,
                 SizeOf(Double), @StrLenOrInd);
    if res = 0 then begin
     cu1:= do1;
     Move(cu1, buffer1^, SizeOf(cu1));
    end;
  end;
  ftTime: begin              // mapped to TTimeField
   Res:= SQLGetData(ODBCCursor.FSTMTHandle,fno,SQL_C_TYPE_TIME,
                @ODBCTimeStruct, SizeOf(SQL_TIME_STRUCT),@StrLenOrInd);
   if StrLenOrInd <> SQL_NULL_DATA then begin
    DateTime:= TimeStructToDateTime(@ODBCTimeStruct);
    Move(DateTime,buffer1^,SizeOf(TDateTime));
   end;
  end;
  ftDate: begin              // mapped to TDateField
   Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_TYPE_DATE,
                   @ODBCDateStruct, SizeOf(SQL_DATE_STRUCT), @StrLenOrInd);
   if StrLenOrInd<>SQL_NULL_DATA then begin
    DateTime:=DateStructToDateTime(@ODBCDateStruct);
    Move(DateTime, buffer1^, SizeOf(TDateTime));
   end;
  end;
  ftDateTime: begin          // mapped to TDateTimeField
   Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_TYPE_TIMESTAMP,
           @ODBCTimeStampStruct, SizeOf(SQL_TIMESTAMP_STRUCT), @StrLenOrInd);
   if StrLenOrInd<>SQL_NULL_DATA then begin
    DateTime:=TimeStampStructToDateTime(@ODBCTimeStampStruct);
    Move(DateTime, buffer1^, SizeOf(TDateTime));
   end;
  end;
  ftBoolean:  begin           // mapped to TBooleanField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BIT, buffer1,
                                         SizeOf(Wordbool), @StrLenOrInd);
  end;
  ftBytes: begin              // mapped to TBytesField
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, buffer1,
                                         bufsize1{aField.Size}, @StrLenOrInd);
  end;
  ftVarBytes: begin           // mapped to TVarBytesField
    int1:= bufsize1-sizeof(word);
    if int1 < 0 then begin
     int1:= 0;
    end;
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, 
                    pchar(buffer1)+sizeof(word),
                    int1{aField.Size}, @StrLenOrInd);
    pword(buffer1)^:= strlenorind;
  end;
  ftguid: begin
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_GUID, buffer1,
                                         SizeOf(tguid), @StrLenOrInd);
  end;
  ftBlob,ftMemo,ftwidememo: begin      // BLOBs   
           // Try to discover BLOB data length
   memolen1:= maxint div sizeof(widechar);
   if odbccursor.fcurrentblobbuffer = '' then begin
    Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, buffer1, 0,
                                         @StrLenOrInd);
    ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
     'Could not get field data for field ''%s'' (index %d).',
    [odbccursor.ffieldNames[fieldnum], fno]);
    if StrLenOrInd = 0 then begin
     strlenorind:= sql_null_data; //length 0 -> NULL
    end;
    // Read the data if not NULL
    if (StrLenOrInd <> SQL_NULL_DATA) and (buffer <> nil) then begin
     // Determine size of buffer to use
     if StrLenOrInd <> SQL_NO_TOTAL then begin
      memolen1:= strlenorind;
      if datatype = ftwidememo then begin
       memolen1:= memolen1 * sizeof(widechar);
      end;
      BlobBufferSize:= StrLenOrInd;
      case datatype of
       ftmemo: begin
        blobbuffersize:= blobbuffersize + sizeof(char); //terminating 0
       end;
       ftwidememo: begin
        blobbuffersize:= (blobbuffersize+1)*sizeof(widechar); //terminating 0
       end;
      end;
     end
     else begin
      BlobBufferSize:= DEFAULT_BLOB_BUFFER_SIZE;
     end;
     if BlobBufferSize > 0 then begin
      int1:= 0; //write index
      targettype:= SQL_C_BINARY;
      if datatype = ftwidememo then begin
       targettype:= SQL_C_WCHAR;
      end;
      repeat
       setlength(str1,int1+blobbuffersize);
       Res:= SQLGetData(ODBCCursor.FSTMTHandle, fno, targettype,
                       pchar(pointer(str1))+int1, BlobBufferSize, @StrLenOrInd);
       ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
        'Could not get field data for field ''%s'' (index %d).',
        [odbccursor.ffieldNames[fieldnum], fno]);
       if (StrLenOrInd=SQL_NO_TOTAL) or (StrLenOrInd>BlobBufferSize) then begin
        BytesRead:= BlobBufferSize;
       end
       else begin
        BytesRead:= StrLenOrInd;
       end;
       inc(int1,bytesread);              
      until Res = SQL_SUCCESS;
      case datatype of
       ftmemo,ftwidestring: begin
        if memolen1 < int1 then begin
         int1:= memolen1; //remove terminating 0
        end;
       end;
      end;
      setlength(str1,int1);
     end;
     if datatype = ftwidememo then begin
      bufsize1:= length(str1);
      odbccursor.fcurrentblobbuffer:= str1;
      bufsize1:= -bufsize1;
     end
     else begin
      int1:= cursor.addblobdata(str1);
      move(int1,buffer^,sizeof(int1));  //save id
     end;
    end;
   end
   else begin
    strlenorind:= sql_null_data; //invalid
    if datatype = ftwidememo then begin
     bufsize1:= length(odbccursor.fcurrentblobbuffer);
     if bufsize1 <= bufsize then begin
      strlenorind:= 0;
      if buffer <> nil then begin
       move(pointer(odbccursor.fcurrentblobbuffer)^,buffer^,bufsize1);
      end;
     end
     else begin
      bufsize1:= 0; //data lost
     end;
     odbccursor.fcurrentblobbuffer:= '';
    end;
   end;
  end;      
  else begin  // TODO: Loading of other field types
   raise EODBCException.CreateFmt('Tried to load field of unsupported field type %s',
   [Fieldtypenames[DataType]]);
  end;
 end;
 bufsize:= bufsize1;
 ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
  'Could not get field data for field ''%s'' (index %d).',
  [odbccursor.ffieldNames[fieldnum], fno]);
 Result:=StrLenOrInd<>SQL_NULL_DATA; // Result indicates whether the value is non-null
end;

function TODBCConnection.CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream;
var
 blobid: integer;
// int1,int2: integer;
// str1: string;
// bo1: boolean;
begin
 result:= nil;
 if mode = bmread then begin
  if field.getData(@blobId) then begin
   result:= acursor.getcachedblob(blobid);
  end;
 end;
end;

procedure TODBCConnection.FreeFldBuffers(cursor: TSQLCursor);
var
  ODBCCursor:TODBCCursor;
//  i: integer;
begin
  ODBCCursor:=cursor as TODBCCursor;
{  
  // Free TMemoryStreams in cursor.FBlobStreams and clear it
  for i:=0 to ODBCCursor.FBlobStreams.Count-1 do
    TObject(ODBCCursor.FBlobStreams[i]).Free;
  ODBCCursor.FBlobStreams.Clear;
}
  ODBCCheckResult(
    SQLFreeStmt(ODBCCursor.FSTMTHandle, SQL_CLOSE),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not close ODBC statement cursor.'
  );
end;

procedure TODBCConnection.AddFieldDefs(const cursor: TSQLCursor; 
                                    const FieldDefs: TFieldDefs);
const
  ColNameDefaultLength  = 40; // should be > 0, because an ansistring of length 0 is a nil pointer instead of a pointer to a #0
  TypeNameDefaultLength = 80; // idem
var
  ODBCCursor:TODBCCursor;
  ColumnCount:SQLSMALLINT;
  i:integer;
  ColNameLength,{TypeNameLength,}DataType,DecimalDigits,Nullable:SQLSMALLINT;
  ColumnSize: SQLULEN;
  ColName{,TypeName}:string;
  FieldType:TFieldType;
  FieldSize: integer;
  fd: tfielddef;
  int1: integer;
begin
 fielddefs.clear;
  ODBCCursor:=cursor as TODBCCursor;

  // get number of columns in result set
  ODBCCheckResult(
    SQLNumResultCols(ODBCCursor.FSTMTHandle, ColumnCount),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
    'Could not determine number of columns in result set.'
  );

  setlength(odbccursor.ffieldnames,columncount);
  for i:=1 to ColumnCount do
  begin
    SetLength(ColName,ColNameDefaultLength); // also garantuees uniqueness

    // call with default column name buffer
    ODBCCheckResult(
      SQLDescribeCol(ODBCCursor.FSTMTHandle, // statement handle
                     i,                      // column number, is 1-based (Note: column 0 is the bookmark column in ODBC)
                     @(ColName[1]),          // default buffer
                     ColNameDefaultLength+1, // and its length; we include the #0 terminating any ansistring of Length > 0 in the buffer
                     ColNameLength,          // actual column name length
                     DataType,               // the SQL datatype for the column
                     ColumnSize,             // column size
                     DecimalDigits,          // number of decimal digits
                     Nullable),              // SQL_NO_NULLS, SQL_NULLABLE or SQL_NULLABLE_UNKNOWN
      SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
      'Could not get column properties for column %d.',[i]
    );

    // truncate buffer or make buffer long enough for entire column name (note: the call is the same for both cases!)
    SetLength(ColName,ColNameLength);
    // check whether entire column name was returned
    if ColNameLength>ColNameDefaultLength then
    begin
      // request column name with buffer that is long enough
      ODBCCheckResult(
        SQLColAttribute(ODBCCursor.FSTMTHandle, // statement handle
                        i,                      // column number
                        SQL_DESC_NAME,          // the column name or alias
                        @(ColName[1]),          // buffer
                        ColNameLength+1,        // buffer size
                        @ColNameLength,         // actual length
                        nil),                   // no numerical output
        SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
        'Could not get column name for column %d.',[i]
      );
    end;

    // convert type
    // NOTE: I made some guesses here after I found only limited information about TFieldType; please report any problems
    case DataType of
      SQL_CHAR:          begin FieldType:=ftString;     FieldSize:=ColumnSize{+1}; end;
      SQL_VARCHAR:       begin FieldType:=ftString;     FieldSize:=ColumnSize{+1}; end;
      SQL_LONGVARCHAR:   begin FieldType:=ftMemo;       FieldSize:= blobidsize; end; 
                                      // is a blob
      SQL_WCHAR:         begin FieldType:=ftWideString; FieldSize:=ColumnSize{+1}; end;
      SQL_WVARCHAR:      begin FieldType:=ftWideString; FieldSize:=ColumnSize{+1}; end;
      SQL_WLONGVARCHAR:  begin 
       FieldType:= ftwidememo; //for tmsestringfield
       FieldSize:= 0;
      end; // is a blob
      SQL_NUMERIC,SQL_DECIMAL:
      begin 
       if (decimaldigits > 4) and 
                       (dbo_bcdtofloatif in controller.options) then begin
        FieldType:= ftFloat;
        FieldSize:= 0;
       end
       else begin
        FieldType:= ftbcd;
        FieldSize:= decimaldigits;
        if fieldsize > 4 then begin
         fieldsize:= 4;
        end;
       end;
      end;
      SQL_SMALLINT:      begin FieldType:=ftSmallint;   FieldSize:=0; end;
      SQL_INTEGER:       begin FieldType:=ftInteger;    FieldSize:=0; end;
      SQL_REAL:          begin FieldType:=ftFloat;      FieldSize:=0; end;
      SQL_FLOAT:         begin FieldType:=ftFloat;      FieldSize:=0; end;
      SQL_DOUBLE:        begin FieldType:=ftFloat;      FieldSize:=0; end;
      SQL_BIT:           begin FieldType:=ftBoolean;    FieldSize:=0; end;
      SQL_TINYINT:       begin FieldType:=ftSmallint;   FieldSize:=0; end;
      SQL_BIGINT:        begin FieldType:=ftLargeint;   FieldSize:=0; end;
      SQL_BINARY:        begin FieldType:=ftBytes;      FieldSize:=ColumnSize; end;
      SQL_VARBINARY:     begin FieldType:=ftVarBytes;   FieldSize:=ColumnSize; end;
      SQL_LONGVARBINARY: begin FieldType:=ftBlob;       FieldSize:=blobidsize; end; 
                                  // is a blob
      SQL_TYPE_DATE:     begin FieldType:=ftDate;       FieldSize:=0; end;
      SQL_TYPE_TIME:     begin FieldType:=ftTime;       FieldSize:=0; end;
      SQL_TYPE_TIMESTAMP:begin FieldType:=ftDateTime;   FieldSize:=0; end;
{      SQL_TYPE_UTCDATETIME:FieldType:=ftUnknown;}
{      SQL_TYPE_UTCTIME:    FieldType:=ftUnknown;}
{      SQL_INTERVAL_MONTH:           FieldType:=ftUnknown;}
{      SQL_INTERVAL_YEAR:            FieldType:=ftUnknown;}
{      SQL_INTERVAL_YEAR_TO_MONTH:   FieldType:=ftUnknown;}
{      SQL_INTERVAL_DAY:             FieldType:=ftUnknown;}
{      SQL_INTERVAL_HOUR:            FieldType:=ftUnknown;}
{      SQL_INTERVAL_MINUTE:          FieldType:=ftUnknown;}
{      SQL_INTERVAL_SECOND:          FieldType:=ftUnknown;}
{      SQL_INTERVAL_DAY_TO_HOUR:     FieldType:=ftUnknown;}
{      SQL_INTERVAL_DAY_TO_MINUTE:   FieldType:=ftUnknown;}
{      SQL_INTERVAL_DAY_TO_SECOND:   FieldType:=ftUnknown;}
{      SQL_INTERVAL_HOUR_TO_MINUTE:  FieldType:=ftUnknown;}
{      SQL_INTERVAL_HOUR_TO_SECOND:  FieldType:=ftUnknown;}
{      SQL_INTERVAL_MINUTE_TO_SECOND:FieldType:=ftUnknown;}
      SQL_GUID:          begin FieldType:=ftGuid;       FieldSize:=ColumnSize; end;
    else
      begin FieldType:=ftUnknown; FieldSize:=ColumnSize; end
    end;

//    if (FieldType in [ftString,ftFixedChar]) and // field types mapped to TStringField
//       (FieldSize >= dsMaxStringSize) then
//    begin
//      FieldSize:=dsMaxStringSize-1;
//    end;
(*    
    if FieldType=ftUnknown then // if unknown field type encountered, try finding more specific information about the ODBC SQL DataType
    begin
      SetLength(TypeName,TypeNameDefaultLength); // also garantuees uniqueness
      
      ODBCCheckResult(
        SQLColAttribute(ODBCCursor.FSTMTHandle,  // statement handle
                        i,                       // column number
                        SQL_DESC_TYPE_NAME,      // FieldIdentifier indicating the datasource dependent data type name (useful for diagnostics)
                        @(TypeName[1]),          // default buffer
                        TypeNameDefaultLength+1, // and its length; we include the #0 terminating any ansistring of Length > 0 in the buffer
                        @TypeNameLength,         // actual type name length
                        nil                      // no need for a pointer to return a numeric attribute at
        ),
        SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
        'Could not get datasource dependent type name for column %s.',[ColName]
      );
      // truncate buffer or make buffer long enough for entire column name (note: the call is the same for both cases!)
      SetLength(TypeName,TypeNameLength);
      // check whether entire column name was returned
      if TypeNameLength>TypeNameDefaultLength then
      begin
        // request column name with buffer that is long enough
        ODBCCheckResult(
          SQLColAttribute(ODBCCursor.FSTMTHandle, // statement handle
                        i,                        // column number
                        SQL_DESC_TYPE_NAME,       // FieldIdentifier indicating the datasource dependent data type name (useful for diagnostics)
                        @(TypeName[1]),           // buffer
                        TypeNameLength+1,         // buffer size
                        @TypeNameLength,          // actual length
                        nil),                     // no need for a pointer to return a numeric attribute at
          SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
          'Could not get datasource dependent type name for column %s.',[ColName]
        );
      end;
      DatabaseErrorFmt('Column %s has an unknown or unsupported column type. Datasource dependent type name: %s. ODBC SQL data type code: %d.', [ColName, TypeName, DataType]);
    end;
*)
    // add FieldDef
    if not(fieldtype in varsizefields) then begin
     fieldsize:= 0;
    end;
    fd:= TFieldDef.Create(FieldDefs, ColName, FieldType, FieldSize, False, i);
    fd.collection:= fielddefs;
    if fieldtype = ftbcd then begin
     int1:= columnsize;
     if int1 > maxprecision then begin
      int1:= maxprecision;
     end;
     fd.precision:= int1;
    end;
    odbccursor.ffieldnames[i-1]:= colname;
  end;
end;

procedure TODBCConnection.UpdateIndexDefs(var IndexDefs: TIndexDefs;
                    const aTableName: string);
var
  StmtHandle:SQLHSTMT;
  Res:SQLRETURN;
  IndexDef: TIndexDef;
  KeyFields, KeyName: String;
  // variables for binding
  NonUnique :SQLSMALLINT; NonUniqueIndOrLen :SQLINTEGER;
  IndexName :string;      IndexNameIndOrLen :SQLINTEGER;
  _Type     :SQLSMALLINT; _TypeIndOrLen     :SQLINTEGER;
  OrdinalPos:SQLSMALLINT; OrdinalPosIndOrLen:SQLINTEGER;
  ColName   :string;      ColNameIndOrLen   :SQLINTEGER;
  AscOrDesc :SQLCHAR;     AscOrDescIndOrLen :SQLINTEGER;
  PKName    :string;      PKNameIndOrLen    :SQLINTEGER;
const
  DEFAULT_NAME_LEN = 255;
begin

// exit; /////////// does not work with MS SQL because of one statement 
         //per connection limitation
 
  // allocate statement handle
  StmtHandle := SQL_NULL_HANDLE;
  ODBCCheckResult(
    SQLAllocHandle(SQL_HANDLE_STMT, FDBCHandle, StmtHandle),
    SQL_HANDLE_DBC, FDBCHandle, 'Could not allocate ODBC Statement handle.'
  );

  try
    // Disabled: only works if we can specify a SchemaName and, if supported by the data source, a CatalogName
    //           otherwise SQLPrimaryKeys returns error HY0009 (Invalid use of null pointer)
    // set the SQL_ATTR_METADATA_ID so parameters to Catalog functions are considered as identifiers (e.g. case-insensitive)
    //ODBCCheckResult(
    //  SQLSetStmtAttr(StmtHandle, SQL_ATTR_METADATA_ID, SQLPOINTER(SQL_TRUE), SQL_IS_UINTEGER),
    //  SQL_HANDLE_STMT, StmtHandle, 'Could not set SQL_ATTR_METADATA_ID statement attribute to SQL_TRUE.'
    //);

    // alloc result column buffers
    SetLength(ColName,  DEFAULT_NAME_LEN);
    SetLength(PKName,   DEFAULT_NAME_LEN);
    SetLength(IndexName,DEFAULT_NAME_LEN);

    // Fetch primary key info using SQLPrimaryKeys
    ODBCCheckResult(
      SQLPrimaryKeys(
        StmtHandle,
        nil, 0, // any catalog
        nil, 0, // any schema
        PChar(aTableName), Length(aTableName)
      ),
      SQL_HANDLE_STMT, StmtHandle,
       'Could not retrieve primary key metadata for table %s using SQLPrimaryKeys.',
        [aTableName]
    );

    // init key name & fields; we will set the IndexDefs.Option ixPrimary below when there is a match by IndexName=KeyName
    KeyName:='';
    KeyFields:='';
    try
      // bind result columns; the column numbers are documented in the reference for SQLStatistics
      ODBCCheckResult(SQLBindCol(StmtHandle,  4, SQL_C_CHAR  , @ColName[1],
        Length(ColName)+1, @ColNameIndOrLen), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind primary key metadata column COLUMN_NAME.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  5, SQL_C_SSHORT, @OrdinalPos, 0,
        @OrdinalPosIndOrLen), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind primary key metadata column KEY_SEQ.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  6, SQL_C_CHAR  , @PKName [1],
       Length(PKName )+1, @PKNameIndOrLen ), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind primary key metadata column PK_NAME.');

      // fetch result
      repeat
        // go to next row; loads data in bound columns
        Res:=SQLFetch(StmtHandle);
        // if no more row, break
        if Res=SQL_NO_DATA then
          Break;
        // handle data
        if ODBCSucces(Res) then begin
          if OrdinalPos=1 then begin
            KeyName:=PChar(@PKName[1]);
            KeyFields:=    PChar(@ColName[1]);
          end else begin
            KeyFields:=KeyFields+';'+PChar(@ColName[1]);
          end;
        end else begin
          ODBCCheckResult(Res, SQL_HANDLE_STMT, StmtHandle,
           'Could not fetch primary key metadata row.');
        end;
      until false;
    finally
      // unbind columns & close cursor
      ODBCCheckResult(SQLFreeStmt(StmtHandle, SQL_UNBIND), SQL_HANDLE_STMT,
       StmtHandle, 'Could not unbind columns.');
      ODBCCheckResult(SQLFreeStmt(StmtHandle, SQL_CLOSE),  SQL_HANDLE_STMT,
       StmtHandle, 'Could not close cursor.');
    end;

    //WriteLn('KeyName: ',KeyName,'; KeyFields: ',KeyFields);

    // use SQLStatistics to get index information
    ODBCCheckResult(
      SQLStatistics(
        StmtHandle,
        nil, 0, // catalog unkown; request for all catalogs
        nil, 0, // schema unkown; request for all schemas
        PChar(aTableName), Length(aTableName), // request information for TableName
        SQL_INDEX_ALL,
        SQL_QUICK
      ),
      SQL_HANDLE_STMT, StmtHandle,
       'Could not retrieve index metadata for table %s using SQLStatistics.',
        [aTableName]
    );

    try
      // bind result columns; the column numbers are documented in the reference for SQLStatistics
      ODBCCheckResult(SQLBindCol(StmtHandle,  4, SQL_C_SSHORT, @NonUnique , 0,
       @NonUniqueIndOrLen ), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column NON_UNIQUE.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  6, SQL_C_CHAR  , @IndexName[1],
       Length(IndexName)+1, @IndexNameIndOrLen), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column INDEX_NAME.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  7, SQL_C_SSHORT, @_Type     , 0,
       @_TypeIndOrLen     ), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column TYPE.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  8, SQL_C_SSHORT, @OrdinalPos, 0,
       @OrdinalPosIndOrLen), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column ORDINAL_POSITION.');
      ODBCCheckResult(SQLBindCol(StmtHandle,  9, SQL_C_CHAR  , @ColName  [1],
       Length(ColName  )+1, @ColNameIndOrLen  ), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column COLUMN_NAME.');
      ODBCCheckResult(SQLBindCol(StmtHandle, 10, SQL_C_CHAR  , @AscOrDesc , 1,
       @AscOrDescIndOrLen ), SQL_HANDLE_STMT, StmtHandle,
        'Could not bind index metadata column ASC_OR_DESC.');

      // clear index defs
      IndexDef:=nil;

      // fetch result
      repeat
        // go to next row; loads data in bound columns
        Res:=SQLFetch(StmtHandle);
        // if no more row, break
        if Res=SQL_NO_DATA then
          Break;
        // handle data
        if ODBCSucces(Res) then begin
          // note: SQLStatistics not only returns index info, but also statistics; we skip the latter
          if _Type<>SQL_TABLE_STAT then begin
            if (OrdinalPos=1) or not Assigned(IndexDef) then begin
              // create new IndexDef iff OrdinalPos=1 or not Assigned(IndexDef) (the latter should not occur though)
              IndexDef:=IndexDefs.AddIndexDef;
              IndexDef.Name:=PChar(@IndexName[1]); // treat ansistring as zero terminated string
              IndexDef.Fields:=PChar(@ColName[1]);
              if NonUnique=SQL_FALSE then
                IndexDef.Options:=IndexDef.Options+[ixUnique];
              if (AscOrDescIndOrLen<>SQL_NULL_DATA) and (AscOrDesc='D') then
                IndexDef.Options:=IndexDef.Options+[ixDescending];
              if IndexDef.Name=KeyName then
                IndexDef.Options:=IndexDef.Options+[ixPrimary];
              // TODO: figure out how we can tell whether COLUMN_NAME is an expression or not
              //       if it is an expression, we should include ixExpression in Options and set Expression to ColName
            end else // NB we re-use the last IndexDef
              IndexDef.Fields:=IndexDef.Fields+';'+PChar(@ColName[1]); // NB ; is the separator to be used for IndexDef.Fields
          end;
        end else begin
          ODBCCheckResult(Res, SQL_HANDLE_STMT, StmtHandle,
           'Could not fetch index metadata row.');
        end;
      until false;
    finally
      // unbind columns & close cursor
      ODBCCheckResult(SQLFreeStmt(StmtHandle, SQL_UNBIND), SQL_HANDLE_STMT,
       StmtHandle, 'Could not unbind columns.');
      ODBCCheckResult(SQLFreeStmt(StmtHandle, SQL_CLOSE),  SQL_HANDLE_STMT,
       StmtHandle, 'Could not close cursor.');
    end;

  finally
    if StmtHandle<>SQL_NULL_HANDLE then begin
      // Free the statement handle
      Res:=SQLFreeHandle(SQL_HANDLE_STMT, StmtHandle);
      if Res=SQL_ERROR then
        ODBCCheckResult(Res, SQL_HANDLE_STMT, STMTHandle,
         'Could not free ODBC Statement handle.');
    end;
  end;
end;

function TODBCConnection.GetSchemaInfoSQL(SchemaType: TSchemaType; SchemaObjectName, SchemaObjectPattern: string): string;
begin
  Result:=inherited GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaObjectPattern);
  // TODO: implement this
end;

{ TODBCEnvironment }

procedure ODBCCheckResult(LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT;
                                    AHandle: SQLHANDLE; ErrorMsg: string;
                                    const values: array of const);
var
 conn: todbcconnection;  
begin
 if not odbcsucces(lastreturncode) then begin
  conn:= todbcconnection.create(nil);
  try
   conn.odbccheckresult(lastreturncode,handletype,ahandle,errormsg,values);
  finally;
   conn.free;
  end;
 end;
end;

constructor TODBCEnvironment.Create;
var
 res: sqlreturn;
begin
  // make sure odbc is loaded
  initializeodbc([]);
  finitialized:= true;
  // allocate environment handle
  if SQLAllocHandle(SQL_HANDLE_ENV,
                        SQL_NULL_HANDLE, FENVHandle) = SQL_Error then begin
    raise EODBCException.Create('Could not allocate ODBC Environment handle');
     // we can't retrieve any more information, 
     //because we don't have a handle for the SQLGetDiag* functions
  end;
  // set odbc version
  res:= SQLSetEnvAttr(FENVHandle, SQL_ATTR_ODBC_VERSION,
                                             SQLPOINTER(SQL_OV_ODBC3), 0);
  ODBCCheckResult(res,
           SQL_HANDLE_ENV, FENVHandle,'Could not set ODBC version to 3.',[]);
end;

destructor TODBCEnvironment.Destroy;
var
  Res:SQLRETURN;
begin
  // free environment handle
  if FENVHandle <> nil then begin //otherwise exception in create
   Res:=SQLFreeHandle(SQL_HANDLE_ENV, FENVHandle);
   if Res = SQL_ERROR then
     ODBCCheckResult(Res,SQL_HANDLE_ENV, FENVHandle,
      'Could not free ODBC Environment handle.',[]);
 
   // free odbc if not used by any TODBCEnvironment object anymore
  end;
//  Dec(ODBCLoadCount);
//  if ODBCLoadCount=0 then ReleaseOdbc;
 if finitialized then begin
  releaseodbc;
 end;
end;

{ TODBCCursor }

constructor TODBCCursor.Create(const aowner: icursorclient;
              const aname: ansistring; const Connection:TODBCConnection);
begin
 fconnection:= connection;
 inherited create(aowner,aname);
  // allocate statement handle
  connection.ODBCCheckResult(
    SQLAllocHandle(SQL_HANDLE_STMT, Connection.FDBCHandle, FSTMTHandle),
    SQL_HANDLE_DBC, Connection.FDBCHandle,
     'Could not allocate ODBC Statement handle.'
  );
  
  // allocate FBlobStreams
//  FBlobStreams:=TList.Create;
end;

destructor TODBCCursor.Destroy;
var
  Res:SQLRETURN;
begin
  inherited Destroy;
  
//  FBlobStreams.Free;

  if pointer(FSTMTHandle) <> pointer(SQL_INVALID_HANDLE) then
  begin
    // deallocate statement handle
    Res:=SQLFreeHandle(SQL_HANDLE_STMT, FSTMTHandle);
    if Res=SQL_ERROR then
      fconnection.ODBCCheckResult(Res,SQL_HANDLE_STMT, FSTMTHandle,
       'Could not free ODBC Statement handle.');
  end;
end;

procedure TODBCCursor.close;
begin
 sqlclosecursor(fstmthandle);
// ODBCCheckResult(sqlclosecursor(fstmthandle),SQL_HANDLE_STMT, FSTMTHandle,
//                         'Could not close Cursor'); 
                  //there is possible no cursor -> no errorcheck
 fcurrentblobbuffer:= '';
 inherited;
end;

{ finalization }

initialization
finalization

  if Assigned(DefaultEnvironment) then
    DefaultEnvironment.Free;

end.

