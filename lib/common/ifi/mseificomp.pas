{ MSEgui Copyright (c) 2009-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   experimental user <-> business logic connection components.
   Warning: works with RTTI and is therefore slow.
}
{$ifdef FPC}
 {$if defined(FPC) and (fpc_fullversion >= 020501)}
  {$define mse_fpc_2_6} 
 {$ifend}
 {$ifdef mse_fpc_2_6}
  {$define mse_hasvtunicodestring}
 {$endif}
{$endif}
unit mseificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mclasses,mseclasses,{msegui,}mseifiglob,mseglob,typinfo,msestrings,
 msetypes,mseinterfaces,msetimer,
 mseificompglob,msearrayprops,msedatalist,msestat,msestatfile,mseapplication,
 mseeditglob;

type
 tifilinkcomp = class;
 tifivaluelinkcomp = class;
 tcustomificlientcontroller = class;

 ifieventty = procedure(const sender: tcustomificlientcontroller) of object;
 ificlienteventty = procedure(const sender: tcustomificlientcontroller;
                              const aclient: iificlient) of object;
 ificlientstateeventty = procedure(const sender: tcustomificlientcontroller;
                           const aclient: iificlient;
                           const astate: ifiwidgetstatesty;
                           const achangedstate: ifiwidgetstatesty) of object;
 ificlientmodalresulteventty = 
             procedure(const sender: tcustomificlientcontroller;
                       const aclient: iificlient; 
                       const amodalresult: modalresultty) of object;
 ificlientclosequeryeventty = 
             procedure(const sender: tcustomificlientcontroller;
                       const aclient: iificlient; 
                       var amodalresult: modalresultty) of object;

 ifivaluelinkstatety = (ivs_linking,ivs_valuesetting,ivs_loadedproc);
 ifivaluelinkstatesty = set of ifivaluelinkstatety;
 valueclientoptionty = (vco_datalist,vco_nosync,vco_novaluetoclient,
                                                  vco_readonly,vco_notnull);
 valueclientoptionsty = set of valueclientoptionty;
   
 tcustomificlientcontroller = class(tlinkedpersistent,iifiserver,istatfile)
  private
   fonclientvaluechanged: ificlienteventty;
   fonclientexecute: ificlienteventty;
   fonclientstatechanged: ificlientstateeventty;
   fonclientmodalresult: ificlientmodalresulteventty;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatpriority: integer;
   fonchangebefore: ifieventty;
   fonchangeafter: ifieventty;
   fonclientclosequery: ificlientclosequeryeventty;
   function getintegerpro(const aname: string): integer;
   procedure setintegerpro(const aname: string; const avalue: integer);
   function getmsestringpro(const aname: string): msestring;
   procedure setmsestringpro(const aname: string; const avalue: msestring);
   function getbooleanpro(const aname: string): boolean;
   procedure setbooleanpro(const aname: string; const avalue: boolean);
   function getrealtypro(const aname: string): realty;
   procedure setrealtypro(const aname: string; const avalue: realty);
   function getdatetimepro(const aname: string): tdatetime;
   procedure setdatetimepro(const aname: string; const avalue: tdatetime);
   procedure setstatfile(const avalue: tstatfile);
  protected
   fowner: tmsecomponent;
   fkind: ttypekind;
   fstate: ifivaluelinkstatesty;
   foptionsvalue: valueclientoptionsty;
   fwidgetstate: ifiwidgetstatesty;
   fwidgetstatebefore: ifiwidgetstatesty;
   fchangedclient: pointer;
   
   fapropname: string;
   fapropkind: ttypekind;
   fapropvalue: pointer;

   procedure dogetprop(const alink: pointer);
   procedure getprop(const aname: string; const akind: ttypekind;
                                                const avaluepo: pointer);
   procedure dosetprop(const alink: pointer);
   procedure setprop(const aname: string; const akind: ttypekind;
                                                const avaluepo: pointer);
   procedure finalizelink(const alink: pointer);
   procedure finalizelinks;
   procedure loaded; virtual;
   function errorname(const ainstance: tobject): string;
   procedure interfaceerror;
   function getifilinkkind: ptypeinfo; virtual;
   function checkcomponent(const aintf: iifilink): pointer; virtual;
              //returns interface info, exception if link invalid
   procedure valuestootherclient(const alink: pointer); 
   procedure valuestoclient(const alink: pointer); virtual; 
   procedure clienttovalues(const alink: pointer); virtual;
   procedure change(const alink: iificlient = nil);
