{
    Copyright (c) 2004 by Joost van der Sluis
    Modified 2006-2007 by Martin Schreiber
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
 
unit mIBConnection;
{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}

{$mode objfpc}{$H+}

{$Define LinkDynamically}
{$R-}
interface

uses
 Classes,SysUtils,msqldb,db,math,dbconst,msebufdataset,msedbevents,msesys,
 msestrings,msedb,msetypes,
{$IfDef LinkDynamically}
  ibase60dyn;
{$Else}
  ibase60;
{$EndIf}

type
 tibconnection = class;
 statusvectorty = array[0..19] of ISC_STATUS;

 eiberror = class(econnectionerror)
  private
   fstatus: statusvectorty;
   fsqlcode: integer;
  public
   constructor create(const asender: tibconnection; const amessage: msestring;
                              const aerror: statusvectorty; const asqlcode: integer);
   property status: statusvectorty read fstatus;
   property sqlcode: integer read fsqlcode;
 end;
 
  TIBCursor = Class(TSQLCursor)
   protected
    fconnection: tibconnection;
    fopen: boolean;
    Status               : array [0..19] of ISC_STATUS;
    Statement            : pointer;
    SQLDA                : PXSQLDA;
    in_SQLDA             : PXSQLDA;
    ParamBinding         : array of integer;
    paramtypes: fieldtypearty;
   public
    constructor create(const aowner: icursorclient; const aconnection: tibconnection);
    procedure close; override;
  end;

  TIBTrans = Class(TSQLHandle)
    protected
    TransactionHandle   : pointer;
    TPB                 : string;                // Transaction parameter buffer
    Status              : array [0..19] of ISC_STATUS;
  end;

  fbeventbufferty = record
   event: tdbevent;
   name: string;
   length: integer;
   eventbuffer: pchar;
   resultbuffer: pchar;
   id: isc_long;
   count: integer;
  end;
  pfbeventbufferty = ^fbeventbufferty;

  ibconnectionoptionty = (ibo_embedded);
  ibconnectionoptionsty = set of ibconnectionoptionty;
  
  fbversionty = record
   imp: stringarty;
   ods: string;
  end;
  
  TIBConnection = class (TSQLConnection,iblobconnection,
                                               idbevent,idbeventcontroller)
  private
   FSQLDatabaseHandle   : pointer;
   FStatus              : statusvectorty; //array [0..19] of ISC_STATUS;
   FDialect             : integer;
   feventcontroller: tdbeventcontroller;
   feventbuffers: array of pfbeventbufferty;
   feventcount: integer;
   fmutex: mutexty;
   foptions: ibconnectionoptionsty;
   flasterror: statusvectorty;
   flasterrormessage: msestring;
   flastsqlcode: integer;
    procedure SetDBDialect;
    procedure AllocSQLDA(var aSQLDA : PXSQLDA;Count : integer);
    procedure TranslateFldType(SQLType,sqlsubtype,SQLLen,SQLScale: integer;
                 var LensSet: boolean; var TrType: TFieldType; var TrLen: word);
    // conversion methods
    procedure GetDateTime(CurrBuff, Buffer : pointer; AType : integer);
    procedure SetDateTime(CurrBuff: pointer; PTime : TDateTime; AType : integer);
    procedure GetFloat(const CurrBuff,Buffer: pointer; 
                                     const datalength: integer);
    procedure SetFloat(CurrBuff: pointer; Dbl: Double; Size: integer);
    procedure CheckError(const ProcName : string; 
                             const Status : statusvectorty); overload;
    procedure CheckError(const ProcName : string;
                             const Status: integer); overload;
    function getMaxBlobSize(blobHandle : TIsc_Blob_Handle) : longInt;
    procedure SetParameters(cursor : TSQLCursor;AParams : TmseParams);
    procedure FreeSQLDABuffer(var aSQLDA : PXSQLDA);
    function getblobstream(const acursor: tsqlcursor; const blobid: isc_quad;
                       const forstring: boolean = false): tmemorystream;
    function getblobstring(const acursor: tsqlcursor;
                                       const blobid: isc_quad): string;
  protected
   procedure freeeventbuffer(var abuffer: pfbeventbufferty);
   
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetHandle : pointer; override;

    Function AllocateCursorHandle(const aowner: icursorclient;
                       const aname: ansistring): TSQLCursor; override;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
    Function AllocateTransactionHandle : TSQLHandle; override;

    procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
    procedure UnPrepareStatement(cursor : TSQLCursor); override;
    procedure FreeFldBuffers(cursor : TSQLCursor); override;
    procedure Execute(const cursor: TSQLCursor;
              const atransaction: tsqltransaction; const AParams : TmseParams); override;
    procedure AddFieldDefs(const cursor: TSQLCursor;
                     const FieldDefs : TfieldDefs); override;
    function Fetch(cursor : TSQLCursor) : boolean; override;
    function loadfield(const cursor: tsqlcursor; 
                const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    function GetTransactionHandle(trans : TSQLHandle): pointer; override;
    function Commit(trans : TSQLHandle) : boolean; override;
    function RollBack(trans : TSQLHandle) : boolean; override;
    function StartdbTransaction(const trans : TSQLHandle;
                       const AParams : string) : boolean; override;
    procedure internalCommitRetaining(trans : TSQLHandle); override;
    procedure internalRollBackRetaining(trans : TSQLHandle); override;
    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                           const TableName : string); override;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; override;
    function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                           const acursor: tsqlcursor): TStream; override;
    function getblobdatasize: integer; override;
                           
           //iblobconnection                           
   procedure writeblobdata(const atransaction: tsqltransaction;
              const tablename: string; const acursor: tsqlcursor;
              const adata: pointer; const alength: integer;
              const afield: tfield; const aparam: tparam; out newid: string);
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                              const aparam: tparam);
   function blobscached: boolean;
          //idbevent
   procedure listen(const sender: tdbevent);
   procedure unlisten(const sender: tdbevent);
   procedure fire(const sender: tdbevent);
          //idbeventcontroller
   function getdbevent(var aname: string; var aid: int64): boolean;
          //false if none
   procedure dolisten(const sender: tdbevent);
   procedure dounlisten(const sender: tdbevent);
  public
    constructor Create(AOwner : TComponent); override;
    destructor destroy; override;
    function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; override;
                              //null based
    procedure createdatabase(const asql: string);
    function version: fbversionty;
    property lasterror: statusvectorty read flasterror;
    property lasterrormessage: msestring read flasterrormessage;
    property lastsqlcode: integer read flastsqlcode;
  published
    property Dialect  : integer read FDialect write FDialect;
    property options: ibconnectionoptionsty read foptions write foptions;
    property DatabaseName;
    property KeepConnection;
    property LoginPrompt;
    property Params;
    property OnLogin;
  end;

function clientversion: string;
function clientmajorversion: integer;
function clientminorversion: integer;
           //library must be inited before calling
           
