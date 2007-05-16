(******************************************************************************
 *                                                                            *
 *  (c) 2005 Hexis BV                                                         *
 *                                                                            *
 *  File:        odbcconn.pas                                                 *
 *  Author:      Bram Kuijvenhoven (bkuijvenhoven@eljakim.nl)                 *
 *  Description: ODBC SQLDB unit                                              *
 *  License:     (modified) LGPL                                              *
 *                                                                            *
 ******************************************************************************)

unit modbcconn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, msqldb, db, odbcsqldyn;

type

  // forward declarations
  TODBCConnection = class;

  { TODBCCursor }

  TODBCCursor = class(TSQLCursor)
  protected
    FSTMTHandle:SQLHSTMT; // ODBC Statement Handle
    FQuery:string;        // last prepared query, with :ParamName converted to ?
    FParamIndex:TParamBinding; // maps the i-th parameter in the query to the TParams passed to PrepareStatement
    FParamBuf:array of pointer; // buffers that can be used to bind the i-th parameter in the query
    FBlobStreams:TList;   // list of Blob TMemoryStreams stored in field buffers (we need this currently as we can't hook into the freeing of TBufDataset buffers)
  public
    constructor Create(const aquery: tsqlquery;
                                      const Connection:TODBCConnection);
    destructor Destroy; override;
  end;

  { TODBCHandle } // this name is a bit confusing, but follows the standards for naming classes in sqldb

  TODBCHandle = class(TSQLHandle)
  protected
  end;

  { TODBCEnvironment }

  TODBCEnvironment = class
  protected
    FENVHandle:SQLHENV; // ODBC Environment Handle
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TODBCConnection }

  TODBCConnection = class(TSQLConnection)
  private
    FDriver: string;
    FEnvironment:TODBCEnvironment;
    FDBCHandle:SQLHDBC; // ODBC Connection Handle
    FFileDSN: string;

    procedure SetParameters(ODBCCursor:TODBCCursor; AParams:TParams);
    procedure FreeParamBuffers(ODBCCursor:TODBCCursor);
  protected
    // Overrides from TSQLConnection
    function GetHandle:pointer; override;
    // - Connect/disconnect
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    // - Handle (de)allocation
    function AllocateCursorHandle(const aquery: tsqlquery): TSQLCursor; override;
    procedure DeAllocateCursorHandle(var cursor:TSQLCursor); override;
    function AllocateTransactionHandle:TSQLHandle; override;
    // - Statement handling
    procedure PrepareStatement(cursor:TSQLCursor; ATransaction:TSQLTransaction; buf:string; AParams:TParams); override;
    procedure UnPrepareStatement(cursor:TSQLCursor); override;
    // - Transaction handling
    function GetTransactionHandle(trans:TSQLHandle):pointer; override;
    function StartDBTransaction(trans:TSQLHandle; AParams:string):boolean; override;
    function Commit(trans:TSQLHandle):boolean; override;
    function Rollback(trans:TSQLHandle):boolean; override;
    procedure internalCommitRetaining(trans:TSQLHandle); override;
    procedure internalRollbackRetaining(trans:TSQLHandle); override;
    // - Statement execution
    procedure Execute(const cursor:TSQLCursor; 
             const ATransaction:TSQLTransaction; const AParams:TParams); override;
    // - Result retrieving
    procedure AddFieldDefs(cursor:TSQLCursor; FieldDefs:TFieldDefs); override;
    function Fetch(cursor:TSQLCursor):boolean; override;
    function loadfield(const cursor: tsqlcursor; const afield: tfield;
      const buffer: pointer; var bufsize: integer): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream; override;
    procedure FreeFldBuffers(cursor:TSQLCursor); override;
    // - UpdateIndexDefs
    procedure UpdateIndexDefs(var IndexDefs:TIndexDefs;
                          const TableName:string); override;
    // - Schema info
    function GetSchemaInfoSQL(SchemaType:TSchemaType; SchemaObjectName, SchemaObjectPattern:string):string; override;

    // Internal utility functions
    function CreateConnectionString:string;
  public
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
    // Redeclare properties from TDatabase
    property Connected;
    property Role;
    property DatabaseName; // will be passed as DSN connection parameter
    property KeepConnection;
    property LoginPrompt;  // if true, ODBC drivers might prompt for more details that are not in the connection string
    property Params;       // will be added to connection string
    property OnLogin;
  end;

  EODBCException = class(Exception)
    // currently empty; perhaps we can add fields here later that describe the error instead of one simple message string
  end;

