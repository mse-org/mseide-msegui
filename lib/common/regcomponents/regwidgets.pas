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

implementation
uses
 sysutils,classes,msesimplewidgets,msegrids,msemenus,mseimage,msedispwidgets,
 msetoolbar,msetabs,msedesignintf,msepropertyeditors,regwidgets_bmp,
 msesplitter,msedock,mseforms,mseclasses,typinfo,msestrings,msearrayprops,
 msegui;
 
type
 tpropertyeditor1 = class(tpropertyeditor);
 
 tgridpropseditor = class(tpersistentarraypropertyeditor)
  protected
   procedure itemmoved(const source,dest: integer); override;
 end;
 
 tfixgridpropeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;
 
 tfixgridpropseditor = class(tgridpropseditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
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
 registerpropertyeditor(typeinfo(tdatacols),nil,'',tgridpropseditor);
 registerpropertyeditor(typeinfo(tfixcols),nil,'',tfixgridpropseditor);
 registerpropertyeditor(typeinfo(tfixrows),nil,'',tfixgridpropseditor);
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
begin
 inherited;
 if fprops[0].instance is tcustomgrid then begin
  tcustomgrid(fprops[0].instance).layoutchanged;
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

initialization
 register;
end.