//   procedure change();
   procedure linkset(const alink: iificlient); virtual;
   
   function setmsestringval(const alink: iificlient; const aname: string;
                                 const avalue: msestring): boolean;
                                    //true if found
   function getmsestringval(const alink: iificlient; const aname: string;
                                 var avalue: msestring): boolean;
                                    //true if found
   function setintegerval(const alink: iificlient; const aname: string;
                                 const avalue: integer): boolean;
                                    //true if found
   function getintegerval(const alink: iificlient; const aname: string;
                                 var avalue: integer): boolean;
                                    //true if found
   function setint64val(const alink: iificlient; const aname: string;
                                 const avalue: int64): boolean;
                                    //true if found
   function getint64val(const alink: iificlient; const aname: string;
                                 var avalue: int64): boolean;
                                    //true if found
   function setpointerval(const alink: iificlient; const aname: string;
                                 const avalue: pointer): boolean;
                                    //true if found
   function getpointerval(const alink: iificlient; const aname: string;
                                 var avalue: pointer): boolean;
                                    //true if found
   function setbooleanval(const alink: iificlient; const aname: string;
                                 const avalue: boolean): boolean;
                                    //true if found
   function getbooleanval(const alink: iificlient; const aname: string;
                                 var avalue: boolean): boolean;
                                    //true if found
   function setrealtyval(const alink: iificlient; const aname: string;
                                 const avalue: realty): boolean;
                                    //true if found
   function getrealtyval(const alink: iificlient; const aname: string;
                                 var avalue: realty): boolean;
                                    //true if found
   function setdatetimeval(const alink: iificlient; const aname: string;
                                 const avalue: tdatetime): boolean;
                                    //true if found
   function getdatetimeval(const alink: iificlient; const aname: string;
                                 var avalue: tdatetime): boolean;
                                    //true if found
   procedure distribute(const sender: iificlient;
                            const local: boolean; const exec: boolean); virtual;
    //iifiserver
   procedure execute(const sender: iificlient); virtual;
   procedure valuechanged(const sender: iificlient);
   procedure statechanged(const sender: iificlient;
                            const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(const sender: iificlient; var avalue;
                     var accept: boolean; const arow: integer); virtual;
   procedure dataentered(const sender: iificlient; const arow: integer); virtual;
   procedure closequery(const sender: iificlient; 
                             var amodalresult: modalresultty); virtual;
   procedure sendmodalresult(const sender: iificlient; 
                             const amodalresult: modalresultty); virtual;
   procedure updateoptionsedit(var avalue: optionseditty); virtual;
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
  public
   constructor create(const aowner: tmsecomponent; const akind: ttypekind);
                              reintroduce; overload;
   constructor create(const aowner: tmsecomponent); overload; virtual;
   function canconnect(const acomponent: tcomponent): boolean; virtual;

   property msestringprop[const aname: string]: msestring read getmsestringpro 
                                                       write setmsestringpro;
   property integerprop[const aname: string]: integer read getintegerpro 
                                                       write setintegerpro;
   property booleanprop[const aname: string]: boolean read getbooleanpro 
                                                       write setbooleanpro;
   property realtyprop[const aname: string]: realty read getrealtypro
                                                       write setrealtypro;
   property datetimeprop[const aname: string]: tdatetime read getdatetimepro 
                                                       write setdatetimepro;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;
   property onchangebefore: ifieventty read fonchangebefore 
                                                     write fonchangebefore;
                  //for data change and execute
   property onchangeafter: ifieventty read fonchangeafter write fonchangeafter;
                  //for data change and execute
   property onclientvaluechanged: ificlienteventty read fonclientvaluechanged 
                                                    write fonclientvaluechanged;
   property onclientstatechanged: ificlientstateeventty 
                     read fonclientstatechanged write fonclientstatechanged;
   property onclientclosequery: ificlientclosequeryeventty 
                     read fonclientclosequery write fonclientclosequery;
   property onclientmodalresult: ificlientmodalresulteventty 
                     read fonclientmodalresult write fonclientmodalresult;
   property onclientexecute: ificlienteventty read fonclientexecute 
                     write fonclientexecute;
 end;

 customificlientcontrollerclassty = class of tcustomificlientcontroller;

 tificlientcontroller = class(tcustomificlientcontroller)
  published
   property statfile;
   property statvarname;
   property statpriority;
   property onchangebefore;
   property onchangeafter;
   property onclientvaluechanged;
   property onclientstatechanged;
   property onclientclosequery;
   property onclientmodalresult;
   property onclientexecute;
 end;
                             
 texecclientcontroller = class(tificlientcontroller)
  private
  protected
   function getifilinkkind: ptypeinfo; override;
   procedure valuestoclient(const alink: pointer); override;
//   procedure execute(const sender: iificlient); overload; override;
   procedure linkset(const alink: iificlient); override;
  public
   function canconnect(const acomponent: tcomponent): boolean; override;
   procedure execute; reintroduce;
  published
   property optionsvalue: valueclientoptionsty read foptionsvalue
                                           write foptionsvalue default [];
 end;

 tformclientcontroller = class(tificlientcontroller)
  private
   procedure setmodalresult(const avalue: modalresultty);
  protected
   fmodalresult: modalresultty;
   function getifilinkkind: ptypeinfo; override;
//   procedure execute(const sender: iificlient); overload; override;
   procedure linkset(const alink: iificlient) override;
   procedure valuestoclient(const alink: pointer) override;
   procedure sendmodalresult(const sender: iificlient; 
                             const amodalresult: modalresultty) override;
  public
   property modalresult: modalresultty read fmodalresult write setmodalresult;
 end;

 valarsetterty = procedure(const alink: pointer; var handled: boolean) of object; 
 valargetterty = procedure(const alink: pointer; var handled: boolean) of object;

 itemsetterty = procedure(const alink: pointer; var handled: boolean) of object; 
 itemgetterty = procedure(const alink: pointer; var handled: boolean) of object;

 tifidatasource = class;
 ififieldnamety = type ansistring;       //type for property editor
 ifisourcefieldnamety = type ansistring; //type for property editor
 
 iififieldinfo = interface(inullinterface)[miid_iififieldinfo]
  procedure getfieldinfo(const apropname: ififieldnamety; 
                         var adatasource: tifidatasource;
                         var atypes: listdatatypesty);
 end;

 iifidatasourceclient = interface(iobjectlink)
  function getobjectlinker: tobjectlinker;
  procedure bindingchanged;
  function ifigriddata: tdatalist;
  function ififieldname: string;
 end;
 
 indexeventty = procedure(const sender: tcustomificlientcontroller;
                    const aclient: iificlient; const aindex: integer) of object;

 setbooleanclienteventty =
                 procedure(const sender: tcustomificlientcontroller;
                     const aclient: iificlient; var avalue: boolean;
                          var accept: boolean; const aindex: integer) of object;
 setstringclienteventty = 
                 procedure(const sender: tcustomificlientcontroller;
                  const aclient: iificlient; var avalue: msestring;
                          var accept: boolean; const aindex: integer) of object;
 setansistringclienteventty = procedure(
                          const sender: tcustomificlientcontroller;
                          var avalue: ansistring;
                          var accept: boolean; const aindex: integer) of object;
 setintegerclienteventty = 
                 procedure(const sender: tobject; const aclient: iificlient;
                          var avalue: integer; 
                          var accept: boolean; const aindex: integer) of object; 
                          //equal parameters as setcoloreventty for tcoloredit!
 setint64clienteventty = 
                 procedure(const sender: tcustomificlientcontroller;
                          const aclient: iificlient; var avalue: int64;
                          var accept: boolean; const aindex: integer) of object; 
 setpointerclienteventty = 
                 procedure(const sender: tcustomificlientcontroller;
                          const aclient: iificlient; var avalue: pointer;
                          var accept: boolean; const aindex: integer) of object; 
 setrealclienteventty = 
                 procedure(const sender: tcustomificlientcontroller;
                          const aclient: iificlient; var avalue: realty;
                          var accept: boolean; const aindex: integer) of object;
 setdatetimeclienteventty = 
                 procedure(const sender: tcustomificlientcontroller;
                          const aclient: iificlient; var avalue: tdatetime;
                          var accept: boolean; const aindex: integer) of object;

 tvalueclientcontroller = class(tificlientcontroller,
                                         iififieldinfo,iifidatasourceclient)
  private
//   fvalarpo: pointer;
   fitempo: pointer;
//   fitemindex: integer;
   fonclientdataentered: indexeventty;
   fdatasource: tifidatasource;
   ffieldname: ififieldnamety;
   procedure setoptionsvalue(const avalue: valueclientoptionsty);
   procedure setdatasource(const avalue: tifidatasource);
   procedure setfieldname(const avalue: ififieldnamety);
   procedure linkdatalist1(const alink: pointer);
   procedure updatereadonlystate1(const alink: pointer);
  protected
   fdatalist: tdatalist;
   procedure updateoptionsedit(var avalue: optionseditty); override;
   procedure linkset(const alink: iificlient); override;

   function getifilinkkind: ptypeinfo; override;
   procedure setvalue(const sender: iificlient; var avalue;
                          var accept: boolean; const arow: integer); override;
   procedure dataentered(const sender: iificlient;
                                              const arow: integer); override;
   procedure loaded; override;
   procedure statreadvalue(const reader: tstatreader); virtual;
   procedure statwritevalue(const reader: tstatwriter); virtual;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;

   procedure linkdatalist;
   procedure updatereadonlystate;
   procedure optionsvaluechanged; virtual;
   function createdatalist: tdatalist; virtual; abstract;
   function getlistdatatypes: listdatatypesty; virtual; abstract;
   procedure statreadlist(const alink: pointer);
   procedure statwritelist(const alink: pointer; var handled: boolean);
    //iifidatasourceclient
   procedure bindingchanged;
   function ifigriddata: tdatalist;
   function ififieldname: string;
    //iififieldinfo
   procedure getfieldinfo(const apropname: ififieldnamety; 
                         var adatasource: tifidatasource;
                         var atypes: listdatatypesty);
  public
   destructor destroy; override;
   function canconnect(const acomponent: tcomponent): boolean; override;
   property datalist: tdatalist read fdatalist;
  published
   property onclientdataentered: indexeventty read fonclientdataentered
                                  write fonclientdataentered;
   property optionsvalue: valueclientoptionsty read foptionsvalue
                                           write setoptionsvalue default [];
   property datasource: tifidatasource read fdatasource write setdatasource;
   property fieldname: ififieldnamety read ffieldname write setfieldname;
 end;
 
 tifimsestringdatalist = class;
  
 tstringclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: msestring;
   fvaluedefault: msestring;
   fonclientsetvalue: setstringclienteventty;
   procedure setvalue1(const avalue: msestring);
   function getgriddata: tifimsestringdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
           var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   function getlistdatatypes: listdatatypesty; override;
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifimsestringdatalist read getgriddata;
//   property gridvalues: msestringarty read getgridvalues write setgridvalues;
//   property gridvalue[const index: integer]: msestring read getgridvalue 
//                                                             write setgridvalue;
  published
   property value: msestring read fvalue write setvalue1;
   property valuedefault: msestring read fvaluedefault write fvaluedefault;
   property onclientsetvalue: setstringclienteventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tifidropdowncol = class(tmsestringdatalist,iififieldinfo,iifidatasourceclient)
  private
   fdatasource: tifidatasource;
   fdatafield: ififieldnamety;
   procedure setdatasource(const avalue: tifidatasource);
   procedure setdatafield(const avalue: ififieldnamety);
  protected
    //iifidatasourceclient
   procedure bindingchanged;
   function ifigriddata: tdatalist;
   function ififieldname: string;
    //iififieldinfo
   procedure getfieldinfo(const apropname: ififieldnamety; 
                         var adatasource: tifidatasource;
                         var atypes: listdatatypesty);
  published
   property datasource: tifidatasource read fdatasource write setdatasource;
   property datafield: ififieldnamety read fdatafield write setdatafield;
 end;

 tifidropdownlistcontroller = class;
 
 tifidropdowncols = class(townedpersistentarrayprop)
  private
   function getitems(const index: integer): tifidropdowncol;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure colchanged(const sender: tobject);
   procedure dochange(const index: integer); override;
  public
   class function getitemclasstype: persistentclassty; override;
   constructor create(const aowner: tifidropdownlistcontroller); reintroduce;
   property items[const index: integer]: tifidropdowncol read getitems; default;
 end;

 iifidropdownlistdatalink = interface(iifidatalink)
  procedure ifidropdownlistchanged(const acols: tifidropdowncols);
 end;
  
 tifidropdownlistcontroller = class(teventpersistent)
  private
   fcols: tifidropdowncols;
   fowner: tvalueclientcontroller;
   procedure setcols(const avalue: tifidropdowncols);
   procedure valuestoclient(const alink: pointer);
  public
   constructor create(const aowner: tvalueclientcontroller); reintroduce;
   destructor destroy; override;
  published
   property cols: tifidropdowncols read fcols write setcols;
 end;
 
 tdropdownlistclientcontroller = class(tstringclientcontroller)
  private
   fdropdown: tifidropdownlistcontroller;
   procedure setdropdown(const avalue: tifidropdownlistcontroller);
  protected
   function getifilinkkind: ptypeinfo; override;
   procedure valuestoclient(const alink: pointer); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   destructor destroy; override;
  published
   property dropdown: tifidropdownlistcontroller read fdropdown write setdropdown;
 end;
 
 tifiintegerdatalist = class;

 tintegerclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: integer;
   fvaluedefault: integer;
   fvaluemin: integer;
   fvaluemax: integer;
   fonclientsetvalue: setintegerclienteventty;
   procedure setvalue1(const avalue: integer);
   procedure setvaluemin(const avalue: integer);
   procedure setvaluemax(const avalue: integer);
   function getgriddata: tifiintegerdatalist;
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  protected
   procedure defineproperties(filer: tfiler) override;
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   function getlistdatatypes: listdatatypesty; override;   
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifiintegerdatalist read getgriddata;
  published
   property value: integer read fvalue write setvalue1 default 0;
   property valuedefault: integer read fvaluedefault 
                                        write fvaluedefault default 0;
   property valuemin: integer read fvaluemin write setvaluemin default 0;
   property valuemax: integer read fvaluemax write setvaluemax default maxint;
   property onclientsetvalue: setintegerclienteventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tifiint64datalist = class;

 tint64clientcontroller = class(tvalueclientcontroller)
  private
   fvalue: int64;
   fvaluedefault: int64;
   fvaluemin: int64;
   fvaluemax: int64;
   fonclientsetvalue: setint64clienteventty;
   procedure setvalue1(const avalue: int64);
   procedure setvaluemin(const avalue: int64);
   procedure setvaluemax(const avalue: int64);
   function getgriddata: tifiint64datalist;
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  protected
   procedure defineproperties(filer: tfiler) override;
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   function getlistdatatypes: listdatatypesty; override;   
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifiint64datalist read getgriddata;
  published
   property value: int64 read fvalue write setvalue1 default 0;
   property valuedefault: int64 read fvaluedefault 
                                        write fvaluedefault default 0;
   property valuemin: int64 read fvaluemin write setvaluemin default 0;
   property valuemax: int64 read fvaluemax write setvaluemax default maxint;
   property onclientsetvalue: setint64clienteventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tifipointerdatalist = class;
 
 tpointerclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: pointer;
   fonclientsetvalue: setpointerclienteventty;
   procedure setvalue1(const avalue: pointer);
   function getgriddata: tifipointerdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   function getlistdatatypes: listdatatypesty; override;   
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifipointerdatalist read getgriddata;
   property value: pointer read fvalue write setvalue1 default nil;
  published
   property onclientsetvalue: setpointerclienteventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tenumclientcontroller = class(tintegerclientcontroller)
  private
   fdropdown: tifidropdownlistcontroller;
   procedure setdropdown(const avalue: tifidropdownlistcontroller);
  protected
   function getifilinkkind: ptypeinfo; override;
   procedure valuestoclient(const alink: pointer); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   destructor destroy; override;
  published
   property dropdown: tifidropdownlistcontroller read fdropdown write setdropdown;
   property value default -1;
   property valuedefault default -1;
   property valuemin default -1;
 end;

 tifibooleandatalist = class;
  
 tbooleanclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: longbool;
   fvaluedefault: longbool;
   fonclientsetvalue: setbooleanclienteventty;
   function getvalue: boolean;
   procedure setvalue1(const avalue: boolean);
   function getvaluedefault: boolean;
   procedure setvaluedefault(const avalue: boolean);
//   function getgridvalues: longboolarty;
//   procedure setgridvalues(const avalue: longboolarty);
//   function getgridvalue(const index: integer): boolean;
//   procedure setgridvalue(const index: integer; const avalue: boolean);
   function getgriddata: tifibooleandatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
            var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   function getlistdatatypes: listdatatypesty; override;
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifibooleandatalist read getgriddata;
//   property gridvalues: longboolarty read getgridvalues write setgridvalues;
//   property gridvalue[const index: integer]: boolean read getgridvalue 
//                                                             write setgridvalue;
  published
   property value: boolean read getvalue write setvalue1 default false;
   property valuedefault: boolean read getvaluedefault write setvaluedefault 
                                                                default false;
   property onclientsetvalue: setbooleanclienteventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tifirealdatalist = class;
 
 trealclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: realty;
   fvaluedefault: realty;
   fvaluemin: realty;
   fvaluemax: realty;
   fonclientsetvalue: setrealclienteventty;
   procedure setvalue1(const avalue: realty);
   procedure setvaluemin(const avalue: realty);
   procedure setvaluemax(const avalue: realty);
   procedure readvalue(reader: treader);
   procedure readmin1(reader: treader);
   procedure readmax1(reader: treader);
   procedure readvaluedefault(reader: treader);
   function getgriddata: tifirealdatalist;
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   procedure defineproperties(filer: tfiler); override;
   function getlistdatatypes: listdatatypesty; override;
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifirealdatalist read getgriddata;
//   property gridvalues: realarty read getgridvalues write setgridvalues;
//   property gridvalue[const index: integer]: real read getgridvalue 
//                                                             write setgridvalue;
  published
   property value: realty read fvalue write setvalue1 {stored false};
   property valuedefault: realty read fvaluedefault
                                          write fvaluedefault {stored false};
   property valuemin: realty read fvaluemin write setvaluemin {stored false};
   property valuemax: realty read fvaluemax write setvaluemax {stored false};
   property onclientsetvalue: setrealclienteventty 
                       read fonclientsetvalue write fonclientsetvalue;
 end;

 tifidatetimedatalist = class;

 tdatetimeclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: tdatetime;
   fvaluedefault: tdatetime;
   fvaluemin: tdatetime;
   fvaluemax: tdatetime;
   fonclientsetvalue: setdatetimeclienteventty;
   procedure setvalue1(const avalue: tdatetime);
   procedure setvaluemin(const avalue: tdatetime);
   procedure setvaluemax(const avalue: tdatetime);
   procedure readvalue(reader: treader);
   procedure readmin1(reader: treader);
   procedure readmax1(reader: treader);
   procedure readvaluedefault(reader: treader);
   function getgriddata: tifidatetimedatalist;
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
              var avalue; var accept: boolean; const arow: integer); override;
   function createdatalist: tdatalist; override;
   procedure defineproperties(filer: tfiler); override;
   function getlistdatatypes: listdatatypesty; override;
    //istatfile
   procedure statreadvalue(const reader: tstatreader); override;
   procedure statwritevalue(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tifidatetimedatalist read getgriddata;
  published
   property value: tdatetime read fvalue write setvalue1 {stored false};
   property valuedefault: tdatetime read fvaluedefault 
                                             write fvaluedefault {stored false};
   property valuemin: tdatetime read fvaluemin write setvaluemin {stored false};
   property valuemax: tdatetime read fvaluemax write setvaluemax {stored false};
   property onclientsetvalue: setdatetimeclienteventty 
                       read fonclientsetvalue write fonclientsetvalue;
 end;
 
 ificelleventty = procedure(const sender: tobject; 
                           var info: ificelleventinfoty) of object;
 ifibeforeblockeventty = procedure(const sender: tobject;
               var aindex,acount: integer; const userinput: boolean) of object;
 ifiafterblockeventty = procedure(const sender: tobject;
             const aindex,acount: integer; const userinput: boolean) of object;

 tificolitem = class(tmsecomponentlinkitem)
  private
   function getlink: tifivaluelinkcomp;
   procedure setlink(const avalue: tifivaluelinkcomp);
  published
   property link: tifivaluelinkcomp read getlink write setlink;
 end;
 
 tifilinkcomparrayprop = class(tmsecomponentlinkarrayprop)
  private
   function getitems(const index: integer): tificolitem;
  public 
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tificolitem read getitems; default;
 end;

 tgridclientcontroller = class;

 trowstatehandler = class(tdatalist,iifidatalink)
  private
   fifilink: tifivaluelinkcomp;
   flistlink: listlinkinfoty;
   findexpar: integer;
   procedure setifilink(const avalue: tifivaluelinkcomp);
  protected
   fowner: tgridclientcontroller;
   procedure updateclient(const alink: pointer); virtual; abstract;
   procedure updateremote(const sender: tcustomrowstatelist; 
                                    const aindex: integer); virtual; abstract;
   procedure itemchanged(const sender: tcustomrowstatelist;
                                            const aindex: integer);
    //iifidatalink
   procedure setifiserverintf(const aintf: iifiserver);
   function getdefaultifilink: iificlient; virtual;
   procedure ifisetvalue(var avalue; var accept: boolean);
   function getifilinkkind: ptypeinfo;
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist; reintroduce; overload;
   function getvalueprop: ppropinfo;
   procedure updatereadonlystate;
   property ifilink: tifivaluelinkcomp read fifilink write setifilink;
  public
   constructor create(const aowner: tgridclientcontroller); reintroduce;
   destructor destroy; override;
   procedure listdestroyed(const sender: tdatalist); override;
   procedure sourcechange(const sender: tdatalist;
                                         const aindex: integer); override;
   function canlink(const asource: tdatalist;
                                     const atag: integer): boolean; override;
 end;

 tifiintegerlinkcomp = class;

 trowstateintegerhandler = class(trowstatehandler)
  private
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink(const avalue: tifiintegerlinkcomp);
  public
   property ifilink: tifiintegerlinkcomp read getifilink write setifilink;
 end;

 tifibooleanlinkcomp = class;
 
 trowstatebooleanhandler = class(trowstatehandler)
  private
   function getifilink: tifibooleanlinkcomp;
   procedure setifilink(const avalue: tifibooleanlinkcomp);
  public
   property ifilink: tifibooleanlinkcomp read getifilink write setifilink;
 end;
  
 trowstatecolorhandler = class(trowstateintegerhandler)
  protected
   procedure updateclient(const alink: pointer); override;
   procedure updateremote(const sender: tcustomrowstatelist; 
                                    const aindex: integer); override;
 end;

 trowstatefonthandler = class(trowstateintegerhandler)
  protected
   procedure updateclient(const alink: pointer); override;
   procedure updateremote(const sender: tcustomrowstatelist; 
                                    const aindex: integer); override;
 end;

 trowstatefoldlevelhandler = class(trowstateintegerhandler)
  protected
   procedure updateclient(const alink: pointer); override;
   procedure updateremote(const sender: tcustomrowstatelist; 
                                    const aindex: integer); override;
 end;

 trowstatehiddenhandler = class(trowstatebooleanhandler)
  protected
   procedure updateclient(const alink: pointer); override;
   procedure updateremote(const sender: tcustomrowstatelist;
                                    const aindex: integer); override;
 end;
 
 trowstatefoldissumhandler = class(trowstatebooleanhandler)
  protected
   procedure updateclient(const alink: pointer); override;
   procedure updateremote(const sender: tcustomrowstatelist; 
                                    const aindex: integer); override;
 end;
 
 gridclientstatety = (gcs_itemchangelock);
 gridclientstatesty = set of gridclientstatety;
  
 tgridclientcontroller = class(tificlientcontroller,idatalistclient)
  private
   frowcount: integer;
   foncellevent: ificelleventty;
   fdatacols: tifilinkcomparrayprop;
   fcheckautoappend: boolean;
   fitempo: pointer;
   frowstatecolor: trowstatecolorhandler;
   frowstatefont: trowstatefonthandler;
   frowstatefoldlevel: trowstatefoldlevelhandler;
   frowstatehidden: trowstatehiddenhandler;
   frowstatefoldissum: trowstatefoldissumhandler;
   fonrowsinserting: ifibeforeblockeventty;
   fonrowsinserted: ifiafterblockeventty;
   fonrowsdeleting: ifibeforeblockeventty;
   fonrowsdeleted: ifiafterblockeventty;
   procedure setrowcount(const avalue: integer);
   procedure setdatacols(const avalue: tifilinkcomparrayprop);
   function getrowstate: tcustomrowstatelist;
   procedure statreadrowstate(const alink: pointer);
   procedure statwriterowstate(const alink: pointer; var handled: boolean);
   function getrowstate_color: tifiintegerlinkcomp;
   procedure setrowstate_color(const avalue: tifiintegerlinkcomp);
   function getrowstate_font: tifiintegerlinkcomp;
   procedure setrowstate_font(const avalue: tifiintegerlinkcomp);
   function getrowstate_foldlevel: tifiintegerlinkcomp;
   procedure setrowstate_foldlevel(const avalue: tifiintegerlinkcomp);
   function getrowstate_hidden: tifibooleanlinkcomp;
   procedure setrowstate_hidden(const avalue: tifibooleanlinkcomp);
   function getrowstate_foldissum: tifibooleanlinkcomp;
   procedure setrowstate_foldissum(const avalue: tifibooleanlinkcomp);
  protected
   fgridstate: gridclientstatesty;
   procedure itemchanged(const sender: tdatalist; const aindex: integer);
   function getifilinkkind: ptypeinfo; override;
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure itemappendrow(const alink: pointer);
   procedure getrowstate1(const alink: pointer; var handled: boolean);
   procedure canclose1(const alink: pointer; var handled: boolean);

   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   function checkcomponent(const aintf: iifilink): pointer; override;
  public
   constructor create(const aowner: tmsecomponent); override;
   destructor destroy; override;
   procedure docellevent(var info: ificelleventinfoty);
   procedure dorowsinserting(var index,count: integer;
                                               const userinput: boolean);
   procedure dorowsinserted(const index,count: integer;
                                               const userinput: boolean);
   procedure dorowsdeleting(var index,count: integer;
                                               const userinput: boolean);
   procedure dorowsdeleted(const index,count: integer;
                                               const userinput: boolean);
   procedure appendrow(const avalues: array of const;
                         const checkautoappend: boolean = false);
   function canclose: boolean;
   function rowempty(const arow: integer): boolean;
   property rowstate: tcustomrowstatelist read getrowstate;
  published
   property rowcount: integer read frowcount write setrowcount default 0;
   property oncellevent: ificelleventty read foncellevent write foncellevent;
   property onrowsinserting: ifibeforeblockeventty read fonrowsinserting
              write fonrowsinserting;
   property onrowsinserted: ifiafterblockeventty read fonrowsinserted
              write fonrowsinserted;
   property onrowsdeleting: ifibeforeblockeventty read fonrowsdeleting
              write fonrowsdeleting;
   property onrowsdeleted: ifiafterblockeventty read fonrowsdeleted
              write fonrowsdeleted;
//  property onclientcellevent: celleventty read fclientcellevent 
//                                                 write fclientcellevent;
   property datacols: tifilinkcomparrayprop read fdatacols write setdatacols;
//   property rowstate_font: tintegerlinkcomp read frowstate_font
//                                                    write setrowstate_font;
   property rowstate_color: tifiintegerlinkcomp read getrowstate_color 
                                                    write setrowstate_color;
   property rowstate_font: tifiintegerlinkcomp read getrowstate_font 
                                                    write setrowstate_font;
   property rowstate_foldlevel: tifiintegerlinkcomp read getrowstate_foldlevel 
                                                    write setrowstate_foldlevel;
   property rowstate_hidden: tifibooleanlinkcomp read getrowstate_hidden 
                                                    write setrowstate_hidden;
   property rowstate_foldissum: tifibooleanlinkcomp read getrowstate_foldissum 
                                                    write setrowstate_foldissum;
 end;

 tifilinkcomp = class(tmsecomponent)
  private
   fcontroller: tcustomificlientcontroller;
  protected
   procedure setcontroller(const avalue: tcustomificlientcontroller);
   function getcontrollerclass: customificlientcontrollerclassty; virtual;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property c: tcustomificlientcontroller read fcontroller 
                                                         write setcontroller;
   property controller: tcustomificlientcontroller read fcontroller 
                                                         write setcontroller;
  published
 end;
 
 tifivaluelinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tvalueclientcontroller;
  public
   property c: tvalueclientcontroller read getcontroller;
   property controller: tvalueclientcontroller read getcontroller;
 end;
 
 tifistringlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tstringclientcontroller;
   procedure setcontroller(const avalue: tstringclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tstringclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tstringclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifidropdownlistlinkcomp = class(tifistringlinkcomp)
  private
   function getcontroller: tdropdownlistclientcontroller;
   procedure setcontroller(const avalue: tdropdownlistclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tdropdownlistclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tdropdownlistclientcontroller read getcontroller
                                                         write setcontroller;
 end;
 
 tifiintegerlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tintegerclientcontroller;
   procedure setcontroller(const avalue: tintegerclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tintegerclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tintegerclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifiint64linkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tint64clientcontroller;
   procedure setcontroller(const avalue: tint64clientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tint64clientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tint64clientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifipointerlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tpointerclientcontroller;
   procedure setcontroller(const avalue: tpointerclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tpointerclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tpointerclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifienumlinkcomp = class(tifiintegerlinkcomp)
  private
   function getcontroller: tenumclientcontroller;
   procedure setcontroller(const avalue: tenumclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tenumclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tenumclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifibooleanlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tbooleanclientcontroller;
   procedure setcontroller(const avalue: tbooleanclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tbooleanclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tbooleanclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifireallinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: trealclientcontroller;
   procedure setcontroller(const avalue: trealclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: trealclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: trealclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifidatetimelinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tdatetimeclientcontroller;
   procedure setcontroller(const avalue: tdatetimeclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tdatetimeclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tdatetimeclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifiactionlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: texecclientcontroller;
   procedure setcontroller(const avalue: texecclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: texecclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: texecclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tififormlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tformclientcontroller;
   procedure setcontroller(const avalue: tformclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tformclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tformclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifigridlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tgridclientcontroller;
   procedure setcontroller(const avalue: tgridclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: tgridclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: tgridclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 iififieldsource = interface(inullinterface)[miid_iififieldsource]
  function getfieldnames(const atypes: listdatatypesty): msestringarty;
 end;

 iififieldlinksource = interface(inullinterface)[miid_iififieldlinksource]
  function getfieldnames(const apropname: ifisourcefieldnamety): msestringarty;
  procedure setdesignsourcefieldname(const aname: ifisourcefieldnamety);
 end;
  
 tififield = class(tvirtualpersistent)
  private
   ffieldname: ansistring;
   fdatatype: listdatatypety;
  public
  published
   property fieldname: ansistring read ffieldname write ffieldname;
   property datatype: listdatatypety read fdatatype write fdatatype;
 end;
 ififieldclassty = class of tififield;
 
 tififields = class(tpersistentarrayprop,iififieldsource)
  protected
   function getififieldclass: ififieldclassty; virtual;
  public
   constructor create;
//   function destdatalists: datalistarty;
    //iififieldsource
   class function getitemclasstype: persistentclassty; override;
   function getfieldnames(const atypes: listdatatypesty): msestringarty;
 end;

 tififieldlinks = class;
 
 tififieldlink = class(tififield,iififieldlinksource)
  private
   fsourcefieldname: ifisourcefieldnamety;
  protected
   fowner: tififieldlinks;
    //iififieldlinksource
   function getfieldnames(
                  const appropname: ifisourcefieldnamety): msestringarty;
   procedure setdesignsourcefieldname(const aname: ifisourcefieldnamety);
  {$ifndef FPC}
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
   function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  {$endif}
  public
  published
   property sourcefieldname: ifisourcefieldnamety read fsourcefieldname
                                                     write fsourcefieldname;
 end;
 ififieldlinkclassty = class of tififieldlink;
 
 tififieldlinks = class(tififields)
  protected
   function getififieldclass: ififieldlinkclassty; reintroduce; virtual;
   procedure createitem(const index: integer; var item: tpersistent); override;
   function getfieldnames(
           const adatatype: listdatatypety): msestringarty; virtual;
  public
   function sourcefieldnames: stringarty;
   function sourcefieldtype(const afieldname: string): listdatatypety virtual;
end;

 iifidataconnection = interface(inullinterface)[miid_iifidataconnection]
  procedure fetchdata(const acolnames: array of string; 
                                                  acols: array of tdatalist);
  function getfieldnames(const adatatype: listdatatypety): msestringarty;
  function getdatatype(const aname: ansistring): listdatatypety;
                           //dl_none if not found
 end;
 
//{$define usedelegation} not working in FPC 2.4
 tifidatasource = class(tactcomponent,iififieldsource)
  private
  {$ifdef usedelegation}
   ffieldsourceintf: iififieldsource;
  {$endif}
   fopenafterread: boolean;

   fonbeforeopen: notifyeventty;
   fonafteropen: notifyeventty;
   findex: integer;
   fnamear: stringarty;
   flistar: datalistarty;
   ftimer: tsimpletimer;
   procedure setfields(const avalue: tififields);
  {$ifdef usedelegation}
   property fieldsurceintf: iififieldsource read ffieldsourceintf 
                                              implements iififieldsource;
         //not working in FPC 2.4
  {$endif}
   procedure getbindinginfo(const alink: pointer); 
  protected
   factive: boolean;
   frefreshing: boolean;
   ffields: tififields;
   procedure setactive(const avalue: boolean); override;
   procedure open; virtual;
   procedure afteropen;
   procedure dorefresh(const sender: tobject);
   procedure close; virtual;
   procedure loaded; override;
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure destdatalists(out names: stringarty; out lists: datalistarty);
{$ifndef usedelegation}
    //iififieldsource
   function getfieldnames(const atypes: listdatatypesty): msestringarty;
{$endif}
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure refresh(const delayus: integer = -1);
                           //-1 -> no delay, 0 -> in onidle
   procedure checkrefresh(); //makes pending delayed refresh
   property refreshing: boolean read frefreshing;
  published
   property fields: tififields read ffields write setfields;
   property active: boolean read factive write setactive default false;
   property activator;
   property onbeforeopen: notifyeventty read fonbeforeopen write fonbeforeopen;
   property onafteropen: notifyeventty read fonafteropen write fonafteropen;
 end;

 tconnectedifidatasource = class;
 tificonnectedfields = class(tififieldlinks)
  protected
   fowner: tconnectedifidatasource;
   function getfieldnames(
                     const adatatype: listdatatypety): msestringarty; override;
  public
   constructor create(const aowner: tconnectedifidatasource);
   function sourcefieldtype(const afieldname: string): listdatatypety override;
 end;
  
 tconnectedifidatasource = class(tifidatasource)
  private
   fconnection: tmsecomponent;
   procedure setconnection(const avalue: tmsecomponent);
   function getfields: tificonnectedfields;
   procedure setfields(const avalue: tificonnectedfields);
  protected
   fconnectionintf: iifidataconnection;
   function getfieldnames(const adatatype: listdatatypety): msestringarty;
   procedure open; override;
   procedure close; override;
   procedure checkconnection;
  public
   constructor create(aowner: tcomponent); override;
  published
   property connection: tmsecomponent read fconnection write setconnection;
   property fields: tificonnectedfields read getfields write setfields;
 end;

 tifiintegerdatalist = class(tintegerdatalist)
  protected
   fowner: tintegerclientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: tintegerclientcontroller); reintroduce;
 end;

 tifiint64datalist = class(tint64datalist)
  protected
   fowner: tint64clientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: tint64clientcontroller); reintroduce;
 end;

 tifipointerdatalist = class(tpointerdatalist)
  protected
   fowner: tpointerclientcontroller;
  public
   constructor create(const aowner: tpointerclientcontroller); reintroduce;
 end;

 tifibooleandatalist = class(tbooleandatalist)
  private
  protected
   fowner: tbooleanclientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: tbooleanclientcontroller); reintroduce;
 end;
   
 tifirealdatalist = class(trealdatalist)
  protected
   fowner: trealclientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: trealclientcontroller); reintroduce;
 end;

 tifidatetimedatalist = class(tdatetimedatalist)
  protected
   fowner: tdatetimeclientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: tdatetimeclientcontroller); reintroduce;
 end;

 tifimsestringdatalist = class(tmsestringdatalist)
  protected
   fowner: tstringclientcontroller;
   function getdefault: pointer; override;
  public
   constructor create(const aowner: tstringclientcontroller); reintroduce;
 end;

procedure setifilinkcomp(const alink: iifilink;
               const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
procedure setifidatasource(const aintf: iifidatasourceclient;
           const source: tifidatasource; var dest: tifidatasource);

implementation
uses
 sysutils,msereal,msestreaming;

const
 valuevarname = '_value';
 listvarname = '_list';
// arvaluevarname = 'arvalue';
 rowstatevarname = '_rowstate';

type
 tmsecomponent1 = class(tmsecomponent);
 tdatalist1 = class(tdatalist);
 
procedure setifilinkcomp(const alink: iifilink;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
var
 po1: pointer;
begin
 alink.setifiserverintf(nil);
 po1:= nil;
 if alinkcomp <> nil then begin
  po1:= alinkcomp.fcontroller.checkcomponent(alink);
 end; 
 alink.getobjectlinker.setlinkedvar(alink,alinkcomp,tmsecomponent(dest),po1);
 if dest <> nil then begin
  alink.setifiserverintf(iifiserver(dest.fcontroller));
  if (alinkcomp is tifivaluelinkcomp) and 
                        not (csloading in alinkcomp.componentstate) and
    (vco_datalist in 
             tifivaluelinkcomp(alinkcomp).controller.optionsvalue) then begin
   iifidatalink(alink).updateifigriddata(alinkcomp,
        tifivaluelinkcomp(alinkcomp).controller.fdatalist);
  end;
  dest.fcontroller.linkset(alink);
//  dest.fcontroller.change(alink);
 end;
end;

procedure setifidatasource(const aintf: iifidatasourceclient;
           const source: tifidatasource; var dest: tifidatasource);
begin
 aintf.getobjectlinker.setlinkedvar(aintf,source,tmsecomponent(dest),
                         typeinfo(iifidatasourceclient));
 aintf.bindingchanged;
end;

{ tcustomificlientcontroller}

constructor tcustomificlientcontroller.create(const aowner: tmsecomponent; 
                               const akind: ttypekind);
begin
 fowner:= aowner;
 fkind:= akind;
 inherited create;
end;

constructor tcustomificlientcontroller.create(const aowner: tmsecomponent);
begin
 create(aowner,tkunknown);
end;

procedure tcustomificlientcontroller.interfaceerror;
begin
 raise exception.create(fowner.name+' wrong iificlient interface.');
            //todo: better error message
end;

function tcustomificlientcontroller.checkcomponent(
          const aintf: iifilink): pointer;
begin
 if not isinterface(aintf.getifilinkkind,getifilinkkind) then begin
  interfaceerror;
 end;
 result:= self;
end;

{
procedure tcustomifivaluewidgetcontroller.setcomponent(const aintf: iificlient);
var
 kind1: ttypekind;
 prop1: ppropinfo;
 inst1: tobject;
begin
 if not (ivs_linking in fstate) then begin
  include(fstate,ivs_linking);
  try
   prop1:= nil;
   kind1:= tkunknown;
   if aintf <> nil then begin
    inst1:= aintf.getinstance;
    prop1:= getpropinfo(inst1,'value');
    if prop1 = nil then begin
     raise exception.create(errorname(inst1)+' has no value property.');
    end
    else begin
     kind1:= prop1^.proptype^.kind;
     if kind1 <> fkind then begin
      raise exception.create(errorname(inst1)+' wrong value data kind.');
     end;
    end;
   end;
   if fintf <> nil then begin
    fintf.setifiserverintf(nil);
   end;
   setlinkedvar(aintf,iobjectlink(fintf));
   fintf:= aintf;
   fvalueproperty:= prop1;
   if fintf <> nil then begin
    fintf.setifiserverintf(iifiserver(self));
    valuetowidget;
//    if not (csloading in fowner.componentstate) then begin
//     updatestate;
//    end;
   end;
  finally
   exclude(fstate,ivs_linking);
  end;
 end;
end;
}
procedure tcustomificlientcontroller.distribute(const sender: iificlient;
                            const local: boolean; const exec: boolean);
begin
 if not (ivs_valuesetting in fstate) and 
               not(csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   if assigned(fonchangebefore) then begin
    fonchangebefore(self);
   end;
   if local then begin
    if not (vco_novaluetoclient in foptionsvalue) then begin
     if sender <> nil then begin
      valuestoclient(pointer(sender));
     end
     else begin
      tmsecomponent1(fowner).getobjectlinker.forall(
                            {$ifdef FPC}@{$endif}valuestoclient,self);
     end;
    end;
   end
   else begin
    clienttovalues(pointer(sender));
    if foptionsvalue*[vco_nosync,vco_datalist] = [] then begin
     fchangedclient:= pointer(sender);
     tmsecomponent1(fowner).getobjectlinker.forall(
                            {$ifdef FPC}@{$endif}valuestootherclient,self);
    end;
   end;
   if assigned(fonchangeafter) then begin
    fonchangeafter(self);
   end;
   if not local then begin
    if exec then begin
     if assigned(fonclientexecute) then begin
      fonclientexecute(self,sender);
     end;
    end
    else begin
     if assigned(fonclientvaluechanged) then begin
      fonclientvaluechanged(self,sender);
     end;
    end;
   end;
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
end;

procedure tcustomificlientcontroller.change(const alink: iificlient);
begin
 distribute(alink,true,false);
end;
(*
procedure tcustomificlientcontroller.change(const alink: iificlient);
begin
 if {(fvalueproperty <> nil) and} not (ivs_valuesetting in fstate) and 
            not (csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   if assigned(fonchangebefore) then begin
    fonchangebefore(self);
   end;
   if not (vco_novaluetoclient in foptionsvalue) then begin
    if alink <> nil then begin
     valuestoclient(pointer(alink));
    end
    else begin
     tmsecomponent1(fowner).getobjectlinker.forall(
                           {$ifdef FPC}@{$endif}valuestoclient,self);
    end;
   end;
   if assigned(fonchangeafter) then begin
    fonchangeafter(self);
   end;
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
end;
*)
procedure tcustomificlientcontroller.valuechanged(const sender: iificlient);
begin
 distribute(sender,false,false);
// dovaluechanged(sender,false);
end;

procedure tcustomificlientcontroller.execute(const sender: iificlient);
begin
 distribute(sender,false,true);
{
 if fowner.canevent(tmethod(fonclientexecute)) then begin
  fonclientexecute(self,sender);
 end;
}
end;


procedure tcustomificlientcontroller.statechanged(const sender: iificlient;
               const astate: ifiwidgetstatesty);
begin
 fwidgetstate:= astate;
 if fowner.canevent(tmethod(fonclientstatechanged)) then begin
  fonclientstatechanged(self,sender,astate,
    ifiwidgetstatesty({$ifdef FPC}longword{$else}byte{$endif}(astate) xor
                 {$ifdef FPC}longword{$else}byte{$endif}(fwidgetstatebefore)));
  fwidgetstatebefore:= astate;
 end;
end;

procedure tcustomificlientcontroller.closequery(const sender: iificlient;
               var amodalresult: modalresultty);
begin
 if fowner.canevent(tmethod(fonclientclosequery)) then begin
  fonclientclosequery(self,sender,amodalresult);
 end;
end;


procedure tcustomificlientcontroller.sendmodalresult(const sender: iificlient;
               const amodalresult: modalresultty);
begin
 if fowner.canevent(tmethod(fonclientmodalresult)) then begin
  fonclientmodalresult(self,sender,amodalresult);
 end;
end;
{
procedure tcustomifivaluewidgetcontroller.widgettovalue;
begin
 //dummy
end;
}

procedure tcustomificlientcontroller.valuestoclient(const alink: pointer);
var
 obj: tobject;
begin
 if not (ivs_loadedproc in fstate) and 
      (fowner.componentstate * [csdesigning,csloading,csdestroying] = 
                                                [csdesigning]) then begin
  obj:= iobjectlink(alink).getinstance;
  if (obj is tcomponent) and (tcomponent(obj).owner <> fowner.owner) then begin
   designchanged(tcomponent(obj));
  end;
 end;
end;

procedure tcustomificlientcontroller.valuestootherclient(const alink: pointer);
begin
 if alink <> fchangedclient then begin
  valuestoclient(alink);
 end;
end;

procedure tcustomificlientcontroller.clienttovalues(const alink: pointer);
begin
 //dummy
end;

{
function tcustomifivaluewidgetcontroller.getclientinstance: tobject;
begin
 result:= nil;
 if fintf <> nil then begin
  result:= fintf.getinstance;
 end;
end;
}
{
function tcustomifivaluewidgetcontroller.getwidget: twidget;
begin
 result:= twidget(fcomponent);
end;

procedure tcustomifivaluewidgetcontroller.setwidget(const avalue: twidget);
var
 intf1: iifilink;
begin
 intf1:= nil;
 if (avalue <> nil) and 
       not getcorbainterface(avalue,typeinfo(iifilink),intf1) then begin
  raise exception.create(avalue.name + ' is no IfI data widget.');
 end;
 setcomponent(avalue,intf1);
end;
}
procedure tcustomificlientcontroller.linkset(const alink: iificlient);
begin
 fwidgetstatebefore:= [];
 change(alink);
end;

procedure tcustomificlientcontroller.finalizelink(const alink: pointer);
begin
 iificlient(alink).setifiserverintf(nil);
end;

procedure tcustomificlientcontroller.finalizelinks;
begin
 if tmsecomponent1(fowner).fobjectlinker <> nil then begin
  tmsecomponent1(fowner).fobjectlinker.forall({$ifdef FPC}@{$endif}finalizelink,self);
 end;
end;

procedure tcustomificlientcontroller.setvalue(const sender: iificlient;
                   var avalue; var accept: boolean; const arow: integer);
begin
 //dummy
end;

procedure tcustomificlientcontroller.dataentered(const sender: iificlient;
               const arow: integer);
begin
 //dummy
end;

function tcustomificlientcontroller.canconnect(
                                       const acomponent: tcomponent): boolean;
var
 po1: pointer;
begin
// result:= getcorbainterface(acomponent,typeinfo(iifilink),po1);
 result:= getcorbainterface(acomponent,getifilinkkind(),po1);
end;

function tcustomificlientcontroller.errorname(const ainstance: tobject): string;
begin
 if ainstance = nil then begin
  result:= 'NIL';
 end
 else begin
  if ainstance is tcomponent then begin
   result:= tcomponent(ainstance).name;
  end
  else begin
   result:= ainstance.classname;
  end;
 end;
end;

function tcustomificlientcontroller.setmsestringval(const alink: iificlient;
               const aname: string; const avalue: msestring): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = msestringtypekind);
 if result then begin
  setmsestringprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getmsestringval(
                     const alink: iificlient; const aname: string;
                     var avalue: msestring): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = msestringtypekind);
 if result then begin
  avalue:= getmsestringprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setintegerval(const alink: iificlient;
               const aname: string; const avalue: integer): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkinteger);
 if result then begin
  setordprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getintegerval(
                     const alink: iificlient; const aname: string;
                     var avalue: integer): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkinteger);
 if result then begin
  avalue:= getordprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setint64val(const alink: iificlient;
               const aname: string; const avalue: int64): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkint64);
 if result then begin
  setordprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getint64val(
                     const alink: iificlient; const aname: string;
                     var avalue: int64): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkint64);
 if result then begin
  avalue:= getordprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setpointerval(const alink: iificlient;
               const aname: string; const avalue: pointer): boolean;
var
 inst: tobject;
 prop: ppropinfo;
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkint64);
 if result then begin
  setordprop(inst,prop,ptrint(avalue));
 end; 
end;

function tcustomificlientcontroller.getpointerval(const alink: iificlient;
               const aname: string; var avalue: pointer): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkpointer);
 if result then begin
  avalue:= pointer(ptrint(getordprop(inst,prop)));
 end
 else begin
///////////////////  alink.getpointerval(avalue);
 end;
end;

function tcustomificlientcontroller.setbooleanval(const alink: iificlient;
               const aname: string; const avalue: boolean): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind in boolprops);
 if result then begin
  setordprop(inst,prop,ord(avalue));
 end; 
end;

function tcustomificlientcontroller.getbooleanval(
                     const alink: iificlient; const aname: string;
                     var avalue: boolean): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind in boolprops);
 if result then begin
  avalue:= getordprop(inst,prop) <> 0;
 end; 
end;

function tcustomificlientcontroller.setrealtyval(const alink: iificlient;
               const aname: string; const avalue: realty): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  setfloatprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getrealtyval(
                     const alink: iificlient; const aname: string;
                     var avalue: realty): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  avalue:= getfloatprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setdatetimeval(const alink: iificlient;
               const aname: string; const avalue: tdatetime): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  setfloatprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getdatetimeval(
                     const alink: iificlient; const aname: string;
                     var avalue: tdatetime): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  avalue:= getfloatprop(inst,prop);
 end; 
end;

procedure tcustomificlientcontroller.loaded;
begin
 include(fstate,ivs_loadedproc);
 try
  change;
 finally
  exclude(fstate,ivs_loadedproc);
 end;
end;

procedure tcustomificlientcontroller.dogetprop(const alink: pointer); 
begin
 case fapropkind of
  tkinteger: begin
   getintegerval(iificlient(alink),fapropname,pinteger(fapropvalue)^);
  end;
  tkint64: begin
   getint64val(iificlient(alink),fapropname,pint64(fapropvalue)^);
  end;
  {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
   getbooleanval(iificlient(alink),fapropname,pboolean(fapropvalue)^);
  end;
  tkfloat: begin
   getrealtyval(iificlient(alink),fapropname,prealty(fapropvalue)^);
  end;
  msestringtypekind: begin
   getmsestringval(iificlient(alink),fapropname,pmsestring(fapropvalue)^);
  end;
 end;
end;

procedure tcustomificlientcontroller.getprop(const aname: string;
               const akind: ttypekind; const avaluepo: pointer);
begin
 fapropname:= aname;
 fapropkind:= akind;
 fapropvalue:= avaluepo;
 tmsecomponent1(fowner).getobjectlinker.forall({$ifdef FPC}@{$endif}dogetprop,self);
end;

procedure tcustomificlientcontroller.dosetprop(const alink: pointer);
begin
 case fapropkind of
  tkinteger: begin
   setintegerval(iificlient(alink),fapropname,pinteger(fapropvalue)^);
  end;
  tkint64: begin
   setint64val(iificlient(alink),fapropname,pint64(fapropvalue)^);
  end;
  {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
   setbooleanval(iificlient(alink),fapropname,pboolean(fapropvalue)^);
  end;
  tkfloat: begin
   setrealtyval(iificlient(alink),fapropname,prealty(fapropvalue)^);
  end;
  msestringtypekind: begin
   setmsestringval(iificlient(alink),fapropname,pmsestring(fapropvalue)^);
  end;
 end;
end;

procedure tcustomificlientcontroller.setprop(const aname: string;
               const akind: ttypekind; const avaluepo: pointer);
begin
 fapropname:= aname;
 fapropkind:= akind;
 fapropvalue:= avaluepo;
 tmsecomponent1(fowner).getobjectlinker.forall({$ifdef FPC}@{$endif}dosetprop,self);
end;

function tcustomificlientcontroller.getintegerpro(const aname: string): integer;
begin
 result:= 0;
 getprop(aname,tkinteger,@result);
end;

procedure tcustomificlientcontroller.setintegerpro(const aname: string;
               const avalue: integer);
begin
 setprop(aname,tkinteger,@avalue);
end;

function tcustomificlientcontroller.getmsestringpro(const aname: string): msestring;
begin
 result:= '';
 getprop(aname,msestringtypekind,@result);
end;

procedure tcustomificlientcontroller.setmsestringpro(const aname: string;
               const avalue: msestring);
begin
 setprop(aname,msestringtypekind,@avalue);
end;

function tcustomificlientcontroller.getbooleanpro(const aname: string): boolean;
begin
 result:= false;
 getprop(aname,{$ifdef FPC}tkbool{$else}tkenumeration{$endif},@result);
end;

procedure tcustomificlientcontroller.setbooleanpro(const aname: string;
               const avalue: boolean);
begin
 setprop(aname,{$ifdef FPC}tkbool{$else}tkenumeration{$endif},@avalue);
end;

function tcustomificlientcontroller.getrealtypro(const aname: string): realty;
begin
 result:= emptyreal;
 getprop(aname,tkfloat,@result);
end;

procedure tcustomificlientcontroller.setrealtypro(const aname: string;
               const avalue: realty);
begin
 setprop(aname,tkfloat,@avalue);
end;

function tcustomificlientcontroller.getdatetimepro(const aname: string): tdatetime;
begin
 result:= emptydatetime;
 getprop(aname,tkfloat,@result);
end;

procedure tcustomificlientcontroller.setdatetimepro(const aname: string;
               const avalue: tdatetime);
begin
 setprop(aname,tkfloat,@avalue);
end;

function tcustomificlientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifilink);
end;

procedure tcustomificlientcontroller.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcustomificlientcontroller.dostatread(const reader: tstatreader);
begin
 //dummy
end;

procedure tcustomificlientcontroller.dostatwrite(const writer: tstatwriter);
begin
 //dummy
end;

procedure tcustomificlientcontroller.statreading;
begin
 //dummy
end;

procedure tcustomificlientcontroller.statread;
begin
 //dummy
end;

function tcustomificlientcontroller.getstatvarname: msestring;
begin
 if fstatvarname = '' then begin
  result:= msestring(ownernamepath(fowner));
  if result = '' then begin
   result:= '.'; //dummy, statfiler can not get componentname because 
                 //self is no tcomponent
  end;
 end
 else begin
  result:= fstatvarname;
 end;
end;

procedure tcustomificlientcontroller.updateoptionsedit(var avalue: optionseditty);
begin
 //dummy
end;

function tcustomificlientcontroller.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tifilinkcomp }

constructor tifilinkcomp.create(aowner: tcomponent);
begin
 fcontroller:= getcontrollerclass.create(self);
 inherited;
end;

destructor tifilinkcomp.destroy;
begin
 fcontroller.finalizelinks;
 inherited;
 fcontroller.free;
end;

procedure tifilinkcomp.setcontroller(const avalue: tcustomificlientcontroller);
begin
 fcontroller.assign(avalue);
end;

function tifilinkcomp.getcontrollerclass: customificlientcontrollerclassty;
begin
 result:= tificlientcontroller;
end;

procedure tifilinkcomp.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

{ tvalueclientcontroller }

destructor tvalueclientcontroller.destroy;
begin
 freeandnil(fdatalist);
 inherited;
end;

function tvalueclientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 prop1: ppropinfo;
begin
 result:= inherited canconnect(acomponent);
 if result then begin
  prop1:= getpropinfo(acomponent,'value');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = fkind);
 end;
end;

function tvalueclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;
{
procedure tvalueclientcontroller.getdatalist1(const alink: pointer;
                                                   var handled: boolean);
var
 datalist1: tdatalist;
begin
 datalist1:= iifidatalink(alink).ifigriddata;
 if datalist1 <> nil then begin
  pdatalist(fitempo)^:= datalist1;
  handled:= true;
 end;
end;

function tvalueclientcontroller.getfirstdatalist1: tdatalist;
begin
 result:= fdatalist;
 if result = nil then begin
  fitempo:= @result;
  tmsecomponent1(fowner).getobjectlinker.forfirst(@getdatalist1,
                                  self); 
  if result = nil then begin
   raise exception.create('No datalist.');
  end;
 end;
end;

function tvalueclientcontroller.getfirstdatalist: tdatalist;
begin
 result:= getfirstdatalist1;
 if result = nil then begin
  raise exception.create('No datalist.');
 end;
end;
}
{
procedure tvalueclientcontroller.setmsestringvalar(const alink: pointer;
                                                      var handled: boolean);
//var
// datalist: tdatalist;
begin
// datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  tmsestringdatalist(datalist).asarray:= pmsestringarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getmsestringvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  pmsestringarty(fvalarpo)^:= tmsestringdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setintegervalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  tintegerdatalist(datalist).asarray:= pintegerarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getintegervalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fvalarpo)^:= tintegerdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setrealtyvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  trealdatalist(datalist).asarray:= prealarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getrealtyvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealarty(fvalarpo)^:= trealdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setdatetimevalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  trealdatalist(datalist).asarray:= pdatetimearty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getdatetimevalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealarty(fvalarpo)^:= trealdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setbooleanvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  tintegerdatalist(datalist).asarray:= pintegerarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getbooleanvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fvalarpo)^:= tintegerdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getvalar(const agetter: valargetterty;
                       var avalue);
begin
 fvalarpo:= @avalue;
 tmsecomponent1(fowner).getobjectlinker.forfirst(agetter,self); 
end;

procedure tvalueclientcontroller.setvalar(const asetter: valarsetterty;
                        const avalue);
begin
 fvalarpo:= @avalue;
 tmsecomponent1(fowner).getobjectlinker.forfirst(asetter,self); 
end;

procedure tvalueclientcontroller.setmsestringitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  tmsestringdatalist(datalist)[int1]:= pmsestring(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getmsestringitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  pmsestring(fitempo)^:= tmsestringdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setintegeritem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  tintegerdatalist(datalist)[int1]:= pinteger(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getintegeritem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pinteger(fitempo)^:= tintegerdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setrealtyitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  trealdatalist(datalist)[int1]:= prealty(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getrealtyitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealty(fitempo)^:= trealdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setdatetimeitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  trealdatalist(datalist)[int1]:= pdatetime(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getdatetimeitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  pdatetime(fitempo)^:= trealdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setbooleanitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  if pinteger(fitempo)^ = 0 then begin
   tintegerdatalist(datalist)[int1]:= longint(longbool(false));
  end
  else begin
   tintegerdatalist(datalist)[int1]:= longint(longbool(true));
  end;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getbooleanitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fitempo)^:= tintegerdatalist(datalist).asarray;
  handled:= true
 end;
end;

procedure tvalueclientcontroller.getitem(const index: integer; 
                                   const agetter: itemgetterty; var avalue);
begin
 fitempo:= @avalue;
 fitemindex:= index;
 tmsecomponent1(fowner).getobjectlinker.forfirst(agetter,self); 
end;

procedure tvalueclientcontroller.setitem(const index: integer; 
                               const asetter: itemsetterty; const avalue);
begin
 fitempo:= @avalue;
 fitemindex:= index;
 tmsecomponent1(fowner).getobjectlinker.forfirst(asetter,self); 
end;
}
procedure tvalueclientcontroller.statreadlist(const alink: pointer);
//var
// datalist: tdatalist;
begin
// datalist:= iifidatalink(alink).ifigriddata;
 if datalist <> nil then begin
  tstatreader(fitempo).readdatalist(getstatvarname,datalist);
 end;
end;

procedure tvalueclientcontroller.statwritelist(const alink: pointer;
                                                      var handled: boolean);
//var
// datalist: tdatalist;
begin
// datalist:= iifidatalink(alink).ifigriddata;
 if datalist <> nil then begin
  tstatwriter(fitempo).writedatalist(getstatvarname,datalist);
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setvalue(const sender: iificlient; var avalue;
               var accept: boolean; const arow: integer);
begin
 inherited;
// if accept and fowner.canevent(tmethod(fonclientdataentered)) then begin
//  fonclientdataentered(fowner,arow);
// end;
end;

procedure tvalueclientcontroller.dataentered(const sender: iificlient;
                                              const arow: integer);
begin
 inherited;
 if fowner.canevent(tmethod(fonclientdataentered)) then begin
  fonclientdataentered(self,sender,arow);
 end;
end;

procedure tvalueclientcontroller.setoptionsvalue(
                                          const avalue: valueclientoptionsty);
begin
 if foptionsvalue <> avalue then begin
  foptionsvalue:= avalue;
  optionsvaluechanged;
 end;
end;

procedure tvalueclientcontroller.linkdatalist1(const alink: pointer);
begin
 iifidatalink(alink).updateifigriddata(fowner,fdatalist);
end;

procedure tvalueclientcontroller.linkdatalist;
begin
 with tmsecomponent1(fowner) do begin
  if fobjectlinker <> nil then begin
   fobjectlinker.forall({$ifdef FPC}@{$endif}self.linkdatalist1,self);
  end;
 end;
end;

procedure tvalueclientcontroller.updatereadonlystate1(const alink: pointer);
begin
 iifidatalink(alink).updatereadonlystate;
end;

procedure tvalueclientcontroller.updatereadonlystate;
begin
 with tmsecomponent1(fowner) do begin
  if fobjectlinker <> nil then begin
   fobjectlinker.forall({$ifdef FPC}@{$endif}self.updatereadonlystate1,self);
  end;
 end;
end;

procedure tvalueclientcontroller.optionsvaluechanged;
begin
 if (vco_datalist in foptionsvalue) xor (fdatalist <> nil) then begin
  if vco_datalist in foptionsvalue then begin
   fdatalist:= createdatalist;
   if fdatalist <> nil then begin
    include(tdatalist1(fdatalist).fstate,dls_remote);
    if not (csloading in fowner.componentstate) then begin
     linkdatalist;
    end;
   end;
  end
  else begin
   freeandnil(fdatalist);
  end;
 end;
 if not (csloading in fowner.componentstate) then begin
  updatereadonlystate;
 end;
end;

procedure tvalueclientcontroller.loaded;
begin
 if fdatalist <> nil then begin 
  linkdatalist;
 end;
 updatereadonlystate;
 inherited;
end;

procedure tvalueclientcontroller.setdatasource(const avalue: tifidatasource);
begin
 if avalue <> fdatasource then begin
  setifidatasource(iifidatasourceclient(self),avalue,fdatasource);
 end;
end;

procedure tvalueclientcontroller.setfieldname(const avalue: ififieldnamety);
begin
 if avalue <> ffieldname then begin
  ffieldname:= avalue;
  bindingchanged;
 end;
end;

procedure tvalueclientcontroller.bindingchanged;
begin
end;

function tvalueclientcontroller.ifigriddata: tdatalist;
begin
 result:= fdatalist;
 if result = nil then begin
  componentexception(fowner,'No datalist, activate optionsvalue vco_datalist.');
 end;
end;

function tvalueclientcontroller.ififieldname: string;
begin
 result:= ffieldname;
end;

procedure tvalueclientcontroller.getfieldinfo(const apropname: ififieldnamety;
               var adatasource: tifidatasource; var atypes: listdatatypesty);
begin
 adatasource:= fdatasource;
 atypes:= getlistdatatypes;
end;

procedure tvalueclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 if reader.candata then begin
  if fdatalist = nil then begin
   statreadvalue(reader);
  end
  else begin
   reader.readdatalist(listvarname,fdatalist);
  end;
 end;
end;

procedure tvalueclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 if writer.candata then begin
  if fdatalist = nil then begin
   statwritevalue(writer);
  end
  else begin
   writer.writedatalist(listvarname,fdatalist);
  end;
 end;
end;

procedure tvalueclientcontroller.statreadvalue(const reader: tstatreader);
begin
 //dummy
end;

procedure tvalueclientcontroller.statwritevalue(const reader: tstatwriter);
begin
 //dummy
end;

procedure tvalueclientcontroller.updateoptionsedit(var avalue: optionseditty);
begin
 if not (csdesigning in fowner.componentstate) then begin
  if vco_readonly in foptionsvalue then begin
   include(avalue,oe_readonly);
  end;
  if vco_notnull in foptionsvalue then begin
   include(avalue,oe_notnull);
  end;
 end;
end;

procedure tvalueclientcontroller.linkset(const alink: iificlient);
begin
 if not (vco_nosync in foptionsvalue) then begin
  inherited;
 end;
end;

{ tstringclientcontroller }

constructor tstringclientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,msestringtypekind);
end;

procedure tstringclientcontroller.setvalue1(const avalue: msestring);
begin
 fvalue:= avalue;
 change;
end;

procedure tstringclientcontroller.valuestoclient(const alink: pointer);
begin
 setmsestringval(iificlient(alink),'value',fvalue);
 inherited;
end;

procedure tstringclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getmsestringval(iificlient(alink),'value',fvalue);
end;

{
procedure tstringwidgetcontroller.widgettovalue;
begin
 value:= getmsestringprop(clientinstance,fvalueproperty);
end;
}
procedure tstringclientcontroller.setvalue(const sender: iificlient;
                   var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,msestring(avalue),accept,arow);
 end;
 inherited;
end;
{
function tstringclientcontroller.getgridvalues: msestringarty;
begin
 result:= nil;
 getvalar(@getmsestringvalar,result);
end;

procedure tstringclientcontroller.setgridvalues(const avalue: msestringarty);
begin
 setvalar(@setmsestringvalar,avalue);
end;

function tstringclientcontroller.getgridvalue(const index: integer): msestring;
begin
 result:= '';
 getitem(index,@getmsestringitem,result);
end;

procedure tstringclientcontroller.setgridvalue(const index: integer;
               const avalue: msestring);
begin
 setitem(index,@setmsestringitem,avalue);
end;
}
function tstringclientcontroller.getgriddata: tifimsestringdatalist;
begin
 result:= tifimsestringdatalist(ifigriddata);
end;

procedure tstringclientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readmsestring(valuevarname,value);
end;

procedure tstringclientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writemsestring(valuevarname,value);
end;

function tstringclientcontroller.createdatalist: tdatalist;
begin
 result:= tifimsestringdatalist.create(self);
end;

function tstringclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_msestring];
end;

{ tintegerclientcontroller }

constructor tintegerclientcontroller.create(const aowner: tmsecomponent);
begin
 fvaluemax:= maxint;
 inherited create(aowner,tkinteger);
end;

procedure tintegerclientcontroller.setvalue1(const avalue: integer);
begin
 fvalue:= avalue;
 change;
end;

procedure tintegerclientcontroller.valuestoclient(const alink: pointer);
begin
 setintegerval(iificlient(alink),'value',fvalue);
 setintegerval(iificlient(alink),'valuemin',fvaluemin);
 setintegerval(iificlient(alink),'valuemax',fvaluemax);
 inherited;
end;

procedure tintegerclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getintegerval(iificlient(alink),'value',fvalue);
end;

procedure tintegerclientcontroller.setvalue(const sender: iificlient;
                      var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(fowner,sender,integer(avalue),accept,arow);
 end;
 inherited;
end;

procedure tintegerclientcontroller.setvaluemin(const avalue: integer);
begin
 fvaluemin:= avalue;
 change;
end;

procedure tintegerclientcontroller.setvaluemax(const avalue: integer);
begin
 fvaluemax:= avalue;
 change;
end;
{
function tintegerclientcontroller.getgridvalues: integerarty;
begin
 result:= nil;
 getvalar(@getintegervalar,result);
end;

procedure tintegerclientcontroller.setgridvalues(const avalue: integerarty);
begin
 setvalar(@setintegervalar,avalue);
end;

function tintegerclientcontroller.getgridvalue(const index: integer): integer;
begin
 result:= 0;
 getitem(index,@getintegeritem,result);
end;

procedure tintegerclientcontroller.setgridvalue(const index: integer;
               const avalue: integer);
begin
 setitem(index,@setintegeritem,avalue);
end;
}
function tintegerclientcontroller.getgriddata: tifiintegerdatalist;
begin
 result:= tifiintegerdatalist(ifigriddata);
end;

procedure tintegerclientcontroller.readmin(reader: treader);
begin
 valuemin:= reader.readinteger;
end;

procedure tintegerclientcontroller.readmax(reader: treader);
begin
 valuemax:= reader.readinteger;
end;

procedure tintegerclientcontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('min',@readmin,nil,false);
 filer.defineproperty('max',@readmax,nil,false);
end;

procedure tintegerclientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readinteger(valuevarname,value);
end;

procedure tintegerclientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writeinteger(valuevarname,value);
end;

function tintegerclientcontroller.createdatalist: tdatalist;
begin
 result:= tifiintegerdatalist.create(self);
end;

function tintegerclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_integer];
end;

{ tint64clientcontroller }

constructor tint64clientcontroller.create(const aowner: tmsecomponent);
begin
 fvaluemax:= maxint;
 inherited create(aowner,tkint64);
end;

procedure tint64clientcontroller.setvalue1(const avalue: int64);
begin
 fvalue:= avalue;
 change;
end;

procedure tint64clientcontroller.valuestoclient(const alink: pointer);
begin
 setint64val(iificlient(alink),'value',fvalue);
 setint64val(iificlient(alink),'valuemin',fvaluemin);
 setint64val(iificlient(alink),'valuemax',fvaluemax);
 inherited;
end;

procedure tint64clientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getint64val(iificlient(alink),'value',fvalue);
end;

procedure tint64clientcontroller.setvalue(const sender: iificlient;
                       var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,int64(avalue),accept,arow);
 end;
 inherited;
end;

procedure tint64clientcontroller.setvaluemin(const avalue: int64);
begin
 fvaluemin:= avalue;
 change;
end;

procedure tint64clientcontroller.setvaluemax(const avalue: int64);
begin
 fvaluemax:= avalue;
 change;
end;
{
function tint64clientcontroller.getgridvalues: int64arty;
begin
 result:= nil;
 getvalar(@getint64valar,result);
end;

procedure tint64clientcontroller.setgridvalues(const avalue: int64arty);
begin
 setvalar(@setint64valar,avalue);
end;

function tint64clientcontroller.getgridvalue(const index: int64): int64;
begin
 result:= 0;
 getitem(index,@getint64item,result);
end;

procedure tint64clientcontroller.setgridvalue(const index: int64;
               const avalue: int64);
begin
 setitem(index,@setint64item,avalue);
end;
}
function tint64clientcontroller.getgriddata: tifiint64datalist;
begin
 result:= tifiint64datalist(ifigriddata);
end;

procedure tint64clientcontroller.readmin(reader: treader);
begin
 valuemin:= reader.readint64();
end;

procedure tint64clientcontroller.readmax(reader: treader);
begin
 valuemax:= reader.readint64()
end;

procedure tint64clientcontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('min',@readmin,nil,false);
 filer.defineproperty('max',@readmax,nil,false);
end;

procedure tint64clientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readint64(valuevarname,value);
end;

procedure tint64clientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writeint64(valuevarname,value);
end;

function tint64clientcontroller.createdatalist: tdatalist;
begin
 result:= tifiint64datalist.create(self);
end;

function tint64clientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_int64];
end;

