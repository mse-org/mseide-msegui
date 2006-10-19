{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msepropertyeditors,msestrings;
 
type
 tgridpropseditor = class(tpersistentarraypropertyeditor)
  protected
   procedure itemmoved(const source,dest: integer); override;
 end;
 
 tdatacoleditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tdatacolseditor = class(tgridpropseditor)
  protected
   function geteditorclass: propertyeditorclassty; override;  
  public
   procedure move(const curindex,newindex: integer); override;
 end;
 
implementation
uses
 sysutils,classes,msesimplewidgets,msegrids,msemenus,mseimage,msedispwidgets,
 msetoolbar,msetabs,msedesignintf,regwidgets_bmp,
 msesplitter,msedock,mseforms,mseclasses,typinfo,msearrayprops,
 msegui;
 
type
 tpropertyeditor1 = class(tpropertyeditor);
 tdatacols1 = class(tdatacols);
 tfixrows1 = class(tfixrows);
 
 
 tfixgridpropeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;
 
 tfixgridpropseditor = class(tgridpropseditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
 end;
   
 tcolheaderelementeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tcolheaderspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
procedure Register;
begin
 registercomponents('Widget',[teventwidget,tbutton,tstockglyphbutton,
  tdrawgrid,tstringgrid,tmainmenu,
  tpopupmenu,tlabel,tpaintbox,timage,tintegerdisp,trealdisp,tdatetimedisp,
  tstringdisp,
  tbytestringdisp,tbooleandisp,
  tgroupbox,tscrollbox,tstepbox,tdockpanel,tdockhandle,tmseformwidget,
  tdockformwidget,
  tsplitter,tspacer,ttoolbar,{tdocktoolbar,}ttabbar,ttabwidget,ttabpage]);
 registerpropertyeditor(typeinfo(tcellframe),nil,'',
                            toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tdatacols),nil,'',tdatacolseditor);
 registerpropertyeditor(typeinfo(tfixcols),nil,'',tfixgridpropseditor);
 registerpropertyeditor(typeinfo(tfixrows),nil,'',tfixgridpropseditor);
 registerpropertyeditor(typeinfo(tcolheaders),nil,'',tcolheaderspropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tsplitter,'linkleft',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tsplitter,'linktop',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tsplitter,'linkright',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tsplitter,'linkbottom',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tspacer,'linkleft',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tspacer,'linktop',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tspacer,'linkright',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tspacer,'linkbottom',
                                 tsisterwidgetpropertyeditor);
 
 registerunitgroup(['msegrids'],['msegui','msegraphutils','mseclasses']);
 registerunitgroup(['msewidgetgrid'],['msedataedits',
                    'msegui','msegraphutils','mseclasses']);
end;


{ tgridpropseditor }

procedure tgridpropseditor.itemmoved(const source,dest: integer);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   if instance is tcustomgrid then begin
    tcustomgrid(instance).layoutchanged;
   end;
  end;
 end;
end;

{ tfixgridpropeditor }

function tfixgridpropeditor.name: msestring;
begin
 result:= 'Item '+inttostr(findex - tarrayprop(tpropertyeditor1(fparenteditor).getordvalue).count);
end;

{ tfixgridptopseditor }

function tfixgridpropseditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tfixgridpropeditor;
end;

{ tdatacoleditor }

function tdatacoleditor.getvalue: msestring;
begin
 result:= '<'+tdatacol(getordvalue).name+'>';
end;

{ tdatacolseditor }

function tdatacolseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tdatacoleditor;
end;

procedure tdatacolseditor.move(const curindex: integer;
               const newindex: integer);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with tdatacols1(getordvalue(int1)) do begin
   move(curindex,newindex);
   tfixrows1(fgrid.fixrows).movecol(curindex,newindex);
  end;   
 end;
end;

{ tcolheaderelementeditor }

function tcolheaderelementeditor.getvalue: msestring;
begin
 result:= '<'+tcolheader(getordvalue).caption+'>';
end;

{ tcolheaderspropertyeditor }

function tcolheaderspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tcolheaderelementeditor;
end;

initialization
 register;
end.


