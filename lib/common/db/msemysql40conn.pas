{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemysql40conn;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 db,classes,mmysql40conn,msestrings,msedb;
 
type
 tmsemysql40connection = class(tmysql40connection,idbcontroller)
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
 
{ tmsemysql40connection }

constructor tmsemysql40connection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
end;

destructor tmsemysql40connection.destroy;
begin
 fcontroller.free;
 inherited;
end;

procedure tmsemysql40connection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

function tmsemysql40connection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tmsemysql40connection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

procedure tmsemysql40connection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsemysql40connection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tmsemysql40connection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

function tmsemysql40connection.readsequence(const sequencename: string): string;
begin
 result:= '';
end;

function tmsemysql40connection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= '';
end;

procedure tmsemysql40connection.updateutf8(var autf8: boolean);
begin
 //dummy
end;

procedure tmsemysql40connection.setinheritedconnected(const avalue: boolean);
begin
 inherited connected:= avalue;
end;

end.
