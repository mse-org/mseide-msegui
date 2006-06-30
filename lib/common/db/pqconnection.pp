unit pqconnection;

{$mode objfpc}{$H+}

{$Define LinkDynamically}

interface

uses
  Classes, SysUtils, sqldb, db, dbconst,
{$IfDef LinkDynamically}
  postgres3dyn;
{$Else}
  postgres3;
{$EndIf}

type
  TPQTrans = Class(TSQLHandle)
    protected
    TransactionHandle   : PPGConn;
  end;

  TPQCursor = Class(TSQLCursor)
    protected
    Statement : string;
    tr        : Pointer;
    nFields   : integer;
    res       : PPGresult;
    Nr        : string;
  end;

  { TPQConnection }

  TPQConnection = class (TSQLConnection)
  private
    FCursorCount         : word;
    FConnectString       : string;
    FSQLDatabaseHandle   : pointer;
    function TranslateFldType(Type_Oid : integer) : TFieldType;
  protected
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetHandle : pointer; override;

    Function AllocateCursorHandle : TSQLCursor; override;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
    Function AllocateTransactionHandle : TSQLHandle; override;

    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); override;
    procedure FreeFldBuffers(cursor : TSQLCursor); override;
    procedure Execute(cursor: TSQLCursor;atransaction:tSQLtransaction; AParams : TParams); override;
    procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); override;
    function Fetch(cursor : TSQLCursor) : boolean; override;
    procedure UnPrepareStatement(cursor : TSQLCursor); override;
    function LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer) : boolean; override;
    function GetTransactionHandle(trans : TSQLHandle): pointer; override;
    function RollBack(trans : TSQLHandle) : boolean; override;
    function Commit(trans : TSQLHandle) : boolean; override;
    procedure CommitRetaining(trans : TSQLHandle); override;
    function StartdbTransaction(trans : TSQLHandle; AParams : string) : boolean; override;
    procedure RollBackRetaining(trans : TSQLHandle); override;
    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string); override;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; override;
  public
    constructor Create(AOwner : TComponent); override;
  published
    property DatabaseName;
    property KeepConnection;
    property LoginPrompt;
    property Params;
    property OnLogin;
  end;

implementation

ResourceString
  SErrRollbackFailed = 'Rollback transaction failed';
  SErrCommitFailed = 'Commit transaction failed';
  SErrConnectionFailed = 'Connection to database failed';
  SErrTransactionFailed = 'Start of transacion failed';
  SErrClearSelection = 'Clear of selection failed';
  SErrExecuteFailed = 'Execution of query failed';
  SErrFieldDefsFailed = 'Can not extract field information from query';
  SErrFetchFailed = 'Fetch of data failed';
  SErrPrepareFailed = 'Preparation of query failed.';

const Oid_Bool     = 16;
      Oid_Text     = 25;
      Oid_Oid      = 26;
      Oid_Name     = 19;
      Oid_Int8     = 20;
      Oid_int2     = 21;
      Oid_Int4     = 23;
      Oid_Float4   = 700;
      Oid_Float8   = 701;
      Oid_Unknown  = 705;
      Oid_bpchar   = 1042;
      Oid_varchar  = 1043;
      Oid_timestamp = 1114;
      oid_date      = 1082;
      oid_time      = 1083;
      oid_numeric   = 1700;

constructor TPQConnection.Create(AOwner : TComponent);

begin
  inherited;
  FConnOptions := FConnOptions + [sqSupportParams];
end;

function TPQConnection.GetTransactionHandle(trans : TSQLHandle): pointer;
begin
  Result := (trans as TPQtrans).TransactionHandle;
end;

function TPQConnection.RollBack(trans : TSQLHandle) : boolean;
var
  res : PPGresult;
  tr  : TPQTrans;
begin
  result := false;

  tr := trans as TPQTrans;

  res := PQexec(tr.TransactionHandle, 'ROLLBACK');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    result := false;
    DatabaseError(SErrRollbackFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.transactionhandle) + ')',self);
    end
  else
    begin
    PQclear(res);
    PQFinish(tr.TransactionHandle);
    result := true;
    end;
