{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regeditwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

implementation
uses
 Classes,mseedit,msedataedits,msegraphedits,{msestringlistedit,}mselistbrowser,
 msewidgetgrid,msetextedit,msedesignintf,regeditwidgets_bmp,msepropertyeditors,
 msedropdownlist,mseterminal,msedrawtext,msedatanodes;

type
 tdropdowncolpropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 titemlistpropertyeditor = class(tdatalistpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;
                        
procedure Register;
begin
 registercomponents('Edit',[tedit,tslider,tbooleanedit,tbooleaneditradio,
   tintegerbutton,tdataicon,tpointeredit,
   tstringedit,tdropdownlistedit,thistoryedit,thexstringedit,tmemoedit,
   tintegeredit,trealedit,tdatetimeedit,tcalendardatetimeedit,tkeystringedit,
   tenumedit,tenumtypeedit,tselector,
   {tstringlistedit,}
   tlistview,titemedit,tdropdownitemedit,tmbdropdownitemedit,ttreeitemedit,
   trecordfieldedit,
   twidgetgrid,ttextedit,tterminal]);
 registerpropertyeditor(tdropdowncols.classinfo,nil,'',tdropdowncolpropertyeditor);
 registerpropertyeditor(ttabulators.classinfo,ttextedit,'tabulators',
            toptionalpersistentarraypropertyeditor);
 registerpropertyeditor(tcustomitemlist.classinfo,nil,'',titemlistpropertyeditor);
end;

{ tdropdowncolpropertyeditor }

function tdropdowncolpropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmsestringdatalistpropertyeditor;
end;

{ titemlistpropertyeditor }

function titemlistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate - [ps_dialog];
end;

initialization
 register;
end.
