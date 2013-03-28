{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseclasses;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}
{$ifndef mse_methodswap}
 {$define mse_nomethodswap}
{$endif}

interface
uses
 classes,mclasses,mseglob,mseevent,msetypes,msestrings,sysutils,typinfo,mselist,
 msegraphutils{$ifdef mse_with_ifi},mseifiglob{$endif}
  {$ifndef FPC},classes_del{$endif};

{$if defined(FPC) and (fpc_fullversion >= 020403)}
 {$define mse_fpc_2_4_3}
{$ifend}
{$if defined(FPC) and (fpc_fullversion >= 020400)}
 {$define mse_fpc_2_4}
{$ifend}

{$ifdef FPC}
 {$ifdef mse_FPC_2_4}
  {$define hascorbagetinterface}
 {$endif}
const
 s_ok = 0;
{$endif}

const
{$ifdef linux}
 {$ifdef CPU64}
  platformtext = 'x86_64-linux';
 {$else}
  platformtext = 'i386-linux';
 {$endif}
{$else}
 {$ifdef openbsd}
  {$ifdef CPU64}
  platformtext = 'x86_64-openbsd';
  {$else}
  platformtext = 'i386-openbsd';
  {$endif}
 {$else}
  {$ifdef bsd}
   {$ifdef CPU64}
  platformtext = 'x86_64-bsd';
   {$else}
  platformtext = 'i386-bsd';
   {$endif}
  {$else}
   platformtext = 'i386-win32';
  {$endif}
 {$endif}
{$endif}

 moduleclassnamename = 'moduleclassname';
// inheritedmoduleclassnamename = 'inheritedmoduleclassname';
 compilerdefaults =
     '{$ifdef FPC}{$mode objfpc}{$h+}{$endif}';

type
 posteventoptionty = (peo_local,peo_first,peo_modaldefer);
 posteventoptionsty = set of posteventoptionty;
 
 notifyeventty = procedure (const sender: tobject) of object;
 componenteventty = procedure (const acomponent: tcomponent) of object;
 checkeventty = function (const sender: tobject): boolean of object;
 accepteventty = procedure (const sender: tobject;
                                var accept: boolean) of object;
 eventeventty = procedure (const sender: tobject;
                              const aevent: tobjectevent) of object;
 asynceventeventty = procedure (const sender: tobject;
                                       var atag: integer) of object;

 booleanchangedeventty = procedure (const sender: tobject;
                            const avalue: boolean) of object;
 stringchangedeventty = procedure (const sender: tobject;
                            const avalue: msestring) of object;
 integerchangedeventty = procedure (const sender: tobject;
                            const avalue: integer) of object;
 realchangedeventty = procedure (const sender: tobject;
                            const avalue: realty) of object;

 getintegereventty = function: integer of object;
 getint64eventty = function: int64 of object;
 getstringareventty = function: stringarty of object;
 
 updatestringeventty = procedure(const sender: tobject; 
                                 var avalue: msestring) of object;
 updateansistringeventty = procedure(const sender: tobject; 
                                 var avalue: ansistring) of object;
 updateintegereventty = procedure(const sender: tobject; 
                                        var avalue: integer) of object;
 updateint64eventty = procedure(const sender: tobject;
                                        var avalue: int64) of object;
 updatebooleaneventty = procedure(const sender: tobject; 
                                        var avalue: boolean) of object;
 updaterealeventty = procedure(const sender: tobject; 
                                        var avalue: real) of object;
 updatedatetimeeventty = procedure(const sender: tobject;
                                        var avalue: tdatetime) of object;
 
 setbooleaneventty = procedure(const sender: tobject; var avalue: boolean;
                          var accept: boolean) of object;
 setstringeventty = procedure(const sender: tobject; var avalue: msestring;
                          var accept: boolean) of object;
 setansistringeventty = procedure(const sender: tobject; var avalue: ansistring;
                          var accept: boolean) of object;
 setintegereventty = procedure(const sender: tobject; var avalue: integer; 
                          var accept: boolean) of object; 
                          //equal parameters as setcoloreventty for tcoloredit!
 setint64eventty = procedure(const sender: tobject; var avalue: int64; 
                          var accept: boolean) of object; 
 setrealeventty = procedure(const sender: tobject; var avalue: realty;
                          var accept: boolean) of object;
 setdatetimeeventty = procedure(const sender: tobject; var avalue: tdatetime;
                          var accept: boolean) of object;

 setbooleanindexeventty = procedure(const sender: tobject; var avalue: boolean;
                          var accept: boolean; const aindex: integer) of object;
 setstringindexeventty = procedure(const sender: tobject; var avalue: msestring;
                          var accept: boolean; const aindex: integer) of object;
 setansistringindexeventty = procedure(const sender: tobject; var avalue: ansistring;
                          var accept: boolean; const aindex: integer) of object;
 setintegerindexeventty = procedure(const sender: tobject; var avalue: integer; 
                          var accept: boolean; const aindex: integer) of object; 
                          //equal parameters as setcoloreventty for tcoloredit!
 setint64indexeventty = procedure(const sender: tobject; var avalue: int64;
                          var accept: boolean; const aindex: integer) of object; 
 setrealindexeventty = procedure(const sender: tobject; var avalue: realty;
                          var accept: boolean; const aindex: integer) of object;
 setdatetimeindexeventty = procedure(const sender: tobject; var avalue: tdatetime;
                          var accept: boolean; const aindex: integer) of object;

 progresseventty =  procedure(const sender: tobject; const avalue: real;
                                               var acancel: boolean) of object;

 persistentarty = array of tpersistent;
 persistentclassty = class of tpersistent;
 
 componentarty = array of tcomponent;
 componentaty = array[0..0] of tcomponent;
 pcomponentaty = ^componentaty;
 
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
 objectlinkintfprocty = procedure(const alink: pointer) of object;
 objectlinkfirstprocty = procedure(const info: linkinfoty;
                                                var handled: boolean) of object;
 objectlinkintffirstprocty = procedure(const alink: pointer;
                                                var handled: boolean) of object;

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
//   function findsource(const item: linkinfoty): integer;
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
   function linkedobjects: objectarty; overload;
   function linkedobjects(const ainterfacetype: pointer): objectarty; overload;

   procedure setlinkedvar(const linkintf: iobjectlink; 
                            const source: iobjectlink; var dest: iobjectlink;
                            const ainterfacetype: pointer = nil); overload;
   procedure setlinkedvar(const linkintf: iobjectlink;
                            const source: tlinkedobject; var dest: tlinkedobject;
                            const ainterfacetype: pointer = nil); overload;
   procedure setlinkedvar(const linkintf: iobjectlink;
                             const source: tlinkedpersistent;
                             var dest: tlinkedpersistent;
                             const ainterfacetype: pointer = nil); overload;
   procedure setlinkedvar(const linkintf: iobjectlink; 
                          const source: tmsecomponent; var dest: tmsecomponent;
                          const ainterfacetype: pointer = nil); overload;
   procedure sendevent(event: objecteventty);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   procedure forall(const proc: objectlinkprocty; 
                            const ainterfacetype: pointer); overload;
   procedure forall(const proc: objectlinkintfprocty;
                            const ainterfacetype: pointer); overload;
   procedure forfirst(const proc: objectlinkfirstprocty; 
                            const ainterfacetype: pointer); overload;
   procedure forfirst(const proc: objectlinkintffirstprocty;
                            const ainterfacetype: pointer); overload;
 end;

 tlinkedobject = class(tnullinterfacedobject,iobjectlink)
  private
  protected
   fobjectlinker: tobjectlinker;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject;
                            const event: objecteventty); virtual;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink;
                                 const event: objecteventty); virtual;
   function getinstance: tobject;
 public
   destructor destroy; override;
//   property objectlinker: tobjectlinker read getobjectlinker;
 end;
(*
 tnullinterfacedobject = class(tobject,iunknown)
  protected
   function _addref: integer; 
                      {$ifdef mswindows}stdcall{$else} cdecl{$endif};
   function _release: integer;
                      {$ifdef mswindows}stdcall{$else} cdecl{$endif};
   function queryinterface({$ifdef fpc_has_constref}constref{$else}const{$endif}
                    iid: tguid; out obj): hresult;
                       {$ifdef mswindows}stdcall{$else} cdecl{$endif};
 end;
*)
 tnullinterfacedpersistent = class(tvirtualpersistent,iunknown)
  protected
  {$ifdef FPC}
   function _addref: integer; 
                      {$ifdef mswindows}stdcall{$else} cdecl{$endif};
   function _release: integer;
                      {$ifdef mswindows}stdcall{$else} cdecl{$endif};
   function QueryInterface({$ifdef fpc_has_constref}constref{$else}const{$endif}
                 IID: TGUID; out Obj): HResult; 
                      {$ifdef mswindows}stdcall{$else} cdecl{$endif};
  {$endif}
 end;

 toptionalpersistent = class(tnullinterfacedpersistent)
  private
   procedure readdummy(reader: treader);
   procedure writedummy(writer: twriter);
  protected
   procedure defineproperties(filer : tfiler); override;
   function isoptional: boolean; virtual;
 end;

 tlinkedpersistent = class(tnullinterfacedpersistent,iobjectlink)
  private
  protected
   fobjectlinker: tobjectlinker;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject; 
                                const event: objecteventty); virtual;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink;
                                const event: objecteventty); virtual;
   function getinstance: tobject; virtual;

  public
   destructor destroy; override;
   procedure setlinkedvar(const source: iobjectlink; var dest: iobjectlink;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedpersistent; 
                                var dest: tlinkedpersistent;
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

 msecomponentstatety = (cs_ismodule,cs_beginreadproc,cs_endreadproc,
                       cs_loadedproc,
                        cs_inheritedloading,cs_noload,cs_tmpmodule,
                        cs_subcompref, //subcomponent can be referenced 
                                       //by component properties
                        cs_parentwidgetrect //info for designer, example ttabpage
//                        cs_skinloaded
                        {cs_hasskin,cs_noskin}{,cs_updateskinproc});
 msecomponentstatesty = set of msecomponentstatety;

 createprocty = procedure of object;
 
 skinoptionty = (sko_container);
 skinoptionsty = set of skinoptionty;
 
 skinobjectkindty = (sok_component,sok_widget,sok_groupbox,
                     sok_simplebutton,sok_databutton,
                     sok_tabbar,sok_tabpage,sok_toolbar,
                     sok_edit,sok_dispwidget,sok_dataedit,sok_booleanedit,
                     sok_grid,
                     sok_mainmenu,sok_popupmenu,
                     sok_user); 

 skininfoty = record
  instance: tobject;
  userkind: integer;
  group: integer;
  objectkind: skinobjectkindty;
  options: skinoptionsty;
 end;

 tmsecomponent = class(tcomponent,ievent
                  {$ifdef mse_with_ifi},iificommand,iificlient{$endif})
  private
   fonbeforeupdateskin: notifyeventty;
   fonafterupdateskin: notifyeventty;
   ftagpo: pointer;
   procedure readmoduleclassname(reader: treader);
   procedure writemoduleclassname(writer: twriter);
   procedure beginread;// virtual;
   procedure endread;
  protected
   fmsecomponentstate: msecomponentstatesty;
   fobjectlinker: tobjectlinker;
   factualclassname: pshortstring;
   fancestorclassname: string;
   fhelpcontext: msestring;

{$ifdef mse_with_ifi}
   fifiserverintf: iifiserver;
  //iificlient
   procedure setifiserverintf(const aintf: iifiserver);
   //iificommand
   procedure executeificommand(var acommand: ificommandcodety); virtual;
{$endif}   

   function getancestorclassname: string;
   function getmsecomponentstate: msecomponentstatesty;
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty); virtual;
   procedure dobeginread; virtual;
   procedure doendread; virtual;
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure validaterename(acomponent: tcomponent;
                         const curname, newname: string); override;
   procedure setchildorder(child: tcomponent; order: integer); override;
   procedure sendchangeevent(const aevent: objecteventty = oe_changed);
   function linkcount: integer;
   function candestroyevent(const event: tmethod): boolean;
   function gethelpcontext: msestring; virtual;

   class function classskininfo: skininfoty; virtual;
   function skininfo: skininfoty; virtual;
   function hasskin: boolean; virtual;
   function getcomponentinstance: tcomponent;
   procedure getcompchildren(const proc: tgetchildproc;
                                                  const root: tcomponent);
   
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); virtual;
   procedure objevent(const sender: iobjectlink; const event: objecteventty); virtual;
   function getinstance: tobject;
   function getcomponent: tcomponent;
     //ievent
   procedure receiveevent(const event: tobjectevent); virtual;

   procedure designselected(const selected: boolean); virtual;
   procedure setlinkedvar(const source: iobjectlink; var dest: iobjectlink;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedpersistent;
              var dest: tlinkedpersistent;
              const linkintf: iobjectlink = nil); overload;
   function getactualclassname: string;
   class function getmoduleclassname: string; virtual;
   class function hasresource: boolean; virtual;
   procedure defineproperties(filer: tfiler); override;
   procedure componentevent(const event: tcomponentevent); virtual;
   procedure doasyncevent(var atag: integer); virtual;
   procedure doafterload; virtual;