{ tpointerclientcontroller }


constructor tpointerclientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,tkpointer);
end;

procedure tpointerclientcontroller.setvalue1(const avalue: pointer);
begin
 fvalue:= avalue;
 change;
end;

function tpointerclientcontroller.getgriddata: tifipointerdatalist;
begin
 result:= tifipointerdatalist(ifigriddata);
end;

procedure tpointerclientcontroller.valuestoclient(const alink: pointer);
begin
 setpointerval(iificlient(alink),'value',fvalue);
 inherited;
end;

procedure tpointerclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getpointerval(iificlient(alink),'value',fvalue);
end;

procedure tpointerclientcontroller.setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,pointer(avalue),accept,arow);
 end;
 inherited;
end;

function tpointerclientcontroller.createdatalist: tdatalist;
begin
 result:= tifipointerdatalist.create(self);
end;

function tpointerclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_pointer];
end;

{ tbooleanclientcontroller }

constructor tbooleanclientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,{$ifdef FPC}tkbool{$else}tkenumeration{$endif});
end;

procedure tbooleanclientcontroller.setvalue1(const avalue: boolean);
begin
 fvalue:= avalue;
 change;
end;

procedure tbooleanclientcontroller.valuestoclient(const alink: pointer);
begin
 setbooleanval(iificlient(alink),'value',fvalue);
 inherited;
