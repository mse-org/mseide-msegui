{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseclasses;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mseglob,mseevent,msetypes,msestrings,sysutils,typinfo,mselist,
 msegraphutils{$ifdef mse_with_ifi},mseifiglob{$endif};

{ $define debugobjectlink}

{$ifdef FPC}
 
const
 s_ok = 0;
{$endif}
const
 moduleclassnamename = 'moduleclassname';
// inheritedmoduleclassnamename = 'inheritedmoduleclassname';
 compilerdefaults =
     '{$ifdef FPC}{$mode objfpc}{$h+}{$endif}';

type
 notifyeventty = procedure (const sender: tobject) of object;
 componenteventty = procedure (const acomponent: tcomponent) of object;
 checkeventty = function (const sender: tobject): boolean of object;
 eventeventty = procedure (const sender: tobject; const aevent: tobjectevent) of object;
 asynceventeventty = procedure (const sender: tobject; var atag: integer) of object;

 booleanchangedeventty = procedure (const sender: tobject;
                            const avalue: boolean) of object;
 stringchangedeventty = procedure (const sender: tobject;
                            const avalue: msestring) of object;
 integerchangedeventty = procedure (const sender: tobject;
                            const avalue: integer) of object;
 realchangedeventty = procedure (const sender: tobject;
                            const avalue: realty) of object;

 getintegereventty = function :integer of object;
 
 updateint64eventty = procedure(const sender: tobject; var avalue: int64) of object;
 
 setbooleaneventty = procedure(const sender: tobject; var avalue: boolean;
                          var accept: boolean) of object;
 setstringeventty = procedure(const sender: tobject; var avalue: msestring;
                          var accept: boolean) of object;
 setansistringeventty = procedure(const sender: tobject; var avalue: ansistring;
                          var accept: boolean) of object;
 setintegereventty = procedure(const sender: tobject; var avalue: integer; 
                          var accept: boolean) of object; 
                          //equal parameters as setcoloreventty for tcoloredit!
 setrealeventty = procedure(const sender: tobject; var avalue: realty;
                          var accept: boolean) of object;
 setdatetimeeventty = procedure(const sender: tobject; var avalue: tdatetime;
                          var accept: boolean) of object;

 progresseventty =  procedure(const sender: tobject; const avalue: real;
                                               var acancel: boolean) of object;

 persistentarty = array of tpersistent;
 persistentclassty = class of tpersistent;
 
 componentarty = array of tcomponent;
 componentclassty = class of tcomponent;

 propinfopoarty = array of ppropinfo;

 tvirtualpersistent = class(tpersistent)
  protected
   procedure internalcreate; virtual;
  public
   constructor create; virtual;
 end;
 virtualpersistentclassty = class of tvirtualpersistent;

 townedpersistent = class(tvirtualpersistent)
  protected
   fowner: tobject;
  public
   constructor create(aowner: tobject); reintroduce; virtual;
 end;

 tlinkedobject = class;

 linkinfoty = record
  source: pointer; //iobjectlink
  dest: pointer;   //iobjectlink
  refcount: integer;
  valuepo: pointer;
  interfacetype: pointer;
 end;
 plinkinfoty = ^linkinfoty;

 linkinfoaty = array[0..0] of linkinfoty;
 plinkinfoaty = ^linkinfoaty;

 plinkedobject = ^tlinkedobject;
 tmsecomponent = class;
 pmsecomponent = ^tmsecomponent;
 pobjectlinker = ^tobjectlinker;
 tlinkedpersistent = class;
 plinkedpersistent = ^tlinkedpersistent;

 objectlinkprocty = procedure(const info: linkinfoty) of object;

 tobjectlinker = class(trecordlist)
  private
   fonevent: objectlinkeventty;
   fownerintf: pointer; //iobjectlink;
   finstancepo: pobjectlinker;
   fnopack: integer;
   procedure dopack;
   procedure removelink(var item: linkinfoty; destroyed: boolean);
  protected
   function isempty(var item): boolean; override;
   function findsource(const item: linkinfoty): integer;
  public
   {$ifdef debugobjectlink}
   debugon: boolean;
   {$endif}
   constructor create(const owner: iobjectlink; onevent: objectlinkeventty);
   destructor destroy; override;
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                ainterfacetype: pointer = nil; once: boolean = false); overload;
   procedure link(const dest: tmsecomponent; valuepo: pointer = nil;
                ainterfacetype: pointer = nil; once: boolean = false); overload;
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); overload;
               //source = 1 -> dest destroyed
   procedure unlink(const dest: tmsecomponent; valuepo: pointer = nil); overload;
   function linkedobjects: objectarty;

   procedure setlinkedvar(const linkintf: iobjectlink; const source: tlinkedobject;
                         var dest: tlinkedobject); overload;
   procedure setlinkedvar(const linkintf: iobjectlink; const source: tlinkedpersistent;
                         var dest: tlinkedpersistent); overload;
   procedure setlinkedvar(const linkintf: iobjectlink; const source: tmsecomponent;
                         var dest: tmsecomponent); overload;
   procedure sendevent(event: objecteventty);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   procedure forall(proc: objectlinkprocty; ainterfacetype: pointer);
 end;

 tlinkedobject = class(tnullinterfacedobject,iobjectlink)
  private
  protected
   fobjectlinker: tobjectlinker;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
 public
   destructor destroy; override;
//   property objectlinker: tobjectlinker read getobjectlinker;
 end;

 tnullinterfacedobject = class(tobject)
  protected
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
   function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
 end;

 tnullinterfacedpersistent = class(tvirtualpersistent)
  protected
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
   function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
 end;

 toptionalpersistent = class(tnullinterfacedpersistent)
  private
   procedure readdummy(reader: treader);
   procedure writedummy(writer: twriter);
  protected
   procedure defineproperties(filer : tfiler); override;
 end;

 tlinkedpersistent = class(tnullinterfacedpersistent,iobjectlink)
  private
  protected
   fobjectlinker: tobjectlinker;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject; virtual;

  public
   destructor destroy; override;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
 end;

 teventpersistent = class(tlinkedpersistent,ievent)
  protected
   procedure receiveevent(const event: tobjectevent); virtual;
  public
 end;

 townedeventpersistent = class(tlinkedpersistent)
  protected
   fowner: tobject;
  public
   constructor create(aowner: tobject); reintroduce; virtual;
 end;

 teventobject = class(tlinkedobject,ievent)
  protected
   procedure receiveevent(const event: tobjectevent); virtual;
  public
 end;

 componenteventstatety = (ces_processed,ces_callchildren);
 componenteventstatesty = set of componenteventstatety;

 tcomponentevent = class(tobjectevent)
  private
   fsender: tobject;
  public
   state: componenteventstatesty;
   tag: integer;
   constructor create(const asender: tobject; const atag: integer = 0;
                                         const callchildren: boolean = true);
                    overload;
   property sender: tobject read fsender;
 end;

 msecomponentstatety = (cs_ismodule,cs_endreadproc,cs_loadedproc,cs_noload{,}
                        {cs_hasskin,}{cs_noskin}{,cs_updateskinproc});
 msecomponentstatesty = set of msecomponentstatety;

 createprocty = procedure of object;
 
 skinoptionty = (sko_container);
 skinoptionsty = set of skinoptionty;
 
 skinobjectkindty = (sok_component,sok_widget,sok_groupbox,sok_simplebutton,
                     sok_tabbar,sok_toolbar,
                     sok_edit,sok_dataedit,sok_booleanedit,
                     sok_grid,
                     sok_mainmenu,sok_popupmenu,
                     sok_user); 
 skininfoty = record
  objectkind: skinobjectkindty;
  userkind: integer;
  options: skinoptionsty;
 end;

 tmsecomponent = class(tcomponent,ievent
                  {$ifdef mse_with_ifi},iificommand{$endif})
  private
   fonbeforeupdateskin: notifyeventty;
   fonafterupdateskin: notifyeventty;
   ftagpo: pointer;
   procedure readmoduleclassname(reader: treader);
   procedure writemoduleclassname(writer: twriter);
   procedure endread;
  protected
   fmsecomponentstate: msecomponentstatesty;
   fobjectlinker: tobjectlinker;
   factualclassname: pshortstring;
   fancestorclassname: string;
   fhelpcontext: msestring;
   function getmsecomponentstate: msecomponentstatesty;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
   procedure beginread; virtual;
   procedure doendread; virtual;
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure validaterename(acomponent: tcomponent;
                         const curname, newname: string); override;
   procedure sendchangeevent(const aevent: objecteventty = oe_changed);
   function linkcount: integer;
   function candestroyevent(const event: tmethod): boolean;
   function gethelpcontext: msestring; virtual;

   class function classskininfo: skininfoty; virtual;
   function skininfo: skininfoty; virtual;
   function hasskin: boolean; virtual;
   
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); virtual;
   procedure objevent(const sender: iobjectlink; const event: objecteventty); virtual;
   function getinstance: tobject;
     //ievent
   procedure receiveevent(const event: tobjectevent); virtual;

   procedure designselected(const selected: boolean); virtual;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedpersistent;
              var dest: tlinkedpersistent;
              const linkintf: iobjectlink = nil); overload;
   procedure writestate(writer: twriter); override;
   function getactualclassname: string;
   class function getmoduleclassname: string; virtual;
   procedure defineproperties(filer: tfiler); override;
   procedure componentevent(const event: tcomponentevent); virtual;
   procedure doasyncevent(var atag: integer); virtual;
   procedure doafterload; virtual;
   {$ifdef mse_with_ifi}
   //iificommand
   procedure executeificommand(var acommand: ificommandcodety); virtual;
   {$endif}
  public
   destructor destroy; override;
   procedure updateskin(const recursive: boolean = false);
   function loading: boolean; reintroduce;
       //this hides FPC tcomponent.loading which is not Delphi compatible
   {$ifdef FPC}
   procedure setinline(value: boolean);
   procedure setancestor(value: boolean);
   {$endif}
   function canevent(const event: tmethod): boolean;
   procedure setoptionalobject(const value: tpersistent; var instance;
                        createproc: createprocty);
   procedure getoptionalobject(const instance: tobject; createproc: createprocty);
   function getcorbainterface(const aintf: ptypeinfo; out obj) : boolean;
