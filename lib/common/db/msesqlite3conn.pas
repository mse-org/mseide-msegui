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
 classes,msqldb,msedb,msestrings,db,sqlite3dyn;
 
type
 tsqlite3connection = class(tsqlconnection,idbcontroller)
  private
   fcontroller: tdbcontroller;
   fhandle: psqlite3;
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
                    
  protected
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
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
   property controller: tdbcontroller read fcontroller write setcontroller;
 end;
 
implementation
uses
 msesqldb,msebufdataset,dbconst,sysutils;
type
 tsqlite3cursor = class(tsqlcursor)
  private
   fstatement: psqlite3_stmt;
   ftail: pchar;
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
begin
 if (mode = bmwrite) and (field.dataset is tmsesqlquery) then begin
  result:= tmsebufdataset(field.dataset).createblobbuffer(field);
 end
 else begin
  result:= inherited createblobstream(field,mode,acursor);
 end;
 //todo
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
  checkerror(sqlite3_prepare_v2(fhandle,pchar(buf),length(buf),@fstatement,
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

procedure tsqlite3connection.Execute(const cursor: TSQLCursor;
               const atransaction: tsqltransaction; const AParams: TParams);
begin
end;

function tsqlite3connection.Fetch(cursor: TSQLCursor): boolean;
begin
end;

procedure tsqlite3connection.AddFieldDefs(cursor: TSQLCursor;
               FieldDefs: TfieldDefs);
begin
end;

procedure tsqlite3connection.FreeFldBuffers(cursor: TSQLCursor);
begin
end;

function tsqlite3connection.loadfield(const cursor: tsqlcursor;
               const afield: tfield; const buffer: pointer;
               var bufsize: integer): boolean;
begin
end;

function tsqlite3connection.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
 result:= nil;
end;

function tsqlite3connection.Commit(trans: TSQLHandle): boolean;
begin
 execsql('COMMIT');
end;

function tsqlite3connection.RollBack(trans: TSQLHandle): boolean;
begin
 execsql('ROLLBACK');
end;

function tsqlite3connection.StartdbTransaction(trans: TSQLHandle;
               aParams: string): boolean;
begin
 execsql('BEGIN');
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
  if int1 = sqlite_busy then begin
   checkerror(int1);
  end;
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

end.
