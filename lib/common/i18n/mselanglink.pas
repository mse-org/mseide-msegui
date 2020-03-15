unit mselanglink;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msei18nglob;

type
 registermodulehookty = procedure(
                 const registermoduleproc: registermodulety);
 registerresourcehookty = procedure(
                 const registerresourceproc: registerresourcety);
var
 registermodulehook: registermodulehookty;
 registerresourcehook: registerresourcehookty;

procedure registerlang(const registermoduleproc: registermodulety;
                          const registerresourceproc: registerresourcety);
procedure unregisterlang(const unregistermoduleproc: registermodulety;
                          const unregisterresourceproc: registerresourcety);

implementation

var
 lastmodulehook: registermodulehookty;
 lastresourcehook: registerresourcehookty;

procedure registerlang(const registermoduleproc: registermodulety;
                          const registerresourceproc: registerresourcety);
begin
 if registermodulehook = nil then begin
  registermodulehook:= lastmodulehook;
 end;
 lastmodulehook:= registermodulehook;
 while registermodulehook <> nil do begin
  registermodulehook(registermoduleproc);
 end;
 if registerresourcehook = nil then begin
  registerresourcehook:= lastresourcehook;
 end;
 lastresourcehook:= registerresourcehook;
 while registerresourcehook <> nil do begin
  registerresourcehook(registerresourceproc);
 end;
end;

procedure unregisterlang(const unregistermoduleproc: registermodulety;
                          const unregisterresourceproc: registerresourcety);
begin
 registermodulehook:= lastmodulehook;
 while registermodulehook <> nil do begin
  registermodulehook(unregistermoduleproc);
 end;
 registerresourcehook:= lastresourcehook;
 while registerresourcehook <> nil do begin
  registerresourcehook(unregisterresourceproc);
 end;
end;

end.
