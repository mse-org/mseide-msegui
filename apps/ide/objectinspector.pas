{ MSEide Copyright (c) 1999-2007 by Martin Schreiber
   
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
unit objectinspector;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 mseforms,msewidgets,msegrids,msewidgetgrid,classes,mseclasses,
 msepropertyeditors,mseglob,mseguiglob,
 msegui,mseedit,msedataedits,mselistbrowser,msedatanodes,
 msedesignintf,typinfo,msecomponenteditors,msesimplewidgets,msegraphutils,
 msemenus,mseevent,msedesigner,msetypes,msestrings,mselist;

type
 tobjectinspectorfo = class;

 tobjectinspectorselections = class(tdesignerselections)
  private
   fowner: tobjectinspectorfo;
  protected
   procedure compselectoronsetvalue(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure dochanged; override;
  public
   constructor create(owner: tobjectinspectorfo);
 end;

 tpropertyitem = class;

 tproppathinfo = class(ttreelistedititem)
  private
   fname: msestring;
   procedure doexpand(const aitem: tpropertyitem);
  public
   constructor create(const aprop: tpropertyitem);
   procedure save(const aprops: ttreeitemeditlist);
   procedure restore(const aprops: ttreeitemeditlist);
 end;

 compinfoty = record
  instance: tcomponent;
  proppathinfo: tproppathinfo;
  actprop: msestringarty;
 end;
 pcompinfoty = ^compinfoty;

 tcomponentinfos = class(torderedrecordlist)
  protected
   procedure compare(const l,r; out result: integer);
   function getcompareproc: compareprocty; override;
   procedure finalizerecord(var item); override;
  public
   constructor create;
   function find(const ainstance: tcomponent): integer;
   function deleteitem(const ainstance: tcomponent): integer;
   function getitem(ainstance: tcomponent): pcompinfoty;
   function add(const aitem: compinfoty): integer;
 end;

 tobjectinspectorfo = class(tdockform,iobjectinspector,idesignnotification)
   compselector: tdropdownlistedit;
   grid: twidgetgrid;
   props: ttreeitemedit;
   tpopupmenu1: tpopupmenu;
   values: tdropdownitemedit;
   compedit: tbutton;
   procedure propsoncheckrowmove(const curindex: Integer; 
                  const newindex: Integer; var accept: Boolean);
   procedure tmseformcreate(const sender: TObject);
   procedure gridrowsdatachanged(const sender: tcustomgrid;
      const aindex: Integer; const count: integer);
   procedure compselectorbeforedropdown(const sender: TObject);
   procedure compselectoronsetvalue(const sender: tobject; var avalue: msestring;
                   var accept: boolean);
   procedure valuesonmouseevent(const sender: twidget; var info: mouseeventinfoty);
   procedure valuessetvalue(const sender: TObject; var avalue: mseString;
       var accept: Boolean);
   procedure gridcellevent(const sender: tobject; var info: celleventinfoty);
   procedure valueupdaterowvalue(const sender: tobject; const aindex: integer;
                      const aitem: tlistitem);
   procedure valuesbuttonaction(const sender: tobject; var action: buttonactionty;
       const buttonindex: Integer);
   procedure valuesbeforedropdown(const sender: TObject);
   procedure compeditonexecute(const sender: tobject);
   procedure gridondragbegin(const sender: tobject; const apos: pointty;
             var dragobject: tdragobject; var processed: boolean);
   procedure gridondragover(const sender: tobject; const apos: pointty;
            var dragobject: tdragobject; var accept: boolean; var processed: boolean);
   procedure gridondragdrop(const sender: tobject; const apos: pointty;
                var dragobject: tdragobject; var processed: boolean);
   procedure propsonpopup(const sender: tobject; var amenu: tpopupmenu;
                            var mouseinfo: mouseeventinfoty);
   procedure objectinspectorfoonloaded(const sender: tobject);
   procedure objectinspectoronchildscaled(const sender: TObject);
   procedure col0onshowhint(const sender: tdatacol; const arow: Integer; var info: hintinfoty);
   procedure col1onshowhint(const sender: tdatacol; const arow: Integer;
                         var info: hintinfoty);
   procedure valueskeydown(const sender: twidget; var info: keyeventinfoty);
   procedure propupdaterowvalue(const sender: TObject; const aindex: integer;
                                    const aitem: tlistitem);
   procedure collapseexe(const sender: TObject);
  private
   factmodule: tmsecomponent;
   factcomp: tcomponent;
   flastcomp: tcomponent;
   factcomps: componentarty;
   fcomponents: componentnamearty;
   fcomponentinfos: tcomponentinfos;
   fchanging: integer;
   frereadprops: boolean;
   fsinglecomp: boolean;
   function componentdispname(const instance: tcomponent): msestring;
   procedure updatecomponentname;
   procedure selectedcompchanged;
   procedure propscreatenode(const sender: tcustomitemlist;
     var node: ttreelistedititem);
   procedure valuescreatenode(const sender: tcustomitemlist;
     var node: tlistedititem);
   procedure propnotification(const sender: tlistitem; var action: nodeactionty);

   procedure readprops(const module: tmsecomponent; const comp: componentarty); overload;
   procedure readprops(const module: tmsecomponent; const comp: tcomponent); overload;
   function editorstoprops(const editors: propertyeditorarty): treelistitemarty;
   function candragsource(const apos: pointty; var row: integer): boolean;
   function candragdest(const apos: pointty; var row: integer): boolean;
   procedure rereadprops;
   procedure callrereadprops;
   procedure showmethodsource(const aeditor: tmethodpropertyeditor);
  protected
   procedure updatedefaultstate(const aindex: integer);
   procedure doasyncevent(var atag: integer); override;
   function findvalueeditor(const editor: tpropertyeditor): integer;
   function restoreactprop(const acomponent: tcomponent;
                 acol: integer; exact: boolean = false): boolean;
   procedure saveproppath;
   procedure clear;
   function reviseproperties(const aprops: propertyeditorarty): propertyeditorarty;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   //idesignnotification
   procedure itemdeleted(const adesigner: idesigner;
                  const amodule: tmsecomponent;  const aitem: tcomponent);
   procedure iteminserted(const adesigner: idesigner;
                  const amodule: tmsecomponent; const aitem: tcomponent);
   procedure itemsmodified(const adesigner: idesigner; const aitem: tobject);
   procedure componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
   procedure moduleclassnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure selectionchanged(const adesigner: idesigner;
                                   const aselection: idesignerselections);
   procedure moduleactivated(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string; const atypeinfo: ptypeinfo);
   procedure showobjecttext(const adesigner: idesigner;
                   const afilename: filenamety; const backupcreated: boolean);
   procedure closeobjecttext(const adesigner: idesigner;
                    const afilename: filenamety; var cancel: boolean);
   procedure beforefilesave(const adesigner: idesigner;
                                    const afilename: filenamety);
   procedure beforemake(const adesigner: idesigner; const maketag: integer;
                         var abort: boolean);
   procedure aftermake(const adesigner: idesigner; const exitcode: integer);

   //iobjectinspector
   function getproperties(const objects: objectarty; const amodule: tmsecomponent;
                          const acomponent: tcomponent): propertyeditorarty;
   procedure propertymodified(const sender: tpropertyeditor);
   function getmatchingmethods(const sender: tpropertyeditor; atype: ptypeinfo): msestringarty;
   function show(const modal: boolean = false;
           const transientfor: twindow = nil): modalresultty; override;
 end;

 tpropertyitem = class(ttreelistedititem)
  private
   function getexpanded: boolean;
   procedure setexpanded(const Value: boolean);
  protected
   feditor: tpropertyeditor;
   procedure updatestate;
   procedure updatesubpropertypath;
   function finditembyname(const aname: msestring): tpropertyitem;
  public
   destructor destroy; override;
   property expanded: boolean read getexpanded write setexpanded;
   function rootpath: msestring;
 end;

var
 objectinspectorfo: Tobjectinspectorfo;

implementation
uses
 objectinspector_mfm,msedatalist,sysutils,msearrayprops,
 msebitmap,msegraphics,msedrag,mseeditglob,msestockobjects,msedropdownlist,
 sourceupdate,sourceform,msekeyboard,main;

const
 ado_rereadprops = 1;  //asyncevent codes
 ado_updatecomponentname = 2;
 objectinspectorcaption = 'Object Inspector';

type
 defaultenumerationty = (null);
 defaultsetty = set of defaultenumerationty;
 defaultmethodty = procedure of object;

 titemlist1 = class(tcustomitemlist);
 tpropertyeditor1 = class(tpropertyeditor);
 propertyitemarty = array of tpropertyitem;

 tpropertyvalue = class(tlistedititem)
  protected
   feditor: tpropertyeditor;
  public
   procedure updatestate;
 end;
 ppropertyvalue = ^tpropertyvalue;

{ tproppathinfo }

constructor tproppathinfo.create(const aprop: tpropertyitem);
var
 int1: integer;
begin
 inherited create;
 if aprop <> nil then begin
  fname:= aprop.feditor.name;
  if aprop.expanded then begin
   for int1:= 0 to aprop.fcount - 1 do begin
    add(ttreelistedititem(
     tproppathinfo.create(tpropertyitem(aprop[int1]))));
   end;
  end;
 end;
end;

procedure tproppathinfo.save(const aprops: ttreeitemeditlist);
var
 int1: integer;
begin
 clear;
 for int1:= 0 to aprops.count - 1 do begin
  self.add(ttreelistedititem(
        tproppathinfo.create(tpropertyitem(aprops[int1]))));
 end;
end;

procedure tproppathinfo.doexpand(const aitem: tpropertyitem);
var
 int1,int2: integer;
 item1: tpropertyitem;
begin
 if aitem.feditor <> nil then begin
  aitem.expanded:= true; //else root item
 end;
 for int1:= 0 to fcount - 1 do begin
  with tproppathinfo(fitems[int1]) do begin
   if fcount > 0 then begin
    for int2:= 0 to aitem.count - 1 do begin
     item1:= tpropertyitem(aitem[int2]);
     if item1.feditor.name = fname then begin
      doexpand(item1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tproppathinfo.restore(const aprops: ttreeitemeditlist);
var
 item1: tpropertyitem;
begin
 item1:= tpropertyitem.create;
 try
  item1.assign(aprops);
  doexpand(item1);
 finally
  item1.Free;
 end;
end;

{ tcomponentinfos }

constructor tcomponentinfos.create;
begin
 inherited create(sizeof(compinfoty),[rels_needsfinalize]);
end;

procedure tcomponentinfos.compare(const l,r; out result: integer);
begin
 result:= pchar(compinfoty(l).instance) - pchar(compinfoty(r).instance);
end;

function tcomponentinfos.getcompareproc: compareprocty;
begin
 result:= {$ifdef FPC}@{$endif}compare;
end;

procedure tcomponentinfos.finalizerecord(var item);
begin
 finalize(compinfoty(item));
 with compinfoty(item) do begin
  proppathinfo.free;
 end;
end;

function tcomponentinfos.find(const ainstance: tcomponent): integer;
var
 info: compinfoty;
begin
 info.instance:= ainstance;
 result:= indexof(info);
end;

function tcomponentinfos.deleteitem(const ainstance: tcomponent): integer;
begin
 result:= find(ainstance);
 delete(result);
end;

function tcomponentinfos.add(const aitem: compinfoty): integer;
begin
 result:= inherited add(aitem);
end;

function tcomponentinfos.getitem(ainstance: tcomponent): pcompinfoty;
var
 int1: integer;
 info: compinfoty;
begin
 int1:= find(ainstance);
 if int1 < 0 then begin
  fillchar(info,sizeof(info),0);
  info.instance:= ainstance;
  info.proppathinfo:= tproppathinfo.create(nil);
  int1:= add(info);
 end;
 result:= getitempo(int1);
end;

{ tobjectinspectorselections }

constructor tobjectinspectorselections.create(owner: tobjectinspectorfo);
begin
 fowner:= owner;
 inherited create;
end;

procedure tobjectinspectorselections.compselectoronsetvalue(const sender: TObject; 
              var avalue: Integer; var accept: Boolean);
begin
end;

procedure tobjectinspectorselections.dochanged;
var
 int1: integer;
begin
 inherited;
 with fowner.compselector.dropdown do begin
  cols[0].clear;
  for int1:= 0 to count-1 do begin
   with itempo(int1)^ do begin
    cols[0].add(designer.getcomponentdispname(instance)+
          ' ('+designer.getclassname(instance)+')');
   end;
  end;
 end;
end;

{ tpropertyitem }

destructor tpropertyitem.destroy;
begin
 inherited;
 if (feditor <> nil) and not (ps_owned in feditor.state) then begin
  feditor.free;
 end;
end;

function tpropertyitem.getexpanded: boolean;
begin
 result:= ps_expanded in feditor.state;
end;

procedure tpropertyitem.setexpanded(const Value: boolean);
begin
 inherited expanded:= value;
 if value <> getexpanded then begin
  feditor.expanded:= value;
  updatestate;
 end;
end;

procedure tpropertyitem.updatestate;
var
 state1: propertystatesty;
begin
 with feditor do begin
  caption:= Name;
  state1:= state;
  if ps_subproperties in state1 then begin
   if ps_expanded in state1 then begin
    fimagenr:= 1;
   end
   else begin
    fimagenr:= 2;
   end;
  end
  else begin
   fimagenr:= -1;
  end;
 end;
end;

procedure tpropertyitem.updatesubpropertypath;
begin
 //dummy
end;

function tpropertyitem.finditembyname(const aname: msestring): tpropertyitem;
var
 int1: integer;
 item1: tpropertyitem;
begin
 result:= nil;
 for int1:= 0 to fcount-1 do begin
  item1:= tpropertyitem(fitems[int1]);
  if item1.feditor.name = aname then begin
   result:= item1;
   break;
  end;
 end;
end;

function tpropertyitem.rootpath: msestring;

var
 prop1: tpropertyitem;
begin
 prop1:= self;
 while prop1 <> nil do begin
  if (prop1.feditor is tarrayelementeditor) or 
              (prop1.feditor is tcollectionitemeditor) then begin
   result:= '[]'+result;
  end
  else begin
   if prop1.feditor is trecordpropertyeditor then begin
    result:= '.'+prop1.feditor.propertyname+'_'+copy(result,2,bigint);
   end
   else begin
    result:= '.'+prop1.feditor.propertyname+result;
   end;
  end;
  prop1:= tpropertyitem(prop1.parent);
 end;
 result:= copy(result,2,bigint);
end;

{ tpropertyvalue }

procedure tpropertyvalue.updatestate;
begin
 with feditor do begin
  if allequal then begin
   caption:= removelinebreaks(getvalue);
  end
  else begin
   caption:= '';
  end;
 end;
end;

{ tobjectinspectorfo}

constructor tobjectinspectorfo.create(aowner: tcomponent);
begin
 fcomponentinfos:= tcomponentinfos.create;
 inherited create(aowner);
 designnotifications.Registernotification(idesignnotification(self));
end;

destructor tobjectinspectorfo.destroy;
begin
 designnotifications.unRegisternotification(idesignnotification(self));
 inherited;
 fcomponentinfos.Free;
end;

procedure Tobjectinspectorfo.propscreatenode(const sender: tcustomitemlist;
  var node: ttreelistedititem);
begin
 node:= tpropertyitem.create(sender);
end;

function tobjectinspectorfo.findvalueeditor(const editor: tpropertyeditor): integer;
var
 int1: integer;
 po1: ppropertyvalue;
begin
 result:= -1;
 po1:= ppropertyvalue(titemlist1(values.itemlist).fdatapo);
 for int1:= 0 to values.itemlist.count - 1 do begin
  if po1^.feditor = editor then begin
   result:= int1;
   break;
  end;
  inc(po1);
 end;
end;

procedure Tobjectinspectorfo.valuescreatenode(
  const sender: tcustomitemlist; var node: tlistedititem);
begin
 node:= tpropertyvalue.create(sender);
end;

procedure tobjectinspectorfo.showmethodsource(const aeditor: tmethodpropertyeditor);
begin
 sourcefo.showsourcepos(sourceupdater.findmethodpos(aeditor.method,true),true);
end;

procedure tobjectinspectorfo.valuesonmouseevent(const sender: twidget; 
              var info: mouseeventinfoty);
begin
 if sender.isdblclick(info) then begin
  with tpropertyitem(props.item) do begin
   if feditor is tmethodpropertyeditor then begin
    if not values.edited or values.checkvalue then begin
     showmethodsource(tmethodpropertyeditor(feditor));
    end;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.valuessetvalue(const sender: TObject;
  var avalue: mseString; var accept: Boolean);
begin
 try
  tpropertyvalue(titemedit(sender).item).feditor.setvalue(avalue);
 except
  values.editor.undo;
  raise;
 end;
 avalue:= tpropertyvalue(titemedit(sender).item).feditor.getvalue;
// mainfo.sourcechanged(nil);
end;

procedure tobjectinspectorfo.propsoncheckrowmove(const curindex: Integer;
        const newindex: Integer; var accept: Boolean);
var
 editor1: tpropertyeditor;
 bo1: boolean;
begin
 //simulate dragevent
 editor1:= tpropertyitem(props[curindex]).feditor;
 editor1.dragbegin(bo1);
 if bo1 then begin
  with tpropertyitem(props[newindex]).feditor do begin
   bo1:= false;
   dragover(editor1,bo1);
   if bo1 then begin
    dragdrop(editor1);
    grid.row:= newindex;
   end;
  end;
 end;
end;

procedure Tobjectinspectorfo.tmseformcreate(const sender: TObject);
begin
 props.itemlist.oncreateitem:= {$ifdef FPC}@{$endif}propscreatenode;
 props.itemlist.onitemnotification:= {$ifdef FPC}@{$endif}propnotification;
 values.itemlist.oncreateitem:= {$ifdef FPC}@{$endif}valuescreatenode;
end;

procedure tobjectinspectorfo.gridrowsdatachanged(const sender: tcustomgrid;
  const aindex: Integer; const count: integer);
var
 int1: integer;
begin
 props.itemlist.beginupdate;
 values.itemlist.beginupdate;
 try
  for int1:= aindex to aindex + count - 1 do begin
   tpropertyitem(props.itemlist[int1]).updatestate;
   tpropertyvalue(values.itemlist[int1]).feditor:=
           tpropertyitem(props.itemlist[int1]).feditor;
   tpropertyvalue(values.itemlist[int1]).updatestate;
  end;
//  valueupdaterowvalue(nil,grid.row,values.itemlist[int1]);
 finally
  props.itemlist.endupdate;
  values.itemlist.endupdate;
 end;
end;
{
procedure tobjectinspectorfo.compselectordataentered(
  const sender: TObject);
begin
 if fchanging > 0 then begin
  readprops(factmodule,factcomp);
 end;
 selectedcompchanged;
end;
}
procedure tobjectinspectorfo.moduleactivated(const adesigner: idesigner;
                  const amodule: tmsecomponent);
begin
 factmodule:= amodule;
 caption:= objectinspectorcaption + ' (' + amodule.Name+')';
 updatecomponentname;
// clear;
end;

procedure tobjectinspectorfo.moduledeactivated(const adesigner: idesigner;
                  const amodule: tmsecomponent);
begin
 caption:= objectinspectorcaption;
// clear;
 factmodule:= nil;
end;

procedure tobjectinspectorfo.moduledestroyed(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tobjectinspectorfo.ItemDeleted(const ADesigner: IDesigner;
                 const amodule: tmsecomponent; const AItem: tcomponent);
begin
 if factcomp = aitem then begin
  clear;
 end;
 if flastcomp = aitem then begin
  flastcomp:= nil;
 end;
 fcomponentinfos.deleteitem(aitem);
end;

procedure tobjectinspectorfo.ItemInserted(const ADesigner: IDesigner;
                 const amodule: tmsecomponent; const AItem: tcomponent);
begin
 //dummy;
end;

function tobjectinspectorfo.reviseproperties(
                const aprops: propertyeditorarty): propertyeditorarty;
var
 int1,int2,int3,int4: integer;
 str1: msestring;
 edar1: propertyeditorarty;
 amodule: tmsecomponent;
 acomponent: tcomponent;
begin
 result:= aprops;
 if length(result) > 0 then begin
  int2:= 0;
  int3:= 1;
  for int1:= 1 to high(result) do begin
   if result[int1].name = result[int2].name then begin
    result[int1].free;   //remove duplicates
   end
   else begin
    result[int3]:= result[int1];
    inc(int3);
    int2:= int1;
   end;
  end;
  setlength(result,int3);
  with tpropertyeditor1(result[0]) do begin
   amodule:= fmodule;
   acomponent:= fcomponent;
  end;
  int1:= 0;
  while int1 <= high(result) do begin
   str1:= result[int1].name;
   int2:= msestrscan(str1,msechar('_'));
   if int2 > 0 then begin
    int3:= int1+1;
    while (int3 <= high(result)) and
     (msestrlcomp(pmsechar(str1),pmsechar(result[int3].name),int2) = 0) do begin
     inc(int3);
    end;
    setlength(edar1,int3-int1);
    move(result[int1],edar1[0],length(edar1) * sizeof(edar1[0]));
    inc(int2);
    for int4:= 0 to high(edar1) do begin
     tpropertyeditor1(edar1[int4]).fname:=
          copy(tpropertyeditor1(edar1[int4]).fname,int2,bigint);
    end;
    fillchar(result[int1],length(edar1)*sizeof(result[0]),0);
    result[int1]:= trecordpropertyeditor.create(designer,amodule,acomponent,
         iobjectinspector(self),copy(str1,1,int2-2),reviseproperties(edar1));
    int1:= int3;
   end
   else begin
    inc(int1);
   end;
  end;
  int2:= 0;
  for int1:= 0 to high(result) do begin
   if result[int1] <> nil then begin
    result[int2]:= result[int1];
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

function comparepropertyeditor(const l,r): integer;
begin
 result:= tpropertyeditor(l).sortlevel - tpropertyeditor(r).sortlevel;
 if result = 0 then begin
//  result:= msecomparetext(tpropertyeditor(l).name,tpropertyeditor(r).name);
            //has problems with underscores
  result:= msestringicomp(tpropertyeditor(l).name,tpropertyeditor(r).name);
 end;
end;

function tobjectinspectorfo.getproperties(const objects: objectarty;
                  const amodule: tmsecomponent;
                  const acomponent: tcomponent): propertyeditorarty;
type
 propinfopoararty = array of propinfopoarty;
var
 ar1: propinfopoararty;
 master: integer;

 function isok(const index: integer; var indexes: integerarty): boolean;

  function check(info: ppropinfo; ar: propinfopoarty; var foundindex: integer): boolean;
  var
   int1: integer;
   kind: ttypekind;
   typedata: ptypedata;
  begin
   result:= false;
   kind:= info^.proptype^.Kind;
   typedata:= gettypedata(info^.proptype{$ifndef FPC}^{$endif});
   for int1:= 0 to high(ar) do begin
    if (ar[int1]^.proptype^.Kind = kind) and (info^.Name = ar[int1]^.Name) then begin
     if not ((kind = tkset) and
      (typedata^.comptype <>
       gettypedata(ar[int1]^.proptype{$ifndef FPC}^{$endif})^.CompType) or
      (kind = tkenumeration) and
       (typedata^.basetype <>
        gettypedata(ar[int1]^.proptype{$ifndef FPC}^{$endif})^.basetype)) then begin
      foundindex:= int1;
      result:= true;
      break;
     end;
    end;
   end;
  end;

 var
  int1: integer;
 begin                 //isok
  result:= true;
  for int1:= 0 to high(ar1) do begin
   if int1 <> master then begin
    result:= check(ar1[master][index],ar1[int1],indexes[int1]);
    if not result then begin
     break;
    end;
   end
   else begin
    indexes[int1]:= index;
   end;
  end;
 end;                //isok

var
 ar2: propinfopoararty;
 int1,int2,int3: integer;
 propar: propinstancearty;
 intar: integerarty;

begin
 result:= nil;
 if (amodule <> nil) and (acomponent <> nil) and (high(objects) >= 0) then begin
  setlength(ar1,length(objects));
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= getpropinfoar(objects[int1]);
  end;
  if high(objects) > 0 then begin
   master:= 0;
   int2:= high(ar1[0]);
   for int1:= 1 to high(ar1) do begin
    if high(ar1[int1]) < int2 then begin
     master:= int1;
     int2:= high(ar1[int1]);
    end;
   end;
   inc(int2);
   setlength(ar2,length(ar1));
   for int1:= 0 to high(ar1) do begin
    setlength(ar2[int1],int2);
   end;
   int2:= 0;
   setlength(intar,length(ar1));
   for int1:= 0 to high(ar1[master]) do begin
    if isok(int1,intar) then begin
     for int3:= 0 to high(ar1) do begin
      ar2[int3][int2]:= ar1[int3][intar[int3]];
     end;
     inc(int2);
    end;
   end;
   for int3:= 0 to high(ar1) do begin
    setlength(ar2[int3],int2);
   end;
  end
  else begin
   ar2:= ar1;
   int2:= length(ar2[0]);
  end;
  setlength(result,int2);
  setlength(propar,length(objects));
  for int1:= 0 to high(propar) do begin
   propar[int1].instance:= objects[int1];
  end;
  for int1:= 0 to int2 - 1 do begin
   for int3:= 0 to high(propar) do begin
    propar[int3].propinfo:= ar2[int3][int1];
   end;
   result[int1]:= propertyeditors.geteditorclass(
      ar2[0][int1]^.proptype{$ifndef FPC}^{$endif},
      objects[0].ClassType,ar2[0][int1]^.Name).create(
              designer,amodule,acomponent,iobjectinspector(self),
              propar,ar2[0][int1]^.proptype{$ifndef FPC}^{$endif});
  end;
  sortarray(pointerarty(result),{$ifdef FPC}@{$endif}comparepropertyeditor);
  result:= reviseproperties(result);
 end;
end;

function tobjectinspectorfo.restoreactprop(const acomponent: tcomponent;
                   acol: integer; exact: boolean = false): boolean;
var
 po1: pcompinfoty;
 int1: integer;
 item1,item2,item3: tpropertyitem;
begin
 result:= false;
 if acomponent <> nil then begin
  po1:= fcomponentinfos.getitempo(fcomponentinfos.find(acomponent));
  if (po1 <> nil) and (high(po1^.actprop) >= 0) then begin
   item1:= tpropertyitem.create;
   try
    item1.assign(props.itemlist);
    item2:= item1;
    result:= true;
    item3:= item2;  //compiler warning
    for int1:= 0 to high(po1^.actprop) do begin
     item3:= item2;
     item2:= item2.finditembyname(po1^.actprop[int1]);
     if item2 = nil then begin
      result:= not exact;
      break;
     end;
    end;
    if result then begin
     if item2 = nil then begin
      item2:= item3;
     end;
     grid.focuscell(makegridcoord(acol,item2.findex));
    end;
   finally
    item1.Free;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.readprops(const module: tmsecomponent;
                         const comp: componentarty);
var
 po1: pcompinfoty;
 acol: integer;
 int1: integer;
begin
 acol:= grid.col;
 if acol < 0 then begin
  acol:= 1;
 end;
 grid.rowcount:= 0;
 if high(comp) >= 0 then begin
  props.itemlist.Assign(listitemarty(editorstoprops(getproperties(objectarty(comp),
               module,comp[0]))));
  po1:= fcomponentinfos.getitempo(fcomponentinfos.find(comp[0]));
  if (po1 = nil) and (flastcomp <> nil) then begin
   po1:= fcomponentinfos.getitempo(fcomponentinfos.find(flastcomp));
  end;
  if po1 <> nil then begin
   po1^.proppathinfo.restore(props.itemlist);
  end;
  if not restoreactprop(flastcomp,acol,true) then begin
   restoreactprop(comp[0],acol);
  end;
  for int1:= 0 to grid.rowhigh do begin
   updatedefaultstate(int1);
  end;
 end;
end;

procedure tobjectinspectorfo.readprops(const module: tmsecomponent;
                         const comp: tcomponent);
var
 ar1: componentarty;
begin
 setlength(ar1,1);
 ar1[0]:= comp;
 readprops(module,ar1);
end;

function tobjectinspectorfo.editorstoprops(const editors: propertyeditorarty): treelistitemarty;
var
 int1: integer;
begin
 setlength(result,length(editors));
 for int1:= 0 to high(result) do begin
  result[int1]:= tpropertyitem.create;
  with tpropertyitem(result[int1]) do begin
   feditor:= editors[int1];
   feditor.expanded:= false;
   fcaption:= feditor.name{.fprops[0].propinfo^.Name};
   if ps_subproperties in feditor.state then begin
    state:= state + [ns_subitems];
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.rereadprops;
var
 scrpos: integer;
begin
 saveproppath;
// grid.beginupdate;
 scrpos:= grid.frame.scrollpos_y;
 try
  grid.defocusrow;
  readprops(factmodule,factcomps);
 finally
  frereadprops:= false;
//  grid.endupdate;
 end;
 grid.frame.scrollpos_y:= scrpos;
 grid.showcell(grid.focusedcell);
end;

procedure tobjectinspectorfo.ItemsModified(const ADesigner: IDesigner;
                         const AItem: tobject);
begin
 if (aitem = nil) or (aitem = factcomp) and (fchanging = 0) then begin
  callrereadprops;
 end;
end;

procedure tobjectinspectorfo.doasyncevent(var atag: integer);
begin
 inherited;
 case atag of
  ado_rereadprops: begin
   rereadprops;
  end;
  ado_updatecomponentname: begin
   updatecomponentname;
  end;
 end;
end;

procedure tobjectinspectorfo.callrereadprops;
begin
 if not frereadprops and (fchanging = 0) then begin
  asyncevent(ado_rereadprops);
  frereadprops:= true;
 end;
end;

procedure tobjectinspectorfo.propertymodified(const sender: tpropertyeditor);

 procedure compmodified;
 var
  int1: integer;
  props1: propinstancearty;
  comps: componentarty;
 begin
  props1:= nil; //compiler warning
  inc(fchanging);
  try
   comps:= sender.propowner;
   if length(comps) > 0 then begin
    for int1:= 0 to high(comps) do begin
     designer.componentmodified(comps[int1]);
    end;
   end
   else begin
    props1:= sender.rootprops;
    for int1:= 0 to high(props1) do begin
     designer.componentmodified(props1[int1].instance);
    end;
   end;
  finally
   dec(fchanging);
  end;
 end;
 
 var
 po1,po2: tpropertyvalue;
 int1,int2,int3: integer;

begin
 designer.begincomponentmodify;
 try
  if ps_volatile in sender.state then begin
   callrereadprops;
   compmodified;
  end
  else begin
//  designer.begincomponentmodify;
//  try
   if (props.item <> nil) and (tpropertyvalue(values.item).feditor = sender) then begin
    po1:= tpropertyvalue(values.item);
   end
   else begin
    int1:= findvalueeditor(sender);
    if int1 >= 0 then begin
     po1:= tpropertyvalue(values.itemlist[int1]);
    end
    else begin
     po1:= nil;
    end;
   end;
   if po1 <> nil then begin
    po1.updatestate;
    for int1:= 0 to grid.rowcount - 1 do begin
     po2:= tpropertyvalue(values[int1]);
     if (po2 <> po1) and (ps_refresh in po2.feditor.state) then begin
      po2.updatestate;
      updatedefaultstate(int1);
      int3:= props[int1].treelevel;
      for int2:= int1 + 1 to grid.rowcount - 1 do begin
       if props[int2].treelevel <= int3 then begin
        break;
       end
       else begin
        tpropertyvalue(values[int2]).updatestate;
       end;
      end;
     end;
    end;
   end;
   compmodified;
  end;
  mainfo.sourcechanged(nil);
 finally
  designer.endcomponentmodify;
 end;
end;

procedure tobjectinspectorfo.updatecomponentname;
begin
 with compselector do begin
  if fsinglecomp then begin
   value:= componentdispname(factcomp);
  end
  else begin
   value:= '';
  end;
  if focused then begin
   initfocus;
  end;
 end;
end;

function tobjectinspectorfo.componentdispname(
        const instance: tcomponent): msestring;
begin
 result:= '';
 if instance <> nil then begin
  if (factmodule <> nil) and not factmodule.checkowned(instance) and 
          (factmodule <> instance) and (instance.owner <> nil) then begin
   result:=  instance.owner.name+'.';
  end;
  result:= result + designer.getcomponentdispname(instance) +
                  ' (' + designer.getclassname(instance)+')';
 end;
end;

procedure tobjectinspectorfo.compselectorbeforedropdown(
  const sender: TObject);
var
 po1: pmoduleinfoty;
 int1,int2: integer;
 str1: msestring;
begin
 with compselector,dropdown do begin
  str1:= text;
  cols.clear;
  if factmodule <> nil then begin
   int2:= -1;
   po1:= designer.modules.findmodulebyinstance(factmodule);
   if po1 <> nil then begin
    fcomponents:= po1^.components.getdispnames;
    cols[0].count:= po1^.components.count;
    for int1:= 0 to cols[0].count-1 do begin
     with fcomponents[int1] do begin
      cols[0][int1]:= dispname + ' (' + designer.getclassname(instance)+')';
      if cols[0][int1] = str1 then begin
       int2:= int1;
      end;
     end;
    end;
    itemindex:= int2;
   end;
  end;
  text:= str1;
  if editor.sellength > 0 then begin
   editor.selectall;
  end
  else begin
   editor.curindex:= length(str1);
  end;
 end;
end;

procedure tobjectinspectorfo.compselectoronsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
begin
 with compselector.dropdown do begin
  if itemindex < 0 then begin
   clear;
   factcomp:= nil;
  end
  else begin
   factcomp:= fcomponents[itemindex].instance;
  end;
  selectedcompchanged;
 end;
end;

procedure tobjectinspectorfo.SelectionChanged(const ADesigner: IDesigner;
  const ASelection: IDesignerSelections);
begin
 saveproppath;
 with aselection do begin
  if count > 0 then begin
   factcomp:= items[0];
  end
  else begin
   factcomp:= nil;
  end;
  factcomps:= getarray;
  if count = 1 then begin
//   compselector.value:= -1;
   fsinglecomp:= true;
   updatecomponentname;
   readprops(factmodule,factcomp);
  end
  else begin
   fsinglecomp:= false;
   compselector.value:= '';
   readprops(factmodule,factcomps);
  end;
  inc(fchanging);
  try
   selectedcompchanged;
  finally
   dec(fchanging);
  end;
 end;
end;

procedure tobjectinspectorfo.selectedcompchanged;
begin
 if fchanging = 0 then begin
  designer.selectcomponent(factcomp);
 end;
 compedit.enabled:= designer.componentcanedit;
end;

procedure tobjectinspectorfo.saveproppath;
var
 po1: pcompinfoty;
begin
 if (factcomp <> nil) and (props.itemlist.count > 0) then begin
  po1:= fcomponentinfos.getitem(factcomp);
  po1^.proppathinfo.save(props.itemlist);
  if props.item <> nil then begin
   po1^.actprop:= props.item.rootcaptions;
  end;
  flastcomp:= factcomp;
 end;
end;

procedure tobjectinspectorfo.clear;
begin
 saveproppath;
 compselector.value:= '';
 values.itemlist.clear;
 frereadprops:= false;
end;

procedure tobjectinspectorfo.loaded;
begin
 inherited;
 clear;
end;

procedure tobjectinspectorfo.propnotification(const sender: tlistitem;
  var action: nodeactionty);
begin
 with tpropertyitem(sender) do begin
  case action of
   na_expand: begin
    feditor.expanded:= true;
    if count = 0 then begin
     add(editorstoprops(feditor.subproperties));
    end;
   end;
   na_collapse: begin
    feditor.expanded:= false;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.gridcellevent(const sender: tobject;
  var info: celleventinfoty);
begin
 if isrowenter(info) then begin
  values.itemlist.beginupdate;
  try
   with tpropertyvalue(values.item) do begin
    if ps_valuelist in feditor.state then begin
     values.dropdown.options:= values.dropdown.options - [deo_disabled];
    end
    else begin
     values.dropdown.options:= values.dropdown.options + [deo_disabled];
    end;
    values.frame.buttons[1].visible:= ps_dialog in feditor.state;
   end;
  finally
   values.itemlist.decupdate;
  end;
 end;
end;

procedure tobjectinspectorfo.valuesbuttonaction(const sender: tobject; 
              var action: buttonactionty; const buttonindex: Integer);
begin
 with titemedit(sender) do begin
  if action = ba_click then begin
   case buttonindex of
    1: begin
     tpropertyvalue(item).feditor.edit;
    end;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.valueskeydown(const sender: twidget;
                var info: keyeventinfoty);
begin
 if (info.key = key_return) and (info.shiftstate = []) and
                            not values.edited then begin
  with tpropertyvalue(values.item),feditor do begin
   if ps_dialog in state then begin
    include(info.eventstate,es_processed);
    edit;
   end
   else begin
    if feditor is tmethodpropertyeditor then begin
     showmethodsource(tmethodpropertyeditor(feditor));
    end;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.valuesbeforedropdown(const sender: TObject);
begin
 with tdropdownitemedit(sender) do begin
  dropdown.cols.clear;
  with tpropertyvalue(item).feditor do begin
   if ps_sortlist in state then begin
    dropdown.options:= dropdown.options + [deo_sorted];
   end
   else begin
    dropdown.options:= dropdown.options - [deo_sorted];
   end;
   dropdown.cols[0].asarray:= getvalues;
  end;
 end;
end;

procedure tobjectinspectorfo.propupdaterowvalue(const sender: TObject;
               const aindex: Integer; const aitem: tlistitem);
begin
 updatedefaultstate(aindex);
end;

procedure tobjectinspectorfo.valueupdaterowvalue(const sender: tobject;
  const aindex: integer; const aitem: tlistitem);
begin
 if (aitem <> nil) and (tpropertyvalue(aitem).feditor <> nil) then begin
  with tpropertyvalue(aitem).feditor do begin
   if (aindex = values.activerow) or allequal then begin
    aitem.caption:= removelinebreaks(getvalue);
   end
   else begin
    aitem.caption:= '';
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.updatedefaultstate(const aindex: integer);
type
 fontmarkty = (modified,iscomponent,issubproperty);
 fontmarksty = set of fontmarkty;
var
 mark: fontmarksty;
const 
 marktable: array[0..7] of integer = (
                     //issubbroperty iscomponent modified
             -1,     //         0            0        0
              0,     //         0            0        1
              3,     //         0            1        0
             -1,     //         0            1        1 invalid
              2,     //         1            0        0
              1,     //         1            0        1
              2,     //         1            1        0
             -1      //         1            1        1 invalid
               );
begin
 with tpropertyvalue(values[aindex]) do begin
  if feditor <> nil then begin
   mark:= [];
   if ps_modified in feditor.state then begin
    include(mark,modified);
   end;
   if ps_component in feditor.state then begin
    include(mark,iscomponent);
   end;
   if ps_subprop in feditor.state then begin
    include(mark,issubproperty);
   end;
   grid.rowfontstate[aindex]:= marktable[
      {$ifdef FPC}longword{$else}byte{$endif}(mark)];
   if feditor.sortlevel > 0 then begin
    grid.rowcolorstate[aindex]:= 0;
   end
   else begin
    grid.rowcolorstate[aindex]:= -1;
   end;
  end;
 end;
end;

procedure tobjectinspectorfo.componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
begin
 if factcomp = aitem then begin
  asyncevent(ado_updatecomponentname);
 end;
end;

procedure tobjectinspectorfo.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
begin
 if factcomp = amodule then begin
  asyncevent(ado_updatecomponentname);
 end;
end;

procedure tobjectinspectorfo.instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure init;
begin
 registerpropertyeditor(typeinfo(integer),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(longint),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(longword),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(word),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(byte),nil,'',tordinalpropertyeditor);
 registerpropertyeditor(typeinfo(currency),nil,'',tcurrencypropertyeditor);
 registerpropertyeditor(typeinfo(real),nil,'',trealpropertyeditor);
 registerpropertyeditor(typeinfo(double),nil,'',trealpropertyeditor);
 registerpropertyeditor(typeinfo(realty),nil,'',trealtypropertyeditor);
 registerpropertyeditor(typeinfo(tdatetime),nil,'',tdatetimepropertyeditor);
 registerpropertyeditor(typeinfo(char),nil,'',tcharpropertyeditor);
 registerpropertyeditor(typeinfo(widechar),nil,'',twidecharpropertyeditor);
 registerpropertyeditor(typeinfo(defaultenumerationty),nil,'',tenumpropertyeditor);
 {$ifdef FPC}
 registerpropertyeditor(typeinfo(boolean),nil,'',tbooleanpropertyeditor); //for fpc
 {$endif}
 registerpropertyeditor(typeinfo(string),nil,'',tstringpropertyeditor);
 registerpropertyeditor(typeinfo(string),tcomponent,'Name',tnamepropertyeditor);
 registerpropertyeditor(typeinfo(msestring),nil,'',tmsestringpropertyeditor);
 registerpropertyeditor(typeinfo(colorty),nil,'',tcolorpropertyeditor);
// registerpropertyeditor(typeinfo(msechar),nil,'',tmsestringpropertyeditor);
      //???
 registerpropertyeditor({$ifdef FPC}tpersistent.classinfo{$else}typeinfo(tpersistent){$endif},
                   nil,'',tclasspropertyeditor);
 registerpropertyeditor(tparentfont.classinfo,nil,'',tparentfontpropertyeditor);

 registerpropertyeditor(tcomponent.classinfo,nil,'',tcomponentpropertyeditor);
 registerpropertyeditor(typeinfo(defaultmethodty),nil,'',tmethodpropertyeditor);
 registerpropertyeditor(typeinfo(defaultsetty),nil,'',tsetpropertyeditor);
 registerpropertyeditor(tarrayprop.classinfo,nil,'',tarraypropertyeditor);
 registerpropertyeditor(tpersistentarrayprop.classinfo,nil,'',
                               tpersistentarraypropertyeditor);
 registerpropertyeditor(tintegerarrayprop.classinfo,nil,'',
                               tintegerarraypropertyeditor);
 registerpropertyeditor(tcolorarrayprop.classinfo,nil,'',
                               tcolorarraypropertyeditor);
 registerpropertyeditor(trealarrayprop.classinfo,nil,'',
                               trealarraypropertyeditor);
 registerpropertyeditor(tstringarrayprop.classinfo,nil,'',
                               tstringarraypropertyeditor);
 registerpropertyeditor(tmsestringarrayprop.classinfo,nil,'',
                               tmsestringarraypropertyeditor);
 registerpropertyeditor(tmaskedbitmap.classinfo,nil,'',tbitmappropertyeditor);
 registerpropertyeditor(tstrings.classinfo,nil,'',tstringspropertyeditor);
 registerpropertyeditor(tdatalist.classinfo,nil,'',tdatalistpropertyeditor);
 registerpropertyeditor(tmsestringdatalist.classinfo,nil,'',
                               tmsestringdatalistpropertyeditor);
 registerpropertyeditor(tdoublemsestringdatalist.classinfo,nil,'',
                            tdoublemsestringdatalistpropertyeditor);
{
 info.editorclass:= timagelisteditor;
 info.propertytype:= typeinfo(timagelist);//tobject.classinfo;
 apropertyeditors.adddata(info);
}
 registercomponenteditor(tcomponent,tcomponenteditor);
 registercomponenteditor(timagelist,timagelisteditor);
end;

procedure tobjectinspectorfo.compeditonexecute(const sender: tobject);
begin
 designer.getcomponenteditor.edit;
end;

function tobjectinspectorfo.candragsource(const apos: pointty; var row: integer): boolean;
var
 widget1: twidget;
 cell: gridcoordty;
begin
 widget1:= grid.editwidgetatpos(apos,cell);
 row:= cell.row;
 if (widget1 = props) and (not values.edited or values.checkvalue) then begin
  result:= props.candragsource(translateclientpoint(apos,grid,widget1));
 end
 else begin
  result:= false;
 end;
end;

function tobjectinspectorfo.candragdest(const apos: pointty; var row: integer): boolean;
var
 widget1: twidget;
 cell: gridcoordty;
begin
 widget1:= grid.editwidgetatpos(apos,cell);
 row:= cell.row;
 result:= widget1 = props;
end;

procedure tobjectinspectorfo.gridondragbegin(const sender: tobject;
  const apos: pointty; var dragobject: tdragobject; var processed: boolean);
var
 row: integer;
 bo1: boolean;
begin
 if candragsource(apos,row) then begin
  bo1:= false;
  tpropertyitem(props[row]).feditor.dragbegin(bo1);
  if bo1 then begin
   tobjectdragobject.create(sender,dragobject,nullpoint,
          tpropertyitem(props[row]).feditor);
  end;
 end;
end;

procedure tobjectinspectorfo.gridondragdrop(const sender: tobject;
  const apos: pointty; var dragobject: tdragobject; var processed: boolean);
var
 row: integer;
begin
 if candragdest(apos,row) then begin
  tpropertyitem(props[row]).feditor.dragdrop(
     tpropertyeditor(tobjectdragobject(dragobject).data));
  grid.row:= row;
 end;
end;

procedure tobjectinspectorfo.gridondragover(const sender: tobject;
               const apos: pointty; var dragobject: tdragobject;
               var accept: boolean; var processed: boolean);
var
 row: integer;
begin
 if candragdest(apos,row) then begin
  tpropertyitem(props[row]).feditor.dragover(
     tpropertyeditor(tobjectdragobject(dragobject).data),accept);
 end;
end;

procedure tobjectinspectorfo.propsonpopup(const sender: tobject;
               var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty);
begin
 tpropertyitem(props.item).feditor.dopopup(amenu,props,mouseinfo);
end;

procedure tobjectinspectorfo.objectinspectorfoonloaded(const sender: tobject);
begin
 grid.top:= compselector.bottom + 1;
 grid.height:= height-grid.top;
 compedit.left:= compedit.right - compedit.height;
 compedit.width:= compedit.height;
 compselector.right:= compedit.left - 1;
// with values.frame.buttons[0] do begin
//  imagelist:= stockobjects.glyphs;
//  imagenr:= ord(stg_ellipsesmall);
// end;
end;

procedure tobjectinspectorfo.methodcreated(const adesigner: idesigner;
  const amodule: tmsecomponent; const aname: string;
  const atype: ptypeinfo);
begin
 //dummy
end;

function tobjectinspectorfo.getmatchingmethods(
  const sender: tpropertyeditor; atype: ptypeinfo): msestringarty;
begin
 result:= sourceupdater.getmatchingmethods(sender.module,atype);
end;

procedure tobjectinspectorfo.methodnamechanged(const adesigner: idesigner;
  const amodule: tmsecomponent; const newname, oldname: string; const atypeinfo: ptypeinfo);
begin
 //dummy
end;

procedure tobjectinspectorfo.showobjecttext(const adesigner: idesigner; 
          const afilename: filenamety; const backupcreated: boolean);
begin
 //dummy
end;

procedure tobjectinspectorfo.closeobjecttext(const adesigner: idesigner; 
                           const afilename: filenamety; var cancel: boolean);
begin
 //dummy
end;

function tobjectinspectorfo.show(const modal: boolean = false;
             const transientfor: twindow = nil): modalresultty;
begin
 result:= inherited show(modal,transientfor);
end;

procedure tobjectinspectorfo.objectinspectoronchildscaled(const sender: TObject);
begin
 placeyorder(0,[2],[compselector,grid]);
 aligny(wam_center,[compselector,compedit]);
end;

procedure tobjectinspectorfo.col0onshowhint(const sender: tdatacol;
                  const arow: Integer; var info: hintinfoty);
begin
 if (props[arow] <> nil) and props[arow].captionclipped then begin
  info.caption:= props[arow].caption;
 end;
end;

procedure tobjectinspectorfo.col1onshowhint(const sender: tdatacol;
         const arow: Integer; var info: hintinfoty);
begin
 if (values[arow] <> nil) and values[arow].captionclipped then begin
  info.caption:= values[arow].caption;
 end;
end;

procedure tobjectinspectorfo.collapseexe(const sender: TObject);
var
 int1: integer;
begin
 for int1:= grid.rowhigh downto 0 do begin
  props[int1].expanded:= false;
 end;
end;

procedure tobjectinspectorfo.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
begin
 //dummy
end;

procedure tobjectinspectorfo.aftermake(const adesigner: idesigner;
                              const exitcode: integer);
begin
 //dummy
end;

procedure tobjectinspectorfo.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
begin
 //dummy
end;

initialization
 init;
end.