implementation

uses
  Math, DBConst;

const
  DefaultEnvironment:TODBCEnvironment = nil;
  ODBCLoadCount:integer = 0; // ODBC is loaded when > 0; modified by TODBCEnvironment.Create/Destroy

{ Generic ODBC helper functions }

function ODBCSucces(const Res:SQLRETURN):boolean;
begin
  Result:=(Res=SQL_SUCCESS) or (Res=SQL_SUCCESS_WITH_INFO);
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

procedure ODBCCheckResult(LastReturnCode:SQLRETURN; HandleType:SQLSMALLINT; AHandle: SQLHANDLE; ErrorMsg: string);

  // check return value from SQLGetDiagField/Rec function itself
  procedure CheckSQLGetDiagResult(const Res:SQLRETURN);
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
  NativeError:SQLINTEGER;
  TextLength:SQLSMALLINT;
  Res:SQLRETURN;
  SqlState,MessageText,TotalMessage:string;
  RecNumber:SQLSMALLINT;
begin
  // check result
  if ODBCSucces(LastReturnCode) then
    Exit; // no error; all is ok

  // build TotalMessage for exception to throw
  TotalMessage:=Format('%s ODBC error details:',[ErrorMsg]);
  // retrieve status records
  SetLength(SqlState,5); // SqlState buffer
  RecNumber:=1;
  repeat
    // dummy call to get correct TextLength
    Res:=SQLGetDiagRec(HandleType,AHandle,RecNumber,@(SqlState[1]),NativeError,@(SqlState[1]),0,TextLength);
    if Res=SQL_NO_DATA then
      Break; // no more status records
    CheckSQLGetDiagResult(Res);
    if TextLength>0 then // if TextLength=0 we don't need another call; also our string buffer would not point to a #0, but be a nil pointer
    begin
      // allocate large enough buffer
      SetLength(MessageText,TextLength); // note: ansistrings of Length>0 are always terminated by a #0 character, so this is safe
      // actual call
      Res:=SQLGetDiagRec(HandleType,AHandle,RecNumber,@(SqlState[1]),NativeError,@(MessageText[1]),Length(MessageText)+1,TextLength);
      CheckSQLGetDiagResult(Res);
    end;
    // add to TotalMessage
    TotalMessage:=TotalMessage + Format(' Record %d: SqlState: %s; NativeError: %d; Message: %s;',[RecNumber,SqlState,NativeError,MessageText]);
    // incement counter
    Inc(RecNumber);
  until false;
  // raise error
  raise EODBCException.Create(TotalMessage);
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

procedure TODBCConnection.SetParameters(ODBCCursor: TODBCCursor; AParams: TParams);
var
  ParamIndex:integer;
  Buf:pointer;
  I:integer;
  IntVal:longint;
  StrVal:string;
  StrLen:SQLINTEGER;
