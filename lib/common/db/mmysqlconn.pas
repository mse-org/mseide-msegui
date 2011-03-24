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

unit mmysqlconn;

{$ifdef VER2_1_5} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_2} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_3} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_4} {$define mse_FPC_2_2} {$endif}
{$ifdef VER2_5} {$define mse_FPC_2_2} {$endif}
{$if FPC_FULLVERSION >= 20300} {$define mse_FPC_2_2} {$endif}
{$mode objfpc}{$H+}
{$MACRO on}


{$DEFINE mysql51}

{$ifdef mysql51}
 {$define mysql50}
{$endif}
{$ifdef mysql50}
 {$define mysql41}
{$endif}

interface

uses
  Classes, SysUtils,msqldb,db,dynlibs,msestrings,msedb,
  mysqldyn,msetypes,ctypes;

Type

 tmysqlcursor = class;
 
 emysqlerror = class(econnectionerror)
  private
   fsqlcode: string;
  public
   constructor create(const asender: tcustomsqlconnection; const amessage: ansistring;
              const aerrormessage: msestring; const aerror: integer; const asqlcode: string);
   property sqlcode: string read fsqlcode;
 end;
  
  tmysqltrans = class(TSQLHandle)
   protected
    fconn: pmysql;
   public
    property conn: pmysql read fconn;
  end;
 
 bindinginfoty = record
  length: culong;
  buffer: pointer;
  isnull: boolean; //-> cchar
  isblob: boolean; //-> cchar
 end;
 pbindinginfoty = ^bindinginfoty;
 bindinginfoarty = array of bindinginfoty;
 
  tmysqlcursor = class(TSQLCursor)
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
    MapDSRowToMSQLRow: integerarty;
    fprimarykeyfieldname: string;
    fconn: pmysql;
    fparambinding: tparambinding;
    fprepstatement: pmysql_stmt;
    fresultmetadata: pmysql_res;
    fresultfieldcount: integer;
    fresultbindinginfo: bindinginfoarty;
    fresultbindings: pointer;
    fresultbuf: pointer;
    procedure freeprepstatement;
   public
  end;

  mysqloptionty = (myo_nopreparedstatements,myo_storeresult,myo_ssl);
  mysqloptionsty = set of mysqloptionty;
  
  tmysqlconnection = class (TSQLConnection,iblobconnection)
  private
   FDialect: integer;
   FHostInfo: String;
   FServerInfo: String;
   FMySQL1 : PMySQL;
//   FDidConnect : Boolean;
   fport: longword;
   flasterror: integer;
   foptions: mysqloptionsty;
   flasterrormessage: msestring;
   flastsqlcode: string;
   ftransactionconnectionused: boolean;
   fssl_key: filenamety;
   fssl_cert: filenamety;
   fssl_ca: filenamety;
   fssl_capath: filenamety;
   fssl_cipher: filenamety;
   function GetClientInfo: string;
   function GetServerStatus: String;
   procedure ConnectMySQL(var HMySQL : PMySQL;H,U,P : pchar);
   procedure freeresultbuffer(const cursor: tmysqlcursor);
   procedure begintrans(const aconnection: pmysql; const aparams: ansistring);
   procedure openconnection(var aconn: pmysql);
   procedure closeconnection(var aconnection: pmysql);
  protected
   Procedure checkerror(const Msg: String; const aconn: pmysql);
   Procedure checkstmterror(const Msg: String; const astmt: pmysql_stmt);

//   function stringtosqltext(const afeildtype: tfieldtype; const avalue: string): string;
    function StrToStatementType(s : msestring) : TStatementType; override;
//    Procedure ConnectToServer; virtual;
//    Procedure SelectDatabase; virtual;
//    function MySQLDataType(AType: enum_field_types; ASize, ADecimals: Integer; var NewType: TFieldType; var NewSize: Integer): Boolean;
    function MySQLDataType(const afield: mysql_field;
               const charsetinfo: my_charset_info; out NewType: TFieldType;
               out NewSize: Integer; out newprecision: integer): Boolean;
    function MySQLWriteData(const acursor: tsqlcursor; AType: enum_field_types;
                        ASize: Integer;
                        AFieldType: TFieldType;Source, Dest: PChar): Boolean;
    // SQLConnection methods
    procedure DoInternalConnect; override;
    procedure executeparams; override;
    procedure DoInternalDisconnect; override;
    function GetHandle : pointer; override;

//    function GetAsSQLText(Field : TField) : string; overload; override;
//    function GetAsSQLText(Param : TParam) : string; overload; override;

    Function AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor; override;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
    Function AllocateTransactionHandle : TSQLHandle; override;
    procedure finalizetransaction(const atransaction: tsqlhandle); override; 

    procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
    procedure UnPrepareStatement(cursor:TSQLCursor); override;
    procedure FreeFldBuffers(cursor : TSQLCursor); override;
    procedure doexecuteunprepared(const c: tmysqlcursor;
                   const atransaction: tsqltransaction; const asql: string);
    procedure internalExecute(const cursor: TSQLCursor;
       const atransaction:tSQLtransaction;
       const AParams: TmseParams; const autf8: boolean); override;
    procedure internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string); override;

    procedure AddFieldDefs(const cursor: TSQLCursor; 
                   const FieldDefs : TfieldDefs); override;
    function Fetch(cursor : TSQLCursor) : boolean; override;
    function loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //null based
      const abuffer: pointer; var abufsize: integer;
                                const aisutf8: boolean): boolean; override;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
    function GetTransactionHandle(trans : TSQLHandle): pointer; override;
    function Commit(trans : TSQLHandle) : boolean; override;
    function RollBack(trans : TSQLHandle) : boolean; override;
    function StartdbTransaction(const trans : TSQLHandle;
                const AParams: tstringlist) : boolean; override;
    procedure internalCommitRetaining(trans : TSQLHandle); override;
    procedure internalRollBackRetaining(trans : TSQLHandle); override;
    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                                          const TableName : string); override;

   function getprimarykeyfield(const atablename: string;
                                 const acursor: tsqlcursor): string; override;
   procedure updateprimarykeyfield(const afield: tfield;
                            const atransaction: tsqltransaction); override;
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                         const acursor: tsqlcursor): TStream; override;
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
   function identquotechar: ansistring; override;
   
  Public
   constructor create(aowner: tcomponent); override;
   function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; override;
                              //null based
   function getinsertid(const atransaction: tsqltransaction): int64; override;
   procedure createdatabase(const asql: ansistring);
   Property ServerInfo : String Read FServerInfo;
   Property HostInfo : String Read FHostInfo;
   property ClientInfo: string read GetClientInfo;
   property ServerStatus : String read GetServerStatus;
   property lasterror: integer read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
   property lastsqlcode: string read flastsqlcode;
  published
    property options: mysqloptionsty read foptions write foptions default [];
    property Dialect  : integer read FDialect write FDialect default 0;
    property port: longword read fport write fport default 0;
    property ssl_key: filenamety read fssl_key write fssl_key;
    property ssl_cert: filenamety read fssl_cert write fssl_cert;
    property ssl_ca: filenamety read fssl_ca write fssl_ca;
    property ssl_capath: filenamety read fssl_capath write fssl_capath;
    property ssl_cipher: filenamety read fssl_cipher write fssl_cipher;
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
 dbconst,msebufdataset,typinfo,dateutils,msefileutils,msedatabase;
