{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbus;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msectypes,msetypes,msestrings;
 
const
{$ifdef mswindows}
 {$define wincall}
 dbuslib: array[0..0] of filenamety = ('libdbus.dll');
{$else}
 dbuslib: array[0..0] of filenamety = ('libdbus-1.so');
{$endif}

type
 DBusError = record
  name: pcchar;    //**< public error name field */
  message: pcchar; //**< public error message field */
  dummy: cuint;
//  unsigned int dummy1 : 1; /**< placeholder */
//  unsigned int dummy2 : 1; /**< placeholder */
//  unsigned int dummy3 : 1; /**< placeholder */
//  unsigned int dummy4 : 1; /**< placeholder */
//  unsigned int dummy5 : 1; /**< placeholder */
  padding1: pointer; {< placeholder }
 end;
 pDBusError = ^DBusError;

 DBusBusType = (
  DBUS_BUS_SESSION,    //**< The login session bus */
  DBUS_BUS_SYSTEM,     //**< The systemwide bus */
  DBUS_BUS_STARTER     //**< The bus that started us, if any */
 );

 DBusConnection = record end;
 pDBusConnection = ^DBusConnection;

var
 dbus_bus_get: function(type_: DBusBusType; error: PDBusError): PDBusConnection
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_close: procedure(connection: pDBusConnection)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

procedure initializedbus(const sonames: array of filenamety;
                                          const onlyonce: boolean = false);
                                     //[] = default
procedure releasedbus();

implementation
uses
 msedynload,sysutils;
var 
 libinfo: dynlibinfoty;

procedure inidbus();
begin
end;

procedure finidbus();
begin
end;

procedure initializedbus(const sonames: array of filenamety; //[] = default
                                         const onlyonce: boolean = false);                                   
const
 funcs: array[0..1] of funcinfoty = (
  (n: 'dbus_bus_get'; d: @dbus_bus_get),
  (n: 'dbus_connection_close'; d: @dbus_connection_close)
 );
 errormessage = 'Can not load D-Bus library. ';

begin
 if not onlyonce or (libinfo.refcount = 0) then begin
  initializedynlib(libinfo,sonames,dbuslib,funcs,[],errormessage,@inidbus);
 end;
end;

procedure releasedbus();
begin
 releasedynlib(libinfo,@finidbus);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