implementation

uses 
 strutils,msesysintf;

function clientversion: string;
var
 buf: array[0..255] of char;
begin
 result:= '';
 if assigned(isc_get_client_version) then begin
  isc_get_client_version(@buf);
  result:= buf;
 end;
end;

function clientmajorversion: integer;
begin
 if assigned(isc_get_client_major_version) then begin
  result:= isc_get_client_major_version();
 end
 else begin
  result:= -1;
 end;
end;

function clientminorversion: integer;
begin
 if assigned(isc_get_client_minor_version) then begin
  result:= isc_get_client_minor_version();
 end
 else begin
  result:= -1;
 end;
end;

type
  TTm = packed record
    tm_sec : longint;
    tm_min : longint;
    tm_hour : longint;
    tm_mday : longint;
    tm_mon : longint;
    tm_year : longint;
    tm_wday : longint;
    tm_yday : longint;
    tm_isdst : longint;
    __tm_gmtoff : longint;
    __tm_zone : Pchar;
  end;

{ TIBCursor }

procedure TIBCursor.close;
begin
 inherited;
 if fopen then begin
  if isc_dsql_free_statement(@status, @statement, dsql_close) <> 0 then begin
   fconnection.checkerror('close cursor', status{,fname});
  end;
  fopen:= false;
 end;
end;

constructor TIBCursor.create(const aowner: icursorclient;
                                         const aconnection: tibconnection);
begin
 fconnection:= aconnection;
 inherited create(aowner,fconnection.name);
end;

{ tibconnection }

procedure TIBConnection.CheckError(const ProcName : string; 
                         const Status: statusvectorty);
var
  buf: array [0..1024] of char;
  p: pointer;
  Msg: string;
  E: eiberror;
  
begin
 if ((Status[0] = 1) and (Status[1] <> 0)) then begin
  p:= @Status;
  msg:= procname;
  while isc_interprete(Buf, @p) > 0 do begin
   Msg := Msg + LineEnding +' -' + StrPas(Buf);
  end;
  flasterror:= status;
  flasterrormessage:= msg;
  flastsqlcode:= isc_sqlcode(status);
  raise eiberror.create(self,msg,status,flastsqlcode);
 end;
end;

procedure tibconnection.CheckError(const ProcName : string; const Status: integer);
begin
 if status <> 0 then begin
  checkerror(procname,fstatus);
 end;
end;

constructor TIBConnection.Create(AOwner : TComponent);

begin
 sys_mutexcreate(fmutex);
 feventcontroller:= tdbeventcontroller.create(idbeventcontroller(self));
 feventcontroller.eventinterval:= -1; //event driven
 inherited;
 FConnOptions := FConnOptions + [sco_SupportParams];
end;

destructor TIBConnection.destroy;
begin
 inherited;
 feventcontroller.free;
 sys_mutexdestroy(fmutex);
end;

function TIBConnection.GetTransactionHandle(trans : TSQLHandle): pointer;
begin
  Result := (trans as TIBtrans).TransactionHandle;
end;

function TIBConnection.Commit(trans : TSQLHandle) : boolean;
begin
  result := false;
  with (trans as TIBTrans) do
    if isc_commit_transaction(@Status, @TransactionHandle) <> 0 then
      CheckError('Commit', Status)
    else result := true;
end;

function TIBConnection.RollBack(trans : TSQLHandle) : boolean;
begin
  result := false;
  if isc_rollback_transaction(@TIBTrans(trans).Status, @TIBTrans(trans).TransactionHandle) <> 0 then
    CheckError('Rollback', TIBTrans(trans).Status)
  else result := true;
end;

function TIBConnection.StartDBTransaction(
                const trans : TSQLHandle; const AParams : String) : boolean;
var
  DBHandle : pointer;
  tr       : TIBTrans;
  i        : integer;
  s        : string;
begin
  result := false;

  DBHandle := GetHandle;
  tr := trans as TIBtrans;
  with tr do
    begin
    TPB := chr(isc_tpb_version3);

    i := 1;
    s := ExtractSubStr(AParams,i,stdWordDelims);
    while s <> '' do
      begin
      if s='isc_tpb_write' then TPB := TPB + chr(isc_tpb_write)
      else if s='isc_tpb_read' then TPB := TPB + chr(isc_tpb_read)
      else if s='isc_tpb_consistency' then TPB := TPB + chr(isc_tpb_consistency)
      else if s='isc_tpb_concurrency' then TPB := TPB + chr(isc_tpb_concurrency)
      else if s='isc_tpb_read_committed' then TPB := TPB + chr(isc_tpb_read_committed)
      else if s='isc_tpb_rec_version' then TPB := TPB + chr(isc_tpb_rec_version)
      else if s='isc_tpb_no_rec_version' then TPB := TPB + chr(isc_tpb_no_rec_version)
      else if s='isc_tpb_wait' then TPB := TPB + chr(isc_tpb_wait)
      else if s='isc_tpb_nowait' then TPB := TPB + chr(isc_tpb_nowait)
      else if s='isc_tpb_shared' then TPB := TPB + chr(isc_tpb_shared)
      else if s='isc_tpb_protected' then TPB := TPB + chr(isc_tpb_protected)
      else if s='isc_tpb_exclusive' then TPB := TPB + chr(isc_tpb_exclusive)
      else if s='isc_tpb_lock_read' then TPB := TPB + chr(isc_tpb_lock_read)
      else if s='isc_tpb_lock_write' then TPB := TPB + chr(isc_tpb_lock_write)
      else if s='isc_tpb_verb_time' then TPB := TPB + chr(isc_tpb_verb_time)
      else if s='isc_tpb_commit_time' then TPB := TPB + chr(isc_tpb_commit_time)
      else if s='isc_tpb_ignore_limbo' then TPB := TPB + chr(isc_tpb_ignore_limbo)
      else if s='isc_tpb_autocommit' then TPB := TPB + chr(isc_tpb_autocommit)
      else if s='isc_tpb_restart_requests' then TPB := TPB + chr(isc_tpb_restart_requests)
      else if s='isc_tpb_no_auto_undo' then TPB := TPB + chr(isc_tpb_no_auto_undo);
      s := ExtractSubStr(AParams,i,stdWordDelims);

      end;

    TransactionHandle := nil;

    if isc_start_transaction(@Status, @TransactionHandle, 1,
       [@DBHandle, Length(TPB), @TPB[1]]) <> 0 then
      CheckError('StartTransaction',Status)
    else Result := True;
    end;
end;


procedure TIBConnection.internalCommitRetaining(trans : TSQLHandle);
begin
  with trans as TIBtrans do
    if isc_commit_retaining(@Status, @TransactionHandle) <> 0 then
      CheckError('CommitRetaining', Status);
end;