type
 tmsebufdataset1 = class(tmsebufdataset);
var
 is51: boolean;
const
 maxprecision = 18;
   
Resourcestring
  SErrServerConnectFailed = 'Server connect failed: %s';
  SErrDatabaseSelectFailed = 'failed to select database: %s';
  SErrDatabaseCreate = 'Failed to create database: %s';
  SErrDatabaseDrop = 'Failed to drop database: %s';
  sbindresult = 'Failed to bind result: %s';
  serrstarttransaction = 'Failed to start transaction: %s';
  serrcommittransaction = 'Failed to commit transaction: %s';
  serrrollbacktransaction = 'Failed to rollback transaction: %s';
  serrprepare = 'Failed to prepare statement: %s';
  SErrNoData = 'No data for record';
  SErrExecuting = 'Error executing query: %s';
  SErrFetchingdata = 'Error fetching row data: %s';
  SErrGettingResult = 'Error getting result set: %s';
  SErrNoQueryResult = 'No result from query.';
  SErrNotversion50 = 'TMySQL50Connection can not work with the installed MySQL client version (%s).';
  SErrNotversion41 = 'TMySQL41Connection can not work with the installed MySQL client version (%s).';
  SErrNotversion40 = 'TMySQL40Connection can not work with the installed MySQL client version (%s).';

function datetimetomysql_time(const datatype: tfieldtype; 
                            const avalue: tdatetime): mysql_time;
var
 year1,month1,day1,hour1,minute1,second1,millisecond1: word;
begin
 fillchar(result,sizeof(result),0);
 decodedatetime(avalue,year1,month1,day1,hour1,minute1,second1,millisecond1);
 with result do begin
  if datatype in [ftdate,ftdatetime] then begin
   year:= year1;
   month:= month1;
   day:= day1;
   time_type:= mysql_timestamp_date;
  end;
  if datatype in [fttime,ftdatetime] then begin
   hour:= hour1;
   minute:= minute1;
   second:= second1;
   second_part:= millisecond1 * 1000;
   time_type:= mysql_timestamp_time;
  end;
  if datatype = ftdatetime then begin
   time_type:= mysql_timestamp_datetime;
  end;
 end;
end;

function mysql_timetodatetime(const avalue: mysql_time): tdatetime;
begin
 result:= 0;
 with avalue do begin
  case time_type of
   mysql_timestamp_date: begin
    tryencodedate(year,month,day,result);
   end;
   mysql_timestamp_time: begin
    tryencodetime(hour,minute,second,second_part div 1000,
                         result);
   end;
   else begin
    tryencodedatetime(year,month,day,hour,minute,second,second_part div 1000,
                         result);
   end;
  end;
 end;
end;

function createbindings(const acount: integer): pointer;
var
 int1: integer;
begin
 result:= nil;
 if is51 then begin
  int1:= acount * sizeof(mysql_bind_51);
 end
 else begin
  int1:= acount * sizeof(mysql_bind_50);
 end;
 if int1 > 0 then begin
  result:= getmem(int1);
  fillchar(result^,int1,0);
 end;
end;

function getbind(const abindings: pointer; const index: integer): pointer;
begin
 if is51 then begin
  result:= @pmysql_bind_51(abindings)[index];
 end
 else begin
  result:= @pmysql_bind_50(abindings)[index];
 end;
end;

procedure freebindings(var abindings: pointer);
begin
 if abindings <> nil then begin
  freemem(abindings);
  abindings:= nil;
 end;
end;

procedure setupresultbinding(const index: integer; const fieldtype: tfieldtype;
               const len: integer;     //character count
               const bindings: pointer; var bindinginfo: bindinginfoarty);
var
 bi: pbindinginfoty;
 bufsize: integer;
 pbuffer_type: penum_field_types;
 pbuffer_length: pculong;
