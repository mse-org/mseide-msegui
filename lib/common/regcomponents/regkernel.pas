{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regkernel;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

implementation

uses
 classes,mseguithread,msebitmap,msetimer,msestat,mseactions,mseshapes,
 msedesignintf,msepropertyeditors,msemenus,msegui,msepipestream,sysutils,
 msegraphutils,regkernel_bmp,msegraphics,msestrings,msepostscriptprinter,
 mseprinter,msetypes,msedatalist;

type
 twidget1 = class(twidget);
 tactivator1 = class(tactivator);

 tactionpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 tshapestatespropertyeditor = class(tsetpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 tbounds_xeditor = class(tordinalpropertyeditor)
  public
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;

 tbounds_yeditor = class(tordinalpropertyeditor)
  public
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;

 tframepropertyeditor = class(toptionalclasspropertyeditor)
  public
   procedure edit; override;
 end;
 
 tactivatorclientspropertyeditor = class(tarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   procedure itemmoved(const source,dest: integer); override;
   function allequal: boolean; override;
  public
   function getvalue: msestring; override;
   function name: msestring; override;
   procedure setvalue(const value: msestring); override;
   function subproperties: propertyeditorarty; override;
 end;
 
procedure Register;
begin
 registercomponents('Gui',[tthreadcomp,tpipereadercomp,tbitmapcomp,timagelist,
                    ttimer,tstatfile,taction,tfacecomp,tframecomp,
                    tpostscriptprinter,tactivator]);
 registercomponents('Dialog',[tpagesizeselector,tpageorientationselector]);
 registerpropertyeditor(typeinfo(tcustomaction),nil,'',tactionpropertyeditor);
 registerpropertyeditor(typeinfo(string),tfont,'name',tfontnamepropertyeditor);
 registerpropertyeditor(typeinfo(actionstatesty),nil,'',tshapestatespropertyeditor);
 registerpropertyeditor(typeinfo(shortcutty),nil,'',tshortcutpropertyeditor);
 registerpropertyeditor(typeinfo(tcollection),nil,'',tcollectionpropertyeditor);
 registerpropertyeditor(typeinfo(tmenuitems),nil,'',tmenuarraypropertyeditor);
 registerpropertyeditor(typeinfo(tcustomframe),twidget,'frame',tframepropertyeditor);
 registerpropertyeditor(typeinfo(tcustomface),twidget,'face',
                             toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tparentfont),nil,'',
                             tparentfontpropertyeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_x',tbounds_xeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_y',tbounds_yeditor);
 registerpropertyeditor(typeinfo(tfacetemplate),tcustommenu,'facetemplate',
                           toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tfacetemplate),tmainmenu,'popupfacetemplate',
                           toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(integer),tactivator,'clients',
                         tactivatorclientspropertyeditor);
end;

{ tactionpropertyeditor }

function tactionpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_volatile];
end;

{ tshapestatespropertyeditor }

function tshapestatespropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_volatile,ps_refresh];
end;

{ tbounds_xeditor }

function tbounds_xeditor.getvalue: msestring;
begin
 if fprops[0].instance = fmodule then begin
  result:= inttostr(twidget(fprops[0].instance).screenpos.x);
 end
 else begin
  result:= inherited getvalue;
 end;
end;

procedure tbounds_xeditor.setvalue(const value: msestring);
begin
 if fprops[0].instance = fmodule then begin
  fdesigner.setmodulex(fmodule,strtoint(value));
 end
 else begin
  inherited;
 end;
end;

{ tbounds_yeditor }

function tbounds_yeditor.getvalue: msestring;
begin
 if fprops[0].instance = fmodule then begin
  result:= inttostr(twidget(fprops[0].instance).screenpos.y);
 end
 else begin
  result:= inherited getvalue;
 end;
end;

procedure tbounds_yeditor.setvalue(const value: msestring);
begin
 if fprops[0].instance = fmodule then begin
  fdesigner.setmoduley(fmodule,strtoint(value));
 end
 else begin
  inherited;
 end;
end;

{ tframepropertyeditor }

procedure tframepropertyeditor.edit;
begin
 inherited;
 if fprops[0].instance is twidget then begin
  twidget1(fprops[0].instance).clientrectchanged;
 end;
end;


{ tactivatorclientspropertyeditor }

function tactivatorclientspropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + 
         [ps_subproperties,ps_noadditems,ps_nodeleteitems{,ps_volatile}];
end;

function tactivatorclientspropertyeditor.getvalue: msestring;
begin
 result:= ''
end;

procedure tactivatorclientspropertyeditor.setvalue(const value: msestring);
begin
 //dummy
end;

function tactivatorclientspropertyeditor.subproperties: propertyeditorarty;
var
 int1: integer;
 ar1: stringarty;
begin
 with tactivator1(fprops[0].instance) do begin
  updateorder;
  fclientnames:= nil;
  ar1:= getclientnames;
  setlength(result,length(fclients));
  for int1:= 0 to high(result) do begin
   result[int1]:= tconstelementeditor.create(ar1[int1],
         int1,self,geteditorclass,fdesigner,fobjectinspector,fprops,ftypeinfo);
  end;
 end;
end;

function tactivatorclientspropertyeditor.name: msestring;
begin
 result:= 'clients';
end;

procedure tactivatorclientspropertyeditor.itemmoved(const source: integer;
                        const dest: integer);
begin
 moveitem(tactivator1(fprops[0].instance).fclients,source,dest);
 modified;
end;

function tactivatorclientspropertyeditor.allequal: boolean;
begin
 result:= false;
end;

initialization
 register;
end.