end;

procedure tbooleanclientcontroller.clienttovalues(const alink: pointer);
var
 bo1: boolean;
begin
 inherited;
 bo1:= fvalue;
 getbooleanval(iificlient(alink),'value',bo1);
 fvalue:= bo1;
end;

procedure tbooleanclientcontroller.setvalue(const sender: iificlient;
                   var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,boolean(avalue),accept,arow);
 end;
 inherited;
end;

function tbooleanclientcontroller.createdatalist: tdatalist;
begin
 result:= tifibooleandatalist.create(self);
end;

{
function tbooleanclientcontroller.getgridvalues: longboolarty;
begin
 result:= nil;
 getvalar(@getbooleanvalar,result);
end;

procedure tbooleanclientcontroller.setgridvalues(const avalue: longboolarty);
begin
 setvalar(@setbooleanvalar,avalue);
end;

function tbooleanclientcontroller.getgridvalue(const index: integer): boolean;
begin
 result:= false;
 getitem(index,@getbooleanitem,result);
end;

procedure tbooleanclientcontroller.setgridvalue(const index: integer;
               const avalue: boolean);
begin
 setitem(index,@setbooleanitem,avalue);
end;
}
function tbooleanclientcontroller.getgriddata: tifibooleandatalist;
begin
 result:= tifibooleandatalist(ifigriddata);