procedure TIBConnection.internalRollBackRetaining(trans : TSQLHandle);
begin
  with trans as TIBtrans do
    if isc_rollback_retaining(@Status, @TransactionHandle) <> 0 then
      CheckError('RollBackRetaining', Status);
end;


procedure TIBConnection.DoInternalConnect;
var
  DPB           : string;
  ADatabaseName : String;
begin
{$IfDef LinkDynamically}
 useembeddedfirebird:= ibo_embedded in foptions;
 InitialiseIBase60;
 try 
{$EndIf}
  inherited dointernalconnect;

  DPB := chr(isc_dpb_version1);
  if (UserName <> '') then
  begin
    DPB := DPB + chr(isc_dpb_user_name) + chr(Length(UserName)) + UserName;
    if (Password <> '') then
      DPB := DPB + chr(isc_dpb_password) + chr(Length(Password)) + Password;
  end;
  if (Role <> '') then
     DPB := DPB + chr(isc_dpb_sql_role_name) + chr(Length(Role)) + Role;
  if Length(CharSet) > 0 then
    DPB := DPB + Chr(isc_dpb_lc_ctype) + Chr(Length(CharSet)) + CharSet;

  FSQLDatabaseHandle := nil;
  if HostName <> '' then ADatabaseName := HostName+':'+DatabaseName
    else ADatabaseName := DatabaseName;
  if isc_attach_database(@FStatus, Length(ADatabaseName), @ADatabaseName[1], @FSQLDatabaseHandle,
         Length(DPB), @DPB[1]) <> 0 then
    CheckError('DoInternalConnect', FStatus);
  SetDBDialect;
{$IfDef LinkDynamically}
 except
  releaseIBase60;
  raise;
 end;
{$EndIf}
 feventcontroller.connect;
end;

procedure TIBConnection.DoInternalDisconnect;
begin
 feventcontroller.disconnect;
 if not Connected then begin
  FSQLDatabaseHandle:= nil;
  Exit;
 end;
 isc_detach_database(@FStatus[0], @FSQLDatabaseHandle);
// CheckError('Close', FStatus); //no exception on close
{$IfDef LinkDynamically}
 ReleaseIBase60;
{$EndIf}
end;


procedure TIBConnection.SetDBDialect;
var
  x : integer;
  Len : integer;
  Buffer : string;
  ResBuf : array [0..39] of byte;
begin
  Buffer := Chr(isc_info_db_sql_dialect) + Chr(isc_info_end);
  if isc_database_info(@FStatus, @FSQLDatabaseHandle, Length(Buffer),
    @Buffer[1], SizeOf(ResBuf), @ResBuf) <> 0 then
      CheckError('SetDBDialect', FStatus);
  x := 0;
  while x < 40 do
    case ResBuf[x] of
      isc_info_db_sql_dialect :
        begin
          Inc(x);
          Len := isc_vax_integer(@ResBuf[x], 2);
          Inc(x, 2);
          FDialect := isc_vax_integer(@ResBuf[x], Len);
          Inc(x, Len);
        end;
      isc_info_end : Break;
    end;
end;

procedure TIBConnection.AllocSQLDA(var aSQLDA : PXSQLDA;Count : integer);

var x : shortint;

begin
  FreeSQLDABuffer(aSQLDA);

  if count > -1 then
    begin
    reAllocMem(aSQLDA, XSQLDA_Length(Count));
    { Zero out the memory block to avoid problems with exceptions within the
      constructor of this class. }
    FillChar(aSQLDA^, XSQLDA_Length(Count), 0);

    aSQLDA^.Version := sqlda_version1;
    aSQLDA^.SQLN := Count;
    end
  else
    reAllocMem(aSQLDA,0);
end;

procedure TIBConnection.TranslateFldType(SQLType,sqlsubtype,SQLLen,
            SQLScale: integer;
            var LensSet: boolean; var TrType: TFieldType; var TrLen: word);
begin
 LensSet := False;
 if SQLScale < 0 then begin
  if (SQLScale >= -4) and (SQLScale <= -1) then //in [-4..-1] then
    begin
    LensSet := True;
    TrLen := SQLLen;
    TrType := ftBCD
    end
  else begin
    TrType := ftFMTBcd;
  end;
 end
 else begin
  LensSet:= True;
  TrLen:= SQLLen;
  case (SQLType and not 1) of
   SQL_VARYING: begin
//        LensSet := True;
       TrType := ftString;
//        TrLen := SQLLen;
   end;
   SQL_TEXT: begin
       LensSet := True;
       TrType := ftString;
       TrLen := SQLLen;
   end;
   SQL_TYPE_DATE: begin
     TrType:= ftDate{Time};
   end;
   SQL_TYPE_TIME: begin
       TrType:= ftDateTime;
   end;
   SQL_TIMESTAMP: begin
       TrType := ftDateTime;
   end;
   SQL_ARRAY: begin
       TrType := ftArray;
//        LensSet := true;
//        TrLen := SQLLen;
   end;
   SQL_BLOB: begin
    if sqlsubtype = isc_blob_text then begin
     trtype:= ftmemo;
    end
    else begin
     TrType:= ftBlob;
    end;
    LensSet:= True;
    TrLen:= SQLLen;
   end;
   SQL_SHORT: begin
//        TrType := ftInteger;
    TrType:= ftsmallint;
   end;
   SQL_LONG: begin
//        LensSet := True;
//       TrLen := 0;
    TrType:= ftInteger;
   end;
   SQL_INT64: begin
       TrType:= ftLargeInt;
   end;
   SQL_DOUBLE: begin
    TrType:= ftFloat;
   end;
   SQL_FLOAT: begin
    LensSet:= True;
    TrLen:= SQLLen;
    TrType:= ftFloat;
   end
   else begin
//     LensSet := True;
    TrLen := 0;
    TrType := ftUnknown;
   end;
  end;
 end;
end;

Function TIBConnection.AllocateCursorHandle(const aowner: icursorclient;
                 const aname: ansistring): TSQLCursor;

var curs : TIBCursor;

begin
  curs := TIBCursor.create(aowner,self);
  curs.sqlda := nil;
  curs.statement := nil;
  curs.FPrepared := False;
  AllocSQLDA(curs.SQLDA,0);
  AllocSQLDA(curs.in_SQLDA,0);
  result := curs;
end;

procedure TIBConnection.DeAllocateCursorHandle(var cursor : TSQLCursor);

begin
  if assigned(cursor) then with cursor as TIBCursor do
    begin
    AllocSQLDA(SQLDA,-1);
    AllocSQLDA(in_SQLDA,-1);
    end;
  FreeAndNil(cursor);
end;

Function TIBConnection.AllocateTransactionHandle : TSQLHandle;

begin
  result := TIBTrans.create;
end;

procedure tibconnection.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);

var dh    : pointer;
    tr    : pointer;
    p     : pchar;
    x     : shortint;
    i     : integer;
 TransLen: word;
 TransType: TFieldType;
 lenset: boolean;
 str1: string;

