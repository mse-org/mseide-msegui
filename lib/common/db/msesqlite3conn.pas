{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqlite3conn;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msqldb,msedb,msestrings,db,sqlite3dyn,msetypes;
{ 
      Type name        SQLite storage class  Field type    Data type
+--------------------+---------------------+-------------+-------------+
| INTEGER or INT     | INTEGER 4           | ftinteger   | integer     |
| LARGEINT           | INTEGER 8           | ftlargeint  | largeint    |
| WORD               | INTEGER 2           | ftword      | word        |
| SMALLINT           | INTEGER 2           | ftsmallint  | smallint    |
| BOOLEAN            | INTEGER 2           | ftboolean   | wordbool    |
| FLOAT[...] or REAL | REAL                | ftfloat     | double      |
| or DOUBLE[...]     |                     |             |             |
| CURRENCY           | REAL                | ftcurrency  | double!     |
| DATETIME           | REAL                | ftdatetime  | tdatetime   |
| DATE               | REAL                | ftdate      | tdatetime   |
| TIME               | REAL                | fttime      | tdatetime   |
| NUMERIC[...]       | INTEGER 8           | ftbcd       | currency    |
| VARCHAR[(n)]       | TEXT                | ftstring    | msestring   |
| TEXT               | TEXT                | ftmemo      | utf8 string |
| BLOB               | BLOB                | ftblob      | string      |
+--------------------+---------------------+-------------+-------------+
}
type
 sqliteoptionty = (slo_transactions,slo_designtransactions);
 sqliteoptionsty = set of sqliteoptionty;
 
 tsqlite3connection = class(tcustomsqlconnection,idbcontroller,iblobconnection)
  private
   fcontroller: tdbcontroller;
   fhandle: psqlite3;
   foptions: sqliteoptionsty;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure loaded; override;
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   
   //idbcontroller
   procedure setinheritedconnected(const avalue: boolean);
   function readsequence(const sequencename: string): string;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string;
   procedure updateutf8(var autf8: boolean);                    

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
  protected
   function stringquery(const asql: string): stringarty;
   function stringsquery(const asql: string): stringararty;
   procedure checkerror(const aerror: integer);
   function cantransaction: boolean;
   
   procedure DoInternalConnect; override;
   procedure DoInternalDisconnect; override;
   function GetHandle : pointer; override;

   Function AllocateCursorHandle(const aowner: tsqlquery) : TSQLCursor; override;
                       //aowner used as blob cache
   Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
   Function AllocateTransactionHandle : TSQLHandle; override;

   procedure PrepareStatement(cursor: TSQLCursor; ATransaction : TSQLTransaction; 
                         buf: string; AParams : TParams); override;
   procedure Execute(const cursor: TSQLCursor; const atransaction: tsqltransaction;
                                const AParams : TParams); override;
   function Fetch(cursor : TSQLCursor) : boolean; override;
   procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); override;
   procedure UnPrepareStatement(cursor : TSQLCursor); override;

   procedure FreeFldBuffers(cursor : TSQLCursor); override;
   function loadfield(const cursor: tsqlcursor; const afield: tfield;
     const buffer: pointer; var bufsize: integer): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
   function GetTransactionHandle(trans : TSQLHandle): pointer; override;
   function Commit(trans : TSQLHandle) : boolean; override;
   function RollBack(trans : TSQLHandle) : boolean; override;
   function StartdbTransaction(trans : TSQLHandle; 
                aParams : string) : boolean; override;
   procedure internalCommitRetaining(trans : TSQLHandle); override;
   procedure internalRollBackRetaining(trans : TSQLHandle); override;
   function getblobdatasize: integer; override;
    
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode; 
                       const acursor: tsqlcursor): TStream; override;
   procedure execsql(const asql: string);
   procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                               const TableName : string); override;
   function getprimarykeyfield(const atablename: string;
                                     const acursor: tsqlcursor): string; override;
   procedure updateprimarykeyfield(const afield: tfield); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function getinsertid: int64; override;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
   property controller: tdbcontroller read fcontroller write setcontroller;
   property options: sqliteoptionsty read foptions write setoptions;
//    property Password;
   property Transaction;
   property afterconnect;
   property beforedisconnect;
