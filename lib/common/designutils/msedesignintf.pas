{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedesignintf;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,msegraphutils,mselist,sysutils,typinfo,msebitmap,
 msetypes,msestrings,msegraphics,msegui,mseglob,
 mseclasses,mseforms,msestat,mserichstring,msecomptree;
const
 defaultmoduleclassname = 'tmseform';
type
 initcomponentprocty = procedure(acomponent: tcomponent; aparent: tcomponent) of object;

 componentclassinfoty = record
  classtyp: tcomponentclass;
  icon: integer;
  page: integer;
  defaultindex: integer;
 end;
 pcomponentclassinfoty = ^componentclassinfoty;

 comppagety = record
  caption: msestring;
  hint: msestring;
 end;
 comppagearty = array of comppagety;
 
 tcomponentclasslist = class(torderedrecordlist)
  private
   fselectedclass: tcomponentclass;
   fimagelist: timagelist;
   fpagenames: comppagearty;
   fpagecomporders: integerararty;
   fdefaultindex: integer;
   fdefaultorder: boolean;
   function getpagecomporders(const index: integer): integerarty;
   procedure setpagecomporders(const index: integer;
      const Value: integerarty);
   procedure checkpageindex(const index: integer);
   procedure setdefaultorder(const avalue: boolean);
  protected
   function findpage(const pagename: msestring): integer;
   function addpage(const pagename: msestring): integer;
   function getcomparefunc: sortcomparemethodty; override;
   function compare(const l,r): integer;
   function componentcounts: integerarty;
  public
   constructor create;
   destructor destroy; override;
   function indexof(const value: tcomponentclass): integer;  //-1 if not found
   function add(var value: componentclassinfoty): integer;
           //-1 if allready registred
   function itempo(const index: integer): pcomponentclassinfoty;
   procedure registercomponents(const page: msestring;
                 const componentclasses: array of tcomponentclass);
   procedure registercomponenttabhints(const pages: array of msestring;
                       const hints: array of msestring);
                       //pages are case sensitive, pages mustexist
   function pagehigh: integer;
   function pagenames: comppagearty;
   property pagecomporders[const index: integer]: integerarty
                  read getpagecomporders write setpagecomporders;
   procedure drawcomponenticon(const acomponent: tcomponent;
              const canvas: tcanvas; const dest: rectty);
   procedure updatestat(const filer: tstatfiler);
   property selectedclass: tcomponentclass read fselectedclass write fselectedclass;
   property imagelist: timagelist read fimagelist;
   property defaultorder: boolean read fdefaultorder write setdefaultorder;
 //nil for unselect
 end;

 idesignerselections = interface(inullinterface)
  function add(const item: tcomponent): integer;
  function equals(const list: idesignerselections): boolean;
  function get(index: integer): tcomponent;
  function getcount: integer;
  function getarray: componentarty;
  property count: integer read getcount;
  property items[index: integer]: tcomponent read get; default;
 end;

 componenteditorstatety = (cs_canedit);
 componenteditorstatesty = set of componenteditorstatety;

 icomponenteditor = interface(inullinterface)
  procedure edit;
  function state: componenteditorstatesty;
 end;

 compfilterfuncty = function(const acomponent: tcomponent): boolean of object;
 
 idesigner = interface(inullinterface)
  procedure componentmodified(const component: tobject);
  function createcurrentcomponent(const module: tmsecomponent): tcomponent;
  function hascurrentcomponent: boolean;
  procedure addcomponent(const module: tmsecomponent;
                                         const acomponent: tcomponent);
  procedure deleteselection(adoall: Boolean = False);
  procedure deletecomponent(const acomponent: tcomponent);
  procedure clearselection;
  procedure selectcomponent(instance: tcomponent);
  procedure setselections(const list: idesignerselections);
  procedure noselection;
  function getmethod(const name: string; const methodowner: tmsecomponent;
                      const atype: ptypeinfo; const searchancestors: boolean): tmethod;
  function getmethodname(const method: tmethod; const comp: tcomponent): string;
  procedure changemethodname(const method: tmethod; newname: string;
                             const atypeinfo: ptypeinfo);
  function createmethod(const name: string; const module: tmsecomponent;
                 const atype: ptypeinfo): tmethod;
  procedure checkmethod(const method: tmethod; const name: string;
               const module: tmsecomponent; const atype: ptypeinfo);
  function isownedmethod(const root: tcomponent;
                                          const method: tmethod): boolean;
  function getcomponentname(const comp: tcomponent): string;
                   //returns qualified name
  procedure validaterename(const acomponent: tcomponent; const curname, newname: string);
  function getcomponentdispname(const comp: tcomponent): string;
                   //returns qualified name into root
  function getclassname(const comp: tcomponent): string;
                   //returns submoduleclass if appropriate
  function getcomponent(const aname: string; const aroot: tcomponent): tcomponent;
                   //handles qualified names for foreign forms
  function componentcanedit: boolean;
  function getcomponenteditor: icomponenteditor;
  function getcomponentlist(const acomponentclass: tcomponentclass;
                  const filter: compfilterfuncty = nil): componentarty;
  function getcomponentnamelist(const acomponentclass: tcomponentclass;
                          const includeinherited: boolean;
                          const aowner: tcomponent = nil;
                          const filter: compfilterfuncty = nil): msestringarty;
  function getcomponentnametree(const acomponentclass: tcomponentclass;
                          const includeinherited: boolean;
                          const aowner: tcomponent = nil;
                          const filter: compfilterfuncty = nil): tcompnameitem;
  procedure setactivemodule(const adesignform: tmseform);
  procedure setmodulex(const amodule: tmsecomponent; avalue: integer);
  procedure setmoduley(const amodule: tmsecomponent; avalue: integer);
  procedure modulesizechanged(const amodule: tmsecomponent);
 end;

 idesignnotification = interface(inullinterface)
  procedure itemdeleted(const adesigner: idesigner;
              const amodule: tmsecomponent; const aitem: tcomponent);
  procedure iteminserted(const adesigner: idesigner;
              const amodule: tmsecomponent; const aitem: tcomponent);
  procedure itemsmodified(const adesigner: idesigner; const aitem: tobject);
                      //nil for undefined aitem
  procedure componentnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const aitem: tcomponent;
                    const newname: string);
  procedure moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
  procedure instancevarnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
  procedure selectionchanged(const adesigner: idesigner;
                    const aselection: idesignerSelections);

  procedure moduleactivated(const adesigner: idesigner;
                          const amodule: tmsecomponent);
  procedure moduledeactivated(const adesigner: idesigner;
                          const amodule: tmsecomponent);
  procedure moduledestroyed(const adesigner: idesigner;
                          const amodule: tmsecomponent);

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
 end;

 selectedinfoty = record
  instance: tcomponent;
 end;
 pselectedinfoty = ^selectedinfoty;
 
 objinfoty = record
  owner: tcomponent;
  parent: twidget;
  objtext: string;
 end;
 objinfoarty = array of objinfoty;

 tdesignerselections = class(trecordlist,idesignerselections)
  private
   fupdating: integer;
   factcomp: tcomponent;
   fpasteowner: tcomponent;
   fpasteroot: tcomponent;
   function Getitems(const index: integer): tcomponent;
   procedure Setitems(const index: integer; const Value: tcomponent);
   procedure dosetactcomp(component: tcomponent);
   procedure doadd(component: tcomponent);
   procedure findpastemethod(Reader: TReader;
           const aMethodName: string; var Address: Pointer; var Error: Boolean);
   procedure referencepastename(reader: treader; var name: string);
  protected
   procedure dochanged; virtual;
   function getrecordsize: integer; virtual;
  public
   constructor create;
   procedure change; virtual;
   procedure beginupdate;
   procedure endupdate;
   procedure decupdate;
    // idesignerselections
   function Add(const Item: Tcomponent): Integer;
   function Equals(const List: IDesignerSelections): Boolean; reintroduce;
   function Get(Index: Integer): Tcomponent;
   function GetCount: Integer;
   function getarray: componentarty;

   function getobjinfoar: objinfoarty;   
   function getobjecttext: string;
   function pastefromobjecttext(const aobjecttext: string; 
           aowner,aparent: tcomponent; initproc: initcomponentprocty): integer;
                  //returns count of added components
   procedure copytoclipboard;
   function pastefromclipboard(aowner,aparent: tcomponent;
                             initproc: initcomponentprocty): integer;
                  //returns count of added components

   function itempo(const index: integer): pselectedinfoty;
   function indexof(const ainstance: tcomponent): integer;
   function remove(const ainstance: tcomponent): integer; virtual;
   procedure assign(const source: idesignerselections);
   property items[const index: integer]: tcomponent
              read Getitems write Setitems; default;
   function isembedded(const component: tcomponent): boolean;
                 //true if subchild of another selected component
 end;

 tdesignnotifications = class(tpointerlist)
  public
   procedure ItemDeleted(const ADesigner: IDesigner; const amodule: tmsecomponent;
                               const AItem: tcomponent);
   procedure ItemInserted(const ADesigner: IDesigner; const amodule: tmsecomponent;
                             const AItem: tcomponent);
   procedure ItemsModified(const ADesigner: IDesigner; const aitem: tobject);
                       //nil for undefined aitem
   procedure componentnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const aitem: tcomponent;
                    const newname: string);
   procedure moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
   procedure instancevarnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
   procedure SelectionChanged(const ADesigner: IDesigner;
                      const ASelection: IDesignerSelections);
   procedure moduleactivated(const adesigner: idesigner;
                          const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner;
                          const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner;
                          const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string; const atypeinfo: ptypeinfo);
   procedure showobjecttext(const adesigner: idesigner;
               const afilename: filenamety; const backupcreated: boolean);
   procedure closeobjecttext(const adesigner: idesigner; 
                 const afilename: filenamety; out cancel: boolean);
   procedure beforefilesave(const adesigner: idesigner;
                                 const afilename: filenamety);
   procedure beforemake(const adesigner: idesigner; const maketag: integer;
                         var abort: boolean);
   procedure aftermake(const adesigner: idesigner; const exitcode: integer);
   
   procedure Registernotification(const DesignNotification: IDesignNotification);
   procedure Unregisternotification(const DesignNotification: IDesignNotification);
 end;
 
 unitgroupinfoty = record
  dependents: stringarty;
  group: stringarty;
 end;
 punitgroupinfoty = ^unitgroupinfoty;
 
 tunitgroups = class(trecordlist)
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
  public
   constructor create;
   procedure registergroups(const adependents: array of string;
                                      const agroup: array of string);
   function getneededunits(const aunitname: string): stringarty;
 end;
 
 createdesignmodulefuncty = function(const aclass: tclass;
                                 const aclassname: pshortstring): tmsecomponent;
 initdesigncomponentprocty = procedure(const amodule: tcomponent; 
                                                const acomponent: tcomponent);
 getdesignscalefuncty = function(const amodule: tcomponent): real;
 sourcetoformfuncty = function(const amodule: tmsecomponent;
                                 const source: trichstringdatalist): boolean; 
                          //true if ok
 designmoduleintfty = record
  createfunc: createdesignmodulefuncty;
  initnewcomponent: initdesigncomponentprocty;
  getscale: getdesignscalefuncty;
  sourcetoform: sourcetoformfuncty;
 end;
 pdesignmoduleintfty = ^designmoduleintfty;
 