begin
  // Note: it is assumed that AParams is the same as the one passed to PrepareStatement, in the sense that
  //       the parameters have the same order and names

  if Length(ODBCCursor.FParamIndex)>0 then
    if not Assigned(AParams) then
      raise EODBCException.CreateFmt('The query has parameter markers in it, but no actual parameters were passed',[]);

  SetLength(ODBCCursor.FParamBuf, Length(ODBCCursor.FParamIndex));
  for i:=0 to High(ODBCCursor.FParamIndex) do
  begin
    ParamIndex:=ODBCCursor.FParamIndex[i];
    if (ParamIndex<0) or (ParamIndex>=AParams.Count) then
      raise EODBCException.CreateFmt('Parameter %d in query does not have a matching parameter set',[i]);
    case AParams[ParamIndex].DataType of
      ftInteger:
        begin
          Buf:=GetMem(4);
          IntVal:=AParams[ParamIndex].AsInteger;
          Move(IntVal,Buf^,4);
          ODBCCursor.FParamBuf[i]:=Buf;
          ODBCCheckResult(
            SQLBindParameter(ODBCCursor.FSTMTHandle, // StatementHandle
                             i+1,                    // ParameterNumber
                             SQL_PARAM_INPUT,        // InputOutputType
                             SQL_C_LONG,             // ValueType
                             SQL_INTEGER,            // ParameterType
                             10,                     // ColumnSize
                             0,                      // DecimalDigits
                             Buf,                    // ParameterValuePtr
                             0,                      // BufferLength
                             nil),                   // StrLen_or_IndPtr
            SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not bind parameter %d',[i])
          );
        end;
      ftString:
        begin
          StrVal:=AParams[ParamIndex].AsString;
          StrLen:=Length(StrVal);
          Buf:=GetMem(SizeOf(SQLINTEGER)+StrLen);
          Move(StrLen,    buf^,                    SizeOf(SQLINTEGER));
          Move(StrVal[1],(buf+SizeOf(SQLINTEGER))^,StrLen);
          ODBCCursor.FParamBuf[i]:=Buf;
          ODBCCheckResult(
            SQLBindParameter(ODBCCursor.FSTMTHandle, // StatementHandle
                             i+1,                    // ParameterNumber
                             SQL_PARAM_INPUT,        // InputOutputType
                             SQL_C_CHAR,             // ValueType
                             SQL_CHAR,               // ParameterType
                             StrLen,                 // ColumnSize
                             0,                      // DecimalDigits
                             buf+SizeOf(SQLINTEGER), // ParameterValuePtr
                             StrLen,                 // BufferLength
                             Buf),                   // StrLen_or_IndPtr
            SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not bind parameter %d',[i])
          );
        end;
    else
      raise EDataBaseError.CreateFmt('Parameter %d is of type %s, which not supported yet',[ParamIndex, Fieldtypenames[AParams[ParamIndex].DataType]]);
    end;
  end;
end;

procedure TODBCConnection.FreeParamBuffers(ODBCCursor: TODBCCursor);
var
  i:integer;
begin
  for i:=0 to High(ODBCCursor.FParamBuf) do
    FreeMem(ODBCCursor.FParamBuf[i]);
  SetLength(ODBCCursor.FParamBuf,0);
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
  ConnectionString:string;
  OutConnectionString:string;
  ActualLength:SQLSMALLINT;
begin
  // Do not call the inherited method as it checks for a non-empty DatabaseName, and we don't even use DatabaseName!
  // inherited DoInternalConnect;

  // make sure we have an environment
  if not Assigned(FEnvironment) then
  begin
    if not Assigned(DefaultEnvironment) then
      DefaultEnvironment:=TODBCEnvironment.Create;
    FEnvironment:=DefaultEnvironment;
  end;

  // allocate connection handle
  ODBCCheckResult(
    SQLAllocHandle(SQL_HANDLE_DBC,Environment.FENVHandle,FDBCHandle),
    SQL_HANDLE_ENV,Environment.FENVHandle,'Could not allocate ODBC Connection handle.'
  );

  // connect
  ConnectionString:=CreateConnectionString;
  SetLength(OutConnectionString,BufferLength-1); // allocate completed connection string buffer (using the ansistring #0 trick)
  ODBCCheckResult(
    SQLDriverConnect(FDBCHandle,               // the ODBC connection handle
                     nil,                      // no parent window (would be required for prompts)
                     PChar(ConnectionString),  // the connection string
                     Length(ConnectionString), // connection string length
                     @(OutConnectionString[1]),// buffer for storing the completed connection string
                     BufferLength,             // length of the buffer
                     ActualLength,             // the actual length of the completed connection string
                     SQL_DRIVER_NOPROMPT),     // don't prompt for password etc.
    SQL_HANDLE_DBC,FDBCHandle,Format('Could not connect with connection string "%s".',[ConnectionString])
  );

// commented out as the OutConnectionString is not used further at the moment
//  if ActualLength<BufferLength-1 then
//    SetLength(OutConnectionString,ActualLength); // fix completed connection string length

  // set connection attributes (none yet)
end;

procedure TODBCConnection.DoInternalDisconnect;
var
  Res:SQLRETURN;
begin
  inherited DoInternalDisconnect;

  // disconnect
  ODBCCheckResult(
    SQLDisconnect(FDBCHandle),
    SQL_HANDLE_DBC,FDBCHandle,'Could not disconnect.'
  );

  // deallocate connection handle
  Res:=SQLFreeHandle(SQL_HANDLE_DBC, FDBCHandle);
  if Res=SQL_ERROR then
    ODBCCheckResult(Res,SQL_HANDLE_DBC,FDBCHandle,'Could not free connection handle.');