begin
  with cursor as TIBcursor do
    begin
    dh := GetHandle;
    if isc_dsql_allocate_statement(@Status, @dh, @Statement) <> 0 then
      CheckError('PrepareStatement', Status);
    tr := aTransaction.Handle;
    
    if assigned(AParams) and (AParams.count > 0) then begin
     str1:= todbstring(AParams.ParseSQL(asql,false,false,false,psInterbase,
                              paramBinding));
    end
    else begin
     str1:= todbstring(asql);
    end;
    if isc_dsql_prepare(@Status, @tr, @Statement, 0, @str1[1],
                        Dialect, nil) <> 0 then begin
     isc_dsql_free_statement(@fstatus, @statement, dsql_drop);
     CheckError('PrepareStatement', Status);
    end;
    FPrepared := True;
    if assigned(AParams) and (AParams.count > 0) then begin
     AllocSQLDA(in_SQLDA,Length(ParamBinding));
     if isc_dsql_describe_bind(@Status, @Statement, 1, in_SQLDA) <> 0 then begin
       CheckError('PrepareStatement', Status);
     end;
     if in_SQLDA^.SQLD > in_SQLDA^.SQLN then begin
       DatabaseError(SParameterCountIncorrect,self);
     end;
     setlength(paramtypes,in_SQLDA^.SQLD);
     for x := 0 to in_SQLDA^.SQLD - 1 do begin
      with in_SQLDA^.SQLVar[x] do begin
       TranslateFldType(SQLType,sqlsubtype,SQLLen,SQLScale,lenset,TransType,TransLen);
       paramtypes[x]:= transtype;
       if ((SQLType and not 1) = SQL_VARYING) then begin
         SQLData := AllocMem(in_SQLDA^.SQLVar[x].SQLLen+2)
       end
       else begin
         SQLData := AllocMem(in_SQLDA^.SQLVar[x].SQLLen);
       end;
       if (sqltype and 1) = 1 then begin
        New(SQLInd);
       end;
      end;
     end;
    end;
    if FStatementType = stselect then
      begin
///////////////////////      FPrepared := False;
      if isc_dsql_describe(@Status, @Statement, 1, SQLDA) <> 0 then
        CheckError('PrepareSelect', Status);
      if SQLDA^.SQLD > SQLDA^.SQLN then
        begin
        AllocSQLDA(SQLDA,SQLDA^.SQLD);
        if isc_dsql_describe(@Status, @Statement, 1, SQLDA) <> 0 then
          CheckError('PrepareSelect', Status);
        end;
      for x := 0 to SQLDA^.SQLD - 1 do with SQLDA^.SQLVar[x] do
        begin
        if ((SQLType and not 1) = SQL_VARYING) then
          SQLData := AllocMem(SQLDA^.SQLVar[x].SQLLen+2)
        else
          SQLData := AllocMem(SQLDA^.SQLVar[x].SQLLen);
        if (SQLType and 1) = 1 then New(SQLInd);
        end;
      end;
    end;
end;

procedure tibconnection.unpreparestatement(cursor: tsqlcursor);
begin
 with tibcursor(cursor) do begin
  if statement <> nil then begin 
   if isc_dsql_free_statement(@status, @statement, dsql_drop) <> 0 then begin
    checkerror('freestatement', status);
   end;
  end;
  statement:= nil;
  fprepared:= false;
  fopen:= false;
 end;
end;

procedure TIBConnection.FreeSQLDABuffer(var aSQLDA : PXSQLDA);

var x : shortint;

begin
  if assigned(aSQLDA) then
    for x := 0 to aSQLDA^.SQLN - 1 do
      begin
      reAllocMem(aSQLDA^.SQLVar[x].SQLData,0);
      if assigned(aSQLDA^.SQLVar[x].sqlind) then
        begin
        Dispose(aSQLDA^.SQLVar[x].sqlind);
        aSQLDA^.SQLVar[x].sqlind := nil;
        end
        
      end;
end;

procedure TIBConnection.FreeFldBuffers(cursor : TSQLCursor);

begin
  with cursor as TIBCursor do
    begin
    FreeSQLDABuffer(SQLDA);
    FreeSQLDABuffer(in_SQLDA);
    end;
end;

procedure TIBConnection.Execute(const cursor: TSQLCursor;
                const atransaction: tsqltransaction; const AParams : TmseParams);
begin
 if Assigned(APArams) and (AParams.count > 0) then begin
  SetParameters(cursor, AParams);
 end;
 with TIBCursor(cursor) do begin
  if isc_dsql_execute2(@Status,@cursor.ftrans,
                        @Statement,1,in_SQLDA,nil) <> 0 then begin
    CheckError('Execute', Status);
  end;
  fopen:= true;  
 end;
end;

type
 tcharlengthgetter = class
  private
   ftransaction: tsqltransaction;
   fcursor: tsqlcursor;
   fowner: tibconnection;
   fparams: tmseparams;
   frelationlen,ffieldlen: integer;
  public
   constructor create(const aowner: tibconnection);
   destructor destroy; override;
   function characterlength(const relationname,fieldname: string): integer;
        //-maxint if invalid
 end;
 
{ tcharlengthgetter }

constructor tcharlengthgetter.create(const aowner: tibconnection);
begin
 fowner:= aowner;
 fparams:= tmseparams.create;
 with tparam.create(fparams,ptoutput) do begin
  datatype:= ftstring;
  name:= 'RELATION';
 end;
 with tparam.create(fparams,ptoutput) do begin
  datatype:= ftstring;
  name:= 'FIELD';
 end;
 fcursor:= fowner.allocatecursorhandle(nil,aowner.name);
 fcursor.fstatementtype:= stselect;
 ftransaction:= tsqltransaction.create(nil);
 ftransaction.database:= aowner;
 ftransaction.starttransaction;
 fowner.preparestatement(fcursor,ftransaction,
   'SELECT B.RDB$CHARACTER_LENGTH FROM RDB$RELATION_FIELDS A '+
   'INNER JOIN  RDB$FIELDS B ON A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME '+
   'WHERE (A.RDB$RELATION_NAME = :RELATION) AND (A.RDB$FIELD_NAME = :FIELD);',
                                     fparams);
 with tibcursor(fcursor).in_sqlda^ do begin
  if sqld = 2 then begin
   frelationlen:= sqlvar[0].sqllen;
   ffieldlen:= sqlvar[1].sqllen;
  end;
 end;
end;

destructor tcharlengthgetter.destroy;
begin
 with fowner do begin
  try
   freefldbuffers(fcursor);
   unpreparestatement(fcursor);
  finally
   fparams.free;
   deallocatecursorhandle(fcursor);
   ftransaction.free;
  end;
 end;
 inherited;
end;