//   function getcorbainterface(const aintf: tguid; out obj) : boolean;
   procedure initnewcomponent(const ascale: real); virtual;
   function checkowned(component: tcomponent): boolean; 
                 //true if component is owned or self
   function checkowner(component: tcomponent): boolean; 
                 //true if component is owner or self
   function rootowner: tcomponent;
   function getrootcomponentpath: componentarty;
   function linkedobjects: objectarty;
                 //returns items of objeclinker and free notify list

   procedure sendcomponentevent(const event: tcomponentevent; 
                                        const destroyevent: boolean = true);
                  //event will be destroyed if not async
   procedure sendrootcomponentevent(const event: tcomponentevent;
                                        const destroyevent: boolean = true);
                  //event will be destroyed if not async
   procedure asyncevent(atag: integer = 0);
                          //posts event for doasyncevent to self
   procedure postcomponentevent(const event: tcomponentevent);

   property moduleclassname: string read getmoduleclassname;
   property actualclassname: string read getactualclassname;
   property msecomponentstate: msecomponentstatesty read fmsecomponentstate;
   property tagpo: pointer read ftagpo write ftagpo;
   property onbeforeupdateskin: notifyeventty read fonbeforeupdateskin 
                                   write fonbeforeupdateskin;
   property onafterupdateskin: notifyeventty read fonafterupdateskin 
                                   write fonafterupdateskin;
  published
   property helpcontext: msestring read gethelpcontext write fhelpcontext;
 end;

 msecomponenteventty = procedure(const sender: tmsecomponent) of object;
 msecomponentclassty = class of tmsecomponent;
 msecomponentarty = array of tmsecomponent;

 tlinkedqueue = class(tpointerqueue,iobjectlink)
  private
   fobjectlinker: tobjectlinker;
   fainstance: tobject;
   fownsobjects: boolean;
   function getitems(const index: integer): iobjectlink;
   procedure setitems(const index: integer; const Value: iobjectlink);
   procedure objectevent(const sender: tobject; const event: objecteventty);
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  protected
   procedure finalizeitem(var item: pointer); override;
   procedure linkdestroyed(const alink: iobjectlink); virtual;
  public
   constructor create(aownsobjects: boolean);
   destructor destroy; override;
   function destroying: boolean;
   function add(const value: iobjectlink): integer;
   procedure insert(const index: integer; const value: iobjectlink); reintroduce;
   function getfirst: iobjectlink;
   function getlast: iobjectlink;
   procedure sendchangenotification(sender: tobject);
   property items[const index: integer]: iobjectlink read getitems write setitems; default;
   property ownsobjects: boolean read fownsobjects write fownsobjects;
 end;

 tlinkedobjectqueue = class(tlinkedqueue,iobjectlink)
  private
  protected
   function getitems(const index: integer): tlinkedobject;
   procedure setitems(const index: integer; const Value: tlinkedobject);
  public
   function findobject(const aobject: tlinkedobject): integer;
                  //-1 if not found
   function add(const value: tlinkedobject): integer;
   procedure insert(const index: integer; const value: tlinkedobject); reintroduce;
   function getfirst: tlinkedobject;
   function getlast: tlinkedobject;
   property items[const index: integer]: tlinkedobject read getitems write setitems; default;
 end;

 tpersistentqueue = class(tlinkedqueue,iobjectlink)
  private
   function getitems(const index: integer): tlinkedpersistent;
   procedure setitems(const index: integer; const Value: tlinkedpersistent);
  protected
  public
   function findobject(const aobject: tlinkedpersistent): integer;
                  //-1 if not found
   procedure add(const value: tlinkedpersistent);
   procedure insert(const index: integer; const value: tlinkedpersistent); reintroduce;
   function getfirst: tlinkedpersistent;
   function getlast: tlinkedpersistent;
   property items[const index: integer]: tlinkedpersistent read getitems write setitems; default;
 end;

 tcomponentqueue = class(tlinkedqueue,iobjectlink)
  private
   function getitems(const index: integer): tmsecomponent;
   procedure setitems(const index: integer; const Value: tmsecomponent);
  protected
  public
   function findobject(const aobject: tmsecomponent): integer;
                  //-1 if not found
   function add(const value: tmsecomponent): integer;
   procedure insert(const index: integer; const value: tmsecomponent); reintroduce;
   function getfirst: tmsecomponent;
   function getlast: tmsecomponent;
   property items[const index: integer]: tmsecomponent read getitems write setitems; default;
 end;

 tobjectlinkrecordlist = class(trecordlist,iobjectlink)
  private
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  protected
   fobjectlinker: tobjectlinker;
   procedure finalizerecord(var item); override;
   procedure dounlink(var item); virtual; abstract;
   procedure itemdestroyed(const sender: iobjectlink); virtual; abstract;
  public
   constructor create(recordsize: integer; aoptions: recordliststatesty = []);
   destructor destroy; override;
 end;

 objectdataty = record
  size: integer;
  data: array[0..0] of byte;
 end;
 pobjectdataty = ^objectdataty;

 tpersistenttemplate = class(tlinkedpersistent)
  private
   fonchange: notifyeventty;
  protected
   fowner: tmsecomponent;
   procedure changed;
   function getinfosize: integer; virtual; abstract;
   function getinfoad: pointer; virtual; abstract;
   procedure copyinfo(const source: tpersistenttemplate); virtual;
   procedure assignto(dest: tpersistent); override;
   procedure doassignto(dest: tpersistent); virtual; abstract;
  public
   constructor create(const owner: tmsecomponent; const onchange: notifyeventty);
                 reintroduce; virtual;
   procedure assign(source: tpersistent); override;
 end;

 templateclassty = class of tpersistenttemplate;

 ttemplatecontainer = class(tmsecomponent)
  protected
   ftemplate: tpersistent;
   procedure assignto(dest: tpersistent); override;
   function gettemplateclass: templateclassty; virtual; abstract;
   procedure templatechanged(const sender: tobject);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

 tnotifylist = class(tmethodlist)
  public 
   procedure notify(const sender: tobject);
 end;
  
 tmodulelist = class(tcomponentqueue)
  protected
   flocked: integer;
   procedure ancestornotfound(Reader: TReader; const ComponentName: string;
                   ComponentClass: TPersistentClass; var Component: TComponent);
//   procedure findmethod(Reader: TReader; const MethodName: string;
//      var Address: Pointer; var Error: Boolean);
         //does not work because method.data is not writable
  public
   function findmodulebyname(const name: string): tcomponent;
   procedure lock;
   procedure unlock;
 end;
 
function ownernamepath(const acomponent: tcomponent): string; 
                     //namepath from root to acomponent separated by '.'
function rootcomponent(const acomponent: tcomponent): tcomponent;
procedure setcomponentorder(const owner: tcomponent; const anames: msestringarty);

function getpropinfoar(const obj: tobject): propinfopoarty; overload;
function getpropinfoar(const atypeinfo: ptypeinfo): propinfopoarty; overload;

procedure createobjectlinker(const owner: iobjectlink; onevent: objectlinkeventty;
                                  var instance: tobjectlinker);
 //sets finstancepo
procedure getoptionalobject(const componentstate: tcomponentstate;
                       const instance: tobject; createproc: createprocty); overload;
procedure getoptionalobject(const componentstate: tcomponentstate;
                  var instance: tvirtualpersistent;
                         const aclass: virtualpersistentclassty); overload;
procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tpersistent; var instance;
                    createproc: createprocty); overload;
procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tvirtualpersistent; var instance;
                  const aclass: virtualpersistentclassty); overload;
procedure setlinkedcomponent(const sender: iobjectlink; const source: tmsecomponent;
                      var instance: tmsecomponent; ainterfacetype: pointer = nil);

procedure createmodule(aowner: tcomponent; instanceclass: msecomponentclassty; var reference);
procedure registerobjectdata(datapo: pobjectdataty; 
                 objectclass: tpersistentclass; name: string = ''); overload;
procedure registerobjectdata(datapo: pobjectdataty; 
                 const objectclassname: string; const name: string = ''); overload;
                 //language overrides
procedure unregisterobjectdata(const objectclassname: string; const name: string = '');
                 //language overrides
procedure resetchangedmodules;
procedure reloadchangedmodules;

procedure reloadmsecomponent(Instance: tmsecomponent);
function initmsecomponent(instance: tcomponent; rootancestor: tclass): boolean;
function findancestorcomponent(const areader: treader; 
                 const componentname: string): tcomponent;
procedure loadmsemodule(const instance: tmsecomponent; const rootancestor: tclass);
function findmoduledata(const aclassname: string; 
                            out aparentclassname: string): pobjectdataty;

function copycomponent(const source: tcomponent; const aowner: tcomponent = nil;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onancestornotfound: tancestornotfoundevent = nil): tcomponent;
                //copy by stream.writecomponent, readcomponent
procedure refreshancestor(const descendent,newancestor,oldancestor: tcomponent;
              const revert: boolean;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onfindmethod: tfindmethodevent = nil;
              const sourcemethodtab: pointer = nil;
              const destmethodtab: pointer = nil);
procedure initinline(const acomponent: tcomponent);
                 //sets inline, resets ancestor, sets ancestor of children
procedure checkinline(const acomponent: tcomponent);
                 //resets csancestor of csinline components
procedure initrootdescendent(const acomponent: tcomponent);
                 //clears csinline flags of acomoponent and children,
                 // sets csancestor
function issubcomponent(const root,child: tcomponent): boolean;
function findcomponentbynamepath(const namepath: string): tcomponent;
function getlinkedcomponents(const acomponent: tcomponent): componentarty;
                 //returns items of free notify list


procedure lockfindglobalcomponent;   //switch of findglobalcomponent
procedure unlockfindglobalcomponent; //switch on findglobalcomponent
function findglobalcomponentlocked: boolean;

function getenumnames(const atypeinfo: ptypeinfo): msestringarty;
function getcorbainterface(const aobject: tobject; const aintf: ptypeinfo;
                                                  out obj) : boolean;

function checkcanevent(const acomponent: tcomponent; const event: tmethod): boolean;

procedure readstringar(const reader: treader; out ar: stringarty);
procedure writestringar(const writer: twriter; const ar: stringarty);

function swapmethodtable(const instance: tobject; const newtable: pointer): pointer;
procedure objectbinarytotextmse(input, output: tstream);
                //workaround for FPC bug 7813 with localized float strings

function setloading(const acomponent: tcomponent; const avalue: boolean): boolean;
           //returns old value
type
 skinobjecteventty = procedure(const instance: tobject; 
                                       const ainfo: skininfoty) of object;
var
 oninitskinobject: skinobjecteventty;
 
implementation
uses
{$ifdef debugobjectlink}
 msegui,mseformatstr,
{$else}
 mseapplication,
{$endif}
{$ifdef mswindows}
 windows,
{$endif}
 msestream,msesys,msedatalist,msedatamodules;

type
 {$ifdef FPC}
 TComponentcracker = class(TPersistent)
 private
   FOwner: TComponent;
   FName: TComponentName;
   FTag: Longint;
   FComponents: TList;
   FFreeNotifies: TList;
   FDesignInfo: Longint;
   FVCLComObject: Pointer;
   FComponentState: TComponentState;
 end;
 {$else}
 TComponentcracker = class(TPersistent)
 private
   FOwner: TComponent;
   FName: TComponentName;
   FTag: Longint;
   FComponents: TList;
   FFreeNotifies: TList;
   FDesignInfo: Longint;
   FComponentState: TComponentState;

   FVCLComObject: Pointer;
 end;
 {$endif}
 {$ifdef FPC}
 TFilercracker = class(TObject)
  private
    FRoot: TComponent;
    FLookupRoot: TComponent;
    FAncestor: TPersistent;
    FIgnoreChildren: Boolean;
 end;
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
    FAncestor: TPersistent;
    FIgnoreChildren: Boolean;
  end;
 {$endif}
 
 tpersistent1 = class(tpersistent);
 tcomponent1 = class(tcomponent);

 tobjectdatastream = class(tcustommemorystream)
  public
   constructor create(data: pobjectdataty);
   function Write(const Buffer; Count: Longint): Longint; override;
 end;

 objectdatainfoty = record
  objectclass: tclass;
  objectdata: pobjectdataty;
  langobjectdata: pobjectdataty;
  name: string;
  changed: boolean;
 end;

 pobjectdatainfoty = ^objectdatainfoty;

 tobjectdatainfolist = class(trecordlist)    //todo: hashed or ordered list for speedup
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
  public
   constructor create;
   function itempo(const index: integer): pobjectdatainfoty;
   procedure add(const value: objectdatainfoty);
   function find(aclass: tclass; aname: string): pobjectdatainfoty; overload;
   function find(aclassname: string; aname: string): pobjectdatainfoty; overload;
   procedure resetchanged;
   procedure reloadchanged;
 end;
 
 tloadedlist = class(tcomponent)
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
 end;

