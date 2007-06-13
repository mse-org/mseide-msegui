{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
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
unit msedesigner;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,msegraphutils,mseguiglob,msedesignintf,
 mseforms,mselist,msedatalist,msebitmap,msetypes,sysutils,msehash,mseclasses,
 mseformdatatools,typinfo,msepropertyeditors,msecomponenteditors,msegraphics,
 msegui,msestrings;

const
 formfileext = 'mfm';
 pasfileext = 'pas';
 backupext = '.bak';

type
 tdesigner = class;

 methodinfoty = record
  name: string;
  address: pointer;
  typeinfo: ptypeinfo;
 end;
 pmethodinfoty = ^methodinfoty;

 tmethods = class(tbucketlist)
  private
   fdesigner: tdesigner;
   {fapropname,fapropvalue: string;}
   fmethodtable: pointer;
  protected
   procedure freedata(var data); override;
   procedure deletemethod(const aadress: pointer);
   procedure addmethod(const aname: string; const aaddress: pointer;
                       const atypeinfo: ptypeinfo);
  public
   constructor create(adesigner: tdesigner);
   destructor destroy; override;
   function findmethod(const aadress: pointer): pmethodinfoty;
   function findmethodbyname(const aname: string;
         const atype: ptypeinfo; out namefound: boolean): pmethodinfoty; overload;
   function findmethodbyname(const aname: string): pmethodinfoty; overload;
   function createmethodtable: pointer;
   procedure releasemethodtable;
 end;

 tcomponents = class;

 tcomponentslink = class(tcomponent)
  private
   fowner: tcomponents;
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
 end;

 componentnamety = record
  instance: tcomponent;
  dispname: string;
 end;
 componentnamearty = array of componentnamety;

 moduleinfoty = record
  filename: msestring;
  backupcreated: boolean;
  moduleclassname: string[80]; //can not be ansistring!
  instancevarname: string;
  instance: tmsecomponent;
  moduleintf: pdesignmoduleintfty;
  designformclass: pointer;
  methods: tmethods;
  methodtableswapped: integer;
  components: tcomponents;
  designform: tmseform;
  modified: boolean;
  referencedmodules: stringarty;
  methodtablebefore: pointer;
  resolved: boolean;
 end;
 pmoduleinfoty = ^moduleinfoty;
 moduleinfopoarty = array of pmoduleinfoty;
 
 tcomponents = class(tbucketlist)
  private
   fdesigner: tdesigner;
   fcomponent: tcomponentslink; // to receive componentnotifications
   famodule: tcomponent;
   fowner: pmoduleinfoty;
   procedure doadd(component: tcomponent);
  protected
   procedure freedata(var data); override;
   function find(const value: tobject): pcomponentinfoty;
   procedure destroynotification(const acomponent: tcomponent);
   procedure swapcomponent(const old,new: tcomponent);
  public
   constructor create(const aowner: pmoduleinfoty; const adesigner: tdesigner);
   destructor destroy; override;
   procedure assigncomps(const module: tmsecomponent);
   procedure add(comp: tcomponent);
   function next: pcomponentinfoty;
   function getcomponents: componentarty;
   function getdispnames: componentnamearty;
   function getcomponent(const aname: string): tcomponent;
   procedure namechanged(const acomponent: tcomponent; const newname: string);
 end;

 tmoduleinfo = class(tlinkedobject)
  protected
   fdesigner: tdesigner;
  public
   info: moduleinfoty;
   constructor create(adesigner: tdesigner);
   destructor destroy; override;
 end;

 pmoduleinfo = ^tmoduleinfo;

 tmodulelist = class(tlinkedobjectqueue)
  private
   fdesigner: tdesigner;
   function getitempo1(const index: integer): pmoduleinfoty;
  protected
   function newmodule(const ainherited: boolean; const afilename: msestring;
                const amoduleclassname,ainstancevarname,
                     designmoduleclassname: string): tmoduleinfo;
   function findmethodbyname(const name: string; const atype: ptypeinfo;
                               const amodule: tmsecomponent): tmethod;
   function findmethodname(const method: tmethod; const comp: tcomponent): string;
   function findform(aform: tmseform): pmoduleinfoty;
   function removemoduleinfo(po: pmoduleinfoty): integer;
   procedure componentmodified(const acomponent: tobject);

  public
   constructor create(adesigner: tdesigner); reintroduce;
   function delete(index: integer): pointer; override;
   function findmodule(const filename: msestring): pmoduleinfoty; overload;
   function findmodule(const amodule: tmsecomponent): pmoduleinfoty; overload;
   function findmodule(const po: pmoduleinfoty): integer;  overload;
   function findmodulebyname(const name: string): pmoduleinfoty;
   function findmoduleinstancebyname(const name: string): tcomponent;
   function findmoduleinstancebyclass(const aclass: tclass): tcomponent;
   function findmodulebyclassname(aclassname: string): pmoduleinfoty;
   function findmodulebycomponent(const acomponent: tobject): pmoduleinfoty;
   function findmodulebyinstance(const ainstance: tcomponent): pmoduleinfoty;
   function filenames: filenamearty;

   property itempo[const index: integer]: pmoduleinfoty read getitempo1; default;
 end;

 tdesignformlist = class(tcomponentqueue)
  private
   function getitems(const index: integer): tmseform;//tformdesignerfo;
  public
   property items[const index: integer]: tmseform read getitems; default;
 end;

 ancestorinfoty = record
  descendent,ancestor: tmsecomponent
 end;
 pancestorinfoty = ^ancestorinfoty;
 ancestorinfoaty = array[0..0] of ancestorinfoty;
 pancestorinfoaty = ^ancestorinfoaty;

 tancestorlist = class(tobjectlinkrecordlist)
  private
   fstreaming: integer;
   fswappedancestors: componentarty;
  protected
   procedure dounlink(var item); override;
   procedure itemdestroyed(const sender: iobjectlink); override;
  public
   constructor create;
   function findancestor(const adescendent: tcomponent): tmsecomponent;
   function finddescendent(const aancestor: tcomponent): tmsecomponent;
   function finddescendentinfo(const adescendent: tcomponent): pancestorinfoty;
   function findancestorinfo(const aancestor: tcomponent): pancestorinfoty;
   procedure add(const adescendent,aancestor: tmsecomponent);
   procedure beginstreaming;
   procedure endstreaming;
 end;

 tdesignerancestorlist = class(tancestorlist)
  private
   fdesigner: tdesigner;
  public
   constructor create(aowner: tdesigner);
 end;

 tsubmodulelist = class(tdesignerancestorlist)
       //ancestor is copy of old state of descendent,
       //descendent is real submodule
  protected
   procedure finalizerecord(var item); override;
  public
   procedure add(const amodule: tmsecomponent);
   procedure renewbackup(const amodule: tmsecomponent);
 end;

 treaderrorhandler = class(tcomponent)
  private
   fcomponentar: componentarty;
   fnewcomponents: componentarty;
   froot: tcomponent;
   procedure doraise(const acomponent: tcomponent);
   procedure ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
   procedure onsetname(reader: treader; component: tcomponent; var aname: string);
   procedure onerror(reader: treader; const message: string; var handled: boolean);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation);
                               override;        
  public
   destructor destroy; override;   
 end;
 
 tdescendentinstancelist = class(tdesignerancestorlist)
  private
   ferrorhandler: treaderrorhandler;
   fdelcomps:componentarty;
   froot: tcomponent;
   fmodule: pmoduleinfoty;
   fmodifiedlevel: integer;
   procedure delcomp(child: tcomponent);
   procedure addcomp(child: tcomponent);
  protected
   procedure modulemodified(const amodule: pmoduleinfoty);
   procedure revert(const info: pancestorinfoty; const module: pmoduleinfoty;
                    const norootposition: boolean = false);
   procedure setnodefaultpos(const aroot: twidget);
   procedure restorepos(const aroot: twidget);
  public
   procedure add(const instance,ancestor: tmsecomponent;
                                         const submodulelist: tsubmodulelist);
   function getclassname(const comp: tcomponent): string;
                   //returns submodule or root classname if appropriate
   function getancestors(const adescendent: tcomponent): componentarty;
   function getdescendents(const aancestor: tcomponent): componentarty;
 end;

 getmoduleeventty = procedure(const amodule: pmoduleinfoty;
                             const aname: string; var action: modalresultty) of object;
                                      //mr_ignore,mr_ok, cancel otherwise
 getmoduletypeeventty = procedure(const atypename: string) of object;

 tdesigner = class(tguicomponent,idesigner)
  private
   fselections: tdesignerselections;
   factmodulepo: pmoduleinfoty;
   floadingmodulepo: pmoduleinfoty;
   fmodules: tmodulelist;
   fcomponenteditor: tcomponenteditor;
   fobjformat: objformatty;
   fsubmoduleinfopo: pmoduleinfoty;
   fsubmodulelist: tsubmodulelist;
   fdescendentinstancelist: tdescendentinstancelist;
   fdesignfiles: tindexedfilenamelist;
   fongetmodulenamefile: getmoduleeventty;
   fongetmoduletypefile: getmoduletypeeventty;
   fnotifymodule: tmsecomponent;
   fcomponentmodifying: integer;
   floadedsubmodules: componentarty;
   fformloadlevel: integer;
   flookupmodule: pmoduleinfoty;
   fnotifydeletedlock: integer;
   fallsaved: boolean;
   function formfiletoname(const filename: msestring): msestring;
   procedure findmethod(Reader: TReader; const aMethodName: string;
                   var Address: Pointer; var Error: Boolean);
   procedure findmethod2(Reader: TReader; const aMethodName: string;
                   var Address: Pointer; var Error: Boolean);
   procedure findcomponentclass(Reader: TReader; const aClassName: string;
                   var ComponentClass: TComponentClass);
   procedure ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
   procedure createcomponent(Reader: TReader; ComponentClass: TComponentClass;
                   var Component: TComponent);
   procedure findancestor(Writer: TWriter; Component: TComponent;
              const aName: string; var Ancestor, RootAncestor: TComponent);
   function getinheritedmodule(const aclassname: string): pmoduleinfoty;
   function findcomponentmodule(const acomponent: tcomponent): pmoduleinfoty;
   procedure selectionchanged;
   procedure docopymethods(const source, dest: tcomponent; const force: boolean);
//   procedure dorefreshmethods(const descendent,newancestor,oldancestor: tcomponent);
   procedure writemodule(const amodule: pmoduleinfoty; const astream: tstream);
   procedure notifydeleted(comp: tcomponent);
   procedure componentdestroyed(const acomponent: tcomponent; const module: pmoduleinfoty);
   procedure dofixup;
   procedure buildmethodtable(const amodule: pmoduleinfoty);
   procedure releasemethodtable(const amodule: pmoduleinfoty);
  protected
   procedure componentevent(const event: tcomponentevent); override;
   function checkmodule(const filename: msestring): pmoduleinfoty;
   procedure checkident(const aname: string);
   procedure beginstreaming(const amodule: pmoduleinfoty);
   procedure endstreaming(const amodule: pmoduleinfoty);
   property selections: tdesignerselections read fselections;
                 //do not modify!
  public
   constructor create; reintroduce;
   destructor destroy; override;

   procedure begincomponentmodify;
   procedure endcomponentmodify;
   
   procedure modulechanged(const amodule: pmoduleinfoty);
   function changemodulename(const filename: msestring; const avalue: string): string;
   function changemoduleclassname(const filename: msestring; const avalue: string): string;
   function changeinstancevarname(const filename: msestring; const avalue: string): string;
   function checksubmodule(const ainstance: tcomponent; 
              out aancestormodule: pmoduleinfoty): boolean;
   function getreferencingmodulenames(const amodule: pmoduleinfoty): stringarty;
   function checkmethodtypes(const amodule: pmoduleinfoty;
            const init: boolean; const quiet: tcomponent): boolean;
               //does correct errors quiet for tmethod.data = quiet
   procedure doswapmethodpointers(const ainstance: tobject;
                        const ainit: boolean);
   
      //idesigner
   procedure componentmodified(const component: tobject);
   procedure selectcomponent(instance: tcomponent);
   procedure setselections(const list: idesignerselections);
   function createnewcomponent(const module: tmsecomponent;
                                 const aclass: tcomponentclass): tcomponent;
   function createcurrentcomponent(const module: tmsecomponent): tcomponent;
   function hascurrentcomponent: boolean;
   procedure addcomponent(const module: tmsecomponent; const acomponent: tcomponent);
   procedure deleteselection(adoall: boolean = false);
   procedure deletecomponent(const acomponent: tcomponent);
   procedure clearselection;
   procedure noselection;

   function getmethod(const aname: string; const methodowner: tmsecomponent;
                        const atype: ptypeinfo): tmethod;
   function getmethodname(const method: tmethod; const comp: tcomponent): string;
   procedure changemethodname(const method: tmethod; newname: string;
                                           const atypeinfo: ptypeinfo);
   function createmethod(const aname: string; const module: tmsecomponent;
                                 const atype: ptypeinfo): tmethod;
   
   function getcomponentname(const comp: tcomponent): string;
                   //returns qualified name for foreign modules
   function getcomponentdispname(const comp: tcomponent): string;
                   //returns qualified name into root
   procedure validaterename(const acomponent: tcomponent;
                      const curname, newname: string); reintroduce;
   function getclassname(const comp: tcomponent): string;
                   //returns submoduleclassname if appropriate
   function getcomponent(const aname: string; 
                               const aroot: tcomponent): tcomponent;
                   //handles qualified names for foreign forms
   function componentcanedit: boolean;
   function getcomponenteditor: icomponenteditor;
   function getcomponentlist(const acomponentclass: tcomponentclass): componentarty;
   function getcomponentnamelist(const acomponentclass: tcomponentclass;
                                 const includeinherited: boolean;
                                 const aowner: tcomponent = nil): msestringarty;
   procedure setmodulex(const amodule: tmsecomponent; avalue: integer);
   procedure setmoduley(const amodule: tmsecomponent; avalue: integer);


   procedure getmethodinfo(const method: tmethod; out moduleinfo: pmoduleinfoty;
                      out methodinfo: pmethodinfoty);
   function getmodules: tmodulelist;

   function loadformfile(filename: msestring): pmoduleinfoty;
   function saveformfile(const modulepo: pmoduleinfoty;
                 const afilename: msestring; createdatafile: boolean): boolean;
                        //false if canceled
   function saveall(noconfirm,createdatafile: boolean): modalresultty;
   procedure savecanceled; //resets fallsaved
   procedure setactivemodule(const adesignform: tmseform);
   function sourcenametoformname(const aname: filenamety): filenamety;

   function closemodule(const amodule: pmoduleinfoty;
                     const checksave: boolean): boolean; //true if closed
   procedure showformdesigner(const amodule: pmoduleinfoty);
   procedure showastext(const amodule: pmoduleinfoty);
   procedure showobjectinspector;
   function actmodulepo: pmoduleinfoty;
   function modified: boolean;
   procedure moduledestroyed(const amodule: pmoduleinfoty);
   procedure addancestorinfo(const ainstance,aancestor: tmsecomponent);
   function copycomponent(const source: tmsecomponent;
                          const root: tmsecomponent):tmsecomponent;
   procedure revert(const acomponent: tcomponent);
   function checkcanclose(const amodule: pmoduleinfoty; out references:  string): boolean;

   property modules: tmodulelist read getmodules;
   property descendentinstancelist: tdescendentinstancelist read 
                                                  fdescendentinstancelist;

   property objformat: objformatty read fobjformat write fobjformat default of_default;
   property designfiles: tindexedfilenamelist read fdesignfiles;

   property ongetmodulenamefile: getmoduleeventty read fongetmodulenamefile
                   write fongetmodulenamefile;
   property ongetmoduletypefile: getmoduletypeeventty read fongetmoduletypefile
                   write fongetmoduletypefile;

 end;