begin
 bi:= @bindinginfo[index];
 if is51 then begin
  with pmysql_bind_51(bindings)[index] do begin
   pbuffer_type:= @buffer_type;
   pbuffer_length:= @buffer_length;
   length:= @bi^.length;
   is_null:= @bi^.isnull;
  end;
 end
 else begin
  with pmysql_bind_50(bindings)[index] do begin
   pbuffer_type:= @buffer_type;
   pbuffer_length:= @buffer_length;
   length:= @bi^.length;
   is_null:= @bi^.isnull;
  end;
 end;
 case fieldtype of
  ftinteger: begin
   bufsize:= sizeof(longint);
   pbuffer_type^:= mysql_type_long;
  end;
  ftlargeint: begin
   bufsize:= sizeof(int64);
   pbuffer_type^:= mysql_type_longlong;
  end;
  ftbcd,ftfloat: begin
   bufsize:= sizeof(double);
   pbuffer_type^:= mysql_type_double;
  end;
  ftdate,ftdatetime,fttime: begin
   bufsize:= sizeof(mysql_time);
   pbuffer_type^:= mysql_type_datetime;
  end;
  ftstring: begin
   bufsize:= len*4; //room for multibyte encodings
   pbuffer_type^:= mysql_type_var_string;
  end;
  ftblob,ftmemo,ftgraphic: begin
   bufsize:= 0;
   pbuffer_type^:= mysql_type_blob;
  end
  else begin
   bufsize:= 0;            //dummy
   pbuffer_type^:= mysql_type_null;
  end;
 end;
 pbuffer_length^:= bufsize;
 bi^.length:= bufsize;
 bi^.isblob:= bufsize = 0;
end;

procedure setupinputbinding(const index: integer; const fieldtype: tfieldtype;
               const bindings: pointer; var bindinginfo: bindinginfoarty;
               const abuffer: pointer; const abufsize: integer);
var
 bi: pbindinginfoty;
 bufsize: integer;
 pbuffer_type: penum_field_types;
 pbuffer_length: pculong;
begin
 bi:= @bindinginfo[index];
 if is51 then begin
  with pmysql_bind_51(bindings)[index] do begin
   pbuffer_type:= @buffer_type;
   pbuffer_length:= @buffer_length;
   length:= @bi^.length;
   is_null:= @bi^.isnull;
   buffer:= abuffer;
  end;
 end
 else begin
  with pmysql_bind_50(bindings)[index] do begin
   pbuffer_type:= @buffer_type;
   pbuffer_length:= @buffer_length;
   length:= @bi^.length;
   is_null:= @bi^.isnull;
   buffer:= abuffer;
  end;
 end;
 case fieldtype of
  ftinteger: begin
   bufsize:= sizeof(longint);
   pbuffer_type^:= mysql_type_long;
  end;
  ftlargeint: begin
   bufsize:= sizeof(int64);
   pbuffer_type^:= mysql_type_longlong;
  end;
  ftbcd,ftfloat: begin
   bufsize:= sizeof(double);
   pbuffer_type^:= mysql_type_double;
  end;
  ftdate,ftdatetime,fttime: begin
   bufsize:= sizeof(mysql_time);
   pbuffer_type^:= mysql_type_datetime;
  end;
  ftstring: begin
   bufsize:= abufsize;
   pbuffer_type^:= mysql_type_var_string;
  end;
  ftblob,ftmemo,ftgraphic: begin
   bufsize:= abufsize;
   pbuffer_type^:= mysql_type_blob;
  end
  else begin
   bufsize:= 0;          //dummy
   pbuffer_type^:= mysql_type_null;
  end;
 end;
 bi^.length:= bufsize;
 pbuffer_length^:= bufsize;
 bi^.isblob:= bufsize = 0;
end;

function createbindingbuffers(const bindings: pointer;
                          var bindinfos: bindinginfoarty): pointer;
var
 int1: integer;
 bufsum: longword;
begin
 bufsum:= 0;
 for int1:= 0 to high(bindinfos) do begin
  bufsum:= bufsum + bindinfos[int1].length;
 end;
 result:= getmem(bufsum);
 bufsum:= 0;
 for int1:= 0 to high(bindinfos) do begin
  with bindinfos[int1] do begin
   if length > 0 then begin
    buffer:= result + bufsum;
    if is51 then begin
     pmysql_bind_51(bindings)[int1].buffer:= buffer;
    end
    else begin
     pmysql_bind_50(bindings)[int1].buffer:= buffer;
    end;
    bufsum:= bufsum + length;
   end;
  end;
 end;   
end;

procedure freebindingbuffers(var abuffer: pointer);
begin
 if abuffer <> nil then begin
  freemem(abuffer);
  abuffer:= nil;
 end;
end;

procedure setbindingbuffer(const bindings: pointer; const index: integer; 
                          const abuffer: pointer; const alength: integer);
begin
 if is51 then begin
  with pmysql_bind_51(bindings)[index] do begin
   buffer:= abuffer;
   buffer_length:= alength;
  end;
 end
 else begin
  with pmysql_bind_50(bindings)[index] do begin
   buffer:= abuffer;
   buffer_length:= alength;
  end;
 end;
end;

{ tmysqlcursor }

procedure tmysqlcursor.freeprepstatement;
begin
 if fprepstatement <> nil then begin
  mysql_stmt_close(fprepstatement);
  fprepstatement:= nil;
 end;
end;

{ tmysqlconnection }

constructor tmysqlconnection.create(aowner: tcomponent);
begin
 inherited;
 fconnoptions:= fconnoptions + [sco_supportparams,sco_emulateretaining];
end;

Procedure tmysqlconnection.checkerror(const Msg: String; const aconn: pmysql);
var
 str1: msestring;
begin
 str1:= connectionmessage(mysql_error(aconn));
 flasterrormessage:= str1;
 flasterror:= mysql_errno(aconn);
 flastsqlcode:= strpas(mysql_sqlstate(aconn));
 raise emysqlerror.create(self,format(msg,[str1]),flasterrormessage,
                      flasterror,flastsqlcode);
end;

Procedure tmysqlconnection.checkstmterror(const Msg: String; 
                                                    const astmt: pmysql_stmt);
var
 str1: msestring;
begin
 str1:= connectionmessage(mysql_stmt_error(astmt));
 flasterrormessage:= str1;
 flasterror:= 0;          //???
 flastsqlcode:= '';       //???
 raise emysqlerror.create(self,format(msg,[str1]),flasterrormessage,
                      flasterror,flastsqlcode);
end;

function tmysqlconnection.StrToStatementType(s : msestring) : TStatementType;

begin
  S:=Lowercase(s);
  if s = 'show' then exit(stSelect);
  result := inherited StrToStatementType(s);
