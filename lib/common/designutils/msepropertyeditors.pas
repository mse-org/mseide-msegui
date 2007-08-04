{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepropertyeditors;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,TypInfo,msedesignintf,msetypes,msestrings,sysutils,msedatalist,msemenus,
 mseevent,msegui,mseclasses,mseforms;

const
 bmpfiledialogstatname = 'bmpfile.sta';
 
type

 tpropertyeditor = class;
 propertyeditorarty = array of tpropertyeditor;

 propinstancety = record
  instance: tobject;
  propinfo: ppropinfo;
 end;
 propinstancearty = array of propinstancety;
 ppropinstancearty = ^propinstancearty;

 iobjectinspector = interface
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
                   ps_local,  //do not display foreign components
                   ps_link);  //do not display selected components
 propertystatesty = set of propertystatety;

 iremotepropertyeditor = interface
  function getordvalue(const index: integer = 0): integer;
  procedure setordvalue(const value: longword); overload;
  procedure setordvalue(const index: integer; const value: longword); overload;
  procedure setbitvalue(const value: boolean; const index: integer);
  function getfloatvalue(const index: integer = 0): extended;
  procedure setfloatvalue(const value: extended);
  function getcurrencyvalue(const index: integer = 0): currency;
  procedure setcurrencyvalue(const value: currency);
  function getstringvalue(const index: integer = 0): string;
  procedure setstringvalue(const value: string);
  function getmsestringvalue(const index: integer = 0): msestring;
  procedure setmsestringvalue(const value: msestring);
  function getparenteditor: tpropertyeditor;

  function getmethodvalue(const index: integer = 0): tmethod;
  procedure setmethodvalue(const value: tmethod);
 end;

 tpropertyeditor = class(tnullinterfacedobject)
  private
   function getexpanded: boolean;
   procedure setexpanded(const Value: boolean);
   function getcount: integer;
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
   procedure setbitvalue(const value: boolean; const index: integer);
   function getfloatvalue(const index: integer = 0): extended;
   procedure setfloatvalue(const value: extended);
   function getcurrencyvalue(const index: integer = 0): currency;
   procedure setcurrencyvalue(const value: currency);
   function getstringvalue(const index: integer = 0): string;
   procedure setstringvalue(const value: string);
   function getmsestringvalue(const index: integer = 0): msestring;
   procedure setmsestringvalue(const value: msestring);
   
   function decodemsestring(const avalue: msestring): msestring;
   function encodemsestring(const avalue: msestring): msestring;

   function getmethodvalue(const index: integer = 0): tmethod;
   procedure setmethodvalue(const value: tmethod);
   function getparenteditor: tpropertyeditor;

   procedure modified; virtual;
   function getdefaultstate: propertystatesty; virtual;
   procedure updatedefaultvalue; virtual;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo); virtual;
   destructor destroy; override;
   procedure setremote(intf: iremotepropertyeditor);

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
   property module: tmsecomponent read fmodule;
   property component: tcomponent read fcomponent;
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
  public
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
  public
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

 tcomponentpropertyeditor = class(tclasspropertyeditor)
  protected
   function issubcomponent(const index: integer = 0): boolean;
   function getdefaultstate: propertystatesty; override;
   procedure checkcomponent(const avalue: tcomponent); virtual;
  public
   function allequal: boolean; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function getvalues: msestringarty; override;
 end;

 tsisterwidgetpropertyeditor = class(tcomponentpropertyeditor)
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
   procedure updatedefaultvalue; override;
  public
   constructor create(const adesigner: idesigner;
        const amodule: tmsecomponent; const acomponent: tcomponent;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypeinfo: ptypeinfo;
            const aparent: tsetpropertyeditor; const aindex: integer);
                             reintroduce; virtual;
  
   function allequal: boolean; override;
   function name: msestring; override;
   function getvalue: msestring; override;
   function getvalues: msestringarty; override;
   procedure setvalue(const value: msestring); override;
 end;

 tsetpropertyeditor = class(tordinalpropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
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
  public
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
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   procedure doafterclosequery(var amodalresult: modalresultty); virtual;                    
   function getsyntaxindex: integer; virtual;
   function gettestbutton: boolean; virtual;
   function getutf8: boolean; virtual;
   function getcaption: msestring; virtual;
  public
   procedure edit; override;
   procedure setvalue(const avalue: msestring); override;
   function getvalue: msestring; override;
 end;

 listeditformkindty = (lfk_none,lfk_msestring,lfk_real,lfk_integer);
 
 tdatalistpropertyeditor = class(tdialogclasspropertyeditor)
  protected
   formkind: listeditformkindty;
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
   procedure checkformkind;
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
 end;

 tdoublemsestringdatalistpropertyeditor = class(tdialogclasspropertyeditor)
   procedure edit; override;
   function getvalue: msestring; override;
  protected
   procedure closequery(const sender: tcustommseform;
                       var amodalresult: modalresultty);
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
   function getfloatvalue(const index: integer = 0): extended;
   procedure setfloatvalue(const value: extended);
   function getstringvalue(const index: integer = 0): string;
   procedure setstringvalue(const value: string);
   function getmsestringvalue(const index: integer = 0): msestring;
   procedure setmsestringvalue(const value: msestring);

   function getdefaultstate: propertystatesty; override;
  public
   constructor create(aindex: integer; aparenteditor: tarraypropertyeditor;
            aeditorclass: propertyeditorclassty;
            const adesigner: idesigner;
            const aobjectinspector: iobjectinspector;
            const aprops: propinstancearty; atypinfo: ptypeinfo); reintroduce;
   destructor destroy; override;
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

 tarraypropertyeditor = class(tclasspropertyeditor)
  private
   procedure doappend(const sender: tobject);
  protected
   function getdefaultstate: propertystatesty; override;
   function geteditorclass: propertyeditorclassty; virtual;
   function getelementeditorclass: elementeditorclassty; virtual;
   procedure itemmoved(const source,dest: integer); virtual;
  public
   procedure move(const curindex,newindex: integer); virtual;
   function allequal: boolean; override;
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
   function subproperties: propertyeditorarty; override;
   function name: msestring; override;
   procedure dopopup(var amenu: tpopupmenu; const atransientfor: twidget;
                          var mouseinfo: mouseeventinfoty); override;
 end;
 
 tcollectionpropertyeditor = class;
 
 tcollectionitemeditor = class(tpropertyeditor,iremotepropertyeditor)
  private
   findex: integer;
   feditor: tpropertyeditor;
  protected
   function getdefaultstate: propertystatesty; override;
   function getordvalue(const index: integer = 0): integer;
   procedure setordvalue(const value: longword); overload;
   procedure setordvalue(const index: integer; const value: longword); overload;
   procedure doinsert(const sender: tobject);
   procedure doappend(const sender: tobject);
   procedure dodelete(const sender: tobject);
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

 tmenuelementeditor =  class(tclasspropertyeditor)
  public
   function getvalue: msestring; override;
 end;
{
 tordinalelementeditor = class(tarrayelementeditor)
  public
   function getvalue: msestring; override;
   procedure setvalue(const value: msestring); override;
 end;
}
 tclasselementeditor = class(tclasspropertyeditor)
  public
   function getvalue: msestring; override;
 end;
 
 tintegerarraypropertyeditor = class(tarraypropertyeditor)
  protected
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
 
function propertyeditors: tpropertyeditors;
procedure registerpropertyeditor(propertytype: ptypeinfo;
  propertyownerclass: tclass; const propertyname: string;
  editorclass: propertyeditorclassty);
  
implementation
uses
 mseformatstr,msebits,msearrayprops,msebitmap,
 msefiledialog,mseimagelisteditor,msereal,msewidgets,
 msegraphics,mseactions,mseguiglob,msehash,
 msestringlisteditor,msedoublestringlisteditor,msereallisteditor,
 mseintegerlisteditor,
 msecolordialog,
 mseshapes,msestockobjects,msetexteditor,
 msegraphicstream,
 mseformatbmpico{$ifdef FPC},mseformatjpg,mseformatpng,
 mseformatpnm,mseformattga,mseformatxpm{$endif},msestat,msestatfile,msefileutils,
 msedesigner;

const
 methodsortlevel = 100;
 falsename = 'False';
 truename = 'True';

type
 twidget1 = class(twidget);
 tcustomcaptionframe1 = class(tcustomcaptionframe);
 tdesigner1 = class(tdesigner);

var
 apropertyeditors: tpropertyeditors;

Function  GetOrdProp1(Instance: TObject; PropInfo : PPropInfo) : Longint;
begin
 result:= getordprop(instance,propinfo);
end;

function propertyeditors: tpropertyeditors;
begin
 if apropertyeditors = nil then begin
  apropertyeditors:= tpropertyeditors.create;
 end;
 result:= apropertyeditors;
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
   {
    if typeclasslevel > atypeclasslevel then begin
     savelevel;
    end
    else begin
     if typeclasslevel = atypeclasslevel then begin
      if propertyownerclasslevel > apropertyownerclasslevel then begin
       savelevel;
      end
      else begin
       if propertyownerclasslevel = apropertyownerclasslevel then begin
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
    }
   end
   else begin
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
    result[int1]:= tcomponent(ed1.getordvalue);
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
begin
 if fremote <> nil then begin
  fremote.setordvalue(value);
 end
 else begin
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    setordprop(instance, propinfo, value);
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

procedure tpropertyeditor.setbitvalue(const value: boolean; const index: integer);
var
 int1: integer;
 wo1: longword;
begin
 if fremote <> nil then begin
  fremote.setbitvalue(value,index);
 end
 else begin
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    wo1:= getordprop(instance,propinfo);
    updatebit(wo1,index,value);
    setordprop(instance,propinfo,wo1);
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
begin
 if fremote <> nil then begin
  fremote.setfloatvalue(value);
 end
 else begin
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    SetfloatProp(Instance, PropInfo, Value);
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
begin
 if fremote <> nil then begin
  fremote.setcurrencyvalue(value);
 end
 else begin
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    setfloatprop(instance, propinfo, value);
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
begin
 if fremote <> nil then begin
  fremote.setstringvalue(value);
 end
 else begin
  str1:= encodemsestring(value);
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    SetstrProp(Instance, PropInfo, str1);
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
    c_tab: begin po1^:= '#'; inc(po1); po1^:= 't'; end;
    c_linefeed: begin po1^:= '#'; inc(po1); po1^:= 'n'; end;
    c_return: begin po1^:= '#'; inc(po1); po1^:= 'r'; end;
    '#': begin po1^:= '#'; inc(po1); po1^:= '#'; end;
    else begin
     if avalue[int1] < widechar(32) then begin
      mstr1:= '#'+inttostr(ord(avalue[int1]));
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
   if (avalue[int1] = '#') and (int1 < length(avalue)+1) then begin
    case avalue[int1+1] of
     '#': po1^:= '#';
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
     else begin po1^:= '#'; dec(int1); end;
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
   result:= decodemsestring(GetwidestrProp(instance,propinfo));     
  end;
 end;
end;

procedure tpropertyeditor.setmsestringvalue(const value: msestring);
var
 mstr1: msestring;
 int1: integer;
begin
 if fremote <> nil then begin
  fremote.setmsestringvalue(value);
 end
 else begin
  mstr1:= encodemsestring(value);
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    setwidestrprop(instance,propinfo,mstr1);  
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
begin
 if fremote <> nil then begin
  fremote.setmethodvalue(value);
 end
 else begin
  for int1:= 0 to high(fprops) do begin
   with fprops[int1] do begin
    SetmethodProp(Instance, PropInfo, Value);
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
                  fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif});
  if method1.data = nil then begin //method not found
   if (method2.data <> nil) and not isselected then begin
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

function tsetpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate  + [ps_subproperties];
end;

function tsetpropertyeditor.getvalue: msestring;
begin
{$ifdef FPC}
 result:= '['+concatstrings(settostrings(tintegerset(cardinal(getordvalue)),
      gettypedata(fprops[0].propinfo^.proptype)^.comptype),',')+']';
{$else}
 result:= '['+concatstrings(settostrings(tintegerset(cardinal(getordvalue)),
      gettypedata(fprops[0].propinfo^.proptype^)^.comptype^),',')+']';
{$endif}
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
 setordvalue(longword(stringstoset(ar1,fprops[0].propinfo^.proptype{$ifndef FPC}^{$endif})));
end;

function tsetpropertyeditor.subproperties: propertyeditorarty;
var
 compty: ptypeinfo;
 int1: integer;
begin
 compty:= gettypedata(ftypeinfo)^.comptype{$ifndef FPC}^{$endif};
 setlength(result,gettypedata(compty)^.MaxValue+1);
 for int1:= 0 to high(result) do begin
  result[int1]:= tsetelementeditor.create(fdesigner,fmodule,fcomponent,
                    fobjectinspector,fprops,compty,self,int1);
 end;
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
end;

function tsetelementeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_valuelist,ps_candefault];
end;

function tsetelementeditor.getvalue: msestring;
begin
 if findex in tintegerset(cardinal(getordvalue)) then begin
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
  bo1:= findex in tintegerset(cardinal(getordvalue));
  for int1:= 1 to high(fprops) do begin
   if bo1 <> (findex in tintegerset(cardinal(getordvalue(int1)))) then begin
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
begin
 setlength(ar1,count);
 for int1:= 0 to high(fprops) do begin
  ar1[int1]:= tobject(getordvalue(int1));
 end;
 result:= fobjectinspector.getproperties(ar1,fmodule,fcomponent);
 for int1:= 0 to high(result) do begin
  result[int1].fparenteditor:= self;
 end;
 if fstate * [ps_component,ps_subprop] <> [] then begin
  for int1:= 0 to high(result) do begin
   include(result[int1].fstate,ps_subprop);
  end;
 end;