procedure registercomponents(const page: msestring;
                          const componentclasses: array of tcomponentclass);
procedure registercomponenttabhints(const pages: array of msestring;
                       const hints: array of msestring);
                       //pages are case sensitive, pages mustexist
function registeredcomponents: tcomponentclasslist;
function unitgroups: tunitgroups;
procedure registerunitgroup(const adependents,agroup: array of string);

function designnotifications: tdesignnotifications;

procedure setcomponentpos(const component: tcomponent; const pos: pointty);
function getcomponentpos(const component: tcomponent): pointty;

implementation
uses
 msesysutils,msestream,msewidgets,msedatalist,rtlconsts,msedesigner,
 msetabs,mseapplication,mseobjecttext,msedatamodules;
 
type
 {$ifdef FPC}
 {$notes off}
  TFilercracker = class(TObject)
  private
//    FRoot: TComponent;
//    FLookupRoot: TComponent;
  end;
 {$notes on}
  {$else}
  TFilercracker = class(TObject)
  private
    FStream: TStream;
    FBuffer: Pointer;
    FBufSize: Integer;
    FBufPos: Integer;
    FBufEnd: Integer;
    FRoot: TComponent;
    FLookupRoot: TComponent;
  end;
  {$endif}
 treader1 = class(treader);
 twriter1 = class(twriter);  
 tcomponent1 = class(tcomponent);

