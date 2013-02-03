unit regmycomps;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msedesignintf,mybutton;
 
procedure register;
begin
 registercomponents('My',[tmybutton]);
end;

initialization
 register;
end.