//   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
//   procedure getchildren1(const proc: tgetchildproc;
//                                      const root: tcomponent); virtual;
  public
   destructor destroy; override;
   procedure writestate(writer: twriter); override;
   procedure updateskin(const recursive: boolean = false); virtual;
//   procedure removeskin(const recursive: boolean = false); virtual;
   function loading: boolean; reintroduce;
       //this hides FPC tcomponent.loading which is not Delphi compatible
   {$ifdef FPC}
   procedure setinline(value: boolean);
   procedure setancestor(value: boolean);
   {$endif}
   procedure setsubcompref;
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
   procedure asyncevent(atag: integer = 0;
                   const aoptions: posteventoptionsty = []);
                          //posts event for doasyncevent to self
   procedure postcomponentevent(const event: tcomponentevent;
                                     const aoptions: posteventoptionsty = []);

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
  protected
   fobjectlinker: tobjectlinker;
   procedure finalizerecord(var item); override;
   procedure dounlink(var item); virtual; abstract;
   procedure itemdestroyed(const sender: iobjectlink); virtual; abstract;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  public
   constructor create(arecordsize: integer; aoptions: recordliststatesty = []);
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
  public
   function findmodulebyname(const name: string): tcomponent;
   procedure lock;
   procedure unlock;
 end;

 getchildreneventty = procedure (const sender: tmsecomponent;
                const proc: tgetchildproc; const root: tcomponent) of object;

 twritermse = class(twriter)
  private
//   fgetchildrenbefore: getchildreneventty;
   fancestorlookuplevel: integer;
   fchildlevel: integer;
   fnoancestor: boolean; //used for copy paste of inherited components
   fmasterancestor: boolean; //used to restore field class in tpersistentfields
  {$ifndef FPC}
   FAncestors: TStringList;
   fcurrentpos: integer;
   fancestorpos: integer;
   fsignaturewritten: boolean;
  {$endif}
   procedure DetermineAncestor(Component : TComponent);
   procedure AddToAncestorList(Component: TComponent);
   procedure DoFindAncestor(Component : TComponent);
  protected
   frootrootancestor: tcomponent;
   frootroot: tcomponent;
   function rootcompname(const acomp: tcomponent;
                             const aroot: tcomponent): string; overload;
   function rootcompname(const acomp: tcomponent;
                             arootlevel: integer): string; overload;
   procedure getchildren1(const acomp: tcomponent;
                             const proc: tgetchildproc; const aroot: tcomponent);
   procedure WriteChildren(Component : TComponent);
   procedure WriteComponentData(Instance: TComponent);
  public
   constructor create(const stream: tstream; const bufsize: integer;
                            const anoancestor: boolean = false;
                            const amasterancestor: boolean = false);
   destructor destroy; override;
   procedure WriteComponent(Component: TComponent);
   procedure writedescendent(const aroot: tcomponent;
                                       const aancestor: tcomponent);
   procedure writerootcomponent(aroot: tcomponent);
   property masterancestor: boolean read fmasterancestor;
 end;
 
 setsplitpairty = record
                   oldenum,newenum: string
                  end;
 setsplitinfoty = record
                   maintype: ptypeinfo;
                   splittype: ptypeinfo;
                   enums: array of setsplitpairty;
                  end;

 writerecordprocty = procedure(const writer: twriter; const data);
 readrecordprocty = procedure(const reader: treader; var data);

function ownscomponent(const owner: tcomponent; const child: tcomponent): boolean;
function ownernamepath(const acomponent: tcomponent): string; 
                     //namepath from root to acomponent separated by '.'
function namepathowner(const acomponent: tcomponent): string; 
                     //namepath from acomponent to root separated by '.'
function getnumberedname(const acomp: tcomponent;
                                     const namebase: string): string;
function ownercomponentpath(const acomponent: tcomponent): componentarty;
                     //componentpath from root to acomponent
function componentpathowner(const acomponent: tcomponent): componentarty;
                     //componentpath from acomponent to root
function rootcomponent(const acomponent: tcomponent): tcomponent;
procedure setcomponentorder(const owner: tcomponent; const anames: msestringarty);
function getcomponentchildren(const acomp: tcomponent;
           const aroot: tcomponent; 
           const nestedowners: boolean = false;
           const nestedparents: boolean = false): componentarty;
function getpropinfoar(const obj: tobject): propinfopoarty; overload;
function getpropinfoar(const atypeinfo: ptypeinfo): propinfopoarty; overload;

procedure createobjectlinker(const owner: iobjectlink; onevent: objectlinkeventty;
                                  var instance: tobjectlinker);
 //sets finstancepo
procedure getoptionalobject(const componentstate: tcomponentstate;
                       const instance: tobject; createproc: createprocty); overload;
procedure getoptionalobject(const aowner: tcomponent; //can be nil
                       const instance: tobject; createproc: createprocty); overload;
procedure getoptionalobject(const componentstate: tcomponentstate;
                  var instance: tvirtualpersistent;
                         const aclass: virtualpersistentclassty); overload;
procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tpersistent; var instance;
                    createproc: createprocty); overload;
procedure setoptionalobject(const aowner: tcomponent; //can be nil
                  const value: tpersistent; var instance;
                    createproc: createprocty); overload;
procedure setoptionalobject(const componentstate: tcomponentstate;
                  const value: tvirtualpersistent; var instance;
                  const aclass: virtualpersistentclassty); overload;
procedure setlinkedcomponent(const sender: iobjectlink; const source: tmsecomponent;
                      var instance: tmsecomponent; ainterfacetype: pointer = nil);

function createmodule(aowner: tcomponent; instanceclass: msecomponentclassty;
                                              var reference): tmsecomponent;
procedure registerobjectdata(datapo: pobjectdataty; 
                 objectclass: tpersistentclass; name: string = ''); overload;
procedure registerobjectdata(datapo: pobjectdataty; 
                 const objectclassname: string; const name: string = ''); overload;
                 //language overrides
procedure unregisterobjectdata(const objectclassname: string; const name: string = '');
                 //language overrides
procedure resetchangedmodules;
procedure reloadchangedmodules;

procedure msebegingloballoading; //recursive
procedure mseendgloballoading;   //calls notifygloballoading in level 0

procedure reloadmsecomponent(Instance: tmsecomponent);
function initmsecomponent(instance: tmsecomponent; rootancestor: tclass;
                            out needsloading: boolean): boolean;
                          //true if root and all inherited classes loaded
function initmsecomponent1(instance: tcomponent; rootancestor: tclass): boolean;
                          //true if root and all inherited classes loaded
function findancestorcomponent(const areader: treader; 
                 const componentname: string): tcomponent;
procedure loadmsemodule(const instance: tmsecomponent; const rootancestor: tclass);
function findmoduledata(const aclassname: string; 
                            out aparentclassname: string): pobjectdataty;

function getfproppath(const writer:twriter): string;
procedure setfproppath(const writer:twriter; const value: string);

procedure freecomponents(const acomponents: componentarty);
                    //uses freenotification
function copycomponent(const source: tcomponent; const aowner: tcomponent = nil;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onancestornotfound: tancestornotfoundevent = nil): tcomponent;
                //copy by stream.writecomponent, readcomponent
procedure refreshancestor(var deletedcomps: componentarty;
              const descendent,newancestor,oldancestor: tcomponent;
              const revert: boolean;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
             {$ifdef mse_nomethodswap}
              const onsetmethodproperty: tsetmethodpropertyevent = nil;
              const onwritemethodproperty: twritemethodpropertyevent = nil;
              const newcomponent: pboolean = nil
             {$else}
              const onfindmethod: tfindmethodevent = nil;
              const sourcemethodtab: pointer = nil;
              const destmethodtab: pointer = nil
             {$endif});
             
procedure initinline(const acomponent: tcomponent);
                 //sets inline, resets ancestor, sets ancestor of children
procedure checkinline(const acomponent: tcomponent);
                 //resets csancestor of csinline components
procedure initrootdescendent(const acomponent: tcomponent);
                 //clears csinline flags of acomoponent and children,
                 // sets csancestor
function issubcomponent(const root,child: tcomponent): boolean;
function fixupsetchildorder(const sender: tcomponent;
                     const child: tcomponent; const order: integer): boolean;
                                 //true if handled
function findcomponentbynamepath(const namepath: string): tcomponent;
function getlinkedcomponents(const acomponent: tcomponent): componentarty;
                 //returns items of free notify list


procedure lockfindglobalcomponent;   //switch of findglobalcomponent
procedure unlockfindglobalcomponent; //switch on findglobalcomponent
function findglobalcomponentlocked: boolean;

function getenumnames(const atypeinfo: ptypeinfo): msestringarty;

procedure nosupportfor(const sender: tcomponent; const avalue: tcomponent;
                          const ainterface: ptypeinfo);
function getcorbainterface(const aobject: tobject; const aintf: ptypeinfo;
                                                  out obj) : boolean;
procedure checkcorbainterface(const sender: tcomponent;
                           const avalue: tcomponent;
                           const ainterface: ptypeinfo; out obj);
function isinterface(const actual: ptypeinfo; const wanted: ptypeinfo): boolean;
function isinterfaceornil(const actual: ptypeinfo; const wanted: ptypeinfo): boolean;

function checkcanevent(const acomponent: tcomponent;
                     const event: tmethod): boolean; overload;
function checkcanevent(const event: tmethod): boolean;
                           {$ifdef FPC}inline;{$endif} overload;

procedure readstringar(const reader: treader; out ar: stringarty); overload;
procedure readstringar(const reader: treader; out ar: msestringarty); overload;
procedure writestringar(const writer: twriter; const ar: stringarty); overload;
procedure writestringar(const writer: twriter; const ar: msestringarty); overload;
procedure readrecordar(const reader: treader; out ar; //array of type
          const typeinfo: pdynarraytypeinfo; const readproc: readrecordprocty);
procedure writerecordar(const writer: twriter; const ar; //array of type
            const typeinfo: pdynarraytypeinfo; const writeproc: writerecordprocty);

function valuescaletorange(const reader: treader): real;

function swapmethodtable(const instance: tobject; const newtable: pointer): pointer;

function checkenumvalue(typeinfo : ptypeinfo;const name : string) : integer;
                 //exception on error
function readenum(const reader: treader; const atypeinfo: ptypeinfo): integer;
procedure writeenum(const writer: twriter; const value: integer;
                                                 const atypeinfo: ptypeinfo);
function readset(const reader: treader; const atypeinfo: ptypeinfo): tintegerset;
procedure writeset(const writer: twriter; const value: tintegerset;
                            const atypeinfo: ptypeinfo);
function readsplitset(const reader: treader; const info: setsplitinfoty;
                        out set1,set2: tintegerset): boolean;
                                  //true if splitted
function setloading(const acomponent: tcomponent; const avalue: boolean): boolean;
           //returns old value

function alive(const acomponent: tcomponent): boolean;

procedure componentexception(const acomponent: tcomponent;
                                   const atext: msestring);
type
 skineventty = procedure(const ainfo: skininfoty) of object;
var
 oninitskinobject: skineventty;
//threadvar
// onstreaminggetchildren: getchildreneventty;

function getcomponentlist(const acomponent: tcomponent): tfplist;
procedure clearcomponentlist(const acomponent: tcomponent);
procedure clearpastedcomponents;
procedure addpastedcomponentname(const acomp: tcomponent);
function findpastedcomponent(const origname: string): tcomponent;
function findpastedcomponentname(const comp: tcomponent): string;

{$ifdef mse_debug}
procedure dumptextstream(const stream: tstream; const atext: string);
procedure dumpcomponent(const acomp: tcomponent; const atext: string = '');
procedure dumpstreamcomponent(const acomp: tcomponent; const atext: string = '');
procedure debugstreamout(const stream: tstream; const atext: string);
procedure debugbinstreamout(const acomp,aancestor: tcomponent; 
             const aonfindancestor: tfindancestorevent; const atext: string);
function debugstringarty(const astringar: stringarty): string;
function debugcompname(const acomponent: tcomponent): string;
function debugcompnames(const acomponents: componentarty): string;
function debugcomprootname(const acomponent: tcomponent): string;
function debugcomprootnames(const acomponents: componentarty): string;
{$endif}

implementation
uses
{$ifdef debugobjectlink}
 msegui,mseformatstr,
{$endif}
 mseapplication,
{$ifdef mse_debug}
 mseobjecttext,
{$endif}
 msestream,msesys,msedatalist,msedatamodules,rtlconsts,msesysutils,
 msearrayutils,msestreaming
 {$ifdef mswindows}
 ,windows
{$endif}
;