var
 adesignnotifications: tdesignnotifications;
 aregisteredcomponents: tcomponentclasslist;
// aregistereddesignmoduleclasses: designmoduleinfoarty;
 aunitgroups: tunitgroups;

{$ifdef FPC}
var
 componentposreversed: boolean;
{$endif}

procedure setcomponentpos(const component: tcomponent; const pos: pointty);
var
 lo1: longint;
begin
 {$ifdef fpc} //fpbug
 if componentposreversed then begin
  longrec(lo1).hi:= pos.x;
  longrec(lo1).lo:= pos.y;
 end
 else begin
  longrec(lo1).lo:= pos.x;
  longrec(lo1).hi:= pos.y;
 end;
 {$else}
 longrec(lo1).lo:= pos.x;
 longrec(lo1).hi:= pos.y;
 {$endif}
 component.designinfo:= lo1;
end;

function getcomponentpos(const component: tcomponent): pointty;
begin
 {$ifdef fpc} //fpbug
 if componentposreversed then begin
  result.x:= smallint(longrec(component.designinfo).hi);
  result.y:= smallint(longrec(component.designinfo).lo);
 end
 else begin
  result.x:= smallint(longrec(component.designinfo).lo);
  result.y:= smallint(longrec(component.designinfo).hi);
 end;
 {$else}
 result.x:= smallint(longrec(component.designinfo).lo);
 result.y:= smallint(longrec(component.designinfo).hi);
 {$endif}
end;

function registeredcomponents: tcomponentclasslist;
begin
 if aregisteredcomponents = nil then begin
  aregisteredcomponents:= tcomponentclasslist.create;
 end;
 result:= aregisteredcomponents;
end;

function unitgroups: tunitgroups;
begin
 if aunitgroups = nil then begin
  aunitgroups:= tunitgroups.create;
 end;
 result:= aunitgroups;
end;

function designnotifications: tdesignnotifications;
begin
 result:= adesignnotifications;
end;

procedure registercomponents(const page: msestring;
                 const componentclasses: array of tcomponentclass);
begin
 registeredcomponents.registercomponents(page,componentclasses);
end;

procedure registercomponenttabhints(const pages: array of msestring;
                       const hints: array of msestring);
                       //pages are case sensitive, pages mustexist
begin
 registeredcomponents.registercomponenttabhints(pages,hints);
end;

procedure registerunitgroup(const adependents,agroup: array of string);
begin
 unitgroups.registergroups(adependents,agroup);
end;

{ tcomponentclasslist }

constructor tcomponentclasslist.create;
begin
 fimagelist:= timagelist.create(nil);
 fimagelist.size:= makesize(24,24);
 fimagelist.colormask:= true;
 inherited create(sizeof(componentclassinfoty));
end;

destructor tcomponentclasslist.destroy;
begin
 fimagelist.Free;
 inherited;
end;

function tcomponentclasslist.add(var value: componentclassinfoty): integer;
begin
 if indexof(value.classtyp) < 0 then begin
  value.defaultindex:= fdefaultindex;
  inc(fdefaultindex);
  result:= inherited add(value);
 end
 else begin
  result:= -1;
 end;
end;

procedure tcomponentclasslist.registercomponents(const page: msestring;
                 const componentclasses: array of tcomponentclass);
var
 info: componentclassinfoty;
 int1: integer;
 bitmap: tbitmapcomp;
 class1: tclass;
 pagenr: integer;
