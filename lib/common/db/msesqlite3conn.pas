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
 
type
 sqliteoptionty = (slo_transactions);
 sqliteoptionsty = set of sqliteoptionty;
 
 tsqlite3connection = class(tsqlconnection,idbcontroller,iblobconnection)
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

  protected
   function stringquery(const asql: string): stringarty;
   function stringsquery(const asql: string): stringararty;
   procedure checkerror(const aerror: integer);
   
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
   procedure CommitRetaining(trans : TSQLHandle); override;
   procedure RollBackRetaining(trans : TSQLHandle); override;
   function getblobdatasize: integer; override;
    
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode; 
                       const acursor: tsqlcursor): TStream; override;
   procedure execsql(const asql: string);
   procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;
                               const TableName : string); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
   property controller: tdbcontroller read fcontroller write setcontroller;
   property options: sqliteoptionsty read foptions write foptions;
 end;
 
implementation
uses
 msesqldb,msebufdataset,dbconst,sysutils,typinfo;
type
 storagetypety = (st_none,st_integer,st_float,st_text,st_blob,st_null);
 
 tsqlite3cursor = class(tsqlcursor)
  private
   fstatement: psqlite3_stmt;
   ftail: pchar;
   fstate: integer;
   fparambinding: integerarty;
 end;
  
{ tsqlite3connection }

constructor tsqlite3connection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
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
  {$ifdef FPC_2_2}
    buf := aparams.parsesql(buf,false,false,false,psinterbase,fparambinding);
  {$else}
    buf := aparams.parsesql(buf,false,psinterbase,fparambinding);
  {$endif}
  end;
  checkerror(sqlite3_prepare(fhandle,pchar(buf),length(buf),@fstatement,
                                               @ftail));
 end;
end;

procedure tsqlite3connection.UnPrepareStatement(cursor: TSQLCursor);
var
 int1: integer;
begin
 with tsqlite3cursor(cursor) do begin
  int1:= sqlite3_finalize(fstatement);
 end;
end;

procedure freebindstring(astring: pointer); cdecl;
begin
 string(astring):= '';
end;

procedure tsqlite3connection.Execute(const cursor: TSQLCursor;
               const atransaction: tsqltransaction; const AParams: TParams);
var
 int1: integer;
 str1: string;
 cu1: currency;
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
       ftfloat: begin
        checkerror(sqlite3_bind_double(fstatement,int1+1,asfloat));
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
  fstate:= sqlite3_step(fstatement);
  if fstate <= sqliteerrormax then begin
   checkerror(sqlite3_reset(fstatement));
  end;
  if fstate = sqlite_row then begin
   fstate:= sqliteerrormax; //first row
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
   if (str2 = 'INT') or (str2 = 'INTEGER') then begin
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
       if (str2 = 'REAL') or (pos('FLOAT',str1) = 1) or 
                                      (pos('DOUBLE',str1) = 1) then begin     
        ft1:= ftfloat;
        size1:= sizeof(double);
       end
       else begin
        if pos('NUMERIC',str2) = 1 then begin      
         ft1:= ftbcd;
         size1:= sizeof(currency);
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
//   if ft1 <> ftunknown then begin
    tfielddef.create(fielddefs,str1,ft1,size1,false,int1+1);
//   end;
  end;
 end;
end;

procedure tsqlite3connection.FreeFldBuffers(cursor: TSQLCursor);
begin
 //dummy
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
    ftlargeint,ftbcd: begin
     largeint(buffer^):= sqlite3_column_int64(fstatement,fnum);
    end;
    ftfloat: begin
     double(buffer^):= sqlite3_column_double(fstatement,fnum);
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

function tsqlite3connection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
 result:= nil;
end;

function tsqlite3connection.Commit(trans: TSQLHandle): boolean;
begin
 if slo_transactions in foptions then begin
  execsql('COMMIT');
 end;
 result:= true;
end;

function tsqlite3connection.RollBack(trans: TSQLHandle): boolean;
begin
 if slo_transactions in foptions then begin
  execsql('ROLLBACK');
 end;
 result:= true;
end;

function tsqlite3connection.StartdbTransaction(trans: TSQLHandle;
               aParams: string): boolean;
begin
 if slo_transactions in foptions then begin
  execsql('BEGIN');
 end;
 result:= true;
end;

procedure tsqlite3connection.CommitRetaining(trans: TSQLHandle);
begin
 commit(trans);  //todo
end;

procedure tsqlite3connection.RollBackRetaining(trans: TSQLHandle);
begin
 rollback(trans); //todo
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
{  
for int1:= 0 to high(ar2) do begin
 for int2:= 0 to high(ar2[int1]) do begin
  write(ar2[int1][int2],' ');
 end;
 writeln;
end;
}
end;

end.