var
 objectdatalist: tobjectdatainfolist;
 fmodules: tmodulelist;
 floadedlist: tloadedlist;
 fmodulestoregister: msecomponentarty;

function modules: tmodulelist;
begin
 if fmodules = nil then begin
  fmodules:= tmodulelist.create(false);
 end;
 result:= fmodules;
end;

function setloading(const acomponent: tcomponent; const avalue: boolean): boolean;
begin
 result:= csdesigning in acomponent.componentstate;
 with tcomponentcracker(acomponent) do begin
  if avalue then begin
   include(fcomponentstate,csloading);
  end
  else begin
   exclude(fcomponentstate,csloading);
  end;
 end;
end;
                    
procedure clearinline(const acomponent: tcomponent);
var
 int1: integer;
begin
 tmsecomponent(acomponent).setinline(false);
 for int1:= 0 to acomponent.componentcount - 1 do begin
  clearinline(acomponent.components[int1]);
 end;
end;

procedure initinline(const acomponent: tcomponent);
                 //sets inline, resets ancestor, sets ancestor of children
var
 int1: integer;
begin
 with tcomponentcracker(acomponent) do begin
  exclude(fcomponentstate,csancestor);
  include(fcomponentstate,csinline);   
 end; 
 for int1:= 0 to acomponent.componentcount - 1 do begin
  tcomponent1(acomponent.components[int1]).setancestor(true);
 end;
end;

procedure checkinline(const acomponent: tcomponent);
var
 int1: integer;
 comp1: tcomponent1;
begin
 if csinline in acomponent.componentstate then begin
  with tcomponentcracker(acomponent) do begin
   exclude(fcomponentstate,csancestor);
  end;
  for int1:= 0 to acomponent.componentcount - 1 do begin
   comp1:= tcomponent1(acomponent.components[int1]);
   comp1.setancestor(true);
   clearinline(comp1);
  end;
 end
 else begin
  for int1:= 0 to acomponent.componentcount - 1 do begin
   checkinline(acomponent.components[int1]);
  end;
 end;
end;

procedure initrootdescendent(const acomponent: tcomponent);
begin
 clearinline(acomponent);
 tcomponent1(acomponent).setancestor(true);
end;

function swapmethodtable(const instance: tobject; const newtable: pointer): pointer;		
var
 {$ifdef mswindows}
 ca1: cardinal;
 {$endif}
 methodtabpo: ppointer;
begin
 methodtabpo:= ppointer(pchar(instance.classtype)+vmtmethodtable);
 {$ifdef mswindows}
 virtualprotect(methodtabpo,sizeof(pointer),page_readwrite,{$ifdef FPC}@{$endif}ca1);
 {$endif}
 result:= methodtabpo^;
 methodtabpo^:= newtable;
 {$ifdef mswindows}
 virtualprotect(methodtabpo,sizeof(pointer),ca1,nil);
 {$endif}
end;

procedure objectbinarytotextmse(input, output: tstream);
                //workaround for FPC bug with localized float strings
{$ifdef FPC}
var
 ch1: char;
{$endif}
begin
 {$ifdef FPC}
 ch1:= decimalseparator;
 decimalseparator:= '.';
 try
  objectbinarytotext(input,output);
 finally
  decimalseparator:= ch1;
 end;  
 {$else}
  objectbinarytotext(input,output);
 {$endif}
end;

function checkcanevent(const acomponent: tcomponent; const event: tmethod): boolean;
begin
 result:= (event.code <> nil) and (acomponent <> nil) and (event.data <> nil) and
            (acomponent.componentstate * [csloading,csdesigning,csdestroying] = []);
end;

procedure writestringar(const writer: twriter; const ar: stringarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 for int1:= 0 to high(ar) do begin
  writer.writestring(ar[int1]);
 end;
 writer.writelistend;
end;

procedure readstringar(const reader: treader; out ar: stringarty);
var
 int1: integer;
begin
 int1:= 0;
 ar:= nil;
 reader.readlistbegin;
 while not reader.endoflist do begin
  additem(ar,reader.readstring,int1);
 end;
 reader.readlistend;
 setlength(ar,int1);
end;

procedure lockfindglobalcomponent;   //switch of findglobalcomponent
begin
 modules.lock;
end;

procedure unlockfindglobalcomponent; //switch on findglobalcomponent
begin
 modules.unlock;
end;

function findglobalcomponentlocked: boolean;
begin
 result:= modules.flocked <> 0;
end;

function ownernamepath(const acomponent: tcomponent): string;
var
 comp: tcomponent;
begin
 with acomponent do begin
  result:= name;
  comp:= owner;
  while comp <> nil do begin
   if comp.Name <> '' then begin
    result:= comp.Name + '.' + result;
   end;
   comp:= comp.Owner;
  end;
 end;
end;

function rootcomponent(const acomponent: tcomponent): tcomponent;
begin
 result:= acomponent;
 while result.owner <> nil do begin
  result:= result.owner;
 end;
end;

procedure setcomponentorder(const owner: tcomponent; const anames: msestringarty);
var
 comp1: tcomponent;
 int1: integer;
begin
 for int1:= 0 to high(anames) do begin
  comp1:= owner.findcomponent(anames[int1]);
  with tcomponentcracker(owner).fcomponents do begin
   remove(comp1);
   add(comp1);
  end;
 end; 
end;

function getlinkedcomponents(const acomponent: tcomponent): componentarty;
var
 int1: integer;
begin
 result:= nil;
 with tcomponentcracker(acomponent) do begin
  if ffreenotifies <> nil then begin
   for int1:= 0 to ffreenotifies.count - 1 do begin
    additem(pointerarty(result),ffreenotifies[int1]);
   end;
  end;
 end;
end;

function getpropinfoar(const atypeinfo: ptypeinfo): propinfopoarty;
var
 po1: ptypedata;
begin
 po1:= gettypedata(atypeinfo);
 setlength(result,po1^.PropCount);
 getpropinfos(atypeinfo,pointer(result));
end;

function getpropinfoar(const obj: tobject): propinfopoarty;
begin
 if obj <> nil then begin
  result:= getpropinfoar(obj.classinfo);
 end
 else begin
  result:= nil;
 end;
end;

function getenumnames(const atypeinfo: ptypeinfo): msestringarty;
var
 typedata1: ptypedata;
 int1{,int2}: integer;
begin
 typedata1:= gettypedata(atypeinfo);
 with typedata1^ do begin
  setlength(result,maxvalue-minvalue+1);
  for int1:= 0 to high(result) do begin
   result[int1]:= getenumname(atypeinfo,int1);
  end;
  {
  int2:= 0;
  for int1:= MinValue to MaxValue do begin
   result[int2]:= getenumname(atypeinfo,int1);
   inc(int2);
  end;
  }
 end;
end;

function copycomponent(const source: tcomponent; const aowner: tcomponent = nil;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onancestornotfound: tancestornotfoundevent = nil): tcomponent;
                //copy by stream.writecomponent, readcomponent
var
 stream: tmemorystream;
 writer: twriter;
 reader: treader;
 {$ifdef mse_debugcopycomponent}
 debugstream: ttextstream;
 {$endif}
begin
 result:= tcomponent(source.NewInstance);
 try
  if csdesigning in source.componentstate then begin
   tcomponent1(result).setdesigning(true);
//   result.name:= source.name;
  end;
  result.Create(aowner);
  stream:= tmemorystream.Create;
  try
   writer:= twriter.Create(stream,4096);
   try
    writer.OnFindAncestor:= onfindancestor;
    writer.Writerootcomponent(source);
   finally
    writer.Free;
   end;
   stream.Position:= 0;
   reader:= treader.Create(stream,4096);
   try
    reader.OnFindComponentClass:= onfindcomponentclass;
    reader.OnCreateComponent:= oncreatecomponent;
    reader.onancestornotfound:= onancestornotfound;
//    reader.ancestor:= aancestor;
    reader.ReadrootComponent(result);
   finally
    reader.free;
   end;
 {$ifdef mse_debugcopycomponent}
   debugstream:= ttextstream.create;
   stream.position:= 0;
   objectbinarytotext(stream,debugstream);
   debugstream.position:= 0;
   writeln(output,'copycomponent source');
   debugstream.writetotext(output);
   stream.clear;
   writer:= twriter.Create(stream,4096);
   writer.Writerootcomponent(result);
   writer.Free;
   stream.position:= 0;
   debugstream.clear;
   objectbinarytotext(stream,debugstream);
   debugstream.position:= 0;
   writeln(output,'copycomponent dest');
   debugstream.writetotext(output);
   flush(output);
   debugstream.free;
 {$endif}
  finally
   stream.Free;
  end;
 except
  result.free;
  raise;
 end;
 if source is tmsecomponent then begin
  tmsecomponent(result).factualclassname:= tmsecomponent(source).factualclassname;
 end;
end;

const
 skipmark = 'h71%z/ur';
 
type 
 trefresheventhandler = class(tcomponent)
  private
   fcomponentar: componentarty;
   procedure onsetname(reader: treader; component: tcomponent; var aname: string);
   procedure onerror(reader: treader; const message: string; var handled: boolean);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation);
                               override;        
  public
   destructor destroy; override;
 end;

 trefreshexception = class(exception)
 end;
  
destructor trefresheventhandler.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fcomponentar) do begin
  fcomponentar[int1].free; //FPC does not free the component
 end;
 inherited;
end;

procedure trefresheventhandler.notification(acomponent: tcomponent; operation: toperation);
begin
 if (operation = opremove) then begin
  removeitem(pointerarty(fcomponentar),acomponent);
 end;
 inherited;
end;

procedure trefresheventhandler.onerror(reader: treader; const message: string;
                        var handled: boolean);
begin
 if message = skipmark then begin
  handled:= true;
 end;
end;

procedure trefresheventhandler.onsetname(reader: treader; 
                                    component: tcomponent; var aname: string);
begin
 if (component.owner <> nil) and (csinline in component.owner.componentstate) and
        not(csancestor in component.componentstate) then begin
  additem(pointerarty(fcomponentar),component);
  component.freenotification(self);
  raise trefreshexception.create(skipmark);
 end;
end;


procedure refreshancestor(const descendent,newancestor,oldancestor: tcomponent;
              const revert: boolean; 
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onfindmethod: tfindmethodevent = nil;
              const sourcemethodtab: pointer = nil;
              const destmethodtab: pointer = nil);
var
 stream1,stream2: tmemorystream;
 writer: twriter;
 reader: treader;
// comp1: tcomponent;
 comp2: tcomponent;
 int1: integer;
 eventhandler: trefresheventhandler;
 inl,anc: boolean;
 tabbefore: pointer;
 {$ifdef mse_debugrefresh}
 stream3: ttextstream;
 {$endif}