type
 tpersistent1 = class(tpersistent);
 tcomponent1 = class(tcomponent);
 twriter1 = class(twriter);
 treader1 = class(treader);
{$ifndef FPC}
const
  filersignature : array[1..4] of char = 'TPF0';
type
{$endif}

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

 trefreshwriter = class(twritermse)
  protected
 end;
 
var
 objectdatalist: tobjectdatainfolist;
 fmodules: tmodulelist;
 floadedlist: tloadedlist;
 fmodulestoregister: msecomponentarty;

{$ifdef mse_debug}
function debugstringarty(const astringar: stringarty): string;
begin
 if astringar = nil then begin
  result:= 'NIL';
 end
 else begin
  result:= concatstrings(astringar,',');
 end;
end;

function debugcompname(const acomponent: tcomponent): string;
begin
 if acomponent = nil then begin
  result:= 'NIL';
 end
 else begin
  result:= acomponent.name+'<'+acomponent.classname+'>';
 end;
end;

function debugcompnames(const acomponents: componentarty): string;
var
 int1: integer;
begin
 if acomponents = nil then begin
  result:= 'NIL';
 end
 else begin
  for int1:= 0 to high(acomponents) do begin
   result:= result + debugcompname(acomponents[int1]) + ',';
  end;
  if result <> '' then begin
   setlength(result,length(result)-1);
  end;
 end;
end;

function debugcomprootname(const acomponent: tcomponent): string;
var
 comp1: tcomponent;
begin
 if acomponent = nil then begin
  result:= 'NIL';
 end
 else begin
  comp1:= acomponent;
  repeat
   result:= comp1.name+'<'+comp1.classname+'>'+'.'+result;
   comp1:= comp1.owner;
  until comp1 = nil;
  setlength(result,length(result)-1);
 end;
end;

function debugcomprootnames(const acomponents: componentarty): string;
var
 int1: integer;
begin
 if acomponents = nil then begin
  result:= 'NIL';
 end
 else begin
  result:= '';
  for int1:= 0 to high(acomponents) do begin
   result:= result + debugcomprootname(acomponents[int1]) + ',';
  end;
  if result <> '' then begin
   setlength(result,length(result)-1);
  end;
 end;
end;

procedure dumpcomponent(const acomp: tcomponent; const atext: string = '');
var
 indent: string;
 
 procedure dodump(const acomp: tcomponent);
 var
  int1: integer;
  str1: string;
 begin
  str1:= settostring(ptypeinfo(typeinfo(tcomponentstate)),
               integer(tintegerset(acomp.componentstate)),true);
  debugwriteln(indent+acomp.name+' '+str1);
  indent:= indent+' ';
  for int1:= 0 to acomp.componentcount-1 do begin
   dodump(acomp.components[int1]);
  end;
  setlength(indent,length(indent)-1);
 end;
 
begin
 if atext = '' then begin
  debugwriteln('*dumpcomp')
 end
 else begin
  debugwriteln(atext);
 end;
 dodump(acomp);
end;

procedure debugstreamout(const stream: tstream; const atext: string);
var
 teststream: ttextstream;
begin
 debugwriteln(atext);
 teststream:= ttextstream.create;
 stream.position:= 0;
 teststream.size:= 0;
 objectbinarytotextmse(stream,teststream);
 teststream.position:= 0;
 teststream.writetotext(output);
 teststream.free;
 flush(output);
end;

procedure dumptextstream(const stream: tstream; const atext: string);
var
 int1: integer;
 str1: string;
begin
 debugwriteln(atext);
 int1:= stream.position;
 stream.position:= 0;
 setlength(str1,stream.size);
 stream.readbuffer(pointer(str1)^,length(str1));
 debugwriteln(str1);
 stream.position:= int1;
end;

procedure debugbinstreamout(const acomp,aancestor: tcomponent;
                            const aonfindancestor: tfindancestorevent; const atext: string);
var
 stream1: tmemorystream;
 writer1: twritermse;
begin
 stream1:= tmemorystream.create;
 writer1:= twritermse.create(stream1,1024,false);
 writer1.onfindancestor:= aonfindancestor;
// writer1.onfindancestor:= {$ifdef FPC}@{$endif}fdesigner.findancestor;
 writer1.writedescendent(acomp,aancestor);
 writer1.free;
 debugstreamout(stream1,atext);
 stream1.free;
end;

procedure dumpstreamcomponent(const acomp: tcomponent; const atext: string = '');
begin
 debugbinstreamout(acomp,nil,nil,atext);
end;

{$endif}

function alive(const acomponent: tcomponent): boolean; 
                                                {$ifdef FPC}inline;{$endif}
begin
 result:= (acomponent <> nil) and 
           not (csdestroying in acomponent.componentstate);
end;

procedure componentexception(const acomponent: tcomponent;
                                      const atext: msestring);
begin
 raise exception.create(acomponent.classname+','+acomponent.name+': '+atext);
end;

function getfproppath(const writer:twriter): string;
begin
{$warnings off}
 result:= twriter1(writer).fproppath;
{$warnings on}
end;

procedure setfproppath(const writer:twriter; const value: string);
begin
{$warnings off}
 twriter1(writer).fproppath:= value;
{$warnings on}
end;

function modules: tmodulelist;
begin
 if fmodules = nil then begin
  fmodules:= tmodulelist.create(false);
 end;
 result:= fmodules;
end;

function getcomponentlist(const acomponent: tcomponent): tfplist;
begin
{$warnings off}
 with tcomponent1(acomponent) do begin
{$warnings on}
  if fcomponents = nil then begin
   fcomponents:= tfplist.create;
  end;
  result:= fcomponents;
 end;
end;

procedure clearcomponentlist(const acomponent: tcomponent);
begin
{$warnings off}
 freeandnil(tcomponent1(acomponent).fcomponents);
{$warnings on}
end;

type
 pastedcompinfoty = record
  comp: tcomponent;
  origname: string;
 end;
var
 pastedcomps: array of pastedcompinfoty;
 
procedure clearpastedcomponents;
begin
 pastedcomps:= nil;
end;

procedure addpastedcomponentname(const acomp: tcomponent);
begin
 setlength(pastedcomps,high(pastedcomps)+2);
 with pastedcomps[high(pastedcomps)] do begin
  comp:= acomp;
  origname:= comp.name;
 end;
end;

function findpastedcomponent(const origname: string): tcomponent;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(pastedcomps) do begin
  if pastedcomps[int1].origname = origname then begin
   result:= pastedcomps[int1].comp;
   break;
  end;
 end;
end;

function findpastedcomponentname(const comp: tcomponent): string;
var
 int1: integer;
begin
 result:= '';
 for int1:= 0 to high(pastedcomps) do begin
  if pastedcomps[int1].comp = comp then begin
   result:= pastedcomps[int1].origname;
   break;
  end;
 end;
end;

function setloading(const acomponent: tcomponent; const avalue: boolean): boolean;
begin
 result:= csdesigning in acomponent.componentstate;
{$warnings off}
 with tcomponent1(acomponent) do begin
{$warnings on}
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
                 //clears inline of children
var
 int1: integer;
 comp1: tcomponent;
begin
{$warnings off}
 with tcomponent1(acomponent) do begin
{$warnings on}
  exclude(fcomponentstate,csancestor);
  include(fcomponentstate,csinline);   
 end; 
 for int1:= 0 to acomponent.componentcount - 1 do begin
  comp1:= acomponent.components[int1];
  tcomponent1(comp1).setancestor(true);
//  clearinline(comp1);
 end;
end;

procedure checkinline(const acomponent: tcomponent);
var
 int1: integer;
 comp1: tcomponent1;
begin
 if csinline in acomponent.componentstate then begin
{$warnings off}
  with tcomponent1(acomponent) do begin
{$warnings on}
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
 ca1: longword;
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

procedure writeset(const writer: twriter; const value: tintegerset;
                            const atypeinfo: ptypeinfo);
var
{$ifndef FPC}
 i: integer;
{$endif}
 basetype: ptypeinfo;
begin
 basetype:= gettypedata(atypeinfo)^.comptype{$ifndef FPC}^{$endif};
 with twriter1(writer) do begin
  driver.writeset(longint(value),basetype);
 end;
end;

function checkenumvalue(typeinfo : ptypeinfo;const name : string) : integer;
begin
 result:= getenumvalue(typeinfo,name);
 if result < 0 then begin
  raise exception.create('In valid enum name for '+typeinfo^.name+
                                                         ': "'+name+'".');
 end;
end;

function readenum(const reader: treader; const atypeinfo: ptypeinfo): integer;
begin
 result:= getenumvalue(atypeinfo,reader.readident);
 if result < 0 then begin
  raise ereaderror.create(sinvalidpropertyvalue);
 end;
end;

procedure writeenum(const writer: twriter; const value: integer; 
                                              const atypeinfo: ptypeinfo);
begin
 writer.writeident(getenumname(atypeinfo,value));
end;

function readset(const reader: treader; const atypeinfo: ptypeinfo): tintegerset;
begin
 {$ifdef FPC}
 reader.checkvalue(vaset);
 result:= tintegerset(treader1(reader).driver.readset(
             gettypedata(atypeinfo)^.comptype{$ifndef fpc}^{$endif}));
 {$else}
 result:= tintegerset(treader1(reader).readset(atypeinfo));
 {$endif}
end;

function readsplitset(const reader: treader; const info: setsplitinfoty;
                        out set1,set2: tintegerset): boolean;
                                  //true if splitted
var
 int1,int2: integer;
 str1: string;
 po1,po2: ptypeinfo;
begin
 reader.checkvalue(vaset);
 set1:= [];
 set2:= [];
 result:= false;
 with info do begin
  while true do begin
   po1:= gettypedata(maintype)^.comptype{$ifndef FPC}^{$endif};
   po2:= gettypedata(splittype)^.comptype{$ifndef FPC}^{$endif};
   str1:= reader.driver.readstr;
   if str1 = '' then begin
    break;
   end;
   int1:= getenumvalue(po1,str1);
   if int1 >= 0 then begin
    include(set1,int1);
   end
   else begin
    for int2:= 0 to high(enums) do begin
     if enums[int1].oldenum = str1 then begin
      int1:= getenumvalue(po2,enums[int1].newenum);
      if int1 >= 0 then begin
       include(set2,int1);
      end;
      result:= true;
      break;
     end;
    end;
   end;
   if int1 < 0 then begin
    repeat
    until reader.driver.readstr = '';
    raise ereaderror.create(sinvalidpropertyvalue);
   end;
  end;
 end;
end;

function checkcanevent(const acomponent: tcomponent; const event: tmethod): boolean;
begin
 result:= (event.code <> nil) and (acomponent <> nil) and (event.data <> nil) and
            (acomponent.componentstate * [csloading,csdesigning,csdestroying] = []);
end;

function checkcanevent(const event: tmethod): boolean;
begin
 result:= (event.code <> nil) and (event.data <> nil);
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

