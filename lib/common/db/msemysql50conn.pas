{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemysql50conn;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 db,classes,mmysql50conn,msestrings,msedb;
 
type
 tmsemysql50connection = class(tmysql50connection,idbcontroller)
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
 
{ tmsemysql50connection }

constructor tmsemysql50connection.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdbcontroller.create(self,idbcontroller(self));
end;

destructor tmsemysql50connection.destroy;
begin
 fcontroller.free;
 inherited;
end;

procedure tmsemysql50connection.setdatabasename(const avalue: filenamety);
begin
 fcontroller.setdatabasename(avalue);
end;

function tmsemysql50connection.getdatabasename: filenamety;
begin
 result:= fcontroller.getdatabasename;
end;

procedure tmsemysql50connection.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

procedure tmsemysql50connection.setcontroller(const avalue: tdbcontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsemysql50connection.getconnected: boolean;
begin
 result:= inherited connected;
end;

procedure tmsemysql50connection.setconnected(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited connected:= avalue;
 end;
end;

function tmsemysql50connection.readsequence(const sequencename: string): string;
begin
 result:= '';
end;

function tmsemysql50connection.writesequence(const sequencename: string;
               const avalue: largeint): string;
begin
 result:= '';
end;

procedure tmsemysql50connection.updateutf8(var autf8: boolean);
begin
 //dummy
end;

procedure tmsemysql50connection.setinheritedconnected(const avalue: boolean);
begin
 inherited connected:= avalue;
end;

end.