end;

function TODBCConnection.AllocateCursorHandle(const aquery: tsqlquery): TSQLCursor;
begin
  Result:=TODBCCursor.Create(aquery,self);
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

procedure TODBCConnection.PrepareStatement(cursor: TSQLCursor; ATransaction: TSQLTransaction; buf: string; AParams: TParams);
var
  ODBCCursor:TODBCCursor;
begin
  ODBCCursor:=cursor as TODBCCursor;

  // Parameter handling
  // Note: We can only pass ? parameters to ODBC, so we should convert named parameters like :MyID
  //       ODBCCursor.FParamIndex will map th i-th ? token in the (modified) query to an index for AParams

  // Parse the SQL and build FParamIndex
  if assigned(AParams) and (AParams.count > 0) then
  {$ifdef FPC_2_2}
    buf := AParams.ParseSQL(buf,false,false,false,psInterbase,ODBCCursor.FParamIndex);
  {$else}
    buf := AParams.ParseSQL(buf,false,psInterbase,ODBCCursor.FParamIndex);
  {$endif}

  // prepare statement
  ODBCCheckResult(
    SQLPrepare(ODBCCursor.FSTMTHandle, PChar(buf), Length(buf)),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not prepare statement.'
  );

  ODBCCursor.FQuery:=Buf;
end;

procedure TODBCConnection.UnPrepareStatement(cursor: TSQLCursor);
begin
  // not necessary in ODBC
end;

function TODBCConnection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
  // Tranactions not implemented yet
end;

function TODBCConnection.StartDBTransaction(trans: TSQLHandle; AParams:string): boolean;
begin
  // Tranactions not implemented yet
end;

function TODBCConnection.Commit(trans: TSQLHandle): boolean;
begin
  // Tranactions not implemented yet
end;

function TODBCConnection.Rollback(trans: TSQLHandle): boolean;
begin
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

procedure TODBCConnection.Execute(const cursor: TSQLCursor;
      const ATransaction: TSQLTransaction; const AParams: TParams);
var
  ODBCCursor:TODBCCursor;
begin
  ODBCCursor:=cursor as TODBCCursor;

  // set parameters
    if Assigned(APArams) and (AParams.count > 0) then SetParameters(ODBCCursor, AParams);

  // execute the statement
  ODBCCheckResult(
    SQLExecute(ODBCCursor.FSTMTHandle),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not execute statement.'
  );

  // free parameter buffers
  FreeParamBuffers(ODBCCursor);
end;

function TODBCConnection.Fetch(cursor: TSQLCursor): boolean;
var
  ODBCCursor:TODBCCursor;
  Res:SQLRETURN;