function fixsize(const avalue: string; const alen: integer): string;
begin
 result:= avalue;
 setlength(result,alen);
 if alen > length(avalue) then begin
  fillchar(result[length(avalue)+1],alen-length(avalue),' ');
 end;
end;

function tcharlengthgetter.characterlength(const relationname: string;
               const fieldname: string): integer;
var 
 tr: pointer;
begin
 result:= -maxint;
 fparams[0].asstring:= fixsize(relationname,frelationlen);
 fparams[1].asstring:= fixsize(fieldname,ffieldlen);
 fowner.SetParameters(fcursor, fparams);
 with tibcursor(fcursor) do begin
  tr:= ftransaction.handle;
  if isc_dsql_execute2(@Status,@tr,@Statement,1,in_SQLDA,nil) <> 0 then begin
   fowner.CheckError('Execute', Status);
  end;
  isc_dsql_set_cursor_name(@status,@statement,'charlencu',0);
  if fowner.fetch(fcursor) then begin
   with sqlda^ do begin
    if sqld = 1 then begin
     with sqlvar[0] do begin
      if not (assigned(SQLInd) and (SQLInd^ = -1)) then begin
                     //not null
       if (sqltype and not 1 = sql_short) then begin
        result:= psmallint(sqldata)^;
       end;
      end;
     end;
    end;
   end;
  end; 
  isc_dsql_free_statement(@status,@statement,DSQL_close);
 end;
end;

function sqlvarnametostring(const avalue: pointer): string;
type
 sqlnamety = packed record
  length: smallint;
  name: array[0..31] of char;
 end;
begin
 with sqlnamety(avalue^) do begin
  setlength(result,length);
  move(name,result[1],length);
 end;
end;
  
procedure TIBConnection.AddFieldDefs(const cursor: TSQLCursor;
               const FieldDefs: TfieldDefs);
var
 x: integer;
 lenset: boolean; //what is the use of this?
 TransLen: word;
 TransType: TFieldType;
 FD: TFieldDef;
 chlengetter: tcharlengthgetter;
 int1: integer;
begin
 fielddefs.clear;
 chlengetter:= tcharlengthgetter.create(self);
 try
  with tibcursor(cursor) do begin
   for x := 0 to SQLDA^.SQLD - 1 do begin
    with SQLDA^.SQLVar[x] do begin
     TranslateFldType(SQLType,sqlsubtype,SQLLen,SQLScale,lenset,TransType,TransLen);
     if transtype = ftstring then begin
      int1:= chlengetter.characterlength(sqlvarnametostring(@relname_length),
                 sqlvarnametostring(@sqlname_length));
      if int1 >= 0 then begin
       translen:= int1;
      end;
     end;
     if not(transtype in varsizefields) then begin
      translen:= 0;
     end;
     FD:= TFieldDef.Create(nil,AliasName,TransType,
                TransLen,False,(x + 1));
     if TransType = ftBCD then begin
      FD.precision:= SQLLen;
     end;
     {$ifndef mse_FPC_2_2} //???
     FD.DisplayName:= AliasName;
     {$endif}
     fd.collection:= fielddefs;
    end;
   end;
  end;
 finally
  chlengetter.free;
 end;
end;

function TIBConnection.GetHandle: pointer;
begin
  Result := FSQLDatabaseHandle;
end;

function TIBConnection.Fetch(cursor : TSQLCursor) : boolean;
var
 retcode: integer;
begin
 with TIBCursor(cursor) do begin
  retcode:= isc_dsql_fetch(@Status,@Statement,1,SQLDA);
  if (retcode <> 0) and (retcode <> 100) and (retcode <> 335544364) then begin
                     //request synchronizing error, FireBird bug?
   CheckError('Fetch',Status);
  end;
 end;
 Result:= retcode = 0;
end;

procedure TIBConnection.SetParameters(cursor : TSQLCursor;AParams : TmseParams);

var ParNr,SQLVarNr : integer;
    s               : string;
    i               : integer;
    li              : LargeInt;
    currbuff        : pchar;
    w               : word;
    cur1: currency;

begin
  with cursor as TIBCursor do for SQLVarNr := 0 to High(ParamBinding){AParams.count-1} do
    begin
    ParNr := ParamBinding[SQLVarNr];
    if AParams[ParNr].IsNull then
      begin
      If Assigned(in_sqlda^.SQLvar[SQLVarNr].SQLInd) then
        in_sqlda^.SQLvar[SQLVarNr].SQLInd^ := -1;
      end
    else
      begin
      if assigned(in_sqlda^.SQLvar[SQLVarNr].SQLInd) then in_sqlda^.SQLvar[SQLVarNr].SQLInd^ := 0;

      case paramtypes[ParNr] of
        ftInteger,ftsmallint :
          begin
          i := AParams[ParNr].AsInteger;
          Move(i, in_sqlda^.SQLvar[SQLVarNr].SQLData^, in_SQLDA^.SQLVar[SQLVarNr].SQLLen);
   //todo: byte order?
          end;
        ftbcd,ftcurrency: begin
         cur1:= AParams[ParNr].ascurrency;
         with in_sqlda^.SQLvar[SQLVarNr] do begin
          cur1:= cur1 / intpower(10,4+SQLScale);
          reallocmem(sqldata,sizeof(cur1));
          move(cur1,sqldata^,sizeof(cur1));
         end;
        end;
        ftString,ftFixedChar  :
          begin
          s:= AParams.AsdbString(parnr);
          w:= length(s);
          with in_sqlda^.SQLvar[SQLVarNr] do begin
           if ((SQLType and not 1) = SQL_VARYING) then begin
            SQLLen:= w;
            ReAllocMem(SQLData,SQLLen+sizeof(w));
            CurrBuff:= SQLData;
            move(w,CurrBuff^,sizeof(w));
            inc(CurrBuff,sizeof(w));
           end
           else begin
            if w > sqllen then begin
             w:= sqllen;
            end;
            CurrBuff:= SQLData;
            if w < sqllen then begin
             fillchar((currbuff+w)^,sqllen-w,' ');
            end;
           end;
          end;
          Move(s[1],CurrBuff^,w);
          end;
        ftDate, ftTime, ftDateTime:
          SetDateTime(in_sqlda^.SQLvar[SQLVarNr].SQLData, 
               AParams[ParNr].AsDateTime, in_SQLDA^.SQLVar[SQLVarNr].SQLType);
        ftLargeInt,ftblob,ftmemo:
          begin
          li := AParams[ParNr].AsLargeInt;
          Move(li, in_sqlda^.SQLvar[SQLVarNr].SQLData^,
                        in_SQLDA^.SQLVar[SQLVarNr].SQLLen);
          end;
        ftFloat:
          SetFloat(in_sqlda^.SQLvar[SQLVarNr].SQLData, AParams[ParNr].AsFloat, in_SQLDA^.SQLVar[SQLVarNr].SQLLen);
      else
        DatabaseErrorFmt(SUnsupportedParameter,[Fieldtypenames[AParams[ParNr].DataType]],self);
      end {case}
      end;
    end;
