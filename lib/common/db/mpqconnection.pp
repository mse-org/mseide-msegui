unit mpqconnection;

{$mode objfpc}{$H+}

{$Define LinkDynamically}

interface

uses
  Classes, SysUtils, msqldb, db, dbconst,
{$IfDef LinkDynamically}
  postgres3dyn;
{$Else}
  postgres3;
{$EndIf}

type
  TPQTrans = Class(TSQLHandle)
    protected
    PGConn        : PPGConn;
    ErrorOccured  : boolean;
  end;

  TPQCursor = Class(TSQLCursor)
    protected
    Statement : string;
    tr        : TPQTrans;
    res       : PPGresult;
    CurTuple  : integer;
    Nr        : string;
  end;

  { TPQConnection }

 TPQConnection = class (TSQLConnection,iblobconnection)
  private
   FCursorCount         : word;
   FConnectString       : string;
   FSQLDatabaseHandle   : pointer;
   FIntegerDateTimes    : boolean;
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
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                      const acursor: tsqlcursor): TStream; override;
          //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
             const tablename: string; const acursor: tsqlcursor;
             const adata: pointer; const alength: integer;
             const afield: tfield; const aparam: tparam;
             out newid: string);
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                                   const aparam: tparam);
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

uses 
 math,msestrings,msestream,msetypes;

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
      Oid_bytea = 17;
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
      
 inv_read =  $40000;
 inv_write = $20000;
 invalidoid = 0;
 
constructor TPQConnection.Create(AOwner : TComponent);

begin
  inherited;
  FConnOptions := FConnOptions + [sqSupportParams];
end;

function TPQConnection.GetTransactionHandle(trans : TSQLHandle): pointer;
begin
  Result := trans;
end;

function TPQConnection.RollBack(trans : TSQLHandle) : boolean;
var
  res : PPGresult;
  tr  : TPQTrans;