end;

{ tcomponentpropertyeditor }

function tcomponentpropertyeditor.issubcomponent(const index: integer = 0): boolean;
var
 comp: tcomponent;
begin
 comp:= tcomponent(getordvalue(index));
 if comp = nil then begin
  result:= false;
 end
 else begin
  result:= cssubcomponent in comp.ComponentStyle;
 end;
end;

function tcomponentpropertyeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate;
 if not issubcomponent then begin
  result:= result + [ps_valuelist,ps_volatile,ps_component];
 end;
end;

function tcomponentpropertyeditor.allequal: boolean;
var
 ca1: cardinal;
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
   ca1:= getordvalue;
   for int1:= 1 to high(fprops) do begin
    if cardinal(getordvalue(int1)) <> ca1 then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

function tcomponentpropertyeditor.getvalue: msestring;
var
 comp1: tcomponent;
begin
 if issubcomponent then begin
  result:= inherited getvalue;
 end
 else begin
  comp1:= tcomponent(getordvalue);
  if comp1 = nil then begin
   result:= '<nil>'
  end
  else begin
   result:= fdesigner.getcomponentname(comp1);
  end;
  if result = '' then begin
   result:= ownernamepath(comp1);
  end;
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
   ar1:= fdesigner.getcomponentlist(tcomponentclass(typedata^.classtype));
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
                  tcomponentclass(typedata^.classtype),false,co1);
  end;
 end;