end;

procedure tbooleanclientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readboolean(valuevarname,value);
end;

procedure tbooleanclientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writeboolean(valuevarname,value);
end;

function tbooleanclientcontroller.getvalue: boolean;
begin
 result:= fvalue;
end;

function tbooleanclientcontroller.getvaluedefault: boolean;
begin
 result:= fvaluedefault;
end;

procedure tbooleanclientcontroller.setvaluedefault(const avalue: boolean);
begin
 fvaluedefault:= avalue;
end;

function tbooleanclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_integer];
end;

{ trealclientcontroller }

constructor trealclientcontroller.create(const aowner: tmsecomponent);
begin
 fvalue:= emptyreal;
 fvaluedefault:= emptyreal;
 fvaluemin:= emptyreal;
 fvaluemax:= bigreal;
 inherited create(aowner,tkfloat);
end;

procedure trealclientcontroller.setvalue1(const avalue: realty);
begin
 fvalue:= avalue;
 change;
end;

procedure trealclientcontroller.valuestoclient(const alink: pointer);
begin
 setrealtyval(iificlient(alink),'value',fvalue);
 setrealtyval(iificlient(alink),'valuemin',fvaluemin);
 setrealtyval(iificlient(alink),'valuemax',fvaluemax);
 inherited;
end;

