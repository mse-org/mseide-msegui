{ MSEide Copyright (c) 1999-2011 by Martin Schreiber

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
unit regeditwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 classes,mclasses,mseedit,msedataedits,msegraphedits,
 msedataimage,mselistbrowser,msecalendardatetimeedit,
 msewidgetgrid,msetextedit,msedesignintf,regeditwidgets_bmp,msepropertyeditors,
 msedropdownlist,mseterminal,msedrawtext,msedatanodes,{msedialog,}
 msetypes,msestrings,
 regwidgets,msearrayprops,typinfo,msestockobjects,msefoldedit,msebitmap,mseglob,
 msestream,mserealsumedit,msedatalist,msegui,msegrids,msesumlist,mseclasses,
 sysutils,regglob,msearrayutils,mseeditglob;

type
 tpropertyeditor1 = class(tpropertyeditor);
 tdropdowndatacolpropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 titemlistpropertyeditor = class(tdatalistpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 twidgetcolelementeditor = class(tdatacoleditor)
  public
   function getvalue: msestring; override;
 end;

 twidgetcolspropertyeditor = class(tdatacolseditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tdataimagepropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
   function getvalue: msestring; override;
 end;

 tdatalistsourcepropertyeditor = class(tstringpropertyeditor)
  protected
   function gettag: integer; virtual;
   function getdefaultstate: propertystatesty; override;
  public
   function getvalues: msestringarty; override;
 end;

 tsumlistsourcelevelpropertyeditor =
                   class(tdatalistsourcepropertyeditor)
  protected
   function gettag: integer; override;
  public
   function getvalues: msestringarty; override;
 end;

 tsumlistsourceissumpropertyeditor =
                   class(tdatalistsourcepropertyeditor)
  protected
   function gettag: integer; override;
 end;

 trowstatelistsourcefoldlevelpropertyeditor =
                   class(tdatalistsourcepropertyeditor)
  protected
   function gettag: integer; override;
 end;

 trowstatelistsourcefoldhiddenpropertyeditor =
                   class(tdatalistsourcepropertyeditor)
  protected
   function gettag: integer; override;
 end;

 trowstatelistsourceissumpropertyeditor =
                   class(tdatalistsourcepropertyeditor)
  protected
   function gettag: integer; override;
 end;

 toptionswidgetpropertyeditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 toptionseditpropertyeditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 tvalueeditpropertyeditor = class(tclasselementeditor)
  public
   procedure navigevent(); override;
 end;

 tvalueeditspropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
   function itemgetvalue(const sender: tarrayelementeditor): msestring;
                                                                   override;
//   function geteditorclass: propertyeditorclassty; override;
 end;

 titemvalueeditpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;

procedure Register;
begin
 registercomponents('Edit',[twidgetgrid,
   tstringedit,tmemoedit,trichmemoedit,
   tintegeredit,tint64edit,trealedit,trealspinedit,trealsumedit,
   tdatetimeedit,
   tcalendardatetimeedit,
   tbooleanedit,tbooleaneditradio,
   tdatabutton,tstockglyphdatabutton,
   tdataicon,tdataimage,
   tslider,tprogressbar,
   tfoldedit,
   titemedit,tdropdownitemedit,{tmbdropdownitemedit,}ttreeitemedit,
   trecordfieldedit,
   thexstringedit,tpointeredit,
   tdropdownlistedit,thistoryedit,
   tenumedit,tenumtypeedit,tselector,
   tkeystringedit,
   {tstringlistedit,}
   ttextedit,tundotextedit,tterminal
]);
 registercomponenttabhints(['Edit'],
 ['Edit widgets, twidgetgrid and widgets'+c_linefeed+
  'which can be placed into twidgetgrid']);
 registerpropertyeditor(tdropdowndatacols.classinfo,nil,'',
                                      tdropdowndatacolpropertyeditor);
 registerpropertyeditor(ttabulators.classinfo,tcustomtextedit,'tabulators',
            toptionalpersistentarraypropertyeditor);
 registerpropertyeditor(tcustomitemlist.classinfo,nil,'',
                                           titemlistpropertyeditor);
 registerpropertyeditor(typeinfo(twidgetcols),nil,'',twidgetcolspropertyeditor);
 registerpropertyeditor(typeinfo(tintegerarrayprop),tstockglyphdatabutton,'',
              tstockglypharraypropertyeditor);
 registerpropertyeditor(typeinfo(string),tdataimage,'value',
                                                  tdataimagepropertyeditor);
 registerpropertyeditor(typeinfo(tmaskedbitmap),tdataimage,'bitmap',
                                                  tclasspropertyeditor);
 registerpropertyeditor(typeinfo(string),tdatalist,'sourcevalue',
                                           tdatalistsourcepropertyeditor);
 registerpropertyeditor(typeinfo(string),trealsumlist,'sourcelevel',
                                      tsumlistsourcelevelpropertyeditor);
 registerpropertyeditor(typeinfo(string),trealsumlist,'sourceissum',
                                      tsumlistsourceissumpropertyeditor);
 registerpropertyeditor(typeinfo(optionswidgetty),nil,'',
                                           toptionswidgetpropertyeditor);
 registerpropertyeditor(typeinfo(optionseditty),nil,'',
                                           toptionseditpropertyeditor);
 registerpropertyeditor(typeinfo(string),trowstatelist,'sourcefoldlevel',
                                 trowstatelistsourcefoldlevelpropertyeditor);
 registerpropertyeditor(typeinfo(string),trowstatelist,'sourcefoldhidden',
                                 trowstatelistsourcefoldhiddenpropertyeditor);
 registerpropertyeditor(typeinfo(string),trowstatelist,'sourceissum',
                                 trowstatelistsourceissumpropertyeditor);
 registerpropertyeditor(typeinfo(boolean),tcustomdatabutton,'visible',
                           trefreshbooleanpropertyeditor);
 registerpropertyeditor(typeinfo(boolean),tcustomdatabutton,'enabled',
                           trefreshbooleanpropertyeditor);
 registerpropertyeditor(typeinfo(tvalueedits),nil,'',tvalueeditspropertyeditor);
 registerpropertyeditor(typeinfo(twidget),tvalueedititem,'',
                           titemvalueeditpropertyeditor);
 registerpropertyeditor(typeinfo(msestring),tcustomrichmemoedit,'value',
                                           trichstringpropertyeditor);
end;

{ tdropdowndatacolpropertyeditor }

function tdropdowndatacolpropertyeditor.geteditorclass: propertyeditorclassty;
var
 obj1: tobject;
begin
 pointer(obj1):= getpointervalue();
 if (obj1 is tdropdowncols) and tdropdowncols(obj1).nostreaming then begin
  result:= tclasselementeditor;
 end
 else begin
  result:= tmsestringdatalistpropertyeditor;
 end;
end;

{ titemlistpropertyeditor }

function titemlistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate - [ps_dialog];
end;

{ twidgetcolelementeditor }

function twidgetcolelementeditor.getvalue: msestring;
var
 col1: twidgetcol;
begin
 col1:= twidgetcol(getpointervalue);
 result:= inherited getvalue;
 if col1.editwidget <> nil then begin
  result:= result + msestring('<'+col1.editwidget.name+'>');
 end
 else begin
  result:= result + '<>';
 end;
end;

{ twidgetcolspropertyeditor }

function twidgetcolspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= twidgetcolelementeditor;
end;

{ tdataimagepropertyeditor }

function tdataimagepropertyeditor.getvalue: msestring;
begin
 if tcustomdataimage(fcomponent).bitmap.isempty then begin
  result:= '<empty>';
 end
 else begin
  result:= '<image>';
 end;
end;

function tdataimagepropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tdataimagepropertyeditor.edit;
var
 mstr1: filenamety;
 format1: string;
 int1: integer;
begin
 if imagefilepropedit(mstr1,format1) = mr_ok then begin
  for int1:= 0 to high(fprops) do begin
   tdataimage(fprops[int1].instance).value:= readfiledatastring(mstr1);
  end;
  modified;
 end;
end;

{ tdatalistsourcepropertyeditor }

function tdatalistsourcepropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_sortlist];
end;

function tdatalistsourcepropertyeditor.getvalues: msestringarty;
var
 int1: integer;
begin
 result:= nil;
 if fcomponent is tcustomgrid then begin
  with tcustomgrid(fcomponent).datacols do begin
   for int1:= 0 to count -1 do begin
    with cols[int1] do begin
     if (name <> '') and
               (tdatalist(fprops[0].instance).canlink(datalist,gettag)) then begin
      additem(result,msestring(name));
     end;
    end;
   end;
  end;
 end;
end;

function tdatalistsourcepropertyeditor.gettag: integer;
begin
 result:= 0;
end;

{ tsumlistsourcelevelpropertyeditor }

function tsumlistsourcelevelpropertyeditor.getvalues: msestringarty;
begin
 result:= inherited getvalues;
// additem(result,foldlevelsumname);
end;

function tsumlistsourcelevelpropertyeditor.gettag: integer;
begin
 result:= sumleveltag;
end;

{ tsumlistsourceissumpropertyeditor }

function tsumlistsourceissumpropertyeditor.gettag: integer;
begin
 result:= sumissumtag;
end;

{ toptionswidgetpropertyeditor }

function toptionswidgetpropertyeditor.getinvisibleitems: tintegerset;
begin
 result:= invisibleoptionswidget;
end;

{ toptionseditpropertyeditor }

function toptionseditpropertyeditor.getinvisibleitems: tintegerset;
begin
 result:= invisibleoptionsedit;
end;

{ trowstatelistsourcefoldlevelpropertyeditor }

function trowstatelistsourcefoldlevelpropertyeditor.gettag: integer;
begin
 result:= rowstatefoldleveltag;
end;

{ trowstatelistsourceissumpropertyeditor }

function trowstatelistsourceissumpropertyeditor.gettag: integer;
begin
 result:= rowstateissumtag;
end;

{ trowstatelistsourcefoldhiddenpropertyeditor }

function trowstatelistsourcefoldhiddenpropertyeditor.gettag: integer;
begin
 result:= rowstatefoldhiddentag;
end;

{ titemvalueeditpropertyeditor }

function titemvalueeditpropertyeditor.filtercomponent(
              const acomponent: tcomponent): boolean;
var
 intf1: igridwidget;
begin
 result:= (acomponent is twidget) and
  ((twidget(acomponent).parentwidget) =
    tvalueedititem(tpropertyeditor1(parenteditor).getpointervalue()).owner) and
               getcorbainterface(acomponent,typeinfo(igridwidget),intf1);
end;

function tvalueeditspropertyeditor.itemgetvalue(
              const sender: tarrayelementeditor): msestring;
begin
 with tvalueedititem(
         tpropertyeditor1(sender.valueeditor).getpointervalue()) do begin
  if editwidget <> nil then begin
   result:= msestring('<'+inttostr(valueindex)+'>'+'<'+editwidget.name+'>');
  end
  else begin
   result:= '<>';
  end;
 end;
end;

function tvalueeditspropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tvalueeditpropertyeditor;
end;

{ tvalueeditpropertyeditor }

procedure tvalueeditpropertyeditor.navigevent;
begin
 with tvalueedititem(getpointervalue()) do begin
  if editwidget <> nil then begin
   editwidget.bringtofront();
  end;
 end;
end;

initialization
 register;
end.