//    property UserName;
//    property CharSet;
//    property HostName;
//    Property Role;
//    property KeepConnection;
//    property LoginPrompt;
//    property Params;
//    property OnLogin;
 end;
 
implementation
uses
 msesqldb,msebufdataset,dbconst,sysutils,typinfo,dateutils,msesysintf,msedate;
type
 tmsebufdataset1 = class(tmsebufdataset);
 
 storagetypety = (st_none,st_integer,st_float,st_text,st_blob,st_null);
 
 tsqlite3cursor = class(tsqlcursor)
  private
   fstatement: psqlite3_stmt;
   ftail: pchar;
   fstate: integer;
   fparambinding: integerarty;
   fopen: boolean;
 end;
  
{ tsqlite3connection }

constructor tsqlite3connection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
 fconnoptions:= fconnoptions + [sco_supportparams,sco_emulateretaining];
end;

destructor tsqlite3connection.destroy;
begin
 fcontroller.free;
 inherited;
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

function tsqlite3connection.readsequence(const sequencename: string): string;
begin
 //todo
end;

function tsqlite3connection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 //todo
end;

function tsqlite3connection.CreateBlobStream(const Field: TField;
               const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
var
 blobid: integer;
 int1,int2: integer;
 str1: string;
 bo1: boolean;
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
 result:= tsqlhandle.create;
end;

function tsqlite3connection.AllocateCursorHandle(const aowner: tsqlquery): TSQLCursor;
begin
 result:= tsqlite3cursor.create(aowner);
end;

procedure tsqlite3connection.DeAllocateCursorHandle(var cursor: TSQLCursor);
begin
 freeandnil(cursor);
end;

procedure tsqlite3connection.PrepareStatement(cursor: TSQLCursor;
               ATransaction: TSQLTransaction; buf: string; AParams: TParams);
begin
 with tsqlite3cursor(cursor) do begin
  if assigned(aparams) and (aparams.count > 0) then begin
  {$ifdef mse_FPC_2_2}
    buf := aparams.parsesql(buf,false,false,false,psinterbase,fparambinding);
  {$else}
    buf := aparams.parsesql(buf,false,psinterbase,fparambinding);
  {$endif}
  end;
  checkerror(sqlite3_prepare(fhandle,pchar(buf),length(buf),@fstatement,
                                               @ftail));
  fprepared:= true;
 end;
end;

procedure tsqlite3connection.UnPrepareStatement(cursor: TSQLCursor);
var
 int1: integer;
begin
 with tsqlite3cursor(cursor) do begin
  int1:= sqlite3_finalize(fstatement);
  fprepared:= false;
  fopen:= false;
 end;
end;

procedure freebindstring(astring: pointer); cdecl;
begin
 string(astring):= '';
end;

procedure tsqlite3connection.AddFieldDefs(cursor: TSQLCursor;
               FieldDefs: TfieldDefs);
var
 int1: integer;
 str1,str2: string;
 ft1: tfieldtype;
 size1: word;
 ar1: stringarty;
begin
 with tsqlite3cursor(cursor) do begin
  for int1:= 0 to sqlite3_column_count(fstatement) - 1 do begin
   str1:= sqlite3_column_name(fstatement,int1);
   str2:= uppercase(sqlite3_column_decltype(fstatement,int1));
   ft1:= ftunknown;
   size1:= 0;
   if pos('INT',str2) = 1 then begin //or 'INTEGER'
    ft1:= ftinteger;
    size1:= sizeof(integer);
   end
   else begin
    if str2 = 'LARGEINT' then begin
     ft1:= ftlargeint;
     size1:= sizeof(largeint);
    end
    else begin
     if str2 = 'WORD' then begin
      ft1:= ftword;
      size1:= sizeof(word);
     end
     else begin
      if str2 = 'SMALLINT' then begin
       ft1:= ftsmallint;
       size1:= sizeof(smallint);
      end
      else begin
       if str2 = 'BOOLEAN' then begin
        ft1:= ftboolean;
        size1:= sizeof(wordbool);
       end
       else begin
        if (str2 = 'REAL') or (pos('FLOAT',str2) = 1) or 
                                       (pos('DOUBLE',str2) = 1) then begin     
         ft1:= ftfloat;
         size1:= sizeof(double);
        end
        else begin
         if str2 = 'DATETIME' then begin
          ft1:= ftdatetime;
          size1:= sizeof(tdatetime);
         end
         else begin
          if str2 = 'DATE' then begin
           ft1:= ftdate;
           size1:= sizeof(tdatetime);
          end
          else begin
           if str2 = 'TIME' then begin
            ft1:= fttime;
            size1:= sizeof(tdatetime);
           end          
           else begin
            if pos('NUMERIC',str2) = 1 then begin      
             ft1:= ftbcd;
             size1:= sizeof(currency);
            end
            else begin
             if str2 = 'CURRENCY' then begin
              ft1:= ftcurrency;
              size1:= sizeof(double);
             end
             else begin
              if pos('VARCHAR',str2) = 1 then begin
               ft1:= ftstring;
               size1:= 255; //default
               ar1:= splitstring(str2,'(');
               if high(ar1) >= 1 then begin
                ar1:= splitstring(ar1[1],')');
                if high(ar1) >= 0 then begin
                 try
                  size1:= strtoint(ar1[0]);
                 except
                 end;
                end;
               end;
              end
              else begin
               if str2 = 'TEXT' then begin
                ft1:= ftmemo;
                size1:= blobidsize;
               end
               else begin
                if str2 = 'BLOB' then begin
                 ft1:= ftblob;
                 size1:= blobidsize;
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
   tfielddef.create(fielddefs,str1,ft1,size1,false,int1+1);
  end;
 end;
end;

procedure tsqlite3connection.Execute(const cursor: TSQLCursor;
               const atransaction: tsqltransaction; const AParams: TParams);
var
 int1: integer;
 str1: string;
 cu1: currency;
 do1: double;
 wo1: word;
begin
 with tsqlite3cursor(cursor) do begin
  if aparams <> nil then begin
   for int1:= 0 to high(fparambinding) do begin
    with aparams[fparambinding[int1]] do begin
     if isnull then begin
      checkerror(sqlite3_bind_null(fstatement,int1+1));
     end
     else begin
      case datatype of
       ftinteger,ftboolean,ftsmallint: begin
        checkerror(sqlite3_bind_int(fstatement,int1+1,asinteger));
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
//        if do1 > 1e15 then begin           //sigfpe in sqlitelib
//         str1:= floattostr(do1);
//         stringaddref(str1);
//         checkerror(sqlite3_bind_text(fstatement,int1+1,pchar(str1),
//                    length(str1),@freebindstring));
//        end
//        else begin
         checkerror(sqlite3_bind_double(fstatement,int1+1,do1));
//        end;
       end;
       ftstring: begin
        str1:= asstring;
        stringaddref(str1);
        checkerror(sqlite3_bind_text(fstatement,int1+1,pchar(str1),
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
  if fopen then begin
   checkerror(sqlite3_reset(fstatement));
   fopen:= false;
  end;   
  wo1:= get8087cw;
  set8087cw(wo1 or $1f);             //mask exceptions, Sqlite3 has overflow
  fstate:= sqlite3_step(fstatement);
  set8087cw(wo1);                    //restore
  if fstate <= sqliteerrormax then begin
   checkerror(sqlite3_reset(fstatement));
  end;
  if fstate = sqlite_row then begin
   fstate:= sqliteerrormax; //first row
  end;
  fopen:= true;
 end;
end;

function tsqlite3connection.loadfield(const cursor: tsqlcursor;
               const afield: tfield; const buffer: pointer;
               var bufsize: integer): boolean;
var
 st1: storagetypety;
 fnum: integer;
 i: integer;
 i64: int64;
 int1,int2: integer;
 str1: string;
 ar1,ar2: stringarty;
 year,month,day,hour,minute,second: integer;
begin
 with tsqlite3cursor(cursor) do begin
  fnum:= afield.fieldno - 1;
  st1:= storagetypety(sqlite3_column_type(fstatement,fnum));
  result:= st1 <> st_null;
  if result then begin
   case afield.datatype of
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
    ftstring: begin
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

function tsqlite3connection.StartdbTransaction(trans: TSQLHandle;
               aParams: string): boolean;
begin
 if cantransaction then begin
  execsql('BEGIN');
 end;
 result:= true;
end;

procedure tsqlite3connection.internalCommitRetaining(trans: TSQLHandle);
begin
 commit(trans);  
 if cantransaction then begin
  execsql('BEGIN');
 end;
end;

procedure tsqlite3connection.internalRollBackRetaining(trans: TSQLHandle);
begin
 rollback(trans);
 if cantransaction then begin
  execsql('BEGIN');
 end;
end;

function tsqlite3connection.getblobdatasize: integer;
begin
 result:= blobidsize;
end;

procedure tsqlite3connection.DoInternalConnect;
var
 mstr1: msestring;
 str1: string;
begin
 mstr1:= fcontroller.getdatabasename;
 if (mstr1 = '') then begin
  DatabaseError(SErrNoDatabaseName,self);
 end;
 initialisesqlite3;
 str1:= stringtoutf8(mstr1);
 checkerror(sqlite3_open(pchar(str1),@fhandle));
end;

procedure tsqlite3connection.DoInternalDisconnect;
var
 int1: integer;
begin
 if fhandle <> nil then begin
  int1:= sqlite3_close(fhandle);
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
var
 mstr1: msestring;
begin
 if aerror <> sqlite_ok then begin
  mstr1:= utf8tostring(sqlite3_errmsg(fhandle));
  databaseerror(mstr1);
 end;
end;

procedure tsqlite3connection.execsql(const asql: string);
var
 err: pchar;
 str1: string;
 int1: integer;
begin
 err:= nil;
 int1:= sqlite3_exec(fhandle,pchar(asql),nil,nil,@err);
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
  aparam.asstring:= str1;
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
 acursor.blobfieldtoparam(afield,aparam,afield.datatype = ftmemo);
end;

function tsqlite3connection.blobscached: boolean;
begin
 result:= true;
end;

function execcallback(adata: pointer; ncols: longint; //adata = pstringarty
                avalues: PPchar; anames: PPchar):longint; cdecl;
var
 int1: integer;
begin
 setlength(pstringarty(adata)^,ncols);
 for int1:= 0 to ncols - 1 do begin
  pstringarty(adata)^[int1]:= pcharpoaty(avalues)^[int1];
 end;
 result:= 0;
end;

function tsqlite3connection.stringquery(const asql: string): stringarty;
begin
 result:= nil;
 checkerror(sqlite3_exec(fhandle,pchar(asql),@execcallback,@result,nil));
end;

function execscallback(adata: pointer; ncols: longint; //adata = pstringarty
                avalues: PPchar; anames: PPchar):longint; cdecl;
var
 int1: integer;
 po1: pstringarty;
begin
 setlength(pstringararty(adata)^,high(pstringararty(adata)^)+2);
 po1:= @(pstringararty(adata)^[high(pstringararty(adata)^)]);
 setlength(po1^,ncols);
 for int1:= 0 to ncols - 1 do begin
  po1^[int1]:= pcharpoaty(avalues)^[int1];
 end;
 result:= 0;
end;

function tsqlite3connection.stringsquery(const asql: string): stringararty;
begin
 result:= nil;
 checkerror(sqlite3_exec(fhandle,pchar(asql),@execscallback,@result,nil));
end;

function tsqlite3connection.getprimarykeyfield(const atablename: string;
                                const acursor: tsqlcursor): string;
var
 int1,int2: integer;
 ar1: stringararty;
 str1: string;
begin
 result:= '';
 if atablename <> '' then begin
  ar1:= stringsquery('PRAGMA table_info('+atablename+');');
  for int1:= 0 to high(ar1) do begin
   if (high(ar1[int1]) >= 5) and (ar1[int1][5] <> '0') then begin
    result:= ar1[int1][1];
    break;
   end;
  end;
 end;
end;

procedure tsqlite3connection.UpdateIndexDefs(var IndexDefs: TIndexDefs;
                              const TableName: string);
var
 str1: string;
begin
 str1:= getprimarykeyfield(tablename,nil);
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
procedure tsqlite3connection.setinheritedconnected(const avalue: boolean);
begin
 inherited connected:= avalue;
end;

function tsqlite3connection.getinsertid: int64;
begin
 result:= sqlite3_last_insert_rowid(fhandle);
end;

procedure tsqlite3connection.updateprimarykeyfield(const afield: tfield);
begin
 with tmsebufdataset1(afield.dataset) do begin
  setcurvalue(afield,getinsertid);
 end;
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

end.
