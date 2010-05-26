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

 tificolitempropertyeditor = class(tclasselementeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tifilinkcomparraypropertyeditor = class(tpersistentarraypropertyeditor)
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
//                                               'widget',tifiwidgeteditor);
 registercomponenteditor(tifilinkcomp,tifilinkcompeditor);
 registerpropertyeditor(typeinfo(tifidropdowncols),nil,'',
                                          tifidropdowncolpropertyeditor);
 registerpropertyeditor(typeinfo(tifilinkcomparrayprop),nil,'',
                                          tifilinkcomparraypropertyeditor);
end;

{ tifiwidgeteditor }

function tifiwidgeteditor.filtercomponent(
                                    const acomponent: tcomponent): boolean;
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

{ tifilinkcomparraypropertyeditor }

function tifilinkcomparraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tificolitempropertyeditor;
end;

{ tificolitempropertyeditor }

function tificolitempropertyeditor.getvalue: msestring;
var
 obj1: tificolitem;
begin
 result:= '<nil>';
 obj1:= tificolitem(getpointervalue);
 if (obj1 <> nil) and (obj1.link <> nil) then begin
  result:= '<'+obj1.link.name+'>';
 end;
end;

initialization
 register;
end.
