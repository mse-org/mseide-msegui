{ MSEide Copyright (c) 1999-2017 by Martin Schreiber

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
unit regwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msepropertyeditors,msestrings,sysutils;

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
   function itemprefix: msestring; override;
 end;
 
implementation
uses
 classes,mclasses,msesimplewidgets,msegrids,msemenus,mseimage,msedispwidgets,
 msetoolbar,msetabs,msedesignintf,regwidgets_bmp,mselistbrowser,mserichstring,
 msesplitter,msedock,mseforms,mseclasses,typinfo,msearrayprops,msewidgets,
 msegui,formdesigner,msedial,msemenuwidgets,msewindowwidget,msechart,
 msepolygon,msepickwidget,msetraywidget,msedockpanelform,msechartedit,mseedit,
 msebarcode,msedatalist,mseact,mseformatstr,msesizingform
 {$ifndef mse_no_opengl}
//  {$ifdef FPC}
     ,mseopenglwidget
   {$ifdef mse_with_openglcanvas}
     ,mseopenglcanvaswidget
//   {$endif}
  {$endif}
 {$endif};
 
type
 tpropertyeditor1 = class(tpropertyeditor);
 tdatacols1 = class(tdatacols);
 tfixcols1 = class(tfixcols);
 tfixrows1 = class(tfixrows);
 
 
type
 tfixgridpropeditor = class(tarrayelementeditor)
  public
   function name: msestring; override;
 end;
 
 tfixgridpropseditor = class(tgridpropseditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
 end;
   
 tfixrowseditor = class(tfixgridpropseditor)
  public
   function itemprefix: msestring; override;
 end;
 
 tfixcolseditor = class(tfixgridpropseditor)
  public
   function itemprefix: msestring; override;
 end;

 tcolheaderelementeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;

 tcolheaderspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
 tfixcolheaderspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   function getelementeditorclass: elementeditorclassty; override;
 end;

 ttraceeditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 ttraceseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;  
  public
 end;

 ttoolbuttoneditor = class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 ttoolbuttonseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;  
  public
 end;

 tcoloptionseditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 tgridoptionseditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;
 
 tframebuttoneditor = class(tclasspropertyeditor)
  protected
   function dispname: msestring; override;
 end;

 tframebuttonitemeditor = class(tclasselementeditor)
  public
   function dispname: msestring; override;
 end;
 
 tframebuttonseditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;  
  public
 end;

 toptionsplaceeditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

const
 mseformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createmseform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 sizingformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createsizingform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 mainformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createmainform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 dockpanelformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createdockpanelform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 subformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createsubform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 scrollboxformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createscrollboxform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);
 tabformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createtabform;
     initnewcomponent: nil; getscale: nil; sourcetoform: nil);

procedure Register;
begin
 registerclass(tmseform);
 registerclass(tdockform);
 registerclass(tsubform);
 registerclass(tdockpanelform);
 registerclass(tscrollboxform);
 registerclass(tsizingform);
 
 registercomponents('Widget',[
  tlabel,ticon,
  tstringdisp,trichstringdisp,tintegerdisp,tint64disp,trealdisp,tdatetimedisp,
  tbytestringdisp,tbooleandisp,
  tedit,
  tbutton,trichbutton,tstockglyphbutton,trichstockglyphbutton,
  tsimplewidget,teventwidget,
  tgroupbox,tscrollbox,tstepbox,tdockpanel,tdockhandle,tmseformwidget,
  tdockformwidget,
  texpandingwidget,tsplitter,tspacer,tlayouter,
  tmainmenuwidget,
  ttoolbar,
  ttabbar,ttabwidget,ttabpage,
  tdrawgrid,tstringgrid,tlistview,
  tpaintbox,tpolygon,tpickwidget,timage,tbarcode,
  tdial,tchart,txychartedit,txserieschartedit,tchartrecorder,
  twindowwidget
   {$ifndef mse_no_opengl}
    {$ifdef FPC}
     ,topenglwidget
     {$ifdef mse_with_openglcanvas}
      ,topenglcanvaswidget
     {$endif}
    {$endif}
   {$endif}
  ,ttraywidget,tdockpanelformcontroller
  ]);
 registercomponenttabhints(['Widget'],
         ['Display widgets, edit widgets which can''t be placed into twidgetgrid']);
 registerpropertyeditor(typeinfo(tcellframe),nil,'',
                            toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(tdatacols),nil,'',tdatacolseditor);
 registerpropertyeditor(typeinfo(tfixcols),nil,'',tfixcolseditor);
 registerpropertyeditor(typeinfo(tfixrows),nil,'',tfixrowseditor);
 registerpropertyeditor(typeinfo(tfixcolheaders),nil,'',
                             tfixcolheaderspropertyeditor);
 registerpropertyeditor(typeinfo(integer),tcolheader,'mergecols',
                             tvolatileordinalpropertyeditor);
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

 registerpropertyeditor(typeinfo(twidget),tlayouter,'linkleft',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tlayouter,'linktop',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tlayouter,'linkright',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tlayouter,'linkbottom',
                                 tsisterwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tlayouter,'align_leader',
                                 tchildwidgetpropertyeditor);
 registerpropertyeditor(typeinfo(placeoptionsty),tlayouter,'place_options',
                                 toptionsplaceeditor);

