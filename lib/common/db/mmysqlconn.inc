{
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
{Modified 2006-2010 by Martin Schreiber}

{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_3} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_4} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_5} {$define mse_FPC_2_2} {$endif}
{$if FPC_FULLVERSION >= 20300} {$define mse_FPC_2_2} {$endif}

{$mode objfpc}{$H+}
{$MACRO on}

interface

uses
  classes,mclasses,SysUtils,msqldb,mdb,dynlibs,msestrings,msedb,
{$IfDef mysql50}
  mysql50dyn;
  {$DEFINE TConnectionName:=TMySQL50Connection}
  {$DEFINE TTransactionName:=TMySQL50Transaction}
  {$DEFINE TCursorName:=TMySQL50Cursor}
  {$define eerrorname:= emysql50error}
{$ELSE}
  {$IfDef mysql41}
    mysql41dyn;
    {$DEFINE TConnectionName:=TMySQL41Connection}
    {$DEFINE TTransactionName:=TMySQL41Transaction}
    {$DEFINE TCursorName:=TMySQL41Cursor}
    {$define eerrorname:= emysql41error}
  {$ELSE}
    {$IFDEF mysql4} // temporary backwards compatibility for Lazarus
      mysql40dyn;
      {$DEFINE TConnectionName:=TMySQLConnection}
      {$DEFINE TTransactionName:=TMySQLTransaction}
      {$DEFINE TCursorName:=TMySQLCursor}
      {$define eerrorname:= emysqlerror}
    {$ELSE}
      mysql40dyn;
      {$DEFINE TConnectionName:=TMySQL40Connection}
      {$DEFINE TTransactionName:=TMySQL40Transaction}
      {$DEFINE TCursorName:=TMySQL40Cursor}
      {$define eerrorname:= emysql40error}
    {$EndIf}
  {$EndIf}
{$EndIf}

Type

 tcursorname = class;
 
 eerrorname = class(econnectionerror)
  private
   fsqlcode: string;
  public
   constructor create(const asender: tcustomsqlconnection; const amessage: ansistring;
              const aerrormessage: msestring; const aerror: integer; const asqlcode: string);
   property sqlcode: string read fsqlcode;
 end;
  
  TTransactionName = Class(TSQLHandle)
  protected
  end;

  TCursorName = Class(TSQLCursor)
  protected
//    FQMySQL : PMySQL;
    FRes: PMYSQL_RES;                   { Record pointer }
    FNeedData : Boolean;
    fstatementm: msestring;
    Row : MYSQL_ROW;
//    RowsAffected : QWord;
    LastInsertID : QWord;
    ParamBinding : TParamBinding;
    ParamReplaceString : mseString;
    MapDSRowToMSQLRow  : array of integer;
    fprimarykeyfieldname: string;
  end;

  TConnectionName = class (TSQLConnection,iblobconnection)
  private
    FDialect: integer;
    FHostInfo: String;
    FServerInfo: String;
    FMySQL : PMySQL;
{$if fpc_fullversion >= 20401}
{$else}
    FDidConnect : Boolean;
{$endif}
   fport: longword;
   flasterror: integer;
   flasterrormessage: msestring;
   flastsqlcode: string;
    function GetClientInfo: string;
    function GetServerStatus: String;
    procedure ConnectMySQL(var HMySQL : PMySQL;H,U,P : pchar);
    procedure freeresultbuffer(const cursor: tcursorname);
  protected
    Procedure checkerror(const Msg: String);

//   function stringtosqltext(const afeildtype: tfieldtype; const avalue: string): string;
    function StrToStatementType(s : msestring) : TStatementType; override;
    Procedure ConnectToServer; virtual;
    Procedure SelectDatabase; virtual;
//    function MySQLDataType(AType: enum_field_types; ASize, ADecimals: Integer; var NewType: TFieldType; var NewSize: Integer): Boolean;
    function MySQLDataType(const afield: mysql_field; var NewType: TFieldType; var NewSize: Integer): Boolean;
    function MySQLWriteData(const acursor: tsqlcursor; AType: enum_field_types;
                        ASize: Integer;
                        AFieldType: TFieldType;Source, Dest: PChar): Boolean;
    // SQLConnection methods
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetHandle : pointer; override;