procedure writestringar(const writer: twriter; const ar: msestringarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 for int1:= 0 to high(ar) do begin
  writer.writeunicodestring(ar[int1]);
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

procedure readstringar(const reader: treader; out ar: msestringarty);
var
 int1: integer;
begin
 int1:= 0;
 ar:= nil;
 reader.readlistbegin;
 while not reader.endoflist do begin
  additem(ar,reader.readunicodestring,int1);
 end;
 reader.readlistend;
 setlength(ar,int1);
end;

procedure readrecordar(const reader: treader; out ar; 
     const typeinfo: pdynarraytypeinfo; const readproc: readrecordprocty);
var
 int1: integer;
begin
 int1:= 0;
 reader.readlistbegin;
 while not reader.endoflist do begin
  reader.readlistbegin;
  readproc(reader,additempo(ar,typeinfo,int1)^);
  reader.readlistend;
 end;
 reader.readlistend;
 dynarraysetlength(pointer(ar),typeinfo,1,@int1);
end;

procedure writerecordar(const writer: twriter; const ar;
       const typeinfo: pdynarraytypeinfo; const writeproc: writerecordprocty);
var
 int1,int2: integer;
begin
 writer.writelistbegin;
 int2:= dynarrayelesize(typeinfo);
 for int1:= 0 to high(pointerarty(ar)) do begin
  writer.writelistbegin;
  writeproc(writer,(pointer(ar)+int2*int1)^);
  writer.writelistend;
 end;
 writer.writelistend;
end;

function valuescaletorange(const reader: treader): real;
begin
 result:= reader.readfloat;
 if result <> 0 then begin
  result:= 1/result;
 end;
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

function ownscomponent(const owner: tcomponent; const child: tcomponent): boolean;
var
 comp1: tcomponent;
begin
 result:= false;
 comp1:= child;
 while comp1 <> nil do begin
  if comp1 = owner then begin
   result:= true;
   break;
  end;
  comp1:= comp1.owner;
 end;
end;

function ownernamepath(const acomponent: tcomponent): string;
var
 comp: tcomponent;
begin
 if acomponent = nil then begin
  result:= ''
 end
 else begin
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
end;

function namepathowner(const acomponent: tcomponent): string; 
                     //namepath from acomponent to root separated by '.'
var
 comp: tcomponent;
begin
 if acomponent = nil then begin
  result:= ''
 end
 else begin
  with acomponent do begin
   result:= name;
   comp:= owner;
   while comp <> nil do begin
    if comp.Name <> '' then begin
     result:= result +  '.' + comp.Name;
    end;
    comp:= comp.Owner;
   end;
  end;
 end;
end;

function componentpathowner(const acomponent: tcomponent): componentarty;
                     //componentpath from acomponent to root
var
 count: integer;
 comp1: tcomponent;
begin
 count:= 0;
 if acomponent <> nil then begin
  comp1:= acomponent;
  repeat
  {$ifndef FPC}
   addpointeritem(pointerarty(result),pointer(comp1),count);
  {$else}
   additem(pointerarty(result),pointer(comp1),count);
  {$endif}
   comp1:= comp1.owner;
  until comp1 = nil;
 end;
 setlength(result,count);
end;

function ownercomponentpath(const acomponent: tcomponent): componentarty;
                     //componentpath from root to acomponent
begin
 result:= componentarty(reversearray(pointerarty(
                                         componentpathowner(acomponent))));
end;

function getnumberedname(const acomp: tcomponent;
                              const namebase: string): string;
var
 int1: integer;
begin
 int1:= 0;
 repeat
  result:= namebase+inttostr(int1);
 until acomp.findcomponent(result) = nil;
end;

function rootcomponent(const acomponent: tcomponent): tcomponent;
begin
 result:= acomponent;
 if result <> nil then begin
  while result.owner <> nil do begin
   result:= result.owner;
  end;
 end;
end;

procedure setcomponentorder(const owner: tcomponent; const anames: msestringarty);
var
 comp1: tcomponent;
 int1: integer;
begin
 for int1:= 0 to high(anames) do begin
  comp1:= owner.findcomponent(anames[int1]);
{$warnings off}
  with tcomponent1(owner).fcomponents do begin
{$warnings on}
   remove(comp1);
   add(comp1);
  end;
 end; 
end;

{ trefreshwriter }

type
 tgetcomponentchildren = class
  private
   fcomp: tcomponent;
   froot: tcomponent;
   fnestedowners: boolean;
   fnestedparents: boolean;
   fchildren: componentarty;
   fcount: integer;
   fcurrroot: tcomponent;
   function getchildrenar: componentarty;
  protected
   procedure childproc(child: tcomponent);
  public
   constructor create(const acomp: tcomponent; const aroot: tcomponent;
                            const nestedowners: boolean = false;
                            const nestedparents: boolean = false);
   property children: componentarty read getchildrenar;
 end;

{ tgetcomponentchildren }

constructor tgetcomponentchildren.create(const acomp: tcomponent;
      const aroot: tcomponent; const nestedowners: boolean = false;
      const nestedparents: boolean = false);
begin
 fcomp:= acomp;
 froot:= aroot;
 fnestedowners:= nestedowners;
 fnestedparents:= nestedparents;
end;

procedure tgetcomponentchildren.childproc(child: tcomponent);
begin
 additem(pointerarty(fchildren),child,fcount);
 if fnestedparents then begin
  tcomponent1(child).getchildren({$ifdef FPC}@{$endif}childproc,fcurrroot);
 end;
end;

function tgetcomponentchildren.getchildrenar: componentarty;
var
 comp1: tcomponent;
begin
 fchildren:= nil;
 fcount:= 0;
 if fnestedowners then begin
  comp1:= fcomp;
  while (comp1 <> froot) and (comp1 <> nil) do begin
   fcurrroot:= comp1;
   tcomponent1(fcomp).getchildren({$ifdef FPC}@{$endif}childproc,comp1);
   comp1:= comp1.owner;
  end;
 end;
 if froot <> nil then begin
  fcurrroot:= froot;
  tcomponent1(fcomp).getchildren({$ifdef FPC}@{$endif}childproc,froot);
 end;
 setlength(fchildren,fcount);
 result:= fchildren;
end;

function getcomponentchildren(const acomp: tcomponent;
                const aroot: tcomponent;
                const nestedowners: boolean = false;
                const nestedparents: boolean = false): componentarty;
var
 obj: tgetcomponentchildren;
// ev1: getchildreneventty; 
begin
// ev1:= onstreaminggetchildren;
// try
//  onstreaminggetchildren:= nil;
  obj:= tgetcomponentchildren.create(acomp,aroot,nestedowners,nestedparents);
  result:= obj.children;
  obj.free;
// finally
//  onstreaminggetchildren:= ev1;
// end;
end;

function getlinkedcomponents(const acomponent: tcomponent): componentarty;
var
 int1: integer;
begin
 result:= nil;
{$warnings off}
 with tcomponent1(acomponent) do begin
{$warnings on}
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
 if (obj <> nil) and (obj.classinfo <> nil) then begin
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

type
 tcomponentdestroyer = class(tcomponent)
  private
   fcomps: componentarty;
   fcurrentcomponent: tcomponent;
  protected
   procedure notification(acomponent: tcomponent;
                                   operation: toperation); override;
  public
   constructor create(const acomps: componentarty); reintroduce;
 end;

{ tcomponentdestroyer }

constructor tcomponentdestroyer.create(const acomps: componentarty);
var
 int1: integer;
begin
 inherited create(nil);
 fcomps:= copy(acomps);
 for int1:= 0 to high(fcomps) do begin
  fcomps[int1].freenotification(self);
 end;
 for int1:= 0 to high(fcomps) do begin
  fcurrentcomponent:= fcomps[int1];
  fcurrentcomponent.free;
 end;
end;

procedure tcomponentdestroyer.notification(acomponent: tcomponent;
                                                  operation: toperation);
var
 int1: integer;
begin
 if (operation = opremove) and (acomponent <> fcurrentcomponent) then begin
  for int1:= high(fcomps) downto 0 do begin
   if fcomps[int1] = acomponent then begin
    fcomps[int1]:= nil;
    break;
   end;
  end;
 end;
 inherited;
end;
 
procedure freecomponents(const acomponents: componentarty);
                    //uses freenotification
begin
 tcomponentdestroyer.create(acomponents).free;
end;

function copycomponent(const source: tcomponent; const aowner: tcomponent = nil;
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
              const onancestornotfound: tancestornotfoundevent = nil): tcomponent;
                //copy by stream.writecomponent, readcomponent

 procedure copyflags(const source: tcomponent; const dest: tcomponent);
 var
  int1: integer;
  comp1,comp2: tcomponent;
 begin
  for int1:= 0 to source.componentcount - 1 do begin
   comp1:= source.components[int1];
   comp2:= dest.findcomponent(comp1.name);
   if comp2 <> nil then begin
    if csancestor in comp1.componentstate then begin
     tcomponent1(comp2).setancestor(true);
    end
    else begin
     copyflags(comp1,comp2);
    end;
   end;
  end;
 end; //copyflags
 
var
 stream: tmemorystream;
 writer: twritermse;
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
   writer:= twritermse.Create(stream,4096,false);
   try
    writer.OnFindAncestor:= onfindancestor;
    writer.Writerootcomponent(source);
   finally
    writer.Free;
   end;
 {$ifdef mse_debugcopycomponent}
   debugstream:= ttextstream.create;
   stream.position:= 0;
   objectbinarytotextmse(stream,debugstream);
   debugstream.position:= 0;
   writeln(output,'***copycomponent source');
   dumpcomponent(source);
   debugstream.writetotext(output);
   flush(output);
  {$endif}
   stream.Position:= 0;
   reader:= treader.Create(stream,4096);
   try
    reader.OnFindComponentClass:= onfindcomponentclass;
    reader.OnCreateComponent:= oncreatecomponent;
    reader.onancestornotfound:= onancestornotfound;
//    reader.ancestor:= aancestor;
    reader.ReadrootComponent(result);
    if (source.owner = nil) and (csancestor in source.componentstate) then begin
     tcomponent1(source).setancestor(true);
    end
    else begin
     copyflags(source,result);
    end;
   finally
    reader.free;
   end;
 {$ifdef mse_debugcopycomponent}
   stream.clear;
   writer:= twritermse.Create(stream,4096);
   writer.Writerootcomponent(result);
   writer.Free;
   stream.position:= 0;
   debugstream.clear;
   objectbinarytotextmse(stream,debugstream);
   debugstream.position:= 0;
   writeln(output,'***copycomponent dest');
   dumpcomponent(result);
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

function fixupsetchildorder(const sender: tcomponent;
                     const child: tcomponent; const order: integer): boolean;
                                 //true if handled
begin
 result:= false;
 if (csloading in child.componentstate) and 
    (child.getparentcomponent = nil) and ownscomponent(sender,child) and
    (child.owner.componentstate*[csreading,csinline] = [csreading,csinline]) and 
    (child.owner <> sender) then begin
   //treader set root as parent istead of lookuproot.
  tcomponent1(child.owner).setchildorder(child,order);
  result:= true;
 end;
end;

function createmodule(aowner: tcomponent; instanceclass: msecomponentclassty;
                                                 var reference): tmsecomponent;
var
 instance: tmsecomponent;
begin
 instance := tmsecomponent(instanceclass.newinstance);
 additem(pointerarty(fmodulestoregister),instance);
// fmodules.add(instance); //not before completely loaded, 
                        //submodules call globalfixupreferences
 if @reference <> nil then begin
  tmsecomponent(reference):= instance;
 end;
 try
  instance.create(aowner);
 except
  if @reference <> nil then begin
   tcomponent(reference) := nil;
  end;
  raise;
 end;
 result:= instance;
end;


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
   reader := tasinheritedreader.create(stream, 4096,true);
  end
  else begin
   reader := treader.create(stream, 4096);
  end;
  try
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

const
 skipmark = 'h71%z/ur';
 
type 
 trefresheventhandler = class(tcomponent)
  private
   fcomponentar: componentarty;
   procedure onsetname(reader: treader; component: tcomponent; var aname: string);
   procedure onerror(reader: treader; const message: string; var handled: boolean);
   procedure doancestornotfound(reader: treader; const componentname: string;
                   componentclass: tpersistentclass; var component: tcomponent);
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
exit;
 if (component.owner <> nil) and ((csinline in component.owner.componentstate) and
        not(csancestor in component.componentstate) or
        (component.owner.findcomponent(aname) <> nil)) then begin
  additem(pointerarty(fcomponentar),component);
  component.freenotification(self);
  raise trefreshexception.create(skipmark); //skip the component
 end;
end;

procedure trefresheventhandler.doancestornotfound(reader: treader;
               const componentname: string; componentclass: tpersistentclass;
               var component: tcomponent);
begin
 if component = nil then begin
  component:= tasinheritedreader(reader).existingcomp;
  if (component = nil) then begin
   if assigned(reader.oncreatecomponent) then begin
    reader.oncreatecomponent(reader,tcomponentclass(componentclass),component);
   end;
   if component = nil then begin
    component:= tcomponent(componentclass.newinstance);
  {$warnings off}
    with tcomponent1(component) do begin
  {$warnings on}
     fcomponentstate:= componentstate + [csloading,csancestor];
    end;
    try
     component.create(reader.owner);
    except
     component.free;
     raise;
    end;
   end;
  end;
 end;
end;


type
 tcomponentdeleter = class(tcomponent)
  private
   fdelcomponents: componentarty;
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
  public
   constructor create(const acomponents: componentarty); reintroduce;
 end;

{ tcomponentdeleter }

constructor tcomponentdeleter.create(const acomponents: componentarty);
var
 int1: integer;
begin
 inherited create(nil);
 fdelcomponents:= acomponents;
 for int1:= 0 to high(fdelcomponents) do begin
  if fdelcomponents[int1] <> nil then begin
   fdelcomponents[int1].freenotification(self);
  end;
 end;
end;
 
procedure tcomponentdeleter.notification(acomponent: tcomponent;
               operation: toperation);
var
 int1: integer;
begin
 inherited;
 if operation = opremove then begin
  for int1:= 0 to high(fdelcomponents) do begin
   if fdelcomponents[int1] = acomponent then begin
    fdelcomponents[int1]:= nil;
   end;
  end;
 end;
end;

type
 trefreshancestoreventhandler = class(trefresheventhandler)
  private
   fnonancestors: componentarty;
   fsetancestorroot: tcomponent;
  protected
   procedure setchildancestor(child: tcomponent);
   procedure setancestors(const acomponent: tcomponent);
   procedure notification(acomponent: tcomponent; operation: toperation);
                               override;  
 end;
 
procedure trefreshancestoreventhandler.notification(acomponent: tcomponent;
                                                     operation: toperation);
begin
 if operation = opremove then begin
  removeitem(pointerarty(fnonancestors),pointer(acomponent));
 end;
 inherited;
end;

procedure trefreshancestoreventhandler.setchildancestor(child: tcomponent);
begin
 with tcomponent1(child) do begin
  setancestor(true);
  getchildren({$ifdef FPC}@{$endif}setchildancestor,fsetancestorroot);
 end;
end;

procedure trefreshancestoreventhandler.setancestors(const acomponent: tcomponent);
begin
 fsetancestorroot:= acomponent.owner;
 setchildancestor(acomponent);
end;

procedure refreshancestor(var deletedcomps: componentarty;
              const descendent,newancestor,oldancestor: tcomponent;
              const revert: boolean; 
              const onfindancestor: tfindancestorevent = nil;
              const onfindcomponentclass: tfindcomponentclassevent = nil;
              const oncreatecomponent: tcreatecomponentevent = nil;
             {$ifdef mse_nomethodswap}
              const onsetmethodproperty: tsetmethodpropertyevent = nil;
              const onwritemethodproperty: twritemethodpropertyevent = nil;
              const newcomponent: system.pboolean = nil
             {$else}
              const onfindmethod: tfindmethodevent = nil;
              const sourcemethodtab: pointer = nil;
              const destmethodtab: pointer = nil
             {$endif});

var
 descendentroot: tcomponent;
 newancestorroot: tcomponent;
 oldancestorroot: tcomponent;
 eventhandler: trefreshancestoreventhandler;
  
 procedure deletecomps(const adescendent,anewancestor,aoldancestor: tcomponent);
 var
  deleter: tcomponentdeleter;
  descendentar,newancestorar,oldancestorar: componentarty;
  int1,int2: integer;
  comp1,comp2: tcomponent;
  str1: string;
 begin
  descendentar:= getcomponentchildren(adescendent,descendentroot,true);
                   //nested components
  deleter:= tcomponentdeleter.create(descendentar);
  try
   newancestorar:= getcomponentchildren(anewancestor,newancestorroot,true);    
   if not revert then begin
    oldancestorar:= getcomponentchildren(aoldancestor,oldancestorroot,true);
   end;
   for int1:= 0 to high(descendentar) do begin
    if descendentar[int1] <> nil then begin
     str1:= descendentar[int1].name;
     comp1:= nil;
     for int2:= 0 to high(newancestorar) do begin
      if newancestorar[int2].name = str1 then begin
       comp1:= newancestorar[int2];
       break;
      end;
     end;
     comp2:= nil;
     if not revert then begin
      for int2:= 0 to high(oldancestorar) do begin
       if oldancestorar[int2].name = str1 then begin
        comp2:= oldancestorar[int2];
        break;
       end;
      end;
     end;
     if ((comp1 = nil) or (finditem(pointerarty(deletedcomps),comp1) >= 0)) and 
                                     (revert or (comp2 <> nil)) then begin
      additem(pointerarty(deletedcomps),pointer(descendentar[int1]));
//      freedesigncomponent(descendentar[int1]);
//      descendentar[int1].free;
     end
     else begin
      if revert or (comp2 <> nil) then begin
       deletecomps(descendentar[int1],comp1,comp2);
      end
      else begin
       with tcomponent1(descendentar[int1]) do begin
        if owner.componentstate * [csinline,csancestor] <> [] then begin
         eventhandler.setancestors(descendentar[int1]);
        end;
       end;
      end;
     end;
    end;
   end;
   if not revert then begin
    with eventhandler do begin
     for int1:= 0 to high(fnonancestors) do begin
      tcomponent1(fnonancestors[int1]).setancestor(false);
     end;
    end;
   end;
  finally
   deleter.free;
  end;
 end;

var
 nonancestors: componentarty;
 stream1,stream2,stream4: tmemorystream;
 writer: twritermse;
 reader: tasinheritedreader;
 inl: boolean;
 int1,int2: integer;
 intf1: iactivatorclient;
{$ifndef mse_nomethodswap}
 tabbefore: pointer;
{$endif}
 {$ifdef mse_debugrefresh}
 comp1: tcomponent;
 stream3: ttextstream;
 {$endif}
 
begin
 descendentroot:= rootcomponent(descendent);
 newancestorroot:= rootcomponent(newancestor);
 oldancestorroot:= rootcomponent(oldancestor);
 if not revert then begin
  nonancestors:= getcomponentchildren(descendent,descendentroot,false,true);
                   //nested components
  int2:= 0;
  for int1:= 0 to high(nonancestors) do begin
   if not (csancestor in nonancestors[int1].componentstate) then begin
    nonancestors[int2]:= nonancestors[int1];
    inc(int2);
   end;
  end;
  setlength(nonancestors,int2);
 end;

{$ifdef mse_debugrefresh}
 if revert then begin
  write('****revert ');
 end
 else begin
  write('****refresh ');
 end;
 comp1:= descendentroot;
 writeln('root: '+comp1.name+' descendent: '+ descendent.name + ' newancestor: '+
        newancestor.name + ' oldancestor: '+oldancestor.name);
 dumpcomponent(descendent,'*descendent');
 dumpcomponent(newancestor,'*newancestor');
 dumpcomponent(oldancestor,'*oldancestor');
 stream3:= ttextstream.create;
{$endif}

 eventhandler:= trefreshancestoreventhandler.create(nil);
 for int1:= 0 to high(nonancestors) do begin
  nonancestors[int1].freenotification(eventhandler);
 end;
 eventhandler.fnonancestors:= nonancestors;
 nonancestors:= nil;
 stream1:= tmemorystream.Create;
 stream2:= tmemorystream.Create;
 stream4:= tmemorystream.Create;

 try
  writer:= trefreshwriter.Create(stream1,4096,false);
{$ifdef mse_nomethodswap}
  writer.onwritemethodproperty:= onwritemethodproperty;
{$else}
  tabbefore:= nil; //compiler warning
  if destmethodtab <> nil then begin
   tabbefore:= swapmethodtable(descendent,destmethodtab);
  end;
{$endif}
  try
   writer.OnFindAncestor:= onfindancestor;
   writer.WriteDescendent(descendent,oldancestor); //changes from oldancestor
  finally
{$ifndef mse_nomethodswap}
   if destmethodtab <> nil then begin
    swapmethodtable(descendent,tabbefore);
   end;
{$endif}
   writer.Free;
  end;

{$ifdef mse_debugrefresh}
  stream1.position:= 0;
  objectbinarytotextmse(stream1,stream3);
  stream3.position:= 0;
  writeln('**changes descendent->oldancestor');
  stream3.writetotext(output);
{$endif}

  writer:= twritermse.Create(stream2,4096,false,true);
  inl:= csinline in newancestor.componentstate;
  if csinline in descendent.componentstate then begin
   tmsecomponent(newancestor).SetInline(true);
  end;

{$ifdef mse_nomethodswap}
  writer.onwritemethodproperty:= onwritemethodproperty;
{$else}
  if sourcemethodtab <> nil then begin
   tabbefore:= swapmethodtable(newancestor,sourcemethodtab);
  end;
{$endif}

  try
   writer.OnFindAncestor:= onfindancestor;
   writer.WriteDescendent(newancestor,descendent); 
                                       //new state before deactivate
   writer.free;
  {$ifdef mse_debugrefresh}
   stream2.position:= 0;
   stream3.setsize(0);
   objectbinarytotextmse(stream2,stream3);
   stream3.position:= 0;
   writeln('**changes newancestor->descendent before deactivate');
   stream3.writetotext(output);
  {$endif}

   if descendent is tactcomponent then begin
    tactcomponent(descendent).deactivate(true);
   end
   else begin
    if getcorbainterface(descendent,typeinfo(iactivatorclient),intf1) then begin
     intf1.setactive(false);
    end;
   end;
 
   writer:= twritermse.Create(stream4,4096,false,true);
  {$ifdef mse_nomethodswap}
   writer.onwritemethodproperty:= onwritemethodproperty;
  {$endif}
   writer.WriteDescendent(newancestor,descendent); //new state after deactivate
  finally
   writer.free;
   tmsecomponent(newancestor).SetInline(inl);
{$ifndef mse_nomethodswap}
   if sourcemethodtab <> nil then begin
    swapmethodtable(newancestor,tabbefore);
   end;
{$endif}
  end;

 {$ifdef mse_debugrefresh}
  stream4.position:= 0;
  stream3.setsize(0);
  objectbinarytotextmse(stream4,stream3);
  stream3.position:= 0;
  writeln('**changes newancestor->descendent after deactivate');
  stream3.writetotext(output);
 {$endif}

  stream1.Position:= 0;
  stream2.Position:= 0;
  stream4.Position:= 0;

 {$ifndef mse_nomethodswap}
  if destmethodtab <> nil then begin
   tabbefore:= swapmethodtable(descendent,destmethodtab);
  end;
 {$endif}
  try
   reader:= tasinheritedreader.create(stream2,4096,inl{false});  
                    //new state before deactivate
   reader.OnFindComponentClass:= onfindcomponentclass;
   reader.OnCreateComponent:= oncreatecomponent;
  {$ifdef mse_nomethodswap}
   reader.onsetmethodproperty:= onsetmethodproperty;
  {$else}
   reader.onfindmethod:= onfindmethod;
  {$endif}
   reader.onancestornotfound:= 
                {$ifdef FPC}@{$endif}eventhandler.doancestornotfound;
 {$ifdef mse_debugrefresh}
    writeln('**reading changes newancestor->descendent before deactivate');
 {$endif}
   reader.ReadRootComponent(descendent); //changes
   if newcomponent <> nil then begin
    newcomponent^:= reader.newcomp;
   end;
   reader.free;

   reader:= tasinheritedreader.create(stream4,4096,inl{false});  
                    //new state after deactivate
   reader.OnFindComponentClass:= onfindcomponentclass;
   reader.OnCreateComponent:= oncreatecomponent;
  {$ifdef mse_nomethodswap}
   reader.onsetmethodproperty:= onsetmethodproperty;
  {$else}
   reader.onfindmethod:= onfindmethod;
  {$endif}
   reader.onancestornotfound:= 
                {$ifdef FPC}@{$endif}eventhandler.doancestornotfound;
 {$ifdef mse_debugrefresh}
    writeln('**reading changes newancestor->descendent after deactivate');
 {$endif}
   reader.ReadRootComponent(descendent); //changes
  
   if not revert then begin
    reader.free;
    reader:= tasinheritedreader.create(stream1,4096,false);  //restore old changes
    reader.OnFindComponentClass:= onfindcomponentclass;
    reader.OnCreateComponent:= oncreatecomponent;
   {$ifdef mse_nomethodswap}
    reader.onsetmethodproperty:= onsetmethodproperty;
   {$else}
    reader.onfindmethod:= onfindmethod;
   {$endif}
    reader.onsetname:= {$ifdef FPC}@{$endif}eventhandler.onsetname;
    reader.onerror:= {$ifdef FPC}@{$endif}eventhandler.onerror;
    reader.onancestornotfound:= 
                {$ifdef FPC}@{$endif}eventhandler.doancestornotfound;
 {$ifdef mse_debugrefresh}
    writeln('**reading changes descendent->oldancestor');
 {$endif}
    reader.ReadRootComponent(descendent); //changes descendent->oldancestor
   end;

  {$ifdef mse_debugrefresh}
   debugwriteln('**deleteldcomps before delete '+
                        debugcomprootnames(deletedcomps));
  {$endif}
  
  finally
  {$ifndef mse_nomethodswap}
   if destmethodtab <> nil then begin
    swapmethodtable(descendent,tabbefore);
   end;
  {$endif}
   reader.free;
   removefixupreferences(descendent,'');
  end;

 finally
  try
   nonancestors:= eventhandler.fnonancestors;
   deletecomps(descendent,newancestor,oldancestor);
  {$ifdef mse_debugrefresh}
   debugwriteln('**deleteldcomps after delete '+
                        debugcomprootnames(deletedcomps));
   dumpcomponent(descendent,'**descendent');
  {$endif}
  finally
   stream1.Free;
   stream2.Free;
   stream4.Free;
 
  {$ifdef mse_debugrefresh}
   stream3.free;
  {$endif}

   eventhandler.free;
  end;
 end;

end;

type
 globalloadinfoty = record
  modules: msecomponentarty;
  modulecount: integer;
 end;
 globalloadinfoarty = array of globalloadinfoty;
 
 tloadmoduletracker = class(tlinkedobject)
  private
   fgloballoadings: globalloadinfoarty;
   fgloballevel: integer;
  protected
   procedure unlink(var ainfo: globalloadinfoty);
   procedure objectevent(const sender: tobject; const event: objecteventty);
                                                                       override;
  public
   constructor create;
   procedure moduleloaded(const amodule: tmsecomponent);
   procedure beginglobal;
   procedure endglobal;
   procedure notifyloading;
 end;
 
{ tloadmoduletracker }

constructor tloadmoduletracker.create;
begin
 setlength(fgloballoadings,16);
end;

procedure tloadmoduletracker.moduleloaded(const amodule: tmsecomponent);
begin
 with fgloballoadings[fgloballevel] do begin
  if length(modules) <= modulecount then begin
   setlength(modules,modulecount*2+16);
  end;
  modules[modulecount]:= amodule;
  getobjectlinker.link(amodule);
  inc(modulecount);
 end;
end;

procedure tloadmoduletracker.beginglobal;
begin
 if length(fgloballoadings) >= fgloballevel then begin
  setlength(fgloballoadings,fgloballevel*2+16);
 end;
 inc(fgloballevel);
end;

procedure tloadmoduletracker.endglobal;
begin
 unlink(fgloballoadings[fgloballevel]);
 dec(fgloballevel);
end;

procedure tloadmoduletracker.unlink(var ainfo: globalloadinfoty);
var
 comp1: tmsecomponent;
 int1: integer;
begin
 with ainfo do begin
  for int1:= 0 to modulecount-1 do begin
   comp1:= modules[int1];
   if comp1 <> nil then begin
    modules[int1]:= nil;
    fobjectlinker.unlink(comp1);
   end;
  end;
  modulecount:= 0;
 end;
end;

procedure tloadmoduletracker.objectevent(const sender: tobject;
                                                 const event: objecteventty);
var
 int1,int2: integer;
begin
 inherited;
 if event = oe_destroyed then begin
  for int1:= 0 to fgloballevel do begin
   with fgloballoadings[int1] do begin
    for int2:= 0 to modulecount-1 do begin
     if modules[int2] = sender then begin
      modules[int2]:= nil;
     end;
    end;
   end;
  end;
 end;
end;

procedure tloadmoduletracker.notifyloading;
var
 comp1: tmsecomponent;
 int1: integer;
begin
 with fgloballoadings[fgloballevel] do begin
  try
   for int1:= modulecount - 1 downto 0 do begin
    comp1:= modules[int1];
    if comp1 <> nil then begin
     modules[int1]:= nil;
     fobjectlinker.unlink(comp1);
     comp1.doafterload;
    end;
   end;
  finally
   unlink(fgloballoadings[fgloballevel]);
  end;
 end;
end;

var
 moduleloadlevel: integer;
 globalloadlevel: integer;
 loadmoduletracker: tloadmoduletracker;
 
procedure msebegingloballoading;
begin
 inc(globalloadlevel);
 if globalloadlevel = 1 then begin
  begingloballoading;
 end;
end;

procedure mseendgloballoading;
begin
 dec(globalloadlevel);
 if globalloadlevel = 0 then begin
  notifygloballoading;
  endgloballoading;
  loadmoduletracker.notifyloading;
 end;
end;

function initmsecomponent(instance: tmsecomponent; rootancestor: tclass;
                          out needsloading: boolean): boolean;
var
 allloaded: boolean;
 ancestorloaded: boolean;
 loadlevel: integer;

 rootancestor1: tclass;

 procedure doload(const aclass: msecomponentclassty);
 var
  po1: pobjectdatainfoty;
 begin
  if (aclass <> rootancestor1) and (aclass <> tmsecomponent) then begin
   if loadlevel > 0 then begin
    include(instance.fmsecomponentstate,cs_inheritedloading);
   end;
   inc(loadlevel);
   try
    doload(msecomponentclassty(aclass.classparent));
   finally
    dec(loadlevel);
    if loadlevel = 0 then begin
     exclude(instance.fmsecomponentstate,cs_inheritedloading);
    end;
   end;
   po1:= nil;
   if objectdatalist <> nil then begin
    po1:= objectdatalist.find(aclass,instance.name);
    if (po1 = nil) and (rootancestor <> nil) then begin
     po1:= objectdatalist.find(aclass,'');
    end;
   end;
   if (po1 <> nil) then begin
    if not ancestorloaded then begin
     ancestorloaded:= true;
     inc(moduleloadlevel);
     if (moduleloadlevel = 1) and (globalloadlevel = 0) then begin
      begingloballoading;
     end;
    end;
    loadmodule(instance,po1,false);
   end
   else begin
    if aclass.hasresource then begin
     allloaded:= false;
     needsloading:= true;
    end;
   end;
  end;
 end;

begin
 loadlevel:= 0;
 if (rootancestor = nil) then begin
  rootancestor1:= instance.classtype.classparent;
 end
 else begin
  rootancestor1:= rootancestor;
 end;
 ancestorloaded:= false;
 needsloading:= false;
 allloaded:= true;
 try
  loadmoduletracker.moduleloaded(instance);
  doload(msecomponentclassty(instance.classtype));
  if finditem(pointerarty(fmodulestoregister),instance) >= 0 then begin
   modules.add(tmsecomponent(instance));
   globalfixupreferences;
  end;
  if ancestorloaded and (moduleloadlevel = 1) and (globalloadlevel = 0) then begin
   moduleloadlevel:= 0;  //allow loading of forms in loaded procedure
   notifygloballoading;
  end;
 finally
  if ancestorloaded then begin
   if moduleloadlevel > 0 then begin
    dec(moduleloadlevel);
   end;
   if (moduleloadlevel = 0) and (globalloadlevel = 0) then begin
    endgloballoading;
   end;
  end;
  removeitem(pointerarty(fmodulestoregister),instance);
 end;
 if (moduleloadlevel = 0) and (globalloadlevel = 0) then begin
  loadmoduletracker.notifyloading;
 end;
 result:= allloaded and ancestorloaded;
end;

function initmsecomponent1(instance: tcomponent; rootancestor: tclass): boolean;
                          //true if root loaded
var
 bo1: boolean;
begin
 if instance is tmsecomponent then begin
  result:= initmsecomponent(tmsecomponent(instance),rootancestor,bo1);
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
procedure loadmsemodule(const instance: tmsecomponent; 
                                           const rootancestor: tclass);
var
 needsloading: boolean;
   
begin
                 //try mse moduleloading
 if not initmsecomponent(instance,rootancestor,needsloading) then begin
  if needsloading {or not 
                       initinheritedcomponent(instance,needsloading)} then begin
                 //try FPC module loading
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
  if (stringicompupper(result^.objectclass.classname,aclassname) = 0) and 
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
                (stringicompupper(name,po1^.name) = 0) then begin
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
 mclasses.registerclass(objectclass);
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

procedure getoptionalobject(const aowner: tcomponent;
                       const instance: tobject; createproc: createprocty);
var
 sta1: tcomponentstate;
begin
 sta1:= [];
 if aowner <> nil then begin
  sta1:= aowner.componentstate;
 end;
 getoptionalobject(sta1,instance,createproc);
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
  if not ((csdesigning in componentstate) and 
                             (pointer(value) = pointer(1))) then begin
   tpersistent(instance).assign(value);
  end;
 end
 else begin
  freeandnil(tpersistent(instance));
 end;
end;

procedure setoptionalobject(const aowner: tcomponent; //can be nil
                  const value: tpersistent; var instance;
                    createproc: createprocty); overload;
var
 sta1: tcomponentstate;
begin
 sta1:= [];
 if aowner <> nil then begin
  sta1:= aowner.componentstate;
 end;
 setoptionalobject(sta1,value,instance,createproc);
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

 function intftext(aintf: iobjectlink): string;
 var
  obj1: tobject;
 begin
  result:= '';
  if odd(ptruint(aintf)) then begin
   dec(pointer(aintf));
  end;
  if aintf = nil then begin
   result:= result+'<nil>';
  end
  else begin
   if ptrint(aintf) = 1 then begin
    result:= result + '<-1->';
   end
   else begin
    result:= result + hextostr(longword(aintf),8) + ' ';
    obj1:= iobjectlink(aintf).getinstance;
    result:= result + hextostr(longword(obj1),8);
    if obj1 <> nil then begin
     result:= result + ' '+obj1.classname;
    end;
    if obj1 is tcomponent then begin
     result:= result+' '+tcomponent(obj1).Name;
    end
    else begin
     if obj1 is twindow then begin
      result:= result+' '+twindow(obj1).owner.Name;
     end;
    end
   end;
  end;
 end;

procedure getdebugtext(owner: tobjectlinker; const source,dest:iobjectlink;
                         valuepo: pointer);
begin
 if rels_destroying in owner.fstate then begin
  write('*');
 end
 else begin
  write(' ');
 end;
 write('v:'+ hextostr(longword(valuepo),8));
 write(' o:'+intftext(iobjectlink(owner.fownerintf)));
 write(' s:'+intftext(source));
 write(' d:'+intftext(dest));
 writeln;
end;

{$endif}

constructor tobjectlinker.create(const owner: iobjectlink;
                                onevent: objectlinkeventty);
begin
{$ifdef debugobjectlink}
 writeln('create o: ' + intftext(owner));
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
 writeln('destroy o: ' + intftext(iobjectlink(fownerintf)));
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
    if odd(ptruint(source)) then begin
     iobjectlink(po1).objevent(iobjectlink(pchar(source)-1),oe_destroyed);
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
        (destroyed or 
               (valuepo = item.valuepo) and (source = item.source)) then begin
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
  if not (once {and (findsource(info) >= 0)}) then begin
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
   if not odd(ptruint(source)) then begin //full link
    dest.link(iobjectlink(pchar(dest)+1),source,valuepo,ainterfacetype);
                      //create backlink
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
 info.source:= pointer(source);
 info.dest:= pointer(dest);
 info.valuepo:= valuepo;
 removelink(info,ptrint(source) = 1);
 if not odd(ptruint(source)) then begin //full link
  dest.unlink(iobjectlink(pchar(dest)+1),source,valuepo);
                       //remove backlink
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
                         const source: iobjectlink;
                         var dest: iobjectlink;
                         const ainterfacetype: pointer = nil);
