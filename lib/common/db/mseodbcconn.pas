{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseodbcconn;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 db,classes,modbcconn,msestrings,msedb;
type
 tmseodbcconnection = class(todbcconnection,idbcontroller)
  private
   fcontroller: tdbcontroller;
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   procedure loaded; override;
   procedure setcontroller(const avalue: tdbcontroller);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
  protected
   //idbcontroller
   procedure setinheritedconnected(const avalue: boolean);
   function readsequence(const sequencename: string): string;
   function writesequence(const sequencename: string;
                    const avalue: largeint): string;
   procedure updateutf8(var autf8: boolean);                    
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
 msefileutils;
 
{ tmseodbcconnection }

constructor tmseodbcconnection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
end;

destructor tmseodbcconnection.destroy;
begin
 fcontroller.free;
 inherited;
end;

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

procedure tmseodbcconnection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
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

function tmseodbcconnection.readsequence(const sequencename: string): string;
begin
 result:= '';
end;

function tmseodbcconnection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= '';
end;

procedure tmseodbcconnection.updateutf8(var autf8: boolean);
begin
 //dummy
end;

procedure tmseodbcconnection.setinheritedconnected(const avalue: boolean);
begin
 inherited connected:= avalue;
end;

end.
