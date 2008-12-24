unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 msedesignintf,msemysqlconn;
 
procedure Register;
begin
 registercomponents('Exp',[tmsemysqlconnection]);
 registercomponenttabhints(['Exp'],['Experimental Components']);
end;
initialization
 register;
end.