begin
 pagenr:= addpage(page);
 bitmap:= tbitmapcomp.create(nil);
 try
  if fimagelist.count = 0 then begin
   bitmap.name:= 'TComponent';
   initmsecomponent1(bitmap,nil);
   fimagelist.addimage(bitmap.bitmap);
  end;
  with info do begin
   for int1:= 0 to high(componentclasses) do begin               
    classtyp:= componentclasses[int1];
    page:= pagenr;
    icon:= 0;
    class1:= classtyp;
    while class1 <> nil do begin
     bitmap.bitmap.clear;
     bitmap.bitmap.colormask:= false;
     bitmap.name:= class1.classname;
     if initmsecomponent1(bitmap,nil) then begin
      if not bitmap.bitmap.colormask then begin
       bitmap.bitmap.automask;
      end;
      icon:= fimagelist.addimage(bitmap.bitmap);
      break;
     end;
     class1:= class1.ClassParent;
    end;
    classes.registerclass(info.classtyp);
    add(info);
   end;
  end;
 finally
  bitmap.Free;
 end;
end;

procedure tcomponentclasslist.registercomponenttabhints(
              const pages: array of msestring; const hints: array of msestring);
                       //pages are case sensitive, pages mustexist
var
 int1: integer;
 int2: integer;
begin
 for int1:= 0 to high(pages) do begin
  int2:= findpage(pages[int1]);
  if (int2 >= 0) then begin
   with fpagenames[int2] do begin
    if int1 <= high(hints) then begin
     hint:= hints[int1];
    end
    else begin
     hint:= '';
    end;
   end;
  end;
 end;
end;

function tcomponentclasslist.indexof(
  const value: tcomponentclass): integer;
begin
 result:= inherited indexof(value);
end;

function tcomponentclasslist.itempo(
  const index: integer): pcomponentclassinfoty;
begin
 result:= pcomponentclassinfoty(getitempo(index));
end;

function tcomponentclasslist.findpage(const pagename: msestring): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fpagenames) do begin
  if fpagenames[int1].caption = pagename then begin
   result:= int1;
   break;
  end;
 end;
end;

function tcomponentclasslist.addpage(const pagename: msestring): integer;
begin
 result:= findpage(pagename);
 if result < 0 then begin
  setlength(fpagenames,length(fpagenames) + 1);
  setlength(fpagecomporders,length(fpagenames));
  result:= high(fpagenames);
  fpagenames[result].caption:= pagename;
 end;
end;

function tcomponentclasslist.pagenames: comppagearty;
begin
 result:= fpagenames;
end;

function tcomponentclasslist.pagehigh: integer;
begin
 result:= high(fpagenames);
end;

procedure tcomponentclasslist.drawcomponenticon(const acomponent: tcomponent;
                                    const canvas: tcanvas; const dest: rectty);
var
 int1: integer;
begin
 int1:= indexof(tcomponentclass(acomponent.classtype));
 if int1 >= 0 then begin
  fimagelist.paint(canvas,itempo(int1)^.icon,dest);
 end;
end;

function tcomponentclasslist.componentcounts: integerarty;
var
 int1: integer;
begin
 setlength(result,length(fpagenames));
 for int1:= 0 to count - 1 do begin
  with itempo(int1)^ do begin
   if page <= high(result) then begin
    inc(result[page]);
   end;
  end;
 end;
end;

procedure tcomponentclasslist.updatestat(const filer: tstatfiler);
var
 int1,int2: integer;
 ar1,ar2,ar3: integerarty;
begin
 ar1:= nil; //compiler warning
 ar2:= nil; //compiler warning
 filer.setsection('componentpalette');
 if filer.iswriter then begin
  for int1:= 0 to high(fpagecomporders) do begin
   tstatwriter(filer).writearray('order'+inttostr(int1),fpagecomporders[int1]);
  end;
 end
 else begin
  ar2:= componentcounts;
  for int1:= 0 to high(fpagecomporders) do begin
   ar1:= tstatreader(filer).readarray('order'+inttostr(int1),integerarty(nil));
   if ar1 <> nil then begin
    if length(ar1) <> ar2[int1] then begin
     ar1:= nil; //invalid
    end
    else begin
     ar3:= copy(ar1);
     sortarray(ar3);
     for int2:= 0 to high(ar3) do begin
      if ar3[int2] <> int2 then begin
       ar1:= nil; //invalid
       break;
      end;
     end;
    end;
   end;
   fpagecomporders[int1]:= ar1;
  end;
 end;
 filer.endlist;
end;

function tcomponentclasslist.compare(const l, r): integer;
begin 
 if fdefaultorder then begin
  result:= componentclassinfoty(l).defaultindex -
              componentclassinfoty(r).defaultindex;
 end
 else begin
  result:= ptruint(componentclassinfoty(l).classtyp) -
              ptruint(componentclassinfoty(r).classtyp);
 end;
end;

function tcomponentclasslist.getcomparefunc: sortcomparemethodty;
begin
 result:= {$ifdef FPC}@{$endif}compare;
end;

procedure tcomponentclasslist.checkpageindex(const index: integer);
begin
 if (index < 0) or (index > high(fpagecomporders)) then begin
  tlist.Error(SListIndexError, Index);
 end;
end;

function tcomponentclasslist.getpagecomporders(
  const index: integer): integerarty;
begin
 checkpageindex(index);
 result:= fpagecomporders[index];
end;

