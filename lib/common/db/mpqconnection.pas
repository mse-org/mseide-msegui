{
    Copyright (c) 2004 by Joost van der Sluis
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  Modified 2006-2013 by Martin Schreiber

 **********************************************************************}
 
unit mpqconnection;
{$ifdef FPC}{$mode objfpc}{$H+}{$endif}

{$Define LinkDynamically}

interface

uses
  classes,mclasses,SysUtils, msqldb, mdb,
  {$ifdef FPC}dbconst{$else}dbconst_del{$endif},
            msedbevents,msestrings,msedb,
{$IfDef LinkDynamically}
  postgres3dyn;
{$Else}
  postgres3;
{$EndIf}

type
 epqerror = class(econnectionerror)
  private
   fsqlcode: string;
  public
   constructor create(const asender: tcustomsqlconnection; const amessage: ansistring;
               const aerrormessage: msestring; const asqlcode: string);
   public
    property sqlcode: string read fsqlcode;
 end;
 
  TPQTrans = Class(TSQLHandle)
   protected
    fconn: PPGConn;
    fparams: ansistring;
//    ErrorOccured  : boolean;
   public
    property conn: ppgconn read fconn;
  end;

  dbarrayinfoty = record
   fieldtype: tfieldtype;
   vartype: word;
  end;
  dbarrayinfoarty = array of dbarrayinfoty;
  
  TPQCursor = Class(TSQLCursor)
   protected
    Statementm : msestring;
    tr        : TPQTrans;
    res       : PPGresult;
    CurTuple  : integer;
    Nr        : string;
    fopen: boolean;
    ParamBinding : TParamBinding;
    ParamReplaceString : mseString;
    arrayinfo: dbarrayinfoarty;
   public
    procedure close; override;
  end;

 dbeventarty = array of tdbevent;
 
 TPQConnection = class (TSQLConnection,iblobconnection,idbevent,idbeventcontroller)
  private
   FCursorCount         : integer;
   FConnectString       : string;
   FHandle: ppgconn;
   FIntegerDateTimes    : boolean;
   feventcontroller: tdbeventcontroller;
   ftransactionconnectionused: boolean;
   flastsqlcode: string;
   flasterrormessage: msestring;
   function TranslateFldType(Type_Oid: integer;
                              out isarray: boolean; out vartype: word) : TFieldType;
   function geteventinterval: integer;
   procedure seteventinterval(const avalue: integer);
   procedure closeconnection(var aconnection: ppgconn);
   function constructconnectstring: string;
   procedure openconnection(const aconnectstring: ansistring;
                                                  var aconnection: ppgconn);
   procedure begintrans(const aconnection: ppgconn; const aparams: ansistring);
  protected
   procedure checkerror(const aconnection: ppgconn; var ares: ppgresult;
                const amessage: ansistring);
   procedure checkexec(const aconnection: ppgconn; const asql: ansistring;
                const amessage: ansistring);
   procedure finalizetransaction(const atransaction: tsqlhandle); override; 
   procedure DoInternalConnect; override;
   procedure DoInternalDisconnect; override;
   function GetHandle : pointer; override;

   Function AllocateTransactionHandle : TSQLHandle; override;

   procedure internalExecute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
                     const AParams : TmseParams; const autf8: boolean); override;
   procedure internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string); override;
   function GetTransactionHandle(trans : TSQLHandle): pointer; override;
   function RollBack(trans : TSQLHandle) : boolean; override;
   function Commit(trans : TSQLHandle) : boolean; override;
   procedure internalCommitRetaining(trans : TSQLHandle); override;
   function StartdbTransaction(const trans : TSQLHandle;
                const AParams: tstringlist) : boolean; override;
   procedure internalRollBackRetaining(trans : TSQLHandle); override;
   procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                 const aTableName : string); override;
   function GetSchemaInfoSQL(SchemaType : TSchemaType;
         SchemaObjectName, SchemaPattern : msestring) : msestring; override;
   procedure dopqexec(const asql: ansistring); overload;
   procedure dopqexec(const asql: ansistring; const aconnection: ppgconn); overload;

   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                      const acursor: tsqlcursor): TStream; override;
   function getblobdatasize: integer; override;
   function getnumboolean: boolean; override;

          //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
             const tablename: string; const acursor: tsqlcursor;
             const adata: pointer; const alength: integer;
             const afield: tfield; const aparam: tparam;
             out newid: string);
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
   Function AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring) : TSQLCursor; override;
   Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
   procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
   procedure FreeFldBuffers(cursor : TSQLCursor); override;
   procedure AddFieldDefs(const cursor: TSQLCursor;
                  const FieldDefs : TfieldDefs); override;
   procedure UnPrepareStatement(cursor : TSQLCursor); override;
   function Fetch(cursor : TSQLCursor) : boolean; override;
   function loadfield(const cursor: tsqlcursor;
            const datatype: tfieldtype; const fieldnum: integer; //null based
              const buffer: pointer; var bufsize: integer;
              const aisutf8: boolean): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
   function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; override;
                              //null based
   function backendpid: int64; //0 if not connected
   procedure createdatabase(const asql: ansistring);
   property eventcontroller: tdbeventcontroller read feventcontroller;
   property lasterrormessage: msestring read flasterrormessage;   
   property lastsqlcode: string read flastsqlcode;
  published
    property DatabaseName;
    property KeepConnection;
//    property LoginPrompt;
    property Params;
//    property OnLogin;
    property eventinterval: integer read geteventinterval 
                     write seteventinterval default defaultdbeventinterval;
  end;

implementation

uses
 math,msestream,msetypes,msedatalist,mseformatstr,msedatabase,msectypes,
 variants,msevariants,msesqlresult{$ifndef FPC},classes_del{$endif};

