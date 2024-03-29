{ MSEide Copyright (c) 1999-2018 by Martin Schreiber

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
unit regkernel;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 typinfo,msepropertyeditors;

implementation
uses
 classes,mclasses,msethreadcomp,msebitmap,msetimer,msestatfile,mseact,
 mseactions,mseshapes,msewidgets,mseindexlookupeditor,msecornermaskeditor,
 msedesignintf,msemenus,msegui,msepipestream,sysutils,mseassistivehandler,
 msegraphutils,regkernel_bmp,msegraphics,msestrings,msepostscriptprinter,
 mseprinter,msetypes,msedatalist,msedatamodules,mseclasses,formdesigner,
 mseapplication,mseglob,mseguiglob,mseskin,msedesigner,msemacros,
 mseguithreadcomp,mseprocmonitorcomp,msefadepropedit,mseguiprocess,
 msearrayprops,msesumlist,mserttistat,
 msestockobjects,
 regglob,msearrayutils,
 msecryptohandler,msestringcontainer,mseformatstr;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 twidget1 = class(twidget);
 tactivator1 = class(tactivator);
 tskincontroller1 = class(tskincontroller);
 tarrayelementeditor1 = class(tarrayelementeditor);

 temptysetpropertyeditor = class(tsetpropertyeditor)
  public
   procedure updatedefaultvalue; override;  //implicit [] default
 end;

 tactionpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 tshortcutactionpropertyeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;

 tshortcutactionspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tskincolorarraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function itemgetvalue(const sender: tarrayelementeditor): msestring;
                                                                    override;
 end;

 tlevelarrayelementeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;

 tlevelarraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
 end;

 tneglevelarrayelementeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;

 tneglevelarraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
 end;

 tactionstatespropertyeditor = class(tsetpropertyeditor)
  protected
   function getdefaultstate: propertystatesty override;
   function getinvisibleitems: tintegerset override;
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

 tbounds_sizeeditor = class(tordinalpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
 end;

 tframepropertyeditor = class(toptionalclasspropertyeditor)
  protected
   function dispname: msestring; override;
  public
   procedure edit; override;
 end;

 tactivatorclientspropertyeditor = class(tconstarraypropertyeditor)
  protected
   procedure itemmoved(const source,dest: integer); override;
  public
   function subproperties: propertyeditorarty; override;
 end;

 tskincontrollerextenderspropertyeditor = class(tconstarraypropertyeditor)
  protected
   procedure itemmoved(const source,dest: integer); override;
  public
   function subproperties: propertyeditorarty; override;
 end;

 tsysshortcutelementeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;

 tsysshortcutspropertyeditor = class(tconstarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   function getelementeditorclass: elementeditorclassty; override;
  public
 end;

 tassistiveshortcutelementeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;

 tassistiveshortcutspropertyeditor = class(tconstarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   function getelementeditorclass: elementeditorclassty; override;
  public
 end;

 tfacelocalpropseditor = class(temptysetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 tfacepropertyeditor = class(toptionalclasspropertyeditor)
  protected
   function dispname: msestring; override;
 end;

 tfaceelementeditor = class(tclasselementeditor)
  protected
   function dispname: msestring; override;
 end;

 tfacelistpropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tindexlookupeditor = class(tmsestringpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   procedure edit(); override;
 end;

 tcornermaskeditor = class(tmsestringpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   procedure edit(); override;
 end;

 tmacroseditor = class(tpersistentarraypropertyeditor)
  protected
   function itemgetvalue(const sender: tarrayelementeditor): msestring
                                                                  override;
 end;

 timagelistversioncounteditor = class(tordinalpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
end;

const
 datamoduleintf: designmoduleintfty =
  (createfunc: {$ifdef FPC}@{$endif}createmsedatamodule;
   initnewcomponent: nil; getscale: nil; sourcetoform: nil;
   );

procedure Register;
begin
 registerclass(tmsedatamodule);
 registercomponents('Gui',[tmainmenu,tpopupmenu,
                    tfacecomp,tfacelist,tframecomp,tfontcomp,tskincontroller,
//                    tskinextender,
                    tbitmapcomp,timagelist,tshortcutcontroller,thelpcontroller,
                    tguiprocess,
                    taction,tguithreadcomp,tassistivehandler,
                    tassistivewidgetitem]);
 registercomponenttabhints(['Gui'],['Non visual components with GUI dependence']);

 registercomponents('NoGui',[tstatfile,trttistat,tnoguiaction,tactivator,
                    ttimer,tanimtimer,tanimitemcomp,tthreadcomp,tpipereadercomp,
                    tprocessmonitor,
                    tstringcontainer,tkeystringcontainer]);
 registercomponenttabhints(['NoGui'],['Components without GUI dependence']);

 registerpropertyeditor(typeinfo(fontlocalpropsty),nil,'',
                                                    temptysetpropertyeditor);
 registerpropertyeditor(typeinfo(framelocalpropsty),nil,'',
                                                    temptysetpropertyeditor);
 registerpropertyeditor(typeinfo(framelocalprops1ty),nil,'',
                                                    temptysetpropertyeditor);
 registerpropertyeditor(typeinfo(facelocalpropsty),nil,'',
                                           tfacelocalpropseditor);

 registerpropertyeditor(typeinfo(tskincolors),nil,'',
                                                 tskincolorarraypropertyeditor);
 registerpropertyeditor(typeinfo(tstatfile),tstatfile,'',
                                      tlinkcomponentpropertyeditor);

 registerpropertyeditor(typeinfo(tcustomframe),nil,'',tframepropertyeditor);
 registerpropertyeditor(typeinfo(tcustomface),nil,'',tfacepropertyeditor);

 registerpropertyeditor(typeinfo(tfacearrayprop),nil,'',tfacelistpropertyeditor);
 registerpropertyeditor(typeinfo(tcustomaction),nil,'',tactionpropertyeditor);
 registerpropertyeditor(typeinfo(tshortcutactions),nil,'',
                           tshortcutactionspropertyeditor);
 registerpropertyeditor(typeinfo(tcolorarrayprop),tcustomface,'fade_color',
                                    tfacefadecoloreditor);
 registerpropertyeditor(typeinfo(trealarrayprop),tcustomface,'fade_pos',
                                    tfacefadeposeditor);
 registerpropertyeditor(typeinfo(tcolorarrayprop),tfacetemplate,'fade_color',
                                    tfacetemplatefadecoloreditor);
 registerpropertyeditor(typeinfo(trealarrayprop),tfacetemplate,'fade_pos',
                                    tfacetemplatefadeposeditor);

 registerpropertyeditor(typeinfo(tcolorarrayprop),tcustomface,'fade_opacolor',
                                    tfacefadeopacoloreditor);
 registerpropertyeditor(typeinfo(trealarrayprop),tcustomface,'fade_opapos',
                                    tfacefadeopaposeditor);
 registerpropertyeditor(typeinfo(tcolorarrayprop),tfacetemplate,'fade_opacolor',
                                    tfacetemplatefadeopacoloreditor);
 registerpropertyeditor(typeinfo(trealarrayprop),tfacetemplate,'fade_opapos',
                                    tfacetemplatefadeopaposeditor);

 registerpropertyeditor(typeinfo(int32),timagelist,'versioncount',
                                                timagelistversioncounteditor);
 registerpropertyeditor(typeinfo(msestring),timagelist,'cornermask_topleft',
                                                       tcornermaskeditor);
 registerpropertyeditor(typeinfo(msestring),timagelist,'cornermask_bottomleft',
                                                       tcornermaskeditor);
 registerpropertyeditor(typeinfo(msestring),timagelist,'cornermask_bottomright',
                                                       tcornermaskeditor);
 registerpropertyeditor(typeinfo(msestring),timagelist,'cornermask_topright',
                                                       tcornermaskeditor);
 registerpropertyeditor(typeinfo(msestring),timagelist,'indexlookup',
                                                       tindexlookupeditor);
 registerpropertyeditor(typeinfo(msestring),tfacelist,'indexlookup',
                                                       tindexlookupeditor);

 registerpropertyeditor(typeinfo(tsumdownarrayprop),nil,'',
                                    tlevelarraypropertyeditor);
 registerpropertyeditor(typeinfo(tsumuparrayprop),nil,'',
                                    tneglevelarraypropertyeditor);
 registerpropertyeditor(typeinfo(tsysshortcuts),nil,'',
                                                 tsysshortcutspropertyeditor);
 registerpropertyeditor(typeinfo(tassistiveshortcuts),nil,'',
                                            tassistiveshortcutspropertyeditor);
 registerpropertyeditor(typeinfo(string),tfont,'name',tfontnamepropertyeditor);
 registerpropertyeditor(typeinfo(actionstatesty),nil,'',
                                                   tactionstatespropertyeditor);
 registerpropertyeditor(typeinfo(shortcutty),nil,'',tshortcutpropertyeditor);
 registerpropertyeditor(typeinfo(imagenrty),nil,'',timagenrpropertyeditor);
 registerpropertyeditor(typeinfo(facenrty),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(tcollection),nil,'',tcollectionpropertyeditor);
 registerpropertyeditor(typeinfo(tmenuitems),nil,'',tmenuarraypropertyeditor);
 registerpropertyeditor(typeinfo(tcustomframe),nil,'',tframepropertyeditor);
 registerpropertyeditor(typeinfo(tcustomface),nil,'',
                             toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(toptionalfont),nil,'',
                             toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tparentfont),nil,'',
                             tparentfontpropertyeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_x',tbounds_xeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_y',tbounds_yeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cy',
                                                            tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cx',
                                                            tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cymin',
                                                     tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cxmin',
                                                     tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cymax',
                                                     tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(integer),twidget,'bounds_cxmax',
                                                     tbounds_sizeeditor);
 registerpropertyeditor(typeinfo(tfacetemplate),tcustommenu,'facetemplate',
                           toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tfacetemplate),tmainmenu,'popupfacetemplate',
                           toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(integer),tactivator,'clients',
                         tactivatorclientspropertyeditor);
 registerpropertyeditor(typeinfo(integer),tskincontroller,'extenders',
                         tskincontrollerextenderspropertyeditor);
 registerpropertyeditor(typeinfo(stockglyphty),nil,'',
                                      tstockglypheditor);
 registerpropertyeditor(typeinfo(tmacroproperty),nil,'',
                                    tmacroseditor);

 registerunitgroup(['msestatfile'],['msestat']);

 registerdesignmoduleclass(tmsedatamodule,@datamoduleintf);
end;

{ tactionpropertyeditor }

function tactionpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_volatile];
end;

{ tactionstatespropertyeditor }

function tactionstatespropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_volatile,ps_refresh];
end;

function tactionstatespropertyeditor.getinvisibleitems: tintegerset;
begin
 result:= invisibleactionstates;
end;

{ tbounds_xeditor }

function tbounds_xeditor.getvalue: msestring;
begin
 if fprops[0].instance = fmodule then begin
  result:= inttostrmse(fdesigner.getmodulex(fmodule));
//  result:= inttostr(twidget(fprops[0].instance).screenpos.x);
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
  result:= inttostrmse(fdesigner.getmoduley(fmodule));
//  result:= inttostr(twidget(fprops[0].instance).screenpos.y);
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

{ tbounds_sizeeditor }

procedure tbounds_sizeeditor.setvalue(const value: msestring);
begin
 inherited;
 fdesigner.modulesizechanged(fmodule);
end;

{ tframepropertyeditor }

function tframepropertyeditor.dispname: msestring;
begin
 with tcustomframe(getpointervalue) do begin
  if template <> nil then begin
   result:= msestring(template.name);
  end
  else begin
   result:= inherited dispname;
  end;
 end;
end;

procedure tframepropertyeditor.edit;
begin
 inherited;
 if fprops[0].instance is twidget then begin
  twidget1(fprops[0].instance).clientrectchanged;
 end;
end;

{ tactivatorclientspropertyeditor }

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
   result[int1]:= tconstelementeditor.create(msestring(ar1[int1]),
         int1,self,geteditorclass,fdesigner,fobjectinspector,fprops,ftypeinfo);
  end;
 end;
end;

procedure tactivatorclientspropertyeditor.itemmoved(const source: integer;
                        const dest: integer);
begin
 moveitem(tactivator1(fprops[0].instance).fclients,source,dest);
 modified;
end;

{ tskincontrollerextenderspropertyeditor }

function tskincontrollerextenderspropertyeditor.subproperties: propertyeditorarty;
var
 int1: integer;
 ar1: stringarty;
begin
 with tskincontroller1(fprops[0].instance) do begin
  updateorder;
  fextendernames:= nil;
  ar1:= getextendernames;
  setlength(result,length(fextenders));
  for int1:= 0 to high(result) do begin
   result[int1]:= tconstelementeditor.create(msestring(ar1[int1]),
         int1,self,geteditorclass,fdesigner,fobjectinspector,fprops,ftypeinfo);
  end;
 end;
end;

procedure tskincontrollerextenderspropertyeditor.itemmoved(const source: integer;
                        const dest: integer);
begin
 moveitem(pointerarty(tskincontroller1(fprops[0].instance).fextenders),
                        source,dest);
 modified;
end;

{ tsysshortcutelementeditor }

function tsysshortcutelementeditor.name: msestring;
begin
 result:= msestring(getenumname(typeinfo(sysshortcutty),findex));
end;

{ tsysshortcutspropertyeditor }

function tsysshortcutspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tshortcutpropertyeditor;
end;

function tsysshortcutspropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tsysshortcutelementeditor;
end;

{ tassistiveshortcutelementeditor }

function tassistiveshortcutelementeditor.name: msestring;
begin
 result:= msestring(getenumname(typeinfo(assistiveshortcutty),findex));
end;

{ tassistiveshortcutspropertyeditor }

function tassistiveshortcutspropertyeditor.geteditorclass():
                                                  propertyeditorclassty;
begin
 result:= tshortcutarpropertyeditor;
end;

function tassistiveshortcutspropertyeditor.getelementeditorclass():
                                                      elementeditorclassty;
begin
 result:= tassistiveshortcutelementeditor;
end;

{ tshortcutactionpropertyeditor }

function tshortcutactionpropertyeditor.getvalue: msestring;
var
 item1: tshortcutaction;
begin
 item1:= tshortcutaction(getpointervalue);
 if item1.action = nil then begin
  result:= '<--->';
 end
 else begin
  result:= '<'+getcomponentpropname(item1.action)+'>';
  {
  result:= '<';
  if item1.action.owner <> module then begin
   result:= result+module.name+'.';
  end;
  result:= result+designer.getcomponentdispname(item1.action)+'>';
  }
 end;
 result:= result + '<' + item1.dispname + '>';
end;

{ tshortcutactionspropertyeditor }

function tshortcutactionspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tshortcutactionpropertyeditor;
end;

{ tlevelarraypropertyeditor }

function tlevelarraypropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tlevelarrayelementeditor;
end;

{ tlevelarrayelementeditor }

function tlevelarrayelementeditor.name: msestring;
begin
 result:= 'Level ' + inttostrmse(findex+1);
end;

{ tneglevelarraypropertyeditor }

function tneglevelarraypropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tneglevelarrayelementeditor;
end;

{ tneglevelarrayelementeditor }

function tneglevelarrayelementeditor.name: msestring;
begin
 result:= 'Level ' + inttostrmse(-(findex+1));
end;

(*
{ tactionshortcutspropertyeditor }

constructor tactionshortcutspropertyeditor.create(const adesigner: idesigner;
               const amodule: tmsecomponent; const acomponent: tcomponent;
               const aobjectinspector: iobjectinspector;
               const aprops: propinstancearty; atypeinfo: ptypeinfo);
begin
 fsc1:=  aprops[0].propinfo^.name = 'shortcut1';
 inherited;
end;

procedure tactionshortcutspropertyeditor.setvalue(const value: msestring);
var
 ar1: msestringarty;
 ar2: shortcutarty;
 int1: integer;
begin
 ar1:= splitstring(value,widechar(' '));
 if high(ar1) > 0 then begin
  setlength(ar2,length(ar1));
  for int1:= 0 to high(ar1) do begin
   ar2[int1]:= texttovalue(ar1[int1]);
  end;
  for int1:= 0 to high(fprops) do begin
   if fprops[int1].instance is taction then begin
    with taction(fprops[int1].instance) do begin
     if fsc1 then begin
      shortcuts1:= ar2;
     end
     else begin
      shortcuts:= ar2;
     end;
    end;
   end
   else begin
    setordvalue(int1,0);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tactionshortcutspropertyeditor.getvalue: msestring;
var
 ar1: shortcutarty;
 int1: integer;
begin
 result:= '';
 with taction(fprops[0].instance) do begin
  if self.fsc1 then begin
   ar1:= shortcuts1;
  end
  else begin
   ar1:= shortcuts;
  end;
 end;
 result:= '';
 for int1:= 0 to high(ar1) do begin
  result:= result + getvaluetext(ar1[int1]) + ' ';
 end;
 if result <> '' then begin
  setlength(result,length(result)-1);
 end;
end;

{ tshortcutactionitempropertyeditor }

constructor tshortcutactionitempropertyeditor.create(const adesigner: idesigner;
               const amodule: tmsecomponent; const acomponent: tcomponent;
               const aobjectinspector: iobjectinspector;
               const aprops: propinstancearty; atypeinfo: ptypeinfo);
begin
 fsc1:=  aprops[0].propinfo^.name = 'shortcut1default';
 inherited;
end;

procedure tshortcutactionitempropertyeditor.setvalue(const value: msestring);
var
 ar1: msestringarty;
 ar2: shortcutarty;
 int1: integer;
begin
 ar1:= splitstring(value,widechar(' '));
 if high(ar1) > 0 then begin
  setlength(ar2,length(ar1));
  for int1:= 0 to high(ar1) do begin
   ar2[int1]:= texttovalue(ar1[int1]);
  end;
  for int1:= 0 to high(fprops) do begin
   if fprops[int1].instance is tshortcutaction then begin
    with tshortcutaction(fprops[int1].instance) do begin
     if fsc1 then begin
      shortcuts1default:= ar2;
     end
     else begin
      shortcutsdefault:= ar2;
     end;
    end;
   end
   else begin
    setordvalue(int1,0);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tshortcutactionitempropertyeditor.getvalue: msestring;
var
 ar1: shortcutarty;
 int1: integer;
begin
 result:= '';
 with tshortcutaction(fprops[0].instance) do begin
  if self.fsc1 then begin
   ar1:= shortcuts1default;
  end
  else begin
   ar1:= shortcutsdefault;
  end;
 end;
 result:= '';
 for int1:= 0 to high(ar1) do begin
  result:= result + getvaluetext(ar1[int1]) + ' ';
 end;
 if result <> '' then begin
  setlength(result,length(result)-1);
 end;
end;
*)
{ tfacelocalpropseditor }

function tfacelocalpropseditor.getinvisibleitems: tintegerset;
begin
 result:= invisiblefacelocalprops;
end;

{ tfaceeditor }

function tfacepropertyeditor.dispname: msestring;
begin
 with tcustomface(getpointervalue) do begin
  if template <> nil then begin
   result:= msestring(template.name);
  end
  else begin
   result:= inherited dispname;
  end;
 end;
end;

{ tfaceelementeditor }

function tfaceelementeditor.dispname: msestring;
begin
 with tcustomface(getpointervalue) do begin
  if template <> nil then begin
   result:= msestring(template.name);
  end
  else begin
   result:= inherited dispname;
  end;
 end;
end;

{ tfacelistpropertyeditor }

function tfacelistpropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tfaceelementeditor;
end;

{ temptysetpropertyeditor }

procedure temptysetpropertyeditor.updatedefaultvalue;
begin
 if getordvalue <> 0 then begin
  include(fstate,ps_modified);
 end
 else begin
  exclude(fstate,ps_modified);
 end;
end;

{ tskincolorarraypropertyeditor }

function tskincolorarraypropertyeditor.itemgetvalue(
              const sender: tarrayelementeditor): msestring;
begin
 result:= msestring('<'+colortostring(tskincolor(
            tarrayelementeditor1(sender).getpointervalue(0)).color) + '>');
end;

{ tindexlookupeditor }

procedure tindexlookupeditor.setvalue(const value: msestring);
begin
 if (value = '') and
      askyesno('Do you want to delete the lookup list?') then begin
  inherited setvalue('');
 end
 else begin
  inherited setvalue(getmsestringvalue(0));
 end;
end;

function tindexlookupeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 mstr1:= getmsestringvalue(0,true);
 if mstr1 = '' then begin
  result:= '<empty>';
 end
 else begin
  result:= '<'+inttostrmse(length(mstr1))+'>';
 end;
end;

procedure tindexlookupeditor.edit();
var
 mstr1: msestring;
 imagelist: timagelist;
 facelist: tfacelist;
begin
 mstr1:= getmsestringvalue(0,true);
 imagelist:= nil;
 facelist:= nil;
 if fcomponent is timagelist then begin
  pointer(imagelist):= fcomponent;
 end;
 if fcomponent is tfacelist then begin
  pointer(facelist):= fcomponent;
 end;
 if editlookupindex(mstr1,imagelist,facelist) then begin
  setmsestringvalue(mstr1,true);
 end;
end;

{ tcornermaskeditor }

procedure tcornermaskeditor.setvalue(const value: msestring);
begin
 if (value = '') and
      askyesno('Do you want to delete the corner mask?') then begin
  inherited setvalue('');
 end
 else begin
  inherited setvalue(getmsestringvalue(0));
 end;
end;

function tcornermaskeditor.getvalue: msestring;
var
 mstr1: msestring;
begin
 mstr1:= getmsestringvalue(0,true);
 if mstr1 = '' then begin
  result:= '<empty>';
 end
 else begin
  result:= '<'+inttostrmse(length(mstr1))+'>';
 end;
end;

procedure tcornermaskeditor.edit();
var
 mstr1: msestring;
begin
 mstr1:= getmsestringvalue(0,true);
 if editcornermask(mstr1) then begin
  setmsestringvalue(mstr1,true);
 end;
end;

{ tmacroseditor }

function tmacroseditor.itemgetvalue(
                     const sender: tarrayelementeditor): msestring;
begin
 with tstringlistmacroitem(
              tarrayelementeditor1(sender).getpointervalue) do begin
  result:= '<'+name+'>';
 end;
end;

{ timagelistversioncounteditor }

procedure timagelistversioncounteditor.setvalue(const value: msestring);
var
 int1: integer;
 va: integer;
begin
 va:= strtoint(value);
 if va < 0 then begin
  va:= 0;
 end;
 int1:= timagelist(fcomponent).versioncount;
 if not wantpropertydelete(va,int1-1) then begin
  exit;
 end;
 inherited;
end;

initialization
 register;
end.