begin
  ODBCCursor:=cursor as TODBCCursor;

  // fetch new row
  Res:=SQLFetch(ODBCCursor.FSTMTHandle);
  if Res<>SQL_NO_DATA then
    ODBCCheckResult(Res,SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not fetch new row from result set');

  // result is true iff a new row was available
  Result:=Res<>SQL_NO_DATA;
end;

function todbcconnection.loadfield(const cursor: tsqlcursor;
       const afield: tfield; const buffer: pointer;
       var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
 //untested!
 //todo: blob implementing 2006-11-14 MSE
 
const
  DEFAULT_BLOB_BUFFER_SIZE = 1024;
var
  ODBCCursor:TODBCCursor;
  StrLenOrInd:SQLINTEGER;
  ODBCDateStruct:SQL_DATE_STRUCT;
  ODBCTimeStruct:SQL_TIME_STRUCT;
  ODBCTimeStampStruct:SQL_TIMESTAMP_STRUCT;
  DateTime:TDateTime;
  BlobBuffer:pointer;
  BlobBufferSize,BytesRead:SQLINTEGER;
  BlobMemoryStream:TMemoryStream;
  Res:SQLRETURN;
  fno: integer;
begin
  ODBCCursor:=cursor as TODBCCursor;

  // load the field using SQLGetData
  // Note: optionally we can implement the use of SQLBindCol later for even more speed
  // TODO: finish this
  fno:= afield.fieldno;
  case aField.DataType of
    ftFixedChar,ftString: begin // are both mapped to TStringField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno,
            SQL_C_CHAR, buffer, aField.Size, @StrLenOrInd);
      bufsize:= strlenorind;                          //untested!!!!!!
    end;
    ftSmallint:           // mapped to TSmallintField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SSHORT, buffer, SizeOf(Smallint), @StrLenOrInd);
    ftInteger,ftWord:     // mapped to TLongintField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SLONG, buffer, SizeOf(Longint), @StrLenOrInd);
    ftLargeint:           // mapped to TLargeintField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_SBIGINT, buffer, SizeOf(Largeint), @StrLenOrInd);
    ftFloat:              // mapped to TFloatField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_DOUBLE, buffer, SizeOf(Double), @StrLenOrInd);
    ftTime:               // mapped to TTimeField
    begin
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_TYPE_TIME, @ODBCTimeStruct, SizeOf(SQL_TIME_STRUCT), @StrLenOrInd);
      if StrLenOrInd<>SQL_NULL_DATA then
      begin
        DateTime:=TimeStructToDateTime(@ODBCTimeStruct);
        Move(DateTime, buffer^, SizeOf(TDateTime));
      end;
    end;
    ftDate:               // mapped to TDateField
    begin
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_TYPE_DATE, @ODBCDateStruct, SizeOf(SQL_DATE_STRUCT), @StrLenOrInd);
      if StrLenOrInd<>SQL_NULL_DATA then
      begin
        DateTime:=DateStructToDateTime(@ODBCDateStruct);
        Move(DateTime, buffer^, SizeOf(TDateTime));
      end;
    end;
    ftDateTime:           // mapped to TDateTimeField
    begin
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_TYPE_TIMESTAMP, @ODBCTimeStampStruct, SizeOf(SQL_TIMESTAMP_STRUCT), @StrLenOrInd);
      if StrLenOrInd<>SQL_NULL_DATA then
      begin
        DateTime:=TimeStampStructToDateTime(@ODBCTimeStampStruct);
        Move(DateTime, buffer^, SizeOf(TDateTime));
      end;
    end;
    ftBoolean:            // mapped to TBooleanField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BIT, buffer, SizeOf(Wordbool), @StrLenOrInd);
    ftBytes:              // mapped to TBytesField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, buffer, aField.Size, @StrLenOrInd);
    ftVarBytes:           // mapped to TVarBytesField
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, buffer, aField.Size, @StrLenOrInd);
    ftBlob, ftMemo:       // BLOBs
    begin
      // Try to discover BLOB data length
      Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, buffer, 0, @StrLenOrInd);
      ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not get field data for field ''%s'' (index %d).',
      [aField.fieldName, fno]));
      // Read the data if not NULL
      if StrLenOrInd<>SQL_NULL_DATA then
      begin
        // Determine size of buffer to use
        if StrLenOrInd<>SQL_NO_TOTAL then
          BlobBufferSize:=StrLenOrInd
        else
          BlobBufferSize:=DEFAULT_BLOB_BUFFER_SIZE;
        try
          // init BlobBuffer and BlobMemoryStream to nil pointers
          BlobBuffer:=nil;
          BlobMemoryStream:=nil;
          if BlobBufferSize>0 then // Note: zero-length BLOB is represented as nil pointer in the field buffer to save memory usage
          begin
            // Allocate the buffer and memorystream
            BlobBuffer:=GetMem(BlobBufferSize);
            BlobMemoryStream:=TMemoryStream.Create;
            // Retrieve data in parts (or effectively in one part if StrLenOrInd<>SQL_NO_TOTAL above)
            repeat
              Res:=SQLGetData(ODBCCursor.FSTMTHandle, fno, SQL_C_BINARY, BlobBuffer, BlobBufferSize, @StrLenOrInd);
              ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
               Format('Could not get field data for field ''%s'' (index %d).',
               [aField.fieldname, fno]));
              // Append data in buffer to memorystream
              if (StrLenOrInd=SQL_NO_TOTAL) or (StrLenOrInd>BlobBufferSize) then
                BytesRead:=BlobBufferSize
              else
                BytesRead:=StrLenOrInd;
              BlobMemoryStream.Write(BlobBuffer^, BytesRead);
            until Res=SQL_SUCCESS;
          end;
          // Store memorystream pointer in Field buffer and in the cursor's FBlobStreams list
          TObject(buffer^):=BlobMemoryStream;
          if BlobMemoryStream<>nil then
            ODBCCursor.FBlobStreams.Add(BlobMemoryStream);
          // Set BlobMemoryStream to nil, so it won't get freed in the finally block below
          BlobMemoryStream:=nil;
        finally
          BlobMemoryStream.Free;
          if BlobBuffer<>nil then
            Freemem(BlobBuffer,BlobBufferSize);
        end;
      end;
    end;
    // TODO: Loading of other field types
  else
    raise EODBCException.CreateFmt('Tried to load field of unsupported field type %s',
    [Fieldtypenames[aField.DataType]]);
  end;
  ODBCCheckResult(Res, SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle,
   Format('Could not get field data for field ''%s'' (index %d).',
   [aField.fieldName, fno]));
  Result:=StrLenOrInd<>SQL_NULL_DATA; // Result indicates whether the value is non-null

