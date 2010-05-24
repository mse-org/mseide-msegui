unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,mseificomp,msedesignintf,regifi_bmp,msepropertyeditors,mseclasses,
 msecomponenteditors,mseificomponenteditors,msestrings; 
    
type
 tifiwidgeteditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;
 
 tifidropdowncolpropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 
procedure register;
begin
 registercomponents('Ifi',[tifiactionlinkcomp,tifiintegerlinkcomp,
       tifibooleanlinkcomp,
       tifireallinkcomp,tifidatetimelinkcomp,tifistringlinkcomp,
       tifidropdownlistlinkcomp,tifienumlinkcomp,
       tifigridlinkcomp]); 
 registercomponenttabhints(['Ifi'],
   ['MSEifi Components (experimental).'+lineend+
   'Compile MSEide with -dmse_with_ifirem '+
   'in order to install MSEifi remote components,'+lineend+
   'compile with -dmse_with_pascalscript for PascalScript components.']);
// registerpropertyeditor(typeinfo(tcomponent),tcustomificlientcontroller,
//                                                      'widget',tifiwidgeteditor);
 registercomponenteditor(tifilinkcomp,tifilinkcompeditor);
 registerpropertyeditor(typeinfo(tifidropdowncols),nil,'',
                                          tifidropdowncolpropertyeditor);
end;

{ tifiwidgeteditor }

function tifiwidgeteditor.filtercomponent(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
begin
// result:= tcustomifivaluewidgetcontroller(
//                    fprops[0].instance).canconnect(acomponent);
end;

{ tifidropdowncolpropertyeditor }

function tifidropdowncolpropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmsestringdatalistpropertyeditor;
end;

initialization
 register;
end.
