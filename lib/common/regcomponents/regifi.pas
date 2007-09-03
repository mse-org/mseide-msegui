unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 mseifi,msedesignintf,msepropertyeditors,msestrings,msedesigner,mseclasses;
type
 tlinkactionitemeditor = class(tclasselementeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function getvalue: msestring; override;
 end;
 
 tlinkactionseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
procedure register;
begin
 registercomponents('Ifi',[tformlink,tpipeiochannel]); 
 registerpropertyeditor(typeinfo(tlinkactions),nil,'',tlinkactionseditor);
end;

{ tlinkactionitemeditor }

function tlinkactionitemeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 with tlinkaction(getordvalue) do begin
  result:= '<'+name+'>';
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

function tlinkactionitemeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_refresh];
end;

{ tlinkactionseditor }

function tlinkactionseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tlinkactionitemeditor;
end;

initialization
 register;
end.