//  writeln(Format('Field.Size: %d; StrLenOrInd: %d',[FieldDef.Size, StrLenOrInd]));
end;

function TODBCConnection.CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                 const acursor: tsqlcursor): TStream;
var
  ODBCCursor: TODBCCursor;
  BlobMemoryStream, BlobMemoryStreamCopy: TMemoryStream;
begin
  if (Mode=bmRead) and not Field.IsNull then
  begin
    Field.GetData(@BlobMemoryStream);
    BlobMemoryStreamCopy:=TMemoryStream.Create;
    if BlobMemoryStream<>nil then
      BlobMemoryStreamCopy.LoadFromStream(BlobMemoryStream);
    Result:=BlobMemoryStreamCopy;
  end
  else
    Result:=nil;
end;

procedure TODBCConnection.FreeFldBuffers(cursor: TSQLCursor);
var
  ODBCCursor:TODBCCursor;
  i: integer;
begin
  ODBCCursor:=cursor as TODBCCursor;
  
  // Free TMemoryStreams in cursor.FBlobStreams and clear it
  for i:=0 to ODBCCursor.FBlobStreams.Count-1 do
    TObject(ODBCCursor.FBlobStreams[i]).Free;
  ODBCCursor.FBlobStreams.Clear;

  ODBCCheckResult(
    SQLFreeStmt(ODBCCursor.FSTMTHandle, SQL_CLOSE),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not close ODBC statement cursor.'
  );
end;

procedure TODBCConnection.AddFieldDefs(cursor: TSQLCursor; FieldDefs: TFieldDefs);
const
  ColNameDefaultLength  = 40; // should be > 0, because an ansistring of length 0 is a nil pointer instead of a pointer to a #0
  TypeNameDefaultLength = 80; // idem
var
  ODBCCursor:TODBCCursor;
  ColumnCount:SQLSMALLINT;
  i:integer;
  ColNameLength,TypeNameLength,DataType,DecimalDigits,Nullable:SQLSMALLINT;
  ColumnSize:SQLUINTEGER;
  ColName,TypeName:string;
  FieldType:TFieldType;
  FieldSize:word;
begin
  ODBCCursor:=cursor as TODBCCursor;

  // get number of columns in result set
  ODBCCheckResult(
    SQLNumResultCols(ODBCCursor.FSTMTHandle, ColumnCount),
    SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, 'Could not determine number of columns in result set.'
  );

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
      SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not get column properties for column %d.',[i])
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
        SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not get column name for column %d.',[i])
      );
    end;

    // convert type
    // NOTE: I made some guesses here after I found only limited information about TFieldType; please report any problems
    case DataType of
      SQL_CHAR:          begin FieldType:=ftFixedChar;  FieldSize:=ColumnSize+1; end;
      SQL_VARCHAR:       begin FieldType:=ftString;     FieldSize:=ColumnSize+1; end;
      SQL_LONGVARCHAR:   begin FieldType:=ftMemo;       FieldSize:=sizeof(pointer); end; // is a blob
      SQL_WCHAR:         begin FieldType:=ftWideString; FieldSize:=ColumnSize+1; end;
      SQL_WVARCHAR:      begin FieldType:=ftWideString; FieldSize:=ColumnSize+1; end;
      SQL_WLONGVARCHAR:  begin FieldType:=ftMemo;       FieldSize:=sizeof(pointer); end; // is a blob
      SQL_DECIMAL:       begin FieldType:=ftFloat;      FieldSize:=0; end;
      SQL_NUMERIC:       begin FieldType:=ftFloat;      FieldSize:=0; end;
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
      SQL_LONGVARBINARY: begin FieldType:=ftBlob;       FieldSize:=sizeof(pointer); end; // is a blob
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
{      SQL_GUID:          begin FieldType:=ftGuid;       FieldSize:=ColumnSize; end; } // no TGuidField exists yet in the db unit
    else
      begin FieldType:=ftUnknown; FieldSize:=ColumnSize; end
    end;

    if (FieldType in [ftString,ftFixedChar]) and // field types mapped to TStringField
       (FieldSize >= dsMaxStringSize) then
    begin
      FieldSize:=dsMaxStringSize-1;
    end;
    
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
        SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not get datasource dependent type name for column %s.',[ColName])
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
          SQL_HANDLE_STMT, ODBCCursor.FSTMTHandle, Format('Could not get datasource dependent type name for column %s.',[ColName])
        );
      end;

      DatabaseErrorFmt('Column %s has an unknown or unsupported column type. Datasource dependent type name: %s. ODBC SQL data type code: %d.', [ColName, TypeName, DataType]);
    end;

    // add FieldDef
    TFieldDef.Create(FieldDefs, ColName, FieldType, FieldSize, False, i);
  end;