end;

procedure tcomponentpropertyeditor.setvalue(const value: msestring);
var
 comp: tcomponent;
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
    comp:= fdesigner.getcomponent(value,fmodule);
    if (comp = nil) or not comp.InheritsFrom(gettypedata(ftypeinfo)^.classtype) then begin
     properror;
    end;
    checkcomponent(comp);
   end
   else begin
    exit;
   end;
  end;
  setordvalue(cardinal(comp));
 end;
end;

procedure tcomponentpropertyeditor.checkcomponent(const avalue: tcomponent);
begin
 //dummy
end;

{ tsisterwidgetpropertyeditor }

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

function tsisterwidgetpropertyeditor.getdefaultstate: propertystatesty;
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

procedure toptionalclasspropertyeditor.edit;
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
//  modified;
end;

function toptionalclasspropertyeditor.getinstance: tpersistent;
begin
 result:= tpersistent(getordvalue);
end;

function toptionalclasspropertyeditor.getniltext: string;
begin
 result:= '<disabled>';
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
    persist1:= tpersistent(getordvalue(int1));
    setordvalue(int1,1);
    persist2:= tpersistent(getordvalue(int1));
    if (persist1 <> nil) and (persist2 <> nil) then begin
     persist2.Assign(persist1);
    end;
   end;
  end
  else begin
   if not checkfreeoptionalclass then begin
    exit;
   end;
   setordvalue(0);
  end;
