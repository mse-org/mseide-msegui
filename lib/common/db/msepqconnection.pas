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
 datasetarty = array of tdataset;
 tmsepqconnection = class(tpqconnection,idbcontroller)
  private
   fcontroller: tdbcontroller;
   foptions: pqconnectionoptionsty;
   fsavepointlock: boolean;
   fdatasets: datasetarty;
   frecnos: integerarty;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure loaded; override;
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure closeds;
   procedure reopends;
   procedure setoptions(const avalue: pqconnectionoptionsty);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation);
                                override;
   procedure commitretaining(trans : tsqlhandle); override;
   procedure rollbackretaining(trans : tsqlhandle); override;
   procedure execute(cursor: tsqlcursor; atransaction: tsqltransaction; 
                            aparams: tparams); override;
   //idbcontroller
   function readsequence(const sequencename: string): string;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string;
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
 msefileutils,msebits,sysutils,msedatalist;
 
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

procedure tmsepqconnection.commitretaining(trans: tsqlhandle);
var
 activeds: integerarty;
begin
 closeds; //cursors are lost
 try
  inherited;
  reopends;
 finally
  fdatasets:= nil;
  frecnos:= nil;
 end;
end;

procedure tmsepqconnection.rollbackretaining(trans: tsqlhandle);
begin
 closeds;
 try
  inherited; 
  reopends;
 finally
  fdatasets:= nil;
  frecnos:= nil;
 end;
end;

procedure tmsepqconnection.notification(acomponent: tcomponent;
               operation: toperation);
var
 int1: integer;
begin
 inherited;
 if operation = opremove then begin
  int1:= finditem(pointerarty(fdatasets),acomponent);
  if int1 >= 0 then begin
   fdatasets[int1]:= nil;
  end;
 end;
end;

procedure tmsepqconnection.closeds;
var
 int1: integer;
begin
 setlength(fdatasets,datasetcount);
 setlength(frecnos,length(fdatasets));
 for int1:= high(fdatasets) downto 0 do begin
  fdatasets[int1]:= datasets[int1];
  with fdatasets[int1] do begin
   freenotification(self);
   if active then begin
    frecnos[int1]:= recno;
   end
   else begin
    frecnos[int1]:= -2;
   end;
  end;
 end;
 for int1:= high(fdatasets) downto 0 do begin
  if (fdatasets[int1] <> nil) and 
                 (tdbdataset(fdatasets[int1]).database = self) then begin
   fdatasets[int1].active:= false;
  end;
 end;
end;

procedure tmsepqconnection.reopends;
var
 int1: integer;
begin
 for int1:= high(fdatasets) downto 0 do begin
  if fdatasets[int1] <> nil then begin
   if frecnos[int1] >= -1 then begin
    with tdbdataset(fdatasets[int1]) do begin
     if database = self then begin
      disablecontrols;
      active:= true;
      if frecnos[int1] >= 0 then begin
       try
        moveby(frecnos[int1]-recno);
       except
       end;
      end;
      enablecontrols;
     end;
    end;
   end;
  end;
 end;
end;

procedure tmsepqconnection.execute(cursor: tsqlcursor; 
                             atransaction: tsqltransaction; aparams: tparams);
const
 savepointname = 'mseinternal$savepoint';
begin
 if fsavepointlock then begin
  inherited;
 end
 else begin
  fsavepointlock:= true;
  try
   if pqco_usesavepoint in foptions then begin
    executedirect('SAVEPOINT '+savepointname+';');
   end;
   try
    inherited;
   except
    if pqco_closetransactiononfail in foptions then begin
     atransaction.active:= false;
    end
    else begin
     if pqco_usesavepoint in foptions then begin
      executedirect('ROLLBACK TO SAVEPOINT '+savepointname+
                    '; RELEASE SAVEPOINT '+savepointname+';');
     end;
    end;
    raise;
   end;
   if pqco_usesavepoint in foptions then begin
    executedirect('RELEASE SAVEPOINT '+savepointname+';');
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

end.
