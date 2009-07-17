{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regeditwidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 {$ifdef FPC}classes{$else}Classes{$endif},mseedit,msedataedits,msegraphedits,
 msedataimage,mselistbrowser,msecalendardatetimeedit,
 msewidgetgrid,msetextedit,msedesignintf,regeditwidgets_bmp,msepropertyeditors,
 msedropdownlist,mseterminal,msedrawtext,msedatanodes,msedialog,msestrings,
 regwidgets,msearrayprops,typinfo,msestockobjects,msefoldedit,msebitmap,mseglob;

type
 tdropdowncolpropertyeditor = class(tarraypropertyeditor)
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

 tstockglypheditor = class(tenumpropertyeditor)
  protected
   function gettypeinfo: ptypeinfo; override;
 end;
 
 tstockglypharraypropertyeditor = class(tintegerarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tdataimagepropertyeditor = class(tstringpropertyeditor)
 protected
   function getdefaultstate: propertystatesty; override;
   procedure edit; override;
  public
   function getvalue: msestring; override;
 end;
 
procedure Register;
begin
 registercomponents('Edit',[twidgetgrid,tedit,tslider,tprogressbar,
   tbooleanedit,tbooleaneditradio,
   tdatabutton,tstockglyphdatabutton,tdataicon,tdataimage,
   tpointeredit,
   tstringedit,tdropdownlistedit,thistoryedit,tdialogstringedit,
   thexstringedit,tmemoedit,tfoldedit,
   tintegeredit,trealedit,trealspinedit,tdatetimeedit,tcalendardatetimeedit,tkeystringedit,
   tenumedit,tenumtypeedit,tselector,
   {tstringlistedit,}
   titemedit,tdropdownitemedit,tmbdropdownitemedit,ttreeitemedit,
   trecordfieldedit,
   ttextedit,tterminal]);
 registercomponenttabhints(['Edit'],
 ['Edit Widgets, twidgetgrid and Widgets'+c_linefeed+
  'which can be placed into twidgetgrid']);
 registerpropertyeditor(tdropdowncols.classinfo,nil,'',tdropdowncolpropertyeditor);
 registerpropertyeditor(ttabulators.classinfo,tcustomtextedit,'tabulators',
            toptionalpersistentarraypropertyeditor);
 registerpropertyeditor(tcustomitemlist.classinfo,nil,'',titemlistpropertyeditor);
 registerpropertyeditor(typeinfo(twidgetcols),nil,'',twidgetcolspropertyeditor);
 registerpropertyeditor(typeinfo(tintegerarrayprop),tstockglyphdatabutton,'',
              tstockglypharraypropertyeditor);
 registerpropertyeditor(typeinfo(string),tdataimage,'value',tdataimagepropertyeditor);
 registerpropertyeditor(typeinfo(tmaskedbitmap),tdataimage,'bitmap',tclasspropertyeditor);
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

{ twidgetcolelementeditor }

function twidgetcolelementeditor.getvalue: msestring;
var
 col1: twidgetcol;
begin
 col1:= twidgetcol(getordvalue);
 result:= inherited getvalue;
 if col1.editwidget <> nil then begin
  result:= result + '<'+col1.editwidget.name+'>';
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

{ tstockglypharraypropertyeditor }

function tstockglypharraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tstockglypheditor;
end;

{ tstockglypheditor }

function tstockglypheditor.gettypeinfo: ptypeinfo;
begin
 result:= typeinfo(stockglyphty);
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
 bmp,bmp1: tmaskedbitmap;
 int1: integer;
begin
 if imagefilepropedit(mstr1,format1) = mr_ok then begin
  bmp:= tmaskedbitmap.create(false);
  try
   bmp.loadfromfile(mstr1,format1);
   for int1:= 0 to high(fprops) do begin
    bmp1:= tdataimage(fprops[int1].instance).bitmap;
    if bmp1 <> nil then begin
     bmp.alignment:= bmp1.alignment;
     bmp.colorbackground:= bmp1.colorbackground;
     bmp.colorforeground:= bmp1.colorforeground;
     bmp.transparency:= bmp1.transparency;
     bmp.transparentcolor:= bmp1.transparentcolor;
    end;
    bmp1.assign(bmp);
   end;
   modified;
  finally
   bmp.Free;
  end;
 end;
end;

initialization
 register;
end.