var
 ba: pointer;
begin
 if source <> dest then begin
  ba:= pointer(dest);
  pointer(dest):= pointer(source);
  if source <> nil then begin
   link(linkintf,source,@dest,ainterfacetype);
  end;
  if ba <> nil then begin
   unlink(linkintf,iobjectlink(ba),@dest);
  end;
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
                  const source: tlinkedobject; var dest: tlinkedobject;
                  const ainterfacetype: pointer = nil);
var
 ba: tlinkedobject;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,iobjectlink(source),@dest,ainterfacetype);
  end;
  if ba <> nil then begin
   unlink(linkintf,iobjectlink(ba),@dest);
  end;
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
               const source: tlinkedpersistent; var dest: tlinkedpersistent;
               const ainterfacetype: pointer = nil);
var
 ba: tlinkedpersistent;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,iobjectlink(source),@dest,ainterfacetype);
  end;
  if ba <> nil then begin
   unlink(linkintf,iobjectlink(ba),@dest);
  end;
 end;
end;

procedure tobjectlinker.setlinkedvar(const linkintf: iobjectlink; 
              const source: tmsecomponent; var dest: tmsecomponent;
              const ainterfacetype: pointer = nil);
var
 ba: tmsecomponent;
begin
 if source <> dest then begin
  ba:= dest;
  dest:= source;
  if source <> nil then begin
   link(linkintf,ievent(source),@dest,ainterfacetype);
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