procedure createbackupfile(const newname,origname: filenamety;
                      var backupcreated: boolean; const backupcount: integer);
           
function designer: tdesigner;

implementation

uses
 msestream,msefileutils,{$ifdef mswindows}windows{$else}libc{$endif},
 designer_bmp,msesys,msewidgets,formdesigner,mseevent,objectinspector,
 msefiledialog,projectoptionsform,sourceupdate,sourceform,pascaldesignparser,
 msearrayprops;

type
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 twriter1 = class(twriter);
 treader1 = class(treader);

 moduleeventty = (me_none,me_componentmodified);

var
 fdesigner: tdesigner;
 loadingdesigner: tdesigner;
 methodaddressdummy: cardinal;
 submodulecopy: integer;

function designer: tdesigner;
begin
 result:= fdesigner;
end;

function ismodule(const acomponent: tcomponent): boolean;
begin
 result:= (acomponent.owner = nil) or (acomponent.owner.owner = nil);
end;

function getglobalcomponent(const Name: string): TComponent;
begin
 if (loadingdesigner <> nil) or (submodulecopy > 0) then begin
  result:= fdesigner.fmodules.findmoduleinstancebyname(name);
 end
 else begin
  result:= nil;
 end;
end;

procedure beginsubmodulecopy;
begin
 inc(submodulecopy);
 if submodulecopy = 1 then begin
  lockfindglobalcomponent;
  RegisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
 end;
end;

procedure endsubmodulecopy;
begin
 dec(submodulecopy);
 if submodulecopy = 0 then begin
  unlockfindglobalcomponent;
  unregisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
 end;
end;

type
 propprocty = procedure(const ainstance: tobject; const data: pointer; 
                const apropinfo: ppropinfo);
                
procedure forallmethodproperties(const ainstance: tobject; const data: pointer;
                              const aproc: propprocty; const docomps: boolean);
var
 ar1: propinfopoarty;
 int1,int2: integer;
 obj1: tobject;
 bo1: boolean;
begin
 if ainstance is tcomponent then begin
  bo1:= not (csloading in tcomponent(ainstance).componentstate);
  if bo1 then begin
   setloading(tcomponent(ainstance),true);
  end;
 end
 else begin
  bo1:= false;
 end;
 ar1:= getpropinfoar(ainstance);
 for int1:= 0 to high(ar1) do begin
  case ar1[int1]^.proptype^.kind of
   tkmethod: begin
    aproc(ainstance,data,ar1[int1]);
   end;
   tkclass: begin
    obj1:= getobjectprop(ainstance,ar1[int1]);
    if (obj1 <> nil) and (not (obj1 is tcomponent) or 
              (cssubcomponent in tcomponent(obj1).componentstyle)) then begin
     forallmethodproperties(obj1,data,aproc,docomps);
     if obj1 is tpersistentarrayprop then begin
      with tpersistentarrayprop(obj1) do begin
       for int2:= 0 to count - 1 do begin
        forallmethodproperties(items[int2],data,aproc,docomps);
       end;
      end;
     end
     else begin
      if obj1 is tcollection then begin
       with tcollection(obj1) do begin
        for int2:= 0 to count - 1 do begin
         forallmethodproperties(items[int2],data,aproc,docomps);
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 if docomps and (ainstance is tcomponent) then begin
  with tcomponent(ainstance) do begin
   for int1:= 0 to componentcount - 1 do begin
    forallmethodproperties(components[int1],data,aproc,docomps);
   end;
  end;
 end;
 if bo1 then begin
  setloading(tcomponent(ainstance),false);
 end;
end;

{ tancestorlist }

constructor tancestorlist.create;
begin
 inherited create(sizeof(ancestorinfoty));
end;

procedure tancestorlist.itemdestroyed(const sender: iobjectlink);
var
 int1: integer;
 comp: tmsecomponent;
begin
 comp:= tmsecomponent(sender.getinstance);
 for int1:= count - 1 downto 0 do begin
  with pancestorinfoty(getitempo(int1))^ do begin
   if (descendent = comp) or (ancestor = comp) then begin
    delete(int1);
   end;
  end;
 end;
end;

procedure tancestorlist.add(const adescendent, aancestor: tmsecomponent);
var
 info: ancestorinfoty;
begin
 fillchar(info,sizeof(info),0);
 fobjectlinker.link(adescendent);
 fobjectlinker.link(aancestor);
 info.descendent:= adescendent;
 info.ancestor:= aancestor;
 inherited add(info);
end;

procedure tancestorlist.dounlink(var item);
begin
 with ancestorinfoty(item) do begin
  fobjectlinker.unlink(descendent);
  fobjectlinker.unlink(ancestor);
 end;
end;

function tancestorlist.findancestor(const adescendent: tcomponent): tmsecomponent;
var
 po1: pancestorinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if po1^.descendent = adescendent then begin
   result:= po1^.ancestor;
   break;
  end;
  inc(po1);
 end;
 if (fstreaming > 0) and (result <> nil) then begin
  if finditem(pointerarty(fswappedancestors),result) < 0 then begin
   designer.doswapmethodpointers(result,false);
   additem(pointerarty(fswappedancestors),result);
  end;
 end;
end;

procedure tancestorlist.beginstreaming;
begin
 inc(fstreaming);
end;

procedure tancestorlist.endstreaming;
var
 int1: integer;
 ar1: componentarty;
begin
 ar1:= nil; //compiler warning
 dec(fstreaming);
 if fstreaming = 0 then begin
  ar1:= copy(fswappedancestors);
  fswappedancestors:= nil;
  for int1:= 0 to high(ar1) do begin
   designer.doswapmethodpointers(ar1[int1],true);
  end;
 end;
end;

function tancestorlist.finddescendent(const aancestor: tcomponent): tmsecomponent;
var
 po1: pancestorinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if po1^.ancestor = aancestor then begin
   result:= po1^.descendent;
   break;
  end;
  inc(po1);
 end;
end;

function tancestorlist.finddescendentinfo(const adescendent: tcomponent): pancestorinfoty;
var
 po1: pancestorinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if po1^.descendent = adescendent then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

function tancestorlist.findancestorinfo(const aancestor: tcomponent): pancestorinfoty;
var
 po1: pancestorinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if po1^.ancestor = aancestor then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

{ tdesignerancestorlist }

constructor tdesignerancestorlist.create(aowner: tdesigner);
begin
 fdesigner:= aowner;
 inherited create;
end;

{ tsubmodulelist }

procedure tsubmodulelist.finalizerecord(var item);
var
 comp: tmsecomponent;
begin
 with ancestorinfoty(item) do begin
  comp:= ancestor;
  ancestor:= nil;
 end;
 inherited;
 comp.Free;
end;

procedure tsubmodulelist.add(const amodule: tmsecomponent);
begin
 if findancestor(amodule) = nil then begin
  inherited add(amodule,fdesigner.copycomponent(amodule,amodule));
 end;
end;

procedure tsubmodulelist.renewbackup(const amodule: tmsecomponent);
var
 po1: pancestorinfoty;
 comp: tmsecomponent;
begin
 po1:= finddescendentinfo(amodule);
 if po1 <> nil then begin
  comp:= po1^.ancestor;
  po1^.ancestor:= nil;
  comp.Free;  
//  po1^.ancestor:= fdesigner.copycomponent(amodule,amodule);
  po1^.ancestor:= fdesigner.copycomponent(amodule,nil);
  fobjectlinker.link(po1^.ancestor);
 end;
end;


const
 skipmark = '1w%f62*7/*+z';
 
type
 trefreshexception = class(exception)
 end;
 
{ treaderrorhandler }

destructor treaderrorhandler.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fcomponentar) do begin
  fcomponentar[int1].free; //FPC does not free the component
 end;
 inherited;
end;

procedure treaderrorhandler.onerror(reader: treader; const message: string;
                        var handled: boolean);
begin
 if message = skipmark then begin
  handled:= true;
 end;
end;

procedure treaderrorhandler.notification(acomponent: tcomponent; operation: toperation);
begin
 if (operation = opremove) then begin
  removeitem(pointerarty(fcomponentar),acomponent);
  removeitem(pointerarty(fnewcomponents),acomponent);
 end;
 inherited;
end;

procedure treaderrorhandler.doraise(const acomponent: tcomponent);
begin  
 if acomponent <> nil then begin
  additem(pointerarty(fcomponentar),acomponent);
  acomponent.freenotification(self);
 end;
 raise trefreshexception.create(skipmark);
end;  