//    function GetAsSQLText(Field : TField) : string; overload; override;
//    function GetAsSQLText(Param : TParam) : string; overload; override;


    procedure internalExecute(const cursor: TSQLCursor;
             const atransaction:tSQLtransaction; const AParams : TmseParams;
             const autf8: boolean); override;
    function GetTransactionHandle(trans : TSQLHandle): pointer; override;
    function Commit(trans : TSQLHandle) : boolean; override;
    function RollBack(trans : TSQLHandle) : boolean; override;
    function StartdbTransaction(const trans : TSQLHandle;
                const AParams: tstringlist) : boolean; override;
    procedure internalCommitRetaining(trans : TSQLHandle); override;
    procedure internalRollBackRetaining(trans : TSQLHandle); override;
    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                          const aTableName : string); override;

   function getprimarykeyfield(const atablename: string;
                                 const acursor: tsqlcursor): string; override;
   procedure updateprimarykeyfield(const afield: tfield;
                const atransaction: tsqltransaction); override;
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                         const acursor: tsqlcursor): TStream; override;
   function getblobdatasize: integer; override;
//   function getfeatures(): databasefeaturesty override;
          //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
             const tablename: string; const acursor: tsqlcursor;
             const adata: pointer; const alength: integer;
             const afield: tfield; const aparam: tparam;
             out newid: string);
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                                   const aparam: tparam);
//   function blobscached: boolean;
   function identquotechar: msestring; override;
   
  Public
   constructor create(aowner: tcomponent); override;
    Function AllocateTransactionHandle : TSQLHandle; override;
    Function AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor; override;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
    procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
    procedure UnPrepareStatement(cursor:TSQLCursor); override;
    procedure FreeFldBuffers(cursor : TSQLCursor); override;
    procedure AddFieldDefs(const cursor: TSQLCursor; 
                   const FieldDefs : TfieldDefs); override;
    function Fetch(cursor : TSQLCursor) : boolean; override;
    function loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
   function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; override;
                              //null based
   function getinsertid(const atransaction: tsqltransaction): int64; override;
   Property ServerInfo : String Read FServerInfo;
   Property HostInfo : String Read FHostInfo;
   property ClientInfo: string read GetClientInfo;
   property ServerStatus : String read GetServerStatus;
   property lasterror: integer read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
   property lastsqlcode: string read flastsqlcode;
  published
    property Dialect  : integer read FDialect write FDialect default 0;
    property port: longword read fport write fport default 0;
    property DatabaseName;
    property HostName;
    property KeepConnection;
//    property LoginPrompt;
    property Params;
//    property OnLogin;
  end;

//  EMySQLError = Class(Exception);

implementation
uses 
 dbconst,msebufdataset,msetypes,msesqlresult;
type
 tmsebufdataset1 = class(tmsebufdataset);
 
{ TConnectionName }

Resourcestring
  SErrServerConnectFailed = 'Server connect failed.';
  SErrDatabaseSelectFailed = 'failed to select database: %s';
  SErrDatabaseCreate = 'Failed to create database: %s';
  SErrDatabaseDrop = 'Failed to drop database: %s';
  SErrNoData = 'No data for record';
  SErrExecuting = 'Error executing query: %s';
  SErrFetchingdata = 'Error fetching row data: %s';
  SErrGettingResult = 'Error getting result set: %s';
  SErrNoQueryResult = 'No result from query.';
  SErrNotversion50 = 'TMySQL50Connection can not work with the installed MySQL client version (%s).';
  SErrNotversion41 = 'TMySQL41Connection can not work with the installed MySQL client version (%s).';
  SErrNotversion40 = 'TMySQL40Connection can not work with the installed MySQL client version (%s).';

constructor TConnectionName.create(aowner: tcomponent);
begin
 inherited;
 fconnoptions:= fconnoptions + [sco_supportparams,sco_emulateretaining,
                                                           sco_blobscached];
end;

Procedure tconnectionname.checkerror(const Msg: String);
var
 str1: msestring;
