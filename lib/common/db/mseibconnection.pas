{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseibconnection;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 db,classes,ibconnection,msestrings,msedb,msesqldb,sqldb,ibase60dyn;
type
 tmseibconnection = class(tibconnection,idbcontroller,imsesqlconnection)
  private
   fcontroller: tdbcontroller;
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
                    
   procedure CheckError(ProcName : string; Status : array of ISC_STATUS);
   function getMaxBlobSize(blobHandle : TIsc_Blob_Handle) : longInt;
  protected
   function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure writeblob(const atransaction: tsqltransaction; const tablename: string;
                         const ablob: blobinfoty; const aparam: tparam);
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
   property controller: tdbcontroller read fcontroller write setcontroller;
 end;
 
implementation
uses
 msefileutils,sysutils;
type
 TIBConnectioncracker = class (TSQLConnection)
  private
    FSQLDatabaseHandle   : pointer;
    FStatus              : array [0..19] of ISC_STATUS;
    FDialect             : integer;
 end;

{ tmseibconnection }

constructor tmseibconnection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
end;

destructor tmseibconnection.destroy;
begin
 fcontroller.free;
 inherited;
end;

procedure TmseIBConnection.CheckError(ProcName : string; Status : array of ISC_STATUS);
var
  buf : array [0..1024] of char;
  p   : pointer;
  Msg : string;
  E   : EIBDatabaseError;
  
begin
  if ((Status[0] = 1) and (Status[1] <> 0)) then
  begin
    p := @Status;
    msg := '';
    while isc_interprete(Buf, @p) > 0 do
      Msg := Msg + LineEnding +' -' + StrPas(Buf);
    E := EIBDatabaseError.CreateFmt('%s : %s : %s',[self.Name,ProcName,Msg]);
    E.GDSErrorCode := Status[1];
    Raise E;
  end;
end;

procedure tmseibconnection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

function tmseibconnection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tmseibconnection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

procedure tmseibconnection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
end;

function tmseibconnection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tmseibconnection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

function tmseibconnection.readsequence(const sequencename: string): string;
begin
 result:= 'select gen_id('+sequencename+',1) as res from RDB$DATABASE;';
end;

function tmseibconnection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= 'set generator '+sequencename+' to '+inttostr(avalue)+';';
end;

function tmseibconnection.CreateBlobStream(Field: TField;
               Mode: TBlobStreamMode): TStream;
begin
 if (mode = bmwrite) and (field.dataset is tmsesqlquery) then begin
  result:= tmsesqlquery(field.dataset).createblobbuffer(field);
 end
 else begin
  result:= inherited createblobstream(field,mode);
 end;
end;

function TmseIBConnection.getMaxBlobSize(blobHandle : TIsc_Blob_Handle) : longInt;
var
  iscInfoBlobMaxSegment : byte = isc_info_blob_max_segment;
  blobInfo : array[0..50] of byte;

begin
 with tibconnectioncracker(self) do begin
  if isc_blob_info(@Fstatus, @blobHandle, sizeof(iscInfoBlobMaxSegment), @iscInfoBlobMaxSegment, sizeof(blobInfo) - 2, @blobInfo) <> 0 then
    CheckError('isc_blob_info', FStatus);
  if blobInfo[0]  = isc_info_blob_max_segment then
    begin
      result :=  isc_vax_integer(pchar(@blobInfo[3]), isc_vax_integer(pchar(@blobInfo[1]), 2));
    end
  else
     CheckError('isc_blob_info', FStatus);
 end;
end;

procedure tmseibconnection.writeblob(const atransaction: tsqltransaction;
     const tablename: string; const ablob: blobinfoty; const aparam: tparam);
     
 procedure check(const ares: isc_status);
 begin
  if ares <> 0 then begin
   CheckError('TIBConnection.writeblob', tibconnectioncracker(self).FStatus);
  end;
 end;
 
var
 transactionhandle: pointer;
 blobhandle: isc_blob_handle;
 blobid: isc_quad;
 step: word;
 po1: pointer;
 int1: integer;
 str1: string;
begin
 with tibconnectioncracker(self) do begin
  if ablob.datalength = 0 then begin
   aparam.clear;
  end
  else begin
   transactionhandle:= atransaction.handle;
   blobhandle:= nil;
   fillchar(blobid,sizeof(blobid),0);
   check(isc_create_blob2(@fstatus,@fsqldatabasehandle,@transactionhandle,
                        @blobhandle,@blobid,0,nil));
   try
    step:= $4000;
    po1:= ablob.data;
    int1:= ablob.datalength;
    while int1 > 0 do begin
     if int1 < step then begin
      step:= int1;
     end;
     check(isc_put_segment(@fstatus,@blobhandle,step,po1));
     dec(int1,step);
     inc(po1,step);
    end;
    setlength(str1,sizeof(blobid));
    move(blobid,str1[1],sizeof(blobid));
    aparam.asstring:= str1;
   finally
    isc_close_blob(@fstatus,@blobhandle);
   end;
  end;
 end;
end;

end.
