unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 classes,mseifi,msedesignintf,msepropertyeditors,msestrings,msedesigner,
 mseclasses,mseifids,mseifiglob,msegui,typinfo;
 
type
 tformlinkitemeditor = class(tclasselementeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function getvalue: msestring; override;
 end;
 
 tformlinkeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
 tformlinkactionitemeditor = class(tformlinkitemeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tformlinkactionseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tifidatawidgeteditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
   procedure checkcomponent(const avalue: tcomponent); override;
  public
 end;

 tformlinkdatawidgetitemeditor = class(tformlinkitemeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tformlinkdatawidgetseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
  
procedure register;
begin
 registercomponents('Ifi',[tformlink,tpipeiochannel,ttxdataset,trxdataset]); 
 registerpropertyeditor(typeinfo(tformlinkarrayprop),nil,'',tformlinkeditor);
 registerpropertyeditor(typeinfo(tlinkactions),nil,'',tformlinkactionseditor);
 registerpropertyeditor(typeinfo(tlinkdatawidgets),nil,'',tformlinkdatawidgetseditor);
 registerpropertyeditor(typeinfo(twidget),tlinkdatawidget,'widget',tifidatawidgeteditor);
end;

{ tformlinkitemeditor }

function tformlinkitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 with tformlinkprop(getordvalue) do begin
  result:= '<'+name+'>';
 end;
end;

{ tformlinkactionitemeditor }

function tformlinkactionitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 result:= inherited getvalue;
 with tlinkaction(getordvalue) do begin
  if action = nil then begin
   result:= result+'<>';
  end
  else begin
   mstr1:= fdesigner.getcomponentname(action);
   if mstr1 = '' then begin
    ownernamepath(action);
   end;
   result:= result+'<'+mstr1+'>';
  end;
 end;
end;

function tformlinkitemeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_refresh];
end;

{ tformlinkeditor }

function tformlinkeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tformlinkitemeditor;
end;

{ tformlinkactionseditor }

function tformlinkactionseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tformlinkactionitemeditor;
end;

{ tifidatawidgeteditor }

function tifidatawidgeteditor.filtercomponent(const acomponent: tcomponent): boolean;
var
 intf1: iifiwidget; 
begin
 result:= getcorbainterface(acomponent,typeinfo(iifiwidget),intf1);
end;

{ tformlinkdatawidgetitemeditor }

function tformlinkdatawidgetitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 result:= inherited getvalue;
 with tlinkdatawidget(getordvalue) do begin
  if widget = nil then begin
   result:= result+'<>';
  end
  else begin
   mstr1:= fdesigner.getcomponentname(widget);
   if mstr1 = '' then begin
    ownernamepath(widget);
   end;
   result:= result+'<'+mstr1+'>';
  end;
 end;
end;

{ tformlinkdatawidgetseditor }

function tformlinkdatawidgetseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tformlinkdatawidgetitemeditor;
end;

procedure tifidatawidgeteditor.checkcomponent(const avalue: tcomponent);
begin
 inherited;
 with tlinkdatawidget(fprops[0].instance) do begin
  if name = '' then begin
   name:= avalue.name;
  end;
 end; 
end;

initialization
 register;
end.