end;

function tmysqlconnection.GetClientInfo: string;

Var
  B : Boolean;

begin
  // To make it possible to call this if there's no connection yet
//  B:=(MysqlLibraryHandle=Nilhandle);
//  If B then
    InitializeMysql([]);
  Try  
    Result:=strpas(mysql_get_client_info());
  Finally  
//    if B then
      ReleaseMysql;
  end;  
end;

function tmysqlconnection.GetServerStatus: String;
begin
  CheckConnected;
  Result := mysql_stat(FMYSQL1);
end;

procedure tmysqlconnection.ConnectMySQL(var HMySQL : PMySQL;H,U,P : pchar);
var
 key,cert,ca,capath,cipher: string;
 hmysql1: pmysql;
 actcipher: pchar;
begin
 mysqllock;
 HMySQL := mysql_init(HMySQL);
 mysqlunlock;
 if myo_ssl in foptions then begin
  key:= tosysfilepath(fssl_key);
  cert:= tosysfilepath(fssl_cert);
  ca:= tosysfilepath(fssl_ca);
  capath:= tosysfilepath(fssl_capath);
  cipher:= fssl_cipher;  
  mysql_ssl_set(hmysql,pointer(key),pointer(cert),pointer(ca),pointer(capath),
           pointer(cipher));
 end;
 HMySQL1:=mysql_real_connect(HMySQL,PChar(H),PChar(U),Pchar(P),Nil,fport,Nil,0);
 If (HMySQL1=Nil) then begin
  checkerror(SErrServerConnectFailed,hmysql);
 end;
 if (myo_ssl in foptions) and (mysql_get_ssl_cipher <> nil) then begin
  actcipher:= mysql_get_ssl_cipher(hmysql);
  if actcipher =  nil then begin
   closeconnection(hmysql);
   databaseerror('Can not encrypt connection.',self);
  end;
 end;
end;
{
function tmysqlconnection.stringtosqltext(const afieldtype: tfieldtype;
                                                const avalue: string): string;
var 
 esc_str : pchar;
begin
 Getmem(esc_str,length(avalue)*2+1);
 mysql_real_escape_string(FMySQL,esc_str,pchar(str1),length(str1));
 Result := '''' + esc_str + '''';
 Freemem(esc_str);
end;

function tmysqlconnection.GetAsSQLText(Field : TField) : string;
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

function tmysqlconnection.GetAsSQLText(Param: TParam) : string;
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

procedure tmysqlconnection.openconnection(var aconn: pmysql);
Var
  H,U,P : String;

begin
 H:= HostName;
 U:= UserName;
 P:= Password;
 ConnectMySQL(aconn,pchar(H),pchar(U),pchar(P));
 if mysql_select_db(aconn,pchar(DatabaseName)) <> 0 then begin
   checkerror(SErrDatabaseSelectFailed,aconn);
 end;
end;

procedure tmysqlconnection.closeconnection(var aconnection: pmysql);
begin
 mysql_close(aconnection);
 aconnection:= nil;
end;

{
procedure tmysqlconnection.SelectDatabase;
begin
  if mysql_select_db(FMySQL,pchar(DatabaseName))<>0 then
    checkerror(SErrDatabaseSelectFailed);
end;
}

procedure tmysqlconnection.DoInternalConnect;
var
 version: integer;
begin
 ftransactionconnectionused:= false;
 InitializeMysql([]);
 version:= mysql_get_client_version() div 100;
 if version < 500 then begin
  raise exception.create(name+': MySql client version must be >= 5.0.');
 end;
 is51:= version >= 501;
 inherited DoInternalConnect;
 openconnection(fmysql1);
 FServerInfo := strpas(mysql_get_server_info(FMYSQL1));
 FHostInfo := strpas(mysql_get_host_info(FMYSQL1));
 if charset <> '' then begin
  mysql_set_character_set(fmysql1,pchar(charset));
 end;
end;

procedure tmysqlconnection.executeparams;
var
 int1: integer;
 bo1: boolean;
begin
 bo1:= transaction.active;
 try
  for int1:= 0 to params.count-1 do begin
   executedirect(params[int1]);
  end;
  if not bo1 then begin
   bo1:= true;
   transaction.commit;
  end;
 finally
  if not bo1 then begin
   transaction.rollback;
  end;
 end;
end;

procedure tmysqlconnection.DoInternalDisconnect;
begin
 inherited DoInternalDisconnect;
 closeconnection(fmysql1);
 ReleaseMysql;
end;

function tmysqlconnection.GetHandle: pointer;
begin
  Result:=FMySQL1;
end;

function tmysqlconnection.AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor;
begin
  Result:= tmysqlcursor.Create(aowner,aname);
  tmysqlcursor(result).fconn:= fmysql1; //can be overridden by transaction
end;

Procedure tmysqlconnection.DeAllocateCursorHandle(var cursor : TSQLCursor);

Var
  C : tmysqlcursor;

begin
 if cursor <> nil then begin
  C:= tmysqlcursor(cursor);
  freeresultbuffer(c);
  freebindingbuffers(c.fresultbuf);
  FreeAndNil(cursor);
 end;
end;

function tmysqlconnection.AllocateTransactionHandle: TSQLHandle;
begin
//  Result:=tmysqltransaction.Create;
 Result:= tmysqltrans.create;
end;

procedure tmysqlconnection.finalizetransaction(const atransaction: tsqlhandle);
begin
 with tmysqltrans(atransaction) do begin
  if (fconn <> fmysql1) then begin
   closeconnection(fconn);
  end;
  fconn:= nil;
 end;
end;

procedure tmysqlconnection.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);
var
 mstr1: msestring;
 str1: ansistring;
 fieldcount: integer;
