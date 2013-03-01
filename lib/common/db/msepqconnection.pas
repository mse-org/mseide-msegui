{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepqconnection;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,mpqconnection,msestrings,msedb,msetypes,msqldb,mdb,
 msedatabase;
type
 pqconnectionoptionty = (pqco_usesavepoint,pqco_closetransactiononfail);
 pqconnectionoptionsty = set of pqconnectionoptionty;
 
const
 defaultpqconnectionoptionsty = [pqco_usesavepoint];
 
type 
 tmsepqconnection = class(tpqconnection,idbcontroller)
  private
   foptions: pqconnectionoptionsty;
   fsavepointlock: boolean;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean; reintroduce;
   procedure setconnected(const avalue: boolean); reintroduce;
   procedure setoptions(const avalue: pqconnectionoptionsty);
  protected
   procedure loaded; override;
   procedure internalexecute(const cursor: tsqlcursor; const atransaction: tsqltransaction;
                     const aparams: tmseparams; const autf8: boolean); override;
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                         const acursor: tsqlcursor): TStream; override;
   //idbcontroller
   function readsequence(const sequencename: string): string; override;
   function sequencecurrvalue(const sequencename: string): string; override;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected default false;
   property options: pqconnectionoptionsty read foptions write setoptions 
                                 default defaultpqconnectionoptionsty;
end;
 
implementation
uses
 msefileutils,msebits,sysutils,msedatalist,msesqldb,msebufdataset,postgres3dyn;
 
{ tmsepqconnection }

constructor tmsepqconnection.create(aowner: tcomponent);
begin
 foptions:= defaultpqconnectionoptionsty;
 inherited;
end;

procedure tmsepqconnection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

function tmsepqconnection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tmsepqconnection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

procedure tmsepqconnection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsepqconnection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tmsepqconnection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

procedure tmsepqconnection.internalexecute(const cursor: tsqlcursor; 
               const atransaction: tsqltransaction;
               const aparams: tmseparams; const autf8: boolean);
const
 savepointname = 'mseinternal$savepoint';
var
 bo1: boolean;
 conn1: ppgconn;
begin
 if fsavepointlock then begin
  inherited;
 end
 else begin
  conn1:= TPQTrans(aTransaction.Handle).conn;
  fsavepointlock:= true;
  bo1:= (pqco_usesavepoint in foptions) and not (tao_fake in atransaction.options);
  try
   if bo1 then begin
//    executedirect('SAVEPOINT '+savepointname+';',atransaction);
    dopqexec('SAVEPOINT '+savepointname+';',conn1);
   end;
   try
    inherited;
   except
    if pqco_closetransactiononfail in foptions then begin
     atransaction.active:= false;
    end
    else begin
     if bo1 then begin
//      executedirect('ROLLBACK TO SAVEPOINT '+savepointname+';',atransaction);
      dopqexec('ROLLBACK TO SAVEPOINT '+savepointname+';',conn1);
//      executedirect('RELEASE SAVEPOINT '+savepointname+';',atransaction);
      dopqexec('RELEASE SAVEPOINT '+savepointname+';',conn1);
     end;
    end;
    raise;
   end;
   if bo1 then begin
//    executedirect('RELEASE SAVEPOINT '+savepointname+';',atransaction);
    dopqexec('RELEASE SAVEPOINT '+savepointname+';',conn1);
   end;
  finally
   fsavepointlock:= false;
  end;
 end;
end;

procedure tmsepqconnection.setoptions(const avalue: pqconnectionoptionsty);
const
 mask: pqconnectionoptionsty = [pqco_usesavepoint,pqco_closetransactiononfail];
begin
 foptions:= pqconnectionoptionsty(
          setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
          {$ifdef FPC}longword{$else}byte{$endif}(foptions),
          {$ifdef FPC}longword{$else}byte{$endif}(mask)));
end;

function tmsepqconnection.readsequence(const sequencename: string): string;
begin
 result:= 'select nextval(''' +sequencename+''') as res;';
end;

function tmsepqconnection.sequencecurrvalue(const sequencename: string): string;
begin
 result:= 'select last_value from ' + sequencename + ';';
end;

function tmsepqconnection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= 'select setval(''' +sequencename+''','+inttostr(avalue)+');';
end;

function tmsepqconnection.CreateBlobStream(const Field: TField;
               const Mode: TBlobStreamMode; const acursor: tsqlcursor): TStream;
begin
 if (mode = bmwrite) and (field.dataset is tmsesqlquery) then begin
  result:= tmsebufdataset(field.dataset).createblobbuffer(field);
 end
 else begin
  result:= inherited createblobstream(field,mode,acursor);
 end;
end;

end.