ResourceString
  SErrRollbackFailed = 'Rollback transaction failed';
  SErrCommitFailed = 'Commit transaction failed';
  SErrConnectionFailed = 'Connection to database failed';
  SErrTransactionFailed = 'Start of transaction failed';
  SErrClearSelection = 'Clear of selection failed';
  SErrExecuteFailed = 'Execution of query failed';
  SErrFieldDefsFailed = 'Can not extract field information from query';
  SErrFetchFailed = 'Fetch of data failed';
  SErrPrepareFailed = 'Preparation of query failed.';

const 
 Oid_Bool         = 16;
 Oid_Bool_ar      = 1000;
 Oid_Text         = 25;
 Oid_Text_ar      = 1009;
 Oid_bytea        = 17;
 Oid_bytea_ar     = 1001;
 Oid_Oid          = 26;
 Oid_Oid_ar       = 1028;
 Oid_Name         = 19;
 Oid_Name_ar      = 1003;
 Oid_Int8         = 20;
 Oid_Int8_ar      = 1016;
 Oid_int2         = 21;
 Oid_int2_ar      = 1005;
 Oid_Int4         = 23;
 Oid_Int4_ar      = 1007;
 Oid_Float4       = 700;
 Oid_Float4_ar    = 1021;
 Oid_Float8       = 701;
 Oid_Float8_ar    = 1022;
 Oid_Unknown      = 705;
 Oid_Unknown_ar   = 0;
 Oid_bpchar       = 1042;
 Oid_bpchar_ar    = 1014;
 Oid_varchar      = 1043;
 Oid_varchar_ar   = 1015;
 Oid_timestamp    = 1114;
 Oid_timestamp_ar = 1115;
 oid_date         = 1082;
 oid_date_ar      = 1182;
 oid_time         = 1083;
 oid_time_ar      = 1183;
 oid_numeric      = 1700;
 oid_numeric_ar   = 1231;
 oid_uuid         = 2950;
 oid_uuid_ar      = 2951;
 pg_diag_sqlstate = 'C';
 
 inv_read =  $40000;
 inv_write = $20000;
 invalidoid = 0;

 varhdrsz = 4;
 nbase = 10000; //base for numeric digits
 maxprecision = 18;

type
 tdatabase1 = class(tdatabase);

{ TPQCursor }

procedure TPQCursor.close;
begin
 inherited;
 if fopen then begin
  arrayinfo:= nil;
  fopen:= false;
  if res <> nil then begin
   pqclear(res);
  end;
 end;
end;
  
{ tpqconnection }
  
constructor tpqconnection.create(aowner: tcomponent);
begin
 feventcontroller:= tdbeventcontroller.create(idbeventcontroller(self));
 inherited;
 fconnoptions:= fconnoptions + [sco_supportparams,sco_emulateretaining];
end;

destructor TPQConnection.destroy;
begin
 inherited;
 feventcontroller.free;
end;

function TPQConnection.GetTransactionHandle(trans : TSQLHandle): pointer;
begin
  Result := trans;
end;

procedure TPQConnection.checkerror(const aconnection: ppgconn;
         var ares: ppgresult; const amessage: ansistring);
var
// err: integer;
 res: texecstatustype;
begin
 res:= PQresultStatus(ares);
 if not(res in [PGRES_COMMAND_OK,PGRES_TUPLES_OK]) then begin
  flastsqlcode:= strpas(pqresulterrorfield(ares,ord(pg_diag_sqlstate)));
  flasterrormessage:= connectionmessage(pqresulterrormessage(ares));
  PQclear(ares);
  ares:= nil;
  raise epqerror.create(self,amessage+' (PostgreSQL: '+
                            ansistring(flasterrormessage)+ ')',
                            flasterrormessage,flastsqlcode);
 end
 else begin
  if res <> pgres_tuples_ok then begin
   PQclear(ares);
   ares:= nil;
  end;
 end;
end;

procedure tpqconnection.checkexec(const aconnection: ppgconn; const asql: ansistring;
                const amessage: ansistring);
var
 res: ppgresult;
begin
 res:= pqexec(aconnection,pchar(asql));
 checkerror(aconnection,res,amessage);
end;

procedure tpqconnection.begintrans(const aconnection: ppgconn;
                const aparams: ansistring);
begin
 checkexec(aconnection,'BEGIN '+aparams,sErrTransactionFailed);
end;

function TPQConnection.StartdbTransaction(const trans : TSQLHandle;
               const AParams: tstringlist) : boolean;
var
 int1: integer;
begin
 with tpqtrans(trans) do begin
  if fconn = nil then begin
   if not ftransactionconnectionused then begin
    fconn:= self.fhandle;
    ftransactionconnectionused:= true;
   end
   else begin
    openconnection(fconnectstring,fconn);
   end;  
  end;
  fparams:= '';  
  if aparams <> nil then begin
   for int1:= 0 to aparams.count - 1 do begin
    fparams:= fparams + aparams[int1] + ','
   end;
   if aparams.count > 0 then begin
    setlength(fparams,length(fparams)-1);
   end;
  end;
  begintrans(fconn,fparams);
 end;
 result:= true;
end;

function TPQConnection.RollBack(trans : TSQLHandle) : boolean;
begin
 checkexec(tpqtrans(trans).fconn,'ROLLBACK',SErrRollbackFailed);
 result := true;
end;

function TPQConnection.Commit(trans : TSQLHandle) : boolean;
begin
 checkexec(tpqtrans(trans).fconn,'COMMIT',SErrCommitFailed);
 result:= true;
end;

procedure TPQConnection.internalRollBackRetaining(trans : TSQLHandle);
begin
 with tpqtrans(trans) do begin
  checkexec(fconn,'ROLLBACK',SErrRollbackFailed);
  begintrans(fconn,fparams);
 end;