begin
 With tmysqlcursor(cursor) do begin
  fconn:= tmysqltrans(atransaction.trans).fconn;
  if fconn = nil then begin
   fconn:= fmysql1; // dummy transaction
   tmysqltrans(atransaction.trans).fconn:= fmysql1;
  end;
  
  if not (myo_nopreparedstatements in foptions) and 
             (FStatementType in [stInsert,stUpdate,stDelete,stSelect]) then begin
   fprepstatement:= mysql_stmt_init(fconn);
   if fprepstatement = nil then begin
    checkerror(serrprepare,fconn);
   end;
   if assigned(aparams) then begin
    mstr1:= aparams.parsesql(asql,true,false,false,psinterbase,fparambinding);
   end
   else begin
    mstr1:= asql;
   end;
   mstr1:= trim(mstr1);
   if (mstr1 <> '') and (mstr1[length(mstr1)] = ';') then begin
    setlength(mstr1,length(mstr1)-1);
   end;
   str1:= mstr1;
   if mysql_stmt_prepare(fprepstatement,pchar(str1),length(str1)) <> 0 then begin
    try
     checkstmterror(serrprepare,fprepstatement);
    finally
     freeprepstatement;
    end;
   end;
   fresultmetadata:= mysql_stmt_result_metadata(fprepstatement);
   if fresultmetadata <> nil then begin
    fresultfieldcount:= mysql_num_fields(fresultmetadata);
    fresultbindings:= createbindings(fresultfieldcount);
   end
   else begin
    fresultfieldcount:= 0;
   end;
  end
  else begin
   FStatementm:= asql;
   if assigned(AParams) and (AParams.count > 0) then begin
     FStatementm:= AParams.ParseSQL(FStatementm,false,false,false,psSimulated,
                      paramBinding,ParamReplaceString);
   end;
  end;
  if FStatementType in datareturningtypes then begin
   FNeedData:=True;
  end;
  fprepared:= true;
 end;
end;

procedure tmysqlconnection.UnPrepareStatement(cursor: TSQLCursor);
begin
 with tmysqlcursor(cursor) do begin
  fstatementm:= '';
  fprepared:= false;
  fparambinding:= nil;
  freeprepstatement;
  freebindings(fresultbindings);
  if fresultmetadata <> nil then begin
   mysql_free_result(fresultmetadata);
   fresultmetadata:= nil;
  end;
 end;
end;

procedure tmysqlconnection.freeresultbuffer(const cursor: tmysqlcursor);
begin
 if cursor.fres <> nil then begin
  mysql_free_result(cursor.fres);
  cursor.fres:= nil;
 end;
 if cursor.fprepstatement <> nil then begin
  mysql_stmt_free_result(cursor.fprepstatement);
 end;
end;

procedure tmysqlconnection.FreeFldBuffers(cursor: TSQLCursor);

Var
  C : tmysqlcursor;

begin
  C:= tmysqlcursor(cursor);
  if c.FStatementType in datareturningtypes then
    c.FNeedData:=False;
  freeresultbuffer(c);
  c.mapdsrowtomsqlrow:= nil;
//  SetLength(c.MapDSRowToMSQLRow,0);
  c.fresultbindinginfo:= nil;
  freebindingbuffers(c.fresultbuf);
end;

procedure tmysqlconnection.doexecuteunprepared(const c: tmysqlcursor;
                   const atransaction: tsqltransaction; const asql: string);
begin
 with tmysqltrans(atransaction.trans) do begin
  if mysql_query(fconn,Pchar(asql)) <> 0 then begin
   checkerror(SErrExecuting,fconn);
  end
  else begin
   C.fRowsAffected := mysql_affected_rows(fconn);
   C.LastInsertID := mysql_insert_id(fconn);
   if C.FNeedData then begin
    if myo_storeresult in foptions then begin
     C.FRes:= mysql_store_result(fconn);
    end
    else begin
     C.FRes:= mysql_use_result(fconn); 
      //needs to call mysql_fetch_row() until all data has been fetched
    end;
    if myo_storeresult in foptions then begin
     c.frowsreturned:= mysql_num_rows(c.fres);
    end;
   end;
  end;
 end;
end;

procedure tmysqlconnection.internalExecute(const  cursor: TSQLCursor;
               const atransaction: tSQLtransaction; const AParams : TmseParams;
               const autf8: boolean);

var
 C: tmysqlcursor;
 i: integer;
 str1: ansistring;
 par1: tparam;
 int1: integer;
 inputparambindings: bindinginfoarty;
 paramdata: pointer;
 inputbindings: pointer;
 strings: stringarty;
 dataty1: tfieldtype;
 mstr1: msestring;