begin
 str1:= connectionmessage(mysql_error(fmysql));
 flasterrormessage:= str1;
 flasterror:= mysql_errno(fmysql);
 flastsqlcode:= strpas(mysql_sqlstate(fmysql));
 raise eerrorname.create(self,format(msg,[str1]),flasterrormessage,
                      flasterror,flastsqlcode);
end;

function TConnectionName.StrToStatementType(s : msestring) : TStatementType;

begin
  S:=Lowercase(s);
  if s = 'show' then exit(stSelect);
  result := inherited StrToStatementType(s);
end;


function TConnectionName.GetClientInfo: string;

{$if fpc_fullversion < 20401}
Var
  B : Boolean;
{$endif}

begin
{$if fpc_fullversion >= 20401}
  // To make it possible to call this if there's no connection yet
  InitialiseMysql;
  Try  
    Result:=strpas(mysql_get_client_info());
  Finally  
    ReleaseMysql;
  end;  
{$else}
  // To make it possible to call this if there's no connection yet
  B:=(MysqlLibraryHandle=Nilhandle);
  If B then
    InitialiseMysql;
  Try  
    Result:=strpas(mysql_get_client_info());
  Finally  
    if B then
      ReleaseMysql;
  end;  
{$endif}
end;

function TConnectionName.GetServerStatus: String;
begin
  CheckConnected;
  Result := mysql_stat(FMYSQL);
end;

procedure TConnectionName.ConnectMySQL(var HMySQL : PMySQL;H,U,P : pchar);

begin
  HMySQL := mysql_init(HMySQL);
  HMySQL:=mysql_real_connect(HMySQL,PChar(H),PChar(U),Pchar(P),Nil,fport,Nil,0);
  If (HMySQL=Nil) then
    databaseerror(SErrServerConnectFailed,Self);
end;
{
function tconnectionname.stringtosqltext(const afieldtype: tfieldtype;
                                                const avalue: string): string;
var 
 esc_str : pchar;
begin
 Getmem(esc_str,length(avalue)*2+1);
 mysql_real_escape_string(FMySQL,esc_str,pchar(str1),length(str1));
 Result := '''' + esc_str + '''';
 Freemem(esc_str);
end;

function TConnectionName.GetAsSQLText(Field : TField) : string;
var 
 esc_str : pchar;
 str1: string;
begin
 if (not assigned(field)) or field.IsNull then begin
  Result := 'Null'
 end
 else begin
  if field.DataType in [ftString,ftmemo,ftblob,ftgraphic] then begin
   result:= stringtosqltext(field.datatype,field.asstring);
  end
  else begin
   Result := inherited GetAsSqlText(field);
  end;
 end;
end;

function TConnectionName.GetAsSQLText(Param: TParam) : string;
var 
 esc_str : pchar;
 str1: string;
begin
 if (not assigned(param)) or param.IsNull then begin
  Result:= 'Null'
 end
 else begin
  if param.DataType in [ftString,ftmemo,ftblob,ftgraphic] then begin
   str1:= param.asstring;
   Getmem(esc_str,length(str1)*4+1);
   mysql_real_escape_string(FMySQL,esc_str,pchar(str1),length(str1));
   Result:= '''' + esc_str + '''';
   Freemem(esc_str);
  end
  else begin
   Result:= inherited GetAsSqlText(Param);
  end;
 end;
end;
}

procedure TConnectionName.ConnectToServer;

Var
  H,U,P : String;

begin
  H:= ansistring(HostName);
  U:= ansistring(UserName);
  P:= ansistring(Password);
  ConnectMySQL(FMySQL,pchar(H),pchar(U),pchar(P));
  FServerInfo := strpas(mysql_get_server_info(FMYSQL));
  FHostInfo := strpas(mysql_get_host_info(FMYSQL));
end;

procedure TConnectionName.SelectDatabase;
begin
  if mysql_select_db(FMySQL,pchar(DatabaseName))<>0 then
    checkerror(SErrDatabaseSelectFailed);
end;