end;

function TPQConnection.Commit(trans : TSQLHandle) : boolean;
var
  res : PPGresult;
  tr  : TPQTrans;
begin
  result := false;

  tr := trans as TPQTrans;

  res := PQexec(tr.TransactionHandle, 'COMMIT');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    result := false;
    DatabaseError(SErrCommitFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.transactionhandle) + ')',self);
    end
  else
    begin
    PQclear(res);
    PQFinish(tr.TransactionHandle);
    result := true;
    end;
end;

function TPQConnection.StartdbTransaction(trans : TSQLHandle; AParams : string) : boolean;
var
  res : PPGresult;
  tr  : TPQTrans;
  msg : string;
begin
  result := false;

  tr := trans as TPQTrans;

  tr.TransactionHandle := PQconnectdb(pchar(FConnectString));

  if (PQstatus(tr.TransactionHandle) = CONNECTION_BAD) then
    begin
    result := false;
    PQFinish(tr.TransactionHandle);
    DatabaseError(SErrConnectionFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.transactionhandle) + ')',self);
    end
  else
    begin
    res := PQexec(tr.TransactionHandle, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      result := false;
      PQclear(res);
      msg := PQerrorMessage(tr.transactionhandle);
      PQFinish(tr.TransactionHandle);
      DatabaseError(sErrTransactionFailed + ' (PostgreSQL: ' + msg + ')',self);
      end
    else
      begin
      PQclear(res);
      result := true;
      end;
    end;
end;

procedure TPQConnection.RollBackRetaining(trans : TSQLHandle);
var
  res : PPGresult;
  tr  : TPQTrans;
  msg : string;
begin
  tr := trans as TPQTrans;
  res := PQexec(tr.TransactionHandle, 'ROLLBACK');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    DatabaseError(SErrRollbackFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.transactionhandle) + ')',self);
    end
  else
    begin
    PQclear(res);
    res := PQexec(tr.TransactionHandle, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      PQclear(res);
      msg := PQerrorMessage(tr.transactionhandle);
      PQFinish(tr.TransactionHandle);
      DatabaseError(sErrTransactionFailed + ' (PostgreSQL: ' + msg + ')',self);
      end
    else
      PQclear(res);
    end;
end;

procedure TPQConnection.CommitRetaining(trans : TSQLHandle);
var
  res : PPGresult;
  tr  : TPQTrans;
  msg : string;
begin
  tr := trans as TPQTrans;
  res := PQexec(tr.TransactionHandle, 'COMMIT');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    DatabaseError(SErrCommitFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.transactionhandle) + ')',self);
    end
  else
    begin
    PQclear(res);
    res := PQexec(tr.TransactionHandle, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      PQclear(res);
      msg := PQerrorMessage(tr.transactionhandle);
      PQFinish(tr.TransactionHandle);
      DatabaseError(sErrTransactionFailed + ' (PostgreSQL: ' + msg + ')',self);
      end
    else
      PQclear(res);
    end;
end;


procedure TPQConnection.DoInternalConnect;

var msg : string;

begin
{$IfDef LinkDynamically}
  InitialisePostgres3;
{$EndIf}

  inherited dointernalconnect;

  FConnectString := '';
  if (UserName <> '') then FConnectString := FConnectString + ' user=''' + UserName + '''';
  if (Password <> '') then FConnectString := FConnectString + ' password=''' + Password + '''';
  if (HostName <> '') then FConnectString := FConnectString + ' host=''' + HostName + '''';
  if (DatabaseName <> '') then FConnectString := FConnectString + ' dbname=''' + DatabaseName + '''';
  if (Params.Text <> '') then FConnectString := FConnectString + ' '+Params.Text;

  FSQLDatabaseHandle := PQconnectdb(pchar(FConnectString));

  if (PQstatus(FSQLDatabaseHandle) = CONNECTION_BAD) then
    begin
    msg := PQerrorMessage(FSQLDatabaseHandle);
    dointernaldisconnect;
    DatabaseError(sErrConnectionFailed + ' (PostgreSQL: ' + msg + ')',self);
    end;
end;

procedure TPQConnection.DoInternalDisconnect;
begin
  PQfinish(FSQLDatabaseHandle);
{$IfDef LinkDynamically}
  ReleasePostgres3;
{$EndIf}

end;

function TPQConnection.TranslateFldType(Type_Oid : integer) : TFieldType;

begin
  case Type_Oid of
    Oid_varchar,Oid_bpchar,
    Oid_name               : Result := ftstring;
    Oid_text               : Result := ftstring;
    Oid_oid                : Result := ftInteger;
    Oid_int8               : Result := ftLargeInt;
    Oid_int4               : Result := ftInteger;
    Oid_int2               : Result := ftSmallInt;
    Oid_Float4             : Result := ftFloat;
    Oid_Float8             : Result := ftFloat;
    Oid_TimeStamp          : Result := ftDateTime;
    Oid_Date               : Result := ftDate;
    Oid_Time               : Result := ftTime;
    Oid_Bool               : Result := ftBoolean;
    Oid_Numeric            : Result := ftBCD;
    Oid_Unknown            : Result := ftUnknown;
  else
    Result := ftUnknown;
  end;
end;

Function TPQConnection.AllocateCursorHandle : TSQLCursor;

begin
  result := TPQCursor.create;
end;

Procedure TPQConnection.DeAllocateCursorHandle(var cursor : TSQLCursor);

begin
  FreeAndNil(cursor);
end;

Function TPQConnection.AllocateTransactionHandle : TSQLHandle;

begin
  result := TPQTrans.create;
end;

procedure TPQConnection.PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams);

const TypeStrings : array[TFieldType] of string =
    (
      'Unknown',
      'text',
      'int',
      'int',
      'int',
      'bool',
      'float',
      'numeric',
      'numeric',
      'date',
      'time',
      'timestamp',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'int',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown',
      'Unknown'
    );


var s : string;
    i : integer;

begin
  with (cursor as TPQCursor) do
    begin
    FPrepared := False;
    nr := inttostr(FCursorcount);
    inc(FCursorCount);
    // Prior to v8 there is no support for cursors and parameters.
    // So that's not supported.
    if FStatementType = stselect then
      statement := 'DECLARE slctst' + name + nr +' BINARY CURSOR FOR ' + buf
    else if FStatementType in [stInsert,stUpdate,stDelete] then
      begin
      tr := aTransaction.Handle;
      // Only available for pq 8.0, so don't use it...
      // Res := pqprepare(tr,'prepst'+name+nr,pchar(buf),params.Count,pchar(''));
      s := 'prepare prepst'+nr+' ';
      if Assigned(AParams) and (AParams.count > 0) then
        begin
        s := s + '(';
        for i := 0 to AParams.count-1 do
          s := s + TypeStrings[AParams[i].DataType] + ',';
        s[length(s)] := ')';
        buf := AParams.ParseSQL(buf,false,psPostgreSQL);
        end;
      s := s + ' as ' + buf;
      res := pqexec(tr,pchar(s));
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrPrepareFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self)
        end;
      FPrepared := True;
      end
    else
      statement := buf;
    end;
end;

procedure TPQConnection.UnPrepareStatement(cursor : TSQLCursor);

begin
  with (cursor as TPQCursor) do if FPrepared then
    begin
    res := pqexec(tr,pchar('deallocate prepst'+nr));
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      pqclear(res);
      DatabaseError(SErrPrepareFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self)
      end;
    pqclear(res);
    FPrepared := False;
    end;
end;

procedure TPQConnection.FreeFldBuffers(cursor : TSQLCursor);

begin
  with cursor as TPQCursor do
   if (PQresultStatus(res) <> PGRES_FATAL_ERROR) then //Don't try to do anything if the transaction has already encountered an error.
    begin
    if FStatementType = stselect then
      begin
      Res := pqexec(tr,pchar('CLOSE slctst' + name + nr));
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrClearSelection + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self)
        end
      end;
    pqclear(res);
    end;
end;

procedure TPQConnection.Execute(cursor: TSQLCursor;atransaction:tSQLtransaction;AParams : TParams);

var ar  : array of pointer;
    i   : integer;
    s   : string;

begin
  with cursor as TPQCursor do
    begin
    if FStatementType in [stInsert,stUpdate,stDelete] then
      begin
      if Assigned(AParams) and (AParams.count > 0) then
        begin
        setlength(ar,Aparams.count);
        for i := 0 to AParams.count -1 do
          begin
          case AParams[i].DataType of
            ftdatetime : s := formatdatetime('YYYY-MM-DD',AParams[i].AsDateTime);
          else
            s := AParams[i].asstring;
          end; {case}
          GetMem(ar[i],length(s)+1);
          StrMove(PChar(ar[i]),Pchar(s),Length(S)+1);
          end;
        res := PQexecPrepared(tr,pchar('prepst'+nr),Aparams.count,@Ar[0],nil,nil,0);
        for i := 0 to AParams.count -1 do
          FreeMem(ar[i]);
        end
      else
        res := PQexecPrepared(tr,pchar('prepst'+nr),0,nil,nil,nil,0);
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrExecuteFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self);
        end;
      end
    else
      begin
      tr := aTransaction.Handle;

      s := statement;
      //Should be altered, just like in TSQLQuery.ApplyRecUpdate
      if assigned(AParams) then for i := 0 to AParams.count-1 do
        s := stringreplace(s,':'+AParams[i].Name,AParams[i].asstring,[rfReplaceAll,rfIgnoreCase]);
      res := pqexec(tr,pchar(s));
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrExecuteFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self);
        end;
      end;
    end;
end;


procedure TPQConnection.AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs);
var
  i         : integer;
  size      : integer;
  st        : string;
  fieldtype : tfieldtype;
  BaseRes   : PPGresult;

begin
  with cursor as TPQCursor do
    begin
//    BaseRes := pqexecParams(tr,'FETCH 0 IN selectst' + pchar(name) ,0,nil,nil,nil,nil,1);
    st := pchar('FETCH 0 IN slctst' + name+nr);
    BaseRes := pqexec(tr,pchar(st));
    if (PQresultStatus(BaseRes) <> PGRES_TUPLES_OK) then
      begin
      pqclear(BaseRes);
      DatabaseError(SErrFieldDefsFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self)
      end;
    nFields := PQnfields(BaseRes);
    for i := 0 to nFields-1 do
      begin
      size := PQfsize(BaseRes, i);
      fieldtype := TranslateFldType(PQftype(BaseRes, i));

      if (fieldtype = ftstring) and (size = -1) then
        begin
        size := pqfmod(baseres,i)-3;
        if size = -4 then size := dsMaxStringSize;
        end;
      if fieldtype = ftdate  then
        size := sizeof(double);

      TFieldDef.Create(FieldDefs, PQfname(BaseRes, i), fieldtype,size, False, (i + 1));
      end;
    pqclear(baseres);
    end;
end;

function TPQConnection.GetHandle: pointer;
begin
  Result := FSQLDatabaseHandle;
end;

function TPQConnection.Fetch(cursor : TSQLCursor) : boolean;

var st : string;

begin
  with cursor as TPQCursor do
    begin
    st := pchar('FETCH NEXT IN slctst' + name+nr);
    Res := pqexec(tr,pchar(st));
    if (PQresultStatus(res) <> PGRES_TUPLES_OK) then
      begin
      pqclear(Res);
      DatabaseError(SErrfetchFailed + ' (PostgreSQL: ' + PQerrorMessage(tr) + ')',self)
      end;
    Result := (PQntuples(res)<>0);
    end;
end;

function TPQConnection.LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer) : boolean;

var
  x,i          : integer;
  li           : Longint;
  CurrBuff     : pchar;
  tel  : byte;
  dbl  : pdouble;


begin
  with cursor as TPQCursor do
    begin
    for x := 0 to PQnfields(res)-1 do
      if PQfname(Res, x) = FieldDef.Name then break;

    if PQfname(Res, x) <> FieldDef.Name then
      DatabaseErrorFmt(SFieldNotFound,[FieldDef.Name],self);

    if pqgetisnull(res,0,x)=1 then
      result := false
    else
      begin
      i := PQfsize(res, x);
      CurrBuff := pqgetvalue(res,0,x);
{$checkpointer off}
      case FieldDef.DataType of
        ftInteger, ftSmallint, ftLargeInt,ftfloat :
          begin
          for tel := 1 to i do   // postgres returns big-endian numbers
            pchar(Buffer)[tel-1] := CurrBuff[i-tel];
          end;
        ftString  :
          begin
          li := pqgetlength(res,0,x);
          Move(CurrBuff^, Buffer^, li);
          pchar(Buffer + li)^ := #0;
          i := pqfmod(res,x)-3;
          end;
        ftdate :
          begin
          li := 0;
          for tel := 1 to i do   // postgres returns big-endian numbers
            pchar(@li)[tel-1] := CurrBuff[i-tel];
//          double(buffer^) := x + 36526; This doesn't work, please tell me what is wrong with it?
          dbl := pointer(buffer);
          dbl^ := li + 36526;
          i := sizeof(double);
          end;
        ftDateTime, fttime :
          begin
          dbl := pointer(buffer);
          dbl^ := 0;
          for tel := 1 to i do   // postgres returns big-endian numbers
            pchar(Buffer)[tel-1] := CurrBuff[i-tel];

          dbl^ := (dbl^+3.1558464E+009)/86400;  // postgres counts seconds elapsed since 1-1-2000
          end;
        ftBCD:
          begin
          // not implemented
          end;
        ftBoolean:
          pchar(buffer)[0] := CurrBuff[0]
      end;
{$checkpointer default}
      result := true;
      end;
    end;
end;

procedure TPQConnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string);

var qry : TSQLQuery;

begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet);

  qry := tsqlquery.Create(nil);
  qry.transaction := Transaction;
  qry.database := Self;
  with qry do
    begin
    ReadOnly := True;
    sql.clear;

    sql.add('select '+
              'ic.relname as indexname,  '+
              'tc.relname as tablename, '+
              'ia.attname, '+
              'i.indisprimary, '+
              'i.indisunique '+
            'from '+
              'pg_attribute ta, '+
              'pg_attribute ia, '+
              'pg_class tc, '+
              'pg_class ic, '+
              'pg_index i '+
            'where '+
              '(i.indrelid = tc.oid) and '+
              '(ta.attrelid = tc.oid) and '+
              '(ia.attrelid = i.indexrelid) and '+
              '(ic.oid = i.indexrelid) and '+
              '(ta.attnum = i.indkey[ia.attnum-1]) and '+
              '(upper(tc.relname)=''' +  UpperCase(TableName) +''') '+
            'order by '+
              'ic.relname;');
    open;
    end;

  while not qry.eof do with IndexDefs.AddIndexDef do
    begin
    Name := trim(qry.fields[0].asstring);
    Fields := trim(qry.Fields[2].asstring);
    If qry.fields[3].asboolean then options := options + [ixPrimary];
    If qry.fields[4].asboolean then options := options + [ixUnique];
    qry.next;
    while (name = qry.fields[0].asstring) and (not qry.eof) do
      begin
      Fields := Fields + ';' + trim(qry.Fields[2].asstring);
      qry.next;
      end;
    end;
  qry.close;
  qry.free;
end;

function TPQConnection.GetSchemaInfoSQL(SchemaType: TSchemaType;
  SchemaObjectName, SchemaPattern: string): string;

var s : string;

begin
  case SchemaType of
    stTables     : s := 'select '+
                          'relfilenode              as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'relname                  as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'pg_class '+
                        'where '+
                          '(relowner > 1) and relkind=''r''' +
                        'order by relname';

    stSysTables  : s := 'select '+
                          'relfilenode              as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'relname                  as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'pg_class '+
                        'where '+
                          'relkind=''r''' +
                        'order by relname';
  else
    DatabaseError(SMetadataUnavailable)
  end; {case}
  result := s;
end;


end.