begin
 C:= tmysqlcursor(cursor);
 c.frowsaffected:= -1;
 c.frowsreturned:= -1;
 if not C.FNeedData then begin
  c.frowsreturned:= 0;
 end;
 freeresultbuffer(c);
 if c.fprepstatement <> nil then begin
  paramdata:= nil;
  inputbindings:= nil;
  if (aparams <> nil) and (aparams.count > 0) then begin
   inputbindings:= createbindings(length(c.fparambinding));
   setlength(inputparambindings,length(c.fparambinding));
   setlength(strings,length(c.fparambinding));
   for int1:= 0 to high(c.fparambinding) do begin
    if c.fparambinding[int1] < aparams.count then begin
     with aparams[c.fparambinding[int1]] do begin
      case datatype of //todo: date and time
       ftinteger,ftsmallint,ftword: begin
        setupinputbinding(int1,ftinteger,inputbindings,
                                 inputparambindings,nil,sizeof(integer));
       end;
       ftlargeint: begin
        setupinputbinding(int1,ftlargeint,inputbindings,
                                 inputparambindings,nil,sizeof(int64));
       end;
       ftfloat,ftcurrency,ftbcd: begin
        setupinputbinding(int1,ftfloat,inputbindings,
                                 inputparambindings,nil,sizeof(double));
       end;
       ftdate,ftdatetime,fttime: begin
        setupinputbinding(int1,ftdatetime,inputbindings,
                                 inputparambindings,nil,sizeof(mysql_time));
       end;
       ftstring,ftwidestring,ftblob,ftmemo,ftfixedchar,ftfixedwidechar: begin
        setupinputbinding(int1,ftstring,inputbindings,
                                 inputparambindings,nil,0);
           //dummy for NULL, setup later
       end;
       else begin
        freebindings(inputbindings);
        databaseerror('Paramtype '+
          getenumname(typeinfo(tfieldtype),ord(datatype))+' not supported.',self);
       end;
      end; 
     end;
    end;
   end;
   paramdata:= createbindingbuffers(inputbindings,inputparambindings);
   for int1:= 0 to high(c.fparambinding) do begin
    if c.fparambinding[int1] < aparams.count then begin
     with aparams[c.fparambinding[int1]] do begin
      if isnull then begin
       inputparambindings[int1].isnull:= true;
      end
      else begin
       case datatype of
        ftinteger,ftsmallint,ftword: begin
         pinteger(inputparambindings[int1].buffer)^:= asinteger;
        end;
        ftlargeint: begin
         pint64(inputparambindings[int1].buffer)^:= aslargeint;
        end;
        ftfloat,ftbcd,ftcurrency: begin
         pdouble(inputparambindings[int1].buffer)^:= asfloat;
        end;
        ftdate,ftdatetime,fttime: begin
         pmysql_time(inputparambindings[int1].buffer)^:= 
                 datetimetomysql_time(datatype,asdatetime);
        end;
        ftstring,ftwidestring,ftblob,ftmemo,ftfixedchar,ftfixedwidechar: begin
         strings[int1]:= aparams.asdbstring(c.fparambinding[int1]);
         dataty1:= datatype;
         if dataty1 <> ftblob then begin
          dataty1:= ftstring;
         end;
         setupinputbinding(int1,dataty1,inputbindings,
                                  inputparambindings,pointer(strings[int1]),
                                  length(strings[int1]));
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  try
   if mysql_stmt_bind_param(c.fprepstatement,inputbindings) <> 0 then begin
    checkstmterror(serrexecuting,c.fprepstatement);
   end;
   if mysql_stmt_execute(c.fprepstatement) <> 0 then begin
    checkstmterror(serrexecuting,c.fprepstatement);
   end;
   if myo_storeresult in foptions then begin
    if mysql_stmt_store_result(c.fprepstatement) <> 0 then begin
     checkstmterror(serrexecuting,c.fprepstatement);
    end;
    if myo_storeresult in foptions then begin
     c.frowsreturned:= mysql_stmt_num_rows(c.fprepstatement);
    end;
   end;
  finally
   freebindingbuffers(paramdata);
   freebindings(inputbindings);
  end;
  C.fRowsAffected := mysql_stmt_affected_rows(c.fprepstatement);
  C.LastInsertID := mysql_stmt_insert_id(c.fprepstatement);
 end
 else begin //not prepared
  if Assigned(AParams) and (aparams.count > 0) then begin
   mstr1:= aparams.expandvalues(c.fstatementm,
                          c.parambinding,c.paramreplacestring);
  end
  else begin
   mstr1:= c.fstatementm;
  end;
  if autf8 then begin
   str1:= stringtoutf8(mstr1);
  end
  else begin
   str1:= mstr1;
  end;
  doexecuteunprepared(c,atransaction,str1);
 end;
// if not C.FNeedData then begin
//  c.frowsreturned:= 0;
// end;
end;

procedure tmysqlconnection.internalexecuteunprepared(const cursor: tsqlcursor;
               const atransaction: tsqltransaction;
               const asql: string);
var
 C: tmysqlcursor;
begin
 C:= tmysqlcursor(cursor);
 c.frowsaffected:= -1;
 c.frowsreturned:= -1;
 c.fneeddata:= c.FStatementType in datareturningtypes;
 if not C.FNeedData then begin
  c.frowsreturned:= 0;
 end;
 freeresultbuffer(c);
 doexecuteunprepared(c,atransaction,asql);
end;

//function tmysqlconnection.MySQLDataType(AType: enum_field_types; ASize, ADecimals: Integer;
//   var NewType: TFieldType; var NewSize: Integer): Boolean;
function tmysqlconnection.MySQLDataType(const afield: mysql_field;
                const charsetinfo: my_charset_info;
                out NewType: TFieldType; out NewSize: Integer;
                out newprecision: integer): Boolean;
begin
  Result := True;
  NewSize:= 0;
  newprecision:= 0;
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
     newprecision:= length - 2;
     if (Decimals <= 4) or not (dbo_bcdtofloatif in controller.options) then begin
      if newprecision > maxprecision then begin
       newprecision:= maxprecision;
      end;
      newsize:= decimals;
      if newsize > 4 then begin
       newsize:= 4;
      end;
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
     if charsetinfo.mbmaxlen > 0 then begin
      newsize:= newsize div charsetinfo.mbmaxlen;
     end;
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

procedure tmysqlconnection.AddFieldDefs(const cursor: TSQLCursor;
                          const FieldDefs: TfieldDefs);
var
 C: tmysqlcursor;
 I,TF,FC: Integer;
 field: PMYSQL_FIELD;
 DFT: TFieldType;
 DFS: Integer;
 precision: integer;
 fd: tfielddef;
 str1: ansistring;
 res1: pmysql_res;
 charsetinfo: my_charset_info;