procedure tcomponentclasslist.setpagecomporders(const index: integer;
  const Value: integerarty);
begin
 checkpageindex(index);
 fpagecomporders[index]:= value;
end;

procedure tcomponentclasslist.setdefaultorder(const avalue: boolean);
begin
 if fdefaultorder <> avalue then begin
  fdefaultorder:= avalue;
  if sorted then begin
   sorted:= false;
   sorted:= true;
  end;
 end;
end;

{ tdesignerselections }

constructor tdesignerselections.create;
begin
 inherited create(getrecordsize);
end;

function tdesignerselections.itempo(const index: integer): pselectedinfoty;
begin
 result:= pselectedinfoty(getitempo(index));
end;

procedure tdesignerselections.assign(const source: idesignerselections);
var
 int1: integer;
begin
 clear;
 count:= source.Count;
 for int1:= 0 to source.count - 1 do begin
  itempo(int1)^.instance:= source.Items[int1];
 end;
 change;
end;

function tdesignerselections.getarray: componentarty;
begin
 if fcount > 0 then begin
  setlength(result,fcount);
  move(datapo^,pointer(result)^,fcount*sizeof(pointer));
 end
 else begin
  result:= nil;
 end;
end;

function tdesignerselections.Add(const Item: Tcomponent): Integer;
var
 info: selectedinfoty;
 widget1: twidget;
begin
 result:= indexof(item);
 if result < 0 then begin
  fillchar(info,sizeof(info),0);
  info.instance:= item;
  result:= inherited add(info);
  if item is twidget then begin
   widget1:= twidget(item);
   while widget1 <> nil do begin
    if (widget1 is ttabpage) then begin
     ttabpage(widget1).isactivepage:= true;
    end;
    widget1:= widget1.parentwidget;
   end;
  end;
  change;
 end;
end;

function tdesignerselections.Equals(const List: IDesignerSelections): Boolean;
var
 int1: integer;
begin
 result:= false;
 if list.Count = count then begin
  for int1:= 0 to count-1 do begin
   if list.Items[int1] <> itempo(int1)^.instance then begin
    exit;
   end;
  end;
 end;
 result:= true;
end;

function tdesignerselections.Get(Index: Integer): Tcomponent;
begin
 result:= itempo(index)^.instance;
end;

function tdesignerselections.GetCount: Integer;
begin
 result:= count;
end;

function tdesignerselections.indexof(const ainstance: tcomponent): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to count-1 do begin
  if itempo(int1)^.instance = ainstance then begin
   result:= int1;
   break;
  end;
 end;
end;

function tdesignerselections.remove(const ainstance: tcomponent): integer;
begin
 result:= indexof(ainstance);
 if result >= 0 then begin
  delete(result);
  change;
 end;
end;

procedure tdesignerselections.dochanged;
begin
 //dummy
end;

function tdesignerselections.getrecordsize: integer;
begin
 result:= sizeof(selectedinfoty);
end;

function tdesignerselections.Getitems(const index: integer): tcomponent;
begin
 result:= itempo(index)^.instance;
end;

procedure tdesignerselections.Setitems(const index: integer;
  const Value: tcomponent);
begin
 itempo(index)^.instance:= value;
end;

procedure tdesignerselections.beginupdate;
begin
 inc(fupdating);
end;

procedure tdesignerselections.change;
begin
 if fupdating = 0 then begin
  dochanged;
 end;
end;

procedure tdesignerselections.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  dochanged;
 end;
end;

procedure tdesignerselections.decupdate;
begin
 dec(fupdating);
end;

function tdesignerselections.isembedded(const component: tcomponent): boolean;
                 //true if subchild of another selected component
var
 comp1: tcomponent;
begin
 result:= false;
 comp1:= component.getparentcomponent;
 while comp1 <> nil do begin
  if (indexof(comp1) >= 0) then begin
   result:= true;
   break;  //stored bay parent
  end;
  comp1:= comp1.getparentcomponent;
 end;
end;

function tdesignerselections.getobjecttext: string;
var
 binstream: tmemorystream;
 textstream: ttextstream;
 int1: integer;
 component: tcomponent;
 writer: twritermse;
 comp1,comp2: tcomponent;
 po1: pointer;
 modulepo: pmoduleinfoty;
begin
 result:= '';
 if count > 0 then begin
  binstream:= tmemorystream.Create;
  textstream:= ttextstream.Create;
  try
   for int1:= 0 to count -1 do begin
    component:= items[int1];
    if not isembedded(component) then begin
     writer:= twritermse.Create(binstream,4096,true);
     comp1:= tcomponent.create(nil);
     try
      modulepo:= designer.modules.findmodulebycomponent(component);
      po1:= swapmethodtable(comp1,
                         modulepo^.methods.createmethodtable(
                                 designer.getancestormethods(modulepo)));
      designer.doswapmethodpointers(component,false);
      try
       writer.Root:= component.Owner;
       designer.descendentinstancelist.beginstreaming; 
       comp2:= designer.descendentinstancelist.findancestor(component);
       writer.ancestor:= comp2;
       writer.rootancestor:= comp2;
       writer.onfindancestor:= {$ifdef FPC}@{$endif}designer.findancestor;
       {$ifndef FPC}
       writer.WriteSignature;
       {$endif}
       writer.writecomponent(component);
      finally
       designer.descendentinstancelist.endstreaming; 
       designer.doswapmethodpointers(component,true);
       swapmethodtable(comp1,po1);
       modulepo^.methods.releasemethodtable;
      end;
     finally
      comp1.free;
      writer.Free;
     end;
    end;
   end;
   binstream.Position:= 0;
   while binstream.Position < binstream.Size do begin
    objectbinarytotextmse(binstream,textstream);
   end;
   textstream.Position:= 0;
   result:= textstream.readdatastring;
  finally
   binstream.Free;
   textstream.Free;
  end;
 end;