procedure trealclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getrealtyval(iificlient(alink),'value',fvalue);
end;

procedure trealclientcontroller.setvalue(const sender: iificlient;
                        var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,realty(avalue),accept,arow);
 end;
 inherited;
end;

function trealclientcontroller.createdatalist: tdatalist;
begin
 result:= tifirealdatalist.create(self);
end;

procedure trealclientcontroller.setvaluemin(const avalue: realty);
begin
 fvaluemin:= avalue;
 change;
end;

procedure trealclientcontroller.setvaluemax(const avalue: realty);
begin
 fvaluemax:= avalue;
 change;
end;

procedure trealclientcontroller.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure trealclientcontroller.readmin1(reader: treader);
begin
 fvaluemin:= readrealty(reader);
end;

procedure trealclientcontroller.readmax1(reader: treader);
begin
 fvaluemax:= readrealty(reader);
end;

procedure trealclientcontroller.readvaluedefault(reader: treader);
begin
 valuedefault:= readrealty(reader);
end;

procedure trealclientcontroller.readmin(reader: treader);
begin
 valuemin:= reader.readfloat;
end;

procedure trealclientcontroller.readmax(reader: treader);
begin
 valuemax:= reader.readfloat;
end;

procedure trealclientcontroller.defineproperties(filer: tfiler);
begin
 inherited;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin1,nil,false);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax1,nil,false);
 filer.DefineProperty('def',{$ifdef FPC}@{$endif}readvaluedefault,nil,false);
 filer.defineproperty('min',@readmin,nil,false);
 filer.defineproperty('max',@readmax,nil,false);
end;

function trealclientcontroller.getgriddata: tifirealdatalist;
begin
 result:= tifirealdatalist(ifigriddata);
end;

procedure trealclientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readreal(valuevarname,value);
end;

procedure trealclientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writereal(valuevarname,value);
end;

function trealclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_real];
end;

{ tdatetimeclientcontroller }

constructor tdatetimeclientcontroller.create(const aowner: tmsecomponent);
begin
 fvalue:= emptydatetime;
 fvaluedefault:= emptydatetime;
 fvaluemin:= emptydatetime;
 fvaluemax:= bigdatetime;
 inherited create(aowner,tkfloat);
end;

procedure tdatetimeclientcontroller.setvalue1(const avalue: tdatetime);
begin
 fvalue:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.valuestoclient(const alink: pointer);
begin
 setdatetimeval(iificlient(alink),'value',fvalue);
 setdatetimeval(iificlient(alink),'valuemin',fvaluemin);
 setdatetimeval(iificlient(alink),'valuemax',fvaluemax);
 inherited;
end;

procedure tdatetimeclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getdatetimeval(iificlient(alink),'value',fvalue);
end;

procedure tdatetimeclientcontroller.setvalue(const sender: iificlient;
                       var avalue; var accept: boolean; const arow: integer);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,sender,tdatetime(avalue),accept,arow);
 end;
 inherited;
end;

function tdatetimeclientcontroller.createdatalist: tdatalist;
begin
 result:= tifidatetimedatalist.create(self);
end;

procedure tdatetimeclientcontroller.setvaluemin(const avalue: tdatetime);
begin
 fvaluemin:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.setvaluemax(const avalue: tdatetime);
begin
 fvaluemax:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;
{
procedure tdatetimeclientcontroller.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;
}
procedure tdatetimeclientcontroller.readmin1(reader: treader);
begin
 fvaluemin:= readrealty(reader);
end;
{
procedure tdatetimeclientcontroller.writemin(writer: twriter);
begin
 writerealty(writer,fmin);
end;
}
procedure tdatetimeclientcontroller.readmax1(reader: treader);
begin
 fvaluemax:= readrealty(reader);
end;
{
procedure tdatetimeclientcontroller.writemax(writer: twriter);
begin
 writerealty(writer,fmax);
end;
}
procedure tdatetimeclientcontroller.readvaluedefault(reader: treader);
begin
 valuedefault:= readrealty(reader);
end;
{
procedure tdatetimeclientcontroller.writevaluedefault(writer: twriter);
begin
 writerealty(writer,fvaluedefault);
end;
}
procedure tdatetimeclientcontroller.readmin(reader: treader);
begin
 valuemin:= reader.readfloat();
end;

procedure tdatetimeclientcontroller.readmax(reader: treader);
begin
 valuemax:= reader.readfloat();
end;

procedure tdatetimeclientcontroller.defineproperties(filer: tfiler);
begin
 inherited;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin1,nil,false);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax1,nil,false);
 filer.DefineProperty('def',{$ifdef FPC}@{$endif}readvaluedefault,nil,false);
 filer.defineproperty('min',@readmin,nil,false);
 filer.defineproperty('max',@readmax,nil,false);
end;
{
function tdatetimeclientcontroller.getgridvalues: datetimearty;
begin
 result:= nil;
 getvalar(@getdatetimevalar,result);
end;

procedure tdatetimeclientcontroller.setgridvalues(const avalue: datetimearty);
begin
 setvalar(@setdatetimevalar,avalue);
end;

function tdatetimeclientcontroller.getgridvalue(const index: integer): tdatetime;
begin
 result:= emptydatetime;
 getitem(index,@getdatetimeitem,result);
end;

procedure tdatetimeclientcontroller.setgridvalue(const index: integer;
               const avalue: tdatetime);
begin
 setitem(index,@setdatetimeitem,avalue);
end;
}
function tdatetimeclientcontroller.getgriddata: tifidatetimedatalist;
begin
 result:= tifidatetimedatalist(ifigriddata);
end;

procedure tdatetimeclientcontroller.statreadvalue(const reader: tstatreader);
begin
 inherited;
 value:= reader.readreal(valuevarname,value);
end;

procedure tdatetimeclientcontroller.statwritevalue(const writer: tstatwriter);
begin
 inherited;
 writer.writereal(valuevarname,value);
end;

function tdatetimeclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [dl_real];
end;

{ tifistringlinkcomp }

function tifistringlinkcomp.getcontrollerclass: 
                                customificlientcontrollerclassty;
begin
 result:= tstringclientcontroller;
end;

function tifistringlinkcomp.getcontroller: tstringclientcontroller;
begin
 result:= tstringclientcontroller(inherited controller);
end;

procedure tifistringlinkcomp.setcontroller(const avalue: tstringclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifidropdownlistlinkcomp }

function tifidropdownlistlinkcomp.getcontroller: tdropdownlistclientcontroller;
begin
 result:= tdropdownlistclientcontroller(inherited controller);
end;

procedure tifidropdownlistlinkcomp.setcontroller(
                                 const avalue: tdropdownlistclientcontroller);
begin
 inherited setcontroller(avalue);
end;

function tifidropdownlistlinkcomp.getcontrollerclass: 
                                   customificlientcontrollerclassty;
begin
 result:= tdropdownlistclientcontroller;
end;

{ tifiintegerlinkcomp }

function tifiintegerlinkcomp.getcontrollerclass: 
                                       customificlientcontrollerclassty;
begin
 result:= tintegerclientcontroller;
end;

function tifiintegerlinkcomp.getcontroller: tintegerclientcontroller;
begin
 result:= tintegerclientcontroller(inherited controller);
end;

procedure tifiintegerlinkcomp.setcontroller(const avalue: tintegerclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifiint64linkcomp }

function tifiint64linkcomp.getcontrollerclass: 
                           customificlientcontrollerclassty;
begin
 result:= tint64clientcontroller;
end;

function tifiint64linkcomp.getcontroller: tint64clientcontroller;
begin
 result:= tint64clientcontroller(inherited controller);
end;

procedure tifiint64linkcomp.setcontroller(const avalue: tint64clientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifipointerlinkcomp }

function tifipointerlinkcomp.getcontroller: tpointerclientcontroller;
begin
 result:= tpointerclientcontroller(inherited controller);
end;

procedure tifipointerlinkcomp.setcontroller(
              const avalue: tpointerclientcontroller);
begin
 inherited setcontroller(avalue);
end;

function tifipointerlinkcomp.getcontrollerclass: customificlientcontrollerclassty;
begin
 result:= tpointerclientcontroller;
end;

{ tifibooleanlinkcomp }

function tifibooleanlinkcomp.getcontrollerclass: 
                              customificlientcontrollerclassty;
begin
 result:= tbooleanclientcontroller;
end;

function tifibooleanlinkcomp.getcontroller: tbooleanclientcontroller;
begin
 result:= tbooleanclientcontroller(inherited controller);
end;

procedure tifibooleanlinkcomp.setcontroller(const avalue: tbooleanclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifireallinkcomp }

function tifireallinkcomp.getcontrollerclass: 
                                   customificlientcontrollerclassty;
begin
 result:= trealclientcontroller;
end;

function tifireallinkcomp.getcontroller: trealclientcontroller;
begin
 result:= trealclientcontroller(inherited controller);
end;

procedure tifireallinkcomp.setcontroller(const avalue: trealclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifidatetimelinkcomp }

function tifidatetimelinkcomp.getcontrollerclass: 
                                       customificlientcontrollerclassty;
begin
 result:= tdatetimeclientcontroller;
end;

function tifidatetimelinkcomp.getcontroller: tdatetimeclientcontroller;
begin
 result:= tdatetimeclientcontroller(inherited controller);
end;

procedure tifidatetimelinkcomp.setcontroller(const avalue: tdatetimeclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tificlientcontroller }

{ tifiactionlinkcomp }

function tifiactionlinkcomp.getcontrollerclass:
                               customificlientcontrollerclassty;
begin
 result:= texecclientcontroller;
end;

function tifiactionlinkcomp.getcontroller: texecclientcontroller;
begin
 result:= texecclientcontroller(inherited controller);
end;

procedure tifiactionlinkcomp.setcontroller(const avalue: texecclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tififormlinkcomp }

function tififormlinkcomp.getcontrollerclass: 
                               customificlientcontrollerclassty;
begin
 result:= tformclientcontroller;
end;

function tififormlinkcomp.getcontroller: tformclientcontroller;
begin
 result:= tformclientcontroller(inherited controller);
end;

procedure tififormlinkcomp.setcontroller(const avalue: tformclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ texecclientcontroller }

function texecclientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 po1: pointer;
// prop1: ppropinfo;
begin
// result:= inherited canconnect(acomponent);
 result:= getcorbainterface(acomponent,typeinfo(iifiexeclink),po1);
 {
 if result then begin
  prop1:= getpropinfo(acomponent,'onexecute');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = tkmethod);
 end;
 }
end;

procedure texecclientcontroller.valuestoclient(const alink: pointer);
begin
 if not (ivs_loadedproc in fstate) then begin
  iifiexeclink(alink).execute;
 end;
end;
{
procedure texecclientcontroller.execute(const sender: iificlient);
begin
 dovaluechanged(sender,true); //distribute event
 inherited;
end;
}
procedure texecclientcontroller.execute;
begin
 distribute(nil,true,true);
// dovaluechanged(nil,true); //distribute event
end;

procedure texecclientcontroller.linkset(const alink: iificlient);
begin
 //do nothing
end;

function texecclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifiexeclink);
end;

{ tifigridlinkcomp }

function tifigridlinkcomp.getcontrollerclass: 
                                 customificlientcontrollerclassty;
begin
 result:= tgridclientcontroller;
end;

function tifigridlinkcomp.getcontroller: tgridclientcontroller;
begin
 result:= tgridclientcontroller(inherited controller);
end;

procedure tifigridlinkcomp.setcontroller(const avalue: tgridclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifilinkcomparrayprop }

constructor tifilinkcomparrayprop.create;
begin
 inherited create(tificolitem);
end;

class function tifilinkcomparrayprop.getitemclasstype: persistentclassty;
begin
 result:= tificolitem;
end;

function tifilinkcomparrayprop.getitems(const index: integer): tificolitem;
begin
 result:= tificolitem(inherited getitems(index));
end;

{ tifivaluelinkcomp }

function tifivaluelinkcomp.getcontroller: tvalueclientcontroller;
begin
 result:= tvalueclientcontroller(fcontroller);
end;

{ tificolitem }

function tificolitem.getlink: tifivaluelinkcomp;
begin
 result:= tifivaluelinkcomp(item);
end;

procedure tificolitem.setlink(const avalue: tifivaluelinkcomp);
begin
 item:= avalue;
end;

{ tifidropdowncols }

constructor tifidropdowncols.create(const aowner: tifidropdownlistcontroller);
begin
 inherited create(aowner,nil);
end;

class function tifidropdowncols.getitemclasstype: persistentclassty;
begin
 result:= tifidropdowncol;
end;

procedure tifidropdowncols.createitem(const index: integer;
               var item: tpersistent);
begin
 item:= tifidropdowncol.create;
 tifidropdowncol(item).onchange:= {$ifdef FPC}@{$endif}colchanged;
end;

function tifidropdowncols.getitems(const index: integer): tifidropdowncol;
begin
 result:= tifidropdowncol(inherited getitems(index));
end;

procedure tifidropdowncols.colchanged(const sender: tobject);
begin
 change(-1);
end;

procedure tifidropdowncols.dochange(const index: integer);
begin
 tifidropdownlistcontroller(fowner).fowner.change(nil); 
end;

{ tifidropdownlistcontroller }

constructor tifidropdownlistcontroller.create(
                                      const aowner: tvalueclientcontroller);
begin
 fowner:= aowner;
 fcols:= tifidropdowncols.create(self);
 inherited create;
end;

destructor tifidropdownlistcontroller.destroy;
begin
 inherited;
 fcols.free;
end;

procedure tifidropdownlistcontroller.setcols(const avalue: tifidropdowncols);
begin
 fcols.assign(avalue);
end;

procedure tifidropdownlistcontroller.valuestoclient(const alink: pointer);
begin
 iifidropdownlistdatalink(alink).ifidropdownlistchanged(fcols);
