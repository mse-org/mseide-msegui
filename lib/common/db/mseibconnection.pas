{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseibconnection;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mdb,classes,mclasses,mibconnection,msestrings,msedb,msesqldb,msqldb,ibase60dyn,
 msebufdataset,msedatabase;
type
 tmseibconnection = class(tibconnection,idbcontroller)
  private
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean; reintroduce;
   procedure setconnected(const avalue: boolean); reintroduce;
  protected
   procedure loaded; override;
   //idbcontroller
   function readsequence(const sequencename: string): msestring; override;
   function sequencecurrvalue(const sequencename: string): msestring; override;
   function writesequence(const sequencename: string;
                    const avalue: largeint): msestring; override;
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode; 
                       const acursor: tsqlcursor): TStream; override;
  public
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected default false;
 end;
 
implementation
uses
 msefileutils,sysutils,mseformatstr;

{ tmseibconnection }

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

function tmseibconnection.readsequence(const sequencename: string): msestring;
begin
 result:= 'select gen_id('+msestring(sequencename)+
                                   ',1) as res from RDB$DATABASE;';
end;

function tmseibconnection.sequencecurrvalue(
                                       const sequencename: string): msestring;
begin
 result:= 'select gen_id('+msestring(sequencename)+
                                    ',0) as res from RDB$DATABASE;';
end;

function tmseibconnection.writesequence(const sequencename: string;
               const avalue: largeint): msestring;
begin
 result:= 'set generator '+msestring(sequencename)+
                                    ' to '+inttostrmse(avalue)+';';
end;

function tmseibconnection.CreateBlobStream(const Field: TField;
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