end;

procedure TPQConnection.internalCommitRetaining(trans : TSQLHandle);
begin
 with tpqtrans(trans) do begin
  checkexec(fconn,'COMMIT',SErrCommitFailed);
  begintrans(fconn,fparams);
 end;
end;

procedure TPQConnection.openconnection(const aconnectstring: string;
                                        var aconnection: ppgconn);
var
 msg: ansistring;
begin
 aconnection:= PQconnectdb(pchar(aConnectString));
 if (PQstatus(aconnection) = CONNECTION_BAD) then begin
  msg:= ansistring(connectionmessage(PQerrorMessage(aconnection)));
  pqfinish(aconnection);
  aconnection:= nil;
  DatabaseError(sErrConnectionFailed + ' (PostgreSQL: ' + msg + ')',self);
 end;
end;

function tpqconnection.constructconnectstring: ansistring;
begin
 result:= '';
 if (UserName <> '') then begin
  result := result + ' user=''' + UserName + '''';
 end;
 if (Password <> '') then begin
  result:= result + ' password=''' + Password + '''';
 end;
 if (HostName <> '') then begin
  result:= result + ' host=''' + HostName + '''';
 end;
 if (DatabaseName <> '') then begin
  result:= result + ' dbname=''' + DatabaseName + '''';
 end
 else begin
  result:= result + ' dbname=''' + 'postgres' + '''';
 end;
 if (Params.Text <> '') then begin
  result:= result + ' '+Params.Text;
 end;
end;

procedure TPQConnection.DoInternalConnect;
var 
// msg: string;
 bo1: boolean;
// int1: integer;
begin
{$IfDef LinkDynamically}
 InitializePostgres3([]);
{$EndIf}
 ftransactionconnectionused:= false;
 inherited dointernalconnect;
 fconnectstring:= constructconnectstring;
 openconnection(fconnectstring,fhandle);
// This does only work for pg>=8.0, so timestamps won't work with earlier versions of pg which are compiled with integer_datetimes on
 if {$ifndef FPC}@{$endif}pqparameterstatus <> nil then begin
  FIntegerDatetimes := pqparameterstatus(FHandle,'integer_datetimes') = 'on';
 end;
 bo1:= fconnected;
 fconnected:= true;
 feventcontroller.connect;
 fconnected:= bo1;
end;

procedure TPQConnection.DoInternalDisconnect;
//var
// int1: integer;
begin
 feventcontroller.disconnect;
 inherited;
 closeconnection(fhandle);
{$IfDef LinkDynamically}
 ReleasePostgres3;
{$EndIf}
end;

procedure TPQConnection.createdatabase(const asql: ansistring);
var
 conn: ppgconn;
begin
{$IfDef LinkDynamically}
 InitializePostgres3([]);
{$EndIf}
 try
  openconnection(constructconnectstring,conn);
  dopqexec(asql,conn);
  closeconnection(conn);
 finally
 {$IfDef LinkDynamically}
  ReleasePostgres3;
 {$EndIf}
 end; 
end;

function TPQConnection.TranslateFldType(Type_Oid : integer; 
                 out isarray: boolean; out vartype: word) : TFieldType;

begin
 isarray:= false;
 vartype:= 0;
 case Type_Oid of
  Oid_varchar,Oid_bpchar,
  Oid_name: begin
    Result:= ftstring;
  end;
  Oid_varchar_ar,Oid_bpchar_ar,
  Oid_name_ar: begin
   Result:= ftstring;
   isarray:= true;
   vartype:= varolestr;
  end;
  Oid_text: begin
   Result:= ftstring;
  end;
  Oid_text_ar: begin
   Result:= ftstring;
   isarray:= true;
   vartype:= varolestr;
  end;
  Oid_bytea: begin
   result:= ftBlob;
  end;
  Oid_bytea_ar: begin
   result:= ftBlob;
   isarray:= true;
  end;
  Oid_oid: begin
   Result:= ftInteger;
  end;
  Oid_oid_ar: begin
   Result:= ftInteger;
   isarray:= true;
   vartype:= varinteger;
  end;
  Oid_int8: begin
   Result:= ftLargeInt;
  end;
  Oid_int8_ar: begin
   Result:= ftLargeInt;
   isarray:= true;
   vartype:= varint64;
  end;
  Oid_int4: begin
   Result:= ftInteger;
  end;
  Oid_int4_ar: begin
   Result:= ftInteger;
   isarray:= true;
   vartype:= varinteger;
  end;
  Oid_int2: begin
   Result:= ftSmallInt;
  end;
  Oid_int2_ar: begin
   Result:= ftSmallInt;
   isarray:= true;
   vartype:= varinteger;
  end;
  Oid_Float4,Oid_Float8: begin
   Result:= ftFloat;
  end;
  Oid_Float4_ar,Oid_Float8_ar: begin
   Result:= ftFloat;
   isarray:= true;
   vartype:= vardouble;
  end;
  Oid_TimeStamp: begin
   Result:= ftDateTime;
  end;
  Oid_TimeStamp_ar: begin
   Result:= ftDateTime;
   isarray:= true;
   vartype:= vardate;
  end;
  Oid_Date: begin
   Result:= ftDate;
  end;
  Oid_Date_ar: begin
   Result:= ftDate;
   isarray:= true;
   vartype:= vardate;
  end;
  Oid_Time: begin
   Result:= ftTime;
  end;
  Oid_Time_ar: begin
   Result:= ftTime;
   isarray:= true;
   vartype:= vardate;
  end;
  Oid_Bool: begin
   Result:= ftBoolean;
  end;
  Oid_Bool_ar: begin
   Result:= ftBoolean;
   isarray:= true;
   vartype:= varboolean;
  end;
  Oid_Numeric: begin
   Result:= ftBCD;
  end;
  Oid_Numeric_ar: begin
   Result:= ftBCD;
   isarray:= true;
   vartype:= varcurrency;
  end;
  oid_uuid: begin
   result:= ftguid;
  end;
  oid_uuid_ar: begin
   result:= ftguid;
   isarray:= true;
   vartype:= varstring;
  end;
  Oid_Unknown: begin
   Result:= ftUnknown;
  end;
  else begin
    Result:= ftUnknown;
  end;
 end;
end;

Function TPQConnection.AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor;
begin
 result:= TPQCursor.create(aowner,aname);
end;

Procedure TPQConnection.DeAllocateCursorHandle(var cursor : TSQLCursor);

begin
  FreeAndNil(cursor);
end;

Function TPQConnection.AllocateTransactionHandle : TSQLHandle;

begin
 result:= TPQTrans.create;
end;

procedure tpqconnection.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);

const TypeStrings : array[TFieldType] of string =
    (
      'Unknown',  //ftUnknown
      'varchar',  //ftString 
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
      'varchar',  //ftFixedChar
      'varchar',  //ftWideString
      'bigint',   //ftLargeint
      'Unknown',  //ftADT
      'Unknown',  //ftArray
      'Unknown',  //ftReference
      'Unknown',  //ftDataSet
      'Unknown',  //ftOraBlob
      'Unknown',  //ftOraClob
      'Unknown',  //ftVariant
      'Unknown',  //ftInterface
      'Unknown',  //ftIDispatch
      'uuid',     //ftGuid
      'Unknown',  //ftTimeStamp
      'Unknown'   //ftFMTBcd
      ,'varchar', //ftFixedWideChar
      'Unknown'   //ftWideMemo
    );

const
 savepoint = 'mseinternal$prep;';
var 
 s: string;
 i: integer;
 str1: string;
 bo1: boolean;
 n: integer;
begin
 with TPQCursor(cursor) do begin
  if tpqtrans(atransaction.trans).fconn = nil then begin
   tpqtrans(atransaction.trans).fconn:= fhandle; //fake transaction
  end;
  FPrepared := False;
  // Prior to v8 there is no support for cursors and parameters.
  // So that's not supported.
  if FStatementType in [stInsert,stUpdate,stDelete,stSelect] then begin
   tr:= TPQTrans(aTransaction.Handle);
   repeat
    n:= interlockedincrement(fcursorcount) and $ffffff;
             //limit range 0..167774655
    nr:= inttostr(n);
    // Only available for pq 8.0, so don't use it...
    // Res := pqprepare(tr,'prepst'+name+nr,pchar(buf),params.Count,pchar(''));
    s:= 'prepare prepst'+nr+' ';
    if Assigned(AParams) and (AParams.count > 0) then begin
     s:= s + '(';
     for i := 0 to AParams.count-1 do begin
      with AParams[i] do begin
       if datatype = ftvariant then begin
        s:= s+'unknown,';
       end
       else begin
        if TypeStrings[DataType] <> 'Unknown' then begin
         s:= s + TypeStrings[DataType] + ','
        end
        else begin
         if DataType = ftUnknown then begin
          DatabaseErrorFmt(SUnknownParamFieldType,[Name],self);
         end
         else begin
          DatabaseErrorFmt(SUnsupportedParameter,
                       [Fieldtypenames[DataType]],self);
         end;
        end;
       end;
      end;
     end;
     s[length(s)]:= ')';
     str1:= todbstring(AParams.ParseSQL(asql,false,false,false,psPostgreSQL));
    end
    else begin
     str1:= todbstring(asql);
    end;
    s:= s + ' as ' + str1;
    pqexec(tr.fconn,'SAVEPOINT '+savepoint);
    res := pqexec(tr.fconn,pchar(s));
    bo1:= (PQresultStatus(res) = PGRES_COMMAND_OK);
    if not bo1 then begin
     pqexec(tr.fconn,'ROLLBACK TO SAVEPOINT '+savepoint);
    end
    else begin
     pqexec(tr.fconn,'RELEASE SAVEPOINT '+savepoint);
    end;
   until bo1 or 
          (strpas(pqresulterrorfield(res,ord(pg_diag_sqlstate))) <> '42P05');
           //no   duplicate_prepared_statement
   if (PQresultStatus(res) <> PGRES_COMMAND_OK) then begin
     s:= ansistring(connectionmessage(pqresulterrormessage(res)));
     pqclear(res);
     DatabaseError(SErrPrepareFailed + lineend +
          ' (PostgreSQL: ' + s + ')',self)
   end;
   FPrepared := True;
  end
  else begin
   Statementm:= {todbstring(}AParams.ParseSQL(asql,false,false,false,psSimulated,
                  paramBinding,ParamReplaceString){)};
//      statement := buf;
  end;
 end;
end;

procedure TPQConnection.UnPrepareStatement(cursor : TSQLCursor);

begin
 with tpqcursor(cursor) do begin
  if FPrepared then begin
   close;
//   if not tr.ErrorOccured then begin
   res := pqexec(tr.fconn,pchar('deallocate prepst'+nr));
   if (PQresultStatus(res) <> PGRES_COMMAND_OK) then begin
    pqclear(res);
    rollback(tr);
    res := pqexec(tr.fconn,pchar('deallocate prepst'+nr));
    {
       DatabaseError(SErrPrepareFailed + ' (PostgreSQL: ' + 
            PQerrorMessage(tr.fconn) + ')',self)
     }
   end;
      //problem with aborted transaction
   pqclear(res);
//  end;
   FPrepared := False;
  end;
 end;
end;

procedure TPQConnection.FreeFldBuffers(cursor : TSQLCursor);

begin
// Do nothing
end;

procedure TPQConnection.internalExecute(const cursor: TSQLCursor; 
           const atransaction: tsqltransaction; const AParams : TmseParams;
           const autf8: boolean);

var
 ar: array of pointer;
 i: integer;
 s: string;
 lengths,formats: integerarty;
 mstr1: msestring;

begin
 with TPQCursor(cursor) do begin
  frowsreturned:= -1;
  frowsaffected:= -1;
  curtuple:= -1;
  if FStatementType in [stInsert,stUpdate,stDelete,stSelect] then begin
   if Assigned(AParams) and (AParams.count > 0) then begin
    setlength(ar,Aparams.count);
    setlength(lengths,length(ar));
    setlength(formats,length(ar));
    for i := 0 to AParams.count -1 do begin
     with AParams[i] do begin
      if not IsNull then begin
       case DataType of
        ftdatetime: s:= formatdatetime('YYYY-MM-DD hh:nn:ss',AsDateTime);
        ftdate: s:= formatdatetime('YYYY-MM-DD',AsDateTime);
        fttime: s:= formatdatetime('hh:nn:ss',AsDateTime);
        ftfloat,ftcurrency: s:= realtostr(asfloat);
        ftbcd: s:= realtostr(ascurrency);
        ftvariant: begin
         if isutf8 then begin
          s:= stringtoutf8ansi(encodesqlvariant(value,true));
         end
         else begin
          s:= ansistring(encodesqlvariant(value,true));
         end;
        end;
        else begin
         s:= AParams.asdbstring(i);
         if datatype = ftblob then begin
          formats[i]:= 1; //binary
         end;
        end;
       end; {case}
       lengths[i]:= length(s);
       GetMem(ar[i],length(s)+1);
       StrMove(PChar(ar[i]),Pchar(s),Length(S)+1);
      end;
     end;
    end;
    res := PQexecPrepared(tr.fconn,pchar('prepst'+nr),Aparams.count,@Ar[0],
             pointer(lengths),pointer(formats),1);
    for i := 0 to AParams.count -1 do begin
     FreeMem(ar[i]);
    end;
   end
   else begin
    res:= PQexecPrepared(tr.fconn,pchar('prepst'+nr),0,nil,nil,nil,1);
   end;
  end
  else begin
   tr := TPQTrans(cursor.ftrans);
   if aparams <> nil then begin
    mstr1:= aparams.expandvalues(statementm,parambinding,paramreplacestring);
   end
   else begin
    mstr1:= statementm;
   end;
   if autf8 then begin
    s:= stringtoutf8ansi(mstr1);
   end
   else begin
    s:= ansistring(mstr1);
   end;
   res:= pqexec(tr.fconn,pchar(s));
  end;
  frowsaffected:= strtointdef(pqcmdtuples(res),-1);
  checkerror(tr.fconn,res,'Execution of query failed');
  frowsreturned:= pqntuples(res);
  fopen:= true;
 end;
end;

procedure tpqconnection.internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string);
begin
 with TPQCursor(cursor) do begin
  tr := TPQTrans(cursor.ftrans);
  frowsreturned:= -1;
  frowsaffected:= -1;
  curtuple:= -1;
//  res:= pqexec(tr.fconn,pchar(asql));
  res:= pqexecparams(tr.fconn,pchar(asql),0,nil,nil,nil,nil,1);
  
  frowsaffected:= strtointdef(pqcmdtuples(res),-1);
  checkerror(tr.fconn,res,'Execution of query failed');
  frowsreturned:= pqntuples(res);
  fopen:= true;
 end;
end;

procedure TPQConnection.AddFieldDefs(const cursor: TSQLCursor;
                    const FieldDefs : TfieldDefs);
var
 i: integer;
 size: integer;
// st: string;
 fieldtype: tfieldtype;
 nFields: integer;
 fd: tfielddef;
 str1: ansistring;
 int1: integer;
 precision: integer;
 isarray: boolean;
begin
 precision:= 0;
 fielddefs.clear;
 with tpqcursor(cursor) do begin
  nFields:= PQnfields(Res);
  setlength(arrayinfo,nfields);
  for i:= 0 to nFields-1 do begin
   fieldtype:= TranslateFldType(PQftype(Res,i),isarray,arrayinfo[i].vartype);
   arrayinfo[i].fieldtype:= fieldtype;
   if isarray then begin
    fieldtype:= ftvariant;
    size:= 0;
   end
   else begin
    size:= PQfsize(Res,i);
    case fieldtype of
     ftstring: begin
      if size = -1 then begin
       size:= pqfmod(res,i)-4;
       if size = -5 then begin //text
        if stringmemo then begin
         size:= 0;
        end
        else begin
         fieldtype:= ftmemo;
         size:= blobidsize;
        end;
       end;
      end;
     end;
     ftdate: begin
      size:= sizeof(double);
     end;
     ftblob,ftmemo: begin
      size:= blobidsize;
     end;
     ftbcd: begin
      int1:= PQfmod(Res,i) - varhdrsz; //can be -1 - 4 = -5
      size:= int1 and $ffff;
      precision:= int1 and $ffff0000 shr 16;
      if (dbo_bcdtofloatif in controller.options) and (size > 4) then begin
                              //for pqfmod = -1 too
       fieldtype:= ftfloat;
      end
      else begin
       if size > 4 then begin
        size:= 4;
       end;
      end;
     end;
    end;
   end;
   str1:= PQfname(Res,i);
   if not(fieldtype in varsizefields) then begin
    size:= 0;
   end;
   fd:= TFieldDef.Create(nil,str1,fieldtype,size,False,(i+1));
   fd.collection:= fielddefs;
   if fieldtype = ftbcd then begin
    if precision > maxprecision then begin
     precision:= maxprecision;
    end;
    fd.precision:= precision;
   end;
  end;
 end;
end;

function TPQConnection.GetHandle: pointer;
begin
  Result := FHandle;
end;

function TPQConnection.Fetch(cursor : TSQLCursor) : boolean;

//var st : string;

begin
  with cursor as TPQCursor do
    begin
    inc(CurTuple);
    Result := (PQntuples(res)>CurTuple);
    end;
end;

type
 arraytypeheaderty = record
//  size: integer;        // total array size (varlena requirement)
  ndim: cint;			// # of dimensions
  flags: cint;          // implementation flags
                        // flags field is currently unused, always zero.
  elemtype: oid;		// element type OID
 end;
 arraytype = record
  header: arraytypeheaderty;
  data: record
 //dim: array[ndim] of cint;
                         // size of each array axis (C array of int)
 //dim_lower: array[ndim] of cint; 
                         // lower boundary of each dimension (C array of int)
 //<actual data>         // whatever is the stored data
  end;
 end;
 parraytype = ^arraytype;

 vararrayboundarty = array of tvararraybound;

type
 TNumericRecord = record
  Digits : SmallInt;
  Weight : SmallInt;
  Sign   : SmallInt;
  Scale  : Smallint;
 end;
 pnumericrecord = ^tnumericrecord;
  
function tpqconnection.loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //zero based
      const buffer: pointer; var bufsize: integer;
                             const aisutf8: boolean): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize

 
const
 numericpos = $0000;
 numericneg = $4000;
 numericnan = $8000;
 numericsigmask = $c000;
 
var
//  x{,i}           : integer;
  CurrBuff      : pchar;

 function getnumeric(out numericrecord: tnumericrecord): boolean;
 begin
  NumericRecord.Digits := BEtoN(pNumericRecord(currbuff)^.Digits);
  NumericRecord.Scale := BEtoN(pNumericRecord(currbuff)^.Scale);
  NumericRecord.Weight := BEtoN(pNumericRecord(currbuff)^.Weight);
  numericrecord.sign:= beton(pnumericrecord(currbuff)^.sign);
  inc(currbuff,sizeof(TNumericRecord));
  result:= numericrecord.sign and numericnan = 0;
//          if (NumericRecord^.Digits = 0) and (NumericRecord^.Scale = 0) then 
// = NaN, which is not supported by Currency-type, so we return NULL 
        //???? 0 in database seems to return digits and scale 0. mse
 end;
 
 function getfloat4: single;
 var
  si1: single;
 begin
 {$ifdef FPC}
  integer(si1):= beton(pinteger(currbuff)^);
 {$else}
  integer(ar4ty(si1)):= beton(pinteger(currbuff)^);
 {$endif}
  result:= si1;
 end;
 
 function getfloat8: double;
 begin
 {$ifdef FPC}
  int64(result):= beton(pint64(currbuff)^);
 {$else}
  int64(ar8ty(result)):= beton8(pint64(currbuff)^);
 {$endif}
 end;
 
  procedure handleitem(const adatatype: tfieldtype;{ const currbuff: pointer;}
               const asize: integer; const atype: integer; var buffer: pchar);
  var
   li            : Longint;
//   dbl           : pdouble;
   cur           : currency;
   lint1: int64;
//   sint1: smallint;
   wbo1: wordbool;
   do1: double;
   int1: integer;
   tel: byte;
   numericrecord: tnumericrecord;
   str1: string;
  begin
   with TPQCursor(cursor) do begin
    case aDataType of
     ftInteger,ftSmallint,ftword: begin
      int1:= 0;
      case asize of               // postgres returns big-endian numbers
       sizeof(integer): begin
        int1:= BEtoN(pinteger(CurrBuff)^);
       end;
       sizeof(smallint): begin
        int1:= BEtoN(psmallint(CurrBuff)^);
       end;
      end;
      move(int1,buffer^,sizeof(int1));
      inc(buffer,sizeof(integer));
      inc(currbuff,asize);
     end;
     ftlargeint: begin
     {$ifdef FPC}
      lint1:= BEtoN(pint64(CurrBuff)^);
     {$else}
      lint1:= BEtoN8(pint64(CurrBuff)^);
     {$endif}
      move(lint1,buffer^,sizeof(lint1));
      inc(buffer,sizeof(int64));
      inc(currbuff,asize);
     end;
     ftfloat,ftcurrency: begin
      if atype = oid_numeric then begin
       if getnumeric(numericrecord) then begin
        do1:= 0;
        for int1 := NumericRecord.Digits - 1 downto 0 do begin
         do1:= do1 + beton(pword(currbuff)^) * intpower(nbase,int1);
         inc(currbuff,2);
        end;
        int1:= numericrecord.weight - numericrecord.digits + 1;
        if int1 < 0 then begin
         do1:= do1 / intpower(nbase,-int1);
        end
        else begin
         do1:= do1 * intpower(nbase,int1);
        end;
        if NumericRecord.Sign <> 0 then begin
         do1:= -do1;
        end;
       end
       else begin
        do1:= nan;
       end;
      end
      else begin
       if atype = oid_float4 then begin
        do1:= getfloat4;
       end
       else begin
        do1:= getfloat8;
       end;
      end;
      Move(do1, Buffer^, sizeof(do1));
      inc(buffer,sizeof(do1));
      inc(currbuff,asize);
     end;
     ftString: begin
      if datatype = ftvariant then begin
       setlength(str1,asize);
       move(currbuff^,str1[1],asize);
       if aisutf8 then begin
        pwidestring(buffer)^:= utf8tostringansi(str1);
       end
       else begin
        pwidestring(buffer)^:= msestring(str1);
       end;
       inc(buffer,sizeof(widestring));
       inc(currbuff,asize);
      end
      else begin
       li:= pqgetlength(res,curtuple,fieldnum);
       if bufsize < li then begin
        bufsize:= -li;
       end
       else begin
        bufsize:= li;
        Move(CurrBuff^,Buffer^,li);
       end;
      end;
     end;
     ftblob,ftmemo,ftgraphic: begin
      li := pqgetlength(res,curtuple,fieldnum);
      int1:= addblobdata(currbuff,li);
      move(int1,buffer^,sizeof(int1));
       //save id
     end;
     ftdate: begin
      do1:= BEtoN(plongint(CurrBuff)^) + 36526;
      move(do1,buffer^,sizeof(do1));
      inc(buffer,sizeof(do1));
      inc(currbuff,asize);
     end;
     ftDateTime,fttime: begin
     {$ifdef FPC}
      do1:= double(BEtoN(pint64(CurrBuff)^));
     {$else}
      do1:= double(ar8ty(BEtoN8(pint64(CurrBuff)^)));
     {$endif}
      if FIntegerDatetimes then begin
       do1:= do1/1000000;
      end;
      do1:= (do1+3.1558464E+009)/86400;  // postgres counts seconds elapsed since 1-1-2000
      // Now convert the mathematically-correct datetime to the
      // illogical windows/delphi/fpc TDateTime:
      if (do1 <= 0) and (frac(do1)<0) then begin
       do1:= trunc(do1)-2-frac(do1);
      end;
      move(do1,buffer^,sizeof(do1));
      inc(buffer,sizeof(do1));
      inc(currbuff,asize);
     end;
     ftBCD: begin
      
      case atype of
       oid_float4: begin
        cur:= getfloat4;
       end;
       oid_float8: begin
        cur:= getfloat8;
       end;
       else begin
        cur := 0;
        result:= getnumeric(numericrecord);
        if result then begin
         for tel := 1 to NumericRecord.Digits  do begin
           cur := cur + beton(pword(currbuff)^) * intpower(10000,-(tel-1)+
                                                       NumericRecord.weight);
           inc(currbuff,2);
         end;
         if NumericRecord.Sign <> 0 then begin
          cur := -cur;
         end;
        end;
       end;
      end;
      Move(Cur, Buffer^, sizeof(cur));
      inc(buffer,sizeof(cur));
//      inc(currbuff,asize);
     end;
     ftBoolean: begin
      if datatype = ftvariant then begin
       pboolean(buffer)^:= CurrBuff[0] <> #0;
       inc(buffer,sizeof(boolean));
      end
      else begin
       wbo1:= CurrBuff[0] <> #0;
       move(wbo1,buffer^,sizeof(wbo1));
       inc(buffer,sizeof(wbo1));
      end;
      inc(currbuff,asize);
     end;
     ftguid: begin
     {$ifdef FPC}
      with pguid(currbuff)^ do begin
       pguid(buffer)^.time_low:= beton(time_low);
       pguid(buffer)^.time_mid:= beton(time_mid);
       pguid(buffer)^.time_hi_and_version:= beton(time_hi_and_version);
       pguid(buffer)^.clock_seq_hi_and_reserved:= clock_seq_hi_and_reserved;
       pguid(buffer)^.clock_seq_low:= clock_seq_low;
       pguid(buffer)^.node:= node;
      end;
     {$else}
      with pguid_fpc(currbuff)^ do begin
       pguid_fpc(buffer)^.time_low:= beton(time_low);
       pguid_fpc(buffer)^.time_mid:= beton(time_mid);
       pguid_fpc(buffer)^.time_hi_and_version:= beton(time_hi_and_version);
       pguid_fpc(buffer)^.clock_seq_hi_and_reserved:= clock_seq_hi_and_reserved;
       pguid_fpc(buffer)^.clock_seq_low:= clock_seq_low;
       pguid_fpc(buffer)^.node:= node;
      end;
     {$endif}
      inc(buffer,sizeof(tguid));
      inc(currbuff,asize);
     end;
     else begin
      result := false;
     end;
    end;
   end;
  end;

var
 int1,int2,int3,eltype: integer;   
 typ1: tfieldtype;
 ar1: vararrayboundarty;
 po1: pcint;
 po2: pointer;
 
begin
{$ifdef FPC}{$checkpointer off}{$endif}
 with TPQCursor(cursor) do begin
  result:= pqgetisnull(res,CurTuple,fieldnum) = 0;
  if not result or (buffer = nil) then begin
   exit;
  end;
  CurrBuff := pqgetvalue(res,CurTuple,fieldnum);
  if datatype = ftvariant then begin
   with parraytype(currbuff)^,header do begin
//    int1:= pqgetlength(res,curtuple,fieldnum);
    setlength(ar1,beton(ndim));
    if ar1 = nil then begin
     result:= false;
     exit;
    end;
    po1:= @data;
    int2:= 1;
    for int1:= 0 to high(ar1) do begin
     int3:= beton(po1^);
     ar1[int1].elementcount:= int3;    //dim
     inc(po1);
     ar1[int1].lowbound:= beton(po1^); //dim_lower
     int2:= int2*int3;
     inc(po1);
    end;
//    inc(po1,length(ar1)); //skip dim_lower
    eltype:= beton(elemtype);
    currbuff:= pointer(po1);
    typ1:= arrayinfo[fieldnum].fieldtype;
    pvariant(buffer)^:= msevararraycreate(pointer(ar1),length(ar1),
                                             arrayinfo[fieldnum].vartype);
    po2:= pvardata(buffer)^.varray^.data;
    for int1:= 0 to int2-1 do begin
     int3:= beton(pinteger(currbuff)^); //alignment?
     inc(pinteger(currbuff));
     handleitem(typ1,int3,eltype,pchar(po2));
    end;
   end;
  end
  else begin
   po2:= buffer;
   handleitem(datatype,{currbuff,}PQfsize(res,fieldnum),pqftype(res,fieldnum),
                      pchar(po2));
  end;
 end;
{$ifdef FPC}{$checkpointer default}{$endif}
end;

function TPQConnection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
begin
 result:= '';
{$ifdef FPC}{$checkpointer off}{$endif}
 with TPQCursor(cursor) do begin
  if pqgetisnull(res,CurTuple,fieldnum) <> 1 then begin
   setlength(result,pqgetlength(res,curtuple,fieldnum));
   if result <> '' then begin
    move(pqgetvalue(res,CurTuple,fieldnum)^,result[1],length(result));
   end;
  end;
 end;
end;

procedure tpqconnection.updateindexdefs(var indexdefs : tindexdefs;
                          const atablename : string);

var
 qry : tsqlresult;
begin
 if not assigned(transaction) then
   databaseerror(serrconntransactionnset);

 qry:= tsqlresult.create(nil);  
 try 
  with qry do begin
   database:= self;
   sql.text:= 'select '+
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
              '(upper(tc.relname)=''' +  
                      msestring(UpperCase(aTableName)) +''') '+
            'order by '+
              'ic.relname;';
   active:= true;
   while not eof do begin 
    with IndexDefs.AddIndexDef do begin
     Name:= trim(qry.cols[0].asstring);
     Fields:= trim(qry.cols[2].asstring);
     If cols[3].asboolean then begin
      options:= options + [ixPrimary];
     end;
     If cols[4].asboolean then begin
      options:= options + [ixUnique];
     end;
     next;
     while not qry.eof and (name = cols[0].asstring) do begin
      fields:= fields + ';' + trim(cols[2].asstring);
      next;
     end;
    end;
   end;
  end;
 finally
  qry.free;
 end;
end;

function TPQConnection.GetSchemaInfoSQL(SchemaType: TSchemaType;
  SchemaObjectName, SchemaPattern: msestring): msestring;

var s : msestring;

begin
 s:= '';
  case SchemaType of
    stTables     : s := 'select '+
                          'relfilenode              as recno, '+
                          '''' + msestring(DatabaseName) + 
                          ''' as catalog_name, '+
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
                          '''' + msestring(DatabaseName) + 
                          ''' as catalog_name, '+
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

procedure TPQConnection.writeblobdata(const atransaction: tsqltransaction;
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

procedure TPQConnection.setupblobdata(const afield: tfield; 
                      const acursor: tsqlcursor; const aparam: tparam);
begin
 acursor.blobfieldtoparam(afield,aparam,false);
end;

function TPQConnection.getblobdatasize: integer;
begin
 result:= sizeof(integer);
end;

function TPQConnection.blobscached: boolean;
begin
 result:= true;
end;

procedure TPQConnection.dolisten(const sender: tdbevent);
begin
 dopqexec('LISTEN '+sender.eventname+';');
end;

procedure TPQConnection.dounlisten(const sender: tdbevent);
begin
 dopqexec('UNLISTEN '+sender.eventname+';');
end;

procedure TPQConnection.listen(const sender: tdbevent);
begin
 feventcontroller.register(sender);
 if connected then begin
  dolisten(sender);
 end;
end;

procedure TPQConnection.unlisten(const sender: tdbevent);
begin
 if connected then begin
  dounlisten(sender);
 end;
 feventcontroller.unregister(sender);
end;

procedure TPQConnection.fire(const sender: tdbevent);
begin
 dopqexec('NOTIFY '+sender.eventname+';');
end;

function TPQConnection.getdbevent(var aname: string; var aid: int64): boolean;
var
 info: ppgnotify;
begin
 pqconsumeinput(fhandle);
 info:= pqnotifies(fhandle);
 result:= info <> nil;
 if result then begin
  aname:= info^.relname;
  aid:= info^.be_pid;
  pqfreemem(info);
 end;
end;

function TPQConnection.geteventinterval: integer;
begin
 result:= feventcontroller.eventinterval;
end;

procedure TPQConnection.seteventinterval(const avalue: integer);
begin
 feventcontroller.eventinterval:= avalue;
end;

procedure tpqconnection.dopqexec(const asql: ansistring; const aconnection: ppgconn);
var
 res: ppgresult;
begin
 res:= pqexec(aconnection,pchar(asql));
 if pqresultstatus(res) <> pgres_command_ok then begin
  pqclear(res);
  databaseerror('PQExecerror'+ ' (postgresql: ' + 
            ansistring(connectionmessage(pqerrormessage(aconnection)))
                                                                + ')',self);
 end
 else begin
  pqclear(res);
 end;
end;

procedure tpqconnection.dopqexec(const asql: ansistring);
begin
 dopqexec(asql,fhandle);
end;

function TPQConnection.backendpid: int64;
begin
 if not connected then begin
  result:= 0;
 end
 else begin
  result:= pqbackendpid(fhandle);
 end;
end;

function TPQConnection.getnumboolean: boolean;
begin
 result:= false;
end;

procedure TPQConnection.closeconnection(var aconnection: ppgconn);
begin
 if aconnection <> nil then begin
  PQfinish(aconnection);
  aconnection:= nil;
 end;  
end;

procedure TPQConnection.finalizetransaction(const atransaction: tsqlhandle);
begin
 with tpqtrans(atransaction) do begin
  if (fconn <> fhandle) then begin
   closeconnection(fconn);
  end;
  fconn:= nil;
 end;
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

{ epqerror }

constructor epqerror.create(const asender: tcustomsqlconnection;
               const amessage: ansistring; const aerrormessage: msestring;
               const asqlcode: string);
begin
 fsqlcode:= asqlcode;
 inherited create(asender,amessage,aerrormessage,-1);
end;

end.