procedure TConnectionName.DoInternalConnect;
begin
{$if fpc_fullversion >= 20401}
{$else}
  FDidConnect:=(MySQLLibraryHandle=NilHandle);
  if FDidConnect then
{$endif}
    InitialiseMysql;
{$IFDEF mysql50}
  if copy(strpas(mysql_get_client_info()),1,3)<>'5.0' then
    Raise EInOutError.CreateFmt(SErrNotversion50,[strpas(mysql_get_client_info())]);
{$ELSE}
  {$IFDEF mysql41}
  if copy(strpas(mysql_get_client_info()),1,3)<>'4.1' then
    Raise EInOutError.CreateFmt(SErrNotversion41,[strpas(mysql_get_client_info())]);
  {$ELSE}
  if copy(strpas(mysql_get_client_info()),1,3)<>'4.0' then
    Raise EInOutError.CreateFmt(SErrNotversion40,[strpas(mysql_get_client_info())]);
  {$ENDIF}
{$ENDIF}
  inherited DoInternalConnect;
  ConnectToServer;
  SelectDatabase;
end;

procedure TConnectionName.DoInternalDisconnect;
begin
  inherited DoInternalDisconnect;
  mysql_close(FMySQL);
  FMySQL:=Nil;
{$if fpc_fullversion >= 20401}
{$else}
  if FDidConnect then
{$endif}
    ReleaseMysql;
end;

function TConnectionName.GetHandle: pointer;
begin
  Result:=FMySQL;
end;

function TConnectionName.AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor;
begin
  Result:=TCursorName.Create(aowner,aname);
end;

Procedure TConnectionName.DeAllocateCursorHandle(var cursor : TSQLCursor);

begin
  FreeAndNil(cursor);
end;

function TConnectionName.AllocateTransactionHandle: TSQLHandle;
begin
//  Result:=TTransactionName.Create;
  Result := nil;
end;

procedure tconnectionname.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);
begin
 With TCursorName(cursor) do begin
  FStatementm:= asql;
  if assigned(AParams) and (AParams.count > 0) then begin
    FStatementm:= AParams.ParseSQL(FStatementm,false,false,false,psSimulated,
                     paramBinding,ParamReplaceString);
  end;
  if FStatementType in datareturningtypes then begin
   FNeedData:=True;
  end;
  fprepared:= true;
 end;
end;

procedure TConnectionName.UnPrepareStatement(cursor: TSQLCursor);
begin
 with tcursorname(cursor) do begin
  fstatementm:= '';
  fprepared:= false;
 end;
end;

procedure tconnectionname.freeresultbuffer(const cursor: tcursorname);
begin
 If (Cursor.FRes<>Nil) then begin
  Mysql_free_result(Cursor.FRes);
  Cursor.FRes:=Nil;
 end;
end;

procedure TConnectionName.FreeFldBuffers(cursor: TSQLCursor);

Var
  C : TCursorName;

begin
  C:= TCursorName(cursor);
  if c.FStatementType in datareturningtypes then
    c.FNeedData:=False;
  freeresultbuffer(c);
  SetLength(c.MapDSRowToMSQLRow,0);
end;

procedure TConnectionName.internalExecute(const  cursor: TSQLCursor;
               const atransaction: tSQLtransaction; const AParams : TmseParams;
               const autf8: boolean);

var
 C: TCursorName;
// i: integer;
 str1: ansistring;
// par1: tparam;
 mstr1: msestring;
begin
  C:= TCursorName(cursor);
  c.frowsaffected:= -1;
  c.frowsreturned:= -1;
  freeresultbuffer(c);
  if Assigned(AParams) and (aparams.count > 0) then begin
   mstr1:= aparams.expandvalues(c.fstatementm,
                          c.parambinding,c.paramreplacestring);
  end
  else begin
   mstr1:= c.fstatementm;
  end;
  if autf8 then begin
   str1:= stringtoutf8ansi(mstr1);
  end
  else begin
   str1:= ansistring(mstr1);
  end;
  
  if mysql_query(FMySQL,Pchar(str1))<>0 then begin
   checkerror(Format(SErrExecuting,[
        ansistring(connectionmessage(mysql_error(FMySQL)))]))
  end
  else begin
   C.fRowsAffected := mysql_affected_rows(FMYSQL);
   C.LastInsertID := mysql_insert_id(FMYSQL);
   if C.FNeedData then begin
    C.FRes:= mysql_store_result(FMySQL);
    c.frowsreturned:= mysql_num_rows(c.fres);
   end
   else begin
    c.frowsreturned:= 0;
   end;
  end;
