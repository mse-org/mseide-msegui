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
 db,classes,ibconnection,msestrings,msedb;
type
 tmseibconnection = class(tibconnection,idbcontroller)
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
 msefileutils,sysutils;

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

end.
