unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,mseificomp,msedesignintf,regifi_bmp,msepropertyeditors,mseclasses; 
    
type
 tifiwidgeteditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;
 
procedure register;
begin
 registercomponents('Ifi',[tifistringlinkcomp]); 
 registercomponenttabhints(['Ifi'],
   ['IFI Components']);
end;

{ tifiwidgeteditor }

function tifiwidgeteditor.filtercomponent(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
begin
// result:= getcorbainterface(acomponent,typeinfo(iifiwidget)) and
             
 
end;

initialization
 register;
end.