procedure tobjectlinker.forall(const proc: objectlinkprocty; 
                                              const ainterfacetype: pointer);
var
 po1: plinkinfoty;
 int1: integer;
begin
 inc(fnopack);
 try
  for int1:= 0 to fcount - 1 do begin
   po1:= @plinkinfoaty(fdata)^[int1];
   if (po1^.dest <> nil) and odd(ptruint(po1^.source)) and 
                             (ainterfacetype = po1^.interfacetype) then begin
    proc(po1^);
   end;
  end;
 finally
  dec(fnopack);
 end;
end;

procedure tobjectlinker.forall(const proc: objectlinkintfprocty; 
                                              const ainterfacetype: pointer);
var
 po1: plinkinfoty;
 int1: integer;
begin
 inc(fnopack);
 try
  for int1:= 0 to fcount - 1 do begin
   po1:= @plinkinfoaty(fdata)^[int1];
   if (po1^.dest <> nil) and odd(ptruint(po1^.source)) and 
                             (ainterfacetype = po1^.interfacetype) then begin
    proc(po1^.dest);
   end;
  end;
 finally
  dec(fnopack);
 end;
end;

procedure tobjectlinker.forfirst(const proc: objectlinkfirstprocty; 
                                              const ainterfacetype: pointer);
var
 po1: plinkinfoty;
 int1: integer;
 bo1: boolean;
begin
 inc(fnopack);
 try
  bo1:= false;
  for int1:= 0 to fcount - 1 do begin
   po1:= @plinkinfoaty(fdata)^[int1];
   if (po1^.dest <> nil) and odd(ptruint(po1^.source)) and 
                             (ainterfacetype = po1^.interfacetype) then begin
    proc(po1^,bo1);
    if bo1 then begin
     break;
    end;
   end;
  end;
 finally
  dec(fnopack);
 end;
end;

procedure tobjectlinker.forfirst(const proc: objectlinkintffirstprocty; 
                                              const ainterfacetype: pointer);
var
 po1: plinkinfoty;
 int1: integer;
 bo1: boolean;