begin
 fielddefs.clear;
 C:= tmysqlcursor(cursor);
 mysql_get_character_set_info(c.fconn,@charsetinfo);
 if c.fprepstatement <> nil then begin
  fc:= c.fresultfieldcount;
  c.fresultbindinginfo:= nil; //initialize with zeros
  setlength(c.fresultbindinginfo,fc);
  res1:= mysql_stmt_result_metadata(c.fprepstatement);
 end
 else begin
  If (C.FRes=Nil) then begin
   checkerror(SErrNoQueryResult,c.fconn);
  end;
  res1:= c.fres;
  FC:= mysql_num_fields(res1);
 end;
 
 SetLength(c.MapDSRowToMSQLRow,FC);
 TF := 1;
 For I:= 0 to FC-1 do begin
  field := mysql_fetch_field_direct(res1, I);
  with field^ do begin
   if (flags and (pri_key_flag or auto_increment_flag) = 
             (pri_key_flag or auto_increment_flag)) then begin
    c.fprimarykeyfieldname:= name;
   end;
  end;
  if MySQLDataType(field^,charsetinfo,DFT,DFS,precision) then begin
   if not(dft in varsizefields) then begin
    dfs:= 0;
   end;
   c.MapDSRowToMSQLRow[TF-1] := I;
   if c.fprepstatement <> nil then begin
    setupresultbinding(i,dft,dfs,c.fresultbindings,c.fresultbindinginfo);
   end;
   if (dft = ftmemo) and (cursor.stringmemo) then begin
    dft:= ftstring;
    dfs:= 0;
   end;
   str1:= field^.name;

   fd:= TFieldDef.Create(nil,str1,DFT,DFS,False,TF);
   {$ifndef mse_FPC_2_2} 
   fd.displayname:= str1;
   {$endif}
   fd.collection:= fielddefs;
   if dft = ftbcd then begin
    fd.precision:= precision;
   end;   
   inc(TF);
  end
 end;
 if (c.fprepstatement <> nil) and (res1 <> nil) then begin
  freebindingbuffers(c.fresultbuf); //could be refresh operation
  c.fresultbuf:= createbindingbuffers(c.fresultbindings,c.fresultbindinginfo);
  mysql_free_result(res1);
  if mysql_stmt_bind_result(c.fprepstatement,c.fresultbindings) <> 0 then begin
   checkstmterror(sbindresult,c.fprepstatement);
  end;
 end;
end;

function tmysqlconnection.Fetch(cursor: TSQLCursor): boolean;

Var
  C : tmysqlcursor;
  int1: integer;
begin
 C:= tmysqlcursor(cursor);
 if c.fprepstatement <> nil then begin
  int1:= mysql_stmt_fetch(c.fprepstatement);
  result:= int1 <> mysql_no_data;
  if result and (int1 <> 0) and (int1 <> mysql_data_truncated) then begin
   checkstmterror(serrfetchingdata,c.fprepstatement);
  end;
 end
 else begin
  C.Row:=MySQL_Fetch_row(C.FRes);
  Result:=(C.Row<>Nil);
 end;
 if not result then begin
  freeresultbuffer(c);
 end;
end;

function tmysqlconnection.loadfield(const cursor: tsqlcursor;
      const datatype: tfieldtype; const fieldnum: integer; //null based
      const abuffer: pointer; var abufsize: integer;
                                const aisutf8: boolean): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize

var
  field: PMYSQL_FIELD;
  row : MYSQL_ROW;
  C : tmysqlcursor;
  fno: integer;
  alen: integer;
  int1: integer;
  str1: ansistring;
  index1: integer;

 procedure loadblob;
 begin
  with c.fresultbindinginfo[index1] do begin
   setlength(str1,length);
   if length > 0 then begin
    setbindingbuffer(c.fresultbindings,index1,pointer(str1),length);
    int1:= mysql_stmt_fetch_column(c.fprepstatement,
                            getbind(c.fresultbindings,index1),index1,0);
    setbindingbuffer(c.fresultbindings,index1,nil,0);
    if int1 <> 0 then begin
     checkstmterror(serrfetchingdata,c.fprepstatement);
    end;
   end;
  end;
 end;

begin
 result:= false;
 C:= tmysqlcursor(Cursor);
 fno:= fieldnum;
 if c.fprepstatement <> nil then begin
  index1:= c.MapDSRowToMSQLRow[fno];
  with c.fresultbindinginfo[index1] do begin
   result:= not isnull;
   if abuffer = nil then begin
    exit;     //check null state
   end;
   if result then begin
    case datatype of        //todo: blobs
     ftinteger,ftsmallint,ftword: begin
      pinteger(abuffer)^:= pinteger(buffer)^;
     end;
     ftlargeint: begin
      pint64(abuffer)^:= pint64(buffer)^;
     end;
     ftfloat: begin
      pdouble(abuffer)^:= pdouble(buffer)^;
     end;
     ftbcd: begin
      pcurrency(abuffer)^:= pdouble(buffer)^;
     end;
     ftdate,fttime,ftdatetime: begin
      pdatetime(abuffer)^:= mysql_timetodatetime(pmysql_time(buffer)^);
     end;
     ftstring: begin
      if length > abufsize then begin
       abufsize:= -length;
      end
      else begin
       if isblob then begin //stringmemo
        loadblob;
        move(pointer(str1)^,abuffer^,length);
        abufsize:= length;
       end
       else begin
        move(buffer^,abuffer^,length);
        abufsize:= length;
       end;
      end;
     end;
     ftblob,ftgraphic,ftmemo: begin
      loadblob;
      int1:= cursor.addblobdata(pchar(str1),system.length(str1));
      pinteger(abuffer)^:= int1;  //save id
     end;
     else begin
      result:= false; //not suported
     end;
    end;
   end;
  end;
 end
 else begin
  if C.Row=nil then
     begin
  //   Writeln('LoadFieldsFromBuffer: row=nil');
     checkerror(SErrFetchingData,c.fconn);
     end;
  Row:=C.Row;
  
  inc(Row,c.MapDSRowToMSQLRow[fno]);
//  inc(row,fno);
  if row^ <> nil then begin
   if abuffer = nil then begin
    result:= true;
    exit;
   end;
   field:= mysql_fetch_field_direct(C.FRES,c.MapDSRowToMSQLRow[fno]);
   if datatype = ftstring then begin
 //   alen:= strlen(row^);
    alen:= mysql_fetch_lengths(c.fres)[c.MapDSRowToMSQLRow[fno]];
    if abufsize < alen then begin 
     abufsize:= -alen;
     result:= true;
     exit;
    end
    else begin
     abufsize:= alen;
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
        DataType,Row^,aBuffer);
  end;
 end;
end;

function tmysqlconnection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
var
 int1: integer;
 row1: MYSQL_ROW;