end;

function tdesignerselections.getobjinfoar: objinfoarty;
var
 int1: integer;   
 co1: tcomponent;
 binstream: tmemorystream;
 textstream: ttextstream;
 writer: twritermse;
begin
 result:= nil;
 for int1:= 0 to count - 1 do begin
  co1:= items[int1];
  if not isembedded(co1) then begin
   setlength(result,high(result)+2);
   with result[high(result)] do begin
    owner:= co1.owner;
    if co1 is twidget then begin
     parent:= twidget(co1).parentwidget;
    end
    else begin
     parent:= nil;
    end;
    binstream:= tmemorystream.create;
    writer:= twritermse.create(binstream,4096,true);
    textstream:= ttextstream.create;
    try
     writer.root:= co1.owner;
     {$ifndef FPC}
     writer.writesignature;
     {$endif}
     writer.writecomponent(co1);
     freeandnil(writer);
     binstream.position:= 0;
     objectbinarytotextmse(binstream,textstream);
     textstream.position:= 0;
     objtext:= textstream.readdatastring;
    finally
     writer.free;
     binstream.free;
     textstream.free;
    end;   
   end;
  end;
 end; 
end;

procedure tdesignerselections.copytoclipboard;
begin
 msewidgets.copytoclipboard(getobjecttext);
end;

procedure tdesignerselections.doadd(component: tcomponent);
begin
 add(component);
end;

procedure tdesignerselections.dosetactcomp(component: tcomponent);
begin
 factcomp:= component;
end;

function getglobalcomponent(const Name: string): TComponent;
begin
 result:= designer.modules.findmoduleinstancebyname(name);
end;

var
 pastingmodulepo: pmoduleinfoty;
 
procedure tdesignerselections.findpastemethod(Reader: TReader;
           const aMethodName: string; var Address: Pointer; var Error: Boolean);
var
 methodinfopo: pmethodinfoty;
begin
 error:= false;
 if pastingmodulepo <> nil then begin
  methodinfopo:= pastingmodulepo^.methods.findmethodbyname(amethodname);
  if methodinfopo <> nil then begin
   address:= methodinfopo^.address;
  end;
 end;
end;

const
 pastenametrailer = '_15dtz4u67sd3r';

procedure tdesignerselections.referencepastename(reader: treader; var name: string);
begin
 if (reader.root = fpasteroot) and (fpasteroot.findcomponent(name) = nil) and
        (fpasteowner.findcomponent(name+pastenametrailer) <> nil) then begin
  name:= name + pastenametrailer; 
            //this is dangerous, there could be a component with the same name 
            //but another class type, no possibility found to access the 
            //propertyinfo of the resolving items :-(
 end;
end;

function tdesignerselections.pastefromobjecttext(const aobjecttext: string; 
         aowner,aparent: tcomponent; initproc: initcomponentprocty): integer;
                  //returns count of added components
var
 binstream: tmemorystream;
 textstream: ttextstream;
 int1: integer;
 countbefore: integer;
 reader: treader;
 comp1,comp2: tcomponent;
 listend: tvaluetype;
 validaterenamebefore: validaterenameeventty;
 
