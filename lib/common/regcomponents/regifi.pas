unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,mseifi,msedesignintf,msepropertyeditors,msestrings,msedesigner,
 mseclasses,mseifids,mseifiglob,msegui,typinfo,msesockets,mseifigui,
 mseifilink,msessl,db,regifi_bmp;
 
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

 tififieldoptoinselementeditor = class(tsetarrayelementeditor)
  public
   function name: msestring; override;
 end;
 
 tififieldoptionseditor = class(tsetarraypropertyeditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;   
  public 
   procedure setvalue(const value: msestring); override;
 end;
 
 tifitxactioncompeditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;
 
 tlocalconncompeditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;

 tifidatacolsitemeditor = class(tmodulelinkitemeditor)
  protected
   function getvalue: msestring; override;
 end;
 
 tifidatacolseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
    
procedure register;
begin
 registercomponents('Ifi',[tmodulelink,tformlink,
                     trxwidgetgrid,ttxdatagrid,
                     {tpipeifichannel,tsocketpipeifichannel,
                     tsocketclientifichannel,tsocketserverifichannel,}
                     ttxdataset,trxdataset,ttxsqlquery,
                     tpipeiochannel,tsocketstdiochannel,
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
 registerpropertyeditor(typeinfo(tcomponent),ttxlinkaction,'ificomp',
                 tifitxactioncompeditor);
 registerpropertyeditor(typeinfo(tcustomiochannel),tcustomiochannel,'localconn',
                 tlocalconncompeditor);
 registerpropertyeditor(typeinfo(tifidatacols),nil,'',tifidatacolseditor);
// registerpropertyeditor(typeinfo(tififieldoptions),tifidscontroller,'',
//                        tififieldoptionseditor);
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

{ tififieldoptionseditor }

function tififieldoptionseditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tififieldoptoinselementeditor;
end;

procedure tififieldoptionseditor.setvalue(const value: msestring);
begin
 //readonly
end;

{ tififieldoptoinselementeditor }

function tififieldoptoinselementeditor.name: msestring;
var
 field1: tfield;
begin
 field1:= tifidscontroller(fprops[0].instance).getfield(findex);
 if field1 <> nil then begin
  result:= field1.fieldname;
 end
 else begin
  result:= inherited name;
 end;
end;

{ tifitxactioncompeditor }

function tifitxactioncompeditor.filtercomponent(
                                    const acomponent: tcomponent): boolean;
var
 intf1: iifitxaction;
begin
 result:= mseclasses.getcorbainterface(acomponent,typeinfo(iifitxaction),intf1);
end;

{ tlocalconncompeditor }

function tlocalconncompeditor.filtercomponent(
                                    const acomponent: tcomponent): boolean;
begin
 result:= acomponent <> fcomponent;
end;

{ tifidatacolsitemeditor }

function tifidatacolsitemeditor.getvalue: msestring;
begin
 with tifidatacol(getordvalue) do begin
  result:= '<'+name+'>';
 end;
end;

{ tifidatacolseditor }

function tifidatacolseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tifidatacolsitemeditor;
end;

initialization
 register;
end.
