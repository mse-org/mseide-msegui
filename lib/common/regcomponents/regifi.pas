unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,mseificomp,msedesignintf,regifi_bmp; 
    
procedure register;
begin
 registercomponents('Ifi',[tifistringlinkcomp]); 
 registercomponenttabhints(['Ifi'],
   ['IFI Components']);
end;

initialization
 register;
end.