begin
 if aobjecttext = '' then begin
  result:= 0;
  exit;
 end; 
 if aowner is tmsecomponent then begin
  pastingmodulepo:= designer.modules.findmodule(tmsecomponent(aowner));
 end
 else begin
  pastingmodulepo:= nil;
 end;
 countbefore:= count;
 try
  designer.beginpasting;
  fpasteowner:= aowner;
  textstream:= ttextstream.Create;
  comp1:= tcomponent.create(nil);
  fpasteroot:= comp1;
  tcomponent1(comp1).SetDesigning(true{$ifndef FPC},false{$endif});
  lockfindglobalcomponent;
  RegisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
  try
   listend:= vanull;
   textstream.writeln('object comp1: tcomponent');
   textstream.writestr(aobjecttext);
   textstream.writeln('end');
   textstream.Position:= 0;
   binstream:= tmemorystream.Create;
   try
    while textstream.position < textstream.Size do begin
     binstream.Position:= 0;
     objecttexttobinarymse(textstream,binstream);
     binstream.Write(listend,sizeof(listend));
     binstream.Position:= 0;
     reader:= treader.create(binstream,4096);
     try
      reader.onreferencename:= {$ifdef FPC}@{$endif}referencepastename;
      reader.onfindmethod:= {$ifdef FPC}@{$endif}findpastemethod;
      reader.onancestornotfound:= {$ifdef FPC}@{$endif}designer.ancestornotfound;
      reader.onfindcomponentclass:= 
                           {$ifdef FPC}@{$endif}designer.findcomponentclass;
      reader.oncreatecomponent:= {$ifdef FPC}@{$endif}designer.createcomponent;
      factcomp:= nil;
      begingloballoading;
      validaterenamebefore:= ondesignvalidaterename;
      ondesignvalidaterename:= nil; //no sourceupdate
      try
       with getcomponentlist(comp1) do begin
        for int1:= 0 to aowner.componentcount - 1 do begin
         comp2:= aowner.components[int1];
         comp2.name:= comp2.name + pastenametrailer; //avoid nameclash
         add(comp2);
        end;
       end;
       try
        reader.readrootcomponent(comp1);
       finally
        for int1:= 0 to aowner.componentcount - 1 do begin
         comp2:= aowner.components[int1];
         comp2.name:= copy(comp2.name,1,length(comp2.name) - 
                                              length(pastenametrailer));
                                 //restore original name
        end;
       end;
      finally
       ondesignvalidaterename:= validaterenamebefore;
      end;
      for int1:= aowner.componentcount to comp1.componentcount - 1 do begin
       comp2:= comp1.components[int1];
       designer.doswapmethodpointers(comp2,true);
       if (comp2.getparentcomponent = nil) or (comp2 is tmsedatamodule) then begin
        add(comp2);
       end;
      end;
      removefixupreferences(comp1,'');
      clearpastedcomponents;
      if assigned(initproc) then begin
       for int1:= comp1.componentcount - 1 downto aowner.componentcount do begin
        comp2:= comp1.components[int1]; 
        if (comp2.getparentcomponent = nil) or (comp2 is tmsedatamodule) then begin
         initproc(comp2,aparent);
        end;
       end;
      end;
      if pastingmodulepo <> nil then begin
       designer.checkmethodtypes(pastingmodulepo,false{,comp1});  
      end;
      notifygloballoading;
     finally
      endgloballoading;
      clearpastedcomponents;
      reader.Free;
     end;
    end;
   finally
    binstream.Free;
   end;
  finally
   designer.endpasting;
   unlockfindglobalcomponent;
   unRegisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
   textstream.Free;
   clearcomponentlist(comp1);
   comp1.Free;
  end;
 except
  for int1:= countbefore to count - 1 do begin
   items[int1].Free;
  end;
  count:= countbefore;
  application.handleexception;
 end;
 result:= count - countbefore;
end;

function tdesignerselections.pastefromclipboard(aowner,aparent: tcomponent;
                initproc: initcomponentprocty): integer;
                  //returns count of added components
var
 str1: msestring;
begin
 result:= 0;
 if msewidgets.pastefromclipboard(str1) then begin
  result:= pastefromobjecttext(str1,aowner,aparent,initproc);
 end;
end;

{ tdesignnotifications }

procedure tdesignnotifications.RegisterNotification(const DesignNotification: IDesignNotification);
begin
 if indexof(pointer(designnotification)) = -1 then begin
  add(pointer(designnotification));
 end;
end;

procedure tdesignnotifications.UnregisterNotification(const DesignNotification: IDesignNotification);
begin
 if self <> nil then begin
  extract(pointer(designnotification));
 end;
end;
{
procedure tdesignnotifications.DesignerClosed(const ADesigner: IDesigner;
  AGoingDormant: Boolean);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).DesignerClosed(adesigner,agoingdormant);
 end;
end;

procedure tdesignnotifications.DesignerOpened(const ADesigner: IDesigner;
  AResurrecting: Boolean);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).Designeropened(adesigner,aresurrecting);
 end;
end;
}
procedure tdesignnotifications.ItemDeleted(const ADesigner: IDesigner;
                const amodule: tmsecomponent; const AItem: tcomponent);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).itemdeleted(adesigner,amodule,aitem);
 end;
end;

procedure tdesignnotifications.ItemInserted(const ADesigner: IDesigner;
                const amodule: tmsecomponent; const AItem: tcomponent);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).iteminserted(adesigner,amodule,aitem);
 end;
end;

procedure tdesignnotifications.ItemsModified(const ADesigner: IDesigner;
  const aitem: tobject);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).itemsmodified(adesigner,aitem);
 end;
end;

procedure tdesignnotifications.SelectionChanged(const ADesigner: IDesigner;
  const ASelection: IDesignerSelections);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).selectionchanged(adesigner,aselection);
 end;
end;

procedure tdesignnotifications.moduleactivated(const adesigner: idesigner;
                  const amodule: tmsecomponent);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).moduleactivated(adesigner,amodule);
 end;
end;

procedure tdesignnotifications.moduledeactivated(const adesigner: idesigner;
                  const amodule: tmsecomponent);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).moduledeactivated(adesigner,amodule);
 end;
end;

procedure tdesignnotifications.moduledestroyed(const adesigner: idesigner;
                  const amodule: tmsecomponent);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).moduledestroyed(adesigner,amodule);
 end;
end;

procedure tdesignnotifications.methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).methodcreated(adesigner,amodule,aname,atype);
 end;
end;

procedure tdesignnotifications.methodnamechanged(
  const adesigner: idesigner; const amodule: tmsecomponent; const newname,
  oldname: string; const atypeinfo: ptypeinfo);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).methodnamechanged(adesigner,amodule,
           newname,oldname,atypeinfo);
 end;
end;

procedure tdesignnotifications.showobjecttext(const adesigner: idesigner; 
              const afilename: filenamety; const backupcreated: boolean);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).showobjecttext(adesigner,afilename,
                                  backupcreated);
 end;
end;

procedure tdesignnotifications.closeobjecttext(const adesigner: idesigner;
               const afilename: filenamety; out cancel: boolean);
var
 int1: integer;
begin
 cancel:= false;
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).closeobjecttext(adesigner,afilename,cancel);
  if cancel then begin
   break;
  end;
 end;