end;

{ tdropdownlistclientcontroller }

constructor tdropdownlistclientcontroller.create(const aowner: tmsecomponent);
begin
 fdropdown:= tifidropdownlistcontroller.create(self);
 inherited;
end;

destructor tdropdownlistclientcontroller.destroy;
begin
 inherited;
 fdropdown.free;
end;

procedure tdropdownlistclientcontroller.setdropdown(
                                 const avalue: tifidropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tdropdownlistclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidropdownlistdatalink);
end;

procedure tdropdownlistclientcontroller.valuestoclient(const alink: pointer);
begin
 fdropdown.valuestoclient(alink);
 inherited;
end;

{ tenumclientcontroller }

constructor tenumclientcontroller.create(const aowner: tmsecomponent);
begin
 fdropdown:= tifidropdownlistcontroller.create(self);
 inherited;
 fvaluemin:= -1;
 fvalue:= -1;
 fvaluedefault:= -1;
end;

destructor tenumclientcontroller.destroy;
begin
 inherited;
 fdropdown.free;
end;

procedure tenumclientcontroller.setdropdown(
                                 const avalue: tifidropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tenumclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidropdownlistdatalink);
end;

procedure tenumclientcontroller.valuestoclient(const alink: pointer);
begin
 fdropdown.valuestoclient(alink);
 inherited;
end;

{ tifienumlinkcomp }

function tifienumlinkcomp.getcontroller: tenumclientcontroller;
begin
 result:= tenumclientcontroller(inherited controller);
end;

procedure tifienumlinkcomp.setcontroller(
                                 const avalue: tenumclientcontroller);
begin
 inherited setcontroller(avalue);
end;

function tifienumlinkcomp.getcontrollerclass: customificlientcontrollerclassty;
begin
 result:= tenumclientcontroller;
end;

{ tifidropdowncol }
 
procedure tifidropdowncol.setdatasource(const avalue: tifidatasource);
begin
 if avalue <> fdatasource then begin
  setifidatasource(iifidatasourceclient(self),avalue,fdatasource);
 end;
end;

procedure tifidropdowncol.setdatafield(const avalue: ififieldnamety);
begin
 if avalue <> fdatafield then begin
  fdatafield:= avalue;
  bindingchanged;
 end;
end;

procedure tifidropdowncol.bindingchanged;
begin
end;

procedure tifidropdowncol.getfieldinfo(const apropname: ififieldnamety;
               var adatasource: tifidatasource; var atypes: listdatatypesty);
begin
 adatasource:= fdatasource;
 atypes:= [dl_msestring,dl_ansistring];
end;

function tifidropdowncol.ifigriddata: tdatalist;
begin
 result:= self;
end;

function tifidropdowncol.ififieldname: string;
begin
 result:= fdatafield;
end;

{ tifidatasource }

constructor tifidatasource.create(aowner: tcomponent);
begin
 if ffields = nil then begin
  ffields:= tififields.create;
 end;
{$ifdef usedelegation}
 ffieldsourceintf:= iififieldsource(ffields);
{$endif}
 inherited;
end;

destructor tifidatasource.destroy;
begin
 freeandnil(ftimer);
 inherited;
 ffields.free;
end;

procedure tifidatasource.setfields(const avalue: tififields);
begin
 ffields.assign(avalue);
end;
{$ifndef usedelegation}
function tifidatasource.getfieldnames(const atypes: listdatatypesty): msestringarty;
begin
 result:= ffields.getfieldnames(atypes);
end;
{$endif}

procedure tifidatasource.open;
begin
 if canevent(tmethod(fonbeforeopen)) then begin
  fonbeforeopen(self);
 end;
end;

procedure tifidatasource.afteropen;
begin
 factive:= true;
 if canevent(tmethod(fonafteropen)) then begin
  fonafteropen(self);
 end;
end;

procedure tifidatasource.close;
begin
 factive:= false;
end;

procedure tifidatasource.setactive(const avalue: boolean);
begin
 if csreading in componentstate then begin
  fopenafterread:= avalue;
 end
 else begin
  if factive <> avalue then begin
   if avalue then begin
    open;
   end
   else begin
    fopenafterread:= false;
    close;
   end;
  end;
 end;
end;

procedure tifidatasource.dorefresh(const sender: tobject);
var
 b1: boolean;
 ar1: datalistarty;
 ar2: stringarty;
 int1: integer;
begin
 destdatalists(ar2,ar1);
 b1:= frefreshing;
 frefreshing:= true;
 for int1:= 0 to high(ar1) do begin
  ar1[int1].beginupdate();
 end;
 try
  active:= false;
  active:= true;
 finally
  for int1:= 0 to high(ar1) do begin
   ar1[int1].endupdate();
  end;
  frefreshing:= b1;
 end;
end;

procedure tifidatasource.refresh(const delayus: integer = -1);
begin
 if delayus < 0 then begin
  freeandnil(ftimer);
  dorefresh(nil);
 end
 else begin
  if ftimer = nil then begin
   ftimer:= tsimpletimer.create(delayus,@dorefresh,true,[to_single]);
  end
  else begin
   ftimer.interval:= delayus; //single shot
   ftimer.enabled:= true;
  end;
 end;
end;

procedure tifidatasource.checkrefresh();
begin
 if ftimer <> nil then begin
  ftimer.firependingandstop; //cancel wait
 end;
end;

procedure tifidatasource.loaded;
begin
 inherited;
 if fopenafterread then begin
  try
   active:= true;
  except
   if csdesigning in componentstate then begin
    application.handleexception;
   end
   else begin
    raise;
   end;
  end;
 end;
end;

procedure tifidatasource.doactivated;
begin
 active:= true;
end;

procedure tifidatasource.dodeactivated;
begin
 active:= false;
end;

procedure tifidatasource.getbindinginfo(const alink: pointer);
begin
 with iifidatasourceclient(alink) do begin
  fnamear[findex]:= ififieldname;
  flistar[findex]:= ifigriddata;
 end;
 inc(findex);
end;

procedure tifidatasource.destdatalists(out names: stringarty; 
                                                 out lists: datalistarty);
var
 int1,int2,int3: integer;
begin
 with getobjectlinker do begin
  setlength(fnamear,count);
  setlength(flistar,count);
  setlength(names,count);
  setlength(lists,count);
  findex:= 0;
  forall({$ifdef FPC}@{$endif}getbindinginfo,typeinfo(iifidatasourceclient));
 end;
 int3:= 0;
 with ffields do begin 
//  result:= nil;
//  setlength(result,count);
  for int1:= 0 to high(fnamear) do begin
   if fnamear[int1] <> '' then begin
    for int2:= 0 to high(fitems) do begin
     if (fnamear[int1] = tififield(fitems[int2]).ffieldname) then begin
      names[int3]:= fnamear[int1];
      lists[int3]:= flistar[int1];
      inc(int3);
      break;
     end;
    end;
   end;
  end;
 end;
 setlength(lists,int3);
 setlength(names,int3);
 fnamear:= nil;
 flistar:= nil;
// for int1:= 0 to high(result) do begin
// end;
end;

{ tififield }

{ tififields }

constructor tififields.create;
begin
 inherited create(getififieldclass);
end;

function tififields.getififieldclass: ififieldclassty;
begin
 result:= tififield;
end;

function tififields.getfieldnames(const atypes: listdatatypesty): msestringarty;
var
 int1,int2: integer;
begin
 setlength(result,count);
 int2:= 0;
 for int1:= 0 to count - 1 do begin
  with tififield(fitems[int1]) do begin
   if (atypes = []) or (datatype in atypes) then begin
    result[int2]:= msestring(fieldname);
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

class function tififields.getitemclasstype: persistentclassty;
begin
 result:= tififield;
end;

{ tififieldlink }

function tififieldlink.getfieldnames(
                  const appropname: ifisourcefieldnamety): msestringarty;
begin
 result:= fowner.getfieldnames(datatype);
end;

procedure tififieldlink.setdesignsourcefieldname(
                           const aname: ifisourcefieldnamety);
begin
 if ffieldname = '' then begin
  ffieldname:= aname;
 end;
 if fdatatype = dl_none then begin
  datatype:= fowner.sourcefieldtype(aname);
 end;
end;

{$ifndef FPC}
function tififieldlink._addref: integer;
begin
 result:= -1;
end;

function tififieldlink._release: integer;
begin
 result:= -1;
end;

function tififieldlink.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;
{$endif}
{ tififieldlinks }

function tififieldlinks.getififieldclass: ififieldlinkclassty;
begin
 result:= tififieldlink;
end;

procedure tififieldlinks.createitem(const index: integer; var item: tpersistent);
begin
 item:= getififieldclass.create;
 tififieldlink(item).fowner:= self;
end;

function tififieldlinks.getfieldnames(
                        const adatatype: listdatatypety): msestringarty;
begin
 result:= nil;
end;

function tififieldlinks.sourcefieldnames: stringarty;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 0 to high(result) do begin
  result[int1]:= tififieldlink(fitems[int1]).sourcefieldname;
 end;
end;

function tififieldlinks.sourcefieldtype(
                                 const afieldname: string): listdatatypety;
begin
 result:= dl_none; //dummy
end;

{ tificonnectedfields }

constructor tificonnectedfields.create(const aowner: tconnectedifidatasource);
begin
 inherited create;
 fowner:= aowner;
end;

function tificonnectedfields.sourcefieldtype(
              const afieldname: string): listdatatypety;
begin
 result:= dl_none;
 if fowner.fconnectionintf <> nil then begin
  result:= fowner.fconnectionintf.getdatatype(afieldname);
 end;
end;

function tificonnectedfields.getfieldnames(
                            const adatatype: listdatatypety): msestringarty;
begin
 result:= fowner.getfieldnames(adatatype);
end;

{ tconnectedifidatasource }

constructor tconnectedifidatasource.create(aowner: tcomponent);
begin
 if ffields = nil then begin
  ffields:= tificonnectedfields.create(self);
 end;
 inherited;
end;

procedure tconnectedifidatasource.setconnection(const avalue: tmsecomponent);
begin
 if avalue <> nil then begin
  checkcorbainterface(self,avalue,typeinfo(iifidataconnection),fconnectionintf);
 end;
 setlinkedvar(avalue,fconnection);
end;

function tconnectedifidatasource.getfields: tificonnectedfields;
begin
 result:= tificonnectedfields(inherited fields);
end;

procedure tconnectedifidatasource.setfields(const avalue: tificonnectedfields);
begin
 inherited setfields(avalue);
end;

function tconnectedifidatasource.getfieldnames(
                   const adatatype: listdatatypety): msestringarty;
begin
 result:= nil;
 if fconnectionintf <> nil then begin
  result:= fconnectionintf.getfieldnames(adatatype);
 end;
end;

procedure tconnectedifidatasource.open;
var
 ar1: stringarty;
 ar2: datalistarty;
begin
 inherited;
 checkconnection;
 destdatalists(ar1,ar2);
 fconnectionintf.fetchdata(ar1,ar2);
 afteropen;
end;

procedure tconnectedifidatasource.close;
var
 ar1: datalistarty;
 ar2: stringarty;
 int1: integer;
begin
 destdatalists(ar2,ar1);
 for int1:= 0 to high(ar1) do begin
  ar1[int1].clear;
 end;
 inherited;
end;

procedure tconnectedifidatasource.checkconnection;
begin
 if fconnectionintf = nil then begin
  raise exception.create(name+': No connection.');
 end;
end;

{ tifiintegerdatalist }