begin
  result := false;

  tr := trans as TPQTrans;

  res := PQexec(tr.PGConn, 'ROLLBACK');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    result := false;
    DatabaseError(SErrRollbackFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self);
    end
  else
    begin
    PQclear(res);
    PQFinish(tr.PGConn);
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

  res := PQexec(tr.PGConn, 'COMMIT');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    result := false;
    DatabaseError(SErrCommitFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self);
    end
  else
    begin
    PQclear(res);
    PQFinish(tr.PGConn);
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

  tr.PGConn := PQconnectdb(pchar(FConnectString));

  if (PQstatus(tr.PGConn) = CONNECTION_BAD) then
    begin
    result := false;
    PQFinish(tr.PGConn);
    DatabaseError(SErrConnectionFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self);
    end
  else
    begin
    tr.ErrorOccured := False;
    res := PQexec(tr.PGConn, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      result := false;
      PQclear(res);
      msg := PQerrorMessage(tr.PGConn);
      PQFinish(tr.PGConn);
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
  res := PQexec(tr.PGConn, 'ROLLBACK');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    DatabaseError(SErrRollbackFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self);
    end
  else
    begin
    PQclear(res);
    res := PQexec(tr.PGConn, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      PQclear(res);
      msg := PQerrorMessage(tr.PGConn);
      PQFinish(tr.PGConn);
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
  res := PQexec(tr.PGConn, 'COMMIT');
  if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
    begin
    PQclear(res);
    DatabaseError(SErrCommitFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self);
    end
  else
    begin
    PQclear(res);
    res := PQexec(tr.PGConn, 'BEGIN');
    if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
      begin
      PQclear(res);
      msg := PQerrorMessage(tr.PGConn);
      PQFinish(tr.PGConn);
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
// This does only work for pg>=8.0, so timestamps won't work with earlier versions of pg which are compiled with integer_datetimes on
  FIntegerDatetimes := pqparameterstatus(FSQLDatabaseHandle,'integer_datetimes') = 'on';
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
    Oid_bytea              : result := ftBlob;
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

procedure TPQConnection.PrepareStatement(cursor: TSQLCursor;
            ATransaction : TSQLTransaction;buf : string; AParams : TParams);

const TypeStrings : array[TFieldType] of string =
    (
      'Unknown',  //ftUnknown
      'text',     //ftString 
      'int',      //ftSmallint
      'int',      //ftInteger
      'int',      //ftWord
      'bool',     //ftBoolean
      'float',    //ftFloat
      'numeric',  //ftCurrency
      'numeric',  //ftBCD
      'date',     //ftDate
      'time',     //ftTime
      'timestamp',//ftDateTime
      'Unknown',  //ftBytes
      'Unknown',  //ftVarBytes
      'Unknown',  //ftAutoInc
      'bytea',    //ftBlob
      'text',     //ftMemo
      'bytea',    //ftGraphic
      'Unknown',  //ftFmtMemo
      'Unknown',  //ftParadoxOle
      'Unknown',  //ftDBaseOle
      'Unknown',  //ftTypedBinary
      'Unknown',  //ftCursor
      'Unknown',  //ftFixedChar
      'Unknown',  //ftWideString
      'int',      //ftLargeint
      'Unknown',  //ftADT
      'Unknown',  //ftArray
      'Unknown',  //ftReference
      'Unknown',  //ftDataSet
      'Unknown',  //ftOraBlob
      'Unknown',  //ftOraClob
      'Unknown',  //ftVariant
      'Unknown',  //ftInterface
      'Unknown',  //ftIDispatch
      'Unknown',  //ftGuid
      'Unknown',  //ftTimeStamp
      'Unknown'   //ftFMTBcd
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
    if FStatementType in [stInsert,stUpdate,stDelete, stSelect] then
      begin
      tr := TPQTrans(aTransaction.Handle);
      // Only available for pq 8.0, so don't use it...
      // Res := pqprepare(tr,'prepst'+name+nr,pchar(buf),params.Count,pchar(''));
      s := 'prepare prepst'+nr+' ';
      if Assigned(AParams) and (AParams.count > 0) then begin
       s:= s + '(';
       for i := 0 to AParams.count-1 do begin
        if TypeStrings[AParams[i].DataType] <> 'Unknown' then begin
         s:= s + TypeStrings[AParams[i].DataType] + ','
        end
        else begin
         if AParams[i].DataType = ftUnknown then begin
          DatabaseErrorFmt(SUnknownParamFieldType,[AParams[i].Name],self);
         end
         else begin
          DatabaseErrorFmt(SUnsupportedParameter,
                       [Fieldtypenames[AParams[i].DataType]],self);
         end;
        end;
       end;
       s[length(s)]:= ')';
       buf := AParams.ParseSQL(buf,false,psPostgreSQL);
      end;
      s:= s + ' as ' + buf;
      res := pqexec(tr.PGConn,pchar(s));
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrPrepareFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self)
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
    if not tr.ErrorOccured then
      begin
      res := pqexec(tr.PGConn,pchar('deallocate prepst'+nr));
      if (PQresultStatus(res) <> PGRES_COMMAND_OK) then
        begin
        pqclear(res);
        DatabaseError(SErrPrepareFailed + ' (PostgreSQL: ' + PQerrorMessage(tr.PGConn) + ')',self)
        end;
      pqclear(res);
      end;
    FPrepared := False;
    end;
end;

procedure TPQConnection.FreeFldBuffers(cursor : TSQLCursor);

begin
// Do nothing
end;

procedure TPQConnection.Execute(cursor: TSQLCursor;atransaction:tSQLtransaction;
                           AParams : TParams);

var
 ar: array of pointer;
 i: integer;
 s: string;
 lengths,formats: integerarty;

begin
 with cursor as TPQCursor do begin
  if FStatementType in [stInsert,stUpdate,stDelete,stSelect] then begin
   if Assigned(AParams) and (AParams.count > 0) then begin
    setlength(ar,Aparams.count);
    setlength(lengths,length(ar));
    setlength(formats,length(ar));
    for i := 0 to AParams.count -1 do begin
     with AParams[i] do begin
      if not IsNull then begin
       case DataType of
        ftdatetime: s:= formatdatetime('YYYY-MM-DD',AParams[i].AsDateTime);
        ftdate: s:= formatdatetime('YYYY-MM-DD',AParams[i].AsDateTime);
        else begin
         s:= AParams[i].asstring;
         if datatype = ftblob then begin
          lengths[i]:= length(s);
          formats[i]:= 1; //binary
         end;
        end;
       end; {case}
       GetMem(ar[i],length(s)+1);
       StrMove(PChar(ar[i]),Pchar(s),Length(S)+1);
      end
      else begin
       FreeAndNil(ar[i]);
      end;
     end;
    end;
    res := PQexecPrepared(tr.PGConn,pchar('prepst'+nr),Aparams.count,@Ar[0],
             pointer(lengths),pointer(formats),1);
    for i := 0 to AParams.count -1 do begin
     FreeMem(ar[i]);
    end;
   end
   else begin
    res := PQexecPrepared(tr.PGConn,pchar('prepst'+nr),0,nil,nil,nil,1);
   end;
  end
  else begin
    tr := TPQTrans(aTransaction.Handle);

    s := statement;
    //Should be altered, just like in TSQLQuery.ApplyRecUpdate
    if assigned(AParams) then for i := 0 to AParams.count-1 do
      s := stringreplace(s,':'+AParams[i].Name,AParams[i].asstring,[rfReplaceAll,rfIgnoreCase]);
    res := pqexec(tr.PGConn,pchar(s));
  end;
  if not (PQresultStatus(res) in [PGRES_COMMAND_OK,PGRES_TUPLES_OK]) then begin
      s := PQerrorMessage(tr.PGConn);
      pqclear(res);

      tr.ErrorOccured := True;
// Don't perform the rollback, only make it possible to do a rollback.
// The other databases also don't do this.
//      atransaction.Rollback;
      DatabaseError(SErrExecuteFailed + ' (PostgreSQL: ' + s + ')',self);
  end;
 end;
end;


procedure TPQConnection.AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs);
var
  i         : integer;
  size      : integer;
  st        : string;
  fieldtype : tfieldtype;
  nFields   : integer;

begin
 with tpqcursor(cursor) do begin
  nFields:= PQnfields(Res);
  for i:= 0 to nFields-1 do begin
   size:= PQfsize(Res,i);
   fieldtype:= TranslateFldType(PQftype(Res,i));
   case fieldtype of
    ftstring: begin
     if size = -1 then begin
      size:= pqfmod(res,i)-4;
      if size = -5 then begin
       fieldtype:= ftmemo;
       size:= blobidsize;
//       size:= dsMaxStringSize;
      end;
     end;
    end;
    ftdate: begin
     size:= sizeof(double);
    end;
    ftblob,ftmemo: begin
     size:= blobidsize;
    end;
   end;
   TFieldDef.Create(FieldDefs,PQfname(Res,i),fieldtype,size,False,(i+1));
  end;
  CurTuple:= -1;
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
    inc(CurTuple);
    Result := (PQntuples(res)>CurTuple);
    end;
end;

function TPQConnection.LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer) : boolean;