end;

procedure tdesignnotifications.componentnamechanging(
  const adesigner: idesigner; const amodule: tmsecomponent;
  const aitem: tcomponent; const newname: string);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).componentnamechanging(adesigner,amodule,
           aitem,newname);
 end;
end;

procedure tdesignnotifications.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).moduleclassnamechanging(adesigner,amodule,
           newname);
 end;
end;

procedure tdesignnotifications.instancevarnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).instancevarnamechanging(adesigner,amodule,
                                                     newname);
 end;
end;

procedure tdesignnotifications.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).beforefilesave(adesigner,afilename);
 end;
end;

procedure tdesignnotifications.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  if abort then begin 
   break;
  end;
  idesignnotification(fitems[int1]).beforemake(adesigner,maketag,abort);
 end;
end;

procedure tdesignnotifications.aftermake(const adesigner: idesigner;
                          const exitcode: integer);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  idesignnotification(fitems[int1]).aftermake(adesigner,exitcode);
 end;
end;

{ tunitgroups }

constructor tunitgroups.create;
begin
 inherited create(sizeof(unitgroupinfoty),[rels_needsfinalize,rels_needscopy]);
end;

procedure tunitgroups.registergroups(const adependents: array of string; 
                                                const agroup: array of string);
var
 info: unitgroupinfoty;
 int1: integer;
begin
 with info do begin
  setlength(dependents,length(adependents));
  for int1:= 0 to high(adependents) do begin
   dependents[int1]:= struppercase(adependents[int1]);
  end;
  setlength(group,length(agroup));
  for int1:= 0 to high(agroup) do begin
   group[int1]:= agroup[int1];
  end;
 end;
 add(info);
end;

procedure tunitgroups.finalizerecord(var item);
begin
 finalize(unitgroupinfoty(item));
end;

procedure tunitgroups.copyrecord(var item);
begin
 with unitgroupinfoty(item) do begin
  arrayaddref(dependents);
  arrayaddref(group);
 end;
end;

function tunitgroups.getneededunits(const aunitname: string): stringarty;
//todo: optimize

 procedure doget(const aname: string; out resnormal,resupper: stringarty);
 var
  po1: punitgroupinfoty;
  int1,int2,int3,int4: integer;
 begin
  resnormal:= nil;
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   for int2:= 0 to high(po1^.dependents) do begin
    if aname = po1^.dependents[int2] then begin
     int3:= length(resnormal);
     setlength(resnormal,int3+length(po1^.group));
     for int4:= int3 to high(resnormal) do begin
      resnormal[int4]:= po1^.group[int4-int3];
     end;
     break;
    end;
   end;
   inc(po1);
  end;
  setlength(resnormal,high(resnormal)+2);
  resnormal[high(resnormal)]:= aunitname; //add dependent
  setlength(resupper,length(resnormal));
  for int1:= 0 to high(resnormal) do begin
   resupper[int1]:= struppercase(resnormal[int1]);
  end;
 end;
 
var
 ar1,ar2: stringarty;
 ar3: integerarty;
 ar4,ar5n,ar5u: stringarty;
 int1,int2{,int3,int4}: integer;
 str1: string;
 level: integer;
 highbefore: integer;
 
begin
 setlength(ar4,1);
 ar4[0]:= struppercase(aunitname);
 level:= 0;
 repeat
  highbefore:= high(ar4);
  ar5n:= nil;
  ar5u:= nil;
  for int1:= 0 to high(ar4) do begin
   doget(ar4[int1],ar1,ar2);
   stackarray(ar1,ar5n);
   stackarray(ar2,ar5u);
  end;
  sortarray(ar5u,{$ifdef FPC}@{$endif}compareasciistring,ar3);
  setlength(ar4,length(ar5u));
  setlength(result,length(ar5u));
  str1:= '';
  int2:= 0;
  for int1:= 0 to high(ar5u) do begin
   if ar5u[int1] <> str1 then begin
    ar4[int2]:= ar5u[int1];
    str1:= ar4[int2];
    result[int2]:= ar5n[ar3[int1]];
    inc(int2);
   end;
  end;
  setlength(ar4,int2);
  inc(level);
 until (high(ar4) = highbefore) or (level > 16);
 setlength(result,length(ar4));
end;

{$ifdef FPC}
procedure checkreversedcomponentpos;
var
 comp1: tcomponent;
 writer1: twritermse;
 reader1: treader;
 stream1: tmemorystream;
 int1: integer;
 str1: string;
begin
 comp1:= tcomponent.create(nil);
 comp1.designinfo:= 1;
 stream1:= tmemorystream.create;
 writer1:= twritermse.create(stream1,256,false);
{$warnings off}
 twriter1(writer1).writeproperties(comp1);
{$warnings on}
 writer1.free;
 stream1.position:= 0;
 reader1:= treader.create(stream1,256);
 str1:= reader1.driver.beginproperty;
 int1:= reader1.readinteger;
 componentposreversed:= (int1 = 1) xor (str1 = 'left');
 reader1.free;
 stream1.free;
 comp1.free;
end;
{$endif}

initialization
 {$ifdef FPC}
 checkreversedcomponentpos;
 {$endif}
 adesignnotifications:= tdesignnotifications.Create;
// aregisteredcomponents:= tcomponentclasslist.create;
finalization
 freeandnil(adesignnotifications);
 freeandnil(aregisteredcomponents);
 freeandnil(aunitgroups);
end.