end;

//function TConnectionName.MySQLDataType(AType: enum_field_types; ASize, ADecimals: Integer;
//   var NewType: TFieldType; var NewSize: Integer): Boolean;
function TConnectionName.MySQLDataType(const afield: mysql_field; var NewType: TFieldType;
                            var NewSize: Integer): Boolean;
begin
  Result := True;
  NewSize:= 0;
  with afield do begin
   case ftype of
    FIELD_TYPE_TINY,FIELD_TYPE_SHORT,FIELD_TYPE_LONG: begin
     NewType:= ftInteger;
    end;
    FIELD_TYPE_LONGLONG,FIELD_TYPE_INT24: begin
     newtype:= ftlargeint;
    end;     
 {$ifdef mysql50}
    FIELD_TYPE_NEWDECIMAL,
 {$endif}
    FIELD_TYPE_DECIMAL: begin
     if Decimals < 5 then begin
      NewType:= ftBCD;
     end
     else begin
      NewType:= ftFloat;
     end;
    end;
    FIELD_TYPE_FLOAT,FIELD_TYPE_DOUBLE: begin
     NewType:= ftFloat;
    end;
    FIELD_TYPE_TIMESTAMP,FIELD_TYPE_DATETIME: begin
     NewType:= ftDateTime;
    end;
    FIELD_TYPE_DATE: begin
     NewType:= ftDate;
    end;
    FIELD_TYPE_TIME: begin
     NewType:= ftTime;
    end;
    FIELD_TYPE_VAR_STRING,FIELD_TYPE_STRING,FIELD_TYPE_ENUM,
                            FIELD_TYPE_SET: begin
     NewType:= ftString;
     NewSize:= length;
    end;
    {$ifdef mysql41}     
    field_type_blob: begin
     newsize:= sizeof(integer);
     if charsetnr = 63 then begin //binary
      newtype:= ftblob;
     end
     else begin 
      newtype:= ftmemo;
     end;
    end;
    {$endif}
   else begin
    Result:= False;
   end;
  end;
 end;
end;

procedure TConnectionName.AddFieldDefs(const cursor: TSQLCursor;
                          const FieldDefs: TfieldDefs);
var
 C: TCursorName;
 I,TF,FC: Integer;
 field: PMYSQL_FIELD;
 DFT: TFieldType;
 DFS: Integer;
 fd: tfielddef;
 str1: ansistring;

begin
 fielddefs.clear;
  C:=(Cursor as TCursorName);
  If (C.FRes=Nil) then begin
    checkerror(SErrNoQueryResult);
  end;
  FC:=mysql_num_fields(C.FRes);
  SetLength(c.MapDSRowToMSQLRow,FC);

  TF := 1;
  For I:= 0 to FC-1 do begin
   field := mysql_fetch_field_direct(C.FRES, I);
   with field^ do begin
    if (flags and (pri_key_flag or auto_increment_flag) = 
              (pri_key_flag or auto_increment_flag)) then begin
     c.fprimarykeyfieldname:= name;
    end;
   end;
   if MySQLDataType(field^,DFT,DFS) then begin
    if (dft = ftmemo) and (cursor.stringmemo) then begin
     dft:= ftstring;
     dfs:= 0;
    end;
    str1:= field^.name;
    if not(dft in varsizefields) then begin
     dfs:= 0;
    end;
    fd:= TFieldDef.Create(nil,str1,DFT,DFS,False,TF);
    fd.collection:= fielddefs;
    
    c.MapDSRowToMSQLRow[TF-1] := I;
    inc(TF);
   end
  end;
end;

function TConnectionName.Fetch(cursor: TSQLCursor): boolean;

Var
  C : TCursorName;

begin
  C:=Cursor as TCursorName;
  C.Row:=MySQL_Fetch_row(C.FRes);
  Result:=(C.Row<>Nil);
end;

function tconnectionname.loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize

var
  field: PMYSQL_FIELD;
  row : MYSQL_ROW;
  C : TCursorName;
  fno: integer;
  alen: integer;
