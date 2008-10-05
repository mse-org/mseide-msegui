{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseodbcconn;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 db,classes,modbcconn,msestrings,msedb,msedatabase,msqldb;
type
 tmseodbcconnection = class(todbcconnection,idbcontroller)
  private
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure loaded; override;
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
  protected
   function CreateBlobStream(const Field: TField; const Mode: TBlobStreamMode;
                         const acursor: tsqlcursor): TStream; override;
  public
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected;
 end;
 
implementation
uses
 msefileutils,msesqldb,msebufdataset;
 
{ tmseodbcconnection }

procedure tmseodbcconnection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

function tmseodbcconnection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tmseodbcconnection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmseodbcconnection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tmseodbcconnection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

function tmseodbcconnection.CreateBlobStream(const Field: TField;
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