begin
 {$ifdef mse_debugrefresh}
  writeln('descendent: '+ descendent.name + ' newancestor: '+
         newancestor.name + ' oldancestor: '+oldancestor.name);
 stream3:= ttextstream.create;
 {$endif}
 eventhandler:= trefresheventhandler.create(nil);
 stream1:= tmemorystream.Create;
 stream2:= tmemorystream.Create;
 try
  writer:= twriter.Create(stream1,4096);
  tabbefore:= nil; //compiler warning
  if destmethodtab <> nil then begin
   tabbefore:= swapmethodtable(descendent,destmethodtab);
  end;
  try
   writer.OnFindAncestor:= onfindancestor;
   writer.WriteDescendent(descendent,oldancestor); //changes from oldancestor
  finally
   if destmethodtab <> nil then begin
    swapmethodtable(descendent,tabbefore);
   end;
   writer.Free;
  end;
 {$ifdef mse_debugrefresh}
   stream1.position:= 0;
   objectbinarytotextmse(stream1,stream3);
   stream3.position:= 0;
   writeln('changes oldancestor->descendent');
   stream3.writetotext(output);
 {$endif}
  writer:= twriter.Create(stream2,4096);
  inl:= csinline in newancestor.componentstate;
  anc:= csancestor in newancestor.componentstate;
  if csinline in descendent.componentstate then begin
   tmsecomponent(newancestor).SetInline(true);
  end;
  tcomponent1(newancestor).SetAncestor(true);
  if sourcemethodtab <> nil then begin
   tabbefore:= swapmethodtable(newancestor,sourcemethodtab);
  end;
  try
   writer.OnFindAncestor:= onfindancestor;
   {
   writer.root:= newancestor;
   writer.ancestor:= descendent;
   writer.rootancestor:= newancestor;
   if descendent.owner <> nil then begin
    twritercracker(writer).flookuproot:= descendent.owner; 
   end
   else begin
    writer.lookuproot:= descendent; 
   end;
   writer.writecomponent(newancestor);
   }
   writer.WriteDescendent(newancestor,descendent); //new state
  finally
   tmsecomponent(newancestor).SetInline(inl);
   tcomponent1(newancestor).SetAncestor(anc);
   if sourcemethodtab <> nil then begin
    swapmethodtable(newancestor,tabbefore);
   end;
   writer.Free;
  end;
 {$ifdef mse_debugrefresh}
   stream2.position:= 0;
   stream3.setsize(0);
   objectbinarytotextmse(stream2,stream3);
   stream3.position:= 0;
   writeln('changes descendent->newancestor');
   stream3.writetotext(output);
 {$endif}
  stream1.Position:= 0;
  stream2.Position:= 0;
  reader:= treader.create(stream2,4096);  //new state
  if destmethodtab <> nil then begin
   tabbefore:= swapmethodtable(descendent,destmethodtab);
  end;
  try
   reader.OnFindComponentClass:= onfindcomponentclass;
   reader.OnCreateComponent:= oncreatecomponent;
   reader.onfindmethod:= onfindmethod;
   reader.ReadRootComponent(descendent);
  finally
   if destmethodtab <> nil then begin
    swapmethodtable(descendent,tabbefore);
   end;
   reader.free;
  end;
  if not revert then begin
   reader:= treader.create(stream1,4096);  //restore old changes
   if destmethodtab <> nil then begin
    tabbefore:= swapmethodtable(descendent,destmethodtab);
   end;
   try
    reader.OnFindComponentClass:= onfindcomponentclass;
    reader.OnCreateComponent:= oncreatecomponent;
    reader.onfindmethod:= onfindmethod;
    reader.onsetname:= {$ifdef FPC}@{$endif}eventhandler.onsetname;
    reader.onerror:= {$ifdef FPC}@{$endif}eventhandler.onerror;
    reader.ReadRootComponent(descendent);
    for int1:= descendent.componentcount - 1 downto 0 do begin
     comp2:= descendent.components[int1];
     if not (cssubcomponent in comp2.componentstyle) and 
                   (newancestor.findcomponent(comp2.name) = nil) then begin
      comp2.free;     //remove deleted components
     end;
    end;
   finally
    if destmethodtab <> nil then begin
     swapmethodtable(descendent,tabbefore);
    end;
    reader.free;
   end;
  end;
 finally
  stream1.Free;
  stream2.Free;
  {$ifdef mse_debugrefresh}
  stream3.free;
  {$endif}
  eventhandler.free;
 end;
end;

function issubcomponent(const root,child: tcomponent): boolean;
var
 comp: tcomponent;
begin
 result:= false;
 comp:= child.Owner;
 while comp <> nil do begin
  if comp = root then begin
   result:= true;
   break;
  end;
  comp:= comp.Owner;
 end;
end;

procedure createmodule(aowner: tcomponent; instanceclass: msecomponentclassty;
                                    var reference);
var
 instance: tmsecomponent;
begin
 instance := tmsecomponent(instanceclass.newinstance);
 additem(pointerarty(fmodulestoregister),instance);
// fmodules.add(instance); //not before completely loaded, 
                        //submodules call globalfixupreferences
 tmsecomponent(reference):= instance;
 try
  instance.create(aowner);
 except
  tcomponent(reference) := nil;
  raise;
 end;
end;

type
{$ifdef FPC}
 tasinheritedobjectreader = class(tbinaryobjectreader)
  protected
   procedure begincomponent(var flags: tfilerflags; var achildpos: Integer;
      var compclassName, compname: string); override;
 end;

 tasinheritedreader = class(treader)
  protected
   function createdriver(stream: tstream; bufsize: integer): tabstractobjectreader; override;
 end;

procedure tasinheritedobjectreader.begincomponent(var flags: tfilerflags;
        var achildpos: Integer; var compclassName, compname: string);
begin
 inherited;
 include(flags,ffinherited);
end;

function tasinheritedreader.createdriver(stream: tstream;
                   bufsize: integer): tabstractobjectreader;
begin
 result:= tasinheritedobjectreader.create(stream, bufsize);
end;

{$else}
 tasinheritedreader = class(treader)
  public
   procedure readprefix(var flags: tfilerflags; var achildpos: integer); override;
 end;

procedure tasinheritedreader.readprefix(var flags: tfilerflags; var achildpos: integer);
begin
 inherited;
 include(flags,ffinherited);
end;

{$endif}

function findmoduledata(const aclassname: string; 
                  out aparentclassname: string): pobjectdataty;
var
 po1: pobjectdatainfoty;
begin
 result:= nil;
 aparentclassname:= '';
 po1:= objectdatalist.find(aclassname,'');
 if po1 <> nil then begin
  aparentclassname:= po1^.objectclass.classparent.classname;
  result:= po1^.objectdata;
 end;
end;

procedure loadmodule(const instance: tcomponent;
                        const po1: pobjectdatainfoty; asinherited: boolean);
var
 stream: tobjectdatastream;
 reader: treader;
 po2: pobjectdataty;
// intf: iobjectlink;
begin
 po2:= po1^.langobjectdata;
 if po2 = nil then begin
  po2:= po1^.objectdata;
 end;
 stream:= tobjectdatastream.create(po2);
 try
  globalnamespace.beginwrite;
  if asinherited then begin
   reader := tasinheritedreader.create(stream, 4096);
  end
  else begin
   reader := treader.create(stream, 4096);
  end;
  try
  {
   if fmodules <> nil then begin
//      reader.onfindmethod:= fmodules.findmethod;
       //does not work because method.data is not writable
   end;
   }
   reader.onancestornotfound:= {$ifdef FPC}@{$endif}modules.ancestornotfound;
   reader.readrootcomponent(instance);
  finally
    reader.free;
  end;
 finally
  globalnamespace.endwrite;
  stream.free;
 end;
 if floadedlist = nil then begin
  floadedlist:= tloadedlist.create(nil);
 end;
 instance.freenotification(floadedlist);
end;

var
 moduleloadlevel: integer;
 
function initmsecomponent(instance: tcomponent; rootancestor: tclass): boolean;
var
 loadingstarted: boolean;
 rootancestor1: tclass;
 
 procedure doload(const aclass: tclass);
 var
  po1: pobjectdatainfoty;
 begin
  if (aclass <> rootancestor1) and (aclass <> tcomponent) then begin
   doload(aclass.classparent);
   po1:= objectdatalist.find(aclass,instance.name);
   if (po1 = nil) and (rootancestor <> nil) then begin
    po1:= objectdatalist.find(aclass,'');
   end; 
   if (po1 <> nil) then begin
    if not loadingstarted then begin
     loadingstarted:= true;    
     inc(moduleloadlevel);
     if moduleloadlevel = 1 then begin
      begingloballoading;
     end;
    end;
    loadmodule(instance,po1,false);
   end;     
  end;
 end;
 
begin
 if objectdatalist <> nil then begin
  if (rootancestor = nil) then begin
   rootancestor1:= instance.classtype.classparent;
  end
  else begin
   rootancestor1:= rootancestor;
  end;
  loadingstarted:= false;
  try
   doload(instance.classtype);
   if finditem(pointerarty(fmodulestoregister),instance) >= 0 then begin
    modules.add(tmsecomponent(instance));
    globalfixupreferences;
   end;
   if loadingstarted and (moduleloadlevel = 1) then begin
    moduleloadlevel:= 0;  //allow loading of forms in loaded procedure
    notifygloballoading;
   end;
  finally
   if loadingstarted then begin
    if moduleloadlevel > 0 then begin
     dec(moduleloadlevel);
    end;
    if moduleloadlevel = 0 then begin
     endgloballoading;
    end;
   end;
   removeitem(pointerarty(fmodulestoregister),instance);
  end;
  result:= loadingstarted;
 end
 else begin
  result:= false;
 end;
end;

procedure reloadmsecomponent(Instance: tmsecomponent);
var
 po1: pobjectdatainfoty;

begin
 po1:= objectdatalist.find(instance.classtype,instance.name);
 if po1 = nil then begin
  po1:= objectdatalist.find(instance.classtype,'');
 end;
 loadmodule(instance,po1,true);
end;
(*
procedure registerclassproperties(aclass: tclass);
type
  PFieldClassTable = ^TFieldClassTable;
  TFieldClassTable = packed record
    Count: Smallint;
    {$ifdef FPC}
    fClasses: array[0..8191] of TPersistentClass;
    {$else}
    fClasses: array[0..8191] of ^TPersistentClass;
    {$endif}
  end;

{$ifdef FPC}
 pfieldtable = ^tfieldtable;
 TFieldTable = packed record
   FieldCount: Word;
   ClassTable: Pointer;
   { Fields: array[Word] of TFieldInfo;  Elements have variant size! }
 end;

function getfieldclasstable(aclass: tclass): pfieldclasstable;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 result:= pfieldclasstable(PFieldTable((Pointer(aclass) + vmtFieldTable)^)^.classtable);
 {$ifdef FPC} {$checkpointer default} {$endif}
end;
{$else}
function GetFieldClassTable(AClass: TClass): PFieldClassTable; assembler;
asm
        MOV     EAX,[EAX].vmtFieldTable
        OR      EAX,EAX
        JE      @@1
        MOV     EAX,[EAX+2].Integer
@@1:
end;
{$endif}

var
 int1: integer;
 fieldclasstab: pfieldclasstable;

begin
 {$ifdef FPC} {$checkpointer off} {$endif}
  fieldclasstab:= getfieldclasstable(aclass);
  if fieldclasstab <> nil then begin
   with fieldclasstab^ do begin
    for int1:= 0 to count - 1 do begin
     {$ifdef FPC}
     classes.registerclass(fclasses[int1]);
     registerclassproperties(fclasses[int1]);
     {$else}
     classes.registerclass(fclasses[int1]^);
     registerclassproperties(fclasses[int1]^);
     {$endif}
              //register classes of subproperties
    end;
   end;
  end;
end;
*)
procedure loadmsemodule(const instance: tmsecomponent; const rootancestor: tclass);
{
 procedure doregister(aclass: tclass);
 begin
  if (aclass <> rootancestor) and (aclass <> tcomponent) then begin
   doregister(aclass.classparent);
   registerclassproperties(aclass);
  end;
 end;
}
begin
//  doregister(instance.classtype);
  if not initmsecomponent(instance,rootancestor) then begin
   if not initinheritedcomponent(instance,rootancestor) then begin
    mseerror(mse_resnotfound,instance);
   end;
  end;
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

