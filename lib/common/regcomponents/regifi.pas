unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 classes,mseifi,msedesignintf,msepropertyeditors,msestrings,msedesigner,
 mseclasses,mseifids,mseifiglob,msegui,typinfo,msesockets,mseifigui,
 mseifilink,msessl;
 
type
 tmodulelinkitemeditor = class(tclasselementeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function getvalue: msestring; override;
 end;
 
 tmodulelinkeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
 tmodulelinkactionitemeditor = class(tmodulelinkitemeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tmodulelinkactionseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tifidatawidgeteditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
   procedure checkcomponent(const avalue: tcomponent); override;
  public
 end;

 tvaluewidgetlinkitemeditor = class(tmodulelinkitemeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tvaluewidgetlinkseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
  
procedure register;
begin
 registercomponents('Ifi',[tmodulelink,tformlink,
                     {tpipeifichannel,tsocketpipeifichannel,
                     tsocketclientifichannel,tsocketserverifichannel,}
                     ttxdataset,trxdataset,
                     tpipeiochannel,tsocketpipeiochannel,
                     tsocketclientiochannel,tsocketserveriochannel,
                     tsocketstdio,tsocketclient,
                     tsocketserver,tsocketserverstdio,
                     tssl]); 
 registercomponenttabhints(['Ifi'],
   ['Internet Form Interpreter and PascalScript Components']);
 registerpropertyeditor(typeinfo(tmodulelinkarrayprop),nil,'',tmodulelinkeditor);
 registerpropertyeditor(typeinfo(tlinkactions),nil,'',tmodulelinkactionseditor);
 registerpropertyeditor(typeinfo(tvaluewidgetlinks),nil,'',tvaluewidgetlinkseditor);
 registerpropertyeditor(typeinfo(twidget),tvaluewidgetlink,'widget',tifidatawidgeteditor);
end;

{ tmodulelinkitemeditor }

function tmodulelinkitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 with tmodulelinkprop(getordvalue) do begin
  result:= '<'+name+'>';
 end;
end;

{ tmodulelinkactionitemeditor }

function tmodulelinkactionitemeditor.getvalue: msestring;
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

function tmodulelinkitemeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_refresh];
end;

{ tmodulelinkeditor }

function tmodulelinkeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmodulelinkitemeditor;
end;

{ tmodulelinkactionseditor }

function tmodulelinkactionseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmodulelinkactionitemeditor;
end;

{ tifidatawidgeteditor }

function tifidatawidgeteditor.filtercomponent(const acomponent: tcomponent): boolean;
var
 intf1: iifiwidget; 
begin
 result:= getcorbainterface(acomponent,typeinfo(iifiwidget),intf1);
end;

{ tvaluewidgetlinkitemeditor }

function tvaluewidgetlinkitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 result:= inherited getvalue;
 with tvaluewidgetlink(getordvalue) do begin
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

{ tvaluewidgetlinkseditor }

function tvaluewidgetlinkseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tvaluewidgetlinkitemeditor;
end;

{ tifidatawidgeteditor }

procedure tifidatawidgeteditor.checkcomponent(const avalue: tcomponent);
begin
 inherited;
 with tvaluewidgetlink(fprops[0].instance) do begin
  if name = '' then begin
   name:= avalue.name;
  end;
 end; 
end;

initialization
 register;
end.