begin
 result:= '';
 with tmysqlcursor(cursor) do begin
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
      Tmp := Tmp + DecimalSeparator
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
      Tmp := Tmp + DecimalSeparator
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

function tmysqlconnection.MySQLWriteData(const acursor: tsqlcursor; 
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

procedure tmysqlconnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;
                     const TableName : string);
var 
 qry: TSQLQuery;
 keynamef,filednamef,columnnamef,nonuniquef: tfield;
 str1: string;
begin
 if not assigned(Transaction) then begin
  DatabaseError(SErrConnTransactionnSet);
 end;
 qry:= tsqlquery.Create(nil);
 try
  qry.transaction := Transaction;
  qry.database := Self;
  with qry do begin
   parsesql:= false;
   sql.add('show index from ' +  TableName);
   open;
  end;
  keynamef:= qry.fieldbyname('Key_name');
  columnnamef:= qry.fieldbyname('Column_name');
  nonuniquef:= qry.fieldbyname('Non_unique');
  while not qry.eof do begin
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
     qry.next;
    until qry.eof or (name <> keynamef.asstring);
    setlength(str1,length(str1)-1); //remove last ';'
    fields:= str1;
   end;
  end;
 finally
  qry.free;
 end;
end;

function tmysqlconnection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
  Result:= trans;
end;

procedure tmysqlconnection.begintrans(const aconnection: pmysql;
                         const aparams: ansistring);
var
 str1: ansistring;
begin
 str1:= 'START TRANSACTION '+aparams;
 if mysql_real_query(aconnection,pointer(str1),length(str1)) <> 0 then begin
  checkerror(serrstarttransaction,aconnection);
 end;
end;

function tmysqlconnection.Commit(trans: TSQLHandle): boolean;
begin
 with tmysqltrans(trans) do begin
  if mysql_query(fconn,'COMMIT') <> 0 then begin
   checkerror(serrcommittransaction,fconn);
  end;
 end;
end;

function tmysqlconnection.RollBack(trans: TSQLHandle): boolean;
begin
 with tmysqltrans(trans) do begin
  if mysql_query(fconn,'ROLLBACK') <> 0 then begin
   checkerror(serrrollbacktransaction,fconn);
  end;
 end;
end;

procedure tmysqlconnection.internalCommitRetaining(trans: TSQLHandle);
begin
 with tmysqltrans(trans) do begin
  if mysql_query(fconn,'COMMIT AND CHAIN') <> 0 then begin
   checkerror(serrcommittransaction,fconn);
  end;
 end;
end;

procedure tmysqlconnection.internalRollBackRetaining(trans: TSQLHandle);
begin
 with tmysqltrans(trans) do begin
  if mysql_query(fconn,'ROLLBACK AND CHAIN') <> 0 then begin
   checkerror(serrrollbacktransaction,fconn);
  end;
 end;
end;

function tmysqlconnection.StartdbTransaction(const trans: TSQLHandle;
              const AParams: tstringlist): boolean;
begin
 with tmysqltrans(trans) do begin
  if fconn = nil then begin
   if not ftransactionconnectionused then begin
    fconn:= self.fmysql1;
    ftransactionconnectionused:= true;
   end
   else begin
    openconnection(fconn);
   end;  
  end;
  begintrans(fconn,aparams.text);
 end;
 result:= true;
end;

function tmysqlconnection.CreateBlobStream(const Field: TField;
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
   result:= acursor.getcachedblob(blobid);
  end;
 end;
end;

function tmysqlconnection.getblobdatasize: integer;
begin
 result:= sizeof(integer);
end;

procedure tmysqlconnection.writeblobdata(const atransaction: tsqltransaction;
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

procedure tmysqlconnection.setupblobdata(const afield: tfield;
               const acursor: tsqlcursor; const aparam: tparam);
begin
 acursor.blobfieldtoparam(afield,aparam,false);
end;

function tmysqlconnection.blobscached: boolean;
begin
 result:= true;
end;

function tmysqlconnection.getprimarykeyfield(const atablename: string;
                        const acursor: tsqlcursor): string;
begin
 result:= tmysqlcursor(acursor).fprimarykeyfieldname;
end;

function tmysqlconnection.getinsertid(const atransaction: tsqltransaction): int64;
begin
 result:= mysql_insert_id(tmysqltrans(atransaction.trans).fconn);
end;

procedure tmysqlconnection.updateprimarykeyfield(const afield: tfield;
                          const atransaction: tsqltransaction);
begin
 if afield.datatype in integerfields then begin
  afield.aslargeint:= getinsertid(atransaction);
 end;
 {
 with tmsebufdataset1(afield.dataset) do begin
  setcurvalue(afield,getinsertid);
 end;
 }
end;

function tmysqlconnection.identquotechar: ansistring;
begin
 result:= '`'; //needed for reserved words as fieldnames
end;

procedure tmysqlconnection.createdatabase(const asql: ansistring);
var
 bo1: boolean;
 po1: pmysql_res;
begin
 initializemysql([]);
 try  
  bo1:= fmysql1 = nil;
  if bo1 then begin
   ConnectMySQL(fmysql1,pchar(hostname),pchar(username),pchar(password));
  end;
  try
   if mysql_real_query(fmysql1,pointer(asql),length(asql)) <> 0 then begin
    checkerror(serrstarttransaction,fmysql1);
   end;
   po1:= mysql_store_result(fmysql1);
   if po1 <> nil then begin
    mysql_free_result(po1);
   end;
  finally
   if bo1 then begin
    closeconnection(fmysql1);
   end;
  end;
 finally  
  releasemysql;
 end;  
end;

{ emysqlerror }

constructor emysqlerror.create(const asender: tcustomsqlconnection; 
         const amessage: ansistring; const aerrormessage: msestring;
         const aerror: integer; const asqlcode: string);
begin
 fsqlcode:= asqlcode;
 inherited create(asender,amessage,aerrormessage,aerror);
end;

end.