function findancestorcomponent(const areader: treader; 
                 const componentname: string): tcomponent;
var
 comp1: tcomponent;
begin
 result:= nil;
 if csinline in areader.lookuproot.componentstate then begin
  comp1:= areader.lookuproot;      //check added component
  while comp1 <> nil do begin
   result:= comp1.findcomponent(componentname);
   if result <> nil then begin
    break;
   end;
   comp1:= comp1.owner;
  end;
 end;
end;

{ tnotifylist }

procedure tnotifylist.notify(const sender: tobject);
begin
 factitem:= 0;
 while (factitem < fcount) do begin
  notifyeventty(getitempo(factitem)^)(sender);
  inc(factitem);
 end;
end;

 { tmodulelist}
{
procedure tmodulelist.findmethod(Reader: TReader; const MethodName: string;
                       var Address: Pointer; var Error: Boolean);
var                           //does not work because method.data is not writable
 comp1: tcomponent;
 str1: string;
 po1,po2: pchar;
begin
 if error and (methodname <> '') then begin
  po1:= pchar(pointer(methodname));
  po2:= strscan(po1,'.');
  if po2 <> nil then begin
   setstring(str1,po1,po2-po1);
   comp1:= findmodulebyname(str1);
   if comp1 <> nil then begin
    address:= comp1.MethodAddress(copy(methodname,po2-po1+2,bigint))
   end;
   error:= address = nil;
  end;
 end;
end;
}
function tmodulelist.findmodulebyname(const name: string): tcomponent;
var
 int1: integer;
 comp1: tcomponent;
begin
 result:= nil;
 if (self <> nil) and (flocked = 0) then begin
  for int1:= 0 to count - 1 do begin
   comp1:= items[int1];
   if stricomp(pchar(comp1.name),pchar(name)) = 0 then begin
    result:= comp1;
    break;
   end;
  end;
 end;
end;

procedure tmodulelist.ancestornotfound(Reader: TReader;
               const ComponentName: string; ComponentClass: TPersistentClass;
               var Component: TComponent);
begin
 component:= findancestorcomponent(reader,componentname);
end;

procedure tmodulelist.lock;
begin
 inc(flocked);
end;

procedure tmodulelist.unlock;
begin
 dec(flocked);
end;

{ tloadedlist }

procedure tloadedlist.notification(acomponent: tcomponent;
               operation: toperation);
begin
 inherited;
 if operation = opremove then begin
  removefixupreferences(acomponent,'');
 end;
end;

{ tobjectdatastream}

constructor tobjectdatastream.create(data: pobjectdataty);
begin
 inherited create;
 {$ifdef FPC} {$checkpointer off} {$endif}
 setpointer(@data^.data,data^.size);
 {$ifdef FPC} {$checkpointer default} {$endif}
end;

function tobjectdatastream.Write(const Buffer; Count: Integer): Longint;
begin
 result:= 0;
 raise exception.Create('readonly.');
end;

{ tobjectdatainfolist}

constructor tobjectdatainfolist.create;
begin
 inherited create(sizeof(objectdatainfoty),[rels_needsfinalize,rels_needscopy]);
end;

function tobjectdatainfolist.find(aclass: tclass; aname: string): pobjectdatainfoty;
var
 int1: integer;
begin
 aname:= uppercase(aname);
 result:= pobjectdatainfoty(fdata);
 for int1:= 0 to fcount -1 do begin                           
  if (result^.objectclass = aclass) and ((aname = '') or (result^.name = aname)) then begin
   exit;
  end;
  inc(result);
 end;
 result:= nil;
end;

function tobjectdatainfolist.find(aclassname: string; aname: string): pobjectdatainfoty;
var
 int1: integer;
begin
 aname:= uppercase(aname);
 aclassname:= uppercase(aclassname);
 result:= pobjectdatainfoty(fdata);
 for int1:= 0 to fcount -1 do begin                           
  if (stringicomp1(result^.objectclass.classname,aclassname) = 0) and 
                       ((aname = '') or (result^.name = aname)) then begin
   exit;
  end;
  inc(result);
 end;
 result:= nil;
end;


function tobjectdatainfolist.itempo(const index: integer): pobjectdatainfoty;
begin
 result:= pobjectdatainfoty(getitempo(index));
end;

procedure tobjectdatainfolist.add(const value: objectdatainfoty);
begin
 inherited add(value);
end;

procedure tobjectdatainfolist.copyrecord(var item);
begin
 with objectdatainfoty(item) do begin
  reallocstring(name);
 end;
end;

procedure tobjectdatainfolist.finalizerecord(var item);
begin
 finalize(objectdatainfoty(item));
end;

procedure tobjectdatainfolist.resetchanged;
var
 int1: integer;
 po1: pobjectdatainfoty;
begin
 po1:= pobjectdatainfoty(fdata);
 for int1:= 0 to count - 1 do begin
  po1^.changed:= false;
  inc(po1);
 end;
end;

procedure tobjectdatainfolist.reloadchanged;
var
 int1: integer;
 int2: integer;
 po1: pobjectdatainfoty;
 comp1: tmsecomponent;
begin
 if fmodules <> nil then begin
  po1:= pobjectdatainfoty(fdata);
  for int1:= 0 to count - 1 do begin
   if po1^.changed then begin
    for int2:= 0 to fmodules.count - 1 do begin
     comp1:= fmodules[int2];
     with comp1 do begin
      if (classtype = po1^.objectclass) and (po1^.name = '') or 
                (stringicomp1(name,po1^.name) = 0) then begin
       comp1.name:= '';
       loadmodule(comp1,po1,true);
      end;
     end;
    end;
    po1^.changed:= false;
   end;
   inc(po1);
  end;
 end;
end;

procedure registerobjectdata(datapo: pobjectdataty; 
            objectclass: tpersistentclass; name: string = '');
var
 info: objectdatainfoty;
begin
 if objectdatalist = nil then begin
  objectdatalist:= tobjectdatainfolist.create;
 end;
 fillchar(info,sizeof(info),0);
 info.objectclass:= objectclass;
 info.objectdata:= datapo;
 info.name:= uppercase(name);
 objectdatalist.add(info);
 classes.registerclass(objectclass);
end;

procedure registerobjectdata(datapo: pobjectdataty; 
                 const objectclassname: string; const name: string = '');
var
 po1: pobjectdatainfoty;
begin
 if objectdatalist <> nil then begin
  po1:= objectdatalist.find(objectclassname,name);
  if po1 <> nil then begin
   po1^.langobjectdata:= datapo;
   po1^.changed:= true;
  end;
 end;
end;

procedure unregisterobjectdata(const objectclassname: string; const name: string = '');
var
 po1: pobjectdatainfoty;
begin
 if objectdatalist <> nil then begin
  po1:= objectdatalist.find(objectclassname,name);
  if po1 <> nil then begin
   po1^.langobjectdata:= nil;
   po1^.changed:= true;
  end;
 end;
end;

procedure resetchangedmodules;
begin
 if objectdatalist <> nil then begin
  objectdatalist.resetchanged;
 end;
end;

procedure reloadchangedmodules;
begin
 if objectdatalist <> nil then begin
  objectdatalist.reloadchanged;
 end;
end;

procedure getoptionalobject(const componentstate: tcomponentstate;
                       const instance: tobject; createproc: createprocty);
begin
 if (instance = nil) and (csreading in componentstate) then begin
  createproc;
 end;
end;

procedure getoptionalobject(const componentstate: tcomponentstate;
           var instance: tvirtualpersistent; const aclass: virtualpersistentclassty);
begin
 if (instance = nil) and (csreading{csloading} in componentstate) then begin
  instance:= aclass.create;
 end;
end;

procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tpersistent; var instance; createproc: createprocty);
begin
 if value <> nil then begin
  if tpersistent(instance) = nil then begin
   createproc;
  end;
  if not (csdesigning in componentstate) and 
                             (pointer(value) <> pointer(1)) then begin
   tpersistent(instance).assign(value);
  end;
 end
 else begin
  freeandnil(tpersistent(instance));
 end;
end;

procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tvirtualpersistent; var instance;
                  const aclass: virtualpersistentclassty);
begin
 if value <> nil then begin
  if tpersistent(instance) = nil then begin
   tvirtualpersistent(instance):= aclass.create;
  end;
  if not (csdesigning in componentstate) and 
                             (pointer(value) <> pointer(1)) then begin
   tpersistent(instance).assign(value);
  end;
 end
 else begin
  freeandnil(tpersistent(instance));
 end;
end;

procedure setlinkedcomponent(const sender: iobjectlink; const source: tmsecomponent;
                      var instance: tmsecomponent; ainterfacetype: pointer = nil);
begin
 if source <> nil then begin
  sender.link(sender,ievent(source),@instance,ainterfacetype);
 end;
 if instance <> nil then begin
  sender.unlink(sender,ievent(instance),@instance);
 end;
 instance:= source;
end;

procedure createobjectlinker(const owner: iobjectlink; onevent: objectlinkeventty;
                                  var instance: tobjectlinker);
 //sets finstancepo
begin
 if instance = nil then begin
  instance:= tobjectlinker.create(owner,onevent);
  instance.finstancepo:= @instance;
 end;
end;

{ townedpersistent }

constructor townedpersistent.create(aowner: tobject);
begin
 fowner:= aowner;
 inherited create;
end;

{ tobjectlinker }

{$ifdef debugobjectlink}

procedure getdebugtext(owner: tobjectlinker; const source,dest:iobjectlink;
                         valuepo: pointer);

 procedure intftext(aintf: iobjectlink);
 var
  obj1: tobject;
 begin
  if aintf = nil then begin
   write('<nil>');
  end
  else begin
   obj1:= iobjectlink(aintf).getinstance;
   write(hextostr(cardinal(aintf),8) + ' ' + hextostr(cardinal(obj1),8));
   if obj1 <> nil then begin
    write(' '+obj1.classname);
   end;
   if obj1 is tcomponent then begin
    write(' '+tcomponent(obj1).Name);
   end
   else begin
    if obj1 is twindow then begin
     write(' '+twindow(obj1).owner.Name);
    end;
   end
  end;
 end;

begin
 if rels_destroying in owner.fstate then begin
  write('*');
 end
 else begin
  write(' ');
 end;
 write('v:'+ hextostr(cardinal(valuepo),8));
 write(' o:');intftext(iobjectlink(owner.fownerintf));
 write(' s:');intftext(source);
 write(' d:');intftext(dest);
 writeln;
end;
{$endif}

