{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mclasses,msegraphutils,mseglob,mseguiglob,msedesignintf,
 mseforms,mselist,msearrayutils,msebitmap,msetypes,sysutils,msehash,mseclasses,
 mseformdatatools,typinfo,msepropertyeditors,msecomponenteditors,msegraphics,
 mseapplication,msegui,msestrings,msedesignparser,msecomptree,mseevent;

{$ifndef mse_methodswap}
 {$ifdef FPC} {$define mse_nomethodswap}{$endif}
{$endif}

const
 formfileext = 'mfm';
 pasfileext = 'pas';
 backupext = '.bak';
 subcomponentsplitchar = ':';

type
 tdesigner = class;

 moduleoptionty = (mo_hidewidgets,mo_hidecomp);
 moduleoptionsty = set of moduleoptionty;

 iformdesigner = interface(inullinterface)
                           ['{0207E291-638A-4A1B-BA9F-4FB0F6A0EA29}']
  function clickedcomponent: tcomponent;
  function getmoduleoptions: moduleoptionsty;
  procedure setmoduleoptions(const aoptions: moduleoptionsty);
  property moduleoptions: moduleoptionsty read getmoduleoptions
                                                 write setmoduleoptions;
 end;
 
 methodinfoty = record
  name: string;
  address: pointer;
  typeinfo: ptypeinfo;
 end;
 pmethodinfoty = ^methodinfoty;
 tmethods = class;
 methodsarty = array of tmethods;

 methodsdataty = record
  key: ptruint;
  data: methodinfoty;
 end;
 pmethodsdataty = ^methodsdataty;
 
 tmethods = class(tptruinthashdatalist)
  private
   fdesigner: tdesigner;
   {fapropname,fapropvalue: string;}
{$ifndef mse_nomethodswap}
   fmethodtable: pointer;
{$endif}
  protected
   procedure finalizeitem(var aitemdata); override;
   procedure deletemethod(const aadress: pointer);
   procedure addmethod(const aname: string; const aaddress: pointer;
                       const atypeinfo: ptypeinfo);
  public
   constructor create(adesigner: tdesigner);
   destructor destroy; override;
   function findmethod(const aadress: pointer): pmethodinfoty;
   function findmethodbyname(const aname: string; const atype: ptypeinfo;
                             out namefound: boolean): pmethodinfoty; overload;
   function findmethodbyname(const aname: string): pmethodinfoty; overload;
{$ifndef mse_nomethodswap}
   function createmethodtable(const ancestors: methodsarty): pointer;
   procedure releasemethodtable;
{$endif}
 end;

 tmethodnames = class(tansistringptruinthashdatalist)
  public
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
  moduleclassname: string[80]; //can not be ansistring!
  instancevarname: string;
  instance: tmsecomponent;
  moduleintf: pdesignmoduleintfty;
  designformclass: pointer;
  methods: tmethods;
 {$ifndef mse_nomethodswap}
  methodtableswapped: integer;
  methodtablebefore: pointer;
 {$endif}
  backupcreated: boolean;
  modified: boolean;
  resolved: boolean;
  hasmenuitem: boolean;
//  options: moduleoptionsty;
  components: tcomponents;
  designform: tmseform;
  designformintf: iformdesigner;
  referencedmodules: stringarty;
  loadingstream: tstream;
 end;
 pmoduleinfoty = ^moduleinfoty;
 moduleinfopoarty = array of pmoduleinfoty;

 componentsdataty = record
  key: ptruint;
  data: componentinfoty;
 end;
 pcomponentsdataty = ^componentsdataty;
  
 tcomponents = class(tptruinthashdatalist)
  private
   fdesigner: tdesigner;
   fcomponent: tcomponentslink; // to receive componentnotifications
   fowner: pmoduleinfoty;
  protected
   procedure finalizeitem(var aitemdata); override;
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
   fmethodnames: tmethodnames;
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
   procedure freeloadingstreams;

  public
   constructor create(adesigner: tdesigner); reintroduce;
   destructor destroy; override;
   procedure designformdestroyed(const sender: tmseform);
   function delete(index: integer): pointer; override;
   function findmodule(const filename: msestring): pmoduleinfoty; overload;
   function findmodule(const amodule: tmsecomponent): pmoduleinfoty; overload;
   function findmodule(const po: pmoduleinfoty): integer;  overload;
   function findmodulebyname(const name: string): pmoduleinfoty;
   function findmoduleinstancebyname(const name: string): tcomponent;
   function findmoduleinstancebyclass(const aclass: tclass): tcomponent;
   function findmodulebyclassname(aclassname: string): pmoduleinfoty;
   function findmodulebycomponent(const acomponent: tcomponent): pmoduleinfoty;
   function findmodulebyinstance(const ainstance: tcomponent): pmoduleinfoty;
   function findownermodule(const acomponent: tcomponent): pmoduleinfoty;
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
 ancestorinfoarty = array of ancestorinfoty;
 ancestorinfoaty = array[0..0] of ancestorinfoty;
 pancestorinfoaty = ^ancestorinfoaty;

 ancestornameinfoty = record
  desc,anc: string;
 end;
 ancestornameinfoarty = array of ancestornameinfoty;
 
 tancestorlist = class(tobjectlinkrecordlist)
  private
   fstreaming: integer;
{$ifndef mse_nomethodswap}
   fswappedancestors: componentarty;
{$endif}
  protected
   procedure dounlink(var item); override;
   procedure doitemdestroyed(const sender: tmsecomponent); virtual;
   procedure itemdestroyed(const sender: iobjectlink); override;
   function getdescendentar(const aancestor: tmsecomponent): msecomponentarty;
{$ifndef mse_nomethodswap}
   procedure streamingswapmethodpointer(const acomp: tcomponent);
{$endif}
  public
   constructor create;
   function findancestor(const adescendent: tcomponent): tmsecomponent;
   function finddescendent(const aancestor: tcomponent): tmsecomponent;
   function finddescendentinfo(const adescendent: tcomponent): pancestorinfoty;
   function findancestorinfo(const aancestor: tcomponent): pancestorinfoty;
   function findinfo(const ainfo: ancestornameinfoty): pancestorinfoty;
   procedure getinfo(const apo: pancestorinfoty; out info: ancestornameinfoty);
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

 tsubmodulelist = class(tdesignerancestorlist,ievent)
       //ancestor is copy of old state of descendent,
       //descendent is real submodule
  protected
   frenewbackuplist: msecomponentarty;
   procedure finalizerecord(var item); override;
   procedure dorenewbackup;
   procedure receiveevent(const event: tobjectevent);
   procedure doitemdestroyed(const sender: tmsecomponent); override;
  public
   procedure add(const amodule: tmsecomponent); overload;
   procedure renewbackup(const amodule: tmsecomponent);
   function findoldancestor(const adescendent: tmsecomponent): tmsecomponent;
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
   fdelcomps:componentarty;
   froot: tcomponent;
   fmodule: pmoduleinfoty;
   fmodulemodifying: boolean;
   fmodifiedmodules: moduleinfopoarty;
   frefreshmethods: methodsarty;
   fcomponentnamechanging: boolean;
   fdeletedcomps: componentarty;
   procedure delcomp(child: tcomponent);
   procedure addcomp(child: tcomponent);
   procedure domodulemodified(const amodule: pmoduleinfoty;
           modifylevel: integer; destcompnames,ancestorcompnames: stringarty;
           newancestorcomps,oldancestorcomps: msecomponentarty);
  {$ifdef mse_nomethodswap}
   procedure setrefreshmethod(reader: treader; instance: tpersistent;
                        propinfo: ppropinfo; const themethodname: string;
                                                        var handled: boolean);
  {$else}
   procedure findrefreshmethod(reader: treader; const amethodname: string;
                          var address: pointer; var error: boolean);
  {$endif}
   procedure modulemodified(const amodule: pmoduleinfoty);
   procedure componentnamechanged(const amodule: pmoduleinfoty;
                    const acomponent: tcomponent; const newname: string);
   procedure setnodefaultpos(const aroot: twidget);
   procedure restorepos(const aroot: twidget);
  public
   procedure beginstreaming(const amodule: pmoduleinfoty);
   procedure add(const instance,ancestor: tmsecomponent;
                        const submodulelist: tsubmodulelist); overload;
   function getclassname(const comp: tcomponent): string;
                   //returns submodule or root classname if appropriate
   function getancestors(const adescendent: tcomponent): componentarty;
   function getancestorsandchildren(const adescendent: tcomponent): componentarty;
   function getdescendents(const aancestor: tcomponent): componentarty;
 end;

 getmoduleeventty = procedure(const amodule: pmoduleinfoty;
                             const aname: string; var action: modalresultty) of object;
                                      //mr_ignore,mr_ok, cancel otherwise
 getmoduletypeeventty = procedure(const atypename: string) of object;
 propprocty = procedure(const ainstance: tobject; const data: pointer; 
                const apropinfo: ppropinfo);
 
 forallmethpropinfoty = record
  root: tcomponent;
  dat: pointer;
  proc: propprocty;
  dochi: boolean;
 end;

 designerstatety = (des_pasting,des_inheritednewmodule);
 designerstatesty = set of designerstatety;
  
 tdesigner = class(tactcomponent,idesigner)
  private
   fselections: tdesignerselections;
   factmodulepo: pmoduleinfoty;
   floadingmodulepo: pmoduleinfoty;
   flastmethodmodulepo: pmoduleinfoty;
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
   fformloadlocklevel: integer;
   fnotifydeletedlock: integer;
   fallsaved: boolean;
   fcreatecomponenttag: integer; //incremented by createcoponent
   ffindcompclasstag: integer;       //stamp of createcomponenttag
   fcheckfixups: moduleinfopoarty;
   function formfiletoname(const filename: msestring): msestring;
  {$ifdef mse_nomethodswap}
   procedure setmethodproperty(reader: treader;
                        instance: tpersistent;
                        propinfo: ppropinfo; const themethodname: string;
                        var handled: boolean);
  {$else}
   procedure findmethod(Reader: TReader; const aMethodName: string;
                   var Address: Pointer; var Error: Boolean);
  {$endif}
   function getinheritedmodule(const aclassname: string): pmoduleinfoty;
   function findcomponentmodule(const acomponent: tcomponent): pmoduleinfoty;
   procedure selectionchanged;
{$ifndef mse_nomethodswap}
   procedure docopymethods(const source, dest: tcomponent; const force: boolean);
{$endif}
   procedure writemodule(const amodule: pmoduleinfoty; const astream: tstream);
   procedure notifydeleted(comp: tcomponent);
   procedure componentdestroyed(const acomponent: tcomponent; const module: pmoduleinfoty);
   procedure dofixup;
  {$ifndef mse_nomethodswap}
   procedure buildmethodtable(const amodule: pmoduleinfoty);
   procedure releasemethodtable(const amodule: pmoduleinfoty);
  {$endif}
  protected
   fstate: designerstatesty;
//   procedure doasyncevent(var atag: integer); override;
   procedure readererror(reader: treader; const message: string;
                                 var handled: boolean);
   procedure forallmethodproperties(const aroot: tcomponent;
                 const ainstance: tobject; const data: pointer;
                 const aproc: propprocty;
                 const dochildren: boolean);
   procedure componentevent(const event: tcomponentevent); override;
   function checkmodule(const filename: msestring): pmoduleinfoty;
   procedure checkident(const aname: string);
   procedure beginstreaming(const amodule: pmoduleinfoty);
   procedure endstreaming(const amodule: pmoduleinfoty);
   property selections: tdesignerselections read fselections;
                 //do not modify!
  {$ifndef mse_nomethodswap}
   procedure internaldoswapmethodpointers(const aroot: tcomponent;
                      const ainstance: tobject; const ainit: boolean);
  {$endif}
  public
   constructor create; reintroduce;
   destructor destroy; override;

   procedure begincomponentmodify;
   procedure endcomponentmodify;
   procedure beginpasting;
   procedure endpasting;
   
   function beforemake: boolean; //true if ok
   procedure modulechanged(const amodule: pmoduleinfoty);
   function changemodulename(const filename: msestring; const avalue: string): string;
   function changemoduleclassname(const filename: msestring; const avalue: string): string;
   function changeinstancevarname(const filename: msestring; const avalue: string): string;
   function checksubmodule(const ainstance: tcomponent; 
              out aancestormodule: pmoduleinfoty): boolean;
   function getreferencingmodulenames(const amodule: pmoduleinfoty): stringarty;
   function checkmethodtypes(const amodule: pmoduleinfoty;
                                          const init: boolean): boolean;
                                      //false on cancel
{$ifndef mse_nomethodswap}
   procedure doswapmethodpointers(const ainstance: tobject; const ainit: boolean);
{$endif}
{$ifdef mse_nomethodswap}
   procedure writedesignmethod(writer: twriter; instance: tpersistent;
                          propinfo: ppropinfo;
                          const methodvalue, defmethodvalue: tmethod;
                          var handled: boolean);
{$endif}
   procedure ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
   procedure findcomponentclass(Reader: TReader; const aClassName: string;
                   var ComponentClass: TComponentClass);
   procedure findancestor(Writer: TWriter; Component: TComponent;
              const aName: string; var Ancestor, RootAncestor: TComponent);
   function findancestorcomponent(const acomponent: tcomponent): tcomponent;
   function getancestormethods(const amodule: pmoduleinfoty): methodsarty;
   procedure createcomponent1(reader: treader; componentclass: tcomponentclass;
                   var component: tcomponent);
   function createcomponent: tcreatecomponentevent;
   function selectedcomponents: componentarty;
   
      //idesigner
   procedure componentmodified(const component: tobject);
   procedure selectcomponent(instance: tcomponent);
   procedure setselections(const list: idesignerselections);
   function createnewcomponent(const module: tmsecomponent;
                                 const aclass: tcomponentclass): tcomponent;
   function createcurrentcomponent(const module: tmsecomponent): tcomponent;
   function hascurrentcomponent: boolean;
   procedure addcomponent(const module: tmsecomponent;
                              const acomponent: tcomponent);
   procedure deleteselection(adoall: boolean = false);
   procedure deletecomponent(const acomponent: tcomponent);
   procedure clearselection;
   procedure noselection;

   function getmethod(const aname: string; const methodowner: tmsecomponent;
              const atype: ptypeinfo; const searchancestors: boolean): tmethod;
   function getmethodname(const method: tmethod; const comp: tcomponent): string;
   procedure changemethodname(const method: tmethod; newname: string;
                                           const atypeinfo: ptypeinfo);
   function createmethod(const aname: string; const module: tmsecomponent;
                                 const atype: ptypeinfo): tmethod;
   procedure checkmethod(const method: tmethod; const aname: string;
                         const module: tmsecomponent; const atype: ptypeinfo);
   
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
   function editcomponent(const aowner: tcomponent = nil): boolean; //false if no editor available
   function getcomponentlist(const acomponentclass: tcomponentclass;
                     const filter: compfilterfuncty = nil;
                           const allmodules: boolean = false): componentarty;
   function getcomponentnamelist(const acomponents: componentarty;
                             const amodule: tmsecomponent): msestringarty;
                                      //nil values ignored
   function getcomponentnamelist(const acomponentclass: tcomponentclass;
                                 const includeinherited: boolean;
                                 const aowner: tcomponent = nil;
                          const filter: compfilterfuncty = nil): msestringarty;
   function getcomponentnametree(const acomponentclass: tcomponentclass;
                                 const includeinherited: boolean;
                                 const aowner: tcomponent = nil;
                          const filter: compfilterfuncty = nil): tcompnameitem;
   function getancestorclassinfo(const ainstance: tcomponent;
                 const interfaceonly: boolean): classinfopoarty;
                                                  overload;
   function getancestorclassinfo(const ainstance: tcomponent;
                 const interfaceonly: boolean;
                                 out aunits: unitinfopoarty): classinfopoarty;
                                                  overload;
                                                          
   procedure setmodulex(const amodule: tmsecomponent; avalue: integer);
   procedure setmoduley(const amodule: tmsecomponent; avalue: integer);
   procedure modulesizechanged(const amodule: tmsecomponent);

   function isownedmethod(const root: tcomponent; 
                                             const method: tmethod): boolean;
   procedure getmethodinfo(const method: tmethod; out moduleinfo: pmoduleinfoty;
                      out methodinfo: pmethodinfoty);
   function getmodules: tmodulelist;

   function loadformfile(filename: msestring;
                                const skipexisting: boolean): pmoduleinfoty;
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
   function clickedcomp: tcomponent;
   procedure moduledestroyed(const amodule: pmoduleinfoty);
   procedure addancestorinfo(const ainstance,aancestor: tmsecomponent);
   function copycomponent(const source: tmsecomponent;
           const root: tmsecomponent; const asinherited: boolean;
           const noloading: boolean):tmsecomponent;
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
function isdatasubmodule(const acomponent: tobject;
                         const iconified: boolean = false;
                         const both: boolean = false): boolean;

implementation

uses
 msestream,msefileutils,
// {$ifdef mswindows}windows{$else}mselibc{$endif},
 designer_bmp,msesys,msewidgets,formdesigner,objectinspector,
 msefiledialog,projectoptionsform,sourceupdate,sourceform,sourcepage,
 pascaldesignparser,msearrayprops,rtlconsts,msedatamodules,
 msesimplewidgets,msesysutils,mseobjecttext,msestreaming,msedatanodes,main,
 actionsmodule;

const
 renewbackuptag = 0;
 
type
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 twriter1 = class(twriter);
 treader1 = class(treader);
{$ifdef mse_nomethodswap}
 tbinaryobjectwriter1 = class(tbinaryobjectwriter);
{$endif}
 moduleeventty = (me_none,me_componentmodified);

var
 fdesigner: tdesigner;
 loadingdesigner: tdesigner;
 methodaddressdummy: ptruint;
 submodulecopy: integer;

function designer: tdesigner;
begin
 result:= fdesigner;
end;

function isnosubcomp(const acomp: tcomponent): boolean;
begin
 result:= (cssubcomponent in acomp.componentstyle) and 
           (acomp is tmsecomponent) and
            not(cs_subcompref in tmsecomponent1(acomp).fmsecomponentstate);
end;

function isdatasubmodule(const acomponent: tobject;
                         const iconified: boolean = false;
                         const both: boolean = false): boolean;
begin
 result:= (acomponent <> nil) and (acomponent is tmsedatamodule) and 
            (csinline in tmsedatamodule(acomponent).componentstate) and
            (both or
            (iconified = (dmo_iconic in tmsedatamodule(acomponent).options)));
end;

function issubprop(const obj1: tobject): boolean;
begin
 result:= (obj1 <> nil) and (not (obj1 is tcomponent) or 
            (cssubcomponent in tcomponent(obj1).componentstyle) and
             ((tcomponent(obj1).owner = nil) or 
               (obj1 is tmsecomponent) and 
                not(cs_subcompref in tmsecomponent1(obj1).fmsecomponentstate)));
end;

function ismodule(const acomponent: tcomponent): boolean;
begin
 result:= (acomponent = nil) or (acomponent.owner = nil);
// result:= (acomponent.owner = nil) or (acomponent.owner.owner = nil);
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

{ tancestorlist }

constructor tancestorlist.create;
begin
 inherited create(sizeof(ancestorinfoty));
end;

procedure tancestorlist.doitemdestroyed(const sender: tmsecomponent);
var
 int1: integer;
 bo1: boolean;
begin
 for int1:= count - 1 downto 0 do begin
  with pancestorinfoty(getitempo(int1))^ do begin
   bo1:= false;
   if descendent = sender then begin
    descendent:= nil;
    bo1:= true;
   end;
   if ancestor = sender then begin
    ancestor:= nil;
    bo1:= true;
   end;
   if bo1 then begin
    delete(int1);
   end;
  end;
 end;
end;

procedure tancestorlist.itemdestroyed(const sender: iobjectlink);
begin
 doitemdestroyed(tmsecomponent(sender.getinstance));
end;

function tancestorlist.getdescendentar(
                             const aancestor: tmsecomponent): msecomponentarty;
var
 int1,int2: integer;
 po1: pancestorinfoty;
begin
 setlength(result,count);
 int2:= 0;
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  if po1^.ancestor = aancestor then begin
   result[int2]:= po1^.descendent;
   inc(int2);
  end;
  inc(po1);
 end;
 setlength(result,int2);
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

{$ifndef mse_nomethodswap}
procedure tancestorlist.streamingswapmethodpointer(const acomp: tcomponent);
begin
 if (fstreaming > 0) then begin
  if finditem(pointerarty(fswappedancestors),acomp) < 0 then begin
   designer.doswapmethodpointers(acomp,false);
   additem(pointerarty(fswappedancestors),acomp);
  end;
 end;
end;
{$endif}

function tancestorlist.findancestor(
                              const adescendent: tcomponent): tmsecomponent;
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
{$ifndef mse_nomethodswap}
 if result <> nil then begin
  streamingswapmethodpointer(result);
 end;
{$endif}
end;

procedure tancestorlist.beginstreaming;
begin
 inc(fstreaming);
end;

procedure tancestorlist.endstreaming;
{$ifndef mse_nomethodswap}
var
 int1: integer;
 ar1: componentarty;
{$endif}
begin
 dec(fstreaming);
{$ifndef mse_nomethodswap}
 ar1:= nil; //compiler warning
 if fstreaming = 0 then begin
  ar1:= copy(fswappedancestors);
  fswappedancestors:= nil;
  for int1:= 0 to high(ar1) do begin
   designer.doswapmethodpointers(ar1[int1],true);
  end;
 end;
{$endif}
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

function tancestorlist.findinfo(const ainfo: ancestornameinfoty): pancestorinfoty;
var
 po1: pancestorinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  if (namepathowner(po1^.descendent) = ainfo.desc) and 
       (namepathowner(po1^.ancestor) = ainfo.anc) then begin
   result:= po1;
   break;
  end;
  inc(po1);
 end;
end;

procedure tancestorlist.getinfo(const apo: pancestorinfoty;
               out info: ancestornameinfoty);
begin
 info.desc:= namepathowner(apo^.descendent);
 info.anc:= namepathowner(apo^.ancestor);
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
 if comp <> nil then begin
  removefixupreferences(comp,'');
 end;
 comp.Free;
end;

procedure tsubmodulelist.add(const amodule: tmsecomponent);
begin
 if findancestor(amodule) = nil then begin
  inherited add(amodule,fdesigner.copycomponent(amodule,amodule,false,false));
//  inherited add(amodule,fdesigner.copycomponent(amodule,nil));
 end;
end;

procedure tsubmodulelist.dorenewbackup;
var
 po1: pancestorinfoty;
 comp: tmsecomponent;
 amodule: tmsecomponent;
 int1: integer;
begin
 try
  for int1:= 0 to high(frenewbackuplist) do begin
   amodule:= frenewbackuplist[int1];
   if amodule <> nil then begin
    po1:= finddescendentinfo(amodule);
    if po1 <> nil then begin
     comp:= po1^.ancestor;
     po1^.ancestor:= nil;
     if comp <> nil then begin
      removefixupreferences(comp,'');
     end;  
     comp.Free;  
    {$ifdef mse_debugcopycomponent}
     debugwriteln('***renewbackup before copy '+amodule.name);
     dumpcomponent(amodule,'source:');
    {$endif}
//     fdesigner.fsubmoduleinfopo:= nil;
     po1^.ancestor:= fdesigner.copycomponent(amodule,amodule,false,false);
    {$ifdef mse_debugcopycomponent}
     debugwriteln('***renewbackup after copy '+amodule.name);
     dumpcomponent(amodule,'source:');
     dumpcomponent(po1^.ancestor,'backup:');
    {$endif}
   //  po1^.ancestor:= fdesigner.copycomponent(amodule,nil);
     fobjectlinker.link(po1^.ancestor);
    end;
   end;
  end;
 finally
  frenewbackuplist:= nil;
 end;
end;

procedure tsubmodulelist.receiveevent(const event: tobjectevent);
begin
 if (event is tasyncevent) and 
                      (tasyncevent(event).tag = renewbackuptag) then begin
  dorenewbackup;
 end;
end;

procedure tsubmodulelist.renewbackup(const amodule: tmsecomponent);
begin
 if frenewbackuplist = nil then begin
  application.postevent(tasyncevent.create(ievent(self),renewbackuptag),true);
 end;
 additem(pointerarty(frenewbackuplist),amodule);
end;

function tsubmodulelist.findoldancestor(
                     const adescendent: tmsecomponent): tmsecomponent;
var
 po1: pancestorinfoty;
begin
 result:= nil;
 po1:= finddescendentinfo(adescendent);
 if po1 <> nil then begin
  result:= po1^.ancestor;
 end;
end;

procedure tsubmodulelist.doitemdestroyed(const sender: tmsecomponent);
var
 int1: integer;
begin
 for int1:= 0 to high(frenewbackuplist) do begin
  if frenewbackuplist[int1] = sender then begin
   frenewbackuplist[int1]:= nil;
  end;
 end;
 inherited;
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
 designer.fsubmoduleinfopo:= nil; //reset for createcomponent
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

type
 tdelcomp = class(tcomponent)
  private
   fdelcomps: componentarty;
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
 end;
 
procedure tdelcomp.notification(acomponent: tcomponent; operation: toperation);
var
 int1: integer;
begin
 inherited;
 if operation = opremove then begin
  for int1:= high(fdelcomps) downto 0 do begin
   if fdelcomps[int1] = acomponent then begin
    fdelcomps[int1]:= nil;
   end;
  end;
 end;
end;

(*
procedure tdescendentinstancelist.revert(const info: pancestorinfoty;
            const module: pmoduleinfoty; out anewinstance: tmsecomponent;
            const norootposition: boolean = false;
            const initflags: boolean = true); 
var
 comp1,comp2: tmsecomponent;
 decomp: tdelcomp;
 parent1: twidget;
 str1: string;
 int1: integer;
 isroot: boolean;
 ancestorclassname1: string;
 actualclassname1: pshortstring;
 pt1: pointty;
 ar1: msecomponentarty;
 ancestorbefore: tmsecomponent;
 infoancestor: tmsecomponent;
 po1: pancestorinfoty;
begin
{$ifdef mse_debugsubmodule}
 debugwriteln('***revert module'+ module^.instance.name+
               ' dest '+info^.descendent.name+' anch '+info^.ancestor.name);
 po1:= datapo;
 for int1:= 0 to count-1 do begin
  debugwriteln('*'+inttostr(int1)+' '+po1^.ancestor.name+' '+
                                           po1^.descendent.name);
  inc(po1);
 end;
{$endif}
 comp1:= info^.descendent;
 infoancestor:= info^.ancestor;
 isroot:= comp1 = module^.instance;
 delete((pchar(info)-pchar(datapo)) div recordsize); //remove item
 ancestorbefore:= nil; //compiler warning
 ar1:= nil;            //compiler warning
 if isroot then begin
  ar1:= getdescendentar(comp1); //restore after revert
  po1:= fdesigner.fsubmodulelist.finddescendentinfo(comp1);
  if po1 <> nil then begin
   ancestorbefore:= po1^.ancestor;
   po1^.ancestor:= nil; //don't free
  end;
 end;
 with tmsecomponent1(comp1) do begin
  ancestorclassname1:= fancestorclassname;
  actualclassname1:= factualclassname;
 end;

// info^.descendent:= nil; //no recursion
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
// fobjectlinker.unlink(comp1);
 fdelcomps:= nil;
 froot:= comp1.owner;
 if ismodule(comp1) then begin 
  froot:= comp1;
 end;
 delcomp(comp1);
 decomp:= tdelcomp.create(nil);
 try
  decomp.fdelcomps:= fdelcomps;
  for int1:= high(fdelcomps) downto 0 do begin
   fdelcomps[int1].freenotification(decomp);
  end;  
  for int1:= high(fdelcomps) downto 0 do begin
   fdelcomps[int1].free;
  end;
 finally
  decomp.free;
 end;
 fdelcomps:= nil;
 comp2:= fdesigner.copycomponent(infoancestor,infoancestor);
 if isroot and initflags then begin
  initrootdescendent(comp2);
 end;

 {
 if not isroot then begin
//  comp2:= fdesigner.copycomponent(info^.ancestor,nil);
  comp2:= fdesigner.copycomponent(info^.ancestor,info^.ancestor);
 end
 else begin
  comp2:= fdesigner.copycomponent(info^.ancestor,info^.ancestor);
  initrootdescendent(comp2);
 end;
 }
// info^.descendent:= comp2;
 comp2.name:= str1;
 with tmsecomponent1(comp2) do begin
  fancestorclassname:= ancestorclassname1;
  factualclassname:= actualclassname1;
 end;
 if not isroot then begin
  initinline(comp2);
 end
 else begin
  tcomponent1(comp2).setancestor(true);
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
// fobjectlinker.link(comp2);
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
  twidget(comp2).parentwidget:= parent1;
 end;
 fmodule:= module;
 addcomp(comp2);
 removefixupreferences(module^.instance,'');
 anewinstance:= comp2;
 add(comp2,infoancestor); //restore entry
// add(comp2,info^.ancestor); //restore entry
 if isroot then begin
  for int1:= 0 to high(ar1) do begin
   add(ar1[int1],comp2);
                     //restore entry;
  end;
  if ancestorbefore = nil then begin
//   fdesigner.fsubmodulelist.add(comp2); //should not happen
  end
  else begin
   fdesigner.fsubmodulelist.add(comp2,ancestorbefore);
  end;
 end;
{$ifdef mse_debugsubmodule}
 debugwriteln('***end revert' );
 po1:= datapo;
 for int1:= 0 to count-1 do begin
  debugwriteln('*'+inttostr(int1)+' '+po1^.ancestor.name+' '+
                                           po1^.descendent.name);
  inc(po1);
 end;
{$endif}
end;         
*)

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
 
begin
 result:= nil;
 addancestors(adescendent);
end;

function tdescendentinstancelist.getancestorsandchildren(
                               const adescendent: tcomponent): componentarty;
var
 po1: pointer;
 int1: integer;
 po2: pmoduleinfoty;
begin
 result:= getancestors(adescendent);
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

{$ifdef mse_nomethodswap}
procedure tdescendentinstancelist.setrefreshmethod(reader: treader;
                        instance: tpersistent;
                        propinfo: ppropinfo; const themethodname: string;
                        var handled: boolean);
var
 m1: tmethod;
 po1: pmethodinfoty;
 int1: integer;
begin
 m1.code:= nil;
 m1.data:= nil;
 for int1:= high(frefreshmethods) downto 0 do begin
  if frefreshmethods[int1] <> nil then begin
   po1:= frefreshmethods[int1].findmethodbyname(themethodname);
   if po1 <> nil then begin
    m1.data:= po1^.address;
    break;
   end;
  end;
 end;
 setmethodprop(instance,propinfo,m1);
 handled:= true;
end;
{$else}
procedure tdescendentinstancelist.findrefreshmethod(reader: treader;
       const amethodname: string; var address: pointer; var error: boolean);
var
// method: tmethod;
 po1: pmethodinfoty;
 int1: integer;
begin
 if error then begin
  for int1:= high(frefreshmethods) downto 0 do begin
   po1:= frefreshmethods[int1].findmethodbyname(amethodname);
//  po1:= fdesigner.floadingmodulepo^.methods.findmethodbyname(amethodname);
   if po1 <> nil then begin
    address:= po1^.address;
    break;
   end;
  end;
  error:= false;
 end;
end;
{$endif}

procedure tdescendentinstancelist.domodulemodified(const amodule: pmoduleinfoty;
                          modifylevel: integer;
                          destcompnames,ancestorcompnames: stringarty;
                          newancestorcomps,oldancestorcomps: msecomponentarty);
  //todo: simplify, optimize
var
 dependentmodules: moduleinfopoarty;
 dependentmod: moduleinfopoarty;
 comp1: tmsecomponent;
 newancestor0: tmsecomponent; 
 oldancestor0: tmsecomponent; 
 descendent1,newancestor1,oldancestor1: tmsecomponent;
 int1,int2,int3,int4: integer;
// str1: string;
 destname: string;
 po1: pancestorinfoty;
 po2: pmoduleinfoty;
 bo1,bo2,bo3,newcomponent: boolean;
 pt1: pointty;
 taborderbefore: integer;
 depmodcomps: array of stringarty;
 dependentcomponents: array of msecomponentarty; 
 newancestorcomponents: array of msecomponentarty; 
 oldancestorcomponents: array of msecomponentarty; 
// sourcemethodtab: pointer;

begin
 if modifylevel >= 16 then begin
  showmessage(actionsmo.c[ord(ac_recursiveforminheritance)]+
                  amodule^.filename+'".',actionsmo.c[ord(ac_error)]);
  sysutils.abort;
 end;
 if modifylevel = 0 then begin
  fdeletedcomps:= nil;
  begingloballoading;
 end;
 inc(modifylevel);
 try
  dependentmodules:= nil; //compilerwarning
  {$ifdef mse_debugsubmodule}
   debugwriteln('***modulemodified '+inttostr(modifylevel)+' '+
                 amodule^.instance.name);
   debugwriteln(' destcompnames: '+debugstringarty(destcompnames));
   debugwriteln(' ancestorcompnames: '+debugstringarty(ancestorcompnames));
   debugwriteln(' newancestorcomps: '+
          debugcomprootnames(componentarty(newancestorcomps)));
   debugwriteln(' oldancestorcomps: '+
          debugcomprootnames(componentarty(oldancestorcomps)));
 //  po1:= datapo;
 //  for int1:= 0 to count-1 do begin
 //   debugwriteln('*'+inttostr(int1)+' '+po1^.ancestor.name+' '+
 //                                            po1^.descendent.name);
 //   inc(po1);
 //  end;
  {$endif}

   newancestor0:= amodule^.instance;
   oldancestor0:= fdesigner.fsubmodulelist.findoldancestor(amodule^.instance); 
   po1:= datapo;
   int2:= 0;
   setlength(dependentmod,fcount); //max
   for int1:= 0 to fcount - 1 do begin
    if po1^.ancestor = amodule^.instance then begin
 //    dependentcomponents[int2]:= po1^.descendent;
     if ismodule(po1^.descendent) then begin  //inherited form        
      comp1:= po1^.descendent;
      destname:= 'OWNER';
     end
     else begin
      comp1:= tmsecomponent(po1^.descendent.owner);
      destname:= po1^.descendent.name;
     end;
     po2:= fdesigner.modules.findmodule(comp1);
     dependentmod[int2]:= po2;
     inc(int2);
    {$ifdef mse_debugsubmodule}
     debugwriteln(' item ancestor: '+po1^.ancestor.name+ ' descendent: '+
              po1^.descendent.name + ' module: '+po2^.instance.name);
    {$endif}               
     int3:= finditem(pointerarty(dependentmodules),po2);
     if int3 < 0 then begin
      int3:= high(dependentmodules)+2;
      setlength(dependentmodules,int3);
      setlength(depmodcomps,int3);
      setlength(dependentcomponents,int3);
      setlength(newancestorcomponents,int3);
      setlength(oldancestorcomponents,int3);
      dec(int3);
      dependentmodules[int3]:= po2;
     end;
     if (destcompnames = nil) then begin
      additem(depmodcomps[int3],destname);
      additem(pointerarty(dependentcomponents[int3]),po1^.descendent);
      additem(pointerarty(newancestorcomponents[int3]),newancestor0);
      additem(pointerarty(oldancestorcomponents[int3]),oldancestor0);
     end
     else begin
      for int4:= 0 to high(destcompnames) do begin
       additem(depmodcomps[int3],destname+'.'+destcompnames[int4]);
       additem(pointerarty(newancestorcomponents[int3]),newancestorcomps[int4]);
       additem(pointerarty(oldancestorcomponents[int3]),oldancestorcomps[int4]);
       additem(pointerarty(dependentcomponents[int3]),po1^.descendent);
      end;
     end;
 //    adduniqueitem(pointerarty(dependentmodules),po2);
    end;
    inc(po1);
   end;
   setlength(dependentmod,int2);
 
   if int2 > 0 then begin
   {$ifdef mse_debugsubmodule}
    debugwriteln('*descendents:');
    for int1:= 0 to high(dependentmodules) do begin
     debugwriteln('module: '+dependentmodules[int1]^.instance.name);
     for int2:= 0 to high(depmodcomps[int1]) do begin
      debugwriteln(' '+depmodcomps[int1][int2]);
     end;
    end;
   {$endif}
    beginsubmodulecopy;
    beginstreaming(amodule);
    if modifylevel = 1 then begin
   {$ifndef mse_nomethodswap}
     streamingswapmethodpointer(amodule^.instance);
   {$endif}
//     frefreshmethods:= fdesigner.getancestormethods(amodule);
   {$ifndef mse_nomethodswap}
     amodule^.methods.createmethodtable(frefreshmethods);
   {$endif}
    end;
    insertitem(pointerarty(frefreshmethods),0,nil);
//    setlength(frefreshmethods,high(frefreshmethods)+3);
//    frefreshmethods[high(frefreshmethods)-1]:= amodule^.methods;
   {$ifndef mse_nomethodswap}
    for int1:= 0 to high(dependentmodules) do begin
     dependentmodules[int1]^.methods.createmethodtable(frefreshmethods);
 //                        fdesigner.getancestormethods(dependentmodules[int1]));
    end;
   {$endif}
    stackarray(pointerarty(dependentmodules),pointerarty(fmodifiedmodules));
    try
//     oldancestor0:= fdesigner.fsubmodulelist.findoldancestor(amodule^.instance);
     for int1:= 0 to high(dependentmodules) do begin
     {$ifndef mse_nomethodswap}
      streamingswapmethodpointer(dependentmodules[int1]^.instance);
     {$endif}
      frefreshmethods[0]:= dependentmodules[int1]^.methods;
      newcomponent:= false;
      for int2:= 0 to high(depmodcomps[int1]) do begin
       descendent1:= dependentcomponents[int1][int2];
       newancestor1:= amodule^.instance;
       oldancestor1:= oldancestor0;
       descendent1:= tmsecomponent(
                  findnestedcomponent(dependentmodules[int1]^.instance,
                                                      depmodcomps[int1][int2]));
       if ancestorcompnames <> nil then begin
        int3:= int2 mod length(ancestorcompnames);
         newancestor1:= newancestorcomps[int3];
         oldancestor1:= oldancestorcomps[int3];
  {$ifdef mse_debugsubmodule}
        debugwriteln('*refreshmain descendent: '+debugcomprootname(descendent1)+
                      ' newancestor: '+debugcomprootname(newancestor1)+
                      ' oldancestor: '+debugcomprootname(oldancestor1));
  {$endif}
        refreshancestor(fdeletedcomps,descendent1,newancestor1,
                                  oldancestor1,false,
         {$ifdef FPC}@{$endif}fdesigner.findancestor,
         {$ifdef FPC}@{$endif}fdesigner.findcomponentclass,
         fdesigner.createcomponent,
        {$ifdef mse_nomethodswap}
         {$ifdef FPC}@{$endif}setrefreshmethod,
         {$ifdef FPC}@{$endif}fdesigner.writedesignmethod,
         @newcomponent
        {$else}
         {$ifdef FPC}@{$endif}findrefreshmethod,
           dependentmod[int1]^.methods.fmethodtable
                                  {amodule^.methods.fmethodtable},
                   dependentmod[int1]^.methods.fmethodtable
        {$endif});
       end
       else begin
        if destcompnames <> nil then begin
         int3:= int2 mod length(destcompnames);
         newancestor1:= newancestorcomps[int3];
         oldancestor1:= oldancestorcomps[int3];        
        end;
        bo3:= (csinline in descendent1.componentstate) and 
                                         (descendent1.owner <> nil); 
                            //whole submodule
        bo1:= false;
        bo2:= false;
        if bo3 then begin   //submodule
         bo1:= descendent1 is twidget;
         if bo1 then begin
          pt1:= twidget(descendent1).pos;
          taborderbefore:= twidget(descendent1).taborder;
         end
         else begin
          bo2:= isdatasubmodule(descendent1);
          if bo2 then begin
           pt1:= getcomponentpos(descendent1);
          end;
         end;
        end;
  {$ifdef mse_debugsubmodule}
        debugwriteln('*refreshcomps descendent: '+debugcomprootname(descendent1)+
                      ' newancestor: '+debugcomprootname(newancestor1)+
                      ' oldancestor: '+debugcomprootname(oldancestor1));
  {$endif}
        refreshancestor(fdeletedcomps,descendent1,newancestor1,
                             oldancestor1,false,
         {$ifdef FPC}@{$endif}fdesigner.findancestor,
         {$ifdef FPC}@{$endif}fdesigner.findcomponentclass,
         fdesigner.createcomponent,
        {$ifdef mse_nomethodswap}
         {$ifdef FPC}@{$endif}setrefreshmethod,
         {$ifdef FPC}@{$endif}fdesigner.writedesignmethod,
         @newcomponent
        {$else}
         {$ifdef FPC}@{$endif}findrefreshmethod,
           amodule^.methods.fmethodtable,
           dependentmod[int1]^.methods.fmethodtable
        {$endif});
        if bo2 then begin
        end;
        if bo1 then begin
         twidget(descendent1).pos:= pt1;  //restore insert position
         twidget(descendent1).taborder:= taborderbefore;
        end
        else begin
         if bo2 then begin
          setcomponentpos(descendent1,pt1); //restore insert position
         end;
        end;
       end;
      end;
      if newcomponent then begin
       with dependentmodules[int1]^ do begin
        components.assigncomps(instance)
       end;
      end;
     end;
     for int1:= 0 to high(dependentmodules) do begin
      domodulemodified(dependentmodules[int1],modifylevel,
                  depmodcomps[int1],destcompnames,
                  newancestorcomponents[int1],oldancestorcomponents[int1]);
     end;
    finally
     if frefreshmethods <> nil then begin
      setlength(frefreshmethods,high(frefreshmethods));
     end;
     fdesigner.fsubmodulelist.renewbackup(amodule^.instance);
    {$ifndef mse_nomethodswap}
     amodule^.methods.releasemethodtable;
    {$endif}
     endsubmodulecopy;
     endstreaming;
    end;
   end
   else begin
    fdesigner.fsubmodulelist.renewbackup(amodule^.instance);
   end;
  {$ifdef mse_debugsubmodule}
   debugwriteln('***end modulemodified '+inttostr(modifylevel)+' '+
                 amodule^.instance.name);
  {$endif}
  if modifylevel = 1 then begin
   notifygloballoading;
   if fdeletedcomps <> nil then begin
    freecomponents(fdeletedcomps);
    fdeletedcomps:= nil;
    modulemodified(amodule); //refresh again
   end;
  end;
 finally
  if modifylevel = 1 then begin
   endgloballoading;
  end;
 end;
end;

procedure tdescendentinstancelist.modulemodified(const amodule: pmoduleinfoty);
var
 int1: integer;
begin
 if not fmodulemodifying then begin
  fmodulemodifying:= true;
  fmodifiedmodules:= nil;
  try
   domodulemodified(amodule,0,nil,nil,nil,nil);
  finally
   try
   {$ifndef mse_nomethodswap}
    for int1:= 0 to high(fmodifiedmodules) do begin
     fmodifiedmodules[int1]^.methods.releasemethodtable;
    end;
   {$endif}
    for int1:= 0 to high(fmodifiedmodules) do begin
     fdesigner.modulechanged(fmodifiedmodules[int1]);
    end;
   finally
    fmodulemodifying:= false;
   end;
  end;
 end;
end;

procedure tdescendentinstancelist.componentnamechanged(
                   const amodule: pmoduleinfoty;
                   const acomponent: tcomponent; const newname: string);
var
 reclevel: integer;
 namepath: string;
 newpath: string;
 
 procedure donamechange(aancestor: pmoduleinfoty);
 var
  int1: integer;
  po1: pancestorinfoty;
  comp1: tcomponent;
 begin
  if aancestor <> nil then begin
   if reclevel >= 16 then begin
    showmessage(actionsmo.c[ord(ac_recursiveforminheritance)]+
                       amodule^.filename+'".',actionsmo.c[ord(ac_error)]);
    sysutils.abort;
   end;
   inc(reclevel);
   po1:= datapo;
   for int1:= 0 to count-1 do begin
    if po1^.ancestor = aancestor^.instance then begin
     comp1:= findnestedcomponent(po1^.descendent,namepath);
     if comp1 <> nil then begin
      comp1.name:= newname;
     end;
     donamechange(fdesigner.modules.findmodule(po1^.descendent));
    end;
    inc(po1);
   end;
   dec(reclevel);
  end;
 end;
 
 procedure docheckname(aancestor: pmoduleinfoty);
 var
  int1: integer;
  po1: pancestorinfoty;
  comp1: tcomponent;
 begin
  if aancestor <> nil then begin
   if reclevel >= 16 then begin
    showmessage(actionsmo.c[ord(ac_recursiveforminheritance)]+
                 amodule^.filename+'".',actionsmo.c[ord(ac_error)]);
    sysutils.abort;
   end;
   inc(reclevel);
   po1:= datapo;
   for int1:= 0 to count-1 do begin
    if po1^.ancestor = aancestor^.instance then begin
     comp1:= findnestedcomponent(po1^.descendent,newpath);
     if comp1 <> nil then begin
      raise exception.create(po1^.descendent.name+': '+
             actionsmo.c[ord(ac_component)]+
             newpath+actionsmo.c[ord(ac_exists)]);
     end;
     donamechange(fdesigner.modules.findmodule(po1^.descendent));
    end;
    inc(po1);
   end;
   dec(reclevel);
  end;
 end;

var
 ar1: componentarty; 
 int1: integer;
begin
 if not fcomponentnamechanging then begin
  fcomponentnamechanging:= true;
  try
   ar1:= ownercomponentpath(acomponent);
   if high(ar1) > 0 then begin
    namepath:= ar1[1].name;
    for int1:= 2 to high(ar1) do begin
     namepath:= namepath+'.'+ar1[int1].name;
    end;
    if high(ar1) > 1 then begin
     newpath:= ar1[1].name;
     for int1:= 2 to high(ar1)-1 do begin
      namepath:= namepath+'.'+ar1[int1].name;
     end;
     newpath:= newpath+'.'+newname;
    end
    else begin
     newpath:= newname;
    end;
    reclevel:= 0;
    docheckname(amodule);
    reclevel:= 0;
    donamechange(amodule);
   end;
  finally
   fcomponentnamechanging:= false;
  end;
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

procedure tdescendentinstancelist.beginstreaming(const amodule: pmoduleinfoty);
begin
 inherited beginstreaming;
 if amodule <> nil then begin
  frefreshmethods:= fdesigner.getancestormethods(amodule);
 end;
end;

{ tmethods }

constructor tmethods.create(adesigner: tdesigner);
begin
 fdesigner:= adesigner;
 inherited create(sizeof(methodinfoty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

destructor tmethods.destroy;
begin
{$ifndef mse_nomethodswap}
 releasemethodtable;
{$endif}
 inherited;
end;

procedure tmethods.addmethod(const aname: string; const aaddress: pointer;
                             const atypeinfo: ptypeinfo);
var
 po1: pmethodinfoty;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 po1:= add(ptruint(aaddress));
 {$ifdef FPC} {$checkpointer default} {$endif}
 with po1^ do begin
  name:= aname;
  address:= aaddress;
  typeinfo:= atypeinfo;
 end;
 fdesigner.fmodules.fmethodnames.add(ptruint(aaddress),aname);
end;

procedure tmethods.deletemethod(const aadress: pointer);
begin
// inherited delete(aadress); do nothing
end;

{$ifndef mse_nomethodswap}
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

function tmethods.createmethodtable(const ancestors: methodsarty): pointer;
var
 int1,int2,int3: integer;
 po1: pmethodinfoty;
 po2: pmethodtableentryty;
 po3: pchar;
 count1: integer;
 ar1: methodsarty;
begin
 releasemethodtable;
 ar1:= copy(ancestors);
 additem(pointerarty(ar1),self);
 count1:= 0;
 for int1:= 0 to high(ar1) do begin
  inc(count1,ar1[int1].count);
 end;
 if count1 > 0 then begin
  int2:= count1; //lenbyte
  for int3:= 0 to high(ar1) do begin
   with ar1[int3] do begin
    for int1:= 0 to count -1 do begin
     int2:= int2 + length(pmethodsdataty(next)^.data.name);    //stringsize
    end;
   end;
  end;
  int1:= sizeof(dword) + count1 * sizeof(tmethodnamerec); //tablesize
  getmem(fmethodtable,int1+int2);
  pdword(fmethodtable)^:= count1;
  po2:= pmethodtableentryty(pchar(fmethodtable) + sizeof(dword));
  po3:= pchar(fmethodtable) + int1;   //stringtable
  for int3:= 0 to high(ar1) do begin
   with ar1[int3] do begin
    for int1:= 0 to count - 1 do begin
     po1:= @pmethodsdataty(next)^.data;
     int2:= length(po1^.name);
     po2^.name:= pshortstring(po3);
     po3^:= char(int2); //namelen
     inc(po3);
     move(pointer(po1^.name)^,po3^,int2);
     inc(po3,int2);
     po2^.addr:= po1^.address;
     inc(po2);
    end;
   end;
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

function tmethods.createmethodtable(const ancestors: methodsarty): pointer;
var
 int1,int2,int3: integer;
 po1: pmethodinfoty;
 po2: pmethodtableentryty;
 count1: integer;
 ar1: methodsarty;

begin
 releasemethodtable;
 ar1:= copy(ancestors);
 additem(pointerarty(ar1),self);
 count1:= 0;
 for int1:= 0 to high(ar1) do begin
  inc(count1,ar1[int1].count);
 end;
 if count1 > 0 then begin
  int2:= sizeof(word); //numentries
  for int3:= 0 to high(ar1) do begin
   with ar1[int3] do begin
    for int1:= 0 to count -1 do begin
     int2:= int2 + length(pmethodsdataty(next)^.data.name);
    end;
   end;
  end;
  getmem(fmethodtable,int2 + count1 * sizeof(methodtableentryfixty));
  pword(fmethodtable)^:= count1;
  po2:= pmethodtableentryty(pchar(fmethodtable) + sizeof(word));
  for int3:= 0 to high(ar1) do begin
   with ar1[int3] do begin
    for int1:= 0 to count - 1 do begin
     po1:= pmethodinfoty(next);
//     po1:= @pmethodstataty(next).data; ????
     int2:= length(po1^.name);
     po2^.len:= sizeof(methodtableentryfixty) + int2;
     po2^.adr:= po1^.address;
     po2^.name[0]:= char(int2);
     move(po1^.name[1],po2^.name[1],int2);
     inc(pchar(po2),po2^.len);
    end;
   end;
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
{$endif mse_nomethodswap}

function tmethods.findmethod(const aadress: pointer): pmethodinfoty;
begin
 result:= pmethodinfoty(find(ptruint(aadress)));
end;

function tmethods.findmethodbyname(const aname: string;
                const atype: ptypeinfo; out namefound: boolean): pmethodinfoty;
var
 int1: integer;
 po1: pmethodsdataty;
 str1: string;
begin
 str1:= uppercase(aname);
 result:= nil;
 namefound:= false;
 for int1:= 0 to count - 1 do begin
  po1:= pmethodsdataty(next);
  if uppercase(po1^.data.name) = str1 then begin
   namefound:= true;
   if (po1^.data.typeinfo = atype) then begin
    result:= @po1^.data;
    break;
   end;
  end;
 end;
end;

function tmethods.findmethodbyname(const aname: string): pmethodinfoty;
var
 int1: integer;
 po1: pmethodsdataty;
 str1: string;
begin
 str1:= uppercase(aname);
 result:= nil;
 for int1:= 0 to count - 1 do begin
  po1:= pmethodsdataty(next);
  if uppercase(po1^.data.name) = str1 then begin
   result:= @po1^.data;
   break;
  end;
 end;
end;

procedure tmethods.finalizeitem(var aitemdata);
begin
 if fdesigner.fmodules.fmethodnames <> nil then begin
  fdesigner.fmodules.fmethodnames.delete(
         ptruint(methodsdataty(aitemdata).data.address));
 end;
 finalize(methodsdataty(aitemdata)); 
end;

{ tcomponents }

constructor tcomponents.create(const aowner: pmoduleinfoty;
                                        const adesigner: tdesigner);
begin
 fowner:= aowner;
 fdesigner:= adesigner;
 fcomponent:= tcomponentslink.Create(nil);
 fcomponent.fowner:= self;
 inherited create(sizeof(componentinfoty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

destructor tcomponents.destroy;
begin
 fcomponent.Free;
 inherited;
end;

procedure tcomponents.destroynotification(const acomponent: tcomponent);
begin
 fdesigner.componentdestroyed(acomponent,fowner);
 delete(ptruint(acomponent),true);
end;

procedure tcomponents.finalizeitem(var aitemdata);
begin
 finalize(componentsdataty(aitemdata));
end;

(*
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
*)
procedure tcomponents.assigncomps(const module: tmsecomponent);
 procedure addcomp(acomp: tcomponent);
 var
  ar1: componentarty;
  int1: integer;
 begin
  if not(acomp is twidget) or 
          (ws_iswidget in twidget1(acomp).fwidgetstate) then begin
   add(acomp);
  end;
  ar1:= getcomponentchildren(acomp,module,true);
  for int1:= 0 to high(ar1) do begin
   addcomp(ar1[int1]);
  end;
 end;
 
begin
 clear;
 if module <> nil then begin
  addcomp(module);
//  famodule:= module;
//  doadd(module);
 end;
end;

procedure tcomponents.add(comp: tcomponent);
var
 po1: pcomponentinfoty;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 po1:= inherited add(ptruint(comp));
 {$ifdef FPC} {$checkpointer default} {$endif}
 with po1^ do begin
  instance:= comp;
  name:= comp.Name;
 end;
 comp.freenotification(fcomponent);
end;

function tcomponents.find(const value: tobject): pcomponentinfoty;
begin
 result:= pcomponentinfoty(inherited find(ptruint(value)));
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
 setlength(result,count);
 for int1:= 0 to count - 1 do begin
  result[int1]:= pcomponentsdataty(next)^.data.instance;
 end;
end;

function tcomponents.next: pcomponentinfoty;
begin
 result:= @pcomponentsdataty(inherited next)^.data;
end;

function tcomponents.getcomponent(const aname: string): tcomponent;
var
 int1,int2: integer;
 po1: pcomponentinfoty;
 str1: string;
 ar1: stringarty;
begin
 result:= nil;
 str1:= uppercase(aname);
 if aname <> '' then begin
  ar1:= splitstring(str1,subcomponentsplitchar);
  for int1:= 0 to count - 1 do begin
   po1:= next;
   if uppercase(po1^.name) = ar1[0] then begin
    result:= po1^.instance;
    for int2:= 1 to high(ar1) do begin
     result:= result.findcomponent(ar1[int2]);
     if (result = nil) then begin
      break;
     end;
     if isnosubcomp(result) then begin
//     if not(cssubcomponent in result.componentstyle) then begin
      result:= nil;
      break;
     end;
    end;
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
 for int1:= 0 to count - 1 do begin
  with result[int1] do begin
   instance:= next^.instance;
   dispname:= fdesigner.getcomponentdispname(instance);
  end;
 end;
 sortarray(result,sizeof(componentnamety),
                                 {$ifdef FPC}@{$endif}comparecomponentname);
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
 removeitem(pointerarty(fdesigner.fcheckfixups),@info);
 with info do begin
  freeandnil(loadingstream);
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
 fmethodnames:= tmethodnames.create;
end;

procedure tmodulelist.designformdestroyed(const sender: tmseform);
var
 po1: pmoduleinfoty;
begin
 if not destroying then begin
  po1:= findform(sender);
  if po1 <> nil then begin
   po1^.designform:= nil;
   removemoduleinfo(po1);
 //  fdesigner.moduledestroyed(po1);
  end;
 end;
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

function tmodulelist.findownermodule(const acomponent: tcomponent): pmoduleinfoty;
begin
 result:= findmodulebyinstance(rootcomponent(acomponent));
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
 inheritedbefore: boolean;
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
     raise exception.create(actionsmo.c[ord(ac_ancestorfor)]+
           designmoduleclassname+actionsmo.c[ord(ac_notfound)]);
    end;
    fdesigner.beginstreaming(po1);
    try
     inheritedbefore:= des_inheritednewmodule in fdesigner.fstate;
     include(fdesigner.fstate,des_inheritednewmodule);
     instance:= fdesigner.copycomponent(po1^.instance,po1^.instance,false,true);
    finally
     if not inheritedbefore then begin
      exclude(fdesigner.fstate,des_inheritednewmodule);
     end;
     fdesigner.endstreaming(po1);
    end;
    moduleintf:= po1^.moduleintf;
    designformclass:= po1^.designformclass;
{$warnings off}
    tcomponent1(instance).setancestor(true);
{$warnings on}
    additem(pointerarty(fdesigner.floadedsubmodules),instance);
    fdesigner.fdescendentinstancelist.add(tmsecomponent(instance),po1^.instance,
                                          fdesigner.fsubmodulelist);
    tmsecomponent1(instance).factualclassname:= @moduleclassname;
    tmsecomponent1(instance).fancestorclassname:= designmoduleclassname;
//    initrootdescendent(instance);
    tmsecomponent1(instance).setancestor(true);
   end
   else begin
    instance:= createdesignmodule(@result.info,designmoduleclassname,@moduleclassname);
   end;
{$warnings off}
   tcomponent1(instance).setdesigning(true{$ifndef FPC},true{$endif});
{$warnings on}
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

procedure tmodulelist.freeloadingstreams;
var
 int1: integer;
 po1: ppointeraty;
begin
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  freeandnil(tmoduleinfo(
              iobjectlink(po1^[int1]).getinstance).info.loadingstream);
 end;
end;

procedure tmodulelist.componentmodified(const acomponent: tobject);
var
 int1: integer;
 po1: ppointeraty;
 comp: tcomponent;

begin
 if acomponent is tcomponent then begin
  comp:= rootcomponent(tcomponent(acomponent));
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
 end;
end;

function tmodulelist.findmodulebycomponent(const acomponent: tcomponent): pmoduleinfoty;
var
 int1: integer;
 po1: ppointeraty;
 po2: pmoduleinfoty;
// comp1: tcomponent;
begin
 result:= nil;
 po1:= datapo;
// comp1:= acomponent;
// while comp1 <> nil do begin
  for int1:= 0 to fcount-1 do begin
   po2:= @tmoduleinfo(iobjectlink(po1^[int1]).getinstance).info;
   if po2^.components.find(acomponent) <> nil then begin
    result:= po2;
    break;
   end;
  end;
//  if result <> nil then begin
//   break;
//  end;
//  if cssubcomponent in comp1.componentstyle then begin
//   comp1:= comp1.owner;
//  end
//  else begin
//   comp1:= nil;
//  end; 
// end;
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

destructor tmodulelist.destroy;
begin
 freeandnil(fmethodnames);
 inherited;
end;

{ tdesignformlist }

function tdesignformlist.getitems(const index: integer): tmseform;//tformdesignerfo;
begin
 result:= tmseform(inherited getitems(index));
end;

type
 tselectiondestroytracker = class(tcomponent)
  private
   fselections: tdesignerselections;
  protected
   procedure notification(acomponent: tcomponent;
                                 operation: toperation); override;
  public
   constructor create(const aselections: tdesignerselections); reintroduce;
 end;

{ tselectiondestroytracker }

constructor tselectiondestroytracker.create(
                                   const aselections: tdesignerselections);
var
 int1: integer;
begin
 fselections:= aselections;
 with fselections do begin
  for int1:= 0 to count - 1 do begin
   items[int1].freenotification(self);
  end;
 end;
 inherited create(nil);
end;

procedure tselectiondestroytracker.notification(acomponent: tcomponent;
                                                        operation: toperation);
var
 po1: pcomponentaty;
 int1: integer;
begin
 if operation = opremove then begin
  po1:= fselections.datapo;
  for int1:= 0 to fselections.count-1 do begin
   if po1^[int1] = acomponent then begin
    po1^[int1]:= nil;
   end;
  end;
 end;
 inherited;
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
 ondesignvalidaterename:= {$ifdef FPC}@{$endif}validaterename;
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

procedure tdesigner.addcomponent(const module: tmsecomponent; 
                           const acomponent: tcomponent);
var
 int1,int2: integer;
 str1: string;
 bo1: boolean;
 classna: string;
 ar1: componentarty;
 
begin
 if (des_pasting in fstate) and (acomponent.name <> '') then begin
  addpastedcomponentname(acomponent);
 end;
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
///////////  componentmodified(acomponent);
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
 destroytracker: tselectiondestroytracker;

begin
 destroytracker:= tselectiondestroytracker.create(self.fselections);
 try
  for int1:= 0 to fselections.count - 1 do begin
   comp1:= fselections[int1];
   if comp1 <> nil then begin
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
  end;
  fselections.clear;
  selectionchanged;
 finally
  destroytracker.free;
 end;
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
var
 po1: pmoduleinfoty;
 notifymodulebefore: tmsecomponent;
begin
 if acomponent <> nil then begin
  fmodules.componentmodified(acomponent);
  po1:= fmodules.findmodulebycomponent(acomponent);
  if po1 <> nil then begin
   notifymodulebefore:= fnotifymodule;
   fnotifymodule:= po1^.instance;
   try
    notifydeleted(acomponent);
//  designnotifications.ItemDeleted(idesigner(self),
//            fmodules.findmodulebycomponent(acomponent)^.instance,acomponent);
   finally
    fnotifymodule:= notifymodulebefore;
   end;
  end;
  acomponent.free;
 end;
end;

{$ifdef mse_nomethodswap}
procedure tdesigner.setmethodproperty(reader: treader;
                        instance: tpersistent;
                        propinfo: ppropinfo; const themethodname: string;
                        var handled: boolean);
var
 m1: tmethod;
 po1: pmethodinfoty;
begin
 po1:= floadingmodulepo^.methods.findmethodbyname(themethodname);
 if po1 = nil then begin
  m1:= createmethod(themethodname,nil,nil);
 end
 else begin
  m1.data:= po1^.address;
  m1.code:= nil;
 end;
 setmethodprop(instance,propinfo,m1);
 handled:= true;
end;
{$else}
procedure tdesigner.findmethod(reader: treader; const amethodname: string;
  var address: pointer; var error: boolean);
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
{$endif}
{
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
}
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
 ffindcompclasstag:= fcreatecomponenttag+1;
 if componentclass = nil then begin
  po1:= getinheritedmodule(aclassname);
  if po1 <> nil then begin
   fsubmoduleinfopo:= po1;  //used in createcomponent
   ffindcompclasstag:= fcreatecomponenttag+1;
   componentclass:= tcomponentclass(po1^.instance.classtype);
  end;
 end;
end;

procedure tdesigner.ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
begin
 fsubmoduleinfopo:= nil; //reset for createcomponent
 component:= fmodules.findmoduleinstancebyclass(componentclass);
 if component = nil then begin
  component:= mseclasses.findancestorcomponent(reader,componentname);
 end;
end;

function tdesigner.findancestorcomponent(const acomponent: tcomponent): tcomponent;
var
// ancestormodule: tmsecomponent;
 comp1: tcomponent;
 ar1: stringarty;
 int1: integer;
begin
 result:= nil;
 if acomponent.owner = nil then begin //module
  result:= descendentinstancelist.findancestor(acomponent);
 end
 else begin //embedded component
  ar1:= nil;
  result:= nil;
  comp1:= acomponent;
  while (comp1.owner <> nil) and 
        (comp1.componentstate * [csinline,csancestor] <> [csinline]) do begin
   if comp1.name = '' then begin
    exit;
   end;
   additem(ar1,comp1.name);
   comp1:= comp1.owner;
  end;
  if (comp1.owner <> nil) and 
                     (csancestor in comp1.owner.componentstate) then begin
     //inherited submodule
   additem(ar1,comp1.name);
   comp1:= comp1.owner;
  end;
  result:= descendentinstancelist.findancestor(comp1);
  for int1:= high(ar1) downto 0 do begin
   if result = nil then begin 
    exit;
   end;
   result:= result.findcomponent(ar1[int1]);
  end;
 end;
end;

procedure tdesigner.createcomponent1(Reader: TReader;
                   ComponentClass: TComponentClass; var Component: TComponent);
var
 asubmoduleinfopo: pmoduleinfoty;
 int1: integer;
begin
 inc(fcreatecomponenttag);
 if fcreatecomponenttag <> ffindcompclasstag then begin
  fsubmoduleinfopo:= nil; //invalid
 end;
 asubmoduleinfopo:= fsubmoduleinfopo;    //can be recursive
 if asubmoduleinfopo <> nil then begin
  fsubmoduleinfopo:= nil;
  component:= copycomponent(asubmoduleinfopo^.instance,
                                   asubmoduleinfopo^.instance,false,false);
  reader.root.insertcomponent(component);
  initinline(component);
  if (des_inheritednewmodule in fstate) then begin
   tcomponent1(component).setancestor(true);
  end
  else begin
   for int1:= 0 to component.componentcount - 1 do begin
    tcomponent1(component.components[int1]).setancestor(true);
   end;
  end;
  if (submodulecopy = 0) and
        (reader.root.componentstate * [csinline{,csancestor}] = [])  then begin
   additem(pointerarty(floadedsubmodules),component);
   fdescendentinstancelist.add(tmsecomponent(component),
                                   asubmoduleinfopo^.instance,fsubmodulelist);
  end;
 end;
 if reader is tasinheritedreader then begin
  tasinheritedreader(reader).newcomp:= true;
 end;
end;

function tdesigner.createcomponent: tcreatecomponentevent;
begin
 fsubmoduleinfopo:= nil; //reset
 result:= @createcomponent1;
end;

{$ifndef mse_nomethodswap}
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
{$endif}
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
{
procedure tdesigner.forallmethprop(child: tcomponent);
begin
 with fforallmethpropsinfo do begin
  forallmethodproperties(child,dat,proc,dochi);  
 end; 
end;
}

procedure tdesigner.forallmethodproperties(const aroot: tcomponent;
                     const ainstance: tobject;
                     const data: pointer; const aproc: propprocty;
                     const dochildren: boolean);
var
 ar1: propinfopoarty;
 ar2: componentarty;
 int1,int2: integer;
 obj1: tobject;
 bo1{,bo2}: boolean;
// rootbefore: tcomponent;
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
    if issubprop(obj1) then begin
     forallmethodproperties(aroot,obj1,data,aproc,dochildren);
     if obj1 is tpersistentarrayprop then begin
      with tpersistentarrayprop(obj1) do begin
       for int2:= 0 to count - 1 do begin
        forallmethodproperties(aroot,items[int2],data,aproc,dochildren);
       end;
      end;
     end
     else begin
      if obj1 is tcollection then begin
       with tcollection(obj1) do begin
        for int2:= 0 to count - 1 do begin
         forallmethodproperties(aroot,items[int2],data,aproc,dochildren);
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 if (ainstance is tcomponent) then begin
  ar2:= getcomponentchildren(tcomponent(ainstance),aroot,true);
  for int1:= 0 to high(ar2) do begin
   forallmethodproperties(aroot,ar2[int1],data,aproc,dochildren);
  end;
 end;
 if bo1 then begin
  setloading(tcomponent(ainstance),false);
 end;
end;

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

procedure tdesigner.modulesizechanged(const amodule: tmsecomponent);
var
 po1: pmoduleinfoty;
begin
 po1:= fmodules.findmodule(tmsecomponent(amodule));
 if po1 <> nil then begin
{$warnings off}
  twidget1(po1^.designform).sizechanged;
{$warnings on}
 end;
end;

function tdesigner.checkmodule(const filename: msestring): pmoduleinfoty;
begin
 result:= fmodules.findmodule(filename);
 if result = nil then begin
  raise exception.Create(actionsmo.c[ord(ac_module)]+
                          filename+actionsmo.c[ord(ac_notfound)]);
 end;
end;

procedure tdesigner.beginstreaming(const amodule: pmoduleinfoty);
begin
 with amodule^ do begin
  if designform <> nil then begin
   tformdesignerfo(designform).beginstreaming;
  end;
 end;
end;

procedure tdesigner.endstreaming(const amodule: pmoduleinfoty);
begin
 with amodule^ do begin
  if designform <> nil then begin
   tformdesignerfo(designform).endstreaming;
  end;
 end;
end;

procedure tdesigner.modulechanged(const amodule: pmoduleinfoty);
begin
 componentmodified(amodule^.instance);
end;

function tdesigner.changemodulename(const filename: msestring; 
                                                  const avalue: string): string;
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
  raise exception.Create(actionsmo.c[ord(ac_invalidname)]+aname+'".');
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
 if fformloadlocklevel = 0 then begin
  fallsaved:= false;
  if component <> nil then begin
   fmodules.componentmodified(component);
  end;
  if fcomponentmodifying = 0 then begin
   postcomponentevent(
          tcomponentevent.create(component,ord(me_componentmodified),false));
  end
 end;
end;

procedure tdesigner.begincomponentmodify;
begin
 inc(fcomponentmodifying);
end;

procedure tdesigner.endcomponentmodify;
begin
 dec(fcomponentmodifying);
end;

procedure tdesigner.beginpasting;
begin
 include(fstate,des_pasting);
end;

procedure tdesigner.endpasting;
begin
 exclude(fstate,des_pasting);
end;

function tdesigner.copycomponent(const source: tmsecomponent;
        const root: tmsecomponent; const asinherited: boolean;
        const noloading: boolean): tmsecomponent;
var
 po1,po2: pmoduleinfoty;
 ar1: msecomponentarty;
 comp1: tmsecomponent;
 int1: integer;
 stream1: tmemorystream;
 stream2: tstream;
 reader: treader;
 writer: twritermse;
 posbefore: integer;
begin
 {$ifdef mse_debugcopycomponent}
 dumpcomponent(source,'***designer copycomponent source: '+source.name+' root: '+
             debugcompname(root));
 {$endif}
 comp1:= source;
 setlength(ar1,1);
 ar1[0]:= source;
 while true do begin
  comp1:= fdescendentinstancelist.findancestor(comp1);
  if comp1 = nil then begin
   break;
  end;
  additem(pointerarty(ar1),comp1);
 end;
 setlength(ar1,high(ar1)+2); //dummy ancestor
 beginsubmodulecopy;
 if root <> nil then begin
  po1:= fmodules.findmodule(root);
  if po1 <> nil then begin
   beginstreaming(po1);
  {$ifndef mse_nomethodswap}
   buildmethodtable(po1);
  {$endif}
  end;
 end
 else begin
  po1:= nil;
 end;
 fdescendentinstancelist.beginstreaming(po1);
// doswapmethodpointers(source,false);
{$ifndef mse_nomethodswap}
 for int1:= 0 to high(ar1)-1 do begin
  doswapmethodpointers(ar1[int1],false);
 end;
{$endif}  
 try
  if not noloading then begin
   begingloballoading;
  end;
  result:= tmsecomponent(source.newinstance);
{$warnings off}
  tcomponent1(result).setdesigning(true);
{$warnings on}
  result.create(nil);
  stream1:= tmemorystream.create;
  try
   for int1:= high(ar1)-1 downto 0 do begin
    stream2:= nil;
    if high(ar1) < 2 then begin //has no ancestors, loading stream can be used ????
     po2:= fmodules.findmodule(root);
     if po2 <> nil then begin
      stream2:= po2^.loadingstream; //needs possibly fixup
     end;
    end;
    if stream2 = nil then begin
     stream2:= stream1;
     stream1.clear;
     writer:= twritermse.create(stream1,4096,false);
     try
     {$ifdef mse_nomethodswap}
      writer.onwritemethodproperty:= {$ifdef FPC}@{$endif}writedesignmethod;
     {$endif}
      writer.onfindancestor:= {$ifdef FPC}@{$endif}findancestor;
      writer.writedescendent(ar1[int1],ar1[int1+1]);
      result.name:= ar1[int1].name;
     finally
      writer.free;
     end;
    end;
   {$ifdef mse_debugcopycomponent}
    debugstreamout(stream1,'*source '+inttostr(int1)+ ': '+
                  debugcompname(ar1[int1])+
                  ' ancestor: '+debugcompname(ar1[int1+1]));
   {$endif}
    posbefore:= stream2.position;
    stream2.position:= 0;
    if asinherited then begin
     reader:= tasinheritedreader.create(stream2,4096,true);
    end
    else begin
     reader:= treader.create(stream2,4096);
    end;
    try
    {$ifdef mse_nomethodswap}
     reader.onsetmethodproperty:= 
        {$ifdef FPC}@{$endif}fdescendentinstancelist.setrefreshmethod;
    {$endif}
     reader.onfindcomponentclass:= {$ifdef FPC}@{$endif}findcomponentclass;
     reader.oncreatecomponent:= createcomponent;
     reader.onancestornotfound:= {$ifdef FPC}@{$endif}ancestornotfound;
   {$ifdef mse_debugcopycomponent}
     debugwriteln('*read '+inttostr(int1)+' '+
            debugcompname(ar1[int1])+' ancestor: '+debugcompname(ar1[int1+1]));
   {$endif}
     reader.readrootcomponent(result);
    finally
     reader.free;
     stream2.position:= posbefore;
    end;
   end;
  finally
   stream1.free;
  end;
  tmsecomponent1(result).factualclassname:= 
                               tmsecomponent1(source).factualclassname;
  (*
  result:= tmsecomponent(mseclasses.copycomponent(source,nil,
            {$ifdef FPC}@{$endif}findancestor,
            {$ifdef FPC}@{$endif}findcomponentclass,
            {$ifdef FPC}@{$endif}createcomponent,
            {$ifdef FPC}@{$endif}ancestornotfound));
   *)
{$ifndef mse_nomethodswap}
  if po1 = nil then begin
   docopymethods(source,result,false);
  end;
  doswapmethodpointers(result,true);
{$endif}
  if not noloading then begin
   notifygloballoading;
  end;
 finally
  if not noloading then begin
   endgloballoading;
  end;
//  doswapmethodpointers(source,true);
{$ifndef mse_nomethodswap}
  for int1:= 0 to high(ar1)-1 do begin
   doswapmethodpointers(ar1[int1],true);
  end;
{$endif}
  fdescendentinstancelist.endstreaming;
  endsubmodulecopy;
  if po1 <> nil then begin
   endstreaming(po1);
  {$ifndef mse_nomethodswap}
   releasemethodtable(po1);
  {$endif}
  end;
 end;
 {$ifdef mse_debugcopycomponent}
 dumpcomponent(result,'*endcopycomp source: '+source.name+' result:');
 {$endif}
end;

procedure tdesigner.revert(const acomponent: tcomponent);
var
 comp1: tcomponent;
// msecomp1: tmsecomponent;
// po1: pancestorinfoty;
 po2: pmoduleinfoty;
 po4: pmoduleinfoty;
{$ifndef mse_nomethodswap}
 po3: pointer;
{$endif}
 bo1,bo2,bo3: boolean;
 pt1: pointty;
 delcomps: componentarty;
begin
 po2:= fmodules.findmodule(tmsecomponent(rootcomponent(acomponent)));
 bo3:= (csinline in acomponent.componentstate) and
         (acomponent.owner <> nil) and
          not (csancestor in acomponent.owner.componentstate); //submodule
 if bo3 or (csancestor in acomponent.componentstate) then begin
  comp1:= findancestorcomponent(acomponent);
  if comp1 <> nil then begin
   beginsubmodulecopy;
   begingloballoading;
   po4:= fmodules.findownermodule(comp1);
{$ifndef mse_nomethodswap}
   po3:= po4^.methods.createmethodtable(getancestormethods(po4));
{$endif}
   fdescendentinstancelist.beginstreaming(po4);
{$ifndef mse_nomethodswap}
   doswapmethodpointers(acomponent,false);
   doswapmethodpointers(comp1,false);
{$endif}
   try
    bo1:= false;
    bo2:= false;
    if bo3 then begin   //submodule
     bo1:= acomponent is twidget;
     if bo1 then begin
      pt1:= twidget(acomponent).pos;
     end
     else begin
      bo2:= isdatasubmodule(acomponent);
      if bo2 then begin
       pt1:= getcomponentpos(acomponent);
      end;
     end;
    end;
    refreshancestor(delcomps,acomponent,comp1,comp1,true,
     {$ifdef FPC}@{$endif}findancestor,
     {$ifdef FPC}@{$endif}findcomponentclass,
     createcomponent,
    {$ifdef mse_nomethodswap}
     {$ifdef FPC}@{$endif}fdescendentinstancelist.setrefreshmethod,
     {$ifdef FPC}@{$endif}writedesignmethod
    {$else}
     nil,po3,po3
    {$endif}
     );
//     docopymethods(comp1,acomponent,true);
    if bo1 then begin
     twidget(acomponent).pos:= pt1;  //restore insert position
    end
    else begin
     if bo2 then begin
      setcomponentpos(acomponent,pt1); //restore insert position
     end;
    end;
    notifygloballoading;
   finally
    endsubmodulecopy;
    endgloballoading;
   {$ifndef mse_nomethodswap}
    po4^.methods.releasemethodtable;
    doswapmethodpointers(acomponent,true);
    doswapmethodpointers(comp1,true);
   {$endif}
    fdescendentinstancelist.endstreaming;
   end;
  end;
 end;
 freecomponents(delcomps);
 componentmodified(po2^.instance);
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
var
 str1: string;
 comp1: tcomponent;
begin
 if (csinline in component.ComponentState) then begin
  if (ancestor = nil) then begin
   ancestor:= fdescendentinstancelist.findancestor(component);
   rootancestor:= ancestor;
  end;
 end;
 if csancestor in component.componentstate then begin
  if ancestor = nil then begin
   str1:= aname;
   comp1:= component.owner;
   while comp1 <> nil do begin
    if csinline in comp1.componentstate then begin
     break;
    end;
    str1:= comp1.name+'.'+str1;
    comp1:= comp1.owner;     
   end;
   if comp1 <> nil then begin
    comp1:= fdescendentinstancelist.findancestor(comp1);
    if comp1 <> nil then begin
     ancestor:= findnestedcomponent(comp1,str1);
    end;
   end;
  end;
 end
 else begin
  if not (csinline in component.componentstate) and 
   (component.owner <> nil) and (csancestor in component.owner.componentstate) then begin
   ancestor:= nil; //has name duplicate
  end;
 end; 
end;

procedure tdesigner.getmethodinfo(const method: tmethod; out moduleinfo: pmoduleinfoty;
                      out methodinfo: pmethodinfoty);
var
 int1: integer;
begin
// moduleinfo:= fmodules.findmodulebyinstance(tcomponent(method.data));
// if moduleinfo <> nil then begin
//  with moduleinfo^.methods do begin
//   methodinfo:= findmethod(method.data);
//  end;
// end
// else begin
  methodinfo:= nil;
  for int1:= 0 to fmodules.count - 1 do begin
   methodinfo:= fmodules[int1]^.methods.findmethod(method.data);
   if methodinfo <> nil then begin
    moduleinfo:= fmodules[int1];
    break;
   end;
  end;
// end;
end;

function tdesigner.isownedmethod(const root: tcomponent;
                                          const method: tmethod): boolean;
var
 po1: pmoduleinfoty;
begin
 result:= false;
 po1:= fmodules.findmodulebyinstance(root);
 if po1 <> nil then begin
  result:= po1^.methods.findmethod(method.data) <> nil;
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
  raise exception.Create(actionsmo.c[ord(ac_invalidmethodname)]+' '''+
                                                            newname+'''.');
 end;
 getmethodinfo(method,po2,po1);
 if po2 = nil then begin
  raise exception.Create(actionsmo.c[ord(ac_modulenotfound)]);
 end;
 if po1 = nil then begin
  raise exception.Create(actionsmo.c[ord(ac_methodnotfound)]);
 end;
 oldname:= po1^.name;
 po1^.name:= newname;
 fmodules.fmethodnames.setdata(ptruint(po1^.address),newname);
 po2^.modified:= true;
 designnotifications.methodnamechanged(fdesigner,po2^.instance,newname,oldname,atypeinfo);
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

procedure tdesigner.checkmethod(const method: tmethod; const aname: string; 
                const module: tmsecomponent; const atype: ptypeinfo);
var
 po1: pmethodinfoty;
 po2: pmoduleinfoty;
begin
 getmethodinfo(method,po2,po1);
 if (po1 <> nil) and (po2 <> nil) and (atype <> nil) then begin
  designnotifications.methodcreated(idesigner(self),module,aname,atype);
 end;
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
 removefixupreferences(amodule^.instance,'');
 if amodule = flastmethodmodulepo then begin
  flastmethodmodulepo:= nil;
 end;
 if amodule = factmodulepo then begin
  setactivemodule(nil);
 end;
 for int1:= 0 to amodule^.components.count - 1 do begin
  fselections.remove(amodule^.components.next^.instance);
 end;
 designnotifications.moduledestroyed(idesigner(self),amodule^.instance);
 designnotifications.selectionchanged(idesigner(self),
       idesignerselections(fselections));
// designnotifications.moduledestroyed(idesigner(self),amodule^.instance);
end;

procedure tdesigner.addancestorinfo(const ainstance,aancestor: tmsecomponent);
begin
 fdescendentinstancelist.add(ainstance,aancestor,fsubmodulelist);
end;

procedure tdesigner.showformdesigner(const amodule: pmoduleinfoty);
begin
 amodule^.designform.activate;
 mainfo.createmodulemenuitem(amodule);
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

{$ifndef mse_nomethodswap}
procedure tdesigner.internaldoswapmethodpointers(const aroot: tcomponent;
                    const ainstance: tobject;
                    const ainit: boolean);
begin
 if finditem(pointerarty(fdescendentinstancelist.fswappedancestors),
                           ainstance) < 0 then begin
  if ainit then begin
   forallmethodproperties(aroot,ainstance,nil,
           {$ifdef FPC}@{$endif}swapinitmethodpointer,true);
  end
  else begin
   forallmethodproperties(aroot,ainstance,nil,
           {$ifdef FPC}@{$endif}swapmethodpointer,true);
  end;
 end;
end;

procedure tdesigner.doswapmethodpointers(const ainstance: tobject;
                                                 const ainit: boolean);
begin
 if ainstance is tcomponent then begin
  internaldoswapmethodpointers(rootcomponent(tcomponent(ainstance)),
                                                               ainstance,ainit);
 end
 else begin
  internaldoswapmethodpointers(nil,ainstance,ainit);
 end;
end;
{$endif}

{$ifdef mse_nomethodswap} 
procedure tdesigner.writedesignmethod(writer: twriter; instance: tpersistent;
               propinfo: ppropinfo; const methodvalue: tmethod;
               const defmethodvalue: tmethod; var handled: boolean);
var
 str1: string;
// po1: pmethodinfoty;
begin
 handled:= true;
 if (methodvalue.data <> defmethodvalue.data) then begin
  with tbinaryobjectwriter1(writer.driver) do begin
   beginproperty(writer.propertypath + ppropinfo(propinfo)^.name);
   if methodvalue.data = nil then begin
    writevalue(vanil);
   end
   else begin
    str1:= fmodules.fmethodnames.find(ptruint(methodvalue.data));        
    if str1 = '' then begin
     writevalue(vanil);
    end
    else begin
     writevalue(vaident);
     writestr(str1);
     endproperty;
    end;
   end;
  end;
 end;
end;
{$endif}

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
function tdesigner.getancestorclassinfo(const ainstance: tcomponent;
                      const interfaceonly: boolean): classinfopoarty;
var
 ar1: componentarty;
 ar2: classinfopoarty;
 int1{,int2}: integer;
 po1: punitinfoty;
 po2: pmoduleinfoty;
begin
 ar1:= fdescendentinstancelist.getancestors(ainstance);
 additem(pointerarty(ar1),ainstance);
 setlength(ar2,length(ar1));
 for int1:= 0 to high(ar1) do begin
  po2:= modules.findmodule(tmsecomponent(ar1[int1]));
  if po2 <> nil then begin
   po1:= sourceupdater.updateformunit(po2^.filename,interfaceonly);
   if po1 <> nil then begin
    ar2[int1]:= findclassinfobyinstance(tmsecomponent(ar1[int1]),po1);
   end;
  end;
 end;
 result:= classinfopoarty(packarray(pointerarty(ar2))); 
end;

function tdesigner.getancestorclassinfo(const ainstance: tcomponent;
                const interfaceonly: boolean;
                                 out aunits: unitinfopoarty): classinfopoarty;
                                                  
var
 ar1: componentarty;
 ar2: classinfopoarty;
 int1{,int2}: integer;
 po1: punitinfoty;
 po2: pmoduleinfoty;
begin
 ar1:= fdescendentinstancelist.getancestors(ainstance);
 additem(pointerarty(ar1),ainstance);
 setlength(ar2,length(ar1));
 setlength(aunits,length(ar1));
 for int1:= 0 to high(ar1) do begin
  po2:= modules.findmodule(tmsecomponent(ar1[int1]));
  if po2 <> nil then begin
   po1:= sourceupdater.updateformunit(po2^.filename,interfaceonly);
   aunits[int1]:= po1;
   if po1 <> nil then begin
    ar2[int1]:= findclassinfobyinstance(tmsecomponent(ar1[int1]),po1);
   end;
  end;
 end;
 result:= ar2;
end;

function tdesigner.checkmethodtypes(const amodule: pmoduleinfoty;
                      const init: boolean): boolean;
                                      //false on cancel
var
 classinfar: classinfopoarty;
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
     if (method1.data <> nil) then begin
      po1:= amodule^.methods.findmethod(method1.data);
      if po1 <> nil then begin
       if init then begin
        po1^.typeinfo:= ar1[int1]^.proptype{$ifndef FPC}^{$endif};
       end
       else begin
        po2:= nil;
        for int2:= 0 to high(classinfar) do begin
         po2:= classinfar[int2]^.procedurelist.finditembyname(po1^.name);
         if po2 <> nil then begin
          break;
         end;
        end;
        mr1:= mr_none;
        if (po2 = nil) or not po2^.managed then begin
         mr1:= askyesnocancel(actionsmo.c[ord(ac_publishedmeth)]+ ' '+
                 amodule^.instance.name+'.'+po1^.name+' ('+
                 comp1.name+'.'+ar1[int1]^.name+') '+
                 actionsmo.c[ord(ac_doesnotexist)]+lineend+
                 actionsmo.c[ord(ac_wishdelete)],actionsmo.c[ord(ac_warning)]);
        end
        else begin
         if not parametersmatch(po1^.typeinfo,po2^.params) then begin
           mr1:= askyesnocancel(actionsmo.c[ord(ac_method)]+
                ' '+amodule^.instance.name+'.'+po1^.name+' ('+
                 comp1.name+'.'+ar1[int1]^.name+') '+
                 actionsmo.c[ord(ac_differentparams)]+lineend+
                 actionsmo.c[ord(ac_wishdelete)],actionsmo.c[ord(ac_warning)]);
         end;
        end;
        if mr1 = mr_yes then begin
         setmethodprop(instance,ar1[int1],nullmethod);
         modulechanged(amodule);
        end
        else begin
        end;
        result:= mr1 in [mr_yes,mr_no,mr_none];
       end;
      end;
     end;
    end;
    tkclass: begin
     obj1:= getobjectprop(instance,ar1[int1]);
     if issubprop(obj1) then begin
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
// po3: punitinfoty;
begin
 result:= true;
 if not init then begin
  mstr1:= replacefileext(amodule^.filename,pasfileext);
  if sourcefo.findsourcepage(mstr1) = nil then begin
   exit;
  end;
//  po3:= sourceupdater.updateformunit(amodule^.filename,true);
//  if po3= nil then begin
//   exit;
//  end;
  classinfar:= getancestorclassinfo(amodule^.instance,true);
//  classinf:= findclassinfobyinstance(amodule^.instance,po3);
//  if classinf = nil then begin
//   exit;
//  end;
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

function tdesigner.loadformfile(filename: msestring;
                         const skipexisting: boolean): pmoduleinfoty;
var
 module: tmsecomponent;
 loadedsubmodulesindex: integer;
 moduleinfo: tmoduleinfo;
  
 procedure dodelete;
 var
  int1: integer;
  desfo: tmseform;
 begin
  removefixupreferences(module,'');
  for int1:= high(floadedsubmodules) downto loadedsubmodulesindex+1 do begin
   removefixupreferences(floadedsubmodules[int1],'');
  end;
  desfo:= result^.designform;
  moduleinfo.free; //frees module by designform
  if desfo = nil then begin
   module.Free;
  end;
  module:= nil;
  result:= nil;
 end;
 
var
 moduleclassname1,modulename,
 designmoduleclassname: string;
 stream1: ttextstream;
 stream2: tmemorystream;
 reader: treader;
 flags: tfilerflags;
 pos: integer;
 rootnames,rootinstancenames: tstringlist;
 int1: integer;
 wstr1: msestring;
 res1: modalresultty;
 bo1: boolean;
 loadingdesignerbefore: tdesigner;
 loadingmodulepobefore: pmoduleinfoty;
 isinherited: boolean;
 str1: string;
 fixupmodule: string;
 lastmissed: string;
 comp1: tcomponent;
 deletefixups: boolean;
 exp1: exception;

begin //loadformfile
 filename:= filepath(filename);
 result:= fmodules.findmodule(filename);
 if result = nil then begin
  designnotifications.closeobjecttext(idesigner(self),filename,bo1);
  if bo1 then begin
   exit; //canceled
  end;
  exp1:= nil;
  stream1:= ttextstream.Create(filename,fm_read);
  designmoduleclassname:= '';
  rootnames:= tstringlist.create;
  rootinstancenames:= tstringlist.create;
  try
   stream2:= tmemorystream.Create;
   try
    try
     objecttexttobinarymse(stream1,stream2);
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
     result:= modules.findmodulebyname(modulename);
     if result <> nil then begin
      stream2.free; //not listed in loadingstreams
      if skipexisting and issamefilepath(result^.filename,filename) then begin
       exit;
      end;
      raise exception.create(actionsmo.c[ord(ac_amodule)]+modulename+
                            actionsmo.c[ord(ac_isopen)]);
     end;
     stream2.Position:= 0;
     loadingdesignerbefore:= loadingdesigner;
     loadingdesigner:= self;
     inc(fformloadlocklevel);
     begingloballoading;
     try
      try
       moduleinfo:= fmodules.newmodule(isinherited,filename,moduleclassname1,modulename,
       designmoduleclassname);
       fmodules.add(moduleinfo);
       result:= @moduleinfo.info;
       result^.loadingstream:= stream2;
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
        {$ifdef mse_nomethodswap}
         reader.onsetmethodproperty:= {$ifdef FPC}@{$endif}setmethodproperty;
        {$else}
         reader.onfindmethod:= {$ifdef FPC}@{$endif}findmethod;
        {$endif}
         reader.onfindcomponentclass:= {$ifdef FPC}@{$endif}findcomponentclass;
         reader.onancestornotfound:= {$ifdef FPC}@{$endif}ancestornotfound;
         reader.oncreatecomponent:= createcomponent;
         reader.onerror:= {$ifdef FPC}@{$endif}readererror;
         module.Name:= modulename;
         reader.ReadrootComponent(module);
        {$ifndef mse_nomethodswap}
         doswapmethodpointers(module,true);
        {$endif}
         result^.components.assigncomps(module);
         getfixupreferencenames(module,rootnames);
         setlength(result^.referencedmodules,rootnames.Count);
         for int1:= 0 to high(result^.referencedmodules) do begin
          result^.referencedmodules[int1]:= rootnames[int1];
         end;
         dofixup;
         fixupmodule:= '';
         lastmissed:= '';
         deletefixups:= true;
         while true do begin
          rootnames.clear;
          rootinstancenames.clear;
          getfixupreferencenames(module,rootnames);
          for int1:= rootnames.count - 1 downto 0 do begin
           comp1:= fmodules.findmoduleinstancebyname(rootnames[int1]);
           if (comp1 <> nil) and (comp1 <> module) and 
                                (csloading in comp1.componentstate) then begin
            deletefixups:= false;
            additem(pointerarty(fcheckfixups),result);
            rootnames.delete(int1); //there is hope
           end;
          end;
          if rootnames.Count > 0 then begin
           if assigned(fongetmodulenamefile) then begin
            try
             res1:= mr_cancel;
             if fixupmodule = rootnames[0] then begin
              break;
             end;
             fixupmodule:= rootnames[0];
             getfixupinstancenames(module,fixupmodule,rootinstancenames);
             if rootinstancenames.count > 0 then begin
              str1:= '.'+rootinstancenames[0];
             end
             else begin
              str1:= '';
             end;
             lastmissed:= fixupmodule + str1;
             fongetmodulenamefile(result,lastmissed,res1);
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
         if (module <> nil) and deletefixups then begin
          removefixupreferences(module,'');
         end;
         if rootnames.Count > 0 then begin
          wstr1:= rootnames[0];
          for int1:= 1 to rootnames.Count - 1 do begin
           wstr1:= wstr1 + ','+rootnames[int1];
          end;
          raise exception.Create(actionsmo.c[ord(ac_unresolvedref)]+' '+
                                                       lastmissed+lineend+
                          actionsmo.c[ord(ac_modules)]+' '+wstr1+'.');
         end;
         result^.resolved:= true;
        except
         freeandnil(reader); //used stream will be freed
         dodelete;
         raise;
        end;
       finally
        reader.free;
        floadingmodulepo:= loadingmodulepobefore;
        setlength(floadedsubmodules,loadedsubmodulesindex+1);
                     //remove info
        dec(fformloadlevel);
        unlockfindglobalcomponent;
       end;
       if result <> nil then begin
        result^.designform:= createdesignform(self,result);
        result^.designform.getcorbainterface(typeinfo(iformdesigner),
                                             result^.designformintf);
        checkmethodtypes(result,true);
        result^.modified:= false;
       end;
      finally
       loadingdesigner:= nil;
      end;
      notifygloballoading;
     finally
      loadingdesigner:= loadingdesignerbefore;
      endgloballoading;
      dec(fformloadlocklevel);
     end;
    except
     on e: exception do begin
      e.Message:= actionsmo.c[ord(ac_cannotreadform)]+filename+'".'+
                                                       lineend+e.Message;
      raise;
     end;
    end;
   finally
    if fformloadlevel = 0 then begin
     fmodules.freeloadingstreams;
     while high(fcheckfixups) >= 0 do begin
      rootnames.clear;
      with fcheckfixups[high(fcheckfixups)]^ do begin
       getfixupreferencenames(instance,rootnames);
       if rootnames.count > 0 then begin
        designnotifications.showobjecttext(
                                  idesigner(self),filename,backupcreated);
        if exp1 = nil then begin
         rootinstancenames.clear;      
         getfixupinstancenames(instance,rootnames[0],rootinstancenames);
         if rootinstancenames.count > 0 then begin
          str1:= '.'+rootinstancenames[0];
         end
         else begin
          str1:= '';
         end;
         exp1:= exception.create(
             actionsmo.c[ord(ac_cannotreadform)]+filename+'".'+lineend+
             actionsmo.c[ord(ac_unresolvedref)]+rootnames[0]+str1+'.');
        end;
        instance.free;
        fmodules.removemoduleinfo(fcheckfixups[high(fcheckfixups)]);
       end
       else begin
        setlength(fcheckfixups,high(fcheckfixups));
       end;
      end;
     end;
     removefixupreferences(nil,'');
     if exp1 <> nil then begin
      if result <> nil then begin
       dodelete;
      end;
      raise exp1;
     end;
    end;
   end;
  finally
   rootnames.free;
   rootinstancenames.free;
   stream1.Free;
  end;
 end;
 (*
  {$ifdef mse_debugsubmodule}
        {$ifdef mse_debugmoduleload}
         dumpcomponent(result^.instance,filename);
        {$endif}
 debugbinstreamout(result^.instance,nil,
                          {$ifdef FPC}@{$endif}fdesigner.findancestor,
                          '*****loadformfile '+filename);
  {$endif}
  *)
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

function tdesigner.getancestormethods(const amodule: pmoduleinfoty): methodsarty;
var
 comp1: tcomponent;
begin
{$ifdef mse_nomethodswap}
 setlength(result,1);
 result[0]:= amodule^.methods;
{$else}
 result:= nil;
{$endif}
 comp1:= amodule^.instance;
 while true do begin
  comp1:= fdescendentinstancelist.findancestor(comp1);
  if comp1 = nil then begin
   break;
  end;
  additem(pointerarty(result),fmodules.findmodulebyinstance(comp1)^.methods);
 end;
end;

{$ifndef mse_nomethodswap}
procedure tdesigner.buildmethodtable(const amodule: pmoduleinfoty);
begin
 if amodule <> nil then begin
  with amodule^ do begin
   if methodtableswapped = 0 then begin
//    flookupmodule:= amodule;
    methodtablebefore:= swapmethodtable(instance,
                      methods.createmethodtable(getancestormethods(amodule)));
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
//    flookupmodule:= nil;
   end;
  end;
 end;
end;
{$endif}
procedure tdesigner.writemodule(const amodule: pmoduleinfoty;
                                     const astream: tstream);
var
 writer1: twritermse;
 ancestor: tcomponent;
begin
{$ifndef mse_nomethodswap}
 buildmethodtable(amodule);
{$endif}
 with amodule^ do begin
  fdescendentinstancelist.beginstreaming(nil);
 {$ifndef mse_nomethodswap}
  doswapmethodpointers(instance,false);
 {$endif}
  writer1:= twritermse.create(astream,4096,false);
  if instance is twidget then begin
   fdescendentinstancelist.setnodefaultpos(twidget(instance));
  end;
  beginstreaming(amodule);
  try
   if csancestor in instance.componentstate then begin
    ancestor:= fdescendentinstancelist.findancestor(instance);
   end
   else begin
    ancestor:= nil;
   end;
   writer1.onfindancestor:= {$ifdef FPC}@{$endif}findancestor;
  {$ifdef mse_nomethodswap}
   writer1.onwritemethodproperty:= {$ifdef FPC}@{$endif}writedesignmethod;
  {$endif}
   writer1.writedescendent(instance,ancestor);
  finally
   fdescendentinstancelist.endstreaming;
   endstreaming(amodule);
   writer1.free;
 {$ifndef mse_nomethodswap}
   doswapmethodpointers(instance,true);
   releasemethodtable(amodule);
 {$endif}
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
 if createdatafile and projectoptions.o.checkmethods 
                       and not checkmethodtypes(modulepo,false{,nil}) then begin
  result:= false;
  exit;
 end;
 result:= true;
 with modulepo^ do begin
  createbackupfile(afilename,filename,
                          backupcreated,projectoptions.e.backupfilecount);
  stream1:= tmemorystream.Create;
  try
   writemodule(modulepo,stream1);
   stream2:= tmsefilestream.createtransaction(afilename);
   try
    stream1.position:= 0;
    try
     objectbinarytotextmse(stream1,stream2);
    except
     stream2.cancel;
     raise;
    end;
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
   if not modified and projectoptions.o.checkmethods then begin
    if not checkmethodtypes(po1,false{,nil}) then begin
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
// asyncevent(showobjectinspectortag);  
               //use async because of window stacking problems
 objectinspectorfo.activate;
end;

function tdesigner.formfiletoname(const filename: msestring): msestring;
begin
 result:= removefileext(msefileutils.filename(filename));
end;

function tdesigner.getmethod(const aname: string;
               const methodowner: tmsecomponent; const atype: ptypeinfo;
                      const searchancestors: boolean): tmethod;
var
 ar1: componentarty;
 int1: integer;
begin
 result:= fmodules.findmethodbyname(aname,atype,methodowner);
 if searchancestors and (result.data = nil) then begin
  ar1:= fdescendentinstancelist.getancestors(methodowner);
  for int1:= high(ar1) downto 0 do begin
   result:= fmodules.findmethodbyname(aname,atype,tmsecomponent(ar1[int1]));
   if result.data <> nil then begin
    break;
   end;
  end;
 end;
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
  if (floadingmodulepo <> nil) and  
           (comp.Owner = floadingmodulepo^.instance) then begin  //???
   result:= comp.name;
  end
  else begin
   for int1:= 0 to fmodules.count - 1 do begin
    po1:= fmodules[int1];
    if issubcomponent(po1^.instance,comp) then begin
     if po1 = floadingmodulepo then begin
      result:= getcomponentdispname(comp);
     end
     else begin
      result:= po1^.instancevarname + '.' + getcomponentdispname(comp);
     end;
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
 ch1: char;
begin
 result:= comp.Name;
 ch1:= subcomponentsplitchar;
// if not (cssubcomponent in comp.componentstyle) then begin
//  ch1:= '.';
// end;
 comp1:= comp.owner;
 while not ismodule(comp1) do begin
  result:= comp1.Name + ch1 + result;
  comp1:= comp1.Owner;
//  if not (cssubcomponent in comp1.componentstyle) then begin
//   ch1:= '.';
//  end;
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
 ar1,ar2: stringarty;
 po1,po2: pmoduleinfoty;
 int1,int2: integer;
 bo1: boolean;
// str1: string;
begin
 if floadingmodulepo <> nil then begin
  splitstring(aname,ar2,':');
  result:= floadingmodulepo^.components.getcomponent(ar2[0]);
  if result = nil then begin
   splitstring(ar2[0],ar1,'.');
   if high(ar1) = 1 then begin
    ar1[0]:= uppercase(ar1[0]);
    for int1:= 0 to fmodules.count - 1 do begin
     po1:= fmodules[int1];
     if stricomp(pchar(po1^.instancevarname),pchar(ar1[0])) = 0 then begin
      result:= po1^.components.getcomponent(ar1[1]);
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
  if (result <> nil) and (high(ar2) > 0) then begin
   for int1:= 1 to high(ar2) do begin
    result:= result.findcomponent(ar2[int1]);
    if result = nil then begin
     break;
    end;
   end;
  end;
 end
 else begin
  result:= nil;
 end;
end;

function tdesigner.getcomponentlist(
             const acomponentclass: tcomponentclass;
             const filter: compfilterfuncty = nil;
             const allmodules: boolean = false): componentarty;
var
 acount: integer;

 procedure check(const acomp: tcomponent);
 begin
  if acomp.InheritsFrom(acomponentclass) and 
       (({$ifndef FPC}@{$endif}filter = nil) or filter(acomp)) and 
       not isnosubcomp(acomp) then begin
   additem(pointerarty(result),acomp,acount);
  end;
 end; //check

 procedure scanmodule(amodule: pmoduleinfoty);
 var
  int1,int3: integer;
  comp1,comp2: tcomponent;
 begin
  with amodule^.components do begin
//   for int1:= 0 to high(result) do begin
//    check(next^.instance);
//   end;
   for int1:= 0 to count - 1 do begin
    comp1:= next^.instance;
    check(comp1);
    for int3:= 0 to comp1.componentcount - 1  do begin
     comp2:= comp1.components[int3];
     if cssubcomponent in comp2.componentstyle then begin
      check(comp2);
     end;
    end;
   end;
  end;
 end;
 
var
 int1: integer;  
 
begin
 acount:= 0;
 if allmodules then begin
  for int1:= 0 to modules.count-1 do begin
   scanmodule(modules[int1]);
  end;
 end
 else begin
  if floadingmodulepo <> nil then begin
   scanmodule(floadingmodulepo);
  end;
 end;
 setlength(result,acount);
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

procedure sortcompnamelist(var avalue: msestringarty);
var
 int1: integer;
begin
 sortarray(avalue,{$ifdef FPC}@{$endif}compcompname);
 for int1:= 0 to high(avalue) do begin
  avalue[int1]:= copy(avalue[int1],2,bigint);
 end;
end;

function tdesigner.getcomponentnamelist(const acomponentclass: tcomponentclass;
                            const includeinherited: boolean;
                            const aowner: tcomponent = nil;
                          const filter: compfilterfuncty = nil): msestringarty;
var
 str1: msestring;
 acount: integer;

 procedure check(const comp1: tcomponent);
 var
  int3: integer;
  comp2: tcomponent;
 begin
  if comp1.InheritsFrom(acomponentclass) and 
          (({$ifndef FPC}@{$endif}filter = nil) or filter(comp1)) then begin
   if ((aowner = nil) or (aowner = comp1.owner)) and 
            (includeinherited or 
            (comp1.componentstate * [csinline,csancestor] = [])) then begin
    additem(result,str1+getcomponentdispname(comp1),acount);
   end;
  end;
  for int3:= 0 to comp1.componentcount - 1  do begin
   comp2:= comp1.components[int3];
   if (cssubcomponent in comp2.componentstyle){ and 
                                    not isnosubcomp(comp2)} then begin
    check(comp2);
   end;
  end;
 end;
 
var
 int1,int2{,int3}: integer;
 comp1{,comp2}: tcomponent;
 po1: pmoduleinfoty;
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
    check(comp1);
   end;
  end;
 end;
 setlength(result,acount);
 sortcompnamelist(result);
end;

function tdesigner.getcomponentnamelist(const acomponents: componentarty;
                            const amodule: tmsecomponent): msestringarty;
var
 int1,int2: integer;
 co1: tcomponent;
begin
 setlength(result,length(acomponents));
 int2:= 0;
 for int1:= 0 to high(acomponents) do begin
  if acomponents[int1] <> nil then begin
   co1:= rootcomponent(acomponents[int1]);
   if co1 = amodule then begin
    result[int2]:= ' ';
   end
   else begin
    result[int2]:= 'z'+co1.name + '.';
   end;
   result[int2]:= result[int2] + getcomponentdispname(acomponents[int1]);
   inc(int2);
  end;
 end;
 setlength(result,int2);
 sortcompnamelist(result);
end;

type
 tdesigncompnameitem = class(tcompnameitem)
  private
   fcomp: tcomponent;
  public
   constructor create(const acomp: tcomponent;
                            const aisvalue: boolean); reintroduce;
   function findcomp(const acomp: tcomponent): tdesigncompnameitem;
 end;

{ tdesigncompnameitem }

constructor tdesigncompnameitem.create(const acomp: tcomponent;
               const aisvalue: boolean);
begin
 fcomp:= acomp;
 inherited create;
 isvalue:= aisvalue;
 if acomp <> nil then begin
  caption:= acomp.name;
 end;
end;

function tdesigncompnameitem.findcomp(const acomp: tcomponent): tdesigncompnameitem;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to fcount -1 do begin
  if tdesigncompnameitem(fitems[int1]).fcomp = acomp then begin
   result:= tdesigncompnameitem(fitems[int1]);
   break;
  end;
 end;
end;

 
function tdesigner.getcomponentnametree(const acomponentclass: tcomponentclass;
                         const includeinherited: boolean;
                         const aowner: tcomponent = nil;
                         const filter: compfilterfuncty = nil): tcompnameitem;

 procedure check(const acomp: tcomponent);
 var
  int1,int3: integer;
  comp1,comp2: tcomponent;
  node1,node2,node3: tdesigncompnameitem;
  ar1: componentarty;
 begin
  if acomp.InheritsFrom(acomponentclass) and 
          (({$ifndef FPC}@{$endif}filter = nil) or filter(acomp)) then begin
   if ((aowner = nil) or (aowner = acomp.owner)) and 
            (includeinherited or 
            (acomp.componentstate * [csinline,csancestor] = [])) then begin
    node1:= tdesigncompnameitem.create(acomp,true);
    node1.imagenr:= 4;
    node1.state:= node1.state + [ns_imagenrfix];
    comp1:= acomp.owner;
    while comp1 <> nil do begin
     additem(pointerarty(ar1),comp1);
     comp1:= comp1.owner;
    end;
    node2:= tdesigncompnameitem(result);
    for int1:= high(ar1) downto 0 do begin
     node3:= node2.findcomp(ar1[int1]);
     if node3 = nil then begin
      node3:= tdesigncompnameitem.create(ar1[int1],false);
      node2.add(node3);
     end;
     node3.state:= node3.state - [ns_imagenrfix];
     node2:= node3;
    end;
    node2.add(node1);
   end;
  end;
  for int3:= 0 to acomp.componentcount - 1  do begin
   comp2:= acomp.components[int3];
   if (cssubcomponent in comp2.componentstyle){ and 
                                    not isnosubcomp(comp2)} then begin
//    node1:= anode.findcomp(comp2);
//    if node1 = nil then begin
//     node1:= tdesigncompnameitem.create(comp2,false);
//    end;
    check(comp2);
   end;
  end;
 end;
 
var
 int1,int2{,int3}: integer;
 comp1{,comp2}: tcomponent;
 po1: pmoduleinfoty;
begin
 result:= tdesigncompnameitem.create(nil,false);
 for int1:= 0 to fmodules.count - 1 do begin
  po1:= fmodules[int1];
  with po1^.components do begin
   for int2:= 0 to count - 1 do begin
    comp1:= next^.instance;
    check(comp1);
   end;
  end;
 end;
 result.sort(false,true);
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
 comp1: tcomponent;
begin
 ar1:= nil; //compiler warning
 if loadingdesigner = nil then begin
  po1:= findcomponentmodule(acomponent);
  if po1 <> nil then begin
   if newname = '' then begin
    raise exception.Create(actionsmo.c[ord(ac_invalidcompname)]);
   end;
   if acomponent.name <> newname then begin
    if stringicomp(acomponent.name,newname) <> 0 then begin
     comp1:= acomponent.getparentcomponent;
     if (comp1 <> nil) and (comp1.findcomponent(newname) <> nil) then begin
      raise EComponentError.Createfmt(SDuplicateName,[newname]);
     end;
    end;
    po1^.components.namechanged(acomponent,newname);
    fdescendentinstancelist.componentnamechanged(po1,acomponent,newname);
    
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

function tdesigner.editcomponent(const aowner: tcomponent = nil): boolean;
                                  //false if no editor available
begin
 result:= componentcanedit and ((aowner = nil) or
                      (fcomponenteditor.component.owner = aowner));
 if result then begin
  fcomponenteditor.edit;
 end;
end;

procedure tdesigner.savecanceled;
begin
 fallsaved:= false;
end;

function tdesigner.beforemake: boolean;
var
 int1: integer;
 page1: tsourcepage;
begin
 result:= true;
 for int1:= 0 to fmodules.count - 1 do begin
  with fmodules.itempo[int1]^ do begin
   if assigned(moduleintf^.sourcetoform) then begin
    page1:= sourcefo.findsourcepage(replacefileext(filename,pasfileext),true,true);
    if (page1 <> nil) then begin
     moduleintf^.sourcetoform(instance,page1.source);
    end;
   end;
  end;
 end;
end;

function tdesigner.selectedcomponents: componentarty;
begin
 setlength(result,fselections.count);
 move(fselections.datapo^,result[0],length(result)*sizeof(pointer)); 
end;

procedure tdesigner.readererror(reader: treader; const message: string;
               var handled: boolean);
var
 comp1: tcomponent;
begin
 comp1:= reader.lookuproot;
 if comp1 = nil then begin
  comp1:= reader.root;
 end;
 with exception(ExceptObject) do begin
  message:= actionsmo.c[ord(ac_component)]+
                            ownernamepath(comp1)+'":'+lineend+message;
 end;
end;

function tdesigner.clickedcomp: tcomponent;
begin
 result:= nil;
 if (factmodulepo <> nil) and (factmodulepo^.designformintf <> nil) then begin
  result:= factmodulepo^.designformintf.clickedcomponent;
 end;
end;
{
procedure tdesigner.doasyncevent(var atag: integer);
begin
 if atag = showobjectinspectortag then begin
  objectinspectorfo.activate;
 end;
end;
}
{ tcomponentslink }

procedure tcomponentslink.notification(acomponent: tcomponent;
  operation: toperation);
begin
 if operation = opremove then begin
  fowner.destroynotification(acomponent);
 end;
 inherited;
end;

{ tmethodnames }

initialization
 fdesigner:= tdesigner.create;
finalization
 fdesigner.Free;
end.