constructor tifiintegerdatalist.create(const aowner: tintegerclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifiintegerdatalist.getdefault: pointer;
begin
 result:= @fowner.valuedefault;
end;

{ tifiint64datalist }

constructor tifiint64datalist.create(const aowner: tint64clientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifiint64datalist.getdefault: pointer;
begin
 result:= @fowner.valuedefault;
end;

{ tifipointerdatalist }

constructor tifipointerdatalist.create(const aowner: tpointerclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

{ tifibooleandatalist }

constructor tifibooleandatalist.create(const aowner: tbooleanclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifibooleandatalist.getdefault: pointer;
begin
 result:= @fowner.fvaluedefault;
end;

{ tifirealdatalist }

constructor tifirealdatalist.create(const aowner: trealclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifirealdatalist.getdefault: pointer;
begin
 result:= @fowner.fvaluedefault;
end;

{ tifidatetimedatalist }

constructor tifidatetimedatalist.create(const aowner: tdatetimeclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifidatetimedatalist.getdefault: pointer;
begin
 result:= @fowner.fvaluedefault;
end;

{ tifimsestringdatalist }

constructor tifimsestringdatalist.create(const aowner: tstringclientcontroller);
begin
 fowner:= aowner;
 inherited create;
end;

function tifimsestringdatalist.getdefault: pointer;
begin
 result:= @fowner.fvaluedefault;
end;

{ trowstatehandler }

constructor trowstatehandler.create(const aowner: tgridclientcontroller);
begin
 fowner:= aowner;
 initsource(flistlink);
 inherited create;
end;

destructor trowstatehandler.destroy;
begin
 removesource(flistlink);
 inherited;
end;

procedure trowstatehandler.setifilink(const avalue: tifivaluelinkcomp);
begin
 setifilinkcomp(iifidatalink(self),avalue,tifilinkcomp(fifilink));
end;

procedure trowstatehandler.setifiserverintf(const aintf: iifiserver);
begin
 //dummy
end;

procedure trowstatehandler.ifisetvalue(var avalue; var accept: boolean);
begin
 //dummy
end;

function trowstatehandler.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure trowstatehandler.updateifigriddata(const sender: tobject;
               const alist: tdatalist);
begin
 internallinksource(alist,0,flistlink.source);
end;

function trowstatehandler.getgriddata: tdatalist;
begin
 result:= nil;
end;

function trowstatehandler.getvalueprop: ppropinfo;
begin
 result:= nil;
end;

procedure trowstatehandler.sourcechange(const sender: tdatalist;
               const aindex: integer);
begin //todo: optimize
 if checksourcechange(flistlink,sender,aindex) then begin
  if not (dls_remotelock in fstate) then begin
   include(fstate,dls_remotelock);
   try
    if aindex < 0 then begin
     fowner.rowcount:= sender.count;
    end;
    findexpar:= aindex;
    tmsecomponent1(fowner.fowner).getobjectlinker.forall(
                             {$ifdef FPC}@{$endif}updateclient,fowner);
    //...
   finally
    exclude(fstate,dls_remotelock);
   end;
  end;
 end;
end;

function trowstatehandler.canlink(const asource: tdatalist;
               const atag: integer): boolean;
begin
 result:= true; //datalist type defined by ifidatalink kind
end;

procedure trowstatehandler.listdestroyed(const sender: tdatalist);
begin
 if sender = flistlink.source then begin
  flistlink.source:= nil;
 end;
 inherited;
end;

procedure trowstatehandler.itemchanged(const sender: tcustomrowstatelist;
               const aindex: integer);
begin //todo: optimize
 if (flistlink.source <> nil) and not (dls_remotelock in fstate) then begin
  include(fstate,dls_remotelock);
  try
   if aindex < 0 then begin
    flistlink.source.count:= sender.count;
   end;
   updateremote(sender,aindex);
  finally
   exclude(fstate,dls_remotelock);
  end;
 end;
end;

procedure trowstatehandler.updatereadonlystate;
begin
 //dummy
end;

function trowstatehandler.getdefaultifilink: iificlient;
begin
 result:= iifidatalink(self);
end;

{ trowstateintegerhandler }

function trowstateintegerhandler.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure trowstateintegerhandler.setifilink(const avalue: tifiintegerlinkcomp);
begin
 inherited setifilink(avalue);
end;

{ trowstatebooleanhandler }

function trowstatebooleanhandler.getifilink: tifibooleanlinkcomp;
begin
 result:= tifibooleanlinkcomp(fifilink);
end;

procedure trowstatebooleanhandler.setifilink(const avalue: tifibooleanlinkcomp);
begin
 inherited setifilink(avalue);
end;

{ trowstatecolorhandler }

procedure trowstatecolorhandler.updateclient(const alink: pointer);
begin
 with iifigridlink(alink) do begin
  with getrowstate do begin
   if findexpar < 0 then begin
    colorar:= tintegerdatalist(flistlink.source).asarray;
   end
   else begin
    color[findexpar]:= tintegerdatalist(flistlink.source)[findexpar];
   end;
   rowchanged(findexpar);
  end;
 end;
end;

procedure trowstatecolorhandler.updateremote(const sender: tcustomrowstatelist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  tintegerdatalist(flistlink.source).asarray:= sender.colorar;
 end
 else begin
  tintegerdatalist(flistlink.source)[aindex]:= sender.color[aindex];
 end;
end;

{ trowstatefonthandler }

procedure trowstatefonthandler.updateclient(const alink: pointer);
begin
 with iifigridlink(alink) do begin
  with getrowstate do begin
   if findexpar < 0 then begin
    fontar:= tintegerdatalist(flistlink.source).asarray;
   end
   else begin
    font[findexpar]:= tintegerdatalist(flistlink.source)[findexpar];
   end;
   rowchanged(findexpar);
  end;
 end;
end;

procedure trowstatefonthandler.updateremote(const sender: tcustomrowstatelist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  tintegerdatalist(flistlink.source).asarray:= sender.fontar;
 end
 else begin
  tintegerdatalist(flistlink.source)[aindex]:= sender.font[aindex];
 end;
end;

{ trowstatefoldlevelhandler }

procedure trowstatefoldlevelhandler.updateclient(const alink: pointer);
begin
 with iifigridlink(alink) do begin
  with getrowstate do begin
   if findexpar < 0 then begin
    foldlevelar:= tintegerdatalist(flistlink.source).asarray;
   end
   else begin
    foldlevel[findexpar]:= tintegerdatalist(flistlink.source)[findexpar];
   end;
   rowchanged(findexpar);
   rowstatechanged(findexpar);
  end;
 end;
end;

procedure trowstatefoldlevelhandler.updateremote(const sender: tcustomrowstatelist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  tintegerdatalist(flistlink.source).asarray:= sender.foldlevelar;
 end
 else begin
  tintegerdatalist(flistlink.source)[aindex]:= sender.foldlevel[aindex];
 end;
end;

{ trowstatehiddenhandler }

procedure trowstatehiddenhandler.updateclient(const alink: pointer);
begin
 with iifigridlink(alink) do begin
  with getrowstate do begin
   if findexpar < 0 then begin
    hiddenar:= tbooleandatalist(flistlink.source).asarray;
   end
   else begin
    hidden[findexpar]:= tbooleandatalist(flistlink.source)[findexpar];
   end;
//   rowchanged(findexpar);
//   rowstatechanged(findexpar);
//   layoutchanged;
  end;
 end;
end;

procedure trowstatehiddenhandler.updateremote(const sender: tcustomrowstatelist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  tbooleandatalist(flistlink.source).asarray:= sender.hiddenar;
 end
 else begin
  tbooleandatalist(flistlink.source)[aindex]:= sender.hidden[aindex];
 end;
end;

{ trowstatehiddenhandler }

procedure trowstatefoldissumhandler.updateclient(const alink: pointer);
begin
 with iifigridlink(alink) do begin
  with getrowstate do begin
   if findexpar < 0 then begin
    foldissumar:= tbooleandatalist(flistlink.source).asarray;
   end
   else begin
    foldissum[findexpar]:= tbooleandatalist(flistlink.source)[findexpar];
   end;
//   rowchanged(findexpar);
//   rowstatechanged(findexpar);
//   layoutchanged;
  end;
 end;
end;

procedure trowstatefoldissumhandler.updateremote(const sender: tcustomrowstatelist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  tbooleandatalist(flistlink.source).asarray:= sender.foldissumar;
 end
 else begin
  tbooleandatalist(flistlink.source)[aindex]:= sender.foldissum[aindex];
 end;
end;

{ tgridclientcontroller }

constructor tgridclientcontroller.create(const aowner: tmsecomponent);
begin
 fdatacols:= tifilinkcomparrayprop.create;
 frowstatecolor:= trowstatecolorhandler.create(self);
 frowstatefont:= trowstatefonthandler.create(self);
 frowstatefoldlevel:= trowstatefoldlevelhandler.create(self);
 frowstatehidden:= trowstatehiddenhandler.create(self);
 frowstatefoldissum:= trowstatefoldissumhandler.create(self);
 inherited;
end;

destructor tgridclientcontroller.destroy;
begin
 fdatacols.free;
 frowstatecolor.free;
 frowstatefont.free;
 frowstatefoldlevel.free;
 frowstatehidden.free;
 frowstatefoldissum.free;
 inherited;
end;

procedure tgridclientcontroller.statreadrowstate(const alink: pointer);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  tstatreader(fitempo).readdatalist(rowstatevarname,list1);
 end;
end;

procedure tgridclientcontroller.dostatread(const reader: tstatreader);
var
 int1: integer;
 lico: tifivaluelinkcomp;
begin
 inherited;
 fitempo:= reader;
 tmsecomponent1(fowner).getobjectlinker.forall({$ifdef FPC}@{$endif}statreadrowstate,self);
 for int1:= 0 to datacols.count - 1 do begin
  lico:= datacols[int1].link;
  if lico <> nil then begin
   with lico.controller do begin
    if fstatfile = nil then begin
     dostatread(reader);
    end;
   end;
  end;
 end;
end;

procedure tgridclientcontroller.statwriterowstate(const alink: pointer;
                                           var handled: boolean);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  tstatwriter(fitempo).writedatalist(rowstatevarname,list1);
  handled:= true;
 end;
end;

procedure tgridclientcontroller.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
 lico: tifivaluelinkcomp;
begin
 inherited;
 fitempo:= writer;
 tmsecomponent1(fowner).getobjectlinker.forfirst({$ifdef FPC}@{$endif}statwriterowstate,self);
 for int1:= 0 to datacols.count - 1 do begin
  lico:= datacols[int1].link;
  if lico <> nil then begin
   with lico.controller do begin
    if fstatfile = nil then begin
     dostatwrite(writer);
//     fitempo:= writer;
//     tmsecomponent1(fowner).getobjectlinker.forfirst(
//                                        @statwritelist,lico.controller); 
    end;
   end;
  end;
 end;
end;

procedure tgridclientcontroller.setrowcount(const avalue: integer);
begin
 frowcount:= avalue;
 change;
end;

procedure tgridclientcontroller.valuestoclient(const alink: pointer);
begin
 setintegerval(iifigridlink(alink),'rowcount',frowcount);
 inherited;
end;

procedure tgridclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getintegerval(iifigridlink(alink),'rowcount',frowcount);
end;

procedure tgridclientcontroller.docellevent(var info: ificelleventinfoty);
begin
 if fowner.canevent(tmethod(foncellevent)) then begin
  foncellevent(self,info);
 end;
end;

procedure tgridclientcontroller.dorowsinserting(var index: integer;
               var count: integer; const userinput: boolean);
begin
 if fowner.canevent(tmethod(fonrowsinserting)) then begin
  fonrowsinserting(self,index,count,userinput);
 end;
end;

procedure tgridclientcontroller.dorowsinserted(const index: integer;
               const count: integer; const userinput: boolean);
begin
 if fowner.canevent(tmethod(fonrowsinserted)) then begin
  fonrowsinserted(self,index,count,userinput);
 end;
end;

procedure tgridclientcontroller.dorowsdeleting(var index: integer;
               var count: integer; const userinput: boolean);
begin
 if fowner.canevent(tmethod(fonrowsdeleting)) then begin
  fonrowsdeleting(self,index,count,userinput);
 end;
end;

procedure tgridclientcontroller.dorowsdeleted(const index: integer;
               const count: integer; const userinput: boolean);
begin
 if fowner.canevent(tmethod(fonrowsdeleted)) then begin
  fonrowsdeleted(self,index,count,userinput);
 end;
end;

function tgridclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifigridlink);
end;

procedure tgridclientcontroller.setdatacols(const avalue: tifilinkcomparrayprop);
begin
 fdatacols.assign(avalue);
end;

procedure tgridclientcontroller.itemappendrow(const alink: pointer);
begin
 iifigridlink(alink).appendrow(fcheckautoappend);
end;

procedure tgridclientcontroller.getrowstate1(const alink: pointer;
                                                  var handled: boolean);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  handled:= true;
  pdatalist(fitempo)^:= list1;
 end;
end;

function tgridclientcontroller.getrowstate: tcustomrowstatelist;
begin
 result:= nil;
 fitempo:= @result;
 tmsecomponent1(fowner).getobjectlinker.forfirst({$ifdef FPC}@{$endif}getrowstate1,self);
end;

procedure tgridclientcontroller.appendrow(const avalues: array of const;
                                        const checkautoappend: boolean = false);
var
 int1,int2: integer;
 comp1: tifilinkcomp;
begin
 fcheckautoappend:= checkautoappend;
 tmsecomponent1(fowner).getobjectlinker.forall({$ifdef FPC}@{$endif}itemappendrow,self);
 int2:= high(avalues);
 if int2 >= datacols.count then begin
  int2:= datacols.count;
 end;
 for int1:= 0 to int2 do begin
  comp1:= tificolitem(fdatacols.fitems[int1]).link;
  if comp1 <> nil then begin
   with avalues[int1] do begin
    case vtype of
     vtstring: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= msestring(vstring^);
        end;
       end;
      end;
     end;
     vtansistring: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= msestring(ansistring(vansistring));
        end;
       end;
      end;
     end;
    {$ifdef mse_hasvtunicodestring}
     vtunicodestring: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= unicodestring(vunicodestring);
        end;
       end;
      end;
     end;
    {$endif}
     vtwidestring: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= widestring(vwidestring);
        end;
       end;
      end;
     end;
     vtpchar: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= msestring(ansistring(vpchar));
        end;
       end;
      end;
     end;
     vtpwidechar: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= msestring(vpwidechar);
        end;
       end;
      end;
     end;
     vtchar: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= msestring(vchar);
        end;
       end;
      end;
     end;
     vtwidechar: begin
      if comp1 is tifistringlinkcomp then begin
       with tifistringlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= vwidechar;
        end;
       end;
      end;
     end;
     vtboolean: begin
      if comp1 is tifibooleanlinkcomp then begin
       with tifibooleanlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= longbool(vboolean);
        end;
       end;
      end;
     end;
     vtinteger: begin
      if comp1 is tifiintegerlinkcomp then begin
       with tifiintegerlinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= vinteger;
        end;
       end;
      end;
     end;
     vtextended: begin
      if comp1 is tifireallinkcomp then begin
       with tifireallinkcomp(comp1).controller do begin
        if fdatalist <> nil then begin
         griddata[fdatalist.count-1]:= vextended^;
        end;
       end;
      end
      else begin
       if comp1 is tifidatetimelinkcomp then begin
        with tifidatetimelinkcomp(comp1).controller do begin
         if fdatalist <> nil then begin
          griddata[fdatalist.count-1]:= vextended^;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tgridclientcontroller.rowempty(const arow: integer): boolean;
var
 int1: integer;
 link1: tifivaluelinkcomp;
begin
 result:= true;
 if arow >= 0 then begin
  for int1:= 0 to high(datacols.fitems) do begin
   link1:= tificolitem(datacols.fitems[int1]).link;
   if link1 <> nil then begin
    with link1.controller.datalist do begin
     if (arow < count) and not empty(arow) then begin
      result:= false;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tgridclientcontroller.getrowstate_color: tifiintegerlinkcomp;
begin
 result:= frowstatecolor.ifilink;
end;

procedure tgridclientcontroller.setrowstate_color(const avalue: tifiintegerlinkcomp);
begin
 frowstatecolor.ifilink:= avalue;
end;

function tgridclientcontroller.getrowstate_font: tifiintegerlinkcomp;
begin
 result:= frowstatefont.ifilink;
end;

procedure tgridclientcontroller.setrowstate_font(
                                            const avalue: tifiintegerlinkcomp);
begin
 frowstatefont.ifilink:= avalue;
end;

function tgridclientcontroller.getrowstate_foldlevel: tifiintegerlinkcomp;
begin
 result:= frowstatefoldlevel.ifilink;
end;

procedure tgridclientcontroller.setrowstate_foldlevel(
                                            const avalue: tifiintegerlinkcomp);
begin
 frowstatefoldlevel.ifilink:= avalue;
end;

function tgridclientcontroller.getrowstate_hidden: tifibooleanlinkcomp;
begin
 result:= frowstatehidden.ifilink;
end;

procedure tgridclientcontroller.setrowstate_hidden(
                                           const avalue: tifibooleanlinkcomp);
begin
 frowstatehidden.ifilink:= avalue;
end;

function tgridclientcontroller.getrowstate_foldissum: tifibooleanlinkcomp;
begin
 result:= frowstatefoldissum.ifilink;
end;

procedure tgridclientcontroller.setrowstate_foldissum(
                                           const avalue: tifibooleanlinkcomp);
begin
 frowstatefoldissum.ifilink:= avalue;
end;

function tgridclientcontroller.checkcomponent(const aintf: iifilink): pointer;
begin
 result:= inherited checkcomponent(aintf);
 iifigridlink(aintf).getrowstate.linkclient(idatalistclient(self));
end;

procedure tgridclientcontroller.itemchanged(const sender: tdatalist;
               const aindex: integer);
begin
 if not (gcs_itemchangelock in fgridstate) then begin
  include(fgridstate,gcs_itemchangelock);
  try
   frowstatecolor.itemchanged(tcustomrowstatelist(sender),aindex);
   frowstatefont.itemchanged(tcustomrowstatelist(sender),aindex);
   frowstatefoldlevel.itemchanged(tcustomrowstatelist(sender),aindex);
   frowstatehidden.itemchanged(tcustomrowstatelist(sender),aindex);
   frowstatefoldissum.itemchanged(tcustomrowstatelist(sender),aindex);
  finally
   exclude(fgridstate,gcs_itemchangelock);
  end;
 end;
end;

procedure tgridclientcontroller.canclose1(const alink: pointer;
                                                  var handled: boolean);
begin
 pboolean(fitempo)^:= iifigridlink(alink).canclose1;
 handled:= not pboolean(fitempo)^;
end;

function tgridclientcontroller.canclose: boolean;
begin
 result:= true;
 fitempo:= @result;
 tmsecomponent1(fowner).getobjectlinker.forfirst(
                                    {$ifdef FPC}@{$endif}canclose1,self);
end;

{ tformclientcontroller }

procedure tformclientcontroller.setmodalresult(const avalue: modalresultty);
begin
 fmodalresult:= avalue;
 change(nil);
end;

function tformclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iififormlink);
end;

procedure tformclientcontroller.linkset(const alink: iificlient);
begin
 //do nothing
end;

procedure tformclientcontroller.valuestoclient(const alink: pointer);
begin
 iififormlink(alink).setmodalresult(fmodalresult);
end;

procedure tformclientcontroller.sendmodalresult(const sender: iificlient;
               const amodalresult: modalresultty);
begin
 fmodalresult:= amodalresult;
 inherited;
end;

end.
