{ MSEgui Copyright (c) 2007-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqlite3conn;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msedb,msqldb,msestrings,mdb,sqlite3dyn,msetypes,msedatabase;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

{ 
      Type name        SQLite storage class  Field type    Data type
+--------------------+---------------------+-------------+-------------+
| INTEGER or INT     | INTEGER 4           | ftinteger   | integer     |
| LARGEINT           | INTEGER 8           | ftlargeint  | largeint    |
| BIGINT             | INTEGER 8           | ftlargeint  | largeint    |
| WORD               | INTEGER 2           | ftword      | word        |
| SMALLINT           | INTEGER 2           | ftsmallint  | smallint    |
| BOOLEAN            | INTEGER 2           | ftboolean   | wordbool    |
| FLOAT[...] or REAL | REAL                | ftfloat     | double      |
| or DOUBLE[...]     |                     |             |             |
| CURRENCY           | REAL                | ftcurrency  | double!     |
| DATETIME or        | REAL                | ftdatetime  | tdatetime   |
|  TIMESTAMP         |                     |             |             |
| DATE               | REAL                | ftdate      | tdatetime   |
| TIME               | REAL                | fttime      | tdatetime   |
| NUMERIC[...]       | INTEGER 8 (*10'000) | ftbcd       | currency    |
| VARCHAR[(n)]       | TEXT                | ftstring    | msestring   |
| TEXT               | TEXT                | ftmemo      | utf8 string |
| TEXT               | TEXT dso_stringmemo | ftstring    | msestring   |
| BLOB               | BLOB                | ftblob      | string      |
+--------------------+---------------------+-------------+-------------+
}
type
 esqlite3error = class(econnectionerror)
 end;

 tsqlitetrans = class(TSQLHandle)
  protected
   fparams: ansistring;
 end;
 
 sqliteoptionty = (slo_transactions,slo_designtransactions,
                   slo_negboolean, //boolean true = -1 instead of 1
                   slo_64bitprimarykey); 
                            //use ftlargint for "integer" primarykeyfield
 sqliteoptionsty = set of sqliteoptionty;
 
 tsqlite3connection = class(tcustomsqlconnection,idbcontroller,iblobconnection)
  private
   fhandle: psqlite3;
   foptions: sqliteoptionsty;
   fbusytimeoutms: integer;
   flasterror: integer;
   flasterrormessage: msestring;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean; reintroduce;
   procedure setconnected(const avalue: boolean); reintroduce;
   
          //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
             const tablename: string; const acursor: tsqlcursor;
             const adata: pointer; const alength: integer;
             const afield: tfield; const aparam: tparam;
             out newid: string);
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                                   const aparam: tparam);
   function blobscached: boolean;

   procedure setoptions(const avalue: sqliteoptionsty);
   procedure setbusytimeoutms(const avalue: integer);
   procedure checkbusytimeout;
  protected
   procedure loaded; override;
   function getfloatdate: boolean; override;
   function getint64currency: boolean; override;
   
   function getassqltext(const field : tfield) : msestring; override;
   function getassqltext(const param : tparam) : msestring; override;
   
   procedure resetstatement(const astatement: psqlite3_stmt);
   procedure checkerror(const aerror: integer);
   function cantransaction: boolean;
   
   procedure DoInternalConnect; override;
   procedure DoInternalDisconnect; override;
   function GetHandle : pointer; override;

   Function AllocateTransactionHandle : TSQLHandle; override;

   procedure internalExecute(const cursor: TSQLCursor;
               const atransaction: tsqltransaction; const AParams : TmseParams;
                                                const autf8: boolean); override;

   function GetTransactionHandle(trans : TSQLHandle): pointer; override;
   function Commit(trans : TSQLHandle) : boolean; override;
   function RollBack(trans : TSQLHandle) : boolean; override;
   function StartdbTransaction(const trans : TSQLHandle; 
                const aParams: tstringlist) : boolean; override;
   procedure internalCommitRetaining(trans : TSQLHandle); override;
   procedure internalRollBackRetaining(trans : TSQLHandle); override;
   function getblobdatasize: integer; override;
    
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode; 
                       const acursor: tsqlcursor): TStream; override;
   procedure execsql(const asql: string);
   procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
               const aTableName : string; const acursor: tsqlcursor); override;
   function getprimarykeyfield(const atablename: string;
                                   const acursor: tsqlcursor): string; override;
   procedure updateprimarykeyfield(const afield: tfield;
                                 const atransaction: tsqltransaction); override;
   procedure beginupdate; override;
   procedure endupdate; override;
  public
   constructor create(aowner: tcomponent); override;
   Function AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring) : TSQLCursor; override;
                       //aowner used as blob cache
   Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
   procedure preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams); override;
   function Fetch(cursor : TSQLCursor) : boolean; override;
   procedure AddFieldDefs(const cursor: TSQLCursor;
                   const FieldDefs : TfieldDefs); override;
   procedure UnPrepareStatement(cursor : TSQLCursor); override;
   procedure FreeFldBuffers(cursor : TSQLCursor); override;
   function loadfield(const cursor: tsqlcursor;
     const datatype: tfieldtype; const fieldnum: integer; //null based
     const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
   procedure updateutf8(var autf8: boolean); override;
   function getinsertid(const atransaction: tsqltransaction): int64; override;
   function fetchblob(const cursor: tsqlcursor;
                              const fieldnum: integer): ansistring; override;
                              //null based
   function stringquery(const asql: string): stringarty;
   function stringsquery(const asql: string): stringararty;
   property lasterror: integer read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected default false;
   property controller: tdbcontroller read fcontroller write setcontroller;
   property options: sqliteoptionsty read foptions write setoptions default [];
   property busytimeoutms: integer read fbusytimeoutms
                                        write setbusytimeoutms default 0;
   property Transaction;
   property transactionwrite;
   property afterconnect;
   property beforedisconnect;
 end;

implementation
uses
 msesqldb,msebufdataset,mseformatstr,
 {$ifdef FPC}dbconst{$else}dbconst_del,classes_del{$endif},
 sysutils,typinfo,dateutils,msesysintf,msedate,
 msefileutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

const
 maxprecision = 18;
type
 tmsebufdataset1 = class(tmsebufdataset);
 
 storagetypety = (st_none,st_integer,st_float,st_text,st_blob,st_null);
 
 tsqlite3cursor = class(tsqlcursor)
  private
   fstatement: psqlite3_stmt;
   ftail: pchar;
   fstate: integer;
   fparambinding: tparambinding;
   fopen: boolean;
   fconnection: tsqlite3connection;
   fprimarykeyfield: string;
  public
   constructor create(const aowner: icursorclient; const aname: ansistring; 
                       const aconnection: tsqlite3connection);
   procedure close; override;
 end;

{ tsqlite3cursor }

constructor tsqlite3cursor.create(const aowner: icursorclient;
              const aname: ansistring; const aconnection: tsqlite3connection);
begin
 fconnection:= aconnection;
 inherited create(aowner,aname);
end;

procedure tsqlite3cursor.close;
begin
 inherited;
 if fopen then begin
  fconnection.resetstatement(fstatement);
  fopen:= false;
 end;   
end;
  
{ tsqlite3connection }

constructor tsqlite3connection.create(aowner: tcomponent);
begin
 inherited;
 fconnoptions:= fconnoptions + [sco_supportparams,sco_emulateretaining];
end;

function tsqlite3connection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tsqlite3connection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

procedure tsqlite3connection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

procedure tsqlite3connection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
end;

function tsqlite3connection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tsqlite3connection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

function tsqlite3connection.CreateBlobStream(const Field: TField;
               const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
var
 blobid: integer;
// int1,int2: integer;
// str1: string;
// bo1: boolean;
begin
 if (mode = bmwrite) and (field.dataset is tmsesqlquery) then begin
  result:= tmsebufdataset(field.dataset).createblobbuffer(field);
 end
 else begin
  result:= nil;
  if mode = bmread then begin
   if field.getData(@blobId) then begin
    result:= acursor.getcachedblob(blobid);
   end;
  end;
 end;
end;

function tsqlite3connection.AllocateTransactionHandle: TSQLHandle;
begin
 result:= tsqlitetrans.create;
end;

function tsqlite3connection.AllocateCursorHandle(const aowner: icursorclient;
                           const aname: ansistring): TSQLCursor;
begin
 result:= tsqlite3cursor.create(aowner,aname,self);
end;

procedure tsqlite3connection.DeAllocateCursorHandle(var cursor: TSQLCursor);
begin
 freeandnil(cursor);
end;

procedure tsqlite3connection.preparestatement(const cursor: tsqlcursor; 
                  const atransaction : tsqltransaction;
                  const asql: msestring; const aparams : tmseparams);
var
 str1: string;
begin
 with tsqlite3cursor(cursor) do begin
  if assigned(aparams) and (aparams.count > 0) then begin
   str1:= todbstring(aparams.parsesql(asql,false,false,false,
                        psinterbase,fparambinding));
  end
  else begin
   str1:= todbstring(asql);
  end;
  checkerror(sqlite3_prepare(fhandle,pchar(str1),length(str1),@fstatement,
                                               @ftail));
  fprepared:= true;
 end;
end;

procedure tsqlite3connection.UnPrepareStatement(cursor: TSQLCursor);
//var
// int1: integer;
begin
 with tsqlite3cursor(cursor) do begin
//  int1:= sqlite3_finalize(fstatement);
  sqlite3_finalize(fstatement);
  fprepared:= false;
  fopen:= false;
 end;
end;

procedure freebindstring(astring: pointer); cdecl;
begin
 if astring <> pchar('') then begin
  string(astring):= '';
 end;
end;

procedure tsqlite3connection.AddFieldDefs(const cursor: TSQLCursor;
               const FieldDefs: TfieldDefs);
const
 fieldsizes: array[tfieldtype] of integer = ( //-1 invalid, -2 use fielddefs
  //ftUnknown,ftString,ftSmallint,     ftInteger,      ftWord,
    -1,       -2,     sizeof(smallint),sizeof(integer),sizeof(word),
  //ftBoolean,       ftFloat,       ftCurrency,    ftBCD,
    sizeof(wordbool),sizeof(double),sizeof(double),sizeof(currency),
  //ftDate,           ftTime,           ftDateTime,
    sizeof(tdatetime),sizeof(tdatetime),sizeof(tdatetime),  
  //ftBytes,ftVarBytes,ftAutoInc,ftBlob,    ftMemo,    ftGraphic,ftFmtMemo,
    -1,     -1,        -1,       blobidsize,blobidsize,-1,       -1,
  //ftParadoxOle,ftDBaseOle,ftTypedBinary,ftCursor,ftFixedChar,
   -1,           -1,        -1,           -1,      -1,
  //ftWideString,ftLargeint,      ftADT,ftArray,ftReference,
   -1,           sizeof(largeint),-1,   -1,     -1,
  //ftDataSet,ftOraBlob,ftOraClob,ftVariant,ftInterface,
  -1,         -1,       -1,       -1,       -1,
  //ftIDispatch,ftGuid,ftTimeStamp,ftFMTBcd,
  -1,           -1,    -1,         -1 
  //                   ftFixedWideChar,ftWideMemo
                         ,-1,             -1
  );

var
 int1,int2,int3: integer;
 str1,str2: string;
 ft1: tfieldtype;
 size1: integer;
 ar1: stringarty;
 defsbefore: fielddefarty;
 fd: tfielddef;
begin
 defsbefore:= getfielddefar(fielddefs);
 fielddefs.clear;
 with tsqlite3cursor(cursor) do begin
  for int1:= 0 to sqlite3_column_count(fstatement) - 1 do begin
   str1:= sqlite3_column_name(fstatement,int1);
   str2:= uppercase(sqlite3_column_decltype(fstatement,int1));
   ft1:= ftunknown;
   size1:= 0;
   if pos('INT',str2) = 1 then begin //or 'INTEGER'
    ft1:= ftinteger;
    if (slo_64bitprimarykey in foptions) and (str1 = fprimarykeyfield) then begin
     ft1:= ftlargeint;
    end;
   end
   else begin
    if (str2 = 'LARGEINT') or (str2 = 'BIGINT') then begin
     ft1:= ftlargeint;
    end
    else begin
     if str2 = 'WORD' then begin
      ft1:= ftword;
     end
     else begin
      if str2 = 'SMALLINT' then begin
       ft1:= ftsmallint;
      end
      else begin
       if str2 = 'BOOLEAN' then begin
        ft1:= ftboolean;
       end
       else begin
        if (str2 = 'REAL') or (pos('FLOAT',str2) = 1) or 
                                       (pos('DOUBLE',str2) = 1) then begin     
         ft1:= ftfloat;
        end
        else begin
         if (str2 = 'DATETIME') or (str2 = 'TIMESTAMP') then begin
          ft1:= ftdatetime;
         end
         else begin
          if str2 = 'DATE' then begin
           ft1:= ftdate;
          end
          else begin
           if str2 = 'TIME' then begin
            ft1:= fttime;
           end          
           else begin
            if pos('NUMERIC',str2) = 1 then begin      
             ft1:= ftbcd;
            end
            else begin
             if str2 = 'CURRENCY' then begin
              ft1:= ftcurrency;
             end
             else begin
              if pos('VARCHAR',str2) = 1 then begin
               ft1:= ftstring;
               ar1:= splitstring(str2,'(');
               if high(ar1) >= 1 then begin
                ar1:= splitstring(ar1[1],')');
                if high(ar1) >= 0 then begin
                 if not trystrtoint(ar1[0],size1) then begin
                  size1:= 0;
                 end;
                end;
               end;
              end
              else begin
               if str2 = 'TEXT' then begin
                if stringmemo then begin
                 ft1:= ftstring;
                end
                else begin
                 ft1:= ftmemo;
                end;
               end
               else begin
                if str2 = 'BLOB' then begin
                 ft1:= ftblob;
                end;
               end;
              end;
             end;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
   if (ft1 = ftunknown) then begin
    int3:= -1;
    for int2:= 0 to high(defsbefore) do begin
     if defsbefore[int2].name = str1 then begin
      int3:= int2;
      break;
     end;
    end;
    if int3 >= 0 then begin
     with defsbefore[int3] do begin
      ft1:= datatype;
      if ft1 = ftstring then begin
       size1:= size;
      end;
     end;
    end;
    if ft1 = ftunknown then begin
     size1:= 0;
     case storagetypety(sqlite3_column_type(fstatement,int1)) of
      st_integer: ft1:= ftinteger;
      st_float: ft1:= ftfloat;
      st_text: ft1:= ftstring;
      st_blob: ft1:= ftblob;
     end;
    end;
   end;
   if ft1 <> ftstring then begin
    size1:= fieldsizes[ft1];
   end;
   if ft1 = ftbcd then begin
    size1:= 4;  //scale fix
   end;
   if size1 < 0 then begin
    ft1:= ftunknown;
    size1:= 0;
   end;
   if not(ft1 in varsizefields) then begin
    size1:= 0;
   end;
   fd:= tfielddef.create(nil,str1,ft1,size1,false,int1+1);
   fd.collection:= fielddefs;
   if ft1 = ftbcd then begin
    fd.precision:= maxprecision;       //precision fix
   end;
  end;
 end;
end;

procedure tsqlite3connection.resetstatement(const astatement: psqlite3_stmt);
begin
 checkerror(sqlite3_reset(astatement));
 checkerror(sqlite3_clear_bindings(astatement));
end;

procedure tsqlite3connection.internalExecute(const cursor: TSQLCursor;
               const atransaction: tsqltransaction; const AParams: TmseParams;
               const autf8: boolean);
var
 int1: integer;
 str1: string;
 cu1: currency;
 do1: double;
{$ifndef CPUARM}
 wo1: word;
{$endif}
 po1: pchar;
 i1: int32;
begin
 with tsqlite3cursor(cursor) do begin
  frowsaffected:= -1;
  frowsreturned:= -1;
  if aparams <> nil then begin
   for int1:= 0 to high(fparambinding) do begin
    with aparams[fparambinding[int1]] do begin
     if isnull then begin
      checkerror(sqlite3_bind_null(fstatement,int1+1));
     end
     else begin
      case datatype of
       ftinteger,ftsmallint: begin
        checkerror(sqlite3_bind_int(fstatement,int1+1,asinteger));
       end;
       ftboolean: begin
        i1:= asinteger;
        if (i1 <> 0) and not (slo_negboolean in foptions) then begin
         i1:= 1;
        end;
        checkerror(sqlite3_bind_int(fstatement,int1+1,i1));
       end;
       ftword: begin
        checkerror(sqlite3_bind_int(fstatement,int1+1,asword));
       end;
       ftlargeint: begin
        checkerror(sqlite3_bind_int64(fstatement,int1+1,aslargeint));
       end;
       ftbcd: begin
        cu1:= ascurrency;
        checkerror(sqlite3_bind_int64(fstatement,int1+1,pint64(@cu1)^));
       end;
       ftfloat,ftcurrency,ftdatetime,ftdate,fttime: begin
        do1:= asfloat;
        checkerror(sqlite3_bind_double(fstatement,int1+1,do1));
       end;
       ftstring,ftwidestring,ftmemo,ftfixedchar,ftfixedwidechar: begin
        str1:= aparams.asdbstring(fparambinding[int1]);
        if str1 = '' then begin
         po1:= pchar('');
        end
        else begin
         stringaddref(str1);
         po1:= pchar(str1);
        end;
        checkerror(sqlite3_bind_text(fstatement,int1+1,po1,
                    length(str1),@freebindstring));
       end;
       ftblob: begin
        str1:= asstring;
        stringaddref(str1);
        checkerror(sqlite3_bind_blob(fstatement,int1+1,pointer(str1),
                    length(str1),@freebindstring));
       end;
       else begin
        databaseerror('Parameter type '+getenumname(typeinfo(tfieldtype),
                                       ord(datatype))+' not supported.',self);
       end;
      end;
     end;
    end;
   end;
  end;
 {$ifndef CPUARM}
  wo1:= get8087cw;
  set8087cw(wo1 or $1f);             //mask exceptions, Sqlite3 has overflow
 {$endif}
  fstate:= sqlite3_step(fstatement);
 {$ifndef CPUARM}
  set8087cw(wo1);                    //restore
 {$endif}
  if fstate = sqlite_row then begin
   fstate:= sqliteerrormax; //first row
   fopen:= true;
  end
  else begin   
   resetstatement(fstatement);
  end;
  frowsaffected:= sqlite3_changes(fhandle);
 end;
end;

function tsqlite3connection.loadfield(const cursor: tsqlcursor;
               const datatype: tfieldtype; const fieldnum: integer; //null based
               const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean;
var
 st1: storagetypety;
 fnum: integer;
// i: integer;
// i64: int64;
 int1,int2: integer;
 str1: string;
 ar1,ar2: stringarty;
 year,month,day,hour,minute,second: integer;
begin
 with tsqlite3cursor(cursor) do begin
  fnum:= fieldnum;
  st1:= storagetypety(sqlite3_column_type(fstatement,fnum));
  result:= st1 <> st_null;
  if result then begin
   if buffer = nil then begin
    exit;
   end;
   case datatype of
    ftinteger: begin
     integer(buffer^):= sqlite3_column_int(fstatement,fnum);
    end;
    ftsmallint: begin
     smallint(buffer^):= sqlite3_column_int(fstatement,fnum);
    end;
    ftword: begin
     word(buffer^):= sqlite3_column_int(fstatement,fnum);
    end;
    ftboolean: begin
     wordbool(buffer^):= sqlite3_column_int(fstatement,fnum) <> 0;
    end; 
    ftlargeint,ftbcd: begin
     largeint(buffer^):= sqlite3_column_int64(fstatement,fnum);
    end;
    ftfloat,ftcurrency: begin
     double(buffer^):= sqlite3_column_double(fstatement,fnum);
    end;
    ftdatetime,ftdate,fttime: begin
     if st1 = st_text then begin
      result:= false;
      setlength(str1,sqlite3_column_bytes(fstatement,fnum));
      move(sqlite3_column_text(fstatement,fnum)^,str1[1],length(str1));
      try
       ar1:= splitstring(str1,' ');
       if high(ar1) = 1 then begin
        ar2:= splitstring(ar1[0],'-');
        if high(ar2) = 2 then begin
         year:= strtoint(ar2[0]);
         month:= strtoint(ar2[1]);
         day:= strtoint(ar2[2]);
         ar2:= splitstring(ar1[1],':');
         if high(ar2) = 2 then begin
          hour:= strtoint(ar2[0]);
          minute:= strtoint(ar2[1]);
          second:= strtoint(ar2[2]);
          tdatetime(buffer^):= encodedatetime(year,month,day,
                                              hour,minute,second,0);
          result:= true;
         end;
        end;
       end
       else begin
        if high(ar1) = 0 then begin
         ar2:= splitstring(ar1[0],'-');
         if high(ar2) = 2 then begin
          year:= strtoint(ar2[0]);
          month:= strtoint(ar2[1]);
          day:= strtoint(ar2[2]);
          tdatetime(buffer^):= encodedate(year,month,day); 
          result:= true;
         end
         else begin
          ar2:= splitstring(ar1[0],':');
          if high(ar2) = 2 then begin
           hour:= strtoint(ar2[0]);
           minute:= strtoint(ar2[1]);
           second:= strtoint(ar2[2]);
           tdatetime(buffer^):= encodetime(hour,minute,second,0); 
           result:= true;
          end;
         end;
        end;
       end;
      except
      end;
     end
     else begin
      tdatetime(buffer^):= sqlite3_column_double(fstatement,fnum);
     end;
    end; 
    ftstring,ftfixedchar: begin
     int1:= sqlite3_column_bytes(fstatement,fnum);
     if int1 > bufsize then begin
      bufsize:= - int1;
     end
     else begin
      bufsize:= int1;
      if int1 > 0 then begin
       move(sqlite3_column_text(fstatement,fnum)^,buffer^,int1);
      end;
     end;
    end;
    ftmemo: begin
     int2:= sqlite3_column_bytes(fstatement,fnum);
     int1:= addblobdata(sqlite3_column_text(fstatement,fnum),int2);
     move(int1,buffer^,sizeof(int1));
      //save id
    end;
    ftblob: begin
     int2:= sqlite3_column_bytes(fstatement,fnum);
     int1:= addblobdata(sqlite3_column_blob(fstatement,fnum),int2);
     move(int1,buffer^,sizeof(int1));
      //save id
    end;
    else begin
     result:= false; // unknown
    end; 
   end;
  end;
 end;
end;

function tsqlite3connection.fetchblob(const cursor: tsqlcursor;
               const fieldnum: integer): ansistring;
begin
 result:= '';
 with tsqlite3cursor(cursor) do begin
  if storagetypety(sqlite3_column_type(fstatement,fieldnum)) <> st_null then begin
   setlength(result,sqlite3_column_bytes(fstatement,fieldnum));
   if result <> '' then begin
    move(sqlite3_column_blob(fstatement,fieldnum)^,result[1],length(result));
   end;
  end;
 end;
end;

function tsqlite3connection.Fetch(cursor: TSQLCursor): boolean;
begin
 with tsqlite3cursor(cursor) do begin
  if fstate = sqliteerrormax then begin
   fstate:= sqlite_row; //first row;
  end
  else begin
   if fstate = sqlite_row then begin
    fstate:= sqlite3_step(fstatement);
    if fstate <= sqliteerrormax then begin
     checkerror(sqlite3_reset(fstatement));  //right error returned??
    end;
   end;
  end;
  result:= fstate = sqlite_row;
 end;
end;

procedure tsqlite3connection.FreeFldBuffers(cursor: TSQLCursor);
begin
 //dummy
end;

function tsqlite3connection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
 result:= nil;
end;

function tsqlite3connection.Commit(trans: TSQLHandle): boolean;
begin
 if cantransaction then begin
  execsql('COMMIT');
 end;
 result:= true;
end;

function tsqlite3connection.RollBack(trans: TSQLHandle): boolean;
begin
 if cantransaction then begin
  execsql('ROLLBACK');
 end;
 result:= true;
end;

function tsqlite3connection.StartdbTransaction(const trans: TSQLHandle;
               const aParams: tstringlist): boolean;
begin
 if cantransaction then begin
  with tsqlitetrans(trans) do begin
   fparams:= aparams.text;
   execsql('BEGIN '+fparams);
  end;
 end;
 result:= true;
end;

procedure tsqlite3connection.internalCommitRetaining(trans: TSQLHandle);
begin
 commit(trans);  
 if cantransaction then begin
  with tsqlitetrans(trans) do begin
   execsql('BEGIN '+fparams);
  end;
 end;
end;

procedure tsqlite3connection.internalRollBackRetaining(trans: TSQLHandle);
begin
 rollback(trans);
 if cantransaction then begin
  with tsqlitetrans(trans) do begin
   execsql('BEGIN '+fparams);
  end;
 end;
end;

function tsqlite3connection.getblobdatasize: integer;
begin
 result:= blobidsize;
end;

procedure tsqlite3connection.DoInternalConnect;
var
 str1: string;
begin
// if (inherited databasename = '') then begin
//  DatabaseError(SErrNoDatabaseName,self);
// end;
 initializesqlite3([]);
 str1:= stringtoutf8ansi(msestring(inherited databasename));
 checkerror(sqlite3_open(pchar(str1),@fhandle));
 checkbusytimeout;
end;

procedure tsqlite3connection.DoInternalDisconnect;
//var
// int1: integer;
begin
 if fhandle <> nil then begin
//  int1:= sqlite3_close(fhandle);
  sqlite3_close(fhandle);
//  if int1 = sqlite_busy then begin
//   checkerror(int1);
//  end;
  fhandle:= nil;
  releasesqlite3;
 end; 
end;

function tsqlite3connection.GetHandle: pointer;
begin
 result:= fhandle;
end;

procedure tsqlite3connection.checkerror(const aerror: integer);
begin
 if aerror <> sqlite_ok then begin
  flasterror:= aerror;
  flasterrormessage:= utf8tostringansi(sqlite3_errmsg(fhandle));
  raise esqlite3error.create(self,ansistring(flasterrormessage),
                                           flasterrormessage,flasterror);
 end;
end;

procedure tsqlite3connection.execsql(const asql: string);
var
 err: pchar;
 str1: string;
 int1: integer;
begin
 str1:= '';
 err:= nil;
{$ifdef FPC} {$checkpointer off} {$endif};
 int1:= sqlite3_exec(fhandle,pchar(asql),nil,nil^,@err);
{$ifdef FPC} {$checkpointer default} {$endif};
 if err <> nil then begin
  str1:= err;
  sqlite3_free(err);
 end;
 if int1 <> sqlite_ok then begin
  databaseerror(str1);
 end;
end;

procedure tsqlite3connection.updateutf8(var autf8: boolean);
begin
 autf8:= true;
end;

procedure tsqlite3connection.writeblobdata(const atransaction: tsqltransaction;
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

procedure tsqlite3connection.setupblobdata(const afield: tfield;
               const acursor: tsqlcursor; const aparam: tparam);
begin
 acursor.blobfieldtoparam(afield,aparam,false);
end;

function tsqlite3connection.blobscached: boolean;
begin
 result:= true;
end;

function execcallback(var adata; ncols: longint; //adata = stringarty
                avalues: PPchar; anames: PPchar):longint; cdecl;
var
 int1: integer;
begin
 setlength(stringarty(adata),ncols);
 for int1:= 0 to ncols - 1 do begin
  stringarty(adata)[int1]:= pcharpoaty(avalues)^[int1];
 end;
 result:= 0;
end;

function tsqlite3connection.stringquery(const asql: string): stringarty;
begin
 result:= nil;
 checkerror(sqlite3_exec(fhandle,pchar(asql),@execcallback,result,nil));
end;

function execscallback(var adata; ncols: longint; //adata = stringarty
                avalues: PPchar; anames: PPchar):longint; cdecl;
var
 int1: integer;
 po1: pstringarty;
 po2: pstring;
begin
   //@ operator and some indexing do not work with -O2 and FPC 2.2
 setlength(stringararty(adata),high(stringararty(adata))+2);
 po1:= pointer(pchar(pointer(adata)) + high(stringararty(adata))*sizeof(pointer));
 setlength(po1^,ncols);
 po2:= pointer(po1^);
 for int1:= 0 to ncols - 1 do begin
  po2^:= pcharpoaty(avalues)^[int1];
  inc(po2);
 end;
 result:= 0;
end;

function tsqlite3connection.stringsquery(const asql: string): stringararty;
begin
 result:= nil;
// checkerror(sqlite3_exec(fhandle,pchar(asql),@execscallback,@result,nil));
 checkerror(sqlite3_exec(fhandle,pchar(asql),@execscallback,result,nil));
end;

function tsqlite3connection.getprimarykeyfield(const atablename: string;
                                const acursor: tsqlcursor): string;
var
 int1{,int2}: integer;
 ar1: stringararty;
// str1: string;
begin
 result:= '';
 if atablename <> '' then begin
  try
   ar1:= stringsquery('PRAGMA table_info('+atablename+');');
   for int1:= 0 to high(ar1) do begin
    if (high(ar1[int1]) >= 5) and (ar1[int1][5] <> '0') then begin
     result:= ar1[int1][1];
     break;
    end;
   end;
  except
  end;
 end;
 tsqlite3cursor(acursor).fprimarykeyfield:= result;
end;

procedure tsqlite3connection.UpdateIndexDefs(var IndexDefs: TIndexDefs;
                         const aTableName: string; const acursor: tsqlcursor);
var
 str1: string;
begin
 try
  str1:= getprimarykeyfield(atablename,acursor);
 except
  str1:= '';
 end;
 if str1 <> '' then begin
  indexdefs.add('$PRIMARY_KEY$',str1,[ixPrimary,ixUnique]);
 end;
end;
{
procedure tsqlite3connection.UpdateIndexDefs(var IndexDefs: TIndexDefs;
                              const TableName: string);
var
 int1,int2: integer;
 ar1: stringararty;
 str1: string;
begin
 ar1:= stringsquery('PRAGMA table_info('+tablename+');');
 for int1:= 0 to high(ar1) do begin
  if (high(ar1[int1]) >= 5) and (ar1[int1][5] <> '0') then begin
   indexdefs.add('$PRIMARY_KEY$',ar1[int1][1],[ixPrimary,ixUnique]);
   break;
  end;
 end;
end;
}

function tsqlite3connection.getinsertid(const atransaction: tsqltransaction): int64;
begin
 result:= sqlite3_last_insert_rowid(fhandle);
end;

procedure tsqlite3connection.updateprimarykeyfield(const afield: tfield;
                               const atransaction: tsqltransaction);
begin
 if afield.datatype in integerfields then begin
  afield.aslargeint:= getinsertid(nil);
 end;
 {
 with tmsebufdataset1(afield.dataset) do begin
  setcurvalue(afield,getinsertid);
 end;
 }
end;

function tsqlite3connection.cantransaction: boolean;
begin
 result:= (slo_transactions in foptions) and 
    ((slo_designtransactions in foptions) or not (csdesigning in componentstate)); 
end;

procedure tsqlite3connection.setoptions(const avalue: sqliteoptionsty);
begin
 if avalue <> foptions then begin
  checkdisconnected;
  foptions:= avalue;
 end;
end;

procedure tsqlite3connection.setbusytimeoutms(const avalue: integer);
begin
 if avalue <> fbusytimeoutms then begin
  fbusytimeoutms:= avalue;
  checkbusytimeout;
 end;
end;

procedure tsqlite3connection.checkbusytimeout;
begin
 if fhandle <> nil then begin
  sqlite3_busy_timeout(fhandle,fbusytimeoutms);
 end;
end;

procedure tsqlite3connection.beginupdate;
begin
 if not (slo_transactions in foptions) then begin
  execsql('BEGIN');
 end;
end;

procedure tsqlite3connection.endupdate;
begin
 if not (slo_transactions in foptions) then begin
  execsql('COMMIT');
 end;
end;

function tsqlite3connection.getassqltext(const field: tfield): msestring;
begin
 if field.isnull then begin
  result:= inherited getassqltext(field);
 end
 else begin
  case field.datatype of
   ftdate,ftdatetime,fttime: begin
    result:= encodesqlfloat(field.asdatetime);
   end;
   ftbcd: begin
   {$ifdef FPC}
    result:= inttostrmse(int64(field.ascurrency));
   {$else}
    result:= inttostrmse(int64(ar8ty(field.ascurrency)));
   {$endif}
   end;
   else begin
    result:= inherited getassqltext(field);
   end;
  end;
 end;
end;

function tsqlite3connection.getassqltext(const param: tparam): msestring;
begin
 if param.isnull then begin
  result:= inherited getassqltext(param);
 end
 else begin
  case param.datatype of
   ftdate,ftdatetime,fttime: begin
    result:= encodesqlfloat(param.asdatetime);
   end;
   ftbcd: begin
   {$ifdef FPC}
    result:= inttostrmse(int64(param.ascurrency));
   {$else}
    result:= inttostrmse(int64(ar8ty(param.ascurrency)));
   {$endif}
   end;
   else begin
    result:= inherited getassqltext(param);
   end;
  end;
 end;
end;

function tsqlite3connection.getfloatdate: boolean;
begin
 result:= true;
end;

function tsqlite3connection.getint64currency: boolean;
begin
 result:= true;
end;

end.