//  modified;
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
 result:= inherited getdefaultstate + [ps_isordprop];
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

{ tarraypropertyeditor }

function tarraypropertyeditor.allequal: boolean;
var
 int1: integer;
 int2: integer;
begin
 result:= inherited allequal;
 if not result then begin
  result:= true;
  int2:= tarrayprop(getordvalue).count;
  for int1:= 1 to high(fprops) do begin
   if int2 <> tarrayprop(getordvalue(int1)).count then begin
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
 result:= inttostr(tarrayprop(getordvalue).count);
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
 int1:= tarrayprop(getordvalue).count;
 if ( int1 > va) and not askok('Do you wish to delete items '+inttostr(va) +
         ' to '+ inttostr(int1-1) + '?','CONFIRMATION') then begin
  exit;
 end;
 if not ((ps_noadditems in fstate) and (va > int1)) then begin
  for int1:= 0 to high(fprops) do begin
   tarrayprop(getordvalue(int1)).count:= va;
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
 prop:= tarrayprop(getordvalue);
 if prop <> nil then begin
  setlength(result,int2+prop.count);
  for int1:= int2 to high(result) do begin
   result[int1]:= getelementeditorclass.create(int1-int2,self,geteditorclass,
          fdesigner,fobjectinspector,fprops,ftypeinfo);
  end;
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
 with tarrayprop(getordvalue) do begin
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
  tarrayprop(getordvalue(int1)).move(curindex,newindex);
 end;
 itemmoved(curindex,newindex)
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
  result:= tintegerarrayprop(GetOrdProp1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setordvalue(const value: longword);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tintegerarrayprop(GetOrdProp1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

procedure tarrayelementeditor.setordvalue(const index: integer; 
                         const value: longword);
begin
 with fprops[index] do begin
  tintegerarrayprop(GetOrdProp1(instance,propinfo))[findex]:= value;
 end;
 modified;
end;

function tarrayelementeditor.getfloatvalue(const index: integer = 0): extended;
begin
 with fprops[index] do begin
  result:= trealarrayprop(GetOrdProp1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setfloatvalue(const value: extended);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   trealarrayprop(GetOrdProp1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

function tarrayelementeditor.getstringvalue(const index: integer = 0): string;
begin
 with fprops[index] do begin
  result:= tstringarrayprop(GetOrdProp1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setstringvalue(const value: string);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tstringarrayprop(GetOrdProp1(instance,propinfo))[findex]:= value;
  end;
 end;
 modified;
end;

function tarrayelementeditor.getmsestringvalue(const index: integer = 0): msestring;
begin
 with fprops[index] do begin
  result:= tmsestringarrayprop(GetOrdProp1(instance,propinfo))[findex];
 end;
end;

procedure tarrayelementeditor.setmsestringvalue(const value: msestring);
var
 int1: integer;
begin
 for int1:= 0 to high(fprops) do begin
  with fprops[int1] do begin
   tmsestringarrayprop(GetOrdProp1(instance,propinfo))[findex]:= value;
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
 result:= 'Item ' + inttostr(findex);
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
  tarrayprop(fparenteditor.getordvalue).delete(findex);
  fparenteditor.modified;
 end;
end;

procedure tarrayelementeditor.doinsert(const sender: tobject);
begin
 tarrayprop(fparenteditor.getordvalue).insertdefault(findex);
 fparenteditor.modified;
end;

procedure tarrayelementeditor.doappend(const sender: tobject);
begin
 tarrayprop(fparenteditor.getordvalue).insertdefault(findex+1);
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
 result:= tpersistent(getordvalue);
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
 item1:= tmenuitem(getordvalue);
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

function tclasselementeditor.getvalue: msestring;
var
 obj1: tobject;
begin
 obj1:= tobject(getordvalue);
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
     tcollection(aparenteditor.getordvalue(int1)).items[aindex];
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

function tcollectionitemeditor.getordvalue(const index: integer = 0): integer;
begin
 result:= integer(tcollection(fparenteditor.getordvalue(index)).items[findex]);
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

procedure tcollectionitemeditor.doinsert(const sender: tobject);
begin
 tcollection(fparenteditor.getordvalue).insert(findex);
 fparenteditor.modified;
end;

procedure tcollectionitemeditor.doappend(const sender: tobject);
begin
 tcollection(fparenteditor.getordvalue).insert(findex+1);
 fparenteditor.modified;
end;

procedure tcollectionitemeditor.dodelete(const sender: tobject);
begin
 tcollection(fparenteditor.getordvalue).delete(findex);
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
  tcollection(fparenteditor.getordvalue).items[source].index:= findex;
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
 col1:= tcollection(getordvalue);
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
 col1:= tcollection(getordvalue);
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
    with tcollection(getordvalue(int1)) do begin
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
 col1:= tcollection(getordvalue);
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
 with tcollection(getordvalue) do begin
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
 setordvalue(cardinal(uppercase(trim(value)) = uppercase(truename)));
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
 bmp: tmaskedbitmap;
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
//      tmaskedbitmap(getordvalue(int1)).assign(bmp);
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
 {
 str1:= '';
 int1:= 0;
 if filedialog(str1,[],'',graphicfilefilternames,graphicfilemasks,
                  '',@int1) = mr_ok then begin
  bmp:= tmaskedbitmap.create(false);
  try
   bmp.loadfromfile(str1,graphicfilefilterlabel(int1));
   for int1:= 0 to high(fprops) do begin
    tmaskedbitmap(getordvalue(int1)).assign(bmp);
   end;
   modified;
  finally
   bmp.Free;
  end;
 end;
 }
end;

function tbitmappropertyeditor.getvalue: msestring;
begin
 with tmaskedbitmap(getordvalue) do begin
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
   tmaskedbitmap(getordvalue(int1)).clear;
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
begin
 result:= datetimetostring(getfloatvalue,'dddddd t');
end;

procedure tdatetimepropertyeditor.setvalue(const value: msestring);
begin
 setfloatvalue(stringtodatetime(value));
end;

{ tshortcutpropertyeditor }

function tshortcutpropertyeditor.getvalue: msestring;
var
 int1,int2: integer;
 keys: integerarty;
 names: msestringarty;
begin
 int2:= getordvalue;
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

function tshortcutpropertyeditor.getvalues: msestringarty;
var
 keys: integerarty;
 names: msestringarty;
begin
 getshortcutlist(keys,names);
 result:= names;
end;

procedure tshortcutpropertyeditor.setvalue(const value: msestring);
var
 int1: integer;
 keys: integerarty;
 names: msestringarty;
begin
 getshortcutlist(keys,names);
 for int1:= 0 to high(names) do begin
  if value = names[int1] then begin
   setordvalue(keys[int1]);
   exit;
  end;
 end;
 if value = '' then begin
  int1:= 0;
 end
 else begin
  int1:= strtointvalue(value,nb_hex);
 end;
 setordvalue(int1);
end;

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
   with tstringlisteditor(sender),tstrings(getordvalue) do begin
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
 strings:= tstrings(getordvalue);
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
 if tstrings(getordvalue).count = 0 then begin
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
begin
 if (amodalresult = mr_ok) or (amodalresult = mr_canclose) then begin
  utf8:= getutf8;
  try
   with tmsetexteditorfo(sender),tstrings(getordvalue) do begin
    beginupdate;
    try
     clear;
     for int1:= 0 to grid.rowcount-1 do begin
      if utf8 then begin
       add(stringtoutf8(textedit[int1]));
      end
      else begin
       add(textedit[int1]);
      end;
     end;
    finally
     endupdate
    end;
   end;
   doafterclosequery(amodalresult);
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
end;

procedure ttextstringspropertyeditor.edit;
var
 editform: tmsetexteditorfo;
 int1: integer;
 strings: tstrings;
 utf8: boolean;
begin
 strings:= tstrings(getordvalue);
 editform:= tmsetexteditorfo.create({$ifdef FPC}@{$endif}closequery,
        msetexteditor.syntaxpainter,getsyntaxindex,gettestbutton);
 utf8:= getutf8;
 try
  with editform do begin
   caption:= getcaption;
   grid.rowcount:= strings.Count;
   for int1:= 0 to strings.Count - 1 do begin
    if utf8 then begin
     textedit[int1]:= utf8tostring(strings[int1]);
    end
    else begin
     textedit[int1]:= strings[int1];
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
 if tstrings(getordvalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
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
  tstrings(getordvalue).clear;
 end;
 inherited;
end;

function ttextstringspropertyeditor.getcaption: msestring;
begin
 result:= 'Texteditor';
end;

{ tdatalistpropertyeditor }

procedure tdatalistpropertyeditor.checkformkind;
var
 datalist1: tdatalist;
begin
 formkind:= lfk_none;
 datalist1:= tdatalist(getordvalue);
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
   end;
  end;
 end;
end;

procedure tdatalistpropertyeditor.edit;
var
 editform: tcustommseform;
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
  else begin
   editform:= nil;
  end;
 end;
 try
  if editform <> nil then begin
   case formkind of
    lfk_msestring: begin
     tstringlisteditor(editform).valueedit.datalist.assign(tmsestringdatalist(getordvalue));
    end;
    lfk_real: begin
     treallisteditor(editform).valueedit.griddata.assign(trealdatalist(getordvalue));
    end;
    lfk_integer: begin
     tintegerlisteditor(editform).valueedit.griddata.assign(tintegerdatalist(getordvalue));
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
 datalist1:= tdatalist(getordvalue);
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
    datalist1:= tdatalist(getordvalue(int1));
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
    end;
    modified;
   end;
  except
   application.handleexception(nil);
   amodalresult:= mr_none;
  end;
 end;
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
    tmsestringdatalist(getordvalue(int1)).assign(
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
   valueedit.datalist.assign(tmsestringdatalist(getordvalue));
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tmsestringdatalistpropertyeditor.getvalue: msestring;
begin
 if tmsestringdatalist(getordvalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
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
    list:= tdoublemsestringdatalist.create;
    try
     list.assign(texta.griddata);
     list.assignb(textb.griddata);
     tdoublemsestringdatalist(getordvalue).assign(list);
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
   texta.assigncol(tmsestringdatalist(getordvalue));
   tdoublemsestringdatalist(getordvalue).assigntob(textb.griddata);
   show(true,nil);
  end;
 finally
  editform.Free;
 end;
end;

function tdoublemsestringdatalistpropertyeditor.getvalue: msestring;
begin
 if tdoublemsestringdatalist(getordvalue).count = 0 then begin
  result:= '<empty>';
 end
 else begin
  result:= inherited getvalue;
 end;
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

initialization
// apropertyeditors:= tpropertyeditors.Create;
finalization
 freeandnil(apropertyeditors);
end.