type TNumericRecord = record
       Digits : SmallInt;
       Weight : SmallInt;
       Sign   : SmallInt;
       Scale  : Smallint;
     end;

var
  x,i           : integer;
  li            : Longint;
  CurrBuff      : pchar;
  tel           : byte;
  dbl           : pdouble;
  cur           : currency;
  NumericRecord : ^TNumericRecord;
 int1: integer;
 
begin
  with cursor as TPQCursor do
    begin
    for x := 0 to PQnfields(res)-1 do
      if PQfname(Res, x) = FieldDef.Name then break;

    if PQfname(Res, x) <> FieldDef.Name then
      DatabaseErrorFmt(SFieldNotFound,[FieldDef.Name],self);

    if pqgetisnull(res,CurTuple,x)=1 then
      result := false
    else
      begin
      i := PQfsize(res, x);
      CurrBuff := pqgetvalue(res,CurTuple,x);

      result := true;

      case FieldDef.DataType of
        ftInteger, ftSmallint, ftLargeInt,ftfloat :
          begin
          case i of               // postgres returns big-endian numbers
            sizeof(int64) : pint64(buffer)^ := BEtoN(pint64(CurrBuff)^);
            sizeof(integer) : pinteger(buffer)^ := BEtoN(pinteger(CurrBuff)^);
            sizeof(smallint) : psmallint(buffer)^ := BEtoN(psmallint(CurrBuff)^);
          else
            for tel := 1 to i do
              pchar(Buffer)[tel-1] := CurrBuff[i-tel];
          end; {case}
          end;
        ftString  :
          begin
          li := pqgetlength(res,curtuple,x);
          Move(CurrBuff^, Buffer^, li);
          pchar(Buffer + li)^ := #0;
          i := pqfmod(res,x)-3;
          end;
        ftblob,ftmemo: begin
         li := pqgetlength(res,curtuple,x);
         int1:= addblobdata(currbuff,li);
         move(int1,buffer^,sizeof(int1));
          //save id
        end;
        ftdate :
          begin
          dbl := pointer(buffer);
          dbl^ := BEtoN(plongint(CurrBuff)^) + 36526;
          i := sizeof(double);
          end;
        ftDateTime, fttime :
          begin
          pint64(buffer)^ := BEtoN(pint64(CurrBuff)^);
          dbl := pointer(buffer);
          if FIntegerDatetimes then dbl^ := pint64(buffer)^/1000000;
          dbl^ := (dbl^+3.1558464E+009)/86400;  // postgres counts seconds elapsed since 1-1-2000
          // Now convert the mathematically-correct datetime to the
          // illogical windows/delphi/fpc TDateTime:
          if (dbl^ <= 0) and (frac(dbl^)<0) then
            dbl^ := trunc(dbl^)-2-frac(dbl^);
          end;
        ftBCD:
          begin
          NumericRecord := pointer(CurrBuff);
          NumericRecord^.Digits := BEtoN(NumericRecord^.Digits);
          NumericRecord^.Scale := BEtoN(NumericRecord^.Scale);
          NumericRecord^.Weight := BEtoN(NumericRecord^.Weight);
          inc(pointer(currbuff),sizeof(TNumericRecord));
          cur := 0;
          if (NumericRecord^.Digits = 0) and (NumericRecord^.Scale = 0) then // = NaN, which is not supported by Currency-type, so we return NULL
            result := false
          else
            begin
            for tel := 1 to NumericRecord^.Digits  do
              begin
              cur := cur + beton(pword(currbuff)^) * intpower(10000,-(tel-1)+NumericRecord^.weight);
              inc(pointer(currbuff),2);
              end;
            if BEtoN(NumericRecord^.Sign) <> 0 then cur := -cur;
            Move(Cur, Buffer^, sizeof(currency));
            end;
          end;
        ftBoolean:
          pchar(buffer)[0] := CurrBuff[0]
        else
          result := false;
      end;
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