begin
 inc(fnopack);
 try
  bo1:= false;
  for int1:= 0 to fcount - 1 do begin
   po1:= @plinkinfoaty(fdata)^[int1];
   if (po1^.dest <> nil) and odd(ptruint(po1^.source)) and 
                             (ainterfacetype = po1^.interfacetype) then begin
    proc(po1^.dest,bo1);
    if bo1 then begin
     break;
    end;
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
  if (po1^.dest <> nil) and odd(ptruint(po1^.source)) then begin
   additem(pointerarty(result),iobjectlink(po1^.dest).getinstance);
  end;
  inc(po1);
 end;
 removearrayduplicates(pointerarty(result));
end;

function tobjectlinker.linkedobjects(
                                const ainterfacetype: pointer): objectarty;
var
 po1: plinkinfoty;
 int1: integer;
begin
 result:= nil;
 po1:= plinkinfoty(fdata);
 for int1:= 0 to fcount - 1 do begin
  if (po1^.dest <> nil) and odd(ptruint(po1^.source)) and 
                      (po1^.interfacetype = ainterfacetype) then begin
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
 freeandnil(fobjectlinker);
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
(*
{ tnullinterfacedobject }

function tnullinterfacedobject._addref: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject._release: integer; stdcall;
begin
 result:= -1;
end;

function tnullinterfacedobject.queryinterface(
 {$ifdef fpc_has_constref}constref{$else}const{$endif}iid: tguid;
  out obj): hresult; stdcall;
begin
 if getinterface(iid, obj) then begin
   result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;
*)
{ tnullinterfacedpersistent }
{$ifdef FPC}
function tnullinterfacedpersistent._addref: integer;
                   {$ifdef mswindows}stdcall{$else} cdecl{$endif};
begin
 result:= -1;
end;

function tnullinterfacedpersistent._release: integer;
                   {$ifdef mswindows}stdcall{$else} cdecl{$endif};
begin
 result:= -1;
end;

function tnullinterfacedpersistent.QueryInterface(
  {$ifdef fpc_has_constref}constref{$else}const{$endif} IID: TGUID;
  out Obj): HResult;
                     {$ifdef mswindows}stdcall{$else} cdecl{$endif};
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;
{$endif}

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
        {$ifdef FPC}@{$endif}writedummy,(filer.ancestor = nil) and isoptional);
 //in order to create optional instance
end;

function toptionalpersistent.isoptional: boolean;
begin
 result:= true;
end;

{ tlinkedpersistent }

destructor tlinkedpersistent.destroy;
begin
 inherited;
 freeandnil(fobjectlinker);
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