begin
//  Writeln('LoadFieldsFromBuffer');
 result:= false;
 C:= tcursorname(Cursor);
 fno:= fieldnum;
 if C.Row=nil then
    begin
 //   Writeln('LoadFieldsFromBuffer: row=nil');
    checkerror(SErrFetchingData);
    end;
 Row:=C.Row;
 
 inc(Row,c.MapDSRowToMSQLRow[fno]);
 if row^ <> nil then begin
  if buffer = nil then begin
   exit;
  end;
  field:= mysql_fetch_field_direct(C.FRES,c.MapDSRowToMSQLRow[fno]);
  if datatype = ftstring then begin
//   alen:= strlen(row^);
   alen:= mysql_fetch_lengths(c.fres)[c.MapDSRowToMSQLRow[fno]];
   if bufsize < alen then begin 
    bufsize:= -alen;
    result:= true;
    exit;
   end
   else begin
    bufsize:= alen;
   end;
  end
  else begin
   if datatype in [ftmemo,ftgraphic,ftblob] then begin
    alen:= mysql_fetch_lengths(c.fres)[c.MapDSRowToMSQLRow[fno]];
   end
   else begin
    alen:= field^.length;
   end;
  end;
  Result:= MySQLWriteData(cursor, field^.ftype,alen,
       DataType,Row^,Buffer);
 end;
end;

function TConnectionName.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
var
 int1: integer;
 row1: MYSQL_ROW;
begin
 result:= '';
 with tcursorname(cursor) do begin
  if row <> nil then begin
   int1:= MapDSRowToMSQLRow[fieldnum];
   row1:= row;
   inc(row1,int1);
   setlength(result,mysql_fetch_lengths(fres)[int1]);
   if result <> '' then begin
    move(row1^^,result[1],length(result));
   end;
  end;
 end;
end;

function InternalStrToFloat(S: string): Extended;

var
  I: Integer;
  Tmp: string;

begin
  Tmp := '';
  for I := 1 to Length(S) do
    begin
    if not (S[I] in ['0'..'9', '+', '-', 'E', 'e']) then
      Tmp := Tmp + {$ifdef FPC}defaultformatsettings.{$endif}DecimalSeparator
    else
      Tmp := Tmp + S[I];
    end;
  Result := StrToFloat(Tmp);
end;

function InternalStrToCurrency(S: string): Extended;

var
  I: Integer;
  Tmp: string;

begin
  Tmp := '';
  for I := 1 to Length(S) do
    begin
    if not (S[I] in ['0'..'9', '+', '-', 'E', 'e']) then
      Tmp := Tmp + {$ifdef FPC}defaultformatsettings.{$endif}DecimalSeparator
    else
      Tmp := Tmp + S[I];
    end;
  Result := StrToCurr(Tmp);
end;

function InternalStrToDate(S: string): TDateTime;

var
  EY, EM, ED: Word;

begin
  EY := StrToInt(Copy(S,1,4));
  EM := StrToInt(Copy(S,6,2));
  ED := StrToInt(Copy(S,9,2));
  if (EY = 0) or (EM = 0) or (ED = 0) then
    Result:=0
  else
    Result:=EncodeDate(EY, EM, ED);
end;

function InternalStrToDateTime(S: string): TDateTime;

var
  EY, EM, ED: Word;
  EH, EN, ES: Word;

begin
  EY := StrToInt(Copy(S, 1, 4));
  EM := StrToInt(Copy(S, 6, 2));
  ED := StrToInt(Copy(S, 9, 2));
  EH := StrToInt(Copy(S, 12, 2));
  EN := StrToInt(Copy(S, 15, 2));
  ES := StrToInt(Copy(S, 18, 2));
  if (EY = 0) or (EM = 0) or (ED = 0) then
    Result := 0
  else
    Result := EncodeDate(EY, EM, ED);
  Result := Result + EncodeTime(EH, EN, ES, 0);
end;

function InternalStrToTime(S: string): TDateTime;

var
  EH, EM, ES: Word;

begin
  EH := StrToInt(Copy(S, 1, 2));
  EM := StrToInt(Copy(S, 4, 2));
  ES := StrToInt(Copy(S, 7, 2));
  Result := EncodeTime(EH, EM, ES, 0);
end;

function InternalStrToTimeStamp(S: string): TDateTime;