procedure treaderrorhandler.ancestornotfound(Reader: TReader;
                   const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
begin
 component:= findancestorcomponent(reader,componentname);
 if component = nil then begin
  doraise(nil); //changed name
 end;
end;

procedure treaderrorhandler.onsetname(reader: treader; 
                                    component: tcomponent; var aname: string);
begin
// if (component.owner <> nil) and (csinline in component.owner.componentstate) and
//        not (csancestor in component.componentstate) then begin
 if component.owner = froot then begin
  additem(pointerarty(fnewcomponents),component);
  component.freenotification(self);
//  doraise(component);    //new component placed into submodule
 end;
end;

{ tdescendentinstancelist }

procedure tdescendentinstancelist.delcomp(child: tcomponent);
begin
 tcomponent1(child).getchildren({$ifdef FPC}@{$endif}delcomp,froot);
 additem(pointerarty(fdelcomps),child);
end;

procedure tdescendentinstancelist.addcomp(child: tcomponent);
begin
 fmodule^.components.add(child);
 tcomponent1(child).getchildren({$ifdef FPC}@{$endif}addcomp,child);
end;

procedure tdescendentinstancelist.revert(const info: pancestorinfoty; 
            const module: pmoduleinfoty; const norootposition: boolean = false); 
var
 comp1,comp2: tmsecomponent;
 parent1: twidget;
 str1: string;
 int1: integer;
 isroot: boolean;
 ancestorclassname1: string;
 actualclassname1: pshortstring;
 pt1: pointty;
begin
 comp1:= info^.descendent;
 isroot:= comp1 = module^.instance;
 with tmsecomponent1(comp1) do begin
  ancestorclassname1:= fancestorclassname;
  actualclassname1:= factualclassname;
 end;
 
 info^.descendent:= nil;
 if comp1 is twidget then begin
  with twidget1(comp1) do begin
   parent1:= parentwidget;
   pt1:= tformdesignerfo(module^.designform).modulerect.pos;
  end;
 end
 else begin
  parent1:= nil;
  pt1:= getcomponentpos(comp1);
 end;
 str1:= comp1.name;
 fobjectlinker.unlink(comp1);
 fdelcomps:= nil;
 froot:= comp1.owner;
 if ismodule(comp1) then begin 
  froot:= comp1;
 end;
 delcomp(comp1);
 for int1:= 0 to high(fdelcomps) do begin
  fdelcomps[int1].free;
 end;
 fdelcomps:= nil;
 comp2:= fdesigner.copycomponent(info^.ancestor,info^.ancestor);
 if isroot then begin
  initrootdescendent(comp2);
 end;
 info^.descendent:= comp2;
 comp2.name:= str1;
 with tmsecomponent1(comp2) do begin
  fancestorclassname:= ancestorclassname1;
  factualclassname:= actualclassname1;
 end;
 tcomponent1(comp2).setancestor(true);
 if not isroot then begin
  tmsecomponent1(comp2).setinline(true);
 end;
 {
 if isroot then begin
  tcomponent1(comp2).setancestor(true);
 end
 else begin
  tmsecomponent1(comp2).setinline(true);
 end;
 }
// checkinline(comp2);
 fobjectlinker.link(comp2); 
 if isroot then begin
  module^.instance:= comp2;
  if norootposition then begin
   if (comp2 is twidget) then begin
    with twidget1(comp2) do begin
     fwidgetrect.pos:= pt1;              //do not restore position
    end;
   end
   else begin
    setcomponentpos(comp2,pt1);
   end;
  end;
  tformdesignerfo(module^.designform).module:= comp2;
 end
 else begin
  tmsecomponent1(comp2).setinline(true);
  module^.instance.insertcomponent(comp2);
 end;
 if parent1 <> nil then begin
  twidget(info^.descendent).parentwidget:= parent1;
 end;
 fmodule:= module;
 addcomp(comp2);
 removefixupreferences(module^.instance,'');
end;         

function tdescendentinstancelist.getancestors(
                               const adescendent: tcomponent): componentarty;
                               
 procedure addancestors(const adescendent: tcomponent);
 var
  po1: pointer;
  int1: integer;
 begin
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   with(pancestorinfoaty(po1)^[int1]) do begin
    if descendent = adescendent then begin
     if finditem(pointerarty(result),ancestor) < 0 then begin
      additem(pointerarty(result),ancestor);
     end;
     addancestors(ancestor);
    end
   end;
  end;
 end;
 
var
 po1: pointer;
 int1: integer;
 po2: pmoduleinfoty;
begin
 result:= nil;
 addancestors(adescendent);
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  with(pancestorinfoaty(po1)^[int1]) do begin
   if ancestor = adescendent then begin
    po2:= fdesigner.modules.findmodulebycomponent(descendent);
    if (po2 <> nil) and (finditem(pointerarty(result),po2^.instance) < 0) then begin
     additem(pointerarty(result),po2^.instance);
    end;
   end;
  end;
 end;
end;

function tdescendentinstancelist.getdescendents(
                                 const aancestor: tcomponent): componentarty;
var
 recursionlevel: integer;
 
 procedure adddescendent(const aancestor: tcomponent);
 var
  int1: integer;
  po1: pancestorinfoaty;
 begin
  dec(recursionlevel);
  if recursionlevel > 0 then begin
   po1:= datapo;
   for int1:= count - 1 downto 0 do begin
    with po1^[int1] do begin
     if ancestor = aancestor then begin
      additem(pointerarty(result),descendent);
      adddescendent(descendent);
     end;
    end;
   end;      
  end;
  inc(recursionlevel);
 end;
 
begin
 recursionlevel:= 32; //max
 adddescendent(aancestor);
end;
(*
procedure tdescendentinstancelist.modulemodified(const amodule: pmoduleinfoty);
type
 streamarty = array of tstream;
 ancestorinfopoarty = array of pancestorinfoty;

{$ifdef mse_debugsubmodule}
var
 teststream: ttextstream;
 procedure debugout(const atext: string; const stream: tstream);
 begin
  writeln(atext);
  stream.position:= 0;
  teststream.size:= 0;
  objectbinarytotextmse(stream,teststream);
  teststream.position:= 0;
  teststream.writetotext(output);
 end;
 procedure debugbinout(const atext: string; const acomp,aancestor: tcomponent);
 var
  stream1: tmemorystream;
  writer1: twriter;
 begin
  stream1:= tmemorystream.create;
  writer1:= twriter.create(stream1,1024);
  writer1.onfindancestor:= {$ifdef FPC}@{$endif}fdesigner.findancestor;
  writer1.writedescendent(acomp,aancestor);
  writer1.free;
  debugout(atext,stream1);
  stream1.free;
 end;
 
{$endif}

var
 modifiedowners,dependentmodules: moduleinfopoarty;
 streams: streamarty;
 infos: ancestorinfopoarty;
 stream1: tmemorystream;
 writer1: twriter;
 reader1: treader;
 comp1,ancestor: tcomponent;
 int1,int2: integer;
 po1: pancestorinfoty;
 po2: pmoduleinfoty;
 rect1: rectty;

begin
 if fmodifiedlevel >= 16 then begin
  exit;
 end;
 inc(fmodifiedlevel);
 try
  po1:= datapo;
  if fmodifiedlevel = 16 then begin
   showmessage('Recursive form inheritance of "'+
                               amodule^.filename+'".','ERROR');
   sysutils.abort;
  end;
  for int1:= 0 to fcount - 1 do begin
   if po1^.ancestor = amodule^.instance then begin
    additem(pointerarty(infos),po1);
    if ismodule(po1^.descendent) then begin  //inherited form        
     comp1:= po1^.descendent;
    end
    else begin
     comp1:= po1^.descendent.owner;
    end;
    po2:= fdesigner.modules.findmodule(tmsecomponent(comp1));
    additem(pointerarty(modifiedowners),po2);
    if finditem(pointerarty(dependentmodules),po2) < 0 then begin
     additem(pointerarty(dependentmodules),po2);
    end;
   end;
   inc(po1);
  end;
  if high(infos) >= 0 then begin
  {$ifdef mse_debugsubmodule}
   teststream:= ttextstream.create;
  {$endif}
   ancestor:= fdesigner.fsubmodulelist.findancestor(amodule^.instance);
   beginsubmodulecopy;
   try 
    setlength(streams,length(infos));
    for int1:= 0 to high(modifiedowners) do begin
     fdesigner.buildmethodtable(modifiedowners[int1]);
     if ismodule(infos[int1]^.descendent.owner) then begin //inherited form
      fdesigner.beginstreaming(modifiedowners[int1]);
     end;
     try
      streams[int1]:= tmemorystream.create;
      writer1:= twriter.create(streams[int1],4096);
      try
       writer1.onfindancestor:= {$ifdef FPC}@{$endif}fdesigner.findancestor;
       writer1.writedescendent(infos[int1]^.descendent,ancestor);
      finally
       if ismodule(infos[int1]^.descendent.owner) then begin //inherited form
        fdesigner.endstreaming(modifiedowners[int1]);
       end;
       writer1.free;
      end;
  {$ifdef mse_debugsubmodule}
      debugout('state ' + modifiedowners[int1]^.instance.name,streams[int1]);
  {$endif}
     finally
      fdesigner.releasemethodtable(modifiedowners[int1]);
     end;
    end;
    fdesigner.fsubmodulelist.renewbackup(amodule^.instance);
    ferrorhandler:= treaderrorhandler.create(nil);
    try
     for int1:= 0 to high(modifiedowners) do begin
      modifiedowners[int1]^.designform.window.beginmoving; //no flicker
      try
       streams[int1].position:= 0;
       revert(infos[int1],modifiedowners[int1],true);
       reader1:= treader.create(streams[int1],4096);
       fdesigner.buildmethodtable(modifiedowners[int1]);
       try
        reader1.onerror:= {$ifdef FPC}@{$endif}ferrorhandler.onerror;
        reader1.onancestornotfound:= 
                          {$ifdef FPC}@{$endif}ferrorhandler.ancestornotfound;
        reader1.onsetname:= {$ifdef FPC}@{$endif}ferrorhandler.onsetname;
        reader1.onfindcomponentclass:= 
                          {$ifdef FPC}@{$endif}fdesigner.findcomponentclass;
        reader1.oncreatecomponent:= {$ifdef FPC}@{$endif}fdesigner.createcomponent;
        reader1.onfindmethod:= {$ifdef FPC}@{$endif}fdesigner.findmethod2;
        reader1.root:= modifiedowners[int1]^.instance;
        ferrorhandler.fnewcomponents:= nil;
        reader1.root:= modifiedowners[int1]^.instance;
        ferrorhandler.froot:= modifiedowners[int1]^.instance;
        comp1:= infos[int1]^.descendent;
        if ismodule(comp1) then begin //inherited form
         with tformdesignerfo(modifiedowners[int1]^.designform) do begin
          beginplacement;
          dec(submodulecopy);
          try
           reader1.readrootcomponent(comp1);
           checkinline(comp1);
           placemodule;
          finally
           inc(submodulecopy);
           endplacement;
          end;
         end;
        end
        else begin
         reader1.parent:= infos[int1]^.descendent.getparentcomponent;
         {$ifdef FPC}
         reader1.driver.beginrootcomponent;
         {$else}
         reader1.readsignature;
         {$endif}
         reader1.beginreferences;
         reader1.readcomponent(infos[int1]^.descendent);
         reader1.fixupreferences;
         reader1.endreferences;
        end;
       finally
        reader1.free;
        fdesigner.releasemethodtable(modifiedowners[int1]);
        removefixupreferences(modifiedowners[int1]^.instance,'');
       end;
       for int2:= high(ferrorhandler.fnewcomponents) downto 0 do begin
        if ferrorhandler.fnewcomponents[int2] <> infos[int1]^.descendent then begin
         modifiedowners[int1]^.components.add(ferrorhandler.fnewcomponents[int2]);
        end;
       end;
 {$ifdef mse_debugsubmodule}
       debugbinout('after load ' + infos[int1]^.descendent.name,
                         infos[int1]^.descendent,infos[int1]^.ancestor);
 {$endif}
      finally
       modifiedowners[int1]^.designform.window.endmoving;
      end;
     end;
    finally
     ferrorhandler.free;
     for int1:= 0 to high(streams) do begin
      streams[int1].free;
     end;
    end;
    for int1:= 0 to high(dependentmodules) do begin
     fdesigner.componentmodified(dependentmodules[int1]^.instance);
    end;
   finally
    endsubmodulecopy;
  {$ifdef mse_debugsubmodule}
    teststream.free;
  {$endif}
   end;
  end;
 finally
  dec(fmodifiedlevel);
 end;
end;
*)

procedure tdescendentinstancelist.modulemodified(const amodule: pmoduleinfoty);
type
 streamarty = array of tstream;
 ancestorinfopoarty = array of pancestorinfoty;

{$ifdef mse_debugsubmodule}
var
 teststream: ttextstream;
 procedure debugout(const atext: string; const stream: tstream);
 begin
  writeln(atext);
  stream.position:= 0;
  teststream.size:= 0;
  objectbinarytotextmse(stream,teststream);
  teststream.position:= 0;
  teststream.writetotext(output);
  flush(output);
 end;
 procedure debugbinout(const atext: string; const acomp,aancestor: tcomponent);
 var
  stream1: tmemorystream;
  writer1: twriter;
 begin
  stream1:= tmemorystream.create;
  writer1:= twriter.create(stream1,1024);
  writer1.onfindancestor:= {$ifdef FPC}@{$endif}fdesigner.findancestor;
  writer1.writedescendent(acomp,aancestor);
  writer1.free;
  debugout(atext,stream1);
  stream1.free;
 end;
 
{$endif}

var
 modifiedowners,dependentmodules: moduleinfopoarty;
 streams: streamarty;
 infos: ancestorinfopoarty;
// stream1: tmemorystream;
 writer1: twriter;
 reader1: treader;
 comp1,ancestor: tcomponent;
 int1,int2: integer;
 po1: pancestorinfoty;
 po2: pmoduleinfoty;
// rect1: rectty;

begin
 if fmodifiedlevel >= 16 then begin
  exit;
 end;
 inc(fmodifiedlevel);
 try
  po1:= datapo;
  if fmodifiedlevel = 16 then begin
   showmessage('Recursive form inheritance of "'+
                               amodule^.filename+'".','ERROR');
   sysutils.abort;
  end;
  for int1:= 0 to fcount - 1 do begin
   if po1^.ancestor = amodule^.instance then begin
    additem(pointerarty(infos),po1);
    if ismodule(po1^.descendent) then begin  //inherited form        
     comp1:= po1^.descendent;
    end
    else begin
     comp1:= po1^.descendent.owner;
    end;
    po2:= fdesigner.modules.findmodule(tmsecomponent(comp1));
    additem(pointerarty(modifiedowners),po2);
    if finditem(pointerarty(dependentmodules),po2) < 0 then begin
     additem(pointerarty(dependentmodules),po2);
    end;
   end;
   inc(po1);
  end;
  if high(infos) >= 0 then begin
  {$ifdef mse_debugsubmodule}
   teststream:= ttextstream.create;
  {$endif}
   ancestor:= fdesigner.fsubmodulelist.findancestor(amodule^.instance);
//   designer.doswapmethodpointers(ancestor,false);
   beginsubmodulecopy;
   beginstreaming;
   try 
    setlength(streams,length(infos));
    for int1:= 0 to high(modifiedowners) do begin
     fdesigner.buildmethodtable(modifiedowners[int1]);
     if ismodule(infos[int1]^.descendent.owner) then begin //inherited form
      fdesigner.beginstreaming(modifiedowners[int1]);
     end;
     try
      streams[int1]:= tmemorystream.create;
      writer1:= twriter.create(streams[int1],4096);
      writer1.onfindancestor:= {$ifdef FPC}@{$endif}fdesigner.findancestor;
      comp1:= infos[int1]^.descendent;
      try
       designer.doswapmethodpointers(comp1,false);
       writer1.writedescendent(comp1,ancestor);
      finally
       designer.doswapmethodpointers(comp1,true);
       if ismodule(infos[int1]^.descendent.owner) then begin //inherited form
        fdesigner.endstreaming(modifiedowners[int1]);
       end;
       writer1.free;
      end;
  {$ifdef mse_debugsubmodule}
      debugout('state ' + modifiedowners[int1]^.instance.name,streams[int1]);
  {$endif}
     finally
      fdesigner.releasemethodtable(modifiedowners[int1]);
     end;
    end;
    fdesigner.fsubmodulelist.renewbackup(amodule^.instance);
    ferrorhandler:= treaderrorhandler.create(nil);
    try
     for int1:= 0 to high(modifiedowners) do begin
      modifiedowners[int1]^.designform.window.beginmoving; //no flicker
      try
       streams[int1].position:= 0;
       revert(infos[int1],modifiedowners[int1],true);
       reader1:= treader.create(streams[int1],4096);
       fdesigner.buildmethodtable(modifiedowners[int1]);
       try
        reader1.onerror:= {$ifdef FPC}@{$endif}ferrorhandler.onerror;
        reader1.onancestornotfound:= 
                          {$ifdef FPC}@{$endif}ferrorhandler.ancestornotfound;
        reader1.onsetname:= {$ifdef FPC}@{$endif}ferrorhandler.onsetname;
        reader1.onfindcomponentclass:= 
                          {$ifdef FPC}@{$endif}fdesigner.findcomponentclass;
        reader1.oncreatecomponent:= {$ifdef FPC}@{$endif}fdesigner.createcomponent;
        reader1.onfindmethod:= {$ifdef FPC}@{$endif}fdesigner.findmethod2;
        reader1.root:= modifiedowners[int1]^.instance;
        ferrorhandler.fnewcomponents:= nil;
        reader1.root:= modifiedowners[int1]^.instance;
        ferrorhandler.froot:= modifiedowners[int1]^.instance;
        comp1:= infos[int1]^.descendent;
        if ismodule(comp1) then begin //inherited form
         with tformdesignerfo(modifiedowners[int1]^.designform) do begin
          beginplacement;
          dec(submodulecopy);
          designer.doswapmethodpointers(comp1,false);
          try
           reader1.readrootcomponent(comp1);
           checkinline(comp1);
           placemodule;
          finally
           designer.doswapmethodpointers(comp1,true);
           inc(submodulecopy);
           endplacement;
          end;
         end;
        end
        else begin
         reader1.parent:= comp1.getparentcomponent;
         {$ifdef FPC}
         reader1.driver.beginrootcomponent;
         {$else}
         reader1.readsignature;
         {$endif}
         reader1.beginreferences;
         try
          designer.doswapmethodpointers(comp1,false);
          reader1.readcomponent(comp1);
         finally
          reader1.fixupreferences;
          reader1.endreferences;
          designer.doswapmethodpointers(comp1,true);
         end;
        end;
       finally
        reader1.free;
        fdesigner.releasemethodtable(modifiedowners[int1]);
        removefixupreferences(modifiedowners[int1]^.instance,'');
       end;
       for int2:= high(ferrorhandler.fnewcomponents) downto 0 do begin
        if ferrorhandler.fnewcomponents[int2] <> infos[int1]^.descendent then begin
         modifiedowners[int1]^.components.add(ferrorhandler.fnewcomponents[int2]);
        end;
       end;
 {$ifdef mse_debugsubmodule}
       debugbinout('after load ' + infos[int1]^.descendent.name,
                         infos[int1]^.descendent,infos[int1]^.ancestor);
 {$endif}
      finally
       modifiedowners[int1]^.designform.window.endmoving;
      end;
     end;
    finally
     ferrorhandler.free;
     for int1:= 0 to high(streams) do begin
      streams[int1].free;
     end;
    end;
   finally
    endsubmodulecopy;
    endstreaming;
  {$ifdef mse_debugsubmodule}
    teststream.free;
  {$endif}
   end;
   for int1:= 0 to high(dependentmodules) do begin
    fdesigner.componentmodified(dependentmodules[int1]^.instance);
   end;
  end;
 finally
  dec(fmodifiedlevel);
 end;
end;

procedure tdescendentinstancelist.add(const instance,ancestor: tmsecomponent;
       const submodulelist: tsubmodulelist);
begin
 submodulelist.add(ancestor);
 inherited add(instance,ancestor);
end;

function tdescendentinstancelist.getclassname(const comp: tcomponent): string;
                   //returns submoduleclassname if appropriate
var
 comp1: tmsecomponent;
begin
 if ismodule(comp) then begin
  //module, must be tmsecomponent;
  result:= tmsecomponent(comp).actualclassname;
 end
 else begin
  if csinline in comp.ComponentState then begin
   comp1:= findancestor(comp);
   if comp1 <> nil then begin
    result:= comp1.actualclassname;
    exit;
   end;
  end;
  result:= comp.classname;
 end;
end;

procedure tdescendentinstancelist.setnodefaultpos(const aroot: twidget);
var
 po1: pancestorinfoty;
 int1: integer;
begin
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if (po1^.descendent is twidget) and (po1^.descendent <> nil) and //else inherited form
                      twidget(po1^.descendent).checkancestor(aroot) then begin
   twidget1(po1^.ancestor).fwidgetrect.pos:= makepoint(-bigint,-bigint);
  end;
  inc(po1);
 end;
end;

procedure tdescendentinstancelist.restorepos(const aroot: twidget);
var
 po1: pancestorinfoty;
 int1: integer;
begin
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if (po1^.descendent is twidget) and 
                      twidget(po1^.descendent).checkancestor(aroot) then begin
   twidget1(po1^.ancestor).fwidgetrect.pos:= nullpoint;
  end;
  inc(po1);
 end;
end;

{ tmethods }

constructor tmethods.create(adesigner: tdesigner);
begin
 fdesigner:= adesigner;
 inherited create(sizeof(methodinfoty));
end;

destructor tmethods.destroy;
begin
 releasemethodtable;
 inherited;
end;

procedure tmethods.addmethod(const aname: string; const aaddress: pointer;
                             const atypeinfo: ptypeinfo);
var
 po1: pmethodinfoty;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 po1:= add(cardinal(aaddress),nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
 with po1^ do begin
  name:= aname;
  address:= aaddress;
  typeinfo:= atypeinfo;
 end;
end;

procedure tmethods.deletemethod(const aadress: pointer);
begin
// inherited delete(cardinal(aadress)); do nothing
end;

type
{$ifdef FPC}
  tmethodnamerec = packed record
     name : pshortstring;
     addr : pointer;
  end;
  pmethodtableentryty = ^tmethodnamerec;
  
  tmethodnametable = packed record
    count : dword;
    entries : packed array[0..0] of tmethodnamerec;
  end;

function tmethods.createmethodtable: pointer;
var
 int1,int2: integer;
 po1: pmethodinfoty;
 po2: pmethodtableentryty;
 po3: pchar;

begin
 releasemethodtable;
 if count > 0 then begin
  int2:= count; //lenbyte
  for int1:= 0 to count -1 do begin
   int2:= int2 + length(pmethodinfoty(next)^.name);       //stringsize
  end;
  int1:= sizeof(dword) + count * sizeof(tmethodnamerec); //tablesize
  getmem(fmethodtable,int1+int2);
  pdword(fmethodtable)^:= count;
  po2:= pmethodtableentryty(pchar(fmethodtable) + sizeof(dword));
  po3:= pchar(fmethodtable) + int1;   //stringtable
  for int1:= 0 to count - 1 do begin
   po1:= pmethodinfoty(next);
   int2:= length(po1^.name);
   po2^.name:= pshortstring(po3);
   po3^:= char(int2); //namelen
   inc(po3);
   move(pointer(po1^.name)^,po3^,int2);
   inc(po3,int2);
   po2^.addr:= po1^.address;
   inc(po1);
   inc(po2);
  end;
 end;
 result:= fmethodtable;
end;

{$else}

 methodtableentryfixty = packed record
  len: word;
  addr: pointer;
  namlen: byte;
end;

 methodtableentryty = packed record
  len: word;
  adr: pointer;
  name: shortstring; //variable length
 end;
 pmethodtableentryty = ^methodtableentryty;

function tmethods.createmethodtable: pointer;
var
 int1,int2: integer;
 po1: pmethodinfoty;
 po2: pmethodtableentryty;

begin
 releasemethodtable;
 if count > 0 then begin
  int2:= sizeof(word); //numentries
  for int1:= 0 to count -1 do begin
   int2:= int2 + length(pmethodinfoty(next)^.name);
  end;
  getmem(fmethodtable,int2 + count * sizeof(methodtableentryfixty));
  pword(fmethodtable)^:= count;
  po2:= pmethodtableentryty(pchar(fmethodtable) + sizeof(word));
//  po1:= pmethodinfoty(fdatapo);
  for int1:= 0 to count - 1 do begin
   po1:= pmethodinfoty(next);
   int2:= length(po1^.name);
   po2^.len:= sizeof(methodtableentryfixty) + int2;
   po2^.adr:= po1^.address;
   po2^.name[0]:= char(int2);
   move(po1^.name[1],po2^.name[1],int2);
   inc(pchar(po2),po2^.len);
  end;
 end;
 result:= fmethodtable;
end;

{$endif}

procedure tmethods.releasemethodtable;
begin
 if fmethodtable <> nil then begin
  freemem(fmethodtable);
  fmethodtable:= nil;
 end;
end;

function tmethods.findmethod(const aadress: pointer): pmethodinfoty;
begin
 result:= pmethodinfoty(find(cardinal(aadress)));
end;

function tmethods.findmethodbyname(const aname: string;
                       const atype: ptypeinfo; out namefound: boolean): pmethodinfoty;
var
 int1: integer;
 po1: pmethodinfoty;
 str1: string;
begin
 str1:= uppercase(aname);
 result:= nil;
 namefound:= false;
 for int1:= 0 to fcount - 1 do begin
  po1:= next;
  if uppercase(po1^.name) = str1 then begin
   namefound:= true;
   if (po1^.typeinfo = atype) then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function tmethods.findmethodbyname(const aname: string): pmethodinfoty;
var
 int1: integer;
 po1: pmethodinfoty;
 str1: string;
begin
 str1:= uppercase(aname);
 result:= nil;
 for int1:= 0 to fcount - 1 do begin
  po1:= next;
  if uppercase(po1^.name) = str1 then begin
   result:= po1;
   break;
  end;
 end;
end;

procedure tmethods.freedata(var data);
begin
 with methodinfoty(data) do begin
  name:= ''
 end;
end;

{ tcomponents }

constructor tcomponents.create(const aowner: pmoduleinfoty; const adesigner: tdesigner);
begin
 fowner:= aowner;
 fdesigner:= adesigner;
 fcomponent:= tcomponentslink.Create(nil);
 fcomponent.fowner:= self;
 inherited create(sizeof(componentinfoty));
end;

destructor tcomponents.destroy;
begin
 fcomponent.Free;
 inherited;
end;

procedure tcomponents.destroynotification(const acomponent: tcomponent);
begin
 fdesigner.componentdestroyed(acomponent,fowner);
 delete(cardinal(acomponent));
end;

procedure tcomponents.freedata(var data);
begin
 with componentinfoty(data) do begin
  name:= '';
 end;
end;

procedure tcomponents.doadd(component: tcomponent);
var
 root: tcomponent;
begin
 if not(component is twidget) or 
         (ws_iswidget in twidget1(component).fwidgetstate) then begin
  add(component);
 end;
 root:= famodule;
 if csinline in component.componentstate then begin
  famodule:= component;
 end;
 tcomponent1(component).GetChildren({$ifdef FPC}@{$endif}doadd,famodule);
 famodule:= root;
end;

procedure tcomponents.assigncomps(const module: tmsecomponent);
begin
 clear;
 if module <> nil then begin
  famodule:= module;
  doadd(module);
 end;
end;

procedure tcomponents.add(comp: tcomponent);
var
 po1: pcomponentinfoty;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 po1:= inherited add(cardinal(comp),nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
 with po1^ do begin
  instance:= comp;
  name:= comp.Name;
 end;
 comp.freenotification(fcomponent);
end;

function tcomponents.find(const value: tobject): pcomponentinfoty;
begin
 result:= pcomponentinfoty(inherited find(cardinal(value)));
end;

procedure tcomponents.swapcomponent(const old,new: tcomponent);
var
 po1: pcomponentinfoty;
begin
 po1:= find(old);
 if po1 <> nil then begin
  po1^.instance:= new;
  old.removefreenotification(fcomponent);
  new.freenotification(fcomponent);
 end;
end;

function tcomponents.getcomponents: componentarty;
var
 int1: integer;
begin
 setlength(result,fcount);
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= next^.instance;
 end;
end;

function tcomponents.next: pcomponentinfoty;
begin
 result:= pcomponentinfoty (inherited next);
end;

function tcomponents.getcomponent(const aname: string): tcomponent;
var
 int1: integer;
 po1: pcomponentinfoty;
 str1: string;

begin
 result:= nil;
 str1:= uppercase(aname);
 if aname <> '' then begin
  for int1:= 0 to fcount - 1 do begin
   po1:= next;
   if uppercase(po1^.name) = str1 then begin
    result:= po1^.instance;
    break;
   end;
  end;
 end;
end;

procedure tcomponents.namechanged(const acomponent: tcomponent;
                                            const newname: string);
var
 po1: pcomponentinfoty;
begin
 po1:= find(acomponent);
 if po1 <> nil then begin
  po1^.name:= newname;
 end;
end;

function comparecomponentname(const l,r): integer;
begin
 result:= comparetext(componentnamety(l).dispname,componentnamety(r).dispname);
end;

function tcomponents.getdispnames: componentnamearty;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 0 to fcount - 1 do begin
  with result[int1] do begin
   instance:= next^.instance;
   dispname:= fdesigner.getcomponentdispname(instance);
  end;
 end;
 sortarray(result,{$ifdef FPC}@{$endif}comparecomponentname,sizeof(componentnamety));
end;

{ tmoduleinfo }

constructor tmoduleinfo.create(adesigner: tdesigner);
begin
 fdesigner:= adesigner;
 with info do begin
  methods:= tmethods.create(fdesigner);
  components:= tcomponents.create(@info,fdesigner);
 end;
end;

destructor tmoduleinfo.destroy;
begin
 inherited;
 with info do begin
  freeandnil(methods);
  freeandnil(components);
  freeandnil(designform);
 end;
end;

{ tmodulelist }

constructor tmodulelist.create(adesigner: tdesigner);
begin
 fdesigner:= adesigner;
 inherited create(true);
end;

function tmodulelist.getitempo1(const index: integer): pmoduleinfoty;
begin
 result:= @(tmoduleinfo(items[index]).info);
end;

function tmodulelist.findmodule(const filename: msestring): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmoduleinfoty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  po2:= @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info;
  if po2^.filename = filename then begin
   result:= po2;
   break;
  end;
 end;
end;

function tmodulelist.findmodule(const amodule: tmsecomponent): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmoduleinfoty;
begin
 result:= nil;
 if amodule <> nil then begin
  po1:= datapo;
  for int1:= 0 to fcount-1 do begin
   po2:= @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info;
   if po2^.instance = amodule then begin
    result:= po2;
    break;
   end;
  end;
 end;
end;

function tmodulelist.findmodulebyinstance(const ainstance: tcomponent): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmoduleinfoty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  po2:= @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info;
  if po2^.instance = ainstance then begin
   result:= po2;
   break;
  end;
 end;
end;

function tmodulelist.findmodule(const po: pmoduleinfoty): integer;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= -1;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  if @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info = po then begin
   result:= int1;
   break;
  end;
 end;
end;

function tmodulelist.findmodulebyname(const name: string): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
   if info.instancevarname = name then begin
    result:= @info;
    break;
   end;
  end;
 end;
end;

function tmodulelist.findmoduleinstancebyname(const name: string): tcomponent;
var
 po1: pmoduleinfoty;
begin
 po1:= findmodulebyname(name);
 if po1 <> nil then begin
  result:= po1^.instance;
 end
 else begin
  result:= nil;
 end;
end;

function tmodulelist.findmoduleinstancebyclass(const aclass: tclass): tcomponent;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
   if info.instance.classtype = aclass then begin
    if not info.resolved then begin
     exit;
    end;
    result:= info.instance;
    break;
   end;
  end;
 end;
end;

function tmodulelist.findmodulebyclassname(aclassname: string): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= nil;
 po1:= datapo;
 aclassname:= uppercase(aclassname);
 for int1:= 0 to fcount-1 do begin
  with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
   if uppercase(info.moduleclassname) = aclassname then begin
    result:= @info;
    break;
   end;
  end;
 end;
end;

function tmodulelist.newmodule(const ainherited: boolean;
       const afilename: msestring; const amoduleclassname,ainstancevarname,
                                designmoduleclassname: string): tmoduleinfo;
var
 po1: pmoduleinfoty;
begin
 po1:= findmodule(afilename);
 if po1 <> nil then begin
  delete(findmodule(po1));
 end;
 result:= tmoduleinfo.create(fdesigner);
 with result.info do begin
  filename:= afilename;
  instancevarname:= ainstancevarname;
  moduleclassname:= amoduleclassname;
  try
   if ainherited then begin
    po1:= fdesigner.getinheritedmodule(designmoduleclassname);
    if po1 = nil then begin
     raise exception.create('Ancestor for "'+designmoduleclassname+'" not found.');
    end;
    fdesigner.beginstreaming(po1);
    try
     instance:= fdesigner.copycomponent(po1^.instance,nil);
    finally
     fdesigner.endstreaming(po1);
    end;
    moduleintf:= po1^.moduleintf;
    designformclass:= po1^.designformclass;
    tcomponent1(instance).setancestor(true);
    additem(pointerarty(fdesigner.floadedsubmodules),instance);
    fdesigner.fdescendentinstancelist.add(tmsecomponent(instance),po1^.instance,
                                          fdesigner.fsubmodulelist);
    tmsecomponent1(instance).factualclassname:= @moduleclassname;
    tmsecomponent1(instance).fancestorclassname:= designmoduleclassname;
    tmsecomponent1(instance).setancestor(true);
   end
   else begin
    instance:= createdesignmodule(@result.info,designmoduleclassname,@moduleclassname);
   end;
   tcomponent1(instance).setdesigning(true{$ifndef FPC},true{$endif});
  except
   result.Free;
   raise;
  end;
 end;
end;

function tmodulelist.findmethodbyname(const name: string; 
                                      const atype: ptypeinfo; 
                                      const amodule: tmsecomponent): tmethod;

 procedure getmethod(ainfo: pmoduleinfoty; aname: string);
 var
  po1: pmethodinfoty;
  bo1: boolean;
 begin
  if ainfo <> nil then begin
   po1:= ainfo^.methods.findmethodbyname(aname,atype,bo1);
   if po1 <> nil then begin
    result.data:= po1^.address;
 //   result.code:= po1^.address;
 //   result.Data:= ainfo^.instance;
   end
//   else begin
//    if bo1 then begin
//     result.data:= pointer(1); //name found
//    end;
//   end;
  end;
 end;

var
 ar1: stringarty;
begin
 result:= nullmethod;
 if amodule <> nil then begin
  getmethod(findmodule(amodule),name);
 end
 else begin
  ar1:= nil;
  splitstring(name,ar1,'.');
  if length(ar1) = 2 then begin
   getmethod(findmodulebyname(ar1[0]),ar1[1]);
  end;
 end;
end;

function tmodulelist.findmethodname(const method: tmethod; const comp: tcomponent): string;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmethodinfoty;
begin
 result:= '';
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
   po2:= info.methods.findmethod(method.data);
   if po2 <> nil then begin
    if info.components.find(comp) = nil then begin
     result:= info.instance.actualclassname + '.' + po2^.name //foreign module
    end
    else begin
     result:= po2^.name;
    end;
    break;
   end;
  end;
 end;
end;

function tmodulelist.delete(index: integer): pointer;
begin
 fdesigner.moduledestroyed(itempo[index]);
 result:= inherited delete(index);
end;

function tmodulelist.removemoduleinfo(po: pmoduleinfoty): integer;
begin
 result:= findmodule(po);
 delete(result);
end;

function tmodulelist.findform(aform: tmseform): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
   if info.designform = aform then begin
    result:= @info;
    break;
   end;
  end;
 end;
end;

procedure tmodulelist.componentmodified(const acomponent: tobject);
var
 int1: integer;
 po1: ppointeraty;
 comp: tcomponent;

begin
 if acomponent is tcomponent then begin
  comp:= tcomponent(acomponent);
  while (comp.owner <> nil) and (comp.owner.owner <> nil) do begin
   comp:= comp.owner; //top level compoent
  end;
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   with tmoduleinfo(iobjectlink(po1^[int1]).getinstance) do begin
    if info.components.find(comp) <> nil then begin
     if not info.modified then begin
      info.modified:= true;
      if info.designform <> nil then begin
       tformdesignerfo(info.designform).updatecaption;
      end;
     end;
     if (info.designform <> nil) and (fdesigner.fcomponentmodifying > 0) then begin
      idesignnotification(
           tdesignwindow(info.designform.window)).itemsmodified(nil,comp);
     end;
     fdesigner.fdescendentinstancelist.modulemodified(@info);
     break;
    end;
   end;
  end;
  {
  while comp <> nil do begin
   fdesigner.fdescendentinstancelist.modulemodified(comp,
        fdesigner.fsubmodulelist.findancestor(comp));
   fdesigner.fsubmodulelist.renewbackup(comp);
   comp:= comp.owner;
  end;
  }
 end;
end;

function tmodulelist.findmodulebycomponent(const acomponent: tobject): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmoduleinfoty;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount-1 do begin
  po2:= @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info;
  if po2^.components.find(acomponent) <> nil then begin
   result:= po2;
   break;
  end;
 end;
end;

function tmodulelist.filenames: filenamearty;
var
 int1: integer;
 po1: ppointeraty;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info.filename;
 end;
end;

{ tdesignformlist }

function tdesignformlist.getitems(const index: integer): tmseform;//tformdesignerfo;
begin
 result:= tmseform(inherited getitems(index));
end;

{ tdesigner }

constructor tdesigner.create;
begin
 fobjformat:= of_default;
 fselections:= tdesignerselections.create;
 fmodules:= tmodulelist.create(self);
 fsubmodulelist:= tsubmodulelist.create(self);
 fdescendentinstancelist:= tdescendentinstancelist.create(self);
 fdesignfiles:= tindexedfilenamelist.create;
 ondesignchanged:= {$ifdef FPC}@{$endif}componentmodified;
 onfreedesigncomponent:= {$ifdef FPC}@{$endif}deletecomponent;
end;

destructor tdesigner.destroy;
begin
 ondesignchanged:= nil;
 fdescendentinstancelist.Free;
 fsubmodulelist.Free;
 inherited;
 fcomponenteditor.Free;
 fmodules.free;
 fselections.Free;
 fdesignfiles.Free;
end;

procedure tdesigner.ClearSelection;
begin
 //dummy
end;

procedure tdesigner.addcomponent(const module: tmsecomponent; const acomponent: tcomponent);
var
 int1,int2: integer;
 str1: string;
 bo1: boolean;
 classna: string;
 ar1: componentarty;
 
begin
 with registeredcomponents do begin
  if (acomponent.ComponentState * [csancestor] = []) or
         (acomponent.Owner = nil) or (acomponent.Owner = module) then begin //probaly inline

   str1:= acomponent.Name;
   acomponent.name:= '';
   if csinline in acomponent.componentstate then begin
    if str1 <> '' then begin
     classna:= str1;
     str1:= str1 + '1';
    end;
   end
   else begin
    classna:= acomponent.ClassName;
   end;
   if acomponent.Owner <> nil then begin
    acomponent.owner.removecomponent(acomponent);
   end;
   module.InsertComponent(acomponent);
   if str1 = '' then begin
    str1:= classna + '1';
   end;
   int1:= 1;
   ar1:= fdescendentinstancelist.getdescendents(module);
   additem(pointerarty(ar1),module);
   repeat
    bo1:= true;
    for int2:= 0 to high(ar1) do begin
     if ar1[int2].findcomponent(str1) <> nil then begin
      inc(int1);
      str1:= classna + inttostr(int1);
      bo1:= false;
      break;
     end;
    end;
   until bo1;
   acomponent.Name:= str1;
   fmodules.findmodulebyinstance(module)^.components.add(acomponent);
   designnotifications.ItemInserted(self,module,acomponent);
  end
  else begin
   fmodules.findmodulebyinstance(module)^.components.add(acomponent);
  end;
  componentmodified(acomponent);
 end;
end;

function tdesigner.createnewcomponent(const module: tmsecomponent;
                                 const aclass: tcomponentclass): tcomponent;
begin
 result:= tcomponent(aclass.newinstance);
 try
  tcomponent1(result).setdesigning(true);
  result.create(nil);
 except
  result.Free;
  raise;
 end;
 with modules.findmodule(module)^.moduleintf^ do begin
  if assigned(initnewcomponent) then begin
   initnewcomponent(module,result);
  end;
 end;
 addcomponent(module,result);
end;

function tdesigner.createcurrentcomponent(const module: tmsecomponent): tcomponent;
begin
 with registeredcomponents do begin
  if selectedclass <> nil then begin
   result:= createnewcomponent(module,selectedclass);
  end
  else begin
   result:= nil;
  end;
 end;
end;

function tdesigner.hascurrentcomponent: boolean;
begin
 result:= registeredcomponents.selectedclass <> nil;
end;

procedure tdesigner.notifydeleted(comp: tcomponent);
begin
 if fnotifydeletedlock = 0 then begin
  if comp is twidget then begin
   tcomponent1(comp).getchildren({$ifdef FPC}@{$endif}notifydeleted,fnotifymodule);
  end;
  designnotifications.itemdeleted(idesigner(self),fnotifymodule,comp);
 end;
end;

procedure tdesigner.deleteselection(adoall: boolean);
var
 int1: integer;
 comp1,comp2: tcomponent;
 po1: pmoduleinfoty;

begin
 for int1:= 0 to fselections.count - 1 do begin
  comp1:= fselections[int1];
  comp2:= comp1.owner;
  po1:= fmodules.findmodulebycomponent(comp1);
  if po1 <> nil then begin
   fnotifymodule:= po1^.instance;
   notifydeleted(comp1);
  end;
  inc(fnotifydeletedlock);
  try
   comp1.free;
  finally
   dec(fnotifydeletedlock);
  end;
  fmodules.componentmodified(comp2);
 end;
 fselections.clear;
 selectionchanged;
// designnotifications.SelectionChanged(idesigner(self),idesignerselections(fselections));
end;

procedure tdesigner.componentdestroyed(const acomponent: tcomponent;
                                           const module: pmoduleinfoty);
begin
 if fnotifydeletedlock = 0 then begin
//  designnotifications.itemdeleted(idesigner(self),module^.instance,acomponent);
  if fselections.remove(acomponent) >= 0 then begin
   selectionchanged;
  end;
 end;
end;

procedure tdesigner.deletecomponent(const acomponent: tcomponent);
begin
 if acomponent <> nil then begin
  fmodules.componentmodified(acomponent);
  designnotifications.ItemDeleted(idesigner(self),
            fmodules.findmodulebycomponent(acomponent)^.instance,acomponent);
  acomponent.free;
 end;
end;

function tdesigner.createmethod(const aname: string; const module: tmsecomponent;
                                   const atype: ptypeinfo): tmethod;
var
 po1: pmoduleinfoty;
begin
 if module = nil then begin
  po1:= floadingmodulepo;
 end
 else begin
  po1:= fmodules.findmodulebyinstance(module);
 end;
 if po1 <> nil then begin
  with po1^.methods do begin
   inc(methodaddressdummy);
   if methodaddressdummy < 256 then begin
    methodaddressdummy:= 256; //0..255 -> special purpose
   end;
//   result.code:= pointer(methodaddressdummy);
//   result.Data:= po1^.instance;
   result.data:= pointer(methodaddressdummy);
   result.code:= nil;
   addmethod(aname,result.data,atype);
  end;
  if atype <> nil then begin
   designnotifications.methodcreated(idesigner(self),module,aname,atype);
  end;
 end
 else begin
  result:= nullmethod;
 end;
end;

procedure tdesigner.findmethod(Reader: TReader; const aMethodName: string;
  var Address: Pointer; var Error: Boolean);
var
 method: tmethod;
 po1: pmethodinfoty;
begin
 if error then begin
  po1:= floadingmodulepo^.methods.findmethodbyname(amethodname);
  if po1 = nil then begin
   method:= createmethod(amethodname,nil,nil);
   address:= method.data;
  end
  else begin
   address:= po1^.address;
  end;
  error:= false;
 end;
end;

procedure tdesigner.findmethod2(Reader: TReader; const aMethodName: string;
  var Address: Pointer; var Error: Boolean);
var
 po2: pmethodinfoty;
begin
 if error then begin
  error:= false; //ignore new method error
  po2:= flookupmodule^.methods.findmethodbyname(amethodname);
  if po2 <> nil then begin
   address:= po2^.address;
  end;
 end;
end;

function tdesigner.getinheritedmodule(const aclassname: string): pmoduleinfoty;
begin
 result:= fmodules.findmodulebyclassname(aclassname);
 if result = nil then begin
  if assigned(fongetmoduletypefile) then begin
   fongetmoduletypefile(aclassname);
  end;
  result:= fmodules.findmodulebyclassname(aclassname);
 end;
end;

procedure tdesigner.findcomponentclass(Reader: TReader; const aClassName: string;
        var ComponentClass: TComponentClass);

var
 po1: pmoduleinfoty;
begin
 fsubmoduleinfopo:= nil;
 if componentclass = nil then begin
  po1:= getinheritedmodule(aclassname);
  if po1 <> nil then begin
   fsubmoduleinfopo:= po1;  //used in createcomponent
   componentclass:= tcomponentclass(po1^.instance.classtype);
  end;
 end;
end;

procedure tdesigner.ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
begin
 component:= fmodules.findmoduleinstancebyclass(componentclass);
 if component = nil then begin
  component:= findancestorcomponent(reader,componentname);
 end;
end;

procedure tdesigner.createcomponent(Reader: TReader; ComponentClass: TComponentClass;
                   var Component: TComponent);
var
 asubmoduleinfopo: pmoduleinfoty;
begin
 asubmoduleinfopo:= fsubmoduleinfopo;    //can be recursive
 if asubmoduleinfopo <> nil then begin
  component:= copycomponent(asubmoduleinfopo^.instance,asubmoduleinfopo^.instance);
  reader.root.insertcomponent(component);
  tmsecomponent1(component).setinline(true);
  tmsecomponent1(component).setancestor(true);
//  checkinline(component);
  if (submodulecopy = 0) and 
          (reader.root.componentstate * [csinline{,csancestor}] = [])  then begin
   additem(pointerarty(floadedsubmodules),component);
   fdescendentinstancelist.add(tmsecomponent(component),asubmoduleinfopo^.instance,fsubmodulelist);
  end;
 end;
end;

procedure tdesigner.docopymethods(const source,dest: tcomponent;
                                      const force: boolean);
 procedure doprops(const source,desc: tobject);
 var
  ar1: propinfopoarty;
  int1: integer;
  method1: tmethod;
 begin
  ar1:= getpropinfoar(desc);
  for int1:= 0 to high(ar1) do begin
   case ar1[int1]^.proptype^.kind of
    tkmethod: begin
     method1:= getmethodprop(source,ar1[int1]);
     if {force or }(method1.code <> nil) or (method1.data <> nil) then begin
      setmethodprop(dest,ar1[int1],method1); 
     end;
    end;
    {
    tkclass: begin
     obj1:= getobjectprop(source,ar1[int1]);
     if (obj1 <> nil) and (not (obj1 is tcomponent) or 
               (cssubcomponent in tcomponent(obj1).componentstyle)) then begin
      obj2:= getobjectprop(dest,ar1[int1]);
      if obj2 <> nil then begin
       doprops(obj1,obj2);
       if obj1 is tpersistentarrayprop then begin
        int3:= tpersistentarrayprop(obj1).count;
        if int3 > tpersistentarrayprop(obj2).count then begin
         int3:= tpersistentarrayprop(obj2).count;
        end;
        for int2:= 0 to int3 - 1 do begin
         doprops(tpersistentarrayprop(obj1).items[int2],
                 tpersistentarrayprop(obj2).items[int2]);
        end;
       end;
      end;        //collections?
     end;
    end;
    }
   end;
  end;
 end;
 
var 
 comp1,comp2: tcomponent;
 int1: integer;
 bo1: boolean;
begin
 bo1:= setloading(dest,true);
 try 
  doprops(source,dest);
 finally
  setloading(dest,bo1);
 end; 
 for int1:= 0 to source.componentcount - 1 do begin
  comp1:= source.components[int1];
  comp2:= dest.findcomponent(comp1.name);
  if (comp2 <> nil) and
       (comp1.classtype = comp2.classtype) then begin
   docopymethods(comp1,comp2,force);
  end;
 end;
end;

{
procedure tdesigner.docopymethods(const source, dest: tcomponent; 
                           const force: boolean);
var
 propar: propinfopoarty;
 po1: ^ppropinfo;
 int1: integer;
 method,method1: tmethod;
 comp1,comp2: tcomponent;
begin
 propar:= getpropinfoar(source);
 po1:= pointer(propar);
 for int1:= 0 to high(propar) do begin
  if po1^^.proptype^.kind = tkmethod then begin
   method:= getmethodprop(source,po1^);
   method1:= getmethodprop(dest,po1^);
   if (method1.code <> method.code) or (method1.data <> method.data) then begin
    setmethodprop(dest,po1^,method);
   end;
  end;
  inc(po1);
 end;
 for int1:= 0 to source.ComponentCount - 1 do begin
  comp1:= source.Components[int1];
  comp2:= dest.FindComponent(comp1.name);
  if (comp2 <> nil) and (comp1.ClassType = comp2.ClassType) then begin
   docopymethods(comp1,comp2,force);
  end;
 end;
end;
}
{
procedure tdesigner.dorefreshmethods(const descendent,newancestor,
                                    oldancestor: tcomponent);
 procedure doprops(const desc,newan,oldan: tobject);
 var
  ar1: propinfopoarty;
  int1,int2,int3: integer;
  method1,method2,method3: tmethod;
  obj1,obj2,obj3: tobject;
 begin
  ar1:= getpropinfoar(desc);
  for int1:= 0 to high(ar1) do begin
   case ar1[int1]^.proptype^.kind of
    tkmethod: begin
     method2:= getmethodprop(newan,ar1[int1]);
     if (method2.code <> nil) or (method2.data <> nil) then begin
      setmethodprop(desc,ar1[int1],method2); 
          //refresh ancestor value, it is not possible to override methods
     end;
    end;
    tkclass: begin
     obj1:= getobjectprop(desc,ar1[int1]);
     obj2:= getobjectprop(newan,ar1[int1]);
     obj3:= getobjectprop(oldan,ar1[int1]);
     if (obj1 <> nil) and (not (obj1 is tcomponent) or 
               (cssubcomponent in tcomponent(obj1).componentstyle)) then begin
      doprops(obj1,obj2,obj3);
      if obj1 is tpersistentarrayprop then begin
       int3:= tpersistentarrayprop(obj1).count;
       if int3 > tpersistentarrayprop(obj2).count then begin
        int3:= tpersistentarrayprop(obj2).count;
       end;
       if int3 > tpersistentarrayprop(obj3).count then begin
        int3:= tpersistentarrayprop(obj3).count;
       end;
       for int2:= 0 to int3 - 1 do begin
        doprops(tpersistentarrayprop(obj1).items[int2],
                tpersistentarrayprop(obj2).items[int2],
                tpersistentarrayprop(obj3).items[int2]);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 
var 
 comp1,comp2,comp3: tcomponent;
 int1: integer;
begin
 doprops(descendent,newancestor,oldancestor);
 for int1:= 0 to descendent.componentcount - 1 do begin
  comp1:= descendent.components[int1];
  comp2:= newancestor.findcomponent(comp1.name);
  comp3:= oldancestor.findcomponent(comp1.name);
  if (comp2 <> nil) and (comp3 <> nil) and
       (comp1.classtype = comp2.classtype) and
       (comp1.classtype = comp3.classtype) then begin
   dorefreshmethods(comp1,comp2,comp3);
  end;
 end;
end;
}

procedure tdesigner.componentevent(const event: tcomponentevent);
begin
 with event do begin
  if tag = ord(me_componentmodified) then begin
   designnotifications.ItemsModified(idesigner(self),sender);
  end;
 end;
 inherited;
end;

procedure tdesigner.setmodulex(const amodule: tmsecomponent; avalue: integer);
var
 po1: pmoduleinfoty;
begin
 po1:= fmodules.findmodule(tmsecomponent(amodule));
 if po1 <> nil then begin
  po1^.designform.bounds_x:= avalue;
 end;
end;

procedure tdesigner.setmoduley(const amodule: tmsecomponent; avalue: integer);
var
 po1: pmoduleinfoty;
begin
 po1:= fmodules.findmodule(tmsecomponent(amodule));
 if po1 <> nil then begin
  po1^.designform.bounds_y:= avalue;
 end;
end;

function tdesigner.checkmodule(const filename: msestring): pmoduleinfoty;
begin
 result:= fmodules.findmodule(filename);
 if result = nil then begin
  raise exception.Create('Module "'+filename+'" not found');
 end;
end;

procedure tdesigner.beginstreaming(const amodule: pmoduleinfoty);
begin
 with amodule^ do begin
  tformdesignerfo(designform).beginstreaming;
 end;
end;

procedure tdesigner.endstreaming(const amodule: pmoduleinfoty);
begin
 with amodule^ do begin
  tformdesignerfo(designform).endstreaming;
 end;
end;

procedure tdesigner.modulechanged(const amodule: pmoduleinfoty);
begin
 componentmodified(amodule^.instance);
end;

function tdesigner.changemodulename(const filename: msestring; const avalue: string): string;
var
 po1: pmoduleinfoty;
 str1: string;
begin
 po1:= checkmodule(filename);
 str1:= po1^.instance.name;
 po1^.instance.Name:= avalue;
 result:= po1^.instance.name;
 if result <> str1 then begin
  modulechanged(po1);
 end;
end;

function tdesigner.componentcanedit: boolean;
begin
 result:= (fcomponenteditor <> nil) and (cs_canedit in fcomponenteditor.state);
end;
  
procedure tdesigner.checkident(const aname: string);
begin
 if not isvalidident(aname) or (aname = '') then begin
  raise exception.Create('Invalid name "'+aname+'".');
 end;
end;

function tdesigner.changemoduleclassname(const filename: msestring; const avalue: string): string;
var
 po1: pmoduleinfoty;
begin
 po1:= checkmodule(filename);
 checkident(avalue);
 designnotifications.moduleclassnamechanging(idesigner(self),po1^.instance,avalue);
 po1^.moduleclassname:= avalue;
 result:= po1^.moduleclassname;
 modulechanged(po1);
end;

function tdesigner.changeinstancevarname(const filename: msestring; const avalue: string): string;
var
 po1: pmoduleinfoty;
begin
 po1:= checkmodule(filename);
 checkident(avalue);
 designnotifications.instancevarnamechanging(idesigner(self),po1^.instance,avalue);
 po1^.instancevarname:= avalue;
 result:= po1^.instancevarname;
 modulechanged(po1);
end;

function tdesigner.checksubmodule(const ainstance: tcomponent; 
              out aancestormodule: pmoduleinfoty): boolean;
begin
 aancestormodule:= modules.findmodule(
          fdescendentinstancelist.findancestor(ainstance));
 result:= aancestormodule <> nil;
end;

procedure tdesigner.componentmodified(const component: tobject);
begin
 fallsaved:= false;
 if component <> nil then begin
  fmodules.componentmodified(component);
 end;
 if fcomponentmodifying = 0 then begin
  postcomponentevent(tcomponentevent.create(component,ord(me_componentmodified),false));
 end
end;

procedure tdesigner.begincomponentmodify;
begin
 inc(fcomponentmodifying);
end;

procedure tdesigner.endcomponentmodify;
begin
 dec(fcomponentmodifying);
end;

function tdesigner.copycomponent(const source: tmsecomponent;
                            const root: tmsecomponent): tmsecomponent;
var
 po1: pmoduleinfoty;
begin
 beginsubmodulecopy;
 fdescendentinstancelist.beginstreaming;
 if root <> nil then begin
  po1:= fmodules.findmodule(root);
  if po1 <> nil then begin
   beginstreaming(po1);
   buildmethodtable(po1);
  end;
 end
 else begin
  po1:= nil;
 end;
 doswapmethodpointers(source,false);
 try
  result:= tmsecomponent(mseclasses.copycomponent(source,nil,
            {$ifdef FPC}@{$endif}findancestor,
            {$ifdef FPC}@{$endif}findcomponentclass,
            {$ifdef FPC}@{$endif}createcomponent,
            {$ifdef FPC}@{$endif}ancestornotfound));
  if po1 = nil then begin
   docopymethods(source,result,false);
  end;
  doswapmethodpointers(result,true);
 finally
  doswapmethodpointers(source,true);
  fdescendentinstancelist.endstreaming;
  endsubmodulecopy;
  if po1 <> nil then begin
   endstreaming(po1);
   releasemethodtable(po1);
  end;
 end;
end;

procedure tdesigner.revert(const acomponent: tcomponent);
var
 comp1: tcomponent;
 po1: pancestorinfoty;
 po2: pmoduleinfoty;
 bo1: boolean;
 pos1: pointty;
begin
 po2:= fmodules.findmodule(tmsecomponent(acomponent.owner));
 if csinline in acomponent.componentstate then begin
  po1:= fdescendentinstancelist.finddescendentinfo(acomponent);
  if po1 <> nil then begin
   if po2 <> nil then begin
    bo1:= acomponent is twidget;
    if bo1 then begin
     pos1:= twidget(acomponent).pos;
    end;
    fdescendentinstancelist.revert(po1,po2);
    if bo1 then begin
     twidget(po1^.descendent).pos:= pos1;
    end;
   end;
  end;
 end
 else begin
  if csancestor in acomponent.componentstate then begin
   comp1:= fdescendentinstancelist.findancestor(acomponent.owner);
   if comp1 <> nil then begin
    comp1:= comp1.findcomponent(acomponent.name);
    if comp1 <> nil then begin
     fdescendentinstancelist.beginstreaming;
     doswapmethodpointers(acomponent,false);
     doswapmethodpointers(comp1,false);
     try
      refreshancestor(acomponent,comp1,comp1,true,
       {$ifdef FPC}@{$endif}findancestor,
       {$ifdef FPC}@{$endif}findcomponentclass,
       {$ifdef FPC}@{$endif}createcomponent);
      docopymethods(comp1,acomponent,true);
//      dorefreshmethods(acomponent,comp1,acomponent);
     finally
      doswapmethodpointers(acomponent,true);
      doswapmethodpointers(comp1,true);
      fdescendentinstancelist.endstreaming;
     end;
    end;
   end;
  end;
 end;
 componentmodified(acomponent);
end;

function tdesigner.getreferencingmodulenames(const amodule: pmoduleinfoty): stringarty;
var
 int1,int2: integer;
 po1: pancestorinfoaty;
 str1: string;
 po2: pmoduleinfoty;
 bo1: boolean;
begin
 result:= nil;
 for int1:= 0 to fmodules.count - 1 do begin
  with fmodules[int1]^ do begin
   for int2:= 0 to high(referencedmodules) do begin
    if referencedmodules[int2] = amodule^.instance.Name then begin
     additem(result,instance.name);
    end;
   end;
  end;
 end;
 po1:= fdescendentinstancelist.datapo;
 for int1:= 0 to fdescendentinstancelist.count - 1 do begin
  with po1^[int1] do begin
   if ancestor = amodule^.instance then begin
    po2:= fmodules.findmodulebycomponent(descendent);
    if po2 <> nil then begin
     str1:= po2^.instance.name;
     bo1:= false;
     for int2:= high(result) downto 0 do begin
      if result[int2] = str1 then begin
       bo1:= true;
       break;
      end;
     end;
     if not bo1 then begin
      additem(result,str1);
     end;
    end;
   end;
  end;
 end;
end;

function tdesigner.checkcanclose(const amodule: pmoduleinfoty;
                  out references:  string): boolean;
begin
 references:= concatstrings(getreferencingmodulenames(amodule),',');
 result:= references = '';
end;

procedure tdesigner.findancestor(Writer: TWriter; Component: TComponent;
              const aName: string; var Ancestor, RootAncestor: TComponent);
begin
 if (csinline in component.ComponentState) then begin
  if (ancestor = nil) then begin
   ancestor:= fdescendentinstancelist.findancestor(component);
   rootancestor:= ancestor;
  end;
 end
 else begin
//  if (component.owner <> nil) and (ancestor <> rootancestor) and
//          not (csinline in component.owner.componentstate) and
//          not (csancestor in component.owner.componentstate) then begin
  if not (csancestor in component.componentstate) then begin
   ancestor:= nil; //has name duplicate
  end;
 end; 
end;

procedure tdesigner.getmethodinfo(const method: tmethod; out moduleinfo: pmoduleinfoty;
                      out methodinfo: pmethodinfoty);
var
 int1: integer;
begin
 moduleinfo:= fmodules.findmodulebyinstance(tcomponent(method.data));
 if moduleinfo <> nil then begin
  with moduleinfo^.methods do begin
   methodinfo:= findmethod(method.data);
  end;
 end
 else begin
  methodinfo:= nil;
  for int1:= 0 to fmodules.count - 1 do begin
   methodinfo:= fmodules[int1]^.methods.findmethod(method.data);
   if methodinfo <> nil then begin
    moduleinfo:= fmodules[int1];
    break;
   end;
  end;
 end;
end;

procedure tdesigner.changemethodname(const method: tmethod; newname: string;
                              const atypeinfo: ptypeinfo);
var
 po1: pmethodinfoty;
 po2: pmoduleinfoty;
 oldname: string;
begin
 if not isvalidident(newname) then begin
  raise exception.Create('Invalid methodname '''+newname+'''.');
 end;
 getmethodinfo(method,po2,po1);
 if po2 = nil then begin
  raise exception.Create('Module not found');
 end;
 if po1 = nil then begin
  raise exception.Create('Method not found');
 end;
 oldname:= po1^.name;
 po1^.name:= newname;
 po2^.modified:= true;
 designnotifications.methodnamechanged(fdesigner,po2^.instance,newname,oldname,atypeinfo);
end;

procedure tdesigner.setactivemodule(const adesignform: tmseform);
var
 po1: pmoduleinfoty;
begin
 if adesignform <> nil then begin
  po1:= fmodules.findform(adesignform);
 end
 else begin
  po1:= nil;
 end;
 floadingmodulepo:= po1;
 if po1 <> factmodulepo then begin
  if factmodulepo <> nil then begin
   designnotifications.moduledeactivated(idesigner(self),factmodulepo^.instance);
  end;
  if po1 <> nil then begin
   factmodulepo:= po1;
//   checkobjectinspector; //ev. create
   designnotifications.moduleactivated(idesigner(self),factmodulepo^.instance);
  end
  else begin
   factmodulepo:= nil;
  end;
 end;
end;

function tdesigner.sourcenametoformname(const aname: filenamety): filenamety;
begin
 result:= replacefileext(aname,formfileext);
end;

procedure tdesigner.moduledestroyed(const amodule: pmoduleinfoty);
var
 int1: integer;
begin
 if amodule = factmodulepo then begin
  setactivemodule(nil);
 end;
 for int1:= 0 to amodule^.components.fcount - 1 do begin
  fselections.remove(amodule^.components.next^.instance);
 end;
 designnotifications.selectionchanged(idesigner(self),
       idesignerselections(fselections));
 designnotifications.moduledestroyed(idesigner(self),amodule^.instance);
end;

procedure tdesigner.addancestorinfo(const ainstance,aancestor: tmsecomponent);
begin
 fdescendentinstancelist.add(ainstance,aancestor,fsubmodulelist);
end;

procedure tdesigner.showformdesigner(const amodule: pmoduleinfoty);
begin
 amodule^.designform.activate;
end;

procedure tdesigner.showastext(const amodule: pmoduleinfoty);
var
 mstr1: filenamety;
 bo1: boolean;
begin
 if (amodule <> nil) then begin
  mstr1:= amodule^.filename;
  bo1:= amodule^.backupcreated;
  if closemodule(amodule,true) then begin
   designnotifications.showobjecttext(idesigner(self),mstr1,bo1);
  end;
 end;
end;

procedure swapmethodpointer(const ainstance: tobject; const data: pointer;
                             const apropinfo: ppropinfo);
var
 method1: tmethod;                             
begin
 method1:= getmethodprop(ainstance,apropinfo);
 if method1.data <> nil then begin
  method1.code:= method1.data;
  method1.data:= nil;
  setmethodprop(ainstance,apropinfo,method1);
 end;
end;

procedure swapinitmethodpointer(const ainstance: tobject; const data: pointer;
                             const apropinfo: ppropinfo);
var
 method1: tmethod;                             
begin
 method1:= getmethodprop(ainstance,apropinfo);
 if method1.code <> nil then begin
  method1.data:= method1.code;
  method1.code:= nil;
  setmethodprop(ainstance,apropinfo,method1);
 end;
end;

procedure tdesigner.doswapmethodpointers(const ainstance: tobject;
                    const ainit: boolean);
begin
 if finditem(pointerarty(fdescendentinstancelist.fswappedancestors),
                           ainstance) < 0 then begin
  if ainit then begin
   forallmethodproperties(ainstance,nil,
           {$ifdef FPC}@{$endif}swapinitmethodpointer,true);
  end
  else begin
   forallmethodproperties(ainstance,nil,
           {$ifdef FPC}@{$endif}swapmethodpointer,true);
  end;
 end;
end;

{
procedure tdesigner.doswapmethodpointers(const ainstance: tobject;
                    const ainit: boolean);
var
 propar: propinfopoarty;
 int1: integer;
 method1: tmethod;
 po1: ^ppropinfo;
 po2: pointer;
begin
 propar:= getpropinfoar(ainstance);
 po1:= pointer(propar);
 for int1:= high(propar) downto 0 do begin
  case po1^^.proptype^.kind of
   tkmethod: begin
    method1:= getmethodprop(ainstance,po1^);
    if ainit then begin
     if method1.code <> nil then begin
      method1.data:= method1.code;
      method1.code:= nil;
      setmethodprop(ainstance,po1^,method1);
     end;
    end
    else begin
     if method1.data <> nil then begin
      method1.code:= method1.data;
      method1.data:= nil;
      setmethodprop(ainstance,po1^,method1);
     end;
    end;
   end;
  end;
  inc(po1);
 end;
end;
}
function tdesigner.checkmethodtypes(const amodule: pmoduleinfoty;
                      const init: boolean; const quiet: tcomponent): boolean;
                                      //false on cancel
var
 classinf: pclassinfoty;
 comp1: tcomponent;
 
 procedure doinit(const instance: tobject);
 var
  ar1: propinfopoarty;
  int1,int2: integer;
  method1: tmethod;
  po1: pmethodinfoty;
  obj1: tobject;
  po2: pprocedureinfoty;
  mr1: modalresultty;
 begin
  ar1:= getpropinfoar(instance);
  for int1:= 0 to high(ar1) do begin
   case ar1[int1]^.proptype^.kind of
    tkmethod: begin
     method1:= getmethodprop(instance,ar1[int1]);
     if (method1.data <> nil) and ((quiet = nil) or 
                         (pointer(quiet) = method1.data)) then begin
//      method1.data:= amodule^.instance;
      po1:= amodule^.methods.findmethod(method1.data);
      if po1 <> nil then begin
       if init then begin
        po1^.typeinfo:= ar1[int1]^.proptype{$ifndef FPC}^{$endif};
       end
       else begin
        po2:= classinf^.procedurelist.finditembyname(po1^.name);
        mr1:= mr_none;
        if po2 = nil then begin
         if quiet <> nil then begin
          mr1:= mr_yes;
         end
         else begin
          mr1:= askyesnocancel('Method '+amodule^.instance.name+'.'+po1^.name+' ('+
                 comp1.name+'.'+ar1[int1]^.name+') does not exist.'+lineend+
                 'Do you wish to delete the event?','WARNING');
         end;
        end
        else begin
         if not parametersmatch(po1^.typeinfo,po2^.params) then begin
          if quiet <> nil then begin
           mr1:= mr_yes;
          end
          else begin
           mr1:= askyesnocancel('Method '+amodule^.instance.name+'.'+po1^.name+' ('+
                 comp1.name+'.'+ar1[int1]^.name+') has different parameters.'+lineend+
                 'Do you wish to delete the event?','WARNING');
          end;
         end;
        end;
        if mr1 = mr_yes then begin
         setmethodprop(instance,ar1[int1],nullmethod);
         modulechanged(amodule);
        end
        else begin
         if quiet <> nil then begin
          setmethodprop(instance,ar1[int1],method1);
                   //refresh data pointer
         end;
        end;
        result:= mr1 <> mr_cancel;
       end;
      end;
     end;
    end;
    tkclass: begin
     obj1:= getobjectprop(instance,ar1[int1]);
     if (obj1 <> nil) and (not (obj1 is tcomponent) or 
               (cssubcomponent in tcomponent(obj1).componentstyle)) then begin
      doinit(obj1);
      if obj1 is tpersistentarrayprop then begin
       with tpersistentarrayprop(obj1) do begin
        for int2:= 0 to count - 1 do begin
         doinit(items[int2]);
         if not result then begin
          break;
         end;
        end;
       end;
      end
      else begin
       if obj1 is tcollection then begin
        with tcollection(obj1) do begin
         for int2:= 0 to count - 1 do begin
          doinit(items[int2]);
          if not result then begin
           break;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
   if not result then begin
    break;
   end;
  end;
 end;

var
 int1: integer;
 mstr1: msestring;
 po3: punitinfoty;
begin
 result:= true;
 if not init then begin
  mstr1:= replacefileext(amodule^.filename,pasfileext);
  if sourcefo.findsourcepage(mstr1) = nil then begin
   exit;
  end;
  po3:= sourceupdater.updateformunit(amodule^.filename,true);
  if po3= nil then begin
   exit;
  end;
  classinf:= findclassinfobyinstance(amodule^.instance,po3);
  if classinf = nil then begin
   exit;
  end;
 end;
 with amodule^ do begin
  for int1:= 0 to components.count - 1 do begin
   comp1:= components.next^.instance;
   doinit(comp1);
   if not result then begin
    break;
   end;
  end;
 end;
end;

procedure tdesigner.dofixup;
begin
 RegisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
 try
  globalfixupreferences;
 finally
  unregisterFindGlobalComponentProc({$ifdef FPC}@{$endif}getglobalcomponent);
 end;
end;

function tdesigner.loadformfile(filename: msestring): pmoduleinfoty;
var
 module: tmsecomponent;
 loadedsubmodulesindex: integer;
 moduleinfo: tmoduleinfo;
  
 procedure dodelete;
 var
  int1: integer;
 begin
  removefixupreferences(module,'');
  for int1:= high(floadedsubmodules) downto loadedsubmodulesindex+1 do begin
   removefixupreferences(floadedsubmodules[int1],'');
  end;
//  fmodules.delete(fmodules.findmodule(result)); //remove added module
  moduleinfo.free;
  module.Free;
  module:= nil;
  result:= nil;
 end;
 
var
 moduleclassname1,modulename,
 designmoduleclassname{,inheritedmoduleclassname}: string;
 stream1: ttextstream;
 stream2: tmemorystream;
 reader: treader;
 flags: tfilerflags;
 pos: integer;
 rootnames: tstringlist;
 int1: integer;
 wstr1: msestring;
 res1: modalresultty;
 bo1: boolean;
 loadingdesignerbefore: tdesigner;
 loadingmodulepobefore: pmoduleinfoty;
 isinherited: boolean;
 str1: string;

begin //loadformfile
 filename:= filepath(filename);
 result:= fmodules.findmodule(filename);
 if result = nil then begin
  designnotifications.closeobjecttext(idesigner(self),filename,bo1);
  if bo1 then begin
   exit; //canceled
  end;
  stream1:= ttextstream.Create(filename,fm_read);
  designmoduleclassname:= '';
//  inheritedmoduleclassname:= '';
  try
   stream2:= tmemorystream.Create;
   try
    try
     objecttexttobinary(stream1,stream2);
     stream2.position:= 0;
     reader:= treader.create(stream2,4096);
     try
      with treader1(reader) do begin
      {$ifdef FPC}
       driver.beginrootcomponent;
       driver.begincomponent(flags,pos,moduleclassname1,modulename);
      {$else}
       readsignature;
       ReadPrefix(flags,pos);
       moduleclassname1:= ReadStr;
       modulename:= ReadStr;
       {$endif}
       isinherited:= ffinherited in flags;
       while not endoflist do begin
      {$ifdef FPC}
        str1:= driver.beginproperty;
      {$else}
        str1:= readstr;
       {$endif}
        if str1 = moduleclassnamename then begin
         designmoduleclassname:= readstring;
        end
        else begin
         {$ifdef FPC}driver.{$endif}skipvalue;
        end;
       end;
      end;
     finally
      reader.free;
     end;
     stream2.Position:= 0;
     loadingdesignerbefore:= loadingdesigner;
     loadingdesigner:= self;
     begingloballoading;
     try
      try
       moduleinfo:= fmodules.newmodule(isinherited,filename,moduleclassname1,modulename,
       designmoduleclassname);
       fmodules.add(moduleinfo);
       result:= @moduleinfo.info;
       module:= result^.instance;
       stream2.Position:= 0;
       reader:= treader.Create(stream2,4096);
       loadedsubmodulesindex:= high(floadedsubmodules);
       inc(fformloadlevel);
       loadingmodulepobefore:= floadingmodulepo;
       try
        floadingmodulepo:= result;
        lockfindglobalcomponent;
        try
         reader.onfindmethod:= {$ifdef FPC}@{$endif}findmethod;
         reader.onfindcomponentclass:= {$ifdef FPC}@{$endif}findcomponentclass;
         reader.onancestornotfound:= {$ifdef FPC}@{$endif}ancestornotfound;
         reader.oncreatecomponent:= {$ifdef FPC}@{$endif}createcomponent;
         reader.ReadrootComponent(module);
         doswapmethodpointers(module,true);
         module.Name:= modulename;
         result^.components.assigncomps(module);
         rootnames:= tstringlist.create;
         getfixupreferencenames(module,rootnames);
         setlength(result^.referencedmodules,rootnames.Count);
         for int1:= 0 to high(result^.referencedmodules) do begin
          result^.referencedmodules[int1]:= rootnames[int1];
         end;
         dofixup;
         while true do begin
          rootnames.clear;
          getfixupreferencenames(module,rootnames);
          if rootnames.Count > 0 then begin
           if assigned(fongetmodulenamefile) then begin
            try
             res1:= mr_cancel;
             fongetmodulenamefile(result,rootnames[0],res1);
             dofixup;
             case res1 of
              mr_ok: begin
              end;
              mr_ignore: begin
               rootnames.Clear;
               break;
              end;
              else begin
               break;
              end;
             end;
            except
             application.handleexception(self);
             break;
            end;
           end
           else begin
            break;
           end;
          end
          else begin
           break;
          end;
         end;
         if module <> nil then begin
          removefixupreferences(module,'');
         end;
         if rootnames.Count > 0 then begin
          wstr1:= rootnames[0];
          for int1:= 1 to rootnames.Count - 1 do begin
           wstr1:= wstr1 + ','+rootnames[int1];
          end;
          rootnames.free;
          raise exception.Create('Unresolved reference to '+wstr1+'.');
         end;
         rootnames.free;
         result^.resolved:= true;
        except
         dodelete;
         raise;
        end;
       finally
        floadingmodulepo:= loadingmodulepobefore;
        setlength(floadedsubmodules,loadedsubmodulesindex+1);
                     //remove info
        dec(fformloadlevel);
        if fformloadlevel = 0 then begin
         removefixupreferences(nil,'');
        end;
        unlockfindglobalcomponent;
        reader.free;
       end;
       if result <> nil then begin
        result^.designform:= createdesignform(self,result);
        checkmethodtypes(result,true,nil);
 //       showformdesigner(result);
        result^.modified:= false;
       end;
      finally
       loadingdesigner:= nil;
      end;
      notifygloballoading;
     finally
      loadingdesigner:= loadingdesignerbefore;
      endgloballoading;
     end;
    except
     on e: exception do begin
      e.Message:= 'Can not read formfile "'+filename+'".'+lineend+e.Message;
      raise;
     end;
    end;
   finally
    stream2.Free;
   end;
  finally
   stream1.Free;
  end;
 end;
end; //loadformfile

procedure createbackupfile(const newname,origname: filenamety;
           var backupcreated: boolean; const backupcount: integer);
var
 int1: integer;
 mstr1: filenamety;
 mstr2: filenamety;
begin
 if (backupcount > 0) and not backupcreated and 
      issamefilename(newname,origname) then begin
  backupcreated:= true;
  mstr1:= origname + backupext;
  for int1:= backupcount-1 downto 2 do begin
   mstr2:= mstr1+inttostr(int1-1);
   if findfile(mstr2) then begin
    msefileutils.renamefile(mstr2,mstr1+inttostr(int1));
   end;
  end;
  if backupcount > 1 then begin
   if findfile(mstr1) then begin
    msefileutils.renamefile(mstr1,mstr1+'1');
   end;
  end;
  msefileutils.copyfile(origname,mstr1);
 end;
end;  

procedure tdesigner.buildmethodtable(const amodule: pmoduleinfoty);
begin
 if amodule <> nil then begin
  with amodule^ do begin
   if methodtableswapped = 0 then begin
    flookupmodule:= amodule;
    methodtablebefore:= swapmethodtable(instance,methods.createmethodtable);
   end;
   inc(methodtableswapped);
  end;
 end;
end;

procedure tdesigner.releasemethodtable(const amodule: pmoduleinfoty);
begin
 if amodule <> nil then begin
  with amodule^ do begin
   dec(methodtableswapped);
   if methodtableswapped = 0 then begin
    swapmethodtable(instance,methodtablebefore);
    methods.releasemethodtable;
    flookupmodule:= nil;
   end;
  end;
 end;
end;

procedure tdesigner.writemodule(const amodule: pmoduleinfoty;
                                     const astream: tstream);
var
 writer1: twriter;
 ancestor: tcomponent;
begin
 buildmethodtable(amodule);
 with amodule^ do begin
  fdescendentinstancelist.beginstreaming;
  doswapmethodpointers(instance,false);
  writer1:= twriter.create(astream,4096);
  beginstreaming(amodule);
  try
   if csancestor in instance.componentstate then begin
    ancestor:= fdescendentinstancelist.findancestor(instance);
   end
   else begin
    ancestor:= nil;
   end;
   writer1.onfindancestor:= {$ifdef FPC}@{$endif}findancestor;
   writer1.writedescendent(instance,ancestor);
  finally
   fdescendentinstancelist.endstreaming;
   endstreaming(amodule);
   writer1.free;
   doswapmethodpointers(instance,true);
   releasemethodtable(amodule);
   if instance is twidget then begin
    fdescendentinstancelist.restorepos(twidget(instance));
   end;
  end;
 end;
end;

function tdesigner.saveformfile(const modulepo: pmoduleinfoty;
                 const afilename: msestring; createdatafile: boolean): boolean;
                      //false if aborted
var
 stream1: tmemorystream;
 stream2: tmsefilestream;
 
begin
 if createdatafile and projectoptions.checkmethods 
                       and not checkmethodtypes(modulepo,false,nil) then begin
  result:= false;
  exit;
 end;
 result:= true;
 with modulepo^ do begin
  createbackupfile(afilename,filename,backupcreated,projectoptions.backupfilecount);
  stream1:= tmemorystream.Create;
  try
   writemodule(modulepo,stream1);
   stream2:= tmsefilestream.create(afilename,fm_create);
   try
    stream1.position:= 0;
    objectbinarytotextmse(stream1,stream2);
   finally
    stream2.Free;
   end;
   if issamefilename(afilename,filename) then begin
    modified:= false;
   end;
   if createdatafile then begin
    formtexttoobjsource(afilename,moduleclassname,'',fobjformat);
   end;
  finally
   stream1.free;
  end;
 end;
end;

function tdesigner.saveall(noconfirm,createdatafile: boolean): modalresultty;
var
 int1: integer;
 po1: pmoduleinfoty;
begin
 result:= mr_none;
 for int1:= 0 to modules.count - 1 do begin
  po1:= modules[int1];
  with po1^ do begin
   if not modified and projectoptions.checkmethods then begin
    if not checkmethodtypes(po1,false,nil) then begin
     result:= mr_cancel;
     exit;
    end;
   end;
   if modified and (result <> mr_noall) and 
     (noconfirm or 
      (result = mr_all) or
      not fallsaved and confirmsavechangedfile(filename,result,true)) then begin
    if not saveformfile(po1,filename,createdatafile) then begin
     result:= mr_cancel;
    end;
   end;
   case result of 
    mr_cancel: begin
     exit;
    end;
    mr_noall: begin
     break;
    end;
   end;
  end;
 end;
 fallsaved:= fallsaved or not noconfirm;
end;

function tdesigner.closemodule(const amodule: pmoduleinfoty;
                             const checksave: boolean): boolean; //true if closed
var
 closingmodules: moduleinfopoarty;
 
 procedure dochecksave(const amodule: pmoduleinfoty);
 var
  modalresult: modalresultty;
  int1: integer;
  ar1: stringarty;
  ar2: moduleinfopoarty;
 begin
  ar1:= nil; //compiler warning
  if amodule <> nil then begin
   modalresult:= mr_none;
   for int1:= 0 to high(closingmodules) do begin
    if closingmodules[int1] = amodule then begin
     exit; //already checked;
    end;
   end;
   with amodule^ do begin
    if modified and checksave and
                 confirmsavechangedfile(filename,modalresult,false) then begin
     saveformfile(amodule,filename,true);
    end;
   end;
   result:= modalresult <> mr_cancel;
   if result then begin
    additem(pointerarty(closingmodules),amodule);
    ar1:= getreferencingmodulenames(amodule);
    setlength(ar2,length(ar1));
    for int1:= 0 to high(ar1) do begin
     ar2[int1]:= modules.findmodulebyname(ar1[int1]);
     dochecksave(ar2[int1]);
     if not result then begin
      break;
     end;
    end;
   end;
  end;
 end;
 
var
 int1: integer;
 
begin //closemodule
 result:= false;
 closingmodules:= nil;
 dochecksave(amodule);
 if result then begin
  for int1:= 0 to high(closingmodules) do begin
   if closingmodules[int1] <> nil then begin
    modules.removemoduleinfo(closingmodules[int1]);
   end;
  end;
 end;
end; //closemodule

function tdesigner.modified: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to fmodules.count - 1 do begin
  if modules[int1]^.modified then begin
   result:= true;
   break;
  end;
 end;
end;

procedure tdesigner.NoSelection;
begin
 selectcomponent(nil);
end;

procedure tdesigner.SelectComponent(Instance: Tcomponent);
var
 list: tdesignerselections;
begin
 freeandnil(fcomponenteditor);
 list:= tdesignerselections.create;
 try
  if instance <> nil then begin
   list.Add(instance);
   fcomponenteditor:= componenteditors.geteditorclass(
                componentclassty(instance.classtype)).create(idesigner(self),instance);
  end;
  setselections(idesignerselections(list));
 finally
  list.Free;
 end;
end;

procedure tdesigner.selectionchanged;
begin
 designnotifications.SelectionChanged(idesigner(self),idesignerselections(fselections));
end;

procedure tdesigner.SetSelections(const List: IDesignerSelections);
var
 int1: integer;
 component1: tcomponent;
begin
 for int1:= 0 to fselections.count - 1 do begin
  component1:= fselections[int1];
  if component1 is tmsecomponent then begin
   tmsecomponent1(component1).designselected(false);
  end;
 end;
 fselections.assign(list);
 for int1:= 0 to fselections.count - 1 do begin
  component1:= fselections[int1];
  if component1 is tmsecomponent then begin
   tmsecomponent1(component1).designselected(true);
  end;
 end;
 selectionchanged;
end;
{
procedure tdesigner.checkobjectinspector;
begin
 if objectinspectorfo = nil then begin
  objectinspectorfo:= tobjectinspectorfo.create(nil,self);
 end;
end;
}
procedure tdesigner.showobjectinspector;
begin
// checkobjectinspector;
 objectinspectorfo.activate;
end;

function tdesigner.formfiletoname(const filename: msestring): msestring;
begin
 result:= removefileext(msefileutils.filename(filename));
end;

function tdesigner.getmethod(const aname: string;
               const methodowner: tmsecomponent; const atype: ptypeinfo): tmethod;
begin
 result:= fmodules.findmethodbyname(aname,atype,methodowner);
end;

function tdesigner.getmethodname(const Method: TMethod; const comp: tcomponent): string;
begin
 result:= fmodules.findmethodname(method,comp);
end;

function tdesigner.actmodulepo: pmoduleinfoty;
begin
 result:= factmodulepo;
end;

function tdesigner.getcomponentname(const comp: tcomponent): string;
var
 int1: integer;
 po1: pmoduleinfoty;
begin
 result:= '';
 if comp <> nil then begin
  if comp.Owner = floadingmodulepo^.instance then begin
   result:= comp.name;
  end
  else begin
   for int1:= 0 to fmodules.count - 1 do begin
    po1:= fmodules[int1];
    if issubcomponent(po1^.instance,comp) then begin
     result:= po1^.instancevarname + '.' + getcomponentdispname(comp);
//    if po1^.instance = comp.Owner then begin
//     result:= po1^.instancevarname + '.' + comp.Name;
     break;
    end;
   end;
  end;
 end;
end;

function tdesigner.getcomponentdispname(const comp: tcomponent): string;
                   //returns qualified name
var
 comp1: tcomponent;
 bo1: boolean;
begin
 result:= comp.Name;
 comp1:= comp.owner;
 while not ismodule(comp1) do begin
  result:= comp1.Name + '.' + result;
  comp1:= comp1.Owner;
 end;
 bo1:= ismodule(comp);
 if bo1 or ismodule(comp.owner) then begin
  if csancestor in comp.componentstate then begin
   if bo1 then begin
    comp1:= comp;
   end
   else begin
    comp1:= comp.owner;
   end;
   comp1:= fdescendentinstancelist.findancestor(comp1);
   if comp1 <> nil then begin
    result:= result+'<'+comp1.name+'>';
   end;
  end;
 end;
end;

function tdesigner.getcomponent(const aname: string; 
                      const aroot: tcomponent): tcomponent;
var
 strar1: stringarty;
 po1,po2: pmoduleinfoty;
 int1,int2: integer;
 bo1: boolean;
begin
 if floadingmodulepo <> nil then begin
  result:= floadingmodulepo^.components.getcomponent(aname);
  if result = nil then begin
   splitstring(aname,strar1,'.');
   if high(strar1) = 1 then begin
    strar1[0]:= uppercase(strar1[0]);
    for int1:= 0 to fmodules.count - 1 do begin
     po1:= fmodules[int1];
     if stricomp(pchar(po1^.instancevarname),pchar(strar1[0])) = 0 then begin
      result:= po1^.components.getcomponent(strar1[1]);
      if result <> nil then begin
       if (aroot <> nil) and (aroot <> po1^.instance) then begin
        po2:= fmodules.findmodulebyinstance(aroot);
        if po2 <> nil then begin
         bo1:= false;
         for int2:= 0 to high(po2^.referencedmodules) do begin
          if po2^.referencedmodules[int2] = aroot.name then begin
           bo1:= true;
           break;
          end;
         end;
         if not bo1 then begin
          additem(po2^.referencedmodules,po1^.instance.name);
         end;
        end;
       end;
       break;
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  result:= nil;
 end;
end;

function tdesigner.getcomponentlist(
             const acomponentclass: tcomponentclass): componentarty;
var
 int1,int2: integer;
 comp1: tcomponent;
begin
 if floadingmodulepo <> nil then begin
  with floadingmodulepo^.components do begin
   setlength(result,count);
   int2:= 0;
   for int1:= 0 to high(result) do begin
    comp1:= next^.instance;
    if comp1.InheritsFrom(acomponentclass) then begin
     result[int2]:= comp1;
     inc(int2);
    end;
   end;
  end;
  setlength(result,int2);
 end
 else begin
  result:= nil;
 end;
end;

function compcompname(const l,r): integer;
begin
 result:= ord(msestring(l)[1])-ord(msestring(r)[1]);
 if result = 0 then begin
  result:= countchars(msestring(l),msechar('.')) -
                countchars(msestring(r),msechar('.'));
  if result = 0 then begin
   result:= msestringicomp(msestring(l),msestring(r));
  end;
 end;
end;

function tdesigner.getcomponentnamelist(const acomponentclass: tcomponentclass;
                            const includeinherited: boolean;
                            const aowner: tcomponent = nil): msestringarty;
var
 int1,int2: integer;
 comp1: tcomponent;
 str1: msestring;
 po1: pmoduleinfoty;
 acount: integer;
begin
 result:= nil;
 acount:= 0;
 for int1:= 0 to fmodules.count - 1 do begin
  po1:= fmodules[int1];
  if po1 = floadingmodulepo then begin
   str1:= ' ';
  end
  else begin
   str1:= 'z'+po1^.instancevarname + '.';
  end;
  with po1^.components do begin
   for int2:= 0 to count - 1 do begin
    comp1:= next^.instance;
    if comp1.InheritsFrom(acomponentclass) then begin
     if ((aowner = nil) or (aowner = comp1.owner)) and 
              (includeinherited or 
              (comp1.componentstate * [csinline,csancestor] = [])) then begin
      additem(result,str1+getcomponentdispname(comp1),acount);
     end;
    end;
   end;
  end;
 end;
 setlength(result,acount);
 sortarray(result,{$ifdef FPC}@{$endif}compcompname);
 for int1:= 0 to high(result) do begin
  result[int1]:= copy(result[int1],2,bigint);
 end;
end;

function tdesigner.getmodules: tmodulelist;
begin
 result:= fmodules;
end;

function tdesigner.findcomponentmodule(const acomponent: tcomponent): pmoduleinfoty;
var
 int1: integer;
 po1: pmoduleinfoty;
begin
 result:= nil;
 for int1:= 0 to fmodules.count-1 do begin
  po1:= fmodules[int1];
  if po1^.components.find(acomponent) <> nil then begin
   result:= po1;
   break;
  end;
 end;
end;

procedure tdesigner.validaterename(const acomponent: tcomponent;
                    const curname,NewName: string);
var
 po1: pmoduleinfoty;
 ar1: objectarty;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 po1:= findcomponentmodule(acomponent);
 if po1 <> nil then begin
  if newname = '' then begin
   raise exception.Create('Invalid component name,');
  end;
  if acomponent.name <> newname then begin
   po1^.components.namechanged(acomponent,newname);
   designnotifications.componentnamechanging(idesigner(self),po1^.instance,
                                      acomponent,newname);
   if acomponent is tmsecomponent then begin
    ar1:= tmsecomponent(acomponent).linkedobjects;
   end
   else begin
    ar1:= objectarty(getlinkedcomponents(acomponent));
   end;
  end;
  for int1:= 0 to high(ar1) do begin
   if ar1[int1] is tcomponent then begin
    componentmodified(tcomponent(ar1[int1]));
   end;
  end;
 end;
end;

function tdesigner.getclassname(const comp: tcomponent): string;
                   //returns submoduleclass if appropriate
begin
 result:= fdescendentinstancelist.getclassname(comp);
end;

function tdesigner.getcomponenteditor: icomponenteditor;
begin
 if fcomponenteditor = nil then begin
  result:= nil;
 end
 else begin
  result:= icomponenteditor(fcomponenteditor);
 end;
end;

procedure tdesigner.savecanceled;
begin
 fallsaved:= false;
end;

{ tcomponentslink }

procedure tcomponentslink.notification(acomponent: tcomponent;
  operation: toperation);
begin
 if operation = opremove then begin
  fowner.destroynotification(acomponent);
 end;
 inherited;
end;

initialization
 fdesigner:= tdesigner.create;
finalization
 fdesigner.Free;
end.