procedure tlinkedpersistent.setlinkedvar(const source: iobjectlink; var dest: iobjectlink;
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

procedure tlinkedpersistent.setlinkedvar(const source: tlinkedpersistent;
              var dest: tlinkedpersistent; const linkintf: iobjectlink = nil);
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

procedure tlinkedpersistent.objevent(const sender: iobjectlink;
                                               const event: objecteventty);
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
 freeandnil(fobjectlinker);
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

procedure tmsecomponent.setlinkedvar(const source: iobjectlink;
              var dest: iobjectlink; const linkintf: iobjectlink = nil);
begin
 if (fobjectlinker = nil) and (csdestroying in componentstate) then begin
  dest:= source;
 end
 else begin
  if linkintf = nil then begin
   getobjectlinker.setlinkedvar(ievent(self),source,dest);
  end
  else begin
   getobjectlinker.setlinkedvar(linkintf,source,dest);
  end;
 end;
end;

procedure tmsecomponent.setlinkedvar(const source: tmsecomponent;
                   var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 if (fobjectlinker = nil) and (csdestroying in componentstate) then begin
  dest:= source;
 end
 else begin
  if linkintf = nil then begin
   getobjectlinker.setlinkedvar(ievent(self),source,dest);
  end
  else begin
   getobjectlinker.setlinkedvar(linkintf,source,dest);
  end;
 end;
end;

procedure tmsecomponent.setlinkedvar(const source: tlinkedobject;
                   var dest: tlinkedobject; const linkintf: iobjectlink = nil);
begin
 if (fobjectlinker = nil) and (csdestroying in componentstate) then begin
  dest:= source;
 end
 else begin
  if linkintf = nil then begin
   getobjectlinker.setlinkedvar(ievent(self),source,dest);
  end
  else begin
   getobjectlinker.setlinkedvar(linkintf,source,dest);
  end;
 end;
end;

procedure tmsecomponent.setlinkedvar(const source: tlinkedpersistent;
                   var dest: tlinkedpersistent; const linkintf: iobjectlink = nil);
begin
 if (fobjectlinker = nil) and (csdestroying in componentstate) then begin
  dest:= source;
 end
 else begin
  if linkintf = nil then begin
   getobjectlinker.setlinkedvar(ievent(self),source,dest);
  end
  else begin
   getobjectlinker.setlinkedvar(linkintf,source,dest);
  end;
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

procedure tmsecomponent.asyncevent(atag: integer = 0;
                                    const aoptions: posteventoptionsty = []);
begin
 application.postevent(tasyncevent.create(ievent(self),atag),aoptions);
end;

procedure tmsecomponent.doasyncevent(var atag: integer);
begin
 //dummy
end;

procedure tmsecomponent.postcomponentevent(const event: tcomponentevent;
                                  const aoptions: posteventoptionsty = []);
begin
 event.create(event.kind,ievent(self));
 application.postevent(event,aoptions);
end;

{$ifdef FPC}

procedure tmsecomponent.setinline(value: boolean);
begin
 if value then begin
  include(fcomponentstate,csinline);
 end
 else begin
  exclude(fcomponentstate,csinline);
 end;
end;

procedure tmsecomponent.setancestor(value: boolean);
begin
 if value then begin
  include(fcomponentstate,csancestor);
 end
 else begin
  exclude(fcomponentstate,csancestor);
 end;
end;

{$endif FPC}

{$ifdef hascorbagetinterface}
function getcorbainterface(const aobject: tobject; const aintf: ptypeinfo;
                                   out obj) : boolean;
var
 typedata1: ptypedata;
 po1: pshortstring;
begin
 typedata1:= gettypedata(aintf);
 po1:= pshortstring(
        ptruint(@typedata1^.rawintfunit)+length(typedata1^.rawintfunit)+1);
 if po1^[0] <> #0 then begin
  result:= aobject.getinterfacebystr(po1^,obj); //works in FPC 2.4+
 end
 else begin
  pointer(obj):= nil;
  result:= false;
 end;
end;

{$else}

function getcorbainterface(const aobject: tobject; const aintf: ptypeinfo;
                                   out obj) : boolean;
var
 intf1: pinterfaceentry;
 typedata1: ptypedata;
 po1: pshortstring;
begin
// result:= getinterface(aintf,obj);
 typedata1:= gettypedata(aintf);
 {$ifdef FPC}
 po1:= pshortstring(
        ptruint(@typedata1^.rawintfunit)+length(typedata1^.rawintfunit)+1);
 if po1^[0] <> #0 then begin
  intf1:= aobject.getinterfaceentrybystr(po1^);
 end
 else begin
  intf1:= nil;
 end;
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
{$endif} //hascorbagetinterface

procedure nosupportfor(const sender: tcomponent; const avalue: tcomponent;
                          const ainterface: ptypeinfo);
begin
 raise exception.create(sender.name+': '+avalue.name+' does not provide '+
                             ainterface^.name+'.');
end;

procedure checkcorbainterface(const sender: tcomponent;
                           const avalue: tcomponent;
                           const ainterface: ptypeinfo; out obj);
begin
 if not getcorbainterface(avalue,ainterface,obj) then begin
  nosupportfor(sender,avalue,ainterface);
 end;  
end;

//function tmsecomponent.getcorbainterface(const aintf: tguid; out obj) : boolean;
function tmsecomponent.getcorbainterface(const aintf: ptypeinfo; out obj) : boolean;
begin
 result:= mseclasses.getcorbainterface(self,aintf,obj);
end;

function isinterface(const actual: ptypeinfo; const wanted: ptypeinfo): boolean;
var
 po1: ptypeinfo;
begin
{$ifdef FPC}
 result:= (actual^.kind = tkinterfaceraw) and (wanted^.kind = tkinterfaceraw);
 if result then begin
  po1:= actual;
  while po1 <> nil do begin
   if po1 = wanted then begin
    exit;
   end;
   po1:= gettypedata(po1)^.rawintfparent;
  end;
  result:= false;
 end
 else begin
{$endif}
  result:= (actual^.kind = tkinterface) and (wanted^.kind = tkinterface);
  if result then begin
   po1:= actual;
   while po1 <> nil do begin
    if po1 = wanted then begin
     exit;
    end;
    po1:= gettypedata(po1)^.intfparent{$ifndef FPC}^{$endif};
   end;
   result:= false;
  end;
{$ifdef FPC}
 end;
{$endif}
end;

function isinterfaceornil(const actual: ptypeinfo; const wanted: ptypeinfo): boolean;
begin
 result:= (actual = nil) or isinterface(actual,wanted);
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

function tmsecomponent.getcomponent: tcomponent;
begin
 result:= self;
end;

function tmsecomponent.getcomponentinstance: tcomponent;
begin
 result:= self;
end;

procedure tmsecomponent.getcompchildren(const proc: tgetchildproc;
                                                  const root: tcomponent);
var
 int1: integer;
 comp1: tcomponent;
begin
 if root = self then begin
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not (cssubcomponent in comp1.componentstyle) and
                   not comp1.hasparent or (comp1 is tmsedatamodule) then begin
    proc(comp1);
   end;
  end;
 end;
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
 include(fmsecomponentstate,cs_beginreadproc);
 try
  dobeginread;
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if (cssubcomponent in comp1.componentstyle) and 
             (comp1 is tmsecomponent) then begin
    tmsecomponent(comp1).beginread;
   end;
  end;
 finally
  exclude(fmsecomponentstate,cs_beginreadproc);
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

function tmsecomponent.getancestorclassname: string;
begin
 if fancestorclassname <> '' then begin
  result:= fancestorclassname;
 end
 else begin
  result:= getmoduleclassname;
 end;
end;

procedure tmsecomponent.readmoduleclassname(reader: treader);
begin
 reader.ReadString; //dummy
end;

procedure tmsecomponent.writemoduleclassname(writer: twriter);
begin
 writer.writestring(getancestorclassname);
end;

procedure tmsecomponent.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty(moduleclassnamename,
           {$ifdef FPC}@{$endif}readmoduleclassname,
           {$ifdef FPC}@{$endif}writemoduleclassname,
           (cs_ismodule in fmsecomponentstate) and (filer.Root = self) and
            ((filer.ancestor = nil) or 
               (tmsecomponent(filer.ancestor).getancestorclassname <> 
                                                     getancestorclassname)));
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

class function tmsecomponent.hasresource: boolean;
begin
 result:= false;
end;

function setclassname(const instance: tobject;
                   const aclassname: pshortstring): pshortstring;
var
 classnamepo: ppointer;
 {$ifdef mswindows}
 ca1: longword;
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
  if writer is twritermse then begin
   twritermse(writer).writecomponentdata(self);
  end
  else begin
   inherited;
  end;
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
 result.instance:= self;
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

procedure tmsecomponent.dobeginread;
begin
 //dummy
end;

procedure tmsecomponent.doendread;
begin
 //dummy
end;

procedure tmsecomponent.doafterload;
begin
 //dummy
end;
{
procedure tmsecomponent.getchildren1(const proc: tgetchildproc;
                                      const root: tcomponent);
begin
 //dummy
end;

procedure tmsecomponent.getchildren(proc: tgetchildproc; root: tcomponent);
var
 ev1: getchildreneventty; 
begin
 ev1:= onstreaminggetchildren;
 if assigned(ev1) then begin
  ev1(self,proc,root);
 end
 else begin
  getchildren1(proc,root);
 end;
end;
}
procedure tmsecomponent.updateskin(const recursive: boolean = false);
var
 int1: integer;
 comp1: tcomponent;
 methodpo: ^skineventty;
begin
 if componentstate*[csdesigning] = [] then begin
  methodpo:= {$ifndef FPC}@{$endif}@oninitskinobject;
 end
 else begin
//  methodpo:= {$ifndef FPC}@{$endif}@oninitskinobjectdesign;
  exit; //do nothing
 end;
 if assigned(methodpo^) then begin
  if recursive then begin
   for int1:= 0 to componentcount - 1 do begin
    comp1:= components[int1];
    if comp1 is tmsecomponent then begin
     tmsecomponent(comp1).updateskin(true);
    end;
   end;
  end;
  if hasskin then begin
//   if cs_skinloaded in fmsecomponentstate then begin
//    removeskin;
//   end;
   if assigned(fonbeforeupdateskin) then begin
    fonbeforeupdateskin(tobject(tmethod(methodpo^).data));
   end;
   methodpo^(skininfo);
//   include(fmsecomponentstate,cs_skinloaded);
   if assigned(fonbeforeupdateskin) then begin
    fonafterupdateskin(tobject(tmethod(methodpo^).data));
   end;   
  end;
 end;
end;
(*
procedure tmsecomponent.removeskin(const recursive: boolean = false);
var
 int1: integer;
 comp1: tcomponent;
 methodpo: ^skineventty;
begin
 if componentstate*[csdesigning] = [] then begin
  methodpo:= {$ifndef FPC}@{$endif}@onremoveskinobject;
 end
 else begin
  methodpo:= {$ifndef FPC}@{$endif}@onremoveskinobjectdesign;
 end;
 if assigned(methodpo^) then begin
  if recursive then begin
   for int1:= 0 to componentcount - 1 do begin
    comp1:= components[int1];
    if comp1 is tmsecomponent then begin
     tmsecomponent(comp1).removeskin(true);
    end;
   end;
  end;
  if hasskin and (cs_skinloaded in fmsecomponentstate) then begin
   methodpo^(skininfo);
   exclude(fmsecomponentstate,cs_skinloaded);
  end;
 end;
end;
*)
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

procedure tmsecomponent.setsubcompref;
begin
 setsubcomponent(true);
 include (fmsecomponentstate,cs_subcompref);
end;

procedure tmsecomponent.setchildorder(child: tcomponent; order: integer);
var
 int1,int2: integer;
begin
 int2:= -1;
 for int1:= 0 to componentcount-1 do begin
  if not components[int1].hasparent then begin //number simple owned only
   inc(int2);
   if int2 = order then begin
    child.componentindex:= int1;
    break;
   end;    
  end;
 end;
end;

{$ifdef mse_with_ifi}
procedure tmsecomponent.setifiserverintf(const aintf: iifiserver);
begin
 fifiserverintf:= aintf;
end;
{
function tmsecomponent.getifiserverintf: iifiserver;
begin
 result:= fifiserverintf;
end;
}
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
 //dummy
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

constructor tobjectlinkrecordlist.create(arecordsize: integer; aoptions: recordliststatesty = []);
begin
 inherited create(arecordsize,aoptions+[rels_needsfinalize]);
 fobjectlinker:= tobjectlinker.create(iobjectlink(self),nil);
end;

destructor tobjectlinkrecordlist.destroy;
begin
 inherited;
 fobjectlinker.free;
end;

procedure tobjectlinkrecordlist.finalizerecord(var item);
begin
 dounlink(item)
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
  itemdestroyed(sender);
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

Type
  TPosComponent = Class(TObject)
    FPos : Integer;
    FComponent : TComponent;
    Constructor Create(APos : Integer; AComponent : TComponent);
  end;

Constructor TPosComponent.Create(APos : Integer; AComponent : TComponent);

begin
  FPos:=APos;
  FComponent:=AComponent;
end;

{ twritermse }

constructor twritermse.create(const stream: tstream; const bufsize: integer;
                       const anoancestor: boolean = false;
                       const amasterancestor: boolean = false);
begin
// fgetchildrenbefore:= onstreaminggetchildren;
// onstreaminggetchildren:= @dogetchildren;
 fnoancestor:= anoancestor;
 fmasterancestor:= amasterancestor;
 inherited create(stream,bufsize);
end;

destructor twritermse.destroy;
begin
 inherited;
// onstreaminggetchildren:= fgetchildrenbefore;
end;

function twritermse.rootcompname(const acomp: tcomponent;
               const aroot: tcomponent): string;
var
 comp1: tcomponent;
begin
 result:= acomp.name;
 comp1:= acomp.owner;
 while (comp1 <> aroot) and (comp1 <> nil) do begin
  result:= comp1.name+'.'+result;
  comp1:= comp1.owner;
 end;
end;

function twritermse.rootcompname(const acomp: tcomponent;
               arootlevel: integer): string;
var
 comp1: tcomponent;
begin
 result:= acomp.name;
 comp1:= acomp.owner;
 while (arootlevel > 0) and (comp1 <> nil) do begin
  result:= comp1.name+'.'+result;
  comp1:= comp1.owner;
  dec(arootlevel);
 end;
end;

// Used as argument for calls to TComponent.GetChildren:
procedure TWritermse.AddToAncestorList(Component: TComponent);
begin
 FAncestors.AddObject(rootcompname(Component,fancestorlookuplevel),
                        TPosComponent.Create(FAncestors.Count,Component));
end;


procedure TWritermse.DetermineAncestor(Component : TComponent);

Var
  I : Integer;
 comp1: tcomponent;
 int1: integer;
begin
  // Should be set only when we write an inherited with children.
 if Not Assigned(FAncestors) then begin
  exit;
 end;
 comp1:= froot;
 for int1:= fancestorlookuplevel-1 downto 0 do begin
  comp1:= comp1.owner;
 end;
 if comp1 = nil then begin
  comp1:= flookuproot; //should not happen
 end;
 I:=FAncestors.IndexOf(rootcompname(Component,comp1));
 If (I=-1) then
   begin
   FAncestor:=Nil;
   FAncestorPos:=-1;
   end
 else begin
  With TPosComponent(FAncestors.Objects[i]) do begin
   FAncestor:=FComponent;
   FAncestorPos:=FPos;
  end;
 end;
end;

procedure TWritermse.DoFindAncestor(Component : TComponent);

Var
  C : TComponent;

begin
 if Assigned(FOnFindAncestor) then
   if (Ancestor=Nil) or (Ancestor is TComponent) then
     begin
     C:=TComponent(Ancestor);
     FOnFindAncestor(Self,Component,Component.Name,C,FRootAncestor);
     Ancestor:=C;
     end;
 if frootrootancestor = nil then begin
  frootrootancestor:= tcomponent(fancestor);
 end;
end;

procedure TWritermse.WriteComponent(Component: TComponent);

var
  SA : TPersistent;
  SR, SRA : TComponent;
begin
 SR:=FRoot;
 SA:=FAncestor;
 SRA:=FRootAncestor;
 inc(fchildlevel);
 Try
{$warnings off}
   tcomponent1(Component).FComponentState:=
              tcomponent1(Component).FComponentState+[csWriting];
{$warnings on}
   Try
    if not fnoancestor or (csinline in component.componentstate) or
                                                (fchildlevel > 1) then begin
     // Possibly set ancestor.
     DetermineAncestor(Component);
     DoFindAncestor(Component);
           // Mainly for IDE when a parent form had an ancestor renamed...
    end;
    tcomponent1(Component).WriteState(Self);
          // Will call WriteComponentData.
   {$ifdef FPC}
    FDriver.EndList;
   {$else}
    writelistend;
   {$endif}
   Finally
{$warnings off}
     tcomponent1(Component).FComponentState:=
                  tcomponent1(Component).FComponentState-[csWriting];
{$warnings on}
   end;
 Finally
  dec(fchildlevel);
  FAncestor:=SA;
  FRoot:=SR;
  FRootAncestor:=SRA;
 end;
end;

procedure TWritermse.WriteChildren(Component : TComponent);

Var
  SRoot, SRootA : TComponent;
  SList : TStringList;
  SPos : Integer;
  I : Integer;
  ancestorlookuplevelbefore: integer;
  rootrootancestorbefore: tcomponent;
  
begin
 // Write children list. 
 // While writing children, the ancestor environment must be saved
 // This is recursive...
 SRoot:=FRoot;
 SRootA:=FRootAncestor;
 SList:=FAncestors;
 SPos:=FCurrentPos;
 ancestorlookuplevelbefore:= fancestorlookuplevel;
 rootrootancestorbefore:= frootrootancestor;
 try
   FAncestors:=Nil;
   FCurrentPos:=0;
   FAncestorPos:=-1;
   if csInline in Component.ComponentState then
      FRoot:=Component;
   if (FAncestor is TComponent) then
      begin
      FAncestors:=TStringList.Create;
      if csInline in TComponent(FAncestor).ComponentState then begin
       FRootAncestor := TComponent(FAncestor);
       if frootrootancestor <> frootancestor then begin
        inc(fancestorlookuplevel);
       end;
      end;
//       TComponent1(FAncestor).GetChildren(@AddToAncestorList,frootancestor);
      GetChildren1(tcomponent(FAncestor),{$ifdef FPC}@{$endif}AddToAncestorList,frootancestor);
      FAncestors.Sorted:=True;
      end;
   try
//      tcomponent1(Component).GetChildren(@WriteComponent, FRoot);
     GetChildren1(component,{$ifdef FPC}@{$endif}WriteComponent, FRoot);
   Finally
     If Assigned(Fancestors) then
       For I:=0 to FAncestors.Count-1 do
         FAncestors.Objects[i].Free;
     FreeAndNil(FAncestors);
   end;    
 finally
  FAncestors:=Slist;
  FRoot:=SRoot;
  FRootAncestor:=SRootA;
  FCurrentPos:=SPos;
  FAncestorPos:=Spos;
  fancestorlookuplevel:= ancestorlookuplevelbefore;
  frootrootancestor:= rootrootancestorbefore;
 end;
end;

procedure TWritermse.WriteComponentData(Instance: TComponent);
var
  Flags: TFilerFlags;
begin
 Flags := [];
 If (Assigned(FAncestor)) and  //has ancestor
    (not (csInline in Instance.ComponentState) or // no inline component
     // .. or the inline component is inherited
     (csAncestor in Instance.Componentstate) and (FAncestors <> nil)) then
   Flags:=[ffInherited]
 else If csInline in Instance.ComponentState then
   Flags:=[ffInline];
 If (FAncestors<>Nil) and ((FCurrentPos<>FAncestorPos) or (FAncestor=Nil)) then
   Include(Flags,ffChildPos);
 FDriver.BeginComponent(Instance,Flags,FCurrentPos);
 If (FAncestors<>Nil) then
   Inc(FCurrentPos);
 WriteProperties(Instance);
 WriteListEnd;
 // Needs special handling of ancestor.
 If not IgnoreChildren then begin
   WriteChildren(Instance);
 end;
end;
{
procedure twritermse.dogetchildren(const sender: tmsecomponent;
               const proc: tgetchildproc; const aroot: tcomponent);
var
 root1: tcomponent;
 comp1,comp2: tcomponent;
 int1: integer;
begin
 comp1:= aroot;
 if aroot = rootancestor then begin
  comp2:= frootrootancestor;
  int1:= fancestorlookuplevel;
  try 
   while (comp1 <> nil) and (fancestorlookuplevel >= 0) do begin
    tmsecomponent(sender).getchildren1(proc,comp1);
    comp1:= comp1.owner;
    dec(fancestorlookuplevel);
   end;
  finally
   fancestorlookuplevel:= int1;
  end;
 end
 else begin
  comp2:= frootroot;
  while comp1 <> nil do begin
   tmsecomponent(sender).getchildren1(proc,comp1);
   if comp1 = comp2 then begin
    break;
   end;
   comp1:= comp1.owner;
  end;
 end;
end;
}
procedure twritermse.getchildren1(const acomp: tcomponent;
               const proc: tgetchildproc; const aroot: tcomponent);
   //support for added components to submodules
var
// root1: tcomponent;
 comp1,comp2: tcomponent;
 int1: integer;
begin
 comp1:= aroot;
 if aroot = rootancestor then begin
  comp2:= frootrootancestor;
  int1:= fancestorlookuplevel;
  try 
   while (comp1 <> nil) and (fancestorlookuplevel >= 0) do begin
    tcomponent1(acomp).getchildren(proc,comp1);
    comp1:= comp1.owner;
    dec(fancestorlookuplevel);
   end;
  finally
   fancestorlookuplevel:= int1;
  end;
 end
 else begin
  comp2:= frootroot;
  while comp1 <> nil do begin
   tcomponent1(acomp).getchildren(proc,comp1);
   if comp1 = comp2 then begin
    break;
   end;
   comp1:= comp1.owner;
  end;
 end;
end;

procedure twritermse.writedescendent(const aroot: tcomponent;
               const aancestor: tcomponent);
begin
 frootrootancestor:= aancestor;
 frootroot:= aroot;
 FRoot := ARoot;
 FAncestor := AAncestor;
 FRootAncestor := AAncestor;
 FLookupRoot := ARoot;

 WriteComponent(ARoot);
// inherited writedescendent(aroot,aancestor);
end;

procedure twritermse.writerootcomponent(aroot: tcomponent);
begin
 writedescendent(aroot,nil);
end;

initialization
 loadmoduletracker:= tloadmoduletracker.create;
{$ifdef FPC}
 registerinitcomponenthandler(tmsecomponent,@initmsecomponent1);
{$endif}
 registerfindglobalcomponentproc({$ifdef FPC}@{$endif}findmodulebyname);
finalization
 freeandnil(fmodules);
 freeandnil(floadedlist);
{$ifdef FPC}
// unregisterinitcomponenthandler(tcomponent,@initmsecomponent);
{$endif}
 unregisterfindglobalcomponentproc({$ifdef FPC}@{$endif}findmodulebyname);
 loadmoduletracker.free;
 freeandnil(objectdatalist);
end.