// registerpropertyeditor(typeinfo(tface),tdial,'',toptionalclasspropertyeditor);
 registerpropertyeditor(typeinfo(ttraces),nil,'',ttraceseditor);
 registerpropertyeditor(typeinfo(ttoolbuttons),nil,'',ttoolbuttonseditor);
 registerpropertyeditor(typeinfo(trealdatalist),ttrace,'',
                                toptionaldatalistpropertyeditor);
 
 registerpropertyeditor(typeinfo(boolean),tcustombutton,'visible',
                           trefreshbooleanpropertyeditor);
 registerpropertyeditor(typeinfo(boolean),tcustombutton,'enabled',
                           trefreshbooleanpropertyeditor);
 registerpropertyeditor(typeinfo(coloptionsty),nil,'',
                                           tcoloptionseditor);
 registerpropertyeditor(typeinfo(optionsgridty),nil,'',
                                           tgridoptionseditor);
 registerpropertyeditor(typeinfo(tframebutton),nil,'',
                                           tframebuttoneditor);
 registerpropertyeditor(typeinfo(tframebuttons),nil,'',
                                           tframebuttonseditor);
 registerpropertyeditor(typeinfo(msestring),tcustomrichstringdisp,'value',
                                           trichstringpropertyeditor);

 registerpropertyeditor(typeinfo(labeloptionsty),tcustomlabel,'',
                                           tvolatilesetpropertyeditor);
  
 registerunitgroup(['msegrids'],['msegui','msegraphutils','mseclasses']);
 registerunitgroup(['msewidgetgrid'],['msedataedits',
                    'msegui','msegraphutils','mseclasses']);
                    
 registerdesignmoduleclass(tmseform,@mseformintf);
 registerdesignmoduleclass(tsizingform,@sizingformintf);
 registerdesignmoduleclass(tmainform,@mainformintf);
 registerdesignmoduleclass(tdockform,@mseformintf);
 registerdesignmoduleclass(tdockpanelform,@dockpanelformintf);
 registerdesignmoduleclass(tsubform,@subformintf);
 registerdesignmoduleclass(tscrollboxform,@scrollboxformintf);
 registerdesignmoduleclass(ttabform,@tabformintf);
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
// result:= 'Item '+inttostr(findex - tarrayprop(tpropertyeditor1(fparenteditor).getordvalue).count);
 result:= tpersistentarraypropertyeditor(fparenteditor).itemprefix+
                         inttostrmse(-findex - 1);
end;

{ tfixgridpropseditor }

function tfixgridpropseditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tfixgridpropeditor;
end;

{ tdatacoleditor }

function tdatacoleditor.getvalue: msestring;
begin
 result:= msestring('<'+tdatacol(getpointervalue).name+'>');
end;

{ tdatacolseditor }

function tdatacolseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tdatacoleditor;
end;
(*
procedure tdatacolseditor.move(const curindex: integer;
               const newindex: integer);
var
 int1: integer;
begin
 inherited;
 {
 for int1:= 0 to high(fprops) do begin
  with tdatacols1(getordvalue(int1)) do begin
   move(curindex,newindex);
//   tfixrows1(fgrid.fixrows).movecol(curindex,newindex);
  end;   
 end;
 }
end;

*)

function tdatacolseditor.itemprefix: msestring;
begin
 result:= 'Col ';
end;

{ tfixcolseditor }

function tfixcolseditor.itemprefix: msestring;
begin
 result:= 'Col ';
end;

{ tcolheaderelementeditor }

function tcolheaderelementeditor.getvalue: msestring;
begin
 result:= '<'+tcolheader(getpointervalue).caption+'>';
end;

{ tcolheaderspropertyeditor }

function tcolheaderspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tcolheaderelementeditor;
end;

{ tfixcolheaderspropertyeditor }

function tfixcolheaderspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tcolheaderelementeditor;
end;

function tfixcolheaderspropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tfixgridpropeditor;
end;

{ tfixrowseditor }

function tfixrowseditor.itemprefix: msestring;
begin
 result:= 'Row ';
end;

{ ttraceeditor }

function ttraceeditor.getvalue: msestring;
begin
 result:= msestring('<'+ttrace(getpointervalue).name+'>');
end;

{ ttraceseditor }

function ttraceseditor.geteditorclass: propertyeditorclassty;
begin
 result:= ttraceeditor;
end;

{ ttoolbuttoneditor }

function ttoolbuttoneditor.getvalue: msestring;
begin
 with ttoolbutton(getpointervalue) do begin
  if mao_separator in options then begin
   result:= '<---->';
  end
  else begin
   if action <> nil then begin
    result:= msestring('<'+action.name+'>');
   end
   else begin
    result:= '<>';
   end;
  end;
 end;
end;

{ ttoolbuttonseditor }

function ttoolbuttonseditor.geteditorclass: propertyeditorclassty;
begin
 result:= ttoolbuttoneditor;
end;

{ tcoloptionseditor }

function tcoloptionseditor.getinvisibleitems: tintegerset;
begin
 result:= invisiblecoloptions;
end;

{ tgridoptionseditor }

function tgridoptionseditor.getinvisibleitems: tintegerset;
begin
 result:= invisibleoptionsgrid;
end;

{ tframebuttoneditor }

function tframebuttoneditor.dispname(): msestring;
begin
 with tframebutton(getpointervalue()) do begin
  if action <> nil then begin
   result:= msestring(action.name);
  end
  else begin
   result:= inherited dispname();
  end;
 end;
end;

{ tframebuttonitemeditor }

function tframebuttonitemeditor.dispname: msestring;
begin
 with tframebutton(getpointervalue()) do begin
  if action <> nil then begin
   result:= msestring(action.name);
  end
  else begin
   result:= inherited dispname();
  end;
 end;
end;

{ tframebuttonseditor }

function tframebuttonseditor.geteditorclass: propertyeditorclassty;
begin
 result:= tframebuttonitemeditor;
end;

{ toptionsplaceeditor }

function toptionsplaceeditor.getinvisibleitems: tintegerset;
begin
 result:= invisibleplaceoptions;
end;

initialization
 register;
end.


