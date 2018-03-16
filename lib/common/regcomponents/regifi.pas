{ MSEide Copyright (c) 1999-2014 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 mseglob,classes,mseificomp,msedesignintf,regifi_bmp,msepropertyeditors,
 mseclasses,
 msecomponenteditors,mseificomponenteditors,msetypes{msestrings},msedatalist,
 {$ifndef mse_no_db}{$ifdef FPC}mseifidbcomp,{$endif}{$endif}
 mseifidialogcomp,mseifigui,mseifiendpoint,
 typinfo,mseififieldeditor;
    
type
 tificonnectedfields1 = class(tificonnectedfields);
{
 tifiwidgeteditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;
}
 tifidropdowncolpropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tificolitempropertyeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tifilinkcomparraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tififieldnamepropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function getvalues: msestringarty; override;
 end;
  
 tifisourcefieldnamepropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure setvalue(const value: msestring); override;
   function getvalues: msestringarty; override;
 end;

 tifidataconnectionpropertyeditor = class(tcomponentinterfacepropertyeditor)
  protected
   function getintfinfo: ptypeinfo; override;
 end;

 tificonnectedfieldselementeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tificonnectedfieldspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;
 
procedure register;
begin
 registercomponents('ifi',[tifiintegerendpoint,tifiint64endpoint,
       tifibooleanendpoint,tifirealendpoint,tifidatetimeendpoint,
       tifistringendpoint,tifiactionendpoint,
       tifiintegerlinkcomp,tifiint64linkcomp,
       tifibooleanlinkcomp,
       tifireallinkcomp,tifidatetimelinkcomp,tifistringlinkcomp,
       tifienumlinkcomp,tifidropdownlistlinkcomp,
       tifiactionlinkcomp,tififormlinkcomp,
       tifidialoglinkcomp,tifidialog,
       tifigridlinkcomp,
       tconnectedifidatasource{,tifisqldatasource,}
       {$ifndef mse_no_db}{$ifdef FPC},tifisqlresult{$endif}{$endif}]);
 registercomponenttabhints(['ifi'],
   ['MSEifi and socket components.'+lineend+
   'Please compile with -dmse_with_pascalscript for PascalScript components.']);
// registerpropertyeditor(typeinfo(tcomponent),tcustomificlientcontroller,
//                                               'widget',tifiwidgeteditor);
 registercomponenteditor(tifilinkcomp,tifilinkcompeditor);
 registerpropertyeditor(typeinfo(tifidropdowncols),nil,'',
                                          tifidropdowncolpropertyeditor);
 registerpropertyeditor(typeinfo(tifilinkcomparrayprop),nil,'',
                                          tifilinkcomparraypropertyeditor);
 registerpropertyeditor(typeinfo(ififieldnamety),nil,'',
                                          tififieldnamepropertyeditor);
 registerpropertyeditor(typeinfo(ifisourcefieldnamety),nil,'',
                                          tifisourcefieldnamepropertyeditor);
 registerpropertyeditor(typeinfo(tificonnectedfields),nil,'',
                                          tificonnectedfieldspropertyeditor);
 registerpropertyeditor(typeinfo(tmsecomponent),tifidatasource,'connection',
                                 tifidataconnectionpropertyeditor);
end;

{ tifiwidgeteditor }
{
function tifiwidgeteditor.filtercomponent(
                                    const acomponent: tcomponent): boolean;
var
 intf1: pointer;
begin
// result:= tcustomifivaluewidgetcontroller(
//                    fprops[0].instance).canconnect(acomponent);
end;
}
{ tifidropdowncolpropertyeditor }

function tifidropdowncolpropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmsestringdatalistpropertyeditor;
end;

{ tificolitempropertyeditor }

function tificolitempropertyeditor.getvalue: msestring;
var
 obj1: tificolitem;
begin
 result:= '<nil>';
 obj1:= tificolitem(getpointervalue);
 if (obj1 <> nil) and (obj1.link <> nil) then begin
  result:= msestring('<'+obj1.link.name+'>');
 end;
end;

{ tifilinkcomparraypropertyeditor }

function tifilinkcomparraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tificolitempropertyeditor;
end;

{ tififieldnamepropertyeditor }

function tififieldnamepropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_sortlist];
end;

function tififieldnamepropertyeditor.getvalues: msestringarty;
var
 intf1: iififieldinfo;
 intf2: iififieldsource;
 dataso: tifidatasource;
 types: listdatatypesty;
begin
 result:= nil;
 if getcorbainterface(fprops[0].instance,typeinfo(iififieldinfo),
                                                              intf1) then begin
  dataso:= nil;
  types:= [];
  intf1.getfieldinfo(ansistring(fname),dataso,types);
  if (dataso <> nil) and getcorbainterface(dataso,typeinfo(iififieldsource),
                                                              intf2) then begin
   result:= intf2.getfieldnames(types);
  end;
 end;
end;

{ tifisourcefieldnamepropertyeditor }

function tifisourcefieldnamepropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_sortlist,ps_volatile];
end;

function tifisourcefieldnamepropertyeditor.getvalues: msestringarty;
var
 intf1: iififieldlinksource;
begin
 result:= nil;
 if getcorbainterface(fprops[0].instance,
                                typeinfo(iififieldlinksource),intf1) then begin
  result:= intf1.getfieldnames(ansistring(fname));
 end;
end;

procedure tifisourcefieldnamepropertyeditor.setvalue(const value: msestring);
var
 intf1: iififieldlinksource;
begin
 inherited;
 if getcorbainterface(fprops[0].instance,
                                typeinfo(iififieldlinksource),intf1) then begin
  intf1.setdesignsourcefieldname(ansistring(value));
 end;
end;

{ tifidataconnectionpropertyeditor }

function tifidataconnectionpropertyeditor.getintfinfo: ptypeinfo;
begin
 result:= typeinfo(iifidataconnection);
end;

{ tificonnectedfieldselementeditor }

function tificonnectedfieldselementeditor.getvalue: msestring;
begin
 with tififieldlink(getpointervalue) do begin
  result:= msestring('<'+sourcefieldname+'><'+fieldname+'>');
 end;
end;

{ tificonnectedfieldspropertyeditor }

function tificonnectedfieldspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tificonnectedfieldselementeditor;
end;

function tificonnectedfieldspropertyeditor.getdefaultstate: propertystatesty;
var
 po1: pointer;
begin
 result:= inherited getdefaultstate();
 if mseclasses.getcorbainterface(
             tificonnectedfields1(getpointervalue).fowner.connection,
                       typeinfo(iifidbdataconnection),po1) then begin

  result:= result + [ps_dialog];
 end;
end;

procedure tificonnectedfieldspropertyeditor.edit;
begin
 if editififields(tificonnectedfields(getpointervalue)) then begin
  modified;
 end;
end;

initialization
 register;
end.