end;

procedure TODBCConnection.UpdateIndexDefs(var IndexDefs: TIndexDefs; 
                                    const TableName: string);
begin
  inherited UpdateIndexDefs(IndexDefs, TableName);
  // TODO: implement this
end;

function TODBCConnection.GetSchemaInfoSQL(SchemaType: TSchemaType; SchemaObjectName, SchemaObjectPattern: string): string;
begin
  Result:=inherited GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaObjectPattern);
  // TODO: implement this
end;

{ TODBCEnvironment }

constructor TODBCEnvironment.Create;
begin
  // make sure odbc is loaded
  if ODBCLoadCount=0 then InitialiseOdbc;
  Inc(ODBCLoadCount);

  // allocate environment handle
  if SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, FENVHandle)=SQL_Error then
    raise EODBCException.Create('Could not allocate ODBC Environment handle'); // we can't retrieve any more information, because we don't have a handle for the SQLGetDiag* functions

  // set odbc version
  ODBCCheckResult(
    SQLSetEnvAttr(FENVHandle, SQL_ATTR_ODBC_VERSION, SQLPOINTER(SQL_OV_ODBC3), 0),
    SQL_HANDLE_ENV, FENVHandle,'Could not set ODBC version to 3.'
  );
end;

destructor TODBCEnvironment.Destroy;
var
  Res:SQLRETURN;
begin
  // free environment handle
  Res:=SQLFreeHandle(SQL_HANDLE_ENV, FENVHandle);
  if Res=SQL_ERROR then
    ODBCCheckResult(Res,SQL_HANDLE_ENV, FENVHandle, 'Could not free ODBC Environment handle.');

  // free odbc if not used by any TODBCEnvironment object anymore
  Dec(ODBCLoadCount);
  if ODBCLoadCount=0 then ReleaseOdbc;
end;

{ TODBCCursor }

constructor TODBCCursor.Create(const aquery: tsqlquery;
                                         const Connection:TODBCConnection);
begin
 inherited create(aquery);
  // allocate statement handle
  ODBCCheckResult(
    SQLAllocHandle(SQL_HANDLE_STMT, Connection.FDBCHandle, FSTMTHandle),
    SQL_HANDLE_DBC, Connection.FDBCHandle, 'Could not allocate ODBC Statement handle.'
  );
  
  // allocate FBlobStreams
  FBlobStreams:=TList.Create;
end;

destructor TODBCCursor.Destroy;
var
  Res:SQLRETURN;
begin
  inherited Destroy;
  
  FBlobStreams.Free;

  if pointer(FSTMTHandle) <> pointer(SQL_INVALID_HANDLE) then
  begin
    // deallocate statement handle
    Res:=SQLFreeHandle(SQL_HANDLE_STMT, FSTMTHandle);
    if Res=SQL_ERROR then
      ODBCCheckResult(Res,SQL_HANDLE_STMT, FSTMTHandle, 'Could not free ODBC Statement handle.');
  end;
end;

{ finalization }

finalization

  if Assigned(DefaultEnvironment) then
    DefaultEnvironment.Free;

end.