function TPQConnection.CreateBlobStream(const Field: TField;
        const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
var
 blobid: integer;
 int1,int2: integer;
 str1: string;
 bo1: boolean;
begin
 result:= nil;
 if mode = bmread then begin
  if field.getData(@blobId) then begin
   result:= tstringcopystream.create(acursor.fblobs[blobid]);
  end;
 end;
end;

procedure TPQConnection.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const acursor: tsqlcursor;
               const adata: pointer; const alength: integer;
               const afield: tfield; const aparam: tparam;
               out newid: string);
var
 str1: string;
 int1: integer;
begin
{
 if alength = 0 then begin
  aparam.clear;
  newid:= '';
 end
 else begin
 }
  setlength(str1,alength);
  move(adata^,str1[1],alength);
  if afield.datatype = ftmemo then begin
   aparam.asstring:= str1;
  end
  else begin
   aparam.asblob:= str1;
  end;
  int1:= acursor.addblobdata(str1);
  setlength(newid,sizeof(int1));
  move(int1,newid[1],sizeof(int1));
// end;
end;

procedure TPQConnection.setupblobdata(const afield: tfield; 
                      const acursor: tsqlcursor; const aparam: tparam);
begin
 acursor.blobfieldtoparam(afield,aparam,afield.datatype = ftmemo);
end;

{
procedure TPQConnection.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const adata: pointer;
               const alength: integer; const aparam: tparam);
               
var
 started: boolean;
 
 procedure endtrans;
 var
  res: ppgresult;
 begin
  res:= pqexec(fsqldatabasehandle,'END');
  pqclear(res);
 end;
 
 procedure doerror;
 begin
  if started then begin
   endtrans;
  end;
  databaseerror('TPQConnection blob write error.');
 end;

 procedure checkerror(const aresult: ppgresult);
 begin
  if PQresultStatus(aresult) <> PGRES_COMMAND_OK then begin
   pqclear(aresult);
   doerror;
  end; 
  pqclear(aresult);
 end;
  
var
 blobid: oid;
 fd: integer;
 int1,int2: integer;
begin
 if alength = 0 then begin
  aparam.clear;
 end
 else begin
  started:= false;
  checkerror(pqexec(fsqldatabasehandle,'BEGIN'));
  started:= true;
  blobid:= lo_creat(fsqldatabasehandle,inv_read or inv_write);
  if blobid = invalidoid then begin
   doerror;
  end;
  fd:= lo_open(fsqldatabasehandle,blobid,inv_write);
  if fd = -1 then begin
   doerror;
  end;
  int1:= alength;
  while int1 > 0 do begin
   int2:= lo_write(fsqldatabasehandle,fd,adata,int1);
   if int2 < 0 then begin
    doerror;
   end;
   dec(int1,int2);
  end; 
  lo_close(fsqldatabasehandle,fd);
  endtrans;
  aparam.asinteger:= blobid;
 end;
end;
}

end.