constructor tobjectlinker.create(const owner: iobjectlink; onevent: objectlinkeventty);
begin
{$ifdef debugobjectlink}
 writeln('create o: ' + hextostr(cardinal(owner),8));
{$endif}
 pointer(fownerintf):= pointer(owner);
 fonevent:= onevent;
 inherited create(sizeof(linkinfoty));
end;

destructor tobjectlinker.destroy;
var
 po1: pointer;
 po2: plinkinfoty;
 int1: integer;
 {$ifndef FPC}
 po3: pointer;
 {$endif}
begin
{$ifdef debugobjectlink}
 writeln('destroy o: ' + hextostr(cardinal(fownerintf),8));
{$endif}
 include(fstate,rels_destroying);
 po2:= datapo;
 for int1:= 0 to count - 1 do begin
  with po2^ do begin
   po1:= dest;
   if po1 <> nil then begin
{$ifdef debugobjectlink}
   write('destrev');getdebugtext(self,iobjectlink(source),iobjectlink(dest),valuepo);
{$endif}
    dest:= nil;
    if source = nil then begin
     iobjectlink(po1).objevent(iobjectlink(fownerintf),oe_destroyed);
     if valuepo <> nil then begin
      pobject(valuepo)^:= nil;
     end;
    end
    else begin
     {$ifdef FPC}
     iobjectlink(po1).unlink(iobjectlink(pointer(1)),iobjectlink(source),valuepo);
     {$else}
     po3:= pointer(1);
     iobjectlink(po1).unlink(iobjectlink(po3),iobjectlink(source),valuepo);
     {$endif}
    end;
   end;
  end;
  inc(po2);
 end;
 pointer(fownerintf):= nil;
 inherited;
end;

procedure tobjectlinker.sendevent(event: objecteventty);
var
 int1: integer;
begin
 if event <> oe_destroyed then begin
  inc(fnopack);
  try
   int1:= 0;
   while int1 < count do begin
    with plinkinfoaty(fdata)^[int1] do begin
     if dest <> nil then begin
      iobjectlink(dest).objevent(iobjectlink(fownerintf),event);
     end;
    end;
    inc(int1);
   end;
  finally
   dec(fnopack);
  end;
 end;
end;

procedure tobjectlinker.dopack;
begin
 if (fnopack = 0) and not (rels_destroying in fstate) then begin
  pack;
  if (count = 0) and (finstancepo <> nil) {$ifdef debugobjectlink}
            and not debugon {$endif} then begin
   freeandnil(finstancepo^);
  end;
 end;
end;

procedure tobjectlinker.removelink(var item: linkinfoty; destroyed: boolean);
var
 int1: integer;
 po1: plinkinfoty;
begin
 po1:= plinkinfoty(fdata);
 for int1:= 0 to count - 1 do begin
  with po1^ do begin
   if (dest <> nil) and (dest = item.dest) and
        (destroyed or (valuepo = item.valuepo) and (source = item.source)) then begin
    if (refcount = 0) or destroyed then begin
     dest:= nil;
    end
    else begin
     dec(refcount);
    end;
   end;
  end;
  inc(po1);
 end;
end;

function tobjectlinker.findsource(const item: linkinfoty): integer;
var
 int1: integer;
 po1: plinkinfoty;
begin
 result:= -1;
 po1:= plinkinfoty(fdata);
 for int1:= 0 to fcount - 1 do begin
  with po1^do begin
   if source = item.source then begin
    result:= int1;
    break;
   end;
  end;
  inc(po1);
 end;
end;

procedure tobjectlinker.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                                  ainterfacetype: pointer = nil; once: boolean = false);
var
 info: linkinfoty;
 int1: integer;
 po1: plinkinfoty;
 bo1: boolean;
begin
 if not (rels_destroying in fstate) then begin
{$ifdef debugobjectlink}
  write('link  ');getdebugtext(self,source,dest,valuepo);
{$endif}
  fillchar(info,sizeof(info),0);
  info.source:= pointer(source);
  info.dest:= pointer(dest);
  info.valuepo:= valuepo;
  info.interfacetype:= ainterfacetype;
  if not (once and (findsource(info) >= 0)) then begin
   bo1:= false;
   po1:= datapo;
   for int1:= 0 to count - 1 do begin
    with po1^ do begin
     if (dest = info.dest) and (source = info.source) and
        (valuepo = info.valuepo) and (interfacetype = info.interfacetype) then begin
      inc(refcount);
      bo1:= true;
      break;
     end
    end;
    inc(po1);
   end;
   if not bo1 then begin
    add(info);
   end;
   if source <> nil then begin
    dest.link(nil,source,valuepo,ainterfacetype);
    source.objevent(dest,oe_connect);
   end;
  end;
 end;
end;

procedure tobjectlinker.link(const dest: tmsecomponent; valuepo: pointer = nil;
                ainterfacetype: pointer = nil; once: boolean = false);
begin
 if dest <> nil then begin
  link(iobjectlink(fownerintf),ievent(dest),valuepo,ainterfacetype,once);
 end;
end;

procedure tobjectlinker.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
var
 info: linkinfoty;
begin
{$ifdef debugobjectlink}
  write('unlink');getdebugtext(self,source,dest,valuepo);
{$endif}
 if ptrint(source) = 1 then begin
  info.source:= nil;
 end
 else begin
  info.source:= pointer(source);
 end;
 info.dest:= pointer(dest);
 info.valuepo:= valuepo;
 removelink(info,ptrint(source) = 1);
 if info.source <> nil then begin
  dest.unlink(nil,source,valuepo);
 end;
 dopack;
end;

procedure tobjectlinker.unlink(const dest: tmsecomponent; valuepo: pointer = nil);
begin
 if dest <> nil then begin
  unlink(iobjectlink(fownerintf),ievent(dest),valuepo);
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
                  const source: tlinkedobject; var dest: tlinkedobject);
var
 ba: tlinkedobject;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,iobjectlink(source),@dest);
  end;
  if ba <> nil then begin
   unlink(linkintf,iobjectlink(ba),@dest);
  end;
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
                  const source: tlinkedpersistent; var dest: tlinkedpersistent);
var
 ba: tlinkedpersistent;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,iobjectlink(source),@dest);
  end;
  if ba <> nil then begin
   unlink(linkintf,iobjectlink(ba),@dest);
  end;
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
              const source: tmsecomponent; var dest: tmsecomponent);
var
 ba: tmsecomponent;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,ievent(source),@dest);
  end;
  if ba <> nil then begin
   unlink(linkintf,ievent(ba),@dest);
  end;
 end;
end;

function tobjectlinker.isempty(var item): boolean;
begin
 with linkinfoty(item) do begin
  result:= dest = nil;
 end;
end;

procedure tobjectlinker.objevent(const sender: iobjectlink;
              const event: objecteventty);
var
 info: linkinfoty;
begin
 if event = oe_destroyed then begin
  inc(fnopack); 
  info.dest:= pointer(sender);
  info.valuepo:= nil;
  removelink(info,true);
 end;
 if assigned(fonevent) and not (rels_destroying in fstate) then begin
  fonevent(sender.getinstance,event);
 end;
 if event = oe_destroyed then begin
  dec(fnopack); 
  dopack;
 end;
end;

procedure tobjectlinker.forall(proc: objectlinkprocty; ainterfacetype: pointer);
var
 po1: plinkinfoty;
 int1: integer;
begin
 inc(fnopack);
 try
  for int1:= 0 to fcount - 1 do begin
   po1:= @plinkinfoaty(fdata)^[int1];
   if (po1^.dest <> nil) and (po1^.source = nil) and 
                             (ainterfacetype = po1^.interfacetype) then begin
    proc(po1^);
   end;
  end;
 finally
  dec(fnopack);
 end;
end;

function tobjectlinker.linkedobjects: objectarty;
var
 po1: plinkinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= plinkinfoty(fdata);
 for int1:= 0 to fcount - 1 do begin
  if (po1^.dest <> nil) and (po1^.source = nil) then begin
   additem(pointerarty(result),iobjectlink(po1^.dest).getinstance);
  end;
  inc(po1);
 end;
 removearrayduplicates(pointerarty(result));
end;

{ tlinkedobject }

destructor tlinkedobject.destroy;
begin
 inherited;
 fobjectlinker.free;
end;