var
  EY, EM, ED: Word;
  EH, EN, ES: Word;

begin
{$IFNDEF mysql40}
  EY := StrToInt(Copy(S, 1, 4));
  EM := StrToInt(Copy(S, 6, 2));
  ED := StrToInt(Copy(S, 9, 2));
  EH := StrToInt(Copy(S, 12, 2));
  EN := StrToInt(Copy(S, 15, 2));
  ES := StrToInt(Copy(S, 18, 2));
{$ELSE}
  EY := StrToInt(Copy(S, 1, 4));
  EM := StrToInt(Copy(S, 5, 2));
  ED := StrToInt(Copy(S, 7, 2));
  EH := StrToInt(Copy(S, 9, 2));
  EN := StrToInt(Copy(S, 11, 2));
  ES := StrToInt(Copy(S, 13, 2));
{$ENDIF}
  if (EY = 0) or (EM = 0) or (ED = 0) then
    Result := 0
  else
    Result := EncodeDate(EY, EM, ED);
  Result := Result + EncodeTime(EH, EN, ES, 0);;
end;

function TConnectionName.MySQLWriteData(const acursor: tsqlcursor; 
                     AType: enum_field_types;ASize: Integer;
                     AFieldType: TFieldType;Source, Dest: PChar): Boolean;

var
 VI: Integer;
 VL: largeint;
 VF: Double;
 VC: Currency;
 VD: TDateTime;
 Src : String;
 int1: integer;
begin
 Result:= False;
 if Source = Nil then begin
  exit;
 end;
 Result:= True;
 case afieldtype of
  ftstring: begin
   Move(Source^, Dest^, ASize)
  end;
  ftblob,ftmemo: begin
   int1:= acursor.addblobdata(source,asize);
   move(int1,dest^,sizeof(int1));
    //save id
  end;
  else begin
   Src:=StrPas(Source);
   case AType of
    FIELD_TYPE_TINY, FIELD_TYPE_SHORT, FIELD_TYPE_LONG,
    FIELD_TYPE_INT24:
      begin
      if (Src<>'') then
        VI := StrToInt(Src)
      else
        VI := 0;
      Move(VI, Dest^, SizeOf(Integer));
      end;
    FIELD_TYPE_LONGLONG:
      begin
      if (Src<>'') then
        VL := StrToInt64(Src)
      else
        VL := 0;
      Move(VL, Dest^, SizeOf(LargeInt));
      end;
{$ifdef mysql50}
    FIELD_TYPE_NEWDECIMAL,
{$endif}      
    FIELD_TYPE_DECIMAL, FIELD_TYPE_FLOAT, FIELD_TYPE_DOUBLE:
      if AFieldType = ftBCD then
        begin
        VC := InternalStrToCurrency(Src);
        Move(VC, Dest^, SizeOf(Currency));
        end
      else
        begin
        if Src <> '' then
          VF := InternalStrToFloat(Src)
        else
          VF := 0;
        Move(VF, Dest^, SizeOf(Double));
        end;
    FIELD_TYPE_TIMESTAMP:
      begin
      if Src <> '' then
        VD := InternalStrToTimeStamp(Src)
      else
        VD := 0;
      Move(VD, Dest^, SizeOf(TDateTime));
      end;
    FIELD_TYPE_DATETIME:
      begin
      if Src <> '' then
        VD := InternalStrToDateTime(Src)
      else
        VD := 0;
      Move(VD, Dest^, SizeOf(TDateTime));
      end;
    FIELD_TYPE_DATE:
      begin
      if Src <> '' then
        VD := InternalStrToDate(Src)
      else
        VD := 0;
      Move(VD, Dest^, SizeOf(TDateTime));
      end;
    FIELD_TYPE_TIME:
      begin
      if Src <> '' then
        VD := InternalStrToTime(Src)
      else
        VD := 0;
      Move(VD, Dest^, SizeOf(TDateTime));
      end;
    FIELD_TYPE_VAR_STRING, FIELD_TYPE_STRING, FIELD_TYPE_ENUM, FIELD_TYPE_SET:
      begin
//      if Src<> '' then
        Move(Source^, Dest^, ASize)