end;

function tibconnection.loadfield(const cursor: tsqlcursor;
          const datatype: tfieldtype; const fieldnum: integer; //null based
      const buffer: pointer; var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
var
 VarcharLen: word;
 CurrBuff: pchar;
 b: longint;
 c: currency;
begin
 with TIBCursor(cursor),SQLDA^.SQLVar[fieldnum] do begin
  if assigned(SQLInd) and (SQLInd^ = -1) then begin
   result:= false
  end
  else begin
   Result := true;
   if buffer = nil then begin
    exit;
   end;
   if ((SQLType and not 1) = SQL_VARYING) then begin
    Move(SQLData^,VarcharLen,2);
    CurrBuff:= SQLData + 2;
   end
   else begin
    CurrBuff:= SQLData;
    VarCharLen:= SQLLen;
   end;
   case DataType of
    ftBCD: begin
     c:= 0;
     Move(CurrBuff^,c,SQLLen);
     c:= c*intpower(10,4+SQLScale);
     Move(c,buffer^,sizeof(c));
    end;
    ftInteger,ftsmallint: begin
//     b:= 0;        //todo: byte order?
//     Move(b, Buffer^,sizeof(longint));
//     Move(CurrBuff^,Buffer^,SQLLen);
     longint(buffer^):= 0;
     Move(CurrBuff^,buffer^,SQLLen);
     if datatype = ftsmallint then begin
      longint(buffer^):= smallint(buffer^);
     end;
    end;
    ftLargeint: begin
     FillByte(buffer^,sizeof(LargeInt),0);
     Move(CurrBuff^,Buffer^,SQLLen);
    end;
    ftDate,ftTime,ftDateTime: begin
     GetDateTime(CurrBuff,Buffer,SQLType);
    end;
    ftString: begin
     if bufsize < varcharlen then begin
      bufsize:= -varcharlen;
     end
     else begin
      bufsize:= varcharlen;
      move(currbuff^,buffer^,varcharlen);
     end;
 //    Move(CurrBuff^,Buffer^,SQLDA^.SQLVar[x].SQLLen);
 //    PChar(Buffer + VarCharLen)^ := #0;
    end;
    ftFloat: begin
     GetFloat(CurrBuff,Buffer,sqllen);
    end;
    ftBlob,ftmemo,ftgraphic: begin  // load the BlobIb in field's buffer
     FillByte(buffer^,sizeof(LargeInt),0);
     Move(CurrBuff^,Buffer^,SQLLen);
     if wantblobfetch then begin
      addblobcache(pint64(buffer)^,getblobstring(cursor,pisc_quad(buffer)^));
     end;
    end;
    else begin
     result := false;
    end;
   end;
  end;
 end;
end;

procedure TIBConnection.GetDateTime(CurrBuff, Buffer : pointer; AType : integer);
var
  CTime : TTm;          // C struct time
  STime : TSystemTime;  // System time
  PTime : TDateTime;    // Pascal time
begin
  case (AType and not 1) of
    SQL_TYPE_DATE :
      isc_decode_sql_date(PISC_DATE(CurrBuff), @CTime);
    SQL_TYPE_TIME :
      isc_decode_sql_time(PISC_TIME(CurrBuff), @CTime);
    SQL_TIMESTAMP :
      isc_decode_timestamp(PISC_TIMESTAMP(CurrBuff), @CTime);
  end;

  STime.Year        := CTime.tm_year + 1900;
  STime.Month       := CTime.tm_mon + 1;
  STime.Day         := CTime.tm_mday;
  STime.Hour        := CTime.tm_hour;
  STime.Minute      := CTime.tm_min;
  STime.Second      := CTime.tm_sec;
  STime.Millisecond := 0;

  PTime := SystemTimeToDateTime(STime);
  Move(PTime, Buffer^, SizeOf(PTime));
end;

procedure TIBConnection.SetDateTime(CurrBuff: pointer; PTime : TDateTime; AType : integer);
var
  CTime : TTm;          // C struct time
  STime : TSystemTime;  // System time
begin
  DateTimeToSystemTime(PTime,STime);
  
  CTime.tm_year := STime.Year - 1900;
  CTime.tm_mon  := STime.Month -1;
  CTime.tm_mday := STime.Day;
  CTime.tm_hour := STime.Hour;
  CTime.tm_min  := STime.Minute;
  CTime.tm_sec  := STime.Second;

  case (AType and not 1) of
    SQL_TYPE_DATE :
      isc_encode_sql_date(@CTime, PISC_DATE(CurrBuff));
    SQL_TYPE_TIME :
      isc_encode_sql_time(@CTime, PISC_TIME(CurrBuff));
    SQL_TIMESTAMP :
      isc_encode_timestamp(@CTime, PISC_TIMESTAMP(CurrBuff));
  end;
end;

function TIBConnection.GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string;

var s : string;

begin
  case SchemaType of
    stTables     : s := 'select '+
                          'rdb$relation_id          as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'rdb$relations '+
                        'where '+
                          '(rdb$system_flag = 0 or rdb$system_flag is null) ' + // and rdb$view_blr is null
                        'order by rdb$relation_name';

    stSysTables  : s := 'select '+
                          'rdb$relation_id          as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'rdb$relations '+
                        'where '+
                          '(rdb$system_flag > 0) ' + // and rdb$view_blr is null
                        'order by rdb$relation_name';

    stProcedures : s := 'select '+
                           'rdb$procedure_id        as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$procedure_name       as proc_name, '+
                          '0                        as proc_type, '+
                          'rdb$procedure_inputs     as in_params, '+
                          'rdb$procedure_outputs    as out_params '+
                        'from '+
                          'rdb$procedures '+
                        'WHERE '+
                          '(rdb$system_flag = 0 or rdb$system_flag is null)';
    stColumns    : s := 'select '+
                           'rdb$field_id            as recno, '+
                          '''' + DatabaseName + ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          'rdb$field_name           as column_name, '+
                          'rdb$field_position       as column_position, '+
                          '0                        as column_type, '+
                          '0                        as column_datatype, '+
                          '''''                     as column_typename, '+
                          '0                        as column_subtype, '+
                          '0                        as column_precision, '+
                          '0                        as column_scale, '+
                          '0                        as column_length, '+
                          '0                        as column_nullable '+
                        'from '+
                          'rdb$relation_fields '+
                        'WHERE '+
                          '(rdb$system_flag = 0 or rdb$system_flag is null) and (rdb$relation_name = ''' + Uppercase(SchemaObjectName) + ''') ' +
                        'order by rdb$field_name';
  else
    DatabaseError(SMetadataUnavailable)
  end; {case}
  result := s;
end;


procedure TIBConnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;
                               const TableName : string);
var 
 qry : TSQLQuery;
 str1: ansistring;
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
              'ind.rdb$index_name, '+
              'ind.rdb$relation_name, '+
              'ind.rdb$unique_flag, '+
              'ind_seg.rdb$field_name, '+
              'rel_con.rdb$constraint_type '+
            'from '+
              'rdb$index_segments ind_seg, '+
              'rdb$indices ind '+
             'left outer join '+
              'rdb$relation_constraints rel_con '+
             'on '+
              'rel_con.rdb$index_name = ind.rdb$index_name '+
            'where '+
              '(ind_seg.rdb$index_name = ind.rdb$index_name) and '+
              '(ind.rdb$relation_name=''' +  UpperCase(TableName) +''') '+
            'order by '+
              'ind.rdb$index_name;');
    open;
    end;

  while not qry.eof do begin
   with IndexDefs.AddIndexDef do begin
    str1:= qry.fields[0].asstring;
    Name := trim(str1);
    Fields := trim(qry.Fields[3].asstring);
    If qry.fields[4].asstring = 'PRIMARY KEY' then begin
     options := options + [ixPrimary];
    end;
    If qry.fields[2].asinteger = 1 then begin
     options := options + [ixUnique];
    end;
    qry.next;
    while (str1 = qry.fields[0].asstring) and (not qry.eof) do begin
     Fields := Fields + ';' + trim(qry.Fields[3].asstring);
     qry.next;
    end;
   end;
  end;
  qry.close;
  qry.free;
end;

procedure TIBConnection.SetFloat(CurrBuff: pointer; Dbl: Double; Size: integer);

var
  Ext : extended;
  Sin : single;
begin
  case Size of
    4 :
      begin
        Sin := Dbl;
        Move(Sin, CurrBuff^, 4);
      end;
    8 :
      begin
        Move(Dbl, CurrBuff^, 8);
      end;
    10:
      begin
        Ext := Dbl;
        Move(Ext, CurrBuff^, 10);
      end;
  end;
end;

procedure tibconnection.GetFloat(const CurrBuff,Buffer: pointer; 
                                     const datalength: integer);
var
 Ext: extended;
 Dbl: double;
 Sin: single;
begin
 case datalength of
  4: begin
   Move(CurrBuff^, Sin, 4);
   Dbl := Sin;
  end;
  8: begin
   Move(CurrBuff^, Dbl, 8);
  end;
  10: begin
   Move(CurrBuff^, Ext, 10);
   Dbl := double(Ext);
  end;
 end;
 Move(Dbl,Buffer^,8);
end;


function TIBConnection.getMaxBlobSize(blobHandle : TIsc_Blob_Handle) : longInt;
var
  iscInfoBlobMaxSegment : byte = isc_info_blob_max_segment;
  blobInfo : array[0..50] of byte;

begin
  if isc_blob_info(@Fstatus, @blobHandle, sizeof(iscInfoBlobMaxSegment),
          @iscInfoBlobMaxSegment, sizeof(blobInfo) - 2, @blobInfo) <> 0 then
    CheckError('isc_blob_info', FStatus);
  if blobInfo[0]  = isc_info_blob_max_segment then
    begin
      result :=  isc_vax_integer(pchar(@blobInfo[3]),
                  isc_vax_integer(pchar(@blobInfo[1]), 2));
    end
  else
     CheckError('isc_blob_info', FStatus);
end;

function tibconnection.getblobstream(const acursor: tsqlcursor;
      const blobid: isc_quad; const forstring: boolean = false): tmemorystream;
const
  isc_segstr_eof = 335544367;
var
 blobHandle : Isc_blob_Handle;
 blobSegment : pointer;
 blobSegLen : smallint;
 maxBlobSize : longInt; 
begin
 blobHandle:= nil;
 if isc_open_blob(@FStatus, @FSQLDatabaseHandle, @acursor.ftrans,
                        @blobHandle, @blobId) <> 0 then begin
  CheckError('TIBConnection.CreateBlobStream', FStatus);
 end;
 maxBlobSize:= getMaxBlobSize(blobHandle);
 blobSegment:= AllocMem(maxBlobSize);
 if forstring then begin
  result:= tmemorystringstream.create;
 end
 else begin
  result:= tmemorystream.create;
 end;
 while isc_get_segment(@FStatus,@blobHandle,@blobSegLen,maxBlobSize,
                                                    blobSegment) = 0 do begin
  result.writeBuffer(blobSegment^,blobSegLen);
 end;
 freemem(blobSegment);
 result.seek(0,soFromBeginning);
 if FStatus[1] = isc_segstr_eof then begin
  if isc_close_blob(@FStatus, @blobHandle) <> 0 then begin
   CheckError('TIBConnection.CreateBlobStream isc_close_blob', FStatus);
  end;
 end
 else begin
  CheckError('TIBConnection.CreateBlobStream isc_get_segment', FStatus);
 end;
end;

function tibconnection.getblobstring(const acursor: tsqlcursor; 
                                            const blobid: isc_quad): string;
begin
 tmemorystringstream(getblobstream(acursor,blobid,true)).destroyasstring(result);
end;

function TIBConnection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
var
 blobId : ISC_QUAD;
 int1: integer;
begin
 int1:= sizeof(blobid);
 if not loadfield(cursor,ftblob,fieldnum,@blobid,int1) then begin
  result:= '';
 end
 else begin
  result:= getblobstring(cursor,blobid);
 end;
end;

function TIBConnection.CreateBlobStream(const Field: TField;
          const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
var
  blobId : ISC_QUAD;
begin
 result := nil;
 if mode = bmRead then begin
  if not field.getData(@blobId) then begin
   exit;
  end;
  result:= getblobstream(acursor,blobid);
 end;
end;


procedure TIBConnection.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const acursor: tsqlcursor;
               const adata: pointer; const alength: integer;
               const afield: tfield; const aparam: tparam; out newid: string);
     
 procedure check(const ares: isc_status);
 begin
  if ares <> 0 then begin
   CheckError('TIBConnection.writeblob', FStatus);
  end;
 end;
const
 defsegsize = $4000; 
var
 transactionhandle: pointer;
 blobhandle: isc_blob_handle;
 blobid: isc_quad;
 step: word;
 po1: pointer;
 int1: integer;
 str1: string;
begin
{
 if alength = 0 then begin
  aparam.clear;
  newid:= '';
 end
 else begin
 }
  transactionhandle:= atransaction.handle;
  blobhandle:= nil;
  fillchar(blobid,sizeof(blobid),0);
  check(isc_create_blob2(@fstatus,@fsqldatabasehandle,@transactionhandle,
                       @blobhandle,@blobid,0,nil));
  try
   int1:= getmaxblobsize(blobhandle);
   if (int1 <= 0) or (int1 > defsegsize) then begin
    step:= defsegsize;
   end
   else begin
    step:= int1;
   end;
   po1:= adata;
   int1:= alength;
   while int1 > 0 do begin
    if int1 < step then begin
     step:= int1;
    end;
    check(isc_put_segment(@fstatus,@blobhandle,step,po1));
    dec(int1,step);
    inc(po1,step);
   end;
   aparam.aslargeint:= int64(blobid);
   newid:= ''; //id no more usable
   {
   setlength(str1,sizeof(blobid));
   move(blobid,str1[1],sizeof(blobid));
   newid:= str1;
   }
  finally
   isc_close_blob(@fstatus,@blobhandle);
  end;
// end;
end;

procedure tibconnection.setupblobdata(const afield: tfield;
                            const acursor: tsqlcursor; const aparam: tparam);
var
 blobid: isc_quad;
begin
{
 if afield.isnull then begin
  aparam.clear;
 end
 else begin
 }
  afield.getdata(@blobid);
  aparam.aslargeint:= int64(blobid);
// end; 
end;

function TIBConnection.getblobdatasize: integer;
begin
 result:= sizeof(isc_quad);
end;

procedure TIBConnection.createdatabase(const asql: string);
var
 dbha: isc_db_handle = nil;
 trha: isc_tr_handle = nil;
 bo1: boolean;
begin
{$ifdef linkdynamically}
 initialiseibase60;
 try
{$endif}
  bo1:= isc_dsql_execute_immediate(@fstatus,@dbha,@trha,length(asql),
                              pchar(asql),fdialect,nil) <> 0;
  if bo1 then begin 
   checkerror('createdatabase',fstatus);
  end
  else begin
   if dbha <> nil then begin
    isc_detach_database(@FStatus,@dbha);
   end;
  end;
{$ifdef linkdynamically}
 finally
  releaseibase60;
 end;
{$endif}
end;

function TIBConnection.blobscached: boolean;
begin
 result:= false;
end;

procedure TIBConnection.listen(const sender: tdbevent);
begin
 feventcontroller.register(sender);
 if connected then begin
  dolisten(sender);
 end;
end;

procedure TIBConnection.unlisten(const sender: tdbevent);
begin
 if connected then begin
  dounlisten(sender);
 end;
 feventcontroller.unregister(sender);
end;

procedure TIBConnection.fire(const sender: tdbevent);
begin
 databaseerror('Event fire not implemented.',self);
end;

procedure eventcallback(adata: pointer; alength: smallint; aupdated: pchar); 
                                                         cdecl;
var
 status: statusvectorty; 
begin
 with pfbeventbufferty(adata)^,tibconnection(event.database) do begin
   sys_mutexlock(fmutex);
   inc(count);
   inc(feventcount);
   move(aupdated^,resultbuffer^,alength);
   feventcontroller.eventinterval:= -1; //restart timer
   sys_mutexunlock(fmutex);
 end;
end;

function TIBConnection.getdbevent(var aname: string; var aid: int64): boolean;
var
 int1: integer;
 status: statusvectorty; 
begin
 result:= false;
 if feventcount > 0 then begin
  sys_mutexlock(fmutex);
  dec(feventcount);
  for int1:= 0 to high(feventbuffers) do begin
   if feventbuffers[int1] <> nil then begin
    with feventbuffers[int1]^ do begin
     if count <> 0 then begin
      isc_event_counts(@status,length,eventbuffer,resultbuffer);
      isc_que_events(@status,@fsqldatabasehandle,@id,length,
         eventbuffer,isc_callback(@eventcallback),feventbuffers[int1]);
      if count < 0 then begin     //first dummy
       count:= 0;
      end
      else begin
       dec(count);
       aname:= event.eventname;
       aid:= id;
       result:= true;
      end;
      break;
     end;
    end;
   end;
  end;
  sys_mutexunlock(fmutex);
 end;
end;

procedure TIBConnection.dolisten(const sender: tdbevent);
var
 int1,int2: integer;
begin
 int2:= -1;
 for int1:= 0 to high(feventbuffers) do begin
  if feventbuffers[int1] = nil then begin
   int2:= int1;
   break;
  end;
 end;
 if int2 < 0 then begin
  int2:= length(feventbuffers);
  setlength(feventbuffers,high(feventbuffers)+17);
 end;
 getmem(feventbuffers[int2],sizeof(fbeventbufferty));
 fillchar(feventbuffers[int2]^,sizeof(fbeventbufferty),0);
 with feventbuffers[int2]^ do begin
  count:= -2; //remove dummy call
  event:= sender;
  name:= sender.eventname;
  length:= isc_event_block(@eventbuffer,@resultbuffer,1,[pchar(name)]);
  checkerror('dolisten',isc_que_events(@fstatus,@fsqldatabasehandle,@id,length,
         eventbuffer,isc_callback(@eventcallback),feventbuffers[int2]));
 end;
end;

procedure TIBConnection.dounlisten(const sender: tdbevent);
var
 int1: integer;
begin
 for int1:= 0 to high(feventbuffers) do begin
  if (feventbuffers[int1] <> nil) and 
                 (feventbuffers[int1]^.event = sender) then begin
   sys_mutexlock(fmutex); //not save! there can be an event in queue
   isc_cancel_events(@fstatus,@fsqldatabasehandle,@feventbuffers[int1]^.id);
   freeeventbuffer(feventbuffers[int1]);
   sys_mutexunlock(fmutex);
   break;
  end;
 end;
end;

procedure TIBConnection.freeeventbuffer(var abuffer: pfbeventbufferty);
begin
 with abuffer^ do begin
  isc_free(eventbuffer);
  isc_free(resultbuffer);
 end;
 finalize(abuffer^);
 freemem(abuffer);
 abuffer:= nil;
end;

procedure versioncallback(user_arg: pointer; atext: pchar); cdecl;
begin
 setlength(stringarty(user_arg^),high(stringarty(user_arg^))+2);
 stringarty(user_arg^)[high(stringarty(user_arg^))]:= atext;
end;

function TIBConnection.version: fbversionty;
var
 ar1: stringarty;
 int1: integer;
begin
 checkconnected;
 ar1:= nil;
 if isc_version(@fsqldatabasehandle,@versioncallback,
                                   @ar1) <> 0 then begin
  raise edatabaseerror(name+': Can not get version info.');
 end;
 with result do begin
  imp:= nil;
  ods:= '';
  if high(ar1) > 0 then begin
   setlength(imp,high(ar1));
   for int1:= 0 to high(imp) do begin
    imp[int1]:= ar1[int1];
   end;
   ods:= ar1[high(ar1)];
  end;
 end;
end;

{ eiberror }

constructor eiberror.create(const asender: tibconnection; const amessage: msestring;
                        const aerror: statusvectorty; const asqlcode: integer);
begin
 fstatus:= aerror;
 fsqlcode:= asqlcode;
 inherited create(asender,amessage,amessage,aerror[1]);
end;

end.