function tlinkedobject.getobjectlinker: tobjectlinker;
begin
 createobjectlinker(self,{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 result:= fobjectlinker;
end;

procedure tlinkedobject.objectevent(const sender: tobject; const event: objecteventty);
begin
 //dummy
end;

procedure tlinkedobject.setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tlinkedobject.setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tlinkedobject.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                              ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tlinkedobject.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tlinkedobject.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tlinkedobject.getinstance: tobject;
begin
 result:= self;
end;

{ tnullinterfacedobject }

function tnullinterfacedobject._addref: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject._release: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject.QueryInterface(const IID: TGUID;
  out Obj): HResult; stdcall;
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;

{ tnullinterfacedpersistent }

function tnullinterfacedpersistent._addref: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedpersistent._release: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedpersistent.QueryInterface(const IID: TGUID;
  out Obj): HResult; stdcall;
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;

{ toptionalpersistent }

procedure toptionalpersistent.readdummy(reader: treader);
begin
 reader.readinteger;
end;

procedure toptionalpersistent.writedummy(writer: twriter);
begin
 writer.writeinteger(0);
end;

procedure toptionalpersistent.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('dummy',{$ifdef FPC}@{$endif}readdummy,
             {$ifdef FPC}@{$endif}writedummy,filer.ancestor = nil);
 //to create optional instance
end;

{ tlinkedpersistent }

destructor tlinkedpersistent.destroy;
begin
 inherited;
 fobjectlinker.Free;
end;

function tlinkedpersistent.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tlinkedpersistent.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 //dummy
end;

procedure tlinkedpersistent.setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tlinkedpersistent.setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tlinkedpersistent.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                     ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tlinkedpersistent.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tlinkedpersistent.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tlinkedpersistent.getinstance: tobject;
begin
 result:= self;
end;

{ teventobject }

procedure teventobject.receiveevent(const event: tobjectevent);
begin
 //dummy
end;

{ tcomponentevent }

constructor tcomponentevent.create(const asender: tobject; const atag: integer = 0;
          const callchildren: boolean = true);
begin
 inherited create(ek_component,nil);
 fsender:= asender;
 tag:= atag;
 if callchildren then begin
  state:= [ces_callchildren];
 end;
end;

 { tmsecomponent }

destructor tmsecomponent.destroy;
begin
 inherited;
 fobjectlinker.free;
end;

function tmsecomponent.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(ievent(self),{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tmsecomponent.initnewcomponent(const ascale: real);
begin
 //dummy
end;

function tmsecomponent.checkowned(component: tcomponent): boolean;
begin
 result:= false;
 while component <> nil do begin
  if component = self then begin
   result:= true;
   break;
  end;
  component:= component.Owner;
 end;
end;

function tmsecomponent.checkowner(component: tcomponent): boolean;
var
 comp1: tcomponent;
begin
 result:= false;
 comp1:= self;
 while comp1 <> nil do begin
  if comp1 = component then begin
   result:= true;
   break;
  end;
  comp1:= comp1.Owner;
 end;
end;

function tmsecomponent.rootowner: tcomponent;

begin
 result:= owner;
 if result <> nil then begin
  while result.owner <> nil do begin
   result:= result.Owner;
  end;
 end;
end;

function tmsecomponent.getrootcomponentpath: componentarty;
var
 count: integer;
 comp: tcomponent;
begin
 result:= nil;
 count:= 0;
 comp:= self;
 while comp <> nil do begin
  if length(result) <= count then begin
   setlength(result,length(result)+32);
  end;
  result[count]:= comp;
  inc(count);
  comp:= comp.owner;
 end;
 setlength(result,count);
end;

procedure tmsecomponent.setlinkedvar(const source: tmsecomponent;
                   var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(ievent(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tmsecomponent.setlinkedvar(const source: tlinkedobject;
                   var dest: tlinkedobject; const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(ievent(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tmsecomponent.setlinkedvar(const source: tlinkedpersistent;
                   var dest: tlinkedpersistent; const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(ievent(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

function tmsecomponent.linkcount: integer;
begin
 if fobjectlinker = nil then begin
  result:= 0;
 end
 else begin
  result:= fobjectlinker.count;
 end;
end;

function tmsecomponent.canevent(const event: tmethod): boolean;
begin
 result:= (event.code <> nil) and (event.data <> nil) and
            (componentstate * [csloading,csdesigning,csdestroying] = []);
end;

function tmsecomponent.candestroyevent(const event: tmethod): boolean;
begin
 result:= (event.code <> nil) and (event.data <> nil) and
            (componentstate * [csloading,csdesigning] = []);
end;

procedure tmsecomponent.receiveevent(const event: tobjectevent);
var
 int1: integer;
begin
 case event.kind of
  ek_async: begin
   int1:= tasyncevent(event).tag;
   doasyncevent(int1);
  end;
  ek_component: begin
   sendcomponentevent(event as tcomponentevent,false);
  end;
 end;
end;

procedure tmsecomponent.asyncevent(atag: integer = 0);
begin
 application.postevent(tasyncevent.create(ievent(self),atag));
end;

procedure tmsecomponent.doasyncevent(var atag: integer);
begin
 //dummy
end;

procedure tmsecomponent.postcomponentevent(const event: tcomponentevent);
begin
 event.create(event.kind,ievent(self));
 application.postevent(event);
end;

{$ifdef FPC}
{
procedure tmsecomponent.setsubcomponent(avalue: boolean); //todo remove for 1.99 !!!!!
begin
end;
}
{
function tmsecomponent._addref: integer; stdcall;
begin
 result:= -1;
end;

function tmsecomponent._release: integer; stdcall;
begin
 result:= -1;
end;

function tmsecomponent.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);//hresult(e_nointerface);
 end;
end;
}
procedure tmsecomponent.setinline(value: boolean);
begin
 with tcomponentcracker(self) do begin
  if value then begin
   include(fcomponentstate,csinline);
  end
  else begin
   exclude(fcomponentstate,csinline);
  end;
 end;
end;

procedure tmsecomponent.setancestor(value: boolean);
begin
 inherited setancestor(value);
end;

{$endif FPC}

function getcorbainterface(const aobject: tobject; const aintf: ptypeinfo;
                                   out obj) : boolean;
var
 intf1: pinterfaceentry;
 typedata1: ptypedata;
begin
// result:= getinterface(aintf,obj);
 typedata1:= gettypedata(aintf);
 {$ifdef FPC}
 intf1:= aobject.getinterfaceentrybystr(pshortstring(
        ptruint(@typedata1^.rawintfunit)+length(typedata1^.rawintfunit)+1)^);
 {$else}
 intf1:= aobject.getinterfaceentry(typedata1^.guid);
 {$endif}
 if intf1 <> nil then begin
  {$ifdef FPC}
  pointer(obj):= pointer(aobject) + intf1^.ioffset;
  {$else}
  pointer(obj):= pointer(integer(aobject) + intf1^.ioffset);
  {$endif}
  result:= true;
 end
 else begin
  pointer(obj):= nil;
  result:= false;
 end;
end;

//function tmsecomponent.getcorbainterface(const aintf: tguid; out obj) : boolean;
function tmsecomponent.getcorbainterface(const aintf: ptypeinfo; out obj) : boolean;
begin
 result:= mseclasses.getcorbainterface(self,aintf,obj);
end;

procedure tmsecomponent.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tmsecomponent.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tmsecomponent.objevent(const sender: iobjectlink;
                 const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tmsecomponent.getinstance: tobject;
begin
 result:= self;
end;

procedure tmsecomponent.componentevent(const event: tcomponentevent);
var
 int1: integer;
 comp1: tcomponent;
begin
 with event do begin
  if ces_callchildren in state then begin
   for int1:= 0 to componentcount - 1 do begin
    if ces_processed in state then begin
     break;
    end;
    comp1:= components[int1];
    if comp1 is tmsecomponent then begin
     tmsecomponent(comp1).componentevent(event);
    end;
   end;
  end;
 end;
end;

procedure tmsecomponent.sendcomponentevent(const event: tcomponentevent;
                         const destroyevent: boolean);
begin
 try
  componentevent(event);
 finally
  if destroyevent then begin
   event.Free1;
  end;
 end;
end;

procedure tmsecomponent.sendrootcomponentevent(const event: tcomponentevent;
                              const destroyevent: boolean);
var
 int1: integer;
 ar1: componentarty;
begin
 try
  ar1:= getrootcomponentpath;
  for int1:= high(ar1) downto 0 do begin
   if ar1[int1] is tmsecomponent then begin
    tmsecomponent(ar1[int1]).sendcomponentevent(event,false);
    break;
   end;
  end;
 finally
  if destroyevent then begin
   event.Free1;
  end;
 end;
end;

procedure tmsecomponent.getoptionalobject(const instance: tobject; 
                               createproc: createprocty);
begin
 if not (cs_endreadproc in fmsecomponentstate) then begin
  mseclasses.getoptionalobject(componentstate,instance,createproc);
 end;
end;

procedure tmsecomponent.setoptionalobject(const value: tpersistent; 
              var instance; createproc: createprocty);
begin
 mseclasses.setoptionalobject(componentstate,value,instance,createproc);
end;

procedure tmsecomponent.loaded;
begin
{
 if cs_hasskin in fmsecomponentstate then begin
  updateskin;
 end;
 }
 inherited;
 include(fmsecomponentstate,cs_loadedproc);
 try
  sendchangeevent;
 finally
  exclude(fmsecomponentstate,cs_loadedproc);
 end;
end;

procedure tmsecomponent.beginread;
var
 int1: integer;
 comp1: tcomponent;
begin
 for int1:= 0 to componentcount - 1 do begin
  comp1:= components[int1];
  if (cssubcomponent in comp1.componentstyle) and 
            (comp1 is tmsecomponent) then begin
   tmsecomponent(comp1).beginread;
  end;
 end;
end;

procedure tmsecomponent.endread;
var
 int1: integer;
 comp1: tcomponent;
begin
 include(fmsecomponentstate,cs_endreadproc);
 try
  doendread;
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if (cssubcomponent in comp1.componentstyle) and 
             (comp1 is tmsecomponent) then begin
    tmsecomponent(comp1).endread;
   end;
  end;
 finally
  exclude(fmsecomponentstate,cs_endreadproc);
 end;  
end;

procedure tmsecomponent.readstate(reader: treader);
begin
 beginread;
 inherited;
 endread;
end;

procedure tmsecomponent.objectevent(const sender: tobject;
         const event: objecteventty);
begin
 //dummy
end;

procedure tmsecomponent.sendchangeevent(const aevent: objecteventty = oe_changed);
begin
 if (fobjectlinker <> nil) and not (csloading in componentstate) then begin
  fobjectlinker.sendevent(aevent);
 end;
end;

procedure tmsecomponent.designselected(const selected: boolean);
begin
 //dummy
end;

procedure tmsecomponent.readmoduleclassname(reader: treader);
begin
 reader.ReadString; //dummy
end;

procedure tmsecomponent.writemoduleclassname(writer: twriter);
begin
 if fancestorclassname <> '' then begin
  writer.writestring(fancestorclassname);
 end
 else begin
  writer.writestring(getmoduleclassname);
 end;
end;

procedure tmsecomponent.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty(moduleclassnamename,
           {$ifdef FPC}@{$endif}readmoduleclassname,
           {$ifdef FPC}@{$endif}writemoduleclassname,
                  (cs_ismodule in fmsecomponentstate) and (filer.Root = self));
end;

function tmsecomponent.getactualclassname: string;
begin
 if factualclassname <> nil then begin
  result:= factualclassname^;
 end
 else begin
  result:= classname;
 end;
end;

class function tmsecomponent.getmoduleclassname: string;
begin
 result:= tmsecomponent.classname;
end;

function setclassname(const instance: tobject;
                   const aclassname: pshortstring): pshortstring;
var
 classnamepo: ppointer;
 {$ifdef mswindows}
 ca1: cardinal;
 {$endif}
begin
 if aclassname = nil then begin
  result:= nil;
 end
 else begin
  classnamepo:= ppointer(pchar(instance.classtype)+vmtclassname);
  {$ifdef mswindows}
  virtualprotect(classnamepo,sizeof(pointer),page_readwrite,{$ifdef FPC}@{$endif}ca1);
  {$endif}
  result:= classnamepo^;
  classnamepo^:= aclassname;
  {$ifdef mswindows}
  virtualprotect(classnamepo,sizeof(pointer),ca1,nil);
  {$endif}
 end;
end;

procedure tmsecomponent.writestate(writer: twriter);
var
 classnamebefore: pshortstring;
begin
 classnamebefore:= setclassname(self,factualclassname);
 try
  inherited;
 finally
  setclassname(self,classnamebefore);
 end;
end;

function tmsecomponent.gethelpcontext: msestring;
begin
 result:= fhelpcontext;
end;

class function tmsecomponent.classskininfo: skininfoty;
begin
 fillchar(result,sizeof(result),0);
 result.objectkind:= sok_component;
end;

function tmsecomponent.skininfo: skininfoty;
begin
 result:= classskininfo;
end;

function tmsecomponent.linkedobjects: objectarty;
begin
 result:= objectarty(getlinkedcomponents(self));
 if fobjectlinker <> nil then begin
  stackarray(pointerarty(fobjectlinker.linkedobjects),pointerarty(result));
 end;
 removearrayduplicates(pointerarty(result));
end;

function tmsecomponent.loading: boolean;
begin
 result:= csloading in componentstate;
end;

procedure tmsecomponent.doendread;
begin
 //dummy
end;

procedure tmsecomponent.doafterload;
begin
 //dummy
end;

procedure tmsecomponent.updateskin(const recursive: boolean = false);
var
 int1: integer;
 comp1: tcomponent;
begin
 if assigned(oninitskinobject) and 
                (componentstate*[csdesigning] = []) then begin
  if recursive then begin
   for int1:= 0 to componentcount - 1 do begin
    comp1:= components[int1];
    if comp1 is tmsecomponent then begin
     tmsecomponent(comp1).updateskin(true);
    end;
   end;
  end;
//  include(fmsecomponentstate,cs_updateskinproc);
//  try
   if hasskin{not (cs_noskin in fmsecomponentstate)} then begin
    if assigned(fonbeforeupdateskin) then begin
     fonbeforeupdateskin(tobject(tmethod(oninitskinobject).data));
    end;
    oninitskinobject(self,skininfo);
    if assigned(fonbeforeupdateskin) then begin
     fonafterupdateskin(tobject(tmethod(oninitskinobject).data));
    end;   
   end;
//  finally
//   exclude(fmsecomponentstate,cs_updateskinproc);
//  end;
 end;
end;

function tmsecomponent.getmsecomponentstate: msecomponentstatesty;
begin
 result:= fmsecomponentstate;
end;

function tmsecomponent.hasskin: boolean;
begin
 result:= true;
end;

procedure tmsecomponent.validaterename(acomponent: tcomponent;
               const curname: string; const newname: string);
begin
 inherited;
 if componentstate * [csdesigning,csreading,csloading,csdestroying] = 
                                                    [csdesigning] then begin
  if acomponent = nil then begin
   acomponent:= self;
  end;
  designvalidaterename(acomponent,curname,newname);
 end;
end;

{$ifdef mse_with_ifi}
procedure tmsecomponent.executeificommand(var acommand: ificommandcodety);
begin
 //dummy
end;
{$endif}

{ tlinkedqueue }

constructor tlinkedqueue.create(aownsobjects: boolean);
begin
 fownsobjects:= aownsobjects;
 fobjectlinker:= tobjectlinker.create(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent);
 inherited create;
end;

destructor tlinkedqueue.destroy;
begin
 include(fobjectlinker.fstate,rels_destroying);
 inherited;
 freeandnil(fobjectlinker);
end;

function tlinkedqueue.destroying: boolean;
begin
 result:= (fobjectlinker = nil) or (rels_destroying in fobjectlinker.fstate);
end;

function tlinkedqueue.add(const value: iobjectlink): integer;
begin
 result:= inherited add(pointer(value));
 fobjectlinker.link(iobjectlink(self),value);
end;

function tlinkedqueue.getfirst: iobjectlink;
begin
 result:= iobjectlink(inherited getfirst);
 fobjectlinker.unlink(iobjectlink(self),result);
end;

function tlinkedqueue.getlast: iobjectlink;
begin
 result:= iobjectlink(inherited getlast);
 fobjectlinker.unlink(iobjectlink(self),result);
end;

function tlinkedqueue.getitems(const index: integer): iobjectlink;
begin
 result:= iobjectlink(inherited getitems(index));
end;

procedure tlinkedqueue.insert(const index: integer;
  const value: iobjectlink);
begin
 inherited insert(index,pointer(value));
 fobjectlinker.link(iobjectlink(self),value);
end;

procedure tlinkedqueue.setitems(const index: integer;
  const Value: iobjectlink);
begin
 fobjectlinker.unlink(iobjectlink(self),getitems(index));
 inherited setitems(index,pointer(value));
 fobjectlinker.link(iobjectlink(self),value);
end;

procedure tlinkedqueue.objectevent(const sender: tobject;
  const event: objecteventty);
begin
// if event = oe_destroyed then begin
//  remove(sender);
// end;
end;

procedure tlinkedqueue.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 fobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tlinkedqueue.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 fobjectlinker.unlink(source,dest,valuepo);
end;

procedure tlinkedqueue.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 fobjectlinker.objevent(sender,event);
 if event = oe_destroyed then begin
  linkdestroyed(sender);
  inc(fnofinalize);
  try
   remove(pointer(sender));
  finally
   dec(fnofinalize);
  end;
 end;
end;

function tlinkedqueue.getinstance: tobject;
begin
 result:= fainstance;
end;

procedure tlinkedqueue.finalizeitem(var item: pointer);
begin
 fobjectlinker.unlink(iobjectlink(self),iobjectlink(item));
 if fownsobjects then begin
  iobjectlink(item).getinstance.Free;
 end;
 inherited;
end;

procedure tlinkedqueue.sendchangenotification(sender: tobject);
begin
 fainstance:= sender;
 fobjectlinker.sendevent(oe_changed);
 fainstance:= nil;
end;

procedure tlinkedqueue.linkdestroyed(const alink: iobjectlink);
begin
 //dummy
end;

{ tlinkedobjectqueue }

function tlinkedobjectqueue.add(const value: tlinkedobject): integer;
begin
 result:= inherited add(iobjectlink(value));
end;

function tlinkedobjectqueue.getfirst: tlinkedobject;
begin
 result:= tlinkedobject(inherited getfirst.getinstance);
end;

function tlinkedobjectqueue.getlast: tlinkedobject;
begin
 result:= tlinkedobject(inherited getlast.getinstance);
end;

function tlinkedobjectqueue.getitems(const index: integer): tlinkedobject;
begin
 result:= tlinkedobject(inherited getitems(index).getinstance);
end;

procedure tlinkedobjectqueue.insert(const index: integer;
  const value: tlinkedobject);
begin
 inherited insert(index,iobjectlink(value));
end;

procedure tlinkedobjectqueue.setitems(const index: integer;
  const Value: tlinkedobject);
begin
 inherited setitems(index,iobjectlink(value));
end;

function tlinkedobjectqueue.findobject(const aobject: tlinkedobject): integer;
begin
 result:= indexof(pointer(iobjectlink(aobject)));
end;

{ tpersistentqueue }

procedure tpersistentqueue.add(const value: tlinkedpersistent);
begin
 inherited add(iobjectlink(value));
end;

function tpersistentqueue.getfirst: tlinkedpersistent;
begin
 result:= tlinkedpersistent(inherited getfirst.getinstance);
end;

function tpersistentqueue.getlast: tlinkedpersistent;
begin
 result:= tlinkedpersistent(inherited getlast.getinstance);
end;

function tpersistentqueue.getitems(const index: integer): tlinkedpersistent;
begin
 result:= tlinkedpersistent(inherited getitems(index).getinstance);
end;

procedure tpersistentqueue.insert(const index: integer;
                const value: tlinkedpersistent);
begin
 inherited insert(index,iobjectlink(value));
end;

procedure tpersistentqueue.setitems(const index: integer;
                const Value: tlinkedpersistent);
begin
 inherited setitems(index,iobjectlink(value));
end;

function tpersistentqueue.findobject(const aobject: tlinkedpersistent): integer;
begin
 result:= indexof(pointer(iobjectlink(aobject)));
end;

{ tcomponentqueue }

function tcomponentqueue.add(const value: tmsecomponent): integer;
begin
 result:= inherited add(ievent(value));
end;

function tcomponentqueue.getfirst: tmsecomponent;
begin
 result:= tmsecomponent(inherited getfirst.getinstance);
end;

function tcomponentqueue.getlast: tmsecomponent;
begin
 result:= tmsecomponent(inherited getlast.getinstance);
end;

function tcomponentqueue.getitems(const index: integer): tmsecomponent;
begin
 result:= tmsecomponent(inherited getitems(index).getinstance);
end;

procedure tcomponentqueue.insert(const index: integer;
  const value: tmsecomponent);
begin
 inherited insert(index,ievent(value));
end;

procedure tcomponentqueue.setitems(const index: integer;
  const Value: tmsecomponent);
begin
 inherited setitems(index,ievent(value));
end;

function tcomponentqueue.findobject(const aobject: tmsecomponent): integer;
begin
 result:= indexof(pointer(ievent(aobject)));
end;

 { tobjectlinkrecordlist }

constructor tobjectlinkrecordlist.create(recordsize: integer; aoptions: recordliststatesty = []);
begin
 inherited create(recordsize,aoptions+[rels_needsfinalize]);
 fobjectlinker:= tobjectlinker.create(iobjectlink(self),nil);
end;

destructor tobjectlinkrecordlist.destroy;
begin
 inherited;
 fobjectlinker.free;
end;

procedure tobjectlinkrecordlist.finalizerecord(var item);
begin
// if fnounlink = 0 then begin
  dounlink(item)
// end;
end;

function tobjectlinkrecordlist.getinstance: tobject;
begin
 result:= self;
end;

procedure tobjectlinkrecordlist.link(const source, dest: iobjectlink; valuepo,
  ainterfacetype: pointer; once: boolean);
begin
 fobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tobjectlinkrecordlist.objevent(const sender: iobjectlink;
  const event: objecteventty);
begin
 fobjectlinker.objevent(sender,event);
 if event = oe_destroyed then begin
//  inc(fnounlink);
//  try
   itemdestroyed(sender);
//  finally
//   dec(fnounlink);
//  end;
 end;
end;

procedure tobjectlinkrecordlist.unlink(const source, dest: iobjectlink;
  valuepo: pointer);
begin
 fobjectlinker.unlink(source,dest,valuepo);
end;

{ tvirtualpersistent }

constructor tvirtualpersistent.create;
begin
 inherited;
 internalcreate;
end;

procedure tvirtualpersistent.internalcreate;
begin
 //dummy
end;

{ townedeventpersistent }

constructor townedeventpersistent.create(aowner: tobject);
begin
 fowner:= aowner;
 inherited create;
end;

{ teventpersistent }

procedure teventpersistent.receiveevent(const event: tobjectevent);
begin
 //dummy
end;

{ tpersistenttemplate }

constructor tpersistenttemplate.create(const owner: tmsecomponent;
                      const onchange: notifyeventty);
begin
 fowner:= owner;
 fonchange:= onchange;
end;

procedure tpersistenttemplate.changed;
begin
 if assigned(fonchange) and not (csloading in fowner.componentstate) then begin
  fonchange(self);
 end;
end;

procedure tpersistenttemplate.copyinfo(const source: tpersistenttemplate);
begin
 //dummy
end;

procedure tpersistenttemplate.assignto(dest: tpersistent);
begin
 doassignto(dest);
end;

procedure tpersistenttemplate.assign(source: tpersistent);
begin
 if source is classtype then begin
  move(tpersistenttemplate(source).getinfoad^,getinfoad^,getinfosize);
  copyinfo(tpersistenttemplate(source));
  changed;
 end
 else begin
  inherited;
 end;
end;

{ ttemplatecontainer }

constructor ttemplatecontainer.create(aowner: tcomponent);
begin
 ftemplate:= gettemplateclass.create(self,{$ifdef FPC}@{$endif}templatechanged);
 inherited;
end;

destructor ttemplatecontainer.destroy;
begin
 inherited;
 ftemplate.free;
end;

procedure ttemplatecontainer.assignto(dest: tpersistent);
begin
 tpersistent1(ftemplate).assignto(dest);
end;

procedure ttemplatecontainer.templatechanged(const sender: tobject);
begin
 sendchangeevent;
end;

function findmodulebyname(const name: string): tcomponent;
begin
 result:= modules.findmodulebyname(name);
end;

function findcomponentbynamepath(const namepath: string): tcomponent;
var
 ar1: stringarty;
 int1: integer;
begin
 result:= nil;
 ar1:= splitstring(namepath,'.');
 if high(ar1) >= 0 then begin
  result:= modules.findmodulebyname(ar1[0]);
  for int1:= 1 to high(ar1) do begin
   if result = nil then begin
    break;
   end;
   result:= result.FindComponent(ar1[int1]);
  end;
 end;
end;

initialization
{$ifdef FPC}
 registerinitcomponenthandler(tcomponent,@initmsecomponent);
{$endif}
 registerfindglobalcomponentproc({$ifdef FPC}@{$endif}findmodulebyname);
finalization
 freeandnil(fmodules);
 freeandnil(floadedlist);
{$ifdef FPC}
// unregisterinitcomponenthandler(tcomponent,@initmsecomponent);
{$endif}
 unregisterfindglobalcomponentproc({$ifdef FPC}@{$endif}findmodulebyname);
 freeandnil(objectdatalist);
end.
