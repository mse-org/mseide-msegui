{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepqconnection;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,mpqconnection,msestrings,msedb,msetypes,msqldb,db;
type
 pqconnectionoptionty = (pqco_usesavepoint,pqco_closetransactiononfail);
 pqconnectionoptionsty = set of pqconnectionoptionty;
 
const
 defaultpqconnectionoptionsty = [pqco_usesavepoint];
 
type 
 tmsepqconnection = class(tpqconnection,idbcontroller)
  private
   fcontroller: tdbcontroller;
   foptions: pqconnectionoptionsty;
   fsavepointlock: boolean;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure loaded; override;
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure setoptions(const avalue: pqconnectionoptionsty);
  protected
   procedure execute(const cursor: tsqlcursor; const atransaction: tsqltransaction;
                             const aparams: tparams); override;
   //idbcontroller
   procedure setinheritedconnected(const avalue: boolean);
   function readsequence(const sequencename: string): string;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string;
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                         const acursor: tsqlcursor): TStream; override;
   procedure updateutf8(var autf8: boolean);                    
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
   property controller: tdbcontroller read fcontroller write setcontroller;
   property options: pqconnectionoptionsty read foptions write setoptions 
                                 default defaultpqconnectionoptionsty;
end;
 
implementation
uses
 msefileutils,msebits,sysutils,msedatalist,msesqldb,msebufdataset;
 
{ tmsepqconnection }

constructor tmsepqconnection.create(aowner: tcomponent);
begin
 foptions:= defaultpqconnectionoptionsty;
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
end;

destructor tmsepqconnection.destroy;
begin
 fcontroller.free;
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

procedure tmsepqconnection.execute(const cursor: tsqlcursor; 
               const atransaction: tsqltransaction; const aparams: tparams);
const
 savepointname = 'mseinternal$savepoint';
var
 bo1: boolean;
begin
 if fsavepointlock then begin
  inherited;
 end
 else begin
  fsavepointlock:= true;
  bo1:= (pqco_usesavepoint in foptions) and not (tao_fake in atransaction.options);
  try
   if bo1 then begin
    executedirect('SAVEPOINT '+savepointname+';',atransaction);
   end;
   try
    inherited;
   except
    if pqco_closetransactiononfail in foptions then begin
     atransaction.active:= false;
    end
    else begin
     if bo1 then begin
      executedirect('ROLLBACK TO SAVEPOINT '+savepointname+';',atransaction);
      executedirect('RELEASE SAVEPOINT '+savepointname+';',atransaction);
     end;
    end;
    raise;
   end;
   if bo1 then begin
    executedirect('RELEASE SAVEPOINT '+savepointname+';',atransaction);
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
          setsinglebit(longword(avalue),longword(foptions),longword(mask)));
end;

function tmsepqconnection.readsequence(const sequencename: string): string;
begin
 result:= 'select nextval(''' +sequencename+''') as res;';
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

procedure tmsepqconnection.updateutf8(var autf8: boolean);
begin
 //dummy
end;

procedure tmsepqconnection.setinheritedconnected(const avalue: boolean);
begin
 inherited connected:= avalue;
end;

end.