//      else
//        Dest^ := #0;
     end;
    field_type_blob: begin
     int1:= acursor.addblobdata(source,asize);
     move(int1,dest^,sizeof(int1));
      //save id
    end;     
   end;
  end;
 end;
end;

procedure TConnectionName.UpdateIndexDefs(var IndexDefs : TIndexDefs;
                     const aTableName : string);
var 
 qry: tsqlresult;
 keynamef,{filednamef,}columnnamef,nonuniquef: tdbcol;
 str1: string;
begin
 if not assigned(Transaction) then begin
  DatabaseError(SErrConnTransactionnSet);
 end;
 qry:= tsqlresult.Create(nil);
 try
  with qry do begin
   database := Self;
   sql.text:= 'show index from ' +  msestring(aTableName);
   active:= true;
   keynamef:= cols.colbyname('Key_name');
   columnnamef:= cols.colbyname('Column_name');
   nonuniquef:= cols.colbyname('Non_unique');
   while not eof do begin
    with IndexDefs.AddIndexDef do begin
     Name:= trim(keynamef.asstring);
     if Name = 'PRIMARY' then begin
      options:= options + [ixPrimary];
     end;
     if nonuniquef.asinteger = 0 then begin
      options:= options + [ixUnique];
     end;
     str1:= '';
     repeat 
      str1:= str1 + trim(columnnamef.asstring) + ';';
      next;
     until eof or (name <> keynamef.asstring);
     setlength(str1,length(str1)-1); //remove last ';'
     fields:= str1;
    end;
   end;
  end;
 finally
  qry.free;
 end;
end;


function TConnectionName.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
  Result:=Nil;
end;

function TConnectionName.Commit(trans: TSQLHandle): boolean;
begin
 result:= true;
  // Do nothing.
end;

function TConnectionName.RollBack(trans: TSQLHandle): boolean;
begin
 result:= true;
  // Do nothing
end;

function TConnectionName.StartdbTransaction(const trans: TSQLHandle;
              const AParams: tstringlist): boolean;
begin
 result:= true;
  // Do nothing
end;

procedure TConnectionName.internalCommitRetaining(trans: TSQLHandle);
begin
  // Do nothing
end;

procedure TConnectionName.internalRollBackRetaining(trans: TSQLHandle);
begin
  // Do nothing
end;

function TConnectionName.CreateBlobStream(const Field: TField;
               const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
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

function TConnectionName.getblobdatasize: integer;
begin
 result:= sizeof(integer);
end;
{
function TConnectionName.getfeatures(): databasefeaturesty;
begin
 result:= inherited getfeatures() + [dbf_blobscached];
end;
}
procedure TConnectionName.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const acursor: tsqlcursor;
               const adata: pointer; const alength: integer;
               const afield: tfield; const aparam: tparam; out newid: string);
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

procedure TConnectionName.setupblobdata(const afield: tfield;
               const acursor: tsqlcursor; const aparam: tparam);
begin
 acursor.blobfieldtoparam(afield,aparam,false);
end;
{
function TConnectionName.blobscached: boolean;
begin
 result:= true;
end;
}
function TConnectionName.getprimarykeyfield(const atablename: string;
                        const acursor: tsqlcursor): string;
begin
 result:= tcursorname(acursor).fprimarykeyfieldname;
end;

function TConnectionName.getinsertid(const atransaction: tsqltransaction): int64;
begin
 result:= mysql_insert_id(fmysql);
end;

procedure TConnectionName.updateprimarykeyfield(const afield: tfield;
                                             const atransaction: tsqltransaction);
begin
 afield.aslargeint:= getinsertid(nil);
 {
 with tmsebufdataset1(afield.dataset) do begin
  setcurvalue(afield,getinsertid);
 end;
 }
end;

function TConnectionName.identquotechar: msestring;
begin
 result:= '`'; //needed for reserved words as fieldnames
end;

{ eerrorname }

constructor eerrorname.create(const asender: tcustomsqlconnection; 
         const amessage: ansistring; const aerrormessage: msestring;
         const aerror: integer; const asqlcode: string);
begin
 fsqlcode:= asqlcode;
 inherited create(asender,amessage,aerrormessage,aerror);
end;

end.
