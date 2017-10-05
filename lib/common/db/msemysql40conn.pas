{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemysql40conn;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mdb,classes,mmysql40conn,msetypes{msestrings},msedb,msedatabase,msqldb;
 
type
 tmsemysql40connection = class(tmysql40connection,idbcontroller)
  private
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
   function getconnected: boolean; reintroduce;
   procedure setconnected(const avalue: boolean); reintroduce;
  protected
   procedure loaded; override;
  public
  published
   property DatabaseName: filenamety read getdatabasename write setdatabasename;
   property Connected: boolean read getconnected write setconnected default false;
 end;
 
implementation
uses
 msefileutils;
 
{ tmsemysql40connection }

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

end.
