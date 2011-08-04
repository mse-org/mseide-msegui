{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepropertyeditors;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 Classes,TypInfo,msedesignintf,msetypes,msestrings,sysutils,msedatalist,msemenus,
 mseevent,msegui,mseglob,mseguiglob,
 mseclasses,mseforms,msegraphics,mserichstring;

const
 bmpfiledialogstatname = 'bmpfile.sta';
 numcharchar = msechar('[');
  
type

 defaultenumerationty = (null);
 defaultsetty = set of defaultenumerationty;

 tpropertyeditor = class;
 propertyeditorarty = array of tpropertyeditor;

 propinstancety = record
  instance: tobject;
  propinfo: ppropinfo;
 end;
 propinstancearty = array of propinstancety;
 ppropinstancearty = ^propinstancearty;

 iobjectinspector = interface(inullinterface)
  procedure propertymodified(const sender: tpropertyeditor);
  function getproperties(const objects: objectarty;
                          const amodule: tmsecomponent;
                          const acomponent: tcomponent): propertyeditorarty;
//  procedure componentnamechanged(comp: tcomponent; newname: string);
  function getmatchingmethods(const sender: tpropertyeditor; atype: ptypeinfo): msestringarty;
 end;

 propertystatety = (ps_expanded,ps_subproperties,ps_volatile,
                   ps_refresh, //needs refresh by modified
                   ps_valuelist,ps_dialog,ps_sortlist,ps_owned,
                   ps_noadditems,ps_nodeleteitems,
                   ps_isordprop,ps_modified,ps_candefault,ps_component,ps_subprop,
                   ps_selected,ps_canselect,ps_refreshall,
                   ps_local,  //do not display foreign components
                   ps_link);  //do not display selected components
 propertystatesty = set of propertystatety;

 iremotepropertyeditor = interface(inullinterface)
  function getordvalue(const index: integer = 0): integer;
  procedure setordvalue(const value: longword); overload;
  procedure setordvalue(const index: integer; const value: longword); overload;
  procedure setbitvalue(const value: boolean; const bitindex: integer);
  function getint64value(const index: integer = 0): int64;
  procedure setint64value(const value: int64); overload;
  procedure setint64value(const index: integer; const value: int64); overload;
  function getpointervalue(const index: integer = 0): pointer;
  procedure setpointervalue(const value: pointer); overload;
  procedure setpointervalue(const index: integer; const value: pointer); overload;
  function getfloatvalue(const index: integer = 0): extended;
  procedure setfloatvalue(const value: extended);
  function getcurrencyvalue(const index: integer = 0): currency;
  procedure setcurrencyvalue(const value: currency);
  function getstringvalue(const index: integer = 0): string;
  procedure setstringvalue(const value: string);
  function getmsestringvalue(const index: integer = 0): msestring;
  procedure setmsestringvalue(const value: msestring);
  function getvariantvalue(const index: integer = 0): variant;
  procedure setvariantvalue(const value: variant);
  function getparenteditor: tpropertyeditor;

  function getmethodvalue(const index: integer = 0): tmethod;
  procedure setmethodvalue(const value: tmethod);
  function getselected: boolean;
  procedure setselected(const avalue: boolean);
  property selected: boolean read getselected write setselected;
  function getselectedpropinstances: objectarty;
 end;

 tpropertyeditor = class(tnullinterfacedobject)
  private
   function getexpanded: boolean;
   procedure setexpanded(const Value: boolean);
   function getcount: integer;
   function getselected: boolean;
   procedure setselected(const avalue: boolean);
  protected
   fsortlevel: integer;
   ftypeinfo: ptypeinfo;
   fstate: propertystatesty;
   fparenteditor: tpropertyeditor;
   fname: msestring;
   fdesigner: idesigner;
   fmodule: tmsecomponent;
   fcomponent: tcomponent;
   fobjectinspector: iobjectinspector;
   fprops: propinstancearty;
   fremote: iremotepropertyeditor;
   procedure properror;

   function instance(const index: integer = 0): tobject;
   function typedata: ptypedata;

   function getordvalue(const index: integer = 0): integer;
   procedure setordvalue(const value: longword); overload;
   procedure setordvalue(const index: integer; const value: longword); overload;
   function getint64value(const index: integer = 0): int64;
   procedure setint64value(const value: int64); overload;
   procedure setint64value(const index: integer; const value: int64); overload;
   function getpointervalue(const index: integer = 0): pointer;
   procedure setpointervalue(const value: pointer); overload;
   procedure setpointervalue(const index: integer; const value: pointer); overload;

   procedure setbitvalue(const value: boolean; const bitindex: integer);
   function getfloatvalue(const index: integer = 0): extended;
   procedure setfloatvalue(const value: extended);
   function getcurrencyvalue(const index: integer = 0): currency;
   procedure setcurrencyvalue(const value: currency);
   function getstringvalue(const index: integer = 0): string;
   procedure setstringvalue(const value: string);
   function getmsestringvalue(const index: integer = 0): msestring;
   procedure setmsestringvalue(const value: msestring);
   function getvariantvalue(const index: integer = 0): variant;
   procedure setvariantvalue(const value: variant);
   
   function decodemsestring(const avalue: msestring): msestring;
   function encodemsestring(const avalue: msestring): msestring;

   function getmethodvalue(const index: integer = 0): tmethod;
   procedure setmethodvalue(const value: tmethod);
   function getparenteditor: tpropertyeditor;
   function queryselectedpropinstances: objectarty;

   procedure modified; virtual;
   function getdefaultstate: propertystatesty; virtual;
   procedure setsubprop; virtual;
   function getvalueeditor: tpropertyeditor; virtual;
   function getlinksource: tcomponent; virtual;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo); virtual;
   destructor destroy; override;
   procedure setremote(intf: iremotepropertyeditor);
   procedure updatedefaultvalue; virtual;
   function canrevert: boolean; virtual;
   procedure copyproperty(const asource: tobject); virtual;

   function propertyname: msestring; virtual;
   function name: msestring; virtual;
   function allequal: boolean; virtual;
   function subproperties: propertyeditorarty; virtual;
   function props: propinstancearty;
   function rootprops: propinstancearty;
   function propowner: componentarty;
             //value of classproperty

   procedure setvalue(const value: msestring); virtual;
   function getvalue: msestring; virtual;
   function getvalues: msestringarty; virtual;
   property state: propertystatesty read fstate;
   function sortlevel: integer;
   procedure dragbegin(var accept: boolean); virtual;
   procedure dragover(const sender: tpropertyeditor; var accept: boolean); virtual;
   procedure dragdrop(const sender: tpropertyeditor); virtual;
   procedure dopopup(var amenu: tpopupmenu;  const atransientfor: twidget;
                var mouseinfo: mouseeventinfoty); virtual;
   procedure edit; virtual;
   property count: integer read getcount;
   property expanded: boolean read getexpanded write setexpanded;
   property selected: boolean read getselected write setselected;
   property module: tmsecomponent read fmodule;
   property component: tcomponent read fcomponent;
   property valueeditor: tpropertyeditor read getvalueeditor;
   property linksource: tcomponent read getlinksource;
  end;

 propertyeditorclassty = class of tpropertyeditor;

 tstringpropertyeditor = class(tpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 trefreshstringpropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;
 
 tnamepropertyeditor = class(tstringpropertyeditor)
  procedure setvalue(const value: msestring); override;
 end;
 
 tfontnamepropertyeditor = class(tstringpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function getvalues: msestringarty; override;
 end;

 tmsestringpropertyeditor = class(tpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 tordinalpropertyeditor = class(tpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 tint64propertyeditor = class(tpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 tcharpropertyeditor = class(tordinalpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;
 
 twidecharpropertyeditor = class(tordinalpropertyeditor)
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;
 
 tbooleanpropertyeditor = class(tordinalpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
 end;
 
 tvolatilebooleanpropertyeditor = class(tbooleanpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 trefreshbooleanpropertyeditor = class(tbooleanpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 trealpropertyeditor = class(tpropertyeditor)
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;
 
 trealtypropertyeditor = class(tpropertyeditor)
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 tcurrencypropertyeditor = class(tpropertyeditor)
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;
 
 tdatetimepropertyeditor = class(tpropertyeditor)
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;

 tvariantpropertyeditor = class(tpropertyeditor)
  protected
  public
   function allequal: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
 end;
 
 tenumpropertyeditor = class(tordinalpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function gettypeinfo: ptypeinfo; virtual;
  public
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
 end;

 tshortcutpropertyeditor = class(tenumpropertyeditor)
  protected
   fsc1: boolean;
   function getvaluetext(avalue: shortcutty): msestring;
   function texttovalue(const atext: msestring): shortcutty;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo); override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
 end;

 tcolorpropertyeditor = class(tenumpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
 end;

 tclasspropertyeditor = class(tpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
   function checkfreeoptionalclass: boolean;
  public
   function getvalue: msestring; override;
   function subproperties: propertyeditorarty; override;
 end;

 toptionalclasspropertyeditor = class(tclasspropertyeditor)
  protected
   function getniltext: string; virtual;
   function getinstance: tpersistent; virtual;
   function getdefaultstate: propertystatesty; override;
   procedure deleteinstance;
  public
   function canrevert: boolean; override;
   procedure setvalue(const avalue: msestring); override;
   function getvalue: msestring; override;
   procedure edit; override;
 end;

 ppersistent = ^tpersistent;
 tparentclasspropertyeditor = class(toptionalclasspropertyeditor)
  protected
   function getniltext: string; override;
   function getinstancepo(acomponent: tobject): ppersistent; virtual; abstract;
   function getinstance: tpersistent; override;
  public
   function subproperties: propertyeditorarty; override;
   procedure edit; override;
 end;

 tparentfontpropertyeditor = class(tparentclasspropertyeditor)
  protected
   function getinstancepo(acomponent: tobject): ppersistent; override;
 end;


        //no solution found to link to streamed tpersistent or tobject,
        //fork of classes.pp necessary. :-(
{
 tlinkedobjectpropertyeditor = class(tclasspropertyeditor)
  protected
//   function issubcomponent(const index: integer = 0): boolean;
   function getdefaultstate: propertystatesty; override;
   procedure checkobj(const avalue: tobject); virtual;
   function filterobj(const aobj: tobject): boolean; virtual;
  public
   function allequal: boolean; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function getvalues: msestringarty; override;
 end;
}
 tcomponentpropertyeditor = class(tclasspropertyeditor)
  protected
   function issubcomponent(const index: integer = 0): boolean; virtual;
   function getdefaultstate: propertystatesty; override;
   procedure checkcomponent(const avalue: tcomponent); virtual;
   function filtercomponent(const acomponent: tcomponent): boolean; virtual;
   function getlinksource: tcomponent; override;
  public
   procedure edit; override;
   function allequal: boolean; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function getvalues: msestringarty; override;
 end;

 tsubcomponentpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function issubcomponent(const index: integer = 0): boolean; override;
 end;
 
 tcomponentinterfacepropertyeditor = class(tcomponentpropertyeditor)
  private
   fintfinfo: ptypeinfo;
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
   function getintfinfo: ptypeinfo; virtual; abstract;
  public
   procedure updatedefaultvalue; override;
 end;
 
 tsisterwidgetpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
   function getdefaultstate: propertystatesty; override;
  public
//   function getvalues: msestringarty; override;
 end;
  
 tchildwidgetpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function getvalues: msestringarty; override;
 end;
 
 tlocalcomponentpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 tlocallinkcomponentpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;
  
 tsetpropertyeditor = class;
 tsetelementeditor = class(tpropertyeditor)
  protected
//   fparent: tsetpropertyeditor;
   findex: integer;
   function getdefaultstate: propertystatesty; override;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo;
            const aparent: tsetpropertyeditor; const aindex: integer);
                             reintroduce; virtual;
   procedure updatedefaultvalue; override;
   function canrevert: boolean; override;
   function allequal: boolean; override;
   function propertyname: msestring; override;
   function name: msestring; override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
   procedure setvalue(const value: msestring); override;
 end;

 tsetpropertyeditor = class(tordinalpropertyeditor)
  protected
   finvisibleitems: tintegerset;
   function getdefaultstate: propertystatesty; override;
   function getinvisibleitems: tintegerset; virtual;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo); override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function subproperties: propertyeditorarty; override;
 end;

 tmethodpropertyeditor = class(tpropertyeditor)
  public
   constructor create(const adesigner: idesigner;
            const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); override;
   function getdefaultstate: propertystatesty; override;
   function allequal: boolean; override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
   procedure setvalue(const value: msestring); override;
   function method: tmethod;
 end;

 tdialogclasspropertyeditor = class(tclasspropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
 end;

 tbitmappropertyeditor = class(tdialogclasspropertyeditor)
  public
   procedure edit; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;

 tstringspropertyeditor = class(tdialogclasspropertyeditor)
  protected
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
  public
   procedure edit; override;
   function getvalue: msestring; override;
 end;

 ttextstringspropertyeditor = class(tdialogclasspropertyeditor)
  protected
   fmodalresult: modalresultty;
   forigtext: msestringarty;
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   procedure doafterclosequery(var amodalresult: modalresultty); virtual;                    
   function getsyntaxindex: integer; virtual;
   function gettestbutton: boolean; virtual;
   function getutf8: boolean; virtual;
   function getcaption: msestring; virtual;
   procedure updateline(var aline: ansistring); virtual;
   function ismsestring: boolean; virtual;
  public
   procedure edit; override;
   procedure setvalue(const avalue: msestring); override;
   function getvalue: msestring; override;
 end;

 listeditformkindty = (lfk_none,lfk_msestring,lfk_real,lfk_integer,
                       lfk_msestringint,lfk_complex);
 
 tdatalistpropertyeditor = class(tdialogclasspropertyeditor)
  protected
   formkind: listeditformkindty;
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   procedure checkformkind;
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
   function getvalue: msestring; override;
 end;
 
 tmsestringdatalistpropertyeditor = class(tdialogclasspropertyeditor)
   procedure edit; override;
   function getvalue: msestring; override;
  protected
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   function getdefaultstate: propertystatesty; override;
 end;

 tdoublemsestringdatalistpropertyeditor = class(tdialogclasspropertyeditor)
   procedure edit; override;
   function getvalue: msestring; override;
  protected
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   function getdefaultstate: propertystatesty; override;
 end;

 tmsestringintdatalistpropertyeditor = class(tdialogclasspropertyeditor)
   procedure edit; override;
   function getvalue: msestring; override;
  protected
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   function getdefaultstate: propertystatesty; override;
 end;

const
 propmaxarraycount = 100;

type

 tarraypropertyeditor = class;

 tarrayelementeditor = class(tpropertyeditor,iremotepropertyeditor)
  private
   feditor: tpropertyeditor;
  protected
   findex: integer;
   procedure doinsert(const sender: tobject);
   procedure doappend(const sender: tobject);
   procedure dodelete(const sender: tobject);

   function getordvalue(const index: integer = 0): integer;
   procedure setordvalue(const value: longword); overload;
   procedure setordvalue(const index: integer; const value: longword); overload;
   function getint64value(const index: integer = 0): int64;
   procedure setint64value(const value: int64); overload;
   procedure setint64value(const index: integer; const value: int64); overload;
   function getpointervalue(const index: integer = 0): pointer;
   procedure setpointervalue(const value: pointer); overload;
   procedure setpointervalue(const index: integer; const value: pointer); overload;

   procedure setbitvalue(const value: boolean; const bitindex: integer);
   function getfloatvalue(const index: integer = 0): extended;
   procedure setfloatvalue(const value: extended);
   function getstringvalue(const index: integer = 0): string;
   procedure setstringvalue(const value: string);
   function getmsestringvalue(const index: integer = 0): msestring;
   procedure setmsestringvalue(const value: msestring);
   function getselectedpropinstances: objectarty; virtual;

   function getdefaultstate: propertystatesty; override;
   function getvalueeditor: tpropertyeditor; override;
   function getlinksource: tcomponent; override;
  public
   constructor create(aindex: integer; aparenteditor: tarraypropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); reintroduce;
                                                         virtual;
   destructor destroy; override;
   function canrevert: boolean; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
   procedure edit; override;
   function name: msestring; override;
   function subproperties: propertyeditorarty; override;
   procedure dragbegin(var accept: boolean); override;
   procedure dragover(const sender: tpropertyeditor; var accept: boolean); override;
   procedure dragdrop(const sender: tpropertyeditor); override;
   procedure dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                          var mouseinfo: mouseeventinfoty); override;
 end;

 elementeditorclassty = class of tarrayelementeditor;
 elementeditorarty = array of tarrayelementeditor;
  
 tarraypropertyeditor = class(tclasspropertyeditor)
  private
   fsubprops: elementeditorarty;
   procedure doappend(const sender: tobject);
  protected
   function getdefaultstate: propertystatesty; override;
   function geteditorclass: propertyeditorclassty; virtual;
   function getelementeditorclass: elementeditorclassty; virtual;
   procedure itemmoved(const source,dest: integer); virtual;
  public
   function itemprefix: msestring; virtual;
   procedure move(const curindex,newindex: integer); virtual;
   function allequal: boolean; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function subproperties: propertyeditorarty; override;
   function name: msestring; override;
   procedure dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                          var mouseinfo: mouseeventinfoty); override;
 end;
 
  tconstelementeditor = class(tarrayelementeditor)
  protected
   fvalue: msestring;
  public
   constructor create(const avalue: msestring;
            aindex: integer; aparenteditor: tarraypropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); reintroduce;
   procedure dragdrop(const sender: tpropertyeditor); override;
   function getvalue: msestring; override;
 end;

 tconstarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function allequal: boolean; override;
   function getvalue: msestring; override;
   function name: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;

 tcollectionpropertyeditor = class;
 
 tcollectionitemeditor = class(tpropertyeditor,iremotepropertyeditor)
  private
   findex: integer;
   feditor: tpropertyeditor;
  protected
   function getdefaultstate: propertystatesty; override;
//   function getordvalue(const index: integer = 0): integer;
//   procedure setordvalue(const value: longword); overload;
//   procedure setordvalue(const index: integer; const value: longword); overload;
   function getpointervalue(const index: integer = 0): pointer;
   procedure setpointervalue(const value: pointer); overload;
   procedure setpointervalue(const index: integer; const value: pointer); overload;
   procedure doinsert(const sender: tobject);
   procedure doappend(const sender: tobject);
   procedure dodelete(const sender: tobject);
   function getselectedpropinstances: objectarty;
  public
   constructor create(aindex: integer; aparenteditor: tcollectionpropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); reintroduce;
   destructor destroy; override;
   procedure setvalue(const value: msestring); override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
   procedure edit; override;
   function subproperties: propertyeditorarty; override;
   function name: msestring; override;
   
   procedure dragbegin(var accept: boolean); override;
   procedure dragover(const sender: tpropertyeditor; var accept: boolean); override;
   procedure dragdrop(const sender: tpropertyeditor); override;
   procedure dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                          var mouseinfo: mouseeventinfoty); override;
 end;
 
 collectionitemeditorclassty = class of tcollectionitemeditor;
  
 tcollectionpropertyeditor = class(tclasspropertyeditor)
  private
   procedure doappend(const sender: tobject);
  protected
   function getdefaultstate: propertystatesty; override;
   procedure itemmoved(const source,dest: integer); virtual;
  public
   function name: msestring; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function subproperties: propertyeditorarty; override;
   procedure dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                          var mouseinfo: mouseeventinfoty); override;
 end;
 
 tpersistentarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 toptionalpersistentarraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function getniltext: string; virtual;
   function getinstance: tpersistent; virtual;
   function getdefaultstate: propertystatesty; override;
  public
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   procedure edit; override;
 end;

 tmenuarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

{
 tordinalelementeditor = class(tarrayelementeditor)
  public
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;
}
 tclasselementeditor = class(tclasspropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   function getvalue: msestring; override;
 end;

 tmenuelementeditor =  class(tclasselementeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tintegerarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tsetarrayelementeditor = class(tarrayelementeditor)
  public
   constructor create(aindex: integer; aparenteditor: tarraypropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); override;
 end;
{
 tsetarrayelementpropertyeditor = class(tsetpropertyeditor)
  public
   function subproperties: propertyeditorarty; override;
 end;
}
 tsetarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function getelementeditorclass: elementeditorclassty; override;
   function geteditorclass: propertyeditorclassty; override;
 end;

 tcolorarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;

 tstringarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
   
 tmsestringarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
 trealarraypropertyeditor = class(tarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
 trecordpropertyeditor = class(tpropertyeditor)
  private
   fsubproperties: propertyeditorarty;
//   fname: string;
  protected
   function getdefaultstate: propertystatesty; override;
   procedure setsubprop; override;
  public
   constructor create(const adesigner: idesigner;
            const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector; const aname: string;
            const subprops: propertyeditorarty); reintroduce;
   destructor destroy; override;
   function allequal: boolean; override;
//   function name: msestring; override;
   function subproperties: propertyeditorarty; override;
   function getvalue: msestring; override;
 end;

 propertyeditorinfoty = record
  propertytype: ptypeinfo;
  propertyownerclass: tclass;
  propertyname: string;
  editorclass: propertyeditorclassty;
  editorclasslevel: integer;
 end;
 ppropertyeditorinfoty = ^propertyeditorinfoty;

 tpropertyeditors = class(tdynamicdatalist)
  private
   function getitems(const index: integer): ppropertyeditorinfoty;
  protected
   procedure freedata(var data); override;
   procedure copyinstance(var data); override;
   procedure add(apropertytype: ptypeinfo;
     apropertyownerclass: tclass; const apropertyname: string;
       aeditorclass: propertyeditorclassty);
  public
   constructor create; override;
   function geteditorclass(apropertytype: ptypeinfo;
     apropertyownerclass: tclass; apropertyname: string): propertyeditorclassty;
   property items[const index: integer]: ppropertyeditorinfoty read getitems; default;
 end;

var
 fontaliasnames: msestringarty;

function textpropertyfont: tfont; 
function propertyeditors: tpropertyeditors;
procedure registerpropertyeditor(propertytype: ptypeinfo;
  propertyownerclass: tclass; const propertyname: string;
  editorclass: propertyeditorclassty);
function imagefilepropedit(out afilename: filenamety;
                                         out aformat: string): modalresultty;
function getcomponentpropname(const acomp: tcomponent): msestring;
  
implementation
uses
 mseformatstr,msebits,msearrayprops,msebitmap,
 msefiledialog,mseimagelisteditor,msereal,msewidgets,
 mseactions,msehash,msegraphutils,
 msestringlisteditor,msedoublestringlisteditor,msestringintlisteditor,
 msereallisteditor,msedoublereallisteditor,msecomptree,
 mseintegerlisteditor,mseact,
 msecolordialog,msememodialog,
 mseshapes,msestockobjects,msetexteditor,
 msegraphicstream,
 mseformatbmpicoread{$ifdef FPC},mseformatjpgread,mseformatpngread,
 mseformatpnmread,mseformattgaread,mseformatxpmread{$endif},
 msestat,msestatfile,msefileutils,
 msedesigner,variants;

const
 methodsortlevel = 100;
 falsename = 'False';
 truename = 'True';

type
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 tcustomcaptionframe1 = class(tcustomcaptionframe);
 tdesigner1 = class(tdesigner);
 tdatalist1 = class(tdatalist);

var
 fpropertyeditors: tpropertyeditors;
 ftextpropertyfont: tfont;

function getcomponentpropname(const acomp: tcomponent): msestring;
begin
 if acomp = nil then begin
  result:= '<nil>'
 end
 else begin
  result:= designer.getcomponentname(acomp);
 end;
 if result = '' then begin
  result:= ownernamepath(acomp);
 end;
end;

function imagefilepropedit(out afilename: filenamety;
                                         out aformat: string): modalresultty;
var
 dialog: tfiledialog;
 statfile1: tstatfile;
begin
 statfile1:= tstatfile.create(nil);
 dialog:= tfiledialog.create(nil);
 dialog.name:= 'filedialog'; //for statvarname
 try
  aformat:= '';
  afilename:= '';
  statfile1.options:= [sfo_memory];
  statfile1.filename:= bmpfiledialogstatname;
  with dialog,controller do begin
   statfile1.options:= [sfo_memory];
   statfile1.filename:= bmpfiledialogstatname;
   filterlist.asarraya:= graphicfilefilternames;
   filterlist.asarrayb:= graphicfilemasks;
   captionopen:= 'Open image file';
   statfile:= statfile1;
   statfile.readstat;
   filename:= filedir(filename);
   result:= execute;
   if result = mr_ok then begin
    aformat:= graphicfilefilterlabel(filterindex);
    afilename:= filename;
    statfile.writestat;
   end;
  end;
 finally
  dialog.free;
  statfile1.free;
 end;
end;

procedure checkdatalistnostreaming(const sender: tpropertyeditor;
                                var defaultstate: propertystatesty);
var
 datalist1: tdatalist1;
begin
 datalist1:= tdatalist1(sender.getpointervalue);
 if (datalist1 = nil) {or 
           (ilo_nostreaming in datalist1.finternaloptions)} then begin
  exclude(defaultstate,ps_dialog);
 end;
end;

function textpropertyfont: tfont;
begin
 if ftextpropertyfont = nil then begin
  ftextpropertyfont:= tfont.create;
 end;
 result:= ftextpropertyfont;
end;

function  getpointerprop1(instance: tobject; propinfo : ppropinfo): pointer;
begin
{$ifdef CPU64}
  result:= pointer(ptruint(getint64prop(instance,propinfo)));
{$else}
  result:= pointer(ptruint(getordprop(instance,propinfo)));
{$endif}
end;

function propertyeditors: tpropertyeditors;
begin
 if fpropertyeditors = nil then begin
  fpropertyeditors:= tpropertyeditors.create;
 end;
 result:= fpropertyeditors;
end;

procedure registerpropertyeditor(propertytype: ptypeinfo;
  propertyownerclass: tclass; const propertyname: string;
  editorclass: propertyeditorclassty);
begin
 propertyeditors.add(propertytype,propertyownerclass,propertyname,editorclass);
end;

function settostrings(const value: tintegerset; const typeinfo: ptypeinfo): msestringarty;
var
 int1,int2: integer;
begin
 setlength(result,32);
 int2:= 0;
 for int1:= 0 to 31 do begin
  if longword(value) and bits[int1] <> 0 then begin
   result[int2]:= getenumname(typeinfo,int1);
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

function stringstoset(const value: stringarty; const typeinfo: ptypeinfo): tintegerset;
var
 ar1: array[0..31] of boolean;
 int1,int2: integer;
 typedata: ptypedata;
 enumtype: ptypeinfo;
begin
 fillchar(ar1,sizeof(ar1),0);
 typedata:= gettypedata(typeinfo);
 enumtype:= typedata^.comptype{$ifndef FPC}^{$endif};
 for int1:= 0 to high(value) do begin
  int2:= getenumvalue(enumtype,value[int1]);
  if (int2 < 0) then begin
   raise exception.Create('Invalid set item: '''+value[int1]+'''');
  end;
  ar1[int2]:= true;
 end;
 result:= [];
 for int1:= 0 to gettypedata(enumtype)^.MaxValue do begin
  if ar1[int1] then begin
   result:= tintegerset(longword(result) or bits[int1]);
  end;
 end;
end;

{ tpropertyeditors }

constructor tpropertyeditors.create;
begin
 inherited;
 fsize:= sizeof(propertyeditorinfoty);
end;

procedure tpropertyeditors.add(apropertytype: ptypeinfo;
  apropertyownerclass: tclass; const apropertyname: string;
  aeditorclass: propertyeditorclassty);
var
 info: propertyeditorinfoty;
// po1: ppropertyeditorinfoty;
// bo1: boolean;
// int1: integer;
 class1: tclass;

begin
 with info do begin
  propertytype:= apropertytype;
  propertyownerclass:= apropertyownerclass;
  propertyname:= uppercase(apropertyname);
  editorclass:= aeditorclass;
  class1:= aeditorclass;
  editorclasslevel:= 0;
  while (class1 <> tpropertyeditor) do begin
   class1:= class1.ClassParent;
   inc(editorclasslevel);
  end;
 end;
 {
 po1:= pointer(fdatapo);
 bo1:= false;
 for int1:= 0 to fcount - 1 do begin
  with po1^ do begin
   if (propertytype = info.propertytype) and (componentclass = info.componentclass) and
      (propertyname = info.propertyname) then begin
    editorclass:= info.editorclass;
    bo1:= true;
    break;
   end;
  end;
  inc(po1);
 end;
 }
 adddata(info);
end;

procedure tpropertyeditors.freedata(var data);
begin
 propertyeditorinfoty(data).propertyname:= '';
 inherited;
end;

procedure tpropertyeditors.copyinstance(var data);
begin
 reallocstring(propertyeditorinfoty(data).propertyname);
end;

function tpropertyeditors.getitems(
  const index: integer): ppropertyeditorinfoty;
begin
 result:= ppropertyeditorinfoty(getitempo(index));
end;

function tpropertyeditors.geteditorclass(apropertytype: ptypeinfo;
               apropertyownerclass: tclass;
               apropertyname: string): propertyeditorclassty;
               
               //todo: optimize
var
 int1: integer;
 po1: ppropertyeditorinfoty;
 kind: ttypekind;
 class1: tclass;
 po2: ptypeinfo;
 int2: integer;
 namelevel,propertyownerclasslevel,typeclasslevel,propertyeditorlevel: integer;
 anamelevel,apropertyownerclasslevel,atypeclasslevel: integer;

 procedure savelevel;
 begin
  namelevel:= anamelevel;
  propertyownerclasslevel:= apropertyownerclasslevel;
  typeclasslevel:= atypeclasslevel;
  propertyeditorlevel:= po1^.editorclasslevel;
  result:= po1^.editorclass;
 end;

begin
 apropertyname:= uppercase(apropertyname);
 result:= tpropertyeditor;
 po1:= ppropertyeditorinfoty(fdatapo);
 kind:= apropertytype^.Kind;
 namelevel:= 1;
 propertyownerclasslevel:= bigint;
 typeclasslevel:= bigint;
 propertyeditorlevel:= 0;

 for int1:= 0 to count - 1 do begin
  if kind = po1^.propertytype^.Kind then begin
   if (po1^.propertyownerclass <> nil) then begin
    class1:= apropertyownerclass;
    int2:= 0;
    while (class1 <> nil) and (class1 <> po1^.propertyownerclass) do begin
     class1:= class1.ClassParent;
     inc(int2)
    end;
    if class1 <> nil then begin
     apropertyownerclasslevel:= int2;
    end
    else begin
     apropertyownerclasslevel:= bigint + 1;
    end;
   end
   else begin
    apropertyownerclasslevel:= bigint - 1;
   end;

   if po1^.propertyname = '' then begin
    anamelevel:= 1;
   end
   else begin
    if po1^.propertyname = apropertyname then begin
     anamelevel:= 3;
    end
    else begin
     anamelevel:= 0;
    end;
   end;

   if kind = tkclass then begin
    {$ifdef FPC}
    po2:= gettypedata(apropertytype)^.classtype.classinfo;
    {$else}
    po2:= apropertytype;
    {$endif}
    int2:= 0;
    while (po2 <> nil) and (po2 <> po1^.propertytype) do begin
     inc(int2);
     {$ifdef FPC}
     po2:= gettypedata(po2)^.parentinfo;
     {$else}
     po2:= ptypeinfo(gettypedata(po2)^.parentinfo);
     if po2 <> nil then begin
      po2:= pptypeinfo(po2)^;
     end;
     {$endif}
    end;
    if (po2 <> nil) then begin
     atypeclasslevel:= int2
    end
    else begin
     atypeclasslevel:= bigint + 1;
    end;
   end
   else begin
    if (po1^.propertytype = apropertytype) {$ifdef FPC}
         or (po1^.propertytype^.name = apropertytype^.name) {$endif} then begin
     atypeclasslevel:= 0;
    end
    else begin
     atypeclasslevel:= 1;
     if (kind = tkset) and 
                    (po1^.propertytype <> typeinfo(defaultsetty)) then begin
      atypeclasslevel:= 2;
     end;
     if (kind = tkenumeration) and 
            (po1^.propertytype <> typeinfo(defaultenumerationty)) then begin
      atypeclasslevel:= 2;
     end;
    end;
   end;

   if kind = tkclass then begin
    if (typeclasslevel > atypeclasslevel) and (anamelevel = 1) and 
               (apropertyownerclasslevel = bigint-1) then begin
     savelevel;
    end
    else begin
     if typeclasslevel >= atypeclasslevel then begin
      if (propertyownerclasslevel > apropertyownerclasslevel) and 
              (anamelevel = 1) then begin
       savelevel;
      end
      else begin
       if propertyownerclasslevel >= apropertyownerclasslevel then begin
        if namelevel < anamelevel then begin
         savelevel;
        end
        else begin
         if (namelevel = anamelevel) and
          (propertyeditorlevel <= po1^.editorclasslevel) then begin
          savelevel;
         end;
        end;
       end;
      end;
     end;
    end;
   end
   else begin
    if typeclasslevel > atypeclasslevel then begin
     savelevel;
    end
    else begin
     if typeclasslevel >= atypeclasslevel then begin
              //do not overwrite exact type match
      if (propertyownerclasslevel > apropertyownerclasslevel) and 
                                           (anamelevel = 1) then begin
       savelevel;
      end
      else begin
       if propertyownerclasslevel >= apropertyownerclasslevel then begin
       if namelevel < anamelevel then begin
        savelevel;
       end
       else begin
        if namelevel = anamelevel then begin
          if (typeclasslevel = atypeclasslevel) and
           (propertyeditorlevel <= po1^.editorclasslevel) then begin
           savelevel;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   {
    if (propertyownerclasslevel > apropertyownerclasslevel) and  (anamelevel = 1) then begin
     savelevel;
    end
    else begin
     if propertyownerclasslevel >= apropertyownerclasslevel then begin
      if namelevel < anamelevel then begin
       savelevel;
      end
      else begin
       if namelevel = anamelevel then begin
        if typeclasslevel > atypeclasslevel then begin
         savelevel;
        end
        else begin
         if (typeclasslevel = atypeclasslevel) and
          (propertyeditorlevel <= po1^.editorclasslevel) then begin
          savelevel;
         end;
        end;
       end;
      end;
     end;
    end;
    }
   end;
  end;
  inc(po1);
 end;
end;

{ tpropertyeditor }

constructor tpropertyeditor.create(const adesigner: idesigner;
            const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo);
begin
 fmodule:= amodule;
 fcomponent:= acomponent;
 fdesigner:= adesigner;
 ftypeinfo:= atypeinfo;
 fobjectinspector:= aobjectinspector;
 if aprops <> nil then begin
  fprops:= copy(aprops); //!!!! crash whithout copy, why ?
// reallocarray(fprops,sizeof(props[0]));
  fname:= fprops[0].propinfo^.Name;
 end;
 fstate:= getdefaultstate;
 updatedefaultvalue;
end;

destructor tpropertyeditor.destroy;
begin
 pointer(fdesigner):= nil;
 pointer(fobjectinspector):= nil;
 pointer(fremote):= nil;
end;

procedure tpropertyeditor.setremote(intf: iremotepropertyeditor);
begin
 fremote:= intf;
 if fremote <> nil then begin
  fparenteditor:= fremote.getparenteditor;
  if (fparenteditor <> nil) and  (ps_subprop in fparenteditor.fstate) then begin
   include(fstate,ps_subprop);
  end;
 end;
end;

function tpropertyeditor.canrevert: boolean;
begin
 result:= (ftypeinfo <> nil) and (fremote = nil) and 
  (csancestor in component.componentstate) and (fprops[0].instance = component);
end;

procedure tpropertyeditor.copyproperty(const asource: tobject);
begin 
 case ftypeinfo^.kind of
  tkInteger,tkChar,tkEnumeration,tkSet,tkWChar,
                         {$ifdef FPC}tkBool,{$endif}tkClass: begin
   setordvalue(getordprop(asource,fprops[0].propinfo));
  end;
  tkFloat: begin
   setfloatvalue(getfloatprop(asource,fprops[0].propinfo));
  end;
  tkMethod: begin
   setmethodvalue(getmethodprop(asource,fprops[0].propinfo));
  end;
  {$ifdef FPC}tkSString,tkAString,{$endif}tkLString: begin
   setstringvalue(getstrprop(asource,fprops[0].propinfo));
  end;
  msestringtypekind: begin
   setmsestringvalue(getmsestringprop(asource,fprops[0].propinfo));
  end;
//  {$ifdef mse_unicodestring}
//  tkUString: begin
//   setmsestringvalue(getunicodestrprop(asource,fprops[0].propinfo));
//  end;
//  {$endif}
  tkInt64{$ifdef FPC},tkQWord{$endif}: begin
   setint64value(getint64prop(asource,fprops[0].propinfo));
  end;
 end;
end;

function tpropertyeditor.getvalue: msestring;
begin
 result:= 'Unknown';
end;

procedure tpropertyeditor.setvalue(const value: msestring);
begin
 //dummy
end;

function tpropertyeditor.name: msestring;
begin
 result:= fname;
end;

function tpropertyeditor.allequal: boolean;
begin
 result:= high(fprops) = 0;
end;

function tpropertyeditor.props: propinstancearty;
begin
 result:= fprops;
end;

function tpropertyeditor.rootprops: propinstancearty;
var
 ed1: tpropertyeditor;
begin
 result:= nil;
 ed1:= getparenteditor;
 if ed1 <> nil then begin
  result:= ed1.rootprops;
 end;
 if result = nil then begin
  result:= fprops;
 end;
end;

function tpropertyeditor.propowner: componentarty;
var
 ed1: tpropertyeditor;
 int1: integer;
begin
 result:= nil;
 ed1:= getparenteditor;
 while ed1 <> nil do begin
  if (ed1 is tcomponentpropertyeditor) and not 
               tcomponentpropertyeditor(ed1).issubcomponent then begin
   setlength(result,count);
   for int1:= 0 to high(result) do begin
    result[int1]:= tcomponent(ed1.getpointervalue);
   end;
   break;
  end;
  ed1:= ed1.getparenteditor;
 end;
end;

function tpropertyeditor.instance(const index: integer = 0): tobject;
begin
 result:= fprops[index].instance;
end;

function tpropertyeditor.typedata: ptypedata;
begin
 result:= gettypedata(ftypeinfo);
end;

function tpropertyeditor.queryselectedpropinstances: objectarty;
var
 editor1: tpropertyeditor;
begin
 result:= nil;
 editor1:= fparenteditor;
 while editor1 <> nil do begin
  if (editor1.fremote <> nil) and (editor1.fremote.selected) then begin
   result:= editor1.fremote.getselectedpropinstances;
   break;
  end;
  if editor1 is tclasspropertyeditor then begin
   break;
  end;
  editor1:= editor1.fparenteditor;
 end;  
 if result <> nil then begin
  include(fstate,ps_refreshall);
 end;
end;

function tpropertyeditor.getordvalue(const index: integer): integer;

begin
 if fremote <> nil then begin
  result:= fremote.getordvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= GetOrdProp(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setordvalue(const value: longword);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setordvalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     setordprop(instance, propinfo, value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setordprop(ar1[int1],fprops[0].propinfo,value);
   end;
  end;
  updatedefaultvalue;
  modified;
 end;
end;

procedure tpropertyeditor.setordvalue(const index: integer; const value: longword);
begin
 if fremote <> nil then begin
  fremote.setordvalue(index,value);
 end
 else begin
  with fprops[index] do begin
   setordprop(instance, propinfo, value);
  end;
  updatedefaultvalue;
  modified;
 end;
end;

function tpropertyeditor.getint64value(const index: integer): int64;

begin
 if fremote <> nil then begin
  result:= fremote.getint64value(index);
 end
 else begin
  with fprops[index] do begin
   result:= getint64prop(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setint64value(const value: int64);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setint64value(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     setint64prop(instance, propinfo, value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setint64prop(ar1[int1],fprops[0].propinfo,value);
   end;
  end;
  updatedefaultvalue;
  modified;
 end;
end;

procedure tpropertyeditor.setint64value(const index: integer; const value: int64);
begin
 if fremote <> nil then begin
  fremote.setint64value(index,value);
 end
 else begin
  with fprops[index] do begin
   setint64prop(instance, propinfo, value);
  end;
  updatedefaultvalue;
  modified;
 end;
end;

function tpropertyeditor.getpointervalue(const index: integer): pointer;

begin
 if fremote <> nil then begin
  result:= fremote.getpointervalue(index);
 end
 else begin
  with fprops[index] do begin
{$ifdef CPU64}
   result:= pointer(ptruint(Getint64Prop(instance,propinfo)));
{$else}
   result:= pointer(ptruint(GetOrdProp(instance,propinfo)));
{$endif}
  end;
 end;
end;

procedure tpropertyeditor.setpointervalue(const value: pointer);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setpointervalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
{$ifdef CPU64}
     setint64prop(instance, propinfo, ptrint(value));
{$else}
     setordprop(instance, propinfo, ptrint(value));
{$endif}
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
{$ifdef CPU64}
    setint64prop(ar1[int1],fprops[0].propinfo,ptrint(value));
{$else}
    setordprop(ar1[int1],fprops[0].propinfo,ptrint(value));
{$endif}
   end;
  end;
  updatedefaultvalue;
  modified;
 end;
end;

procedure tpropertyeditor.setpointervalue(const index: integer; const value: pointer);
begin
 if fremote <> nil then begin
  fremote.setpointervalue(index,value);
 end
 else begin
  with fprops[index] do begin
{$ifdef CPU64}
   setint64prop(instance, propinfo, ptrint(value));
{$else}
   setordprop(instance, propinfo, ptrint(value));
{$endif}
  end;
  updatedefaultvalue;
  modified;
 end;
end;

procedure tpropertyeditor.setbitvalue(const value: boolean; const bitindex: integer);
var
 int1: integer;
 wo1: longword;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setbitvalue(value,bitindex);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     wo1:= getordprop(instance,propinfo);
     updatebit(wo1,bitindex,value);
     setordprop(instance,propinfo,wo1);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    wo1:= getordprop(ar1[int1],fprops[0].propinfo);
    updatebit(wo1,bitindex,value);
    setordprop(ar1[int1],fprops[0].propinfo,wo1);
   end;
  end;
  fparenteditor.updatedefaultvalue;
  updatedefaultvalue;
  modified;
 end;
end;

function tpropertyeditor.getfloatvalue(const index: integer): extended;
begin
 if fremote <> nil then begin
  result:= fremote.getfloatvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= GetfloatProp(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setfloatvalue(const value: extended);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setfloatvalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     SetfloatProp(Instance, PropInfo, Value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setfloatprop(ar1[int1],fprops[0].propinfo,value);
   end;
  end;
  modified;
 end;
end;

function tpropertyeditor.getcurrencyvalue(const index: integer = 0): currency;
begin
 if fremote <> nil then begin
  result:= fremote.getcurrencyvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= getfloatprop(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setcurrencyvalue(const value: currency);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setcurrencyvalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     setfloatprop(instance, propinfo, value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setfloatprop(ar1[int1],fprops[0].propinfo,value);
   end;
  end;
  modified;
 end;
end;

function tpropertyeditor.getstringvalue(const index: integer): string;
begin
 if fremote <> nil then begin
  result:= fremote.getstringvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= decodemsestring(GetstrProp(instance,propinfo));
  end;
 end;
end;

procedure tpropertyeditor.setstringvalue(const value: string);
var
 int1: integer;
 str1: string;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setstringvalue(value);
 end
 else begin
  str1:= encodemsestring(value);
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     SetstrProp(Instance, PropInfo, str1);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    SetstrProp(ar1[int1], fprops[0].propinfo, str1);
   end;
  end;
  modified;
 end;
end;

function tpropertyeditor.decodemsestring(const avalue: msestring): msestring;
var
 int1: integer;
 po1: pmsechar;
 mstr1: msestring;
begin
 setlength(result,length(avalue) * 10); //max size
 if length(avalue) > 0 then begin
  po1:= pointer(result);
  for int1:= 1 to length(avalue) do begin
   case avalue[int1] of
    c_tab: begin po1^:= numcharchar; inc(po1); po1^:= 't'; end;
    c_linefeed: begin po1^:= numcharchar; inc(po1); po1^:= 'n'; end;
    c_return: begin po1^:= numcharchar; inc(po1); po1^:= 'r'; end;
    numcharchar: begin po1^:= numcharchar; inc(po1); po1^:= numcharchar; end;
    else begin
     if avalue[int1] < widechar(32) then begin
      mstr1:= numcharchar+inttostr(ord(avalue[int1]));
      if (avalue[int1+1] >= '0') and (avalue[int1+1] <= '9') or 
                     (avalue[int1+1] = ' ') then begin
       mstr1:= mstr1 + ' ';
      end;
      move(mstr1[1],po1^,length(mstr1)*sizeof(widechar));
      inc(po1,length(mstr1)-1);
     end
     else begin
      po1^:= avalue[int1];
     end;
    end;
   end;
   inc(po1)
  end;
  setlength(result,po1-pmsechar(pointer(result)));
 end;
end;

function tpropertyeditor.encodemsestring(const avalue: msestring): msestring;
var
 int1: integer;
 po1: pmsechar;
 int2: integer;
begin
 setlength(result,length(avalue)); //max
 if length(result) > 0 then begin
  po1:= pointer(result);
  int1:= 1;
  while int1 <= length(avalue) do begin
   if (avalue[int1] = numcharchar) and (int1 < length(avalue)+1) then begin
    case avalue[int1+1] of
     numcharchar: po1^:= numcharchar;
     't': po1^:= c_tab;
     'n': po1^:= c_linefeed;
     'r': po1^:= c_return;
     '0'..'9': begin
      int2:= int1+2;
      while (avalue[int2] >= '0') and (avalue[int2] <= '9') do begin
       inc(int2);
      end;
      po1^:= widechar(strtoint(copy(avalue,int1+1,int2-int1-1)));
      if avalue[int2] = ' ' then begin
       inc(int2);
      end;
      int1:= int2-2;
     end;
     else begin po1^:= numcharchar; dec(int1); end;
    end;
    inc(int1,2);
   end
   else begin
    po1^:= avalue[int1];
    inc(int1);
   end;
   inc(po1);
  end;
  setlength(result,po1 - pmsechar(pointer(result)));
 end;
end;

function tpropertyeditor.getmsestringvalue(
  const index: integer): msestring;

begin
 if fremote <> nil then begin
  result:= fremote.getmsestringvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= decodemsestring(getmsestringprop(instance,propinfo));
//  {$ifdef mse_unicodestring}
//   result:= decodemsestring(GetunicodestrProp(instance,propinfo));     
//  {$else}
//   result:= decodemsestring(GetwidestrProp(instance,propinfo));     
//  {$endif}
  end;
 end;
end;

procedure tpropertyeditor.setmsestringvalue(const value: msestring);
var
 mstr1: msestring;
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setmsestringvalue(value);
 end
 else begin
  mstr1:= encodemsestring(value);
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     setmsestringprop(instance,propinfo,mstr1);
//    {$ifdef mse_unicodestring}
//     setunicodestrprop(instance,propinfo,mstr1);  
//    {$else}
//     setwidestrprop(instance,propinfo,mstr1);  
//    {$endif}
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setmsestringprop(ar1[int1],fprops[0].propinfo,mstr1);  
//   {$ifdef mse_unicodestring}
//    setunicodestrprop(ar1[int1],fprops[0].propinfo,mstr1);  
//   {$else}
//    setwidestrprop(ar1[int1],fprops[0].propinfo,mstr1);  
//   {$endif}
   end;
  end;    
  modified;
 end;
end;

function tpropertyeditor.getvariantvalue(const index: integer = 0): variant;
begin
 if fremote <> nil then begin
  result:= fremote.getvariantvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= getvariantprop(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setvariantvalue(const value: variant);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setvariantvalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     setvariantprop(instance,propinfo,value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setvariantprop(ar1[int1],fprops[0].propinfo,value);  
   end;
  end;    
  modified;
 end;
end;

function tpropertyeditor.getmethodvalue(const index: integer): tmethod;
begin
 if fremote <> nil then begin
  result:= fremote.getmethodvalue(index);
 end
 else begin
  with fprops[index] do begin
   result:= GetmethodProp(instance,propinfo);
  end;
 end;
end;

procedure tpropertyeditor.setmethodvalue(const value: tmethod);
var
 int1: integer;
 ar1: objectarty;
begin
 if fremote <> nil then begin
  fremote.setmethodvalue(value);
 end
 else begin
  ar1:= queryselectedpropinstances;
  if ar1 = nil then begin
   for int1:= 0 to high(fprops) do begin
    with fprops[int1] do begin
     SetmethodProp(Instance, PropInfo, Value);
    end;
   end;
  end
  else begin
   for int1:= 0 to high(ar1) do begin
    setmethodprop(ar1[int1],fprops[0].propinfo,value);
   end;
  end;
  modified;
 end;
end;

function tpropertyeditor.getparenteditor: tpropertyeditor;
begin
 if fremote <> nil then begin
  result:= fremote.getparenteditor;
 end
 else begin
  result:= fparenteditor;
 end;
end;

function tpropertyeditor.sortlevel: integer;
begin
 result:= fsortlevel;
end;

function tpropertyeditor.getexpanded: boolean;
begin
 result:= ps_expanded in fstate;
end;

function tpropertyeditor.getcount: integer;
begin
 result:= length(fprops);
end;

procedure tpropertyeditor.setexpanded(const Value: boolean);
begin
 if value then begin
  include(fstate,ps_expanded);
 end
 else begin
  exclude(fstate,ps_expanded);
 end;
end;

procedure tpropertyeditor.modified;
begin
 fobjectinspector.propertymodified(self);
 exclude(fstate,ps_refreshall);
end;

function tpropertyeditor.subproperties: propertyeditorarty;
begin
 result:= nil;
end;

procedure tpropertyeditor.edit;
begin
 //dummy
end;

function tpropertyeditor.getvalues: msestringarty;
begin
 result:= nil;
end;

procedure tpropertyeditor.properror;
begin
 raise exception.Create('Wrong property value');
end;

function tpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= [];
 if (fparenteditor <> nil) and (ps_subprop in fparenteditor.fstate) then begin
  include(result,ps_subprop);
 end;
end;

procedure tpropertyeditor.dragbegin(var accept: boolean);
begin
 //dummy
end;

procedure tpropertyeditor.dragover(const sender: tpropertyeditor; var accept: boolean);
begin
 //dummy
end;

procedure tpropertyeditor.dragdrop(const sender: tpropertyeditor);
begin
 //dummy
end;

procedure tpropertyeditor.dopopup(var amenu: tpopupmenu; 
          const atransientfor: twidget; var mouseinfo: mouseeventinfoty);
begin
 //dummy
end;

procedure tpropertyeditor.updatedefaultvalue;
begin
 if (fstate * [ps_isordprop,ps_candefault] = [ps_isordprop,ps_candefault]) and 
        (getordvalue <> fprops[0].propinfo^.default) then begin
  include(fstate,ps_modified);
 end
 else begin
  exclude(fstate,ps_modified);
 end;
end;

function tpropertyeditor.propertyname: msestring;
begin
 result:= fname;
end;

function tpropertyeditor.getselected: boolean;
begin
 result:= ps_selected in fstate;
end;

procedure tpropertyeditor.setselected(const avalue: boolean);
begin
 if avalue and (ps_canselect in fstate) then begin
  include(fstate,ps_selected);
 end
 else begin
  exclude(fstate,ps_selected);
 end;
end;

procedure tpropertyeditor.setsubprop;
begin
 include(fstate,ps_subprop);
end;

function tpropertyeditor.getvalueeditor: tpropertyeditor;
begin
 result:= self;
end;

function tpropertyeditor.getlinksource: tcomponent;
begin
 result:= nil;
end;

{ tordinalpropertyeditor }

function tordinalpropertyeditor.allequal: boolean;
var
 int1: integer;
 int2: integer;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  int2:= getordvalue;
  for int1:= 1 to high(fprops) do begin
   if int2 <> getordvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tordinalpropertyeditor.getvalue: msestring;
begin
 result:= inttostr(getordvalue);
end;

procedure tordinalpropertyeditor.setvalue(const value: msestring);
begin
 setordvalue(strtointvalue(value));
end;

function tordinalpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_isordprop,ps_candefault];
end;

{ tint64propertyeditor }

function tint64propertyeditor.allequal: boolean;
var
 int1: integer;
 int2: int64;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  int2:= getint64value;
  for int1:= 1 to high(fprops) do begin
   if int2 <> getint64value(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tint64propertyeditor.getvalue: msestring;
begin
 result:= inttostr(getint64value);
end;

procedure tint64propertyeditor.setvalue(const value: msestring);
begin
 setint64value(strtointvalue64(value));
end;

function tint64propertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_isordprop,ps_candefault];
end;

{ tcharpropertyeditor }

procedure tcharpropertyeditor.setvalue(const value: msestring);
var
 str1: string;
begin
 str1:= encodemsestring(value);
 if str1 = '' then begin
  setordvalue(0);
 end
 else begin
  setordvalue(ord(str1[1]));
 end;
end;

function tcharpropertyeditor.getvalue: msestring;
var
 int1: integer;
begin
 int1:= getordvalue;
 if int1 = 0 then begin
  result:= '';
 end
 else begin
  result:= decodemsestring(char(int1));
 end;
end;

{ twidecharpropertyeditor }

procedure twidecharpropertyeditor.setvalue(const value: msestring);
var
 str1: msestring;
begin
 str1:= encodemsestring(value);
 if str1 = '' then begin
  setordvalue(0);
 end
 else begin
  setordvalue(ord(str1[1]));
 end;
end;

function twidecharpropertyeditor.getvalue: msestring;
var
 int1: integer;
begin
 int1:= getordvalue;
 if int1 = 0 then begin
  result:= '';
 end
 else begin
  result:= decodemsestring(widechar(int1));
 end;
end;

{ tmethodpropertyeditor }

constructor tmethodpropertyeditor.create(const adesigner: idesigner;
  const amodule: tmsecomponent; const acomponent: tcomponent;
  const aobjectinspector: iobjectinspector; const aprops: propinstancearty;
           atypinfo: ptypeinfo);
begin
 inherited;
 fsortlevel:= methodsortlevel;
end;

function tmethodpropertyeditor.allequal: boolean;
var
 int1: integer;
 method1,method2: tmethod;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  method1:= getmethodvalue;
  for int1:= 1 to high(fprops) do begin
   method2:= getmethodvalue(int1);
   if (method1.code <> method2.code) or (method1.data <> method2.data) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tmethodpropertyeditor.getvalue: msestring;
var
 method1: tmethod;
begin
 method1:= getmethodvalue;
 if method1.data <> nil then begin
  result:= fdesigner.getmethodname(method1,fcomponent);
 end
 else begin
  result:= '';
 end;
end;

function tmethodpropertyeditor.method: tmethod;
begin
 result:= getmethodvalue;
end;

procedure tmethodpropertyeditor.setvalue(const value: msestring);

 function isselected: boolean;
 var
  ar1: msestringarty;
  int1: integer;
 begin
  ar1:= getvalues;
  result:= false;
  for int1:= 0 to high(ar1) do begin
   if value = ar1[int1] then begin
    result:= true;
    break;
   end;
  end;
 end;

var
 method1,method2: tmethod;
begin
 method2:= getmethodvalue;
 if value = '' then begin
  method1.code:= nil;
  method1.data:= nil;
  setmethodvalue(method1);
 end
 else begin
  if not isvalidident(value) then begin
   raise exception.create('Invalid method name '''+value+'''.');
  end;
  method1:= fdesigner.getmethod(value,fmodule,
                  fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif},true);
  if method1.data = nil then begin //method not found
   if (method2.data <> nil) and not isselected and 
                         fdesigner.isownedmethod(fmodule,method2)then begin
    fdesigner.changemethodname(method2,value,
         fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif});
    method1:= method2;
   end
   else begin
    if method1.data <> nil then begin
     raise exception.create('Methodname '''+value+''' exists');
    end;
    method1:= fdesigner.createmethod(value,fmodule,
                 fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif});
   end;
  end
  else begin
   fdesigner.checkmethod(method1,value,fmodule,
                 fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif});
  end;
  setmethodvalue(method1);
 end;
// modified;
end;

function tmethodpropertyeditor.getvalues: msestringarty;
begin
 result:= fobjectinspector.getmatchingmethods(self,
            fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif});
end;

function tmethodpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= [ps_valuelist,ps_sortlist];
end;

{ tsetpropertyeditor }

constructor tsetpropertyeditor.create(const adesigner: idesigner;
               const amodule: tmsecomponent; const acomponent: tcomponent;
               const aobjectinspector: iobjectinspector;
               const aprops: propinstancearty; atypeinfo: ptypeinfo);
begin
 finvisibleitems:= getinvisibleitems;
 inherited;
end;

function tsetpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate  + [ps_subproperties];
end;

function tsetpropertyeditor.getvalue: msestring;
begin
 {$ifdef FPC}
 result:= '['+concatstrings(settostrings(tintegerset(longword(getordvalue)),
      typedata^.comptype),',')+']';
 {$else}
 result:= '['+concatstrings(settostrings(tintegerset(longword(getordvalue)),
      typedata^.comptype^),',')+']';
 {$endif}
(*
{$ifdef FPC}
 result:= '['+concatstrings(settostrings(tintegerset(longword(getordvalue)),
      gettypedata(fprops[0].propinfo^.proptype)^.comptype),',')+']';
{$else}
 result:= '['+concatstrings(settostrings(tintegerset(longword(getordvalue)),
      gettypedata(fprops[0].propinfo^.proptype^)^.comptype^),',')+']';
{$endif}
*)
end;

procedure tsetpropertyeditor.setvalue(const value: msestring);
var
 str1: string;
 ar1: stringarty;
begin
 str1:= trim(value);
 if (length(str1) > 0) and (str1[1] = '[') then begin
  str1:= copy(str1,2,bigint);
 end;
 if (length(str1) > 0) and (str1[length(str1)] = ']') then begin
  setlength(str1,length(str1)-1);
 end;
 ar1:= nil;
 splitstring(str1,ar1,',',true);
 setordvalue(longword(stringstoset(ar1,ftypeinfo)));
end;

function tsetpropertyeditor.subproperties: propertyeditorarty;
var
 compty: ptypeinfo;
 int1: integer;
 int2: integer;
begin
 compty:= gettypedata(ftypeinfo)^.comptype{$ifndef FPC}^{$endif};
 setlength(result,gettypedata(compty)^.MaxValue+1);
 int2:= 0;
 for int1:= 0 to high(result) do begin
  if not (int1 in finvisibleitems) then begin
   result[int2]:= tsetelementeditor.create(fdesigner,fmodule,fcomponent,
                    fobjectinspector,fprops,compty,self,int1);
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

function tsetpropertyeditor.getinvisibleitems: tintegerset;
begin
 result:= [];
end;

{ tsetelementeditor }

constructor tsetelementeditor.create(const adesigner: idesigner; 
      const amodule: tmsecomponent; const acomponent: tcomponent; 
      const aobjectinspector: iobjectinspector; 
      const aprops: propinstancearty; atypeinfo: ptypeinfo; 
      const aparent: tsetpropertyeditor; const aindex: integer);
begin
 findex:= aindex;
 fparenteditor:= aparent;
 inherited create(adesigner,amodule,acomponent,aobjectinspector,aprops,atypeinfo);
 fremote:= aparent.fremote;
end;

function tsetelementeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_candefault];
end;

function tsetelementeditor.getvalue: msestring;
begin
 if findex in tintegerset(longword(getordvalue)) then begin
  result:= truename;
 end
 else begin
  result:= falsename;
 end;
end;

function tsetelementeditor.allequal: boolean;
var
 int1: integer;
 bo1: boolean;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  bo1:= findex in tintegerset(longword(getordvalue));
  for int1:= 1 to high(fprops) do begin
   if bo1 <> (findex in tintegerset(longword(getordvalue(int1)))) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tsetelementeditor.getvalues: msestringarty;
begin
 setlength(result,2);
 result[0]:= falsename;
 result[1]:= truename;
end;

function tsetelementeditor.name: msestring;
begin
{$ifdef FPC}
// result:= getenumname(gettypedata(
//          fparent.fprops[0].propinfo^.proptype)^.comptype,findex);
{$else}
// result:= getenumname(gettypedata(fparent.fprops[0].propinfo^.proptype^)^.comptype^,findex);
 {$endif}
 result:= getenumname(ftypeinfo,findex);
end;

procedure tsetelementeditor.setvalue(const value: msestring);
begin
 setbitvalue(value = truename,findex);
// fparenteditor.modified;
end;

procedure tsetelementeditor.updatedefaultvalue;
begin
 if (fparenteditor.getordvalue xor fparenteditor.fprops[0].propinfo^.default) and
            (1 shl findex) <> 0 then begin
  include(fstate,ps_modified);
 end
 else begin
  exclude(fstate,ps_modified);
 end;
end;

function tsetelementeditor.propertyname: msestring;
begin
 result:= name;
end;

function tsetelementeditor.canrevert: boolean;
begin
 result:= false;
end;

{ tclasspropertyeditor }

function tclasspropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_subproperties,ps_isordprop];
end;

function tclasspropertyeditor.checkfreeoptionalclass: boolean;
begin
 result:= askok('Do you wish to destroy ' + fname+' ('+ftypeinfo^.Name+
          ')?','CONFIRMATION');
end;

function tclasspropertyeditor.getvalue: msestring;

begin
// result:= '('+fprops[0].propinfo^.proptype^.name+')';
 result:= '<'+ftypeinfo^.name+'>';
end;

function tclasspropertyeditor.subproperties: propertyeditorarty;
var
 ar1: objectarty;
 int1: integer;
// prop1: tpropertyeditor;
begin
 setlength(ar1,count);
 for int1:= 0 to high(fprops) do begin
  ar1[int1]:= tobject(getpointervalue(int1));
 end;
 result:= fobjectinspector.getproperties(ar1,fmodule,fcomponent);
 for int1:= 0 to high(result) do begin
  result[int1].fparenteditor:= self;
 end;
 if fstate * [ps_component,ps_subprop] <> [] then begin
  for int1:= 0 to high(result) do begin
   result[int1].setsubprop;
  end;
 end;
end;

{ tlinkedpersistentpropertyeditor }
{
function tlinkedpersistentpropertyeditor.issubcomponent(const index: integer = 0): boolean;
var
 comp: tcomponent;
begin
 comp:= tcomponent(getpointervalue(index));
 if comp = nil then begin
  result:= false;
 end
 else begin
  result:= cssubcomponent in comp.ComponentStyle;
 end;
end;
}
{
function tlinkedobjectpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_volatile,ps_component];
end;

function tlinkedobjectpropertyeditor.allequal: boolean;
var
 po1: pointer;
 int1: integer;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  po1:= getpointervalue;
  for int1:= 1 to high(fprops) do begin
   if getpointervalue(int1) <> po1 then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tlinkedobjectpropertyeditor.getvalue: msestring;
var
 obj1: tobject; 
begin
 obj1:= tobject(getpointervalue);
 if obj1 = nil then begin
  result:= '<nil>';
 end
 else begin
  result:= obj1.classname;
 end;
end;

function tlinkedobjectpropertyeditor.getvalues: msestringarty;
begin
 result:= nil;
end;

procedure tlinkedobjectpropertyeditor.setvalue(const value: msestring);
var
 obj1: tobject;
begin
 obj1:= nil;
 if value = '' then begin
  setpointervalue(obj1);
 end;
end;

procedure tlinkedobjectpropertyeditor.checkobj(const avalue: tobject);
begin
 //dummy
end;

function tlinkedobjectpropertyeditor.filterobj(const aobj: tobject): boolean;
begin
 result:= true;
end;
}
{ tcomponentpropertyeditor }

function tcomponentpropertyeditor.issubcomponent(const index: integer = 0): boolean;
var
 comp: tcomponent;
begin
 comp:= tcomponent(getpointervalue(index));
 if comp = nil then begin
  result:= false;
 end
 else begin
  result:= (cssubcomponent in comp.ComponentStyle) and 
   ((comp.owner = nil) or ownscomponent(component,comp) and
    (comp is tmsecomponent) and 
              not (cs_subcompref in tmsecomponent1(comp).fmsecomponentstate));
 end;
end;

function tcomponentpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 if not issubcomponent then begin
  result:= result + [ps_valuelist,ps_volatile,ps_component,ps_dialog];
 end;
end;

function tcomponentpropertyeditor.allequal: boolean;
var
// ca1: cardinal;
 po1: pointer;
 int1: integer;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  if issubcomponent then begin
   for int1:= 1 to high(fprops) do begin
    if not issubcomponent(int1) then begin
     result:= false;
     break;
    end;
   end;
  end
  else begin
//   ca1:= getordvalue;
   po1:= getpointervalue;
   for int1:= 1 to high(fprops) do begin
//    if cardinal(getordvalue(int1)) <> ca1 then begin
    if getpointervalue(int1) <> po1 then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

function tcomponentpropertyeditor.getvalue: msestring;
//var
// comp1: tcomponent;
begin
 if issubcomponent then begin
  result:= inherited getvalue;
 end
 else begin
  result:= getcomponentpropname(tcomponent(getpointervalue));
 end;
end;

function tcomponentpropertyeditor.getvalues: msestringarty;
var
 co1: tcomponent;
 ar1: componentarty;
 int1,int2: integer;
begin
 ar1:= nil; //compiler warning
 if issubcomponent then begin
  result:= inherited getvalues;
 end
 else begin
  if ps_link in fstate then begin
   ar1:= fdesigner.getcomponentlist(tcomponentclass(typedata^.classtype),
             {$ifdef FPC}@{$endif}filtercomponent);
   if ps_local in fstate then begin
    co1:= fcomponent.owner;
    for int1:= high(ar1) downto 0 do begin
     if ar1[int1].owner <> co1 then begin
      ar1[int1]:= nil;
     end;
    end;
   end;

   for int1:= 0 to high(ar1) do begin
    with tdesigner1(designer).selections do begin
     for int2:= count - 1 downto 0 do begin
      if items[int2] = ar1[int1] then begin
       ar1[int1]:= nil; //remove selected components
       break;
      end;
     end;
    end;
   end;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] <> nil then begin
     additem(result,msestring(ar1[int1].name));
    end;
   end;
  end
  else begin
   if ps_local in fstate then begin
    co1:= fmodule;
   end
   else begin
    co1:= nil;
   end;
   result:= fdesigner.getcomponentnamelist(
                  tcomponentclass(typedata^.classtype),true{false},co1,
                  {$ifdef FPC}@{$endif}filtercomponent);
  end;
 end;
end;

procedure tcomponentpropertyeditor.edit;
var
 tree1: tcompnameitem;
 mstr1: msestring;
 co1: tcomponent;
begin
 if ps_local in fstate then begin
  co1:= fmodule;
 end
 else begin
  co1:= nil;
 end;
 tree1:= fdesigner.getcomponentnametree(
                tcomponentclass(typedata^.classtype),true{false},co1,
                {$ifdef FPC}@{$endif}filtercomponent);
 co1:= tcomponent(getpointervalue);
 if co1 = nil then begin
  mstr1:= fmodule.name;
 end
 else begin
  mstr1:= ownernamepath(co1);
 end;
 if compnamedialog(tree1,mstr1) = mr_ok then begin
  setvalue(mstr1);
 end;
end;

procedure tcomponentpropertyeditor.setvalue(const value: msestring);
var
 comp: tcomponent;
 int1: integer;
begin
 if issubcomponent then begin
  inherited setvalue(value);
 end
 else begin
  if value = '' then begin
   comp:= nil;
  end
  else begin
   if value <> getvalue then begin
    int1:= pos('<',value);
    if int1 > 0 then begin
     comp:= fdesigner.getcomponent(copy(value,1,int1-1),fmodule);
//     comp:= fmodule.findcomponent(copy(value,1,int1-1));
    end
    else begin
     comp:= fdesigner.getcomponent(value,fmodule);
    end;
    if (comp = nil) or not comp.InheritsFrom(gettypedata(ftypeinfo)^.classtype) then begin
     properror;
    end;
    checkcomponent(comp);
   end
   else begin
    exit;
   end;
  end;
  setpointervalue(comp);
 end;
end;

procedure tcomponentpropertyeditor.checkcomponent(const avalue: tcomponent);
begin
 //dummy
end;

function tcomponentpropertyeditor.filtercomponent(
                               const acomponent: tcomponent): boolean;
begin
 result:= true;
end;

function tcomponentpropertyeditor.getlinksource: tcomponent;
begin
 result:= tcomponent(getpointervalue);
end;

{ tsubcomponenteditor }

function tsubcomponentpropertyeditor.issubcomponent(const index: integer = 0): boolean;
begin
 result:= true;
end;

{ tsisterwidgetpropertyeditor }
{
function tsisterwidgetpropertyeditor.getvalues: msestringarty;
var
 ar1: componentarty;
 widget1: twidget;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 if issubcomponent then begin
  result:= inherited getvalues;
 end
 else begin
  result:= nil;
  widget1:= twidget(fcomponent).parentwidget;
  if widget1 <> nil then begin
   ar1:= fdesigner.getcomponentlist(tcomponentclass(typedata^.classtype));
   for int1:= 0 to high(ar1) do begin
    if (twidget(ar1[int1]).parentwidget <> widget1) or 
                  (ar1[int1] = fcomponent) then begin
     ar1[int1]:= nil;
    end;
   end;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] <> nil then begin
     additem(result,msestring(ar1[int1].name));
    end;
   end;
  end;
 end;
end;
}

function tsisterwidgetpropertyeditor.filtercomponent(
                      const acomponent: tcomponent): boolean;
begin
 result:= (acomponent <> fcomponent) and
          (twidget(acomponent).parentwidget = twidget(fcomponent).parentwidget);
end;

function tsisterwidgetpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_sortlist];
end;

{ tchildwidgetpropertyeditor }

function tchildwidgetpropertyeditor.getvalues: msestringarty;
var
 ar1: componentarty;
 widget1: twidget;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 if issubcomponent then begin
  result:= inherited getvalues;
 end
 else begin
  result:= nil;
  widget1:= twidget(fcomponent);
  ar1:= fdesigner.getcomponentlist(tcomponentclass(typedata^.classtype));
  for int1:= 0 to high(ar1) do begin
   if (twidget(ar1[int1]).parentwidget <> widget1) then begin
    ar1[int1]:= nil;
   end;
  end;
  for int1:= 0 to high(ar1) do begin
   if ar1[int1] <> nil then begin
    additem(result,msestring(ar1[int1].name));
   end;
  end;
 end;
end;

function tchildwidgetpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_sortlist];
end;

{ tlocalcomponentpropertyeditor }

function tlocalcomponentpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_local];
end;

{ tlocallinkcomponentpropertyeditor }

function tlocallinkcomponentpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_local,ps_link];
end;

{ toptionalclasspropertyeditor }

function toptionalclasspropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog,ps_volatile];
end;

procedure toptionalclasspropertyeditor.deleteinstance;
begin
 if checkfreeoptionalclass then begin
  setordvalue(0);
 end;
end;

procedure toptionalclasspropertyeditor.edit;
var
 obj1: tobject;
begin
 obj1:= getinstance;
 if obj1 = nil then begin
  setordvalue(1);
 end
 else begin
  deleteinstance;
 end;
end;

function toptionalclasspropertyeditor.getinstance: tpersistent;
begin
 result:= tpersistent(getpointervalue);
end;

function toptionalclasspropertyeditor.getniltext: string;
begin
 result:= '<disabled>';
end;

procedure toptionalclasspropertyeditor.setvalue(const avalue: msestring);
begin
 if avalue = '' then begin
  deleteinstance;
 end
 else begin
  inherited;
 end;
end;

function toptionalclasspropertyeditor.getvalue: msestring;
begin
 if getinstance = nil then begin
  result:= getniltext;
 end
 else begin
  result:= inherited getvalue;
 end;
end;

function toptionalclasspropertyeditor.canrevert: boolean;
begin
 result:= false;
end;

{ tparentclasspropertyeditor }

procedure tparentclasspropertyeditor.edit;
var
 obj1: tobject;
 persist1,persist2: tpersistent;
 int1: integer;
begin
  obj1:= getinstance;
  if obj1 = nil then begin
   for int1:= 0 to count - 1 do begin
    persist1:= tpersistent(getpointervalue(int1));
    setordvalue(int1,1); //create instance
    persist2:= tpersistent(getpointervalue(int1));
    if (persist1 <> nil) and (persist2 <> nil) then begin
     persist2.Assign(persist1);    //copy default values
    end;
   end;
  end
  else begin
   if not checkfreeoptionalclass then begin
    exit;
   end;
   setordvalue(0);
  end;
end;

function tparentclasspropertyeditor.getinstance: tpersistent;
begin
 result:= getinstancepo(instance)^;
end;

function tparentclasspropertyeditor.getniltext: string;
begin
 result:= '<parent>';
end;

function tparentclasspropertyeditor.subproperties: propertyeditorarty;
begin
 if getinstance = nil then begin
  result:= nil;
 end
 else begin
  result:= inherited subproperties;
 end;
end;

{ tparentfontproperty }

function tparentfontpropertyeditor.getinstancepo(acomponent: tobject): ppersistent;
begin
 result:= ppersistent(parentfontclassty(typedata^.classtype).getinstancepo(acomponent));
end;

{ tstringpropertyeditor }

function tstringpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_isordprop];
end;

function tstringpropertyeditor.allequal: boolean;
var
 int1: integer;
 str1: string;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  str1:= getstringvalue;
  for int1:= 1 to high(fprops) do begin
   if str1 <> getstringvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tstringpropertyeditor.getvalue: msestring;
begin
 result:= getstringvalue(0);
end;

procedure tstringpropertyeditor.setvalue(const value: msestring);
begin
 setstringvalue(value);
end;

{ tmsestringpropertyeditor }

function tmsestringpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_isordprop,ps_dialog];
end;

function tmsestringpropertyeditor.allequal: boolean;
var
 int1: integer;
 str1: msestring;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  str1:= getmsestringvalue;
  for int1:= 0 to high(fprops) do begin
   if str1 <> getmsestringvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tmsestringpropertyeditor.getvalue: msestring;
begin
 result:= getmsestringvalue(0);
end;

procedure tmsestringpropertyeditor.setvalue(const value: msestring);
begin
 setmsestringvalue(value);
end;

procedure tmsestringpropertyeditor.edit;
var
 mstr1: msestring;
begin
 mstr1:= encodemsestring(getmsestringvalue(0));
 if memodialog(mstr1) = mr_ok then begin
  setmsestringvalue(decodemsestring(mstr1));
 end;
end;

{ tarraypropertyeditor }

function tarraypropertyeditor.allequal: boolean;
var
 int1: integer;
 int2: integer;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  int2:= tarrayprop(getpointervalue).count;
  for int1:= 1 to high(fprops) do begin
   if int2 <> tarrayprop(getpointervalue(int1)).count then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tpropertyeditor;
end;

function tarraypropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tarrayelementeditor;
end;

function tarraypropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_subproperties,ps_volatile];
end;

function tarraypropertyeditor.getvalue: msestring;
begin
 result:= inttostr(tarrayprop(getpointervalue).count);
end;

function tarraypropertyeditor.name: msestring;
begin
 result:= inherited name +'.count';
end;
{
procedure tarraypropertyeditor.setmincount(mincount: integer);
begin

end;
}
procedure tarraypropertyeditor.setvalue(const value: msestring);
var
 int1: integer;
 va: integer;
begin
 va:= strtoint(value);
 if va < 0 then begin
  va:= 0;
 end
 else begin
  if va > propmaxarraycount then begin
   va:= propmaxarraycount;
  end;
 end;
 int1:= tarrayprop(getpointervalue).count;
 if ( int1 > va) and not askok('Do you wish to delete items '+inttostr(va) +
         ' to '+ inttostr(int1-1) + '?','CONFIRMATION') then begin
  exit;
 end;
 if not ((ps_noadditems in fstate) and (va > int1)) then begin
  for int1:= 0 to high(fprops) do begin
   tarrayprop(getpointervalue(int1)).count:= va;
  end;
  modified;
 end;
end;

function tarraypropertyeditor.subproperties: propertyeditorarty;
var
 prop: tarrayprop;
 int1,int2: integer;
begin
 result:= inherited subproperties;
 int2:= 0;
 for int1:= 0 to high(result) do begin
  if result[int1].name = 'count' then begin
   result[int1].Free;
  end
  else begin
   result[int2]:= result[int1];
   inc(int2);
  end;
 end;
 setlength(result,int2);
 prop:= tarrayprop(getpointervalue);
 if prop <> nil then begin
  setlength(fsubprops,prop.count);
  for int1:= 0 to high(fsubprops) do begin
   fsubprops[int1]:= getelementeditorclass.create(int1,self,geteditorclass,
          fdesigner,fobjectinspector,fprops,ftypeinfo);
  end;
  stackarray(pointerarty(fsubprops),pointerarty(result));
 end
 else begin
  setlength(result,0);
 end;
end;

procedure tarraypropertyeditor.itemmoved(const source,dest: integer);
begin
 modified;
end;

procedure tarraypropertyeditor.dopopup(var amenu: tpopupmenu;
               const atransientfor: twidget; var mouseinfo: mouseeventinfoty);
begin
 if not (ps_noadditems in fstate) then begin
  tpopupmenu.additems(amenu,atransientfor,mouseinfo,
     ['Append Item'],[],[],[{$ifdef FPC}@{$endif}doappend]);
 end;
 inherited;
end;

procedure tarraypropertyeditor.doappend(const sender: tobject);
begin
 with tarrayprop(getpointervalue) do begin
  insertdefault(count);
 end;
 modified;
end;

procedure tarraypropertyeditor.move(const curindex: integer;
               const newindex: integer);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  tarrayprop(getpointervalue(int1)).move(curindex,newindex);
 end;
 itemmoved(curindex,newindex)
end;

function tarraypropertyeditor.itemprefix: msestring;
begin
 result:= 'Item ';
end;

{ tarrayelementeditor }

constructor tarrayelementeditor.create(aindex: integer;
            aparenteditor: tarraypropertyeditor; aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo);
begin
 findex:= aindex;
 fparenteditor:= aparenteditor;
 feditor:= aeditorclass.create(adesigner,aparenteditor.fmodule,
             aparenteditor.fcomponent,aobjectinspector,aprops,atypinfo);
 feditor.setremote(iremotepropertyeditor(self));
 inherited create(adesigner,feditor.fmodule,feditor.fcomponent,
         aobjectinspector,aprops,atypinfo);
end;

destructor tarrayelementeditor.destroy;
begin
 feditor.Free;
 inherited;
end;

function tarrayelementeditor.getordvalue(const index: integer = 0): integer;
begin
 with fprops[index] do begin
  result:= tintegerarrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setordvalue(const value: longword);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tintegerarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

procedure tarrayelementeditor.setordvalue(const index: integer; 
                         const value: longword);
begin
 with fprops[index] do begin
  tintegerarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
 end;
 modified;
end;

function tarrayelementeditor.getint64value(const index: integer = 0): int64;
begin
 with fprops[index] do begin
  result:= tint64arrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setint64value(const value: int64);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tint64arrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

procedure tarrayelementeditor.setint64value(const index: integer; 
                         const value: int64);
begin
 with fprops[index] do begin
  tint64arrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
 end;
 modified;
end;

function tarrayelementeditor.getpointervalue(const index: integer = 0): pointer;
begin
 with fprops[index] do begin
  result:= tpointerarrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setpointervalue(const value: pointer);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tpointerarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

procedure tarrayelementeditor.setpointervalue(const index: integer; 
                         const value: pointer);
begin
 with fprops[index] do begin
  tpointerarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
 end;
 modified;
end;

procedure tarrayelementeditor.setbitvalue(const value: boolean;
               const bitindex: integer);
var
 int1: integer;
 wo1: longword;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   wo1:= longword(tsetarrayprop(getpointerprop1(instance,propinfo))[findex]);
   updatebit(wo1,bitindex,value);
   tsetarrayprop(getpointerprop1(instance,propinfo))[findex]:= tintegerset(wo1);
  end;
 end;
 modified;
end;

function tarrayelementeditor.getfloatvalue(const index: integer = 0): extended;
begin
 with fprops[index] do begin
  result:= trealarrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setfloatvalue(const value: extended);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   trealarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

function tarrayelementeditor.getstringvalue(const index: integer = 0): string;
begin
 with fprops[index] do begin
  result:= tstringarrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setstringvalue(const value: string);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tstringarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

function tarrayelementeditor.getmsestringvalue(const index: integer = 0): msestring;
begin
 with fprops[index] do begin
  result:= tmsestringarrayprop(getpointerprop1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setmsestringvalue(const value: msestring);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tmsestringarrayprop(getpointerprop1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;
{
function tarrayelementeditor.getclassvalue(
  const aindex: integer): tpersistent;
begin
 with fprops[aindex] do begin
  result:= tpersistentarrayprop(GetOrdProp(instance,propinfo))[findex];
 end;
end;
}
function tarrayelementeditor.name: msestring;
begin
 result:= tarraypropertyeditor(fparenteditor).itemprefix + inttostr(findex);
end;

function tarrayelementeditor.subproperties: propertyeditorarty;
begin
 result:= feditor.subproperties;
end;

procedure tarrayelementeditor.dragbegin(var accept: boolean);
begin
 accept:= true;
end;

procedure tarrayelementeditor.dragdrop(const sender: tpropertyeditor);
begin
 if (sender is tarrayelementeditor) and
      (tarrayelementeditor(sender).fparenteditor = fparenteditor) then begin
  tarraypropertyeditor(fparenteditor).move(tarrayelementeditor(sender).findex,
                        findex);
 end;
end;

procedure tarrayelementeditor.dragover(const sender: tpropertyeditor;
  var accept: boolean);
begin
 accept:= (sender is tarrayelementeditor) and
      (tarrayelementeditor(sender).fparenteditor = fparenteditor);
end;

procedure tarrayelementeditor.dodelete(const sender: tobject);
begin
 if askyesno('Do you wish to delete '+getvalue+'?','CONFIRMATION') then begin
  tarrayprop(fparenteditor.getpointervalue).delete(findex);
  fparenteditor.modified;
 end;
end;

procedure tarrayelementeditor.doinsert(const sender: tobject);
begin
 tarrayprop(fparenteditor.getpointervalue).insertdefault(findex);
 fparenteditor.modified;
end;

procedure tarrayelementeditor.doappend(const sender: tobject);
begin
 tarrayprop(fparenteditor.getpointervalue).insertdefault(findex+1);
 fparenteditor.modified;
end;

procedure tarrayelementeditor.dopopup(var amenu: tpopupmenu;
                const atransientfor: twidget; var mouseinfo: mouseeventinfoty);
begin
 if not (ps_noadditems in fparenteditor.fstate) then begin
  tpopupmenu.additems(amenu,atransientfor,mouseinfo,
     ['Insert Item','Append Item','Delete Item'],[],[],
     [{$ifdef FPC}@{$endif}doinsert,
     {$ifdef FPC}@{$endif}doappend,{$ifdef FPC}@{$endif}dodelete]);
 end
 else begin
  if not (ps_nodeleteitems in fparenteditor.fstate) then begin
   tpopupmenu.additems(amenu,atransientfor,mouseinfo,
     ['Delete Item'],[],[],
     [{$ifdef FPC}@{$endif}dodelete]);
  end;
 end;
 inherited;
end;

{ tconstarraypropertyeditor }

function tconstarraypropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + 
         [ps_subproperties,ps_noadditems,ps_nodeleteitems{,ps_volatile}];
end;

function tconstarraypropertyeditor.getvalue: msestring;
begin
 result:= ''
end;

procedure tconstarraypropertyeditor.setvalue(const value: msestring);
begin
 //dummy
end;

function tconstarraypropertyeditor.name: msestring;
begin
 result:= fname;
end;

function tconstarraypropertyeditor.allequal: boolean;
begin
 result:= false;
end;

{ tclasselementeditor }
{
function tclasselementeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_subproperties];
end;

function tclasselementeditor.getvalue: msestring;
begin
 result:= '('+fprops[0].propinfo^.proptype^.name+')';
end;

function tclasselementeditor.subproperties: propertyeditorarty;
begin
 result:= fobjectinspector.getproperties(tobject(getclassvalue));
end;
}
procedure tarrayelementeditor.edit;
begin
 feditor.edit;
end;

function tarrayelementeditor.getdefaultstate: propertystatesty;
begin
 result:= feditor.getdefaultstate{ + [ps_volatile]};
end;

function tarrayelementeditor.getvalue: msestring;
begin
 result:= feditor.getvalue;
end;

function tarrayelementeditor.getvalues: msestringarty;
begin
 result:= feditor.getvalues;
end;

procedure tarrayelementeditor.setvalue(const value: msestring);
begin
 feditor.setvalue(value);
end;

function tarrayelementeditor.canrevert: boolean;
begin
 result:= false;
end;

function tarrayelementeditor.getselectedpropinstances: objectarty;
var
 int1,int2: integer;
begin
 with tarraypropertyeditor(fparenteditor) do begin
  setlength(result,length(fsubprops));
  int2:= 0;
  for int1:= 0 to high(fsubprops) do begin
   if fsubprops[int1].selected then begin
    result[int2]:= tobject(fsubprops[int1].feditor.getpointervalue);
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

function tarrayelementeditor.getvalueeditor: tpropertyeditor;
begin
 result:= feditor;
end;

function tarrayelementeditor.getlinksource: tcomponent;
begin
 result:= feditor.getlinksource;
end;

{ tpersistentarraypropertyeditor }

function tpersistentarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tclasselementeditor;
end;

{ toptionalpersistentarraypropertyeditor }

function toptionalpersistentarraypropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog,ps_volatile];
end;

procedure toptionalpersistentarraypropertyeditor.edit;
var
 obj1: tobject;
begin
 obj1:= getinstance;
 if obj1 = nil then begin
  setordvalue(1);
 end
 else begin
  if not checkfreeoptionalclass then begin
   exit;
  end;
  setordvalue(0);
 end;
 modified;
end;

function toptionalpersistentarraypropertyeditor.getinstance: tpersistent;
begin
 result:= tpersistent(getpointervalue);
end;

function toptionalpersistentarraypropertyeditor.getniltext: string;
begin
 result:= '<disabled>';
end;

function toptionalpersistentarraypropertyeditor.getvalue: msestring;
begin
 if getinstance = nil then begin
  result:= getniltext;
 end
 else begin
  result:= inherited getvalue;
 end;
end;

procedure toptionalpersistentarraypropertyeditor.setvalue(const value: msestring);
begin
 if getordvalue <> 0 then begin
  inherited;
 end;
end;

{ tmenuelementeditor }

function tmenuelementeditor.getvalue: msestring;
var
 item1: tmenuitem;
begin
 item1:= tmenuitem(getpointervalue);
 if (mao_separator in item1.options) then begin
  result:= '<---->';
 end
 else begin
  result:= '<' + decodemsestring(item1.caption) + '>';
  if item1.name <> '' then begin
   result:= result + '<' + item1.name + '>';
  end;
 end;
end;

{ tmenuarraypropertyeditor }

function tmenuarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmenuelementeditor;
end;

{ tintegerarraypropertyeditor }

function tintegerarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tordinalpropertyeditor;
end;

{ tsetarrayelementeditor }

constructor tsetarrayelementeditor.create(aindex: integer;
               aparenteditor: tarraypropertyeditor;
               aeditorclass: propertyeditorclassty; const adesigner: idesigner;
               const aobjectinspector: iobjectinspector;
               const aprops: propinstancearty; atypinfo: ptypeinfo);
begin
 inherited;
 feditor.ftypeinfo:= tsetarrayprop(aparenteditor.getpointervalue).typeinfo;
end;

{ tsetarraypropertyeditor }

function tsetarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tsetpropertyeditor;
end;

function tsetarraypropertyeditor.getelementeditorclass: elementeditorclassty;
begin
 result:= tsetarrayelementeditor;
end;

{ trealarraypropertyeditor}

function trealarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= trealtypropertyeditor;
end;

{ tcolorarraypropertyeditor }

function tcolorarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tcolorpropertyeditor;
end;

{ tstringarraypropertyeditor }

function tstringarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tstringpropertyeditor;
end;

{ tmsestringarraypropertyeditor }

function tmsestringarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tmsestringpropertyeditor;
end;

{ tordinalelementeditor }
{
function tordinalelementeditor.getvalue: msestring;
begin
 result:= inttostr(getordvalue);
end;

procedure tordinalelementeditor.setvalue(const value: msestring);
begin
 setordvalue(strtointvalue(value));
end;
}
{ tlclasselementeditor }

function tclasselementeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_canselect];
end;

function tclasselementeditor.getvalue: msestring;
var
 obj1: tobject;
begin
 obj1:= tobject(getpointervalue);
 if obj1 = nil then begin
  result:= '<nil>';
 end
 else begin
  result:= '<'+obj1.classtype.classname+'>';
 end;
end;

{ tcllectionitemeditor }

constructor tcollectionitemeditor.create(aindex: integer; 
            aparenteditor: tcollectionpropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo);
var
 props1: propinstancearty;
 int1: integer;
begin
 setlength(props1,length(aprops));
 for int1:= 0 to high(props1) do begin
  props1[int1].propinfo:= aprops[int1].propinfo;
  props1[int1].instance:= 
     tcollection(aparenteditor.getpointervalue(int1)).items[aindex];
 end;
 findex:= aindex;
 fparenteditor:= aparenteditor;
 feditor:= aeditorclass.create(adesigner,aparenteditor.fmodule,
             aparenteditor.fcomponent,aobjectinspector,props1,atypinfo);
 feditor.setremote(iremotepropertyeditor(self));
 inherited create(adesigner,feditor.fmodule,feditor.fcomponent,
         aobjectinspector,aprops,atypinfo);
end;

destructor tcollectionitemeditor.destroy;
begin
 feditor.free;
 inherited;
end;

procedure tcollectionitemeditor.setvalue(const value: msestring);
begin
 feditor.setvalue(value);
end;

function tcollectionitemeditor.getvalue: msestring;
begin
 result:= feditor.getvalue;
end;

function tcollectionitemeditor.getvalues: msestringarty;
begin
 result:= feditor.getvalues;
end;

procedure tcollectionitemeditor.edit;
begin
 feditor.edit;
end;

function tcollectionitemeditor.subproperties: propertyeditorarty;
begin
 result:= feditor.subproperties;
end;

function tcollectionitemeditor.name: msestring;
begin
 result:= 'Item '+inttostr(findex);
end;
{
function tcollectionitemeditor.getordvalue(const index: integer = 0): integer;
begin
 result:= integer(tcollection(fparenteditor.getpointervalue(index)).items[findex]);
end;

procedure tcollectionitemeditor.setordvalue(const value: longword);
begin
 //dummy
end;

procedure tcollectionitemeditor.setordvalue(const index: integer; 
                               const value: longword);
begin
 //dummy
end;
}
function tcollectionitemeditor.getpointervalue(const index: integer = 0): pointer;
begin
 result:= tcollection(fparenteditor.getpointervalue(index)).items[findex];
end;

procedure tcollectionitemeditor.setpointervalue(const value: pointer);
begin
 //dummy
end;

procedure tcollectionitemeditor.setpointervalue(const index: integer; 
                               const value: pointer);
begin
 //dummy
end;

procedure tcollectionitemeditor.doinsert(const sender: tobject);
begin
 tcollection(fparenteditor.getpointervalue).insert(findex);
 fparenteditor.modified;
end;

procedure tcollectionitemeditor.doappend(const sender: tobject);
begin
 tcollection(fparenteditor.getpointervalue).insert(findex+1);
 fparenteditor.modified;
end;

procedure tcollectionitemeditor.dodelete(const sender: tobject);
begin
 tcollection(fparenteditor.getpointervalue).delete(findex);
 fparenteditor.modified;
end;

function tcollectionitemeditor.getdefaultstate: propertystatesty;
begin
 result:= feditor.getdefaultstate;
end;

procedure tcollectionitemeditor.dragbegin(var accept: boolean);
begin
 accept:= true;
end;

procedure tcollectionitemeditor.dragover(const sender: tpropertyeditor; 
                                     var accept: boolean);
begin
 accept:= (sender is tcollectionitemeditor) and
      (tcollectionitemeditor(sender).fparenteditor = fparenteditor);
end;

procedure tcollectionitemeditor.dragdrop(const sender: tpropertyeditor);
var
 source: integer;
begin
 if (sender is tcollectionitemeditor) and
      (tcollectionitemeditor(sender).fparenteditor = fparenteditor) then begin
  source:= tcollectionitemeditor(sender).findex;
  tcollection(fparenteditor.getpointervalue).items[source].index:= findex;
//  sender.modified;
//  modified;
  tcollectionpropertyeditor(fparenteditor).itemmoved(source,findex);
 end;
end;

procedure tcollectionitemeditor.dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                       var mouseinfo: mouseeventinfoty);
begin
 tpopupmenu.additems(amenu,atransientfor,mouseinfo,
    ['Insert Item','Append Item','Delete Item'],[],[],
    [{$ifdef FPC}@{$endif}doinsert,
    {$ifdef FPC}@{$endif}doappend,{$ifdef FPC}@{$endif}dodelete]);
 inherited;
end;

function tcollectionitemeditor.getselectedpropinstances: objectarty;
begin
 result:= nil;
end;

{ tcollectionpropertyeditor }

function tcollectionpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_subproperties,ps_volatile];
end;

function tcollectionpropertyeditor.name: msestring;
begin
 result:= inherited name +'.count';
end;

function tcollectionpropertyeditor.getvalue: msestring;
var
 col1: tcollection;
begin
 col1:= tcollection(getpointervalue);
 if col1 <> nil then begin
  result:= inttostr(col1.count);
 end
 else begin
  result:= '<nil>';
 end;
end;

procedure tcollectionpropertyeditor.setvalue(const value: msestring);
var
 int1,int2: integer;
 va: integer;
 col1: tcollection;
begin
 col1:= tcollection(getpointervalue);
 if col1 <> nil then begin
  va:= strtoint(value);
  if va < 0 then begin
   va:= 0;
  end
  else begin
   if va > propmaxarraycount then begin
    va:= propmaxarraycount;
   end;
  end;
  int1:= col1.count;
  if ( int1 > va) then begin
   if askok('Do you wish to delete items '+inttostr(va) +
          ' to '+ inttostr(int1-1) + '?','CONFIRMATION') then begin
    for int2:= int1 - 1 downto va do begin
     col1.items[int2].free;
    end;
   end
   else begin
    exit;
   end;
  end
  else begin
   for int1:= 0 to high(fprops) do begin
    with tcollection(getpointervalue(int1)) do begin
     for int2:= count to va - 1 do begin
      add;
     end;
    end;
   end;
  end;
  modified;
 end;
end;

function tcollectionpropertyeditor.subproperties: propertyeditorarty;
var
 col1: tcollection;
 itemtypeinfo: ptypeinfo;
 edtype: propertyeditorclassty; 
 int1: integer;
begin
 col1:= tcollection(getpointervalue);
 if col1 <> nil then begin
  setlength(result,col1.count);
  itemtypeinfo:= ptypeinfo(col1.itemclass.classinfo);
  edtype:= propertyeditors.geteditorclass(itemtypeinfo,fcomponent.classtype,fname);
  for int1:= 0 to high(result) do begin
   result[int1]:= tcollectionitemeditor.create(int1,self,edtype,fdesigner,
            fobjectinspector,fprops,itemtypeinfo);
  end;
 end
 else begin
  result:= nil;
 end;
end;

procedure tcollectionpropertyeditor.dopopup(var amenu: tpopupmenu;
               const atransientfor: twidget; var mouseinfo: mouseeventinfoty);
begin
 if not (ps_noadditems in fstate) then begin
  tpopupmenu.additems(amenu,atransientfor,mouseinfo,
     ['Append Item'],[],[],[{$ifdef FPC}@{$endif}doappend]);
 end;
 inherited;
end;

procedure tcollectionpropertyeditor.doappend(const sender: tobject);
begin
 with tcollection(getpointervalue) do begin
  insert(count);
 end;
 modified;
end;

procedure tcollectionpropertyeditor.itemmoved(const source: integer;
               const dest: integer);
begin
 modified;
end;

{ tenumpropertyeditor }

function tenumpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist];
end;

function tenumpropertyeditor.getvalue: msestring;
begin
 result:= getenumname(gettypeinfo,getordvalue);
end;

procedure tenumpropertyeditor.setvalue(const value: msestring);
begin
 setordvalue(getenumvalue(gettypeinfo,value));
end;

function tenumpropertyeditor.getvalues: msestringarty;
var
 typedata1: ptypedata;
 atypeinfo: ptypeinfo;
begin
 atypeinfo:= gettypeinfo;
 typedata1:= gettypedata(atypeinfo);
 with typedata1^ do begin
  if minvalue < 0 then begin //for boolean
   setlength(result,2);
   result[0]:= getenumname(atypeinfo,0);
   result[1]:= getenumname(atypeinfo,1);
  end
  else begin
   result:= getenumnames(atypeinfo);
  end;
 end;
end;

function tenumpropertyeditor.gettypeinfo: ptypeinfo;
begin
 result:= ftypeinfo;
end;

{ tfontnamepropertyeditor }

function tfontnamepropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_sortlist];
end;

function tfontnamepropertyeditor.getvalues: msestringarty;
begin
 result:= getenumnames(typeinfo(stockfontty));
 stackarray(fontaliasnames,result);
end;

{ tbooleanpropertyeditor }

function tbooleanpropertyeditor.getdefaultstate: propertystatesty;
begin
 Result:= inherited getdefaultstate  + [ps_valuelist];
end;

procedure tbooleanpropertyeditor.setvalue(const value: msestring);
begin
 setordvalue(longword(uppercase(trim(value)) = uppercase(truename)));
end;

function tbooleanpropertyeditor.getvalue: msestring;
begin
 if getordvalue <> 0 then begin
  result:= truename;
 end
 else begin
  result:= falsename;
 end;
end;

function tbooleanpropertyeditor.getvalues: msestringarty;
begin
 setlength(result,2);
 result[0]:= falsename;
 result[1]:= truename;
end;

{ tdialogclasspropertyeditor }

function tdialogclasspropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog,ps_volatile];
end;

{ tbitmappropertyeditor }

procedure tbitmappropertyeditor.edit;
var
 bmp,bmp1: tmaskedbitmap;
 int1: integer;
 mstr1: filenamety;
 format1: string;
begin
 if imagefilepropedit(mstr1,format1) = mr_ok then begin
  bmp:= tmaskedbitmap.create(false);
  try
   bmp.loadfromfile(mstr1,format1);
   for int1:= 0 to high(fprops) do begin
    bmp1:= tmaskedbitmap(getpointervalue(int1));
    if bmp1 <> nil then begin
     bmp.alignment:= bmp1.alignment;
     bmp.colorbackground:= bmp1.colorbackground;
     bmp.colorforeground:= bmp1.colorforeground;
     bmp.transparency:= bmp1.transparency;
     bmp.transparentcolor:= bmp1.transparentcolor;
    end;
    setpointervalue(int1,bmp);
   end;
   modified;
  finally
   bmp.Free;
  end;
 end;
end;
{
procedure tbitmappropertyeditor.edit;
var
 bmp,bmp1: tmaskedbitmap;
 int1: integer;
 dialog: tfiledialog;
 statfile1: tstatfile;
begin
 statfile1:= tstatfile.create(nil);
 dialog:= tfiledialog.create(nil);
 try
  statfile1.options:= [sfo_memory];
  statfile1.filename:= bmpfiledialogstatname;
  with dialog,controller do begin
   filterlist.asarraya:= graphicfilefilternames;
   filterlist.asarrayb:= graphicfilemasks;
   captionopen:= 'Open image file';
   statfile:= statfile1;
   statfile.readstat;
   filename:= filedir(filename);
   if execute = mr_ok then begin
    statfile.writestat;
    bmp:= tmaskedbitmap.create(false);
    try
     bmp.loadfromfile(filename,graphicfilefilterlabel(filterindex));
     for int1:= 0 to high(fprops) do begin
      bmp1:= tmaskedbitmap(getordvalue(int1));
      if bmp1 <> nil then begin
       bmp.alignment:= bmp1.alignment;
       bmp.colorbackground:= bmp1.colorbackground;
       bmp.colorforeground:= bmp1.colorforeground;
       bmp.transparency:= bmp1.transparency;
       bmp.transparentcolor:= bmp1.transparentcolor;
      end;
      setordvalue(int1,ptruint(bmp));
     end;
     modified;
    finally
     bmp.Free;
    end;
   end;
  end;
 finally
  dialog.free;
  statfile1.free;
 end;
end;
}
function tbitmappropertyeditor.getvalue: msestring;
begin
 with tmaskedbitmap(getpointervalue) do begin
  if source <> nil then begin
   result:= fdesigner.getcomponentname(source);
  end
  else begin
   if isempty then begin
    result:= '<empty>';
   end
   else begin
    result:= inherited getvalue;
   end;
  end;
 end;
end;

procedure tbitmappropertyeditor.setvalue(const value: msestring);
var
 int1: integer;
begin
 if value = '' then begin
  for int1:= 0 to high(fprops) do begin
   tmaskedbitmap(getpointervalue(int1)).clear;
  end;
  modified;
 end;
end;

{ trealpropertyeditor }

function trealpropertyeditor.allequal: boolean;
var
 int1: integer;
 rea1: real;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  rea1:= getfloatvalue;
  for int1:= 1 to high(fprops) do begin
   if rea1 <> getfloatvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

procedure trealpropertyeditor.setvalue(const value: msestring);
begin
 setfloatvalue(strtoreal(value));
end;

function trealpropertyeditor.getvalue: msestring;
begin
 result:= realtostr(getfloatvalue);
end;

{ tcurrencypropertyeditor }

function tcurrencypropertyeditor.allequal: boolean;
var
 int1: integer;
 cu1: currency;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  cu1:= getcurrencyvalue;
  for int1:= 1 to high(fprops) do begin
   if cu1 <> getcurrencyvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

procedure tcurrencypropertyeditor.setvalue(const value: msestring);
begin
 setcurrencyvalue(strtoreal(value));
end;

function tcurrencypropertyeditor.getvalue: msestring;
begin
 result:= realtostr(getcurrencyvalue);
end;

{ trealtypropertyeditor }

function trealtypropertyeditor.allequal: boolean;
var
 int1: integer;
 rea1: real;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  rea1:= getfloatvalue;
  for int1:= 1 to high(fprops) do begin
   if rea1 <> getfloatvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function trealtypropertyeditor.getvalue: msestring;
begin
 result:= realtytostr(getfloatvalue);
end;

procedure trealtypropertyeditor.setvalue(const value: msestring);
begin
 setfloatvalue(strtorealty(value));
end;

{ tdatetimepropertyeditor }

function tdatetimepropertyeditor.allequal: boolean;
var
 int1: integer;
 rea1: real;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  rea1:= getfloatvalue;
  for int1:= 1 to high(fprops) do begin
   if rea1 <> getfloatvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

function tdatetimepropertyeditor.getvalue: msestring;
var
 rea1: real;
begin
// result:= datetimetostring(getfloatvalue,'dddddd t');
 rea1:= getfloatvalue;
 if rea1 = emptydatetime then  begin
  result:= '';
 end
 else begin
  if trunc(rea1) = 0 then begin
   result:= datetimetostring(getfloatvalue,'hh:nn:ss');
  end
  else begin
   if frac(rea1) = 0 then begin
    result:= datetimetostring(getfloatvalue,'yyyy-mm-dd');
   end
   else begin
    result:= datetimetostring(getfloatvalue,'yyyy-mm-dd hh:nn:ss');
   end;
  end;
 end;
end;

procedure tdatetimepropertyeditor.setvalue(const value: msestring);

 function encdate(const str: msestring): real;
 var
  ar2: msestringarty;
  year,month,day: word;
 begin
  result:= 0;
  ar2:= splitstring(str,msechar('-'));
  if high(ar2) >= 0 then begin
   year:= strtoint(ar2[0]);
   month:= 1;
   day:= 1;
   if high(ar2) > 0 then begin
    month:= strtoint(ar2[1]);
    if high(ar2) > 1 then begin
     day:= strtoint(ar2[2]);
    end;
   end;
  end
  else begin
   raise exception.create('Empty date.');
  end;
  result:= encodedate(year,month,day);
 end;

 function enctime(const str: msestring): real;
 var
  ar2: msestringarty;
  hour,minute,second: word;
 begin
  result:= 0;
  ar2:= splitstring(str,msechar(':'),true);
  if high(ar2) >= 0 then begin
   hour:= strtoint(ar2[0]);
   minute:= 0;
   second:= 0;
   if high(ar2) > 0 then begin
    minute:= strtoint(ar2[1]);
    if high(ar2) > 1 then begin
     second:= strtoint(ar2[2]);
    end;
   end;
   result:= encodetime(hour,minute,second,0);
  end
  else begin
   raise exception.create('Empty time.');
  end;
 end;
 
var
 rea1,rea2: real;
 ar1: msestringarty;
  
begin
 if value = '' then begin
  rea1:= emptydatetime;
 end
 else begin
  if value = ' ' then begin
   rea1:= now;
  end
  else begin
   rea1:= 0;
   rea2:= 0;
   ar1:= splitstring(value,msechar(' '),true);
   if high(ar1) > 0 then begin
    rea1:= encdate(ar1[0]);
    rea2:= enctime(ar1[1]);
   end
   else begin
    try
     rea1:= encdate(ar1[0]);
    except       
     rea1:= enctime(ar1[0]);
    end;
   end;
   rea1:= rea1 + rea2;
  end;
 end;
 setfloatvalue(rea1);
end;

{ tvariantpropertyeditor }

function tvariantpropertyeditor.allequal: boolean;
var
 int1: integer;
 var1: variant;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  var1:= getvariantvalue;
  for int1:= 1 to high(fprops) do begin
   if var1 <> getvariantvalue(int1) then begin
    result:= false;
    break;
   end;
  end;
 end;
end;

procedure tvariantpropertyeditor.setvalue(const value: msestring);
var
 var1: variant;
begin
 if value = '' then begin
  fillchar(var1,sizeof(var1),0);
  setvariantvalue(var1);
 end
 else begin
  setvariantvalue(value);
 end;
end;

function tvariantpropertyeditor.getvalue: msestring;
var
 var1: variant;
begin
 var1:= getvariantvalue;
 result:= '';
 if not varisnull(var1) then begin
  try
   result:= var1;
  except
  end;
 end;
end;

{ tshortcutpropertyeditor }

constructor tshortcutpropertyeditor.create(const adesigner: idesigner;
               const amodule: tmsecomponent; const acomponent: tcomponent;
               const aobjectinspector: iobjectinspector;
               const aprops: propinstancearty; atypeinfo: ptypeinfo);
begin
 fsc1:=  pos('shortcut1',aprops[0].propinfo^.name) = 1;
 inherited;
end;

function tshortcutpropertyeditor.getvaluetext(avalue: shortcutty): msestring;
var
 int1,int2: integer;
 keys: integerarty;
 names: msestringarty;
begin
 int2:= avalue;
 if int2 = 0 then begin
  result:= '';
 end
 else begin
  getshortcutlist(keys,names);
  for int1:= 0 to high(keys) do begin
   if int2 = keys[int1] then begin
    result:= names[int1];
    exit;
   end;
  end;
  result:= '$'+intvaluetostr(int2,nb_hex,16);
 end;
end;

procedure tshortcutpropertyeditor.setvalue(const value: msestring);
var
 ar1: msestringarty;
 ar2: shortcutarty;
 int1: integer;
 intf1: iactionlink;
begin
 ar1:= splitstring(value,widechar(' '));
 setlength(ar2,length(ar1));
 for int1:= 0 to high(ar1) do begin
  ar2[int1]:= texttovalue(ar1[int1]);
 end;
 for int1:= 0 to high(fprops) do begin
  if getcorbainterface(fprops[int1].instance,typeinfo(iactionlink),
                                                             intf1) then begin
   with intf1.getactioninfopo^ do begin
    if fsc1 then begin
     intf1.setshortcuts1(ar2);
    end
    else begin
     intf1.setshortcuts(ar2);
    end;
   end;
   modified;
  end
  else begin
   if high(ar2) = 0 then begin
    setordvalue(ar2[0]);
   end
   else begin
    setordvalue(int1,0);
   end;
  end;
 end;
end;

function tshortcutpropertyeditor.getvalue: msestring;
var
 ar1: shortcutarty;
 int1: integer;
 intf1: iactionlink;
begin
 result:= '';
 if getcorbainterface(fprops[0].instance,typeinfo(iactionlink),intf1) then begin
  with intf1.getactioninfopo^ do begin
   if self.fsc1 then begin
    ar1:= shortcut1;
   end
   else begin
    ar1:= shortcut;
   end;
   for int1:= 0 to high(ar1) do begin
    result:= result + getvaluetext(ar1[int1]) + ' ';
   end;
   if result <> '' then begin
    setlength(result,length(result)-1);
   end;
  end;
 end
 else begin
  result:= getvaluetext(getordvalue);
 end;
end;

function tshortcutpropertyeditor.getvalues: msestringarty;
var
 keys: integerarty;
 names: msestringarty;
begin
 getshortcutlist(keys,names);
 result:= names;
end;

function tshortcutpropertyeditor.texttovalue(const atext: msestring): shortcutty;
var
 int1: integer;
 keys: integerarty;
 names: msestringarty;
begin
 getshortcutlist(keys,names);
 for int1:= 0 to high(names) do begin
  if atext = names[int1] then begin
   result:= keys[int1];
   exit;
  end;
 end;
 if atext = '' then begin
  result:= 0;
 end
 else begin
  result:= strtointvalue(atext,nb_hex);
 end;
end;
{
procedure tshortcutpropertyeditor.setvalue(const value: msestring);
begin
 setordvalue(texttovalue(value));
end;
}
 { tcolorpropertyeditorty}

function tcolorpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tcolorpropertyeditor.edit;
var
 col1: colorty;
begin
 col1:= getordvalue;
 if colordialog(col1) = mr_ok then begin
  setordvalue(col1);
 end;
end;

function tcolorpropertyeditor.getvalue: msestring;
begin
 result:= colortostring(getordvalue);
end;

function tcolorpropertyeditor.getvalues: msestringarty;
begin
 result:= getcolornames;
end;

procedure tcolorpropertyeditor.setvalue(const value: msestring);
begin
 setordvalue(stringtocolor(value));
end;

{ tstringspropertyeditor }

procedure tstringspropertyeditor.closequery(const sender: tcustommseform; var amodalresult: modalresultty);
var
 int1: integer;
begin
 if amodalresult = mr_ok then begin
  try
   with tstringlisteditor(sender),tstrings(getpointervalue) do begin
    beginupdate;
    try
     clear;
     for int1:= 0 to grid.rowcount-1 do begin
      Add(valueedit[int1]);
     end;
    finally
     endupdate
    end;
   end;
   modified;
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
end;

procedure tstringspropertyeditor.edit;
var
 editform: tstringlisteditor;
 int1: integer;
 strings: tstrings;
begin
 strings:= tstrings(getpointervalue);
 editform:= tstringlisteditor.create({$ifdef FPC}@{$endif}closequery);
 try
  with editform do begin
   grid.rowcount:= strings.Count;
   for int1:= 0 to strings.Count - 1 do begin
    valueedit[int1]:= strings[int1];
   end;
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tstringspropertyeditor.getvalue: msestring;
begin
 if tstrings(getpointervalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
end;

{ ttextstringspropertyeditor }

procedure ttextstringspropertyeditor.closequery(const sender: tcustommseform; 
             var amodalresult: modalresultty);
var
 int1: integer;
 utf8: boolean;
 str1: ansistring;
 backup: string;
 backupm: msestringarty;
begin
 fmodalresult:= amodalresult;
 forigtext:= nil;
 if (amodalresult = mr_ok) or (amodalresult = mr_canclose) then begin
  try
   with tmsetexteditorfo(sender) do begin
    forigtext:= textedit.datalist.asmsestringarray;
    try
     if ismsestring then begin
      with tmsestringdatalist(getpointervalue) do begin
       backupm:= asarray;
       beginupdate;
       try
        clear;
        for int1:= 0 to grid.rowcount-1 do begin
         add(textedit[int1]);
        end;
       finally
        endupdate
       end;
      end;
     end
     else begin
      with tstrings(getpointervalue) do begin
       backup:= text;
       utf8:= getutf8;
       beginupdate;
       try
        clear;
        for int1:= 0 to grid.rowcount-1 do begin
         if utf8 then begin
          str1:= stringtoutf8(textedit[int1]);
         end
         else begin
          str1:= textedit[int1];
         end;
         updateline(str1);
         add(str1);
        end;
       finally
        endupdate
       end;
      end;
     end;
     doafterclosequery(amodalresult);
    finally
     if amodalresult = mr_canclose then begin
      if ismsestring then begin
       with tmsestringdatalist(getpointervalue) do begin
        asarray:= backupm;
       end;
      end
      else begin
       with tstrings(getpointervalue) do begin
        text:= backup;
       end;
      end;
     end;
    end;
   end;
  except
   application.handleexception(nil);
//   if amodalresult = mr_canclose then begin
    amodalresult:= mr_none;
//   end;
  end;
 end;
end;

procedure ttextstringspropertyeditor.edit;
var
 editform: tmsetexteditorfo;
 int1: integer;
 strings: tstrings;
 mstrings: tmsestringdatalist;
 utf8: boolean;
begin
 fmodalresult:= mr_cancel;
 editform:= tmsetexteditorfo.create({$ifdef FPC}@{$endif}closequery,
        msetexteditor.syntaxpainter,getsyntaxindex,gettestbutton);
 editform.textedit.createfont;
 editform.textedit.font.assign(textpropertyfont);
 utf8:= getutf8;
 try
  with editform do begin
   caption:= getcaption;
   if ismsestring then begin
    mstrings:= tmsestringdatalist(getpointervalue);
    grid.rowcount:= mstrings.Count;
    for int1:= 0 to mstrings.Count - 1 do begin
     textedit[int1]:= mstrings[int1];
    end;
   end
   else begin
    strings:= tstrings(getpointervalue);
    grid.rowcount:= strings.Count;
    for int1:= 0 to strings.Count - 1 do begin
     if utf8 then begin
      textedit[int1]:= utf8tostring(strings[int1]);
     end
     else begin
      textedit[int1]:= strings[int1];
     end;
    end;
   end;
   show(true,nil);
   modified;
  end;
 finally
  editform.Free;
 end;
end;

function ttextstringspropertyeditor.getvalue: msestring;
begin
 if ismsestring then begin
  if tmsestringdatalist(getpointervalue).count = 0 then begin
   result:= '<empty>';
  end
  else begin
   result:= inherited getvalue;
  end;
 end
 else begin
  if tstrings(getpointervalue).count = 0 then begin
   result:= '<empty>';
  end
  else begin
   result:= inherited getvalue;
  end;
 end;
end;

function ttextstringspropertyeditor.getsyntaxindex: integer;
begin
 result:= -1;
end;

procedure ttextstringspropertyeditor.doafterclosequery(var amodalresult: modalresultty);
begin
 //dummy
end;

function ttextstringspropertyeditor.gettestbutton: boolean;
begin
 result:= false;
end;

function ttextstringspropertyeditor.getutf8: boolean;
begin
 result:= false;
end;

procedure ttextstringspropertyeditor.setvalue(const avalue: msestring);
begin
 if (avalue = '') and askok('Do you wish to clear "'+fname+'"?') then begin
  if ismsestring then begin
   tmsestringdatalist(getpointervalue).clear;
  end
  else begin
   tstrings(getpointervalue).clear;
  end;
 end;
 inherited;
end;

function ttextstringspropertyeditor.getcaption: msestring;
begin
 result:= 'Texteditor';
end;

procedure ttextstringspropertyeditor.updateline(var aline: ansistring);
begin
 //dummy
end;

function ttextstringspropertyeditor.ismsestring: boolean;
begin
 result:= false;
end;

{ tdatalistpropertyeditor }

procedure tdatalistpropertyeditor.checkformkind;
var
 datalist1: tdatalist;
begin
 formkind:= lfk_none;
 datalist1:= tdatalist(getpointervalue);
 if datalist1 is tmsestringdatalist then begin
  formkind:= lfk_msestring;
 end
 else begin
  if datalist1 is trealdatalist then begin
   formkind:= lfk_real;
  end
  else begin
   if datalist1 is tintegerdatalist then begin
    formkind:= lfk_integer;
   end
   else begin
    if datalist1 is tmsestringintdatalist then begin
     formkind:= lfk_msestringint;
    end
    else begin
     if datalist1 is tcomplexdatalist then begin
      formkind:= lfk_complex;
     end
    end;
   end;
  end;
 end;
end;

procedure tdatalistpropertyeditor.edit;
var
 editform: tcustommseform;
 realdata: trealdatalist;
 complexdata: tcomplexdatalist;
begin
 checkformkind;
 case formkind of
  lfk_msestring: begin
   editform:= tstringlisteditor.create({$ifdef FPC}@{$endif}closequery);
  end;
  lfk_real: begin
   editform:= treallisteditor.create({$ifdef FPC}@{$endif}closequery);
  end;
  lfk_integer: begin
   editform:= tintegerlisteditor.create({$ifdef FPC}@{$endif}closequery);
  end;
  lfk_msestringint: begin
   editform:= tmsestringintlisteditor.create({$ifdef FPC}@{$endif}closequery);
  end;
  lfk_complex: begin
   editform:= tdoublereallisteditor.create({$ifdef FPC}@{$endif}closequery);
  end;
  else begin
   editform:= nil;
  end;
 end;
 try
  if editform <> nil then begin
   case formkind of
    lfk_msestring: begin
     tstringlisteditor(editform).valueedit.datalist.assign(
                                          tmsestringdatalist(getpointervalue));
    end;
    lfk_real: begin
     realdata:= trealdatalist(getpointervalue);
     with treallisteditor(editform).valueedit do begin
      griddata.assign(realdata);
      if realdata.defaultzero then begin
       valuedefault:= 0;
      end;
      min:= realdata.min;
      max:= realdata.max;
     end;
    end;
    lfk_integer: begin
     tintegerlisteditor(editform).valueedit.griddata.assign(
                                          tintegerdatalist(getpointervalue));
    end;
    lfk_msestringint: begin
     with tmsestringintlisteditor(editform) do begin
      texta.assigncol(tmsestringdatalist(getpointervalue));
      tmsestringintdatalist(getpointervalue).assigntob(textb.griddata);
     end;
    end;
    lfk_complex: begin
     complexdata:= tcomplexdatalist(getpointervalue);
     with tdoublereallisteditor(editform) do begin
      complexdata.assigntoa(vala.griddata);
      complexdata.assigntob(valb.griddata);
      if complexdata.defaultzero then begin
       vala.valuedefault:= 0;
       valb.valuedefault:= 0;
      end;
      vala.min:= complexdata.min;
      vala.max:= complexdata.max;
      valb.min:= vala.min;
      valb.max:= vala.max;
     end;
    end;
   end;
   editform.show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tdatalistpropertyeditor.getvalue: msestring;
var
 datalist1: tdatalist;
begin
 datalist1:= tdatalist(getpointervalue);
 if datalist1 = nil then begin
  result:= '<nil>';
 end
 else begin
  if datalist1.count = 0 then begin
   result:= '<empty>';
  end
  else begin
   result:= '<'+datalist1.classname+'>';
  end;
 end;
end;

procedure tdatalistpropertyeditor.closequery(const sender: tcustommseform;
               var amodalresult: modalresultty);
var
 datalist1: tdatalist;
 int1: integer;
begin
 if amodalresult = mr_ok then begin
  try
   for int1:= 0 to high (fprops) do begin
    datalist1:= tdatalist(getpointervalue(int1));
    case formkind of
     lfk_msestring: begin
      tmsestringdatalist(datalist1).assign(
                   tstringlisteditor(sender).valueedit.datalist);
     end;
     lfk_real: begin
      trealdatalist(datalist1).assign(
                    treallisteditor(sender).valueedit.griddata);
     end;
     lfk_integer: begin
      tintegerdatalist(datalist1).assign(
                    tintegerlisteditor(sender).valueedit.griddata);
     end;
     lfk_msestringint: begin
      with tmsestringintlisteditor(sender) do begin
       tmsestringintdatalist(datalist1).assign(texta.griddata);
       tmsestringintdatalist(datalist1).assignb(textb.griddata);
      end;
     end;
     lfk_complex: begin
      with tdoublereallisteditor(sender) do begin
       tcomplexdatalist(datalist1).assign(vala.griddata);
       tcomplexdatalist(datalist1).assignb(valb.griddata);
      end;
     end;
    end;
    modified;
   end;
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
end;

function tdatalistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 checkdatalistnostreaming(self,result);
end;

{ tmsestringdatalistpropertyeditor }

procedure tmsestringdatalistpropertyeditor.closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
var
 int1: integer;
begin
 if amodalresult = mr_ok then begin
  for int1:= 0 to high(fprops) do begin
   try
    tmsestringdatalist(getpointervalue(int1)).assign(
                   tstringlisteditor(sender).valueedit.datalist);
    modified;
   except
    application.handleexception(nil);
    amodalresult:= mr_none;
   end;
  end;
 end;
end;

procedure tmsestringdatalistpropertyeditor.edit;
var
 editform: tstringlisteditor;
begin
 editform:= tstringlisteditor.create({$ifdef FPC}@{$endif}closequery);
 try
  with editform do begin
   valueedit.datalist.assign(tmsestringdatalist(getpointervalue));
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tmsestringdatalistpropertyeditor.getvalue: msestring;
begin
 if tmsestringdatalist(getpointervalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
end;

function tmsestringdatalistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 checkdatalistnostreaming(self,result);
end;

{ tdoublemsestringdatalistpropertyeditor }

procedure tdoublemsestringdatalistpropertyeditor.closequery(
          const sender: tcustommseform; var amodalresult: modalresultty);
var
 list: tdoublemsestringdatalist;
begin
 if amodalresult = mr_ok then begin
  try
   with tdoublestringlisteditor(sender) do begin
   {$warnings off}
    list:= tdoublemsestringdatalist.create;
   {$warnings on}
    try
     list.assign(texta.griddata);
     list.assignb(textb.griddata);
     tdoublemsestringdatalist(getpointervalue).assign(list);
     modified;
    finally
     list.Free;
    end;
   end;
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
end;

procedure tdoublemsestringdatalistpropertyeditor.edit;
var
 editform: tdoublestringlisteditor;
begin
 editform:= tdoublestringlisteditor.create({$ifdef FPC}@{$endif}closequery);
 try
  with editform do begin
   texta.assigncol(tmsestringdatalist(getpointervalue));
   tdoublemsestringdatalist(getpointervalue).assigntob(textb.griddata);
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tdoublemsestringdatalistpropertyeditor.getvalue: msestring;
begin
 if tdoublemsestringdatalist(getpointervalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
end;

function tdoublemsestringdatalistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 checkdatalistnostreaming(self,result);
end;

{ tmsestringintdatalistpropertyeditor }

procedure tmsestringintdatalistpropertyeditor.closequery(
          const sender: tcustommseform; var amodalresult: modalresultty);
var
 list: tmsestringintdatalist;
begin
 if amodalresult = mr_ok then begin
  try
   with tmsestringintlisteditor(sender) do begin
{$warnings off}
    list:= tmsestringintdatalist.create;
{$warnings on}
    try
     list.assign(texta.griddata);
     list.assignb(textb.griddata);
     tmsestringintdatalist(getpointervalue).assign(list);
     modified;
    finally
     list.Free;
    end;
   end;
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
end;

procedure tmsestringintdatalistpropertyeditor.edit;
var
 editform: tmsestringintlisteditor;
begin
 editform:= tmsestringintlisteditor.create({$ifdef FPC}@{$endif}closequery);
 try
  with editform do begin
   texta.assigncol(tmsestringdatalist(getpointervalue));
   tmsestringintdatalist(getpointervalue).assigntob(textb.griddata);
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tmsestringintdatalistpropertyeditor.getvalue: msestring;
begin
 if tmsestringintdatalist(getpointervalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
end;

function tmsestringintdatalistpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 checkdatalistnostreaming(self,result);
end;

{ trecordpropertyeditor }

constructor trecordpropertyeditor.create(const adesigner: idesigner;
  const amodule: tmsecomponent; const acomponent: tcomponent;
  const aobjectinspector: iobjectinspector; const aname: string;
  const subprops: propertyeditorarty);
var
 int1: integer;
begin
 inherited create(adesigner,amodule,acomponent,aobjectinspector,nil,nil);
 fname:= aname;
 fsubproperties:= subprops;
 for int1:= 0 to high(fsubproperties) do begin
  with fsubproperties[int1] do begin
   include(fstate,ps_owned);
   fparenteditor:= self;
  end;
 end;
end;

function trecordpropertyeditor.allequal: boolean;
begin
 result:= true;
end;


destructor trecordpropertyeditor.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fsubproperties) do begin
  fsubproperties[int1].Free;
 end;
 inherited;
end;

function trecordpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= [ps_subproperties];
end;

function trecordpropertyeditor.getvalue: msestring;
begin
 result:= '_';
end;

function trecordpropertyeditor.subproperties: propertyeditorarty;
begin
 result:= fsubproperties;
end;

procedure trecordpropertyeditor.setsubprop;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fsubproperties) do begin
  include(fsubproperties[int1].fstate,ps_subprop);
 end;
end;

{ tconstelementeditor }

constructor tconstelementeditor.create(const avalue: msestring; aindex: integer;
     aparenteditor: tarraypropertyeditor; aeditorclass: propertyeditorclassty; 
     const adesigner: idesigner; const aobjectinspector: iobjectinspector; 
     const aprops: propinstancearty; atypinfo: ptypeinfo);
begin
 fvalue:= avalue;
 inherited create(aindex,aparenteditor,aeditorclass,adesigner,aobjectinspector,
                  aprops,atypinfo);
end;

function tconstelementeditor.getvalue: msestring;
begin
 result:= fvalue;
end;

procedure tconstelementeditor.dragdrop(const sender: tpropertyeditor);
begin
 if (sender is tarrayelementeditor) and
      (tarrayelementeditor(sender).fparenteditor = fparenteditor) then begin
//  sender.modified;
//  modified;
  tarraypropertyeditor(fparenteditor).itemmoved(
          tarrayelementeditor(sender).findex,findex);
 end;
end;

{ tnamepropertyeditor }

procedure tnamepropertyeditor.setvalue(const value: msestring);
begin
 if not isvalidident(value) then begin
  raise exception.create('Invalid component name '''+value+'''.');
 end;
 inherited;
end;

{ trefreshstringpropertyeditor }

function trefreshstringpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_refresh];
end;

{ tvolatilebooleanpropertyeditor }

function tvolatilebooleanpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_volatile];
end;

{ trefreshbooleanpropertyeditor }

function trefreshbooleanpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_refresh];
end;

{ tcomponentinterfacepropertyeditor }

function tcomponentinterfacepropertyeditor.filtercomponent(
                                      const acomponent: tcomponent): boolean;
var
 po1: pointer;
begin
 result:= getcorbainterface(acomponent,fintfinfo,po1);
end;

procedure tcomponentinterfacepropertyeditor.updatedefaultvalue;
begin
 fintfinfo:= getintfinfo;
end;

initialization
// apropertyeditors:= tpropertyeditors.Create;
finalization
 freeandnil(fpropertyeditors);
 freeandnil(ftextpropertyfont);
end.
