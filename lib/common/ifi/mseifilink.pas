{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifilink;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 classes,mseclasses,mseifiglob,mseifi,msearrayprops,mseapplication,mseact,
 mseevent,mseglob,msestrings,msetypes,msedatalist,msegraphutils,typinfo;
 
const
 ifidatatypes = [dl_integer,dl_int64,dl_currency,dl_real,
                 dl_msestring,dl_ansistring,dl_msestringint];
 
type
 tmodulelinkarrayprop = class;
 
 tmodulelinkprop = class(townedeventpersistent)
  private
   fprop: tmodulelinkarrayprop;
   fname: ansistring;
   ftag: integer;
  protected
   procedure inititemheader(out arec: string;
                  const akind: ifireckindty; const asequence: sequencety;
                  const datasize: integer;
                  out datapo: pchar); virtual;
  public
   property prop: tmodulelinkarrayprop read fprop;
  published
   property name: ansistring read fname write fname;
   property tag: integer read ftag write ftag default 0;
 end;
 modulelinkpropclassty = class of tmodulelinkprop;
   
 tcustommodulelink = class;

 tmodulelinkarrayprop = class(tpersistentarrayprop)
  private
   fowner: tcustommodulelink;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   function getitemclass: modulelinkpropclassty; virtual; abstract;
  public
   constructor create(const aowner: tcustommodulelink);
   function finditem(const aname: string): tmodulelinkprop;
   function byname(const aname: string): tmodulelinkprop;
   property owner: tcustommodulelink read fowner;
 end; 
 
 tlinkaction = class(tmodulelinkprop)
  private
   faction: tcustomaction;
   procedure setaction(const avalue: tcustomaction);
  protected
  public
   destructor destroy; override;
  published
   property action: tcustomaction read faction write setaction;
 end;

 trxlinkaction = class;
  
 ifiexecuteeventty = procedure(const sender: trxlinkaction; const atag: integer;
                                 const aparams: variant) of object;
                                 
 trxlinkaction = class(tlinkaction)
  private
   fonexecute: ifiexecuteeventty;
  published
   property onexecute: ifiexecuteeventty read fonexecute write fonexecute;
               //sender = item, avalue = tx tag
 end;

 iifitxaction = interface(inullinterface)
                          ['{70ECD758-7388-4205-BA70-7DC95B660C5F}']
  procedure txactionfired(var adata: ansistring; var adatapo: pchar);
 end; 

 ttxlinkaction = class(tlinkaction)
  private
   fificomp: tcomponent;
   fificompintf: iifitxaction;
   procedure setificomp(const avalue: tcomponent);
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  public
   procedure execute;
  published
   property ificomp: tcomponent read fificomp write setificomp;
 end;
 
 tlinkactions = class(tmodulelinkarrayprop)
  private
  protected
  public
 end;

 trxlinkactions = class(tlinkactions)
  private
   fonexecute: ifiexecuteeventty;
   function getitems(const index: integer): trxlinkaction;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): trxlinkaction;
   property items[const index: integer]: trxlinkaction read getitems; default;
  published
   property onexecute: ifiexecuteeventty read fonexecute write fonexecute;
               //sender = item, avalue = tx tag
 end;

 ttxlinkactions = class;
 
 ttxactiondestroyhandler = class(tcomponent)
  private
   fowner: ttxlinkactions;
  protected
   procedure notification(acomponent: tcomponent;
                           operation: toperation); override;
  public
   constructor create(aowner: ttxlinkactions); reintroduce;
 end;
  
 ttxlinkactions = class(tlinkactions)
  private
   fdestroyhandler: ttxactiondestroyhandler;
   function getitems(const index: integer): ttxlinkaction;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   destructor destroy; override;
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): ttxlinkaction;
   property items[const index: integer]: ttxlinkaction read getitems; default;
 end;

 tlinkmodule = class(tmodulelinkprop)
 end;
 
 ttxlinkmodule = class(tlinkmodule)
  private
   fmoduleclassname: string;
   fmoduleparentclassname: string;
  public
   procedure sendmodule;
   procedure close;
  published
   property moduleclassname: string read fmoduleclassname write fmoduleclassname;
   property moduleparentclassname: string read fmoduleparentclassname 
                            write fmoduleparentclassname;
 end;
  
 ttxlinkmodules = class(tmodulelinkarrayprop)
  private
   function getitems(const index: integer): ttxlinkmodule;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): ttxlinkmodule;
   property items[const index: integer]: ttxlinkmodule read getitems; default;   
 end;

 trxlinkmodule = class;
 rxlinkmoduleeventty = procedure(sender: trxlinkmodule) of object;

 trxlinkmodule = class(tlinkaction)
  private
   fmodule: tmsecomponent;
   fcommandintf: iificommand;
   fonmodulereceived: rxlinkmoduleeventty;
   fsequence: sequencety;
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  public
   procedure requestmodule;
   property module: tmsecomponent read fmodule;
  published
   property onmodulereceived: rxlinkmoduleeventty read fonmodulereceived 
                         write fonmodulereceived;
 end;
  
 trxlinkmodules = class(tmodulelinkarrayprop)
  private
   function getitems(const index: integer): trxlinkmodule;
  protected
   function finditem(const asequence: sequencety): trxlinkmodule; overload;
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): trxlinkmodule;
   property items[const index: integer]: trxlinkmodule read getitems; default;   
 end;

 tvaluelink = class;
 
 propertychangedeventty = procedure(const sender: tvaluelink;
                 const atag: integer; const apropertyname: string) of object;
 widgetstatechangedeventty = procedure(const sender: tvaluelink;
                 const atag: integer; const astate: ifiwidgetstatesty) of object;
 modalresulteventty = procedure(const sender: tvaluelink;
                 const atag: integer; const amodalresult: modalresultty) of object;

//todo: beginupdate/endupdate
 tvaluelink = class(tmodulelinkprop)
  private
   fint64value: int64;
   fdoublevalue: double;
   fmsestringvalue: msestring;
//   fansistringvalue: ansistring;
   fdatakind: ifidatakindty;
   fonpropertychanged: propertychangedeventty;
   fonwidgetstatechanged: widgetstatechangedeventty;
   fonmodalresult: modalresulteventty;
   procedure checkdatakind(const akind: ifidatakindty);
   function getasinteger: integer;
   procedure setasinteger(const avalue: integer);
   function getaslargeint: int64;
   procedure setaslargeint(const avalue: int64);
   function getasfloat: double;
   procedure setasfloat(const avalue: double);
   function getasmsestring: msestring;
   procedure setasmsestring(const avalue: msestring);
   function getasansistring: ansistring;
   procedure setasansistring(const avalue: ansistring);
   procedure setenabled(const avalue: boolean);
   procedure setvisible(const avalue: boolean);
  protected
   procedure setdata(const adata: pifidataty; const aname: ansistring); virtual;
   procedure initpropertyrecord(out arec: string; const apropertyname: string;
       const akind: ifidatakindty; const datasize: integer; out datapo: pchar);
   procedure sendvalue(const aname: string; const avalue: int64); overload;
   procedure sendvalue(const aname: string; const avalue: double); overload;
   procedure sendvalue(const aname: string; const avalue: msestring); overload;
   procedure sendvalue(const aname: string; const avalue: ansistring); overload;
   procedure sendcommand(const acommand: ifiwidgetcommandty);
  public
   procedure sendproperty(const aname: string; const avalue: boolean); overload;
   procedure sendproperty(const aname: string; const avalue: integer); overload;
   procedure sendproperty(const aname: string; const avalue: colorty); overload;
   procedure sendproperty(const aname: string; const avalue: int64); overload;
   procedure sendproperty(const aname: string; const avalue: string); overload;
   procedure sendproperty(const aname: string; const avalue: msestring); overload;
   procedure sendproperty(const aname: string; const avalue: realty); overload;
   procedure sendproperty(const aname: string; const avalue: currency); overload;

   property asinteger: integer read getasinteger write setasinteger;
   property aslargeint: int64 read getaslargeint write setaslargeint;
   property asfloat: double read getasfloat write setasfloat;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property asstring: string read getasansistring write setasansistring;
   property enabled: boolean write setenabled;
   property visible: boolean write setvisible;
  published
   property onpropertychanged: propertychangedeventty read fonpropertychanged 
                                     write fonpropertychanged;
   property onwidgetstatechanged: widgetstatechangedeventty
                        read fonwidgetstatechanged write fonwidgetstatechanged;
   property onmodalresult: modalresulteventty read fonmodalresult 
                        write fonmodalresult;
 end;

 tvaluelinks = class(tmodulelinkarrayprop) 
  private
   function getitems(const index: integer): tvaluelink;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): tvaluelink;
   property items[const index: integer]: tvaluelink read getitems; default;   
 end;

 tcustomvaluecomponentlink = class(tvaluelink)
  private
   procedure setcomponent(const avalue: tmsecomponent);
   procedure checkcomponent;
  protected
   fcomponent: tmsecomponent;
   fintf: iifiwidget;
   fvalueproperty: ppropinfo;
   fupdatelock: integer;
   procedure setdata(const adata: pifidataty; const aname: ansistring); override;
   procedure sendvalue(const aproperty: ppropinfo); overload;
   procedure sendstate(const astate: ifiwidgetstatesty);
   procedure sendmodalresult(const amodalresult: modalresultty);
  public
   procedure sendvalue(const aname: string; const avalue: colorty); overload;
   procedure sendproperties;
   property component: tmsecomponent read fcomponent write setcomponent;
 end; 

 tvaluecomponentlink = class(tcustomvaluecomponentlink)
  published
   property component;
 end;
 
 tvaluecomponentlinks = class(tvaluelinks)
  private
   function getitems(const index: integer): tvaluecomponentlink;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): tvaluecomponentlink;
   property items[const index: integer]: tvaluecomponentlink read getitems; default;   
 end;
 
 formlinkoptionty = (flo_useclientchannel);
 formlinkoptionsty = set of formlinkoptionty;
const
 defaultformlinkoptions = [flo_useclientchannel];
type 

 iifimodulelink = interface(inullinterface)
                          ['{90279F1E-E80F-4657-9531-3C3A2CF151BD}']
  procedure connectmodule(const sender: tcustommodulelink);
 end;
 
 tcustommodulelink = class(tifiiolinkcomponent,iifiserver,iifimodulelink)
  private
   factionsrx: trxlinkactions;
   factionstx: ttxlinkactions;
   fmodulestx: ttxlinkmodules;
   fmodulesrx: trxlinkmodules;
   foptions: formlinkoptionsty;
   flinkname: string;
   procedure setactionsrx(const avalue: trxlinkactions);
   procedure setactionstx(const avalue: ttxlinkactions);
   procedure setmodulestx(const avalue: ttxlinkmodules);
   procedure setmodulesrx(const avalue: trxlinkmodules);
   procedure setvalues(const avalue: tvaluelinks);
   procedure setvaluecomponents(const avalue: tvaluecomponentlinks);
  protected
   fvalues: tvaluelinks;
   fvaluecomponents: tvaluecomponentlinks;
   function hasconnection: boolean;
   function encodemodulecommand(const acommand: ificommandcodety;
               const atag: integer; const aname: string): string;
   procedure closemodule(const atag: integer; const aname: string);
   function encodeactionfired(const atag: integer; const aname: string;
                                  out adatapo: pchar): string;
   procedure actionfired(const sender: tlinkaction; 
                          const acompintf: iifitxaction); virtual;
   function actionreceived(const adata: pifirecty; var adatapo: pchar;
                  const atag: integer; const aname: string):boolean;
   function requestmodulereceived(const atag: integer; const aname: string;
                                    const asequence: sequencety): boolean;
   function modulecommandreceived(const atag: integer; const aname: string;
                   const adata: pmodulecommanddataty): boolean;
   function moduledatareceived(const atag: integer; const aname: string;
                   const asequence: sequencety;
                   const adata: pmoduledatadataty): boolean;
   procedure moduleloaded(const sender: tmsecomponent);
   function propertychangereceived(const atag: integer; const aname: string;
                      const apropertyname: string; const adata: pifidataty): boolean;

   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function processdataitem(const adata: pifirecty; var adatapo: pchar;
                  const atag: integer; const aname: string): boolean; virtual;
                //true if handled
   function processdata(const adata: pifirecty): boolean;
                //true if handled
   function senddata(const adata: ansistring): sequencety;
                //returns sequence number
   procedure receiveevent(const event: tobjectevent); override;
  //iifiserver
   procedure valuechanged(const sender: iifiwidget); virtual;
   procedure statechanged(const sender: iifiwidget;
                             const astate: ifiwidgetstatesty); virtual;
   procedure sendmodalresult(const sender: iifiwidget; 
                                         const amodalresult: modalresultty); virtual;
  //imodulelink
   procedure connectmodule(const sender: tcustommodulelink);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updatecomponent(const anamepath: ansistring;
                                const aobjecttext: ansistring);
   property linkname: string read flinkname write flinkname;
   property actionsrx: trxlinkactions read factionsrx write setactionsrx;
   property actionstx: ttxlinkactions read factionstx write setactionstx;
   property modulesrx: trxlinkmodules read fmodulesrx write setmodulesrx;
   property modulestx: ttxlinkmodules read fmodulestx write setmodulestx;
   property valuecomponents: tvaluecomponentlinks read fvaluecomponents 
                                                     write setvaluecomponents;
   property values: tvaluelinks read fvalues write setvalues;
   property options: formlinkoptionsty read foptions write foptions
                                      default defaultformlinkoptions;
 end;

 tmodulelink = class(tcustommodulelink)
  published
   property linkname;
   property actionsrx;
   property actionstx;
   property modulesrx;
   property modulestx;
   property values;
   property valuecomponents;
   property channel;
   property options;
 end;

 ifirxoptionty = (irxo_useclientchannel,irxo_postecho); 
 ifirxoptionsty = set of ifirxoptionty;

const 
 defaultifirxoptions = [irxo_useclientchannel];
 defaultifirxtimeout = 10000000; //10 second

type 
 tificontroller = class(tactivatorcontroller,iifimodulelink)
  private
   fchannel: tcustomiochannel;
   flinkname: string;
   ftag: integer;
   fdefaulttimeout: integer;
   procedure setchannel(const avalue: tcustomiochannel);
  protected
   foptions: ifirxoptionsty;
   procedure objectevent(const sender: tobject; const event: objecteventty);
                                                        override;   
   function senddata(const adata: ansistring; 
                         const asequence: sequencety = 0): sequencety;
   function senddataandwait(const adata: ansistring;
            out asequence: sequencety; atimeoutus: integer = 0): boolean;
   function senditem(const kind: ifireckindty; 
                               const data: array of ansistring): sequencety;
                //returns sequence number
   procedure inititemheader(out arec: string;
               const akind: ifireckindty; const asequence: sequencety; 
                const datasize: integer; out datapo: pchar);
   procedure processdata(const adata: pifirecty; var adatapo: pchar); 
                                    virtual; abstract;
   function getifireckinds: ifireckindsty; virtual;
   //iifimodulelink
   procedure connectmodule(const sender: tcustommodulelink);
  public
   constructor create(const aowner: tcomponent);
   function cansend: boolean;
  published
   property channel: tcustomiochannel read fchannel write setchannel;
   property linkname: string read flinkname write flinkname;
   property tag: integer read ftag write ftag default 0;
   property options: ifirxoptionsty read foptions write foptions 
                                       default defaultifirxoptions;
   property timeoutus: integer read fdefaulttimeout write fdefaulttimeout 
                       default defaultifirxtimeout;
 end;

 tifirxcontroller = class(tificontroller)
 end;
 tifitxcontroller = class(tificontroller)
 end;

 tifidatacol = class(townedpersistent)
  private
   fdatalist: tdatalist;
   fdatakind: ifidatakindty;
   fname: ansistring;
   procedure setdatakind(const avalue: ifidatakindty);
   function getdatalist: tdatalist;
   function getasinteger(const index: integer): integer;
   procedure setasinteger(const index: integer; const avalue: integer);
   function getasint64(const index: integer): int64;
   procedure setasint64(const index: integer; const avalue: int64);
   function getascurrency(const index: integer): currency;
   procedure setascurrency(const index: integer; const avalue: currency);
   function getasreal(const index: integer): real;
   procedure setasreal(const index: integer; const avalue: real);
   function getasmsestring(const index: integer): msestring;
   procedure setasmsestring(const index: integer; const avalue: msestring);
   function getasbytes(const index: integer): ansistring;
   procedure setasbytes(const index: integer; const avalue: ansistring);
   function getasmsestringint(const index: integer): msestringintty;
   procedure setasmsestringint(const index: integer; const avalue: msestringintty);
   function getasmsestringinti(const index: integer): integer;
   procedure setasmsestringinti(const index: integer; const avalue: integer);
   function getasmsestringints(const index: integer): msestring;
   procedure setasmsestringints(const index: integer; const avalue: msestring);
  protected
   procedure freedatalist;
   procedure checkdatalist; overload;
   procedure checkdatalist(const akind: ifidatakindty); overload;
  public
   destructor destroy; override;
   property datalist: tdatalist read getdatalist;
   property asinteger[const index: integer]: integer read getasinteger 
                               write setasinteger;
   property asint64[const index: integer]: int64 read getasint64 
                               write setasint64;
   property ascurrency[const index: integer]: currency read getascurrency 
                               write setascurrency;
   property asreal[const index: integer]: real read getasreal 
                               write setasreal;
   property asmsestring[const index: integer]: msestring read getasmsestring 
                               write setasmsestring;
   property asmsestringint[const index: integer]: msestringintty
                         read getasmsestringint write setasmsestringint;
   property asmsestringinti[const index: integer]: integer
                         read getasmsestringinti write setasmsestringinti;
   property asmsestringints[const index: integer]: msestring
                         read getasmsestringints write setasmsestringints;
   property asbytes[const index: integer]: ansistring read getasbytes 
                               write setasbytes;
  published
   property datakind: ifidatakindty read fdatakind write setdatakind 
                         default idk_none;
   property name: ansistring read fname write fname;
 end;
  
 ttxdatagrid = class;
 tifirowstatelist = class(tcustomrowstatelist)
 end;
    
 tifidatacols = class(townedpersistentarrayprop)
  private
   frowstate: tifirowstatelist;
   function getcols(const index: integer): tifidatacol;
   procedure setcols(const index: integer; const avalue: tifidatacol);
  public 
   constructor create(const aowner: ttxdatagrid);
   destructor destroy; override;
   class function getitemclasstype: persistentclassty; override;
   function colbyname(const aname: ansistring): tifidatacol;
   property rowstate: tifirowstatelist read frowstate;
   property cols[const index: integer]: tifidatacol read getcols write setcols;
                                                 default;
 end;
 
 ttxdatagridcontroller = class(tifitxcontroller)
  protected
   function getifireckinds: ifireckindsty; override;
   procedure setowneractive(const avalue: boolean); override;
   procedure processdata(const adata: pifirecty; var adatapo: pchar); 
                                    override;
   function encodegriddata(const asequence: sequencety): ansistring;
  public
   constructor create(const aowner: ttxdatagrid);
 end;

 ttxdatagrid = class(tmsecomponent)
  private
   fifi: ttxdatagridcontroller;
   fdatacols: tifidatacols;
   frowcount: integer;
   
   procedure setifi(const avalue: ttxdatagridcontroller);
   procedure setdatacols(const avalue: tifidatacols);
   procedure setrowcount(const avalue: integer);
   function getrowhigh: integer;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property rowhigh: integer read getrowhigh;
//   property 
  published
   property ifi: ttxdatagridcontroller read fifi write setifi;
   property datacols: tifidatacols read fdatacols write setdatacols;
   property rowcount: integer read frowcount write setrowcount default 0;
 end;
   
function ifidatatodatalist(const akind: datatypty; const arowcount: integer;
                       const adata: pchar; const adatalist: tdatalist): integer;
       //returns datasize
function datalisttoifidata(const adatalist: tdatalist): integer; overload;
procedure datalisttoifidata(const adatalist: tdatalist;
                                         var dest: pchar); overload;
implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules;

type
 tmoduledataevent = class(tstringobjectevent)
  protected
   fmodulelink: trxlinkmodule;
   fmoduledata: pmoduledatadataty;
  public
   constructor create(const adata: ansistring; const dest: ievent;
        const amodulelink: trxlinkmodule; const amoduledata: pmoduledatadataty);
 end;
 
{ tmodulelinkprop }

procedure tmodulelinkprop.inititemheader(out arec: string;
               const akind: ifireckindty; const asequence: sequencety; 
               const datasize: integer; out datapo: pchar);
begin
 mseifi.inititemheader(ftag,fname,arec,akind,asequence,datasize,datapo);
end;

{ tlinkaction }

destructor tlinkaction.destroy;
begin
 action:= nil;
 inherited;
end;

procedure tlinkaction.setaction(const avalue: tcustomaction);
begin
 setlinkedvar(avalue,faction);
end;

{ trxlinkaction }

{ ttxlinkaction }
 
procedure ttxlinkaction.execute;
begin
 tcustommodulelink(fowner).actionfired(self,fificompintf);
end;

procedure ttxlinkaction.objectevent(const sender: tobject;
                                          const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  execute;
 end;
end;

procedure ttxlinkaction.setificomp(const avalue: tcomponent);
begin
 if fificomp <> nil then begin
  ttxlinkactions(prop).fdestroyhandler.removefreenotification(fificomp);
 end;
 fificomp:= avalue;
 if fificomp <> nil then begin
  ttxlinkactions(prop).fdestroyhandler.freenotification(fificomp);
  mseclasses.getcorbainterface(fificomp,typeinfo(iifitxaction),fificompintf);
 end
 else begin
  fificompintf:= nil;
 end;
end;

{ tmodulelinkarrayprop }

constructor tmodulelinkarrayprop.create(const aowner: tcustommodulelink);
begin
 fowner:= aowner;
 inherited create(getitemclass);
end;

procedure tmodulelinkarrayprop.createitem(const index: integer; var item: tpersistent);
begin
 item:= modulelinkpropclassty(fitemclasstype).create(fowner);
 tmodulelinkprop(item).fprop:= self;
end;

function tmodulelinkarrayprop.finditem(const aname: string): tmodulelinkprop;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if tmodulelinkprop(fitems[int1]).fname = aname then begin
   result:= tmodulelinkprop(fitems[int1]);
   exit;
  end;
 end;
end;

function tmodulelinkarrayprop.byname(const aname: string): tmodulelinkprop;
begin
 result:= finditem(aname);
 if result = nil then begin
  raise exception.create(fowner.name+': array property "'+aname+'" not found.');
 end;
end;

{ trxlinkactions }

constructor trxlinkactions.create(const aowner: tcustommodulelink);
begin
 inherited create(aowner);
end;

class function trxlinkactions.getitemclasstype: persistentclassty;
begin
 result:= trxlinkaction;
end;

function trxlinkactions.getitems(const index: integer): trxlinkaction;
begin
 result:= trxlinkaction(inherited getitems(index));
end;

function trxlinkactions.byname(const aname: string): trxlinkaction;
begin
 result:= trxlinkaction(inherited byname(aname));
end;

function trxlinkactions.getitemclass: modulelinkpropclassty;
begin
 result:= trxlinkaction;
end;

{ ttxactiondestroyhandler }

constructor ttxactiondestroyhandler.create(aowner: ttxlinkactions);
begin
 fowner:= aowner;
 inherited create(nil);
end;

procedure ttxactiondestroyhandler.notification(acomponent: tcomponent;
               operation: toperation);
var
 int1: integer;
begin
 inherited;
 if operation = opremove then begin
  with fowner do begin
   for int1:= 0 to high(fitems) do begin
    with ttxlinkaction(fitems[int1]) do begin
     if acomponent = fificomp then begin
      fificomp:= nil;
      fificompintf:= nil;
     end;
    end;
   end;    
  end;
 end;
end;

{ ttxlinkactions }

constructor ttxlinkactions.create(const aowner: tcustommodulelink);
begin
 fdestroyhandler:= ttxactiondestroyhandler.create(self);
 inherited create(aowner);
end;

destructor ttxlinkactions.destroy;
begin
 inherited;
 fdestroyhandler.destroy;
end;

class function ttxlinkactions.getitemclasstype: persistentclassty;
begin
 result:= ttxlinkaction;
end;

function ttxlinkactions.getitems(const index: integer): ttxlinkaction;
begin
 result:= ttxlinkaction(inherited getitems(index));
end;

function ttxlinkactions.byname(const aname: string): ttxlinkaction;
begin
 result:= ttxlinkaction(inherited byname(aname));
end;

function ttxlinkactions.getitemclass: modulelinkpropclassty;
begin
 result:= ttxlinkaction;
end;

{ ttxlinkmodules }

constructor ttxlinkmodules.create(const aowner: tcustommodulelink);
begin
 inherited create(aowner);
end;

class function ttxlinkmodules.getitemclasstype: persistentclassty;
begin
 result:= ttxlinkmodule;
end;

function ttxlinkmodules.getitems(const index: integer): ttxlinkmodule;
begin
 result:= ttxlinkmodule(inherited getitems(index));
end;

function ttxlinkmodules.byname(const aname: string): ttxlinkmodule;
begin
 result:= ttxlinkmodule(inherited byname(aname));
end;

function ttxlinkmodules.getitemclass: modulelinkpropclassty;
begin
 result:= ttxlinkmodule;
end;

{ trxlinkmodule }

procedure trxlinkmodule.requestmodule;
var
 str1: string;
 po1: pchar;
begin
 inititemheader(str1,ik_requestmodule,0,0,po1);
 fsequence:= tcustommodulelink(fowner).senddata(str1);
end;

procedure trxlinkmodule.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  requestmodule;
 end;
end;

{ trxlinkmodules }

constructor trxlinkmodules.create(const aowner: tcustommodulelink);
begin
 inherited create(aowner);
end;

class function trxlinkmodules.getitemclasstype: persistentclassty;
begin
 result:= trxlinkmodule;
end;

function trxlinkmodules.getitems(const index: integer): trxlinkmodule;
begin
 result:= trxlinkmodule(inherited getitems(index));
end;

function trxlinkmodules.byname(const aname: string): trxlinkmodule;
begin
 result:= trxlinkmodule(inherited byname(aname));
end;

function trxlinkmodules.finditem(const asequence: sequencety): trxlinkmodule;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  if trxlinkmodule(fitems[int1]).fsequence = asequence then begin
   result:= trxlinkmodule(fitems[int1]);
   exit;
  end;
 end;
 result:= nil;
end;

function trxlinkmodules.getitemclass: modulelinkpropclassty;
begin
 result:= trxlinkmodule;
end;

{ tvaluelink }

procedure tvaluelink.sendvalue(const aname: string; const avalue: int64);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_int64,0,po1); 
 pint64(po1)^:= avalue;
 tcustommodulelink(fowner).senddata(str1);
end;

procedure tvaluelink.sendvalue(const aname: string; const avalue: double);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_real,0,po1);
 pdouble(po1)^:= avalue;
 tcustommodulelink(fowner).senddata(str1);
end;

procedure tvaluelink.sendvalue(const aname: string; const avalue: msestring);
var
 str1,str2: string;
 po1: pchar;
begin
 str2:= stringtoutf8(avalue);
 initpropertyrecord(str1,aname,idk_msestring,length(str2),po1);
 stringtoifiname(str2,pifinamety(po1));
 tcustommodulelink(fowner).senddata(str1);
end;

procedure tvaluelink.sendvalue(const aname: string; const avalue: ansistring);
begin
 sendvalue(aname,msestring(avalue));
end;
{
procedure tvaluelink.sendvalue(const aname: string; const avalue: ansistring);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_ansistring,length(avalue),po1);
 stringtoifiname(avalue,pifinamety(po1));
 tcustommodulelink(fowner).senddata(str1);
end;
}
procedure tvaluelink.initpropertyrecord(out arec: string;
          const apropertyname: string; const akind: ifidatakindty;
          const datasize: integer; out datapo: pchar);
var
 po1: pchar; 
begin
 inititemheader(arec,ik_propertychanged,0,datarecsizes[akind]+
                length(apropertyname)+datasize,po1);
       
 inc(po1,stringtoifiname(apropertyname,pifinamety(po1)));
 pifidataty(po1)^.header.kind:= akind;
 datapo:= po1 + sizeof(ifidataty.header);
end;

procedure tvaluelink.sendcommand(const acommand: ifiwidgetcommandty);
var
 str1: string;
 po1: pchar;
begin
 inititemheader(str1,ik_widgetcommand,0,0,po1);
 pifiwidgetcommandty(po1)^:= acommand;
 tcustommodulelink(fowner).senddata(str1);
end;

procedure tvaluelink.setdata(const adata: pifidataty; const aname: ansistring);
var
 str1: string;
begin
 with adata^ do begin
  fdatakind:= header.kind;
  case fdatakind of
   idk_int64: begin
    fint64value:= pint64(@data)^;
   end;
   idk_real: begin
    fdoublevalue:= pdouble(@data)^;
   end;
   idk_msestring: begin
    ifinametostring(pifinamety(@data),str1);
    fmsestringvalue:= utf8tostring(str1);
   end;
  end;
 end;
end;

procedure tvaluelink.checkdatakind(const akind: ifidatakindty);
begin
 if fdatakind <> akind then begin
  raise exception.create('Invalid datakind');
 end;
end;

function tvaluelink.getasinteger: integer;
begin
 checkdatakind(idk_int64);
 result:= fint64value;
end;

procedure tvaluelink.setasinteger(const avalue: integer);
begin
 setaslargeint(avalue);
end;

function tvaluelink.getaslargeint: int64;
begin
 checkdatakind(idk_int64);
 result:= fint64value;
end;

procedure tvaluelink.setaslargeint(const avalue: int64);
begin
 fdatakind:= idk_int64;
 fint64value:= avalue;
 sendvalue('value',fint64value);
end;

function tvaluelink.getasfloat: double;
begin
 checkdatakind(idk_real);
 result:= fdoublevalue;
end;

procedure tvaluelink.setasfloat(const avalue: double);
begin
 fdatakind:= idk_real;
 fdoublevalue:= avalue;
 sendvalue('value',fdoublevalue);
end;

function tvaluelink.getasmsestring: msestring;
begin
 checkdatakind(idk_msestring);
 result:= fmsestringvalue;
{
 if fdatakind = idk_ansistring then begin
  result:= fansistringvalue;
 end
 else begin
  checkdatakind(idk_msestring);
  result:= fmsestringvalue;
 end;
 }
end;

procedure tvaluelink.setasmsestring(const avalue: msestring);
begin
 fdatakind:= idk_msestring;
 fmsestringvalue:= avalue;
 sendvalue('value',fmsestringvalue);
end;

function tvaluelink.getasansistring: ansistring;
begin
 result:= getasmsestring;
 {
 if fdatakind = idk_msestring then begin
  result:= fmsestringvalue;
 end
 else begin
  checkdatakind(idk_ansistring);
  result:= fansistringvalue;
 end;
 }
end;

procedure tvaluelink.setasansistring(const avalue: ansistring);
begin
 setasmsestring(avalue);
 {
 fdatakind:= idk_ansistring;
 fansistringvalue:= avalue;
 sendvalue('value',fansistringvalue);
 }
end;

procedure tvaluelink.setenabled(const avalue: boolean);
begin
 if avalue then begin
  sendcommand(iwc_enable);
 end
 else begin
  sendcommand(iwc_disable);
 end;
end;

procedure tvaluelink.setvisible(const avalue: boolean);
begin
 if avalue then begin
  sendcommand(iwc_show);
 end
 else begin
  sendcommand(iwc_hide);
 end;
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: boolean);
var
 int1: integer;
begin
 int1:= 0;
 if avalue then begin
  int1:= -1;
 end;
 sendvalue(aname,int1);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: integer);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: colorty);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: int64);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: string);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: msestring);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: realty);
begin
 sendvalue(aname,avalue);
end;

procedure tvaluelink.sendproperty(const aname: string; const avalue: currency);
begin
 sendvalue(aname,avalue);
end;

{ tvaluelinks }

class function tvaluelinks.getitemclasstype: persistentclassty;
begin
 result:= tvaluelink;
end;

function tvaluelinks.getitems(const index: integer): tvaluelink;
begin
 result:= tvaluelink(inherited getitems(index));
end;

function tvaluelinks.byname(const aname: string): tvaluelink;
begin
 result:= tvaluelink(inherited byname(aname));
end;

function tvaluelinks.getitemclass: modulelinkpropclassty;
begin
 result:= tvaluelink;
end;

{ tcustomvaluecomponentlink }

procedure tcustomvaluecomponentlink.setcomponent(const avalue: tmsecomponent);
begin
 setlinkedvar(avalue,fcomponent);
 if avalue <> nil then begin
  fvalueproperty:= getpropinfo(avalue,'value');
 end;
end;

procedure tcustomvaluecomponentlink.checkcomponent;
begin
 if fcomponent = nil then begin
  exception.create(tcustommodulelink(fowner).name+': No component.');
 end;
end;

function getnestedpropinfo(var ainstance: tobject; 
                            apropname: pchar; out aindex: integer;
                            out arraypropkind: arraypropkindty): ppropinfo;
var
 po1,po2: pchar;
 prop1: ppropinfo;
 index1: integer;
begin
 result:= nil;
 po1:= apropname;
 index1:= -1;
 arraypropkind:= apk_none;
 while po1^ <> #0 do begin
  if po1^ = '.' then begin
   break;
  end;
  if po1^ = '[' then begin
   po2:= po1+1;
   while (po2^ <> ']') and (po2^ <> #0) do begin
    inc(po2);
   end;
   if po2^ <> #0 then begin
    if not trystrtoint(psubstr(po1+1,po2),index1) then begin
     index1:= -1;
    end;
    inc(po2);
   end;
   break;
  end;
  inc(po1);
 end;
 if po1 <> apropname then begin
  result:= getpropinfo(ainstance,psubstr(apropname,po1));
  if result <> nil then begin
   if result^.proptype^.kind = tkclass then begin
    ptruint(ainstance):= ptruint(getordprop(ainstance,result));
    prop1:= result;    
    result:= nil;
    if ainstance <> nil then begin
     if index1 >= 0 then begin
      if ainstance is tarrayprop then begin
       with tarrayprop(ainstance) do begin
        if index1 < count then begin
         arraypropkind:= propkind; 
         if arraypropkind = apk_tpersistent then begin
          ainstance:= tpersistentarrayprop(ainstance)[index1];
          if po2^ = '.' then begin
           result:= getnestedpropinfo(ainstance,po2+1,index1,arraypropkind);
          end;
         end
         else begin
          result:= prop1;
         end;
        end;
       end;
      end
     end
     else begin
      if (po1^ = '.') then begin
       result:= getnestedpropinfo(ainstance,po1+1,index1,arraypropkind);
      end
      else begin
       result:= nil;
      end;
     end;
    end;
   end;
  end;
 end;
 aindex:= index1;
end;

procedure tcustomvaluecomponentlink.setdata(const adata: pifidataty; 
                                               const aname: ansistring);
var
 aproperty: ppropinfo;
 instance: tobject;
 index1: integer;
 arraypropkind: arraypropkindty;
begin
 inherited;
 aproperty:= nil;
 instance:= fcomponent;
 with adata^ do begin
  if aname = 'value' then begin
   aproperty:= fvalueproperty;
   index1:= -1;
  end
  else begin
   if fcomponent <> nil then begin
    aproperty:= getnestedpropinfo(instance,pchar(aname),index1,arraypropkind);
   end;
  end;
  if (aproperty <> nil) and (instance <> nil) then begin
   inc(fupdatelock);
   try
    if index1 >= 0 then begin
     case arraypropkind of
      apk_integer,apk_colorty: begin
       tintegerarrayprop(instance)[index1]:= asinteger;
      end;
      apk_real: begin
       trealarrayprop(instance)[index1]:= asfloat;
      end;
      apk_string: begin
       tstringarrayprop(instance)[index1]:= asstring;
      end;
      apk_msestring: begin
       tmsestringarrayprop(instance)[index1]:= asmsestring;
      end;
      apk_boolean: begin
       tbooleanarrayprop(instance)[index1]:= asinteger <> 0;;
      end;
     end;
    end
    else begin
     case aproperty^.proptype^.kind of
      tkInteger,tkBool,tkInt64,tkset: begin
       setordprop(instance,aproperty,aslargeint);
      end;
      tkFloat: begin
       setfloatprop(instance,aproperty,asfloat);
      end;
      tkWString: begin
       setwidestrprop(instance,aproperty,asmsestring);
      end;
     {$ifdef mse_unicodestring}
      tkUString: begin
       setunicodestrprop(instance,aproperty,asmsestring);
      end;
     {$endif}
      tkSString,tkLString,tkAString: begin
       setstrprop(instance,aproperty,asstring);
      end;
     end;
    end;
   finally
    dec(fupdatelock);
   end;
  end;
 end;
end;

procedure tcustomvaluecomponentlink.sendvalue(const aproperty: ppropinfo);
begin
 if aproperty <> nil then begin
  case aproperty^.proptype^.kind of
   tkInteger,tkBool,tkInt64: begin
    sendvalue(aproperty^.name,getordprop(fcomponent,aproperty));
   end;
   tkFloat: begin
    sendvalue(aproperty^.name,double(getfloatprop(fcomponent,aproperty)));
   end;
  {$ifdef mse_unicodestring}
   tkUString: begin
    sendvalue(aproperty^.name,getunicodestrprop(fcomponent,aproperty));
   end;
  {$endif}
   tkWString: begin
    sendvalue(aproperty^.name,getwidestrprop(fcomponent,aproperty));
   end;
   tkSString,tkLString,tkAString: begin
    sendvalue(aproperty^.name,getstrprop(fcomponent,aproperty));
   end;
  end;
 end;
end;

procedure tcustomvaluecomponentlink.sendstate(const astate: ifiwidgetstatesty);
begin
 sendvalue(ifiwidgetstatename,integer(astate));
end;

procedure tcustomvaluecomponentlink.sendmodalresult(const amodalresult: modalresultty);
begin
 sendvalue(ifiwidgetmodalresultname,integer(amodalresult));
end;

procedure tcustomvaluecomponentlink.sendproperties;
var
 stream1: tmemorystream;
 str1: string;
 po1: pchar;
begin
 checkcomponent;
 stream1:= tmemorystream.create;
 try
  stream1.writecomponent(fcomponent);
  inititemheader(str1,ik_widgetproperties,0,stream1.size,po1);
  setifibytes(stream1.memory,stream1.size,pifibytesty(po1));
 finally
  stream1.free;
 end;
 tcustommodulelink(fowner).senddata(str1);
end;

procedure tcustomvaluecomponentlink.sendvalue(const aname: string;
               const avalue: colorty);
begin
 sendvalue(aname,int64(avalue));
end;

{ tvaluecomponentlinks }

class function tvaluecomponentlinks.getitemclasstype: persistentclassty;
begin
 result:= tvaluecomponentlink;
end;

function tvaluecomponentlinks.getitems(const index: integer): tvaluecomponentlink;
begin
 result:= tvaluecomponentlink(inherited getitems(index));
end;

function tvaluecomponentlinks.byname(const aname: string): tvaluecomponentlink;
begin
 result:= tvaluecomponentlink(inherited byname(aname));
end;

function tvaluecomponentlinks.getitemclass: modulelinkpropclassty;
begin
 result:= tvaluecomponentlink;
end;

{ tcustommodulelink }

constructor tcustommodulelink.create(aowner: tcomponent);
begin
 foptions:= defaultformlinkoptions;
 factionsrx:= trxlinkactions.create(self);
 factionstx:= ttxlinkactions.create(self);
 fmodulestx:= ttxlinkmodules.create(self);
 fmodulesrx:= trxlinkmodules.create(self);
 fvaluecomponents:= tvaluecomponentlinks.create(self);
 if fvalues = nil then begin
  fvalues:= tvaluelinks.create(self);
 end;
 inherited;
end;

destructor tcustommodulelink.destroy;
begin
 factionsrx.free;
 factionstx.free;
 fmodulesrx.free;
 fmodulestx.free;
 fvaluecomponents.free;
 fvalues.free;
 inherited;
end;

procedure tcustommodulelink.setactionsrx(const avalue: trxlinkactions);
begin
 factionsrx.assign(avalue);
end;

procedure tcustommodulelink.setactionstx(const avalue: ttxlinkactions);
begin
 factionstx.assign(avalue);
end;

procedure tcustommodulelink.updatecomponent(const anamepath: ansistring;
                                const aobjecttext: ansistring);
var
 comp1: tcomponent;
 stream1: tstringcopystream;
 stream2: tmemorystream;
begin
 comp1:= findcomponentbynamepath(anamepath);
 if comp1 = nil then begin
  raise exception.create('Component "'+anamepath+'" not found.');
 end;
 stream1:= tstringcopystream.create(aobjecttext);
 stream2:= tmemorystream.create;
 try
  objecttexttobinary(stream1,stream2);
  stream2.position:= 0;
  stream2.readcomponent(comp1);
 finally
  stream1.free;
  stream2.free;
 end;
end;

function tcustommodulelink.encodemodulecommand(const acommand: ificommandcodety;
               const atag: integer; const aname: string): string;
var
 po1: pchar;
begin
 initifirec(result,ik_modulecommand,0,length(aname),po1);
 with pmodulecommandty(po1)^ do begin
  with header do begin
   tag:= atag;
   po1:= @name;
   inc(po1,stringtoifiname(aname,@name));
  end;
 end;
 with pmodulecommanddataty(po1)^ do begin
  command:= acommand;
 end;
end;

procedure tcustommodulelink.closemodule(const atag: integer; const aname: string);
begin
 if fchannel <> nil then begin
  fchannel.senddata(encodemodulecommand(icc_close,atag,aname));
 end;
end;

procedure tcustommodulelink.actionfired(const sender: tlinkaction;
                                     const acompintf: iifitxaction);
var
 str1: string;
 po1: pchar;
begin
 if fchannel <> nil then begin
  str1:= encodeactionfired(sender.tag,sender.name,po1);
  if acompintf <> nil then begin
   acompintf.txactionfired(str1,po1);
  end;
  fchannel.senddata(str1);
 end;
end;

function tcustommodulelink.encodeactionfired(const atag: integer;
               const aname: string; out adatapo: pchar): string;
var
 po1: pchar;
begin
 initifirec(result,ik_actionfired,0,length(aname),po1);
 with pifirecty(result)^.actionfired.header do begin
  tag:= atag;
  adatapo:= @name;
  inc(adatapo,stringtoifiname(aname,pifinamety(adatapo)));
 end;
end;

procedure tcustommodulelink.objectevent(const sender: tobject;
               const event: objecteventty);
var
 po1: pifirecty;
 str1: string;
begin
 if (event = oe_dataready) and (sender = fchannel) then begin
  if (length(fchannel.rxdata) >= sizeof(ifiheaderty)) then begin
   with fchannel do begin
    po1:= pifirecty(rxdata);
    with po1^.header do begin
     if size = length(rxdata) then begin
      if (kind in ifiasynckinds) and not (irs_async in state) then begin
       include(state,irs_async);
       asyncrx;
      end
      else begin
       if processdata(po1) then begin
        rxdata:= '';
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustommodulelink.processdataitem(const adata: pifirecty; 
           var adatapo: pchar; const atag: integer; const aname: string): boolean;
var
 str2: string;
begin
 with adata^ do begin
  case header.kind of
   ik_actionfired: begin
    result:= actionreceived(adata,adatapo,atag,aname);
   end;
   ik_propertychanged: begin
    with propertychanged.header do begin
     inc(adatapo,ifinametostring(pifinamety(adatapo),str2));
     result:= propertychangereceived(atag,aname,str2,pifidataty(adatapo));
    end;
   end;
   ik_requestmodule: begin
    result:= requestmodulereceived(atag,aname,adata^.header.sequence);          
   end;
   ik_moduledata: begin
    result:= moduledatareceived(atag,aname,header.answersequence,
                           pmoduledatadataty(adatapo));
   end;
   ik_modulecommand: begin
    result:= modulecommandreceived(atag,aname,pmodulecommanddataty(adatapo));
   end;
  end;
 end;
end;

function tcustommodulelink.processdata(const adata: pifirecty): boolean;
         //todo: optimize link name check
var 
 tag1: integer;
 str1: string;
 po1: pchar;
 ar1: stringarty;
begin 
 result:= false;
 with adata^ do begin
  if header.kind in ifiitemkinds then begin
   with itemheader do begin 
    tag1:= tag;
    po1:= @name;
   end;
   inc(po1,ifinametostring(pifinamety(po1),str1));
   ar1:= splitstring(str1,'.');
   if high(ar1) = 1 then begin
    if ar1[0] <> flinkname then begin
     exit;
    end;
    str1:= ar1[1];
   end;
   result:= processdataitem(adata,po1,tag1,str1);
   if result and (header.answersequence <> 0) then begin
    channel.synchronizer.answerreceived(header.answersequence);
   end;
  end;
 end;
end;

procedure tcustommodulelink.receiveevent(const event: tobjectevent);
var
 comp1: tmsecomponent;
 stream1: tmemorycopystream;
 po1: pchar;
 str1: string;
begin
 if event.kind = ek_objectdata then begin
  if event is tmoduledataevent then begin
   with tmoduledataevent(event) do begin    
    po1:= @fmoduledata^.parentclass;
    inc(po1,ifinametostring(pifinamety(po1),str1));
    with fmodulelink do begin
     freeandnil(fmodule);
     with pifibytesty(po1)^ do begin
      stream1:= tmemorycopystream.create(@data,length);
      try
       fmodule:= createtmpmodule(str1,stream1,@moduleloaded);
       fmodule.getcorbainterface(typeinfo(iificommand),fcommandintf);
      finally
       stream1.free;
      end;
     end;
     setlinkedvar(fmodule,fmodule);
    end;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tcustommodulelink.actionreceived(const adata: pifirecty;
        var adatapo: pchar; const atag: integer; const aname: string): boolean;
var
 act1: trxlinkaction;
 int1: integer;
 var1: variant;
begin
 result:= false;
 with factionsrx do begin
  act1:= trxlinkaction(finditem(aname));
  if act1 <> nil then begin
   result:= true;
   if adatapo^ <> #0 then begin
    var1:= readifivariant(adata,adatapo);
   end
   else begin //end of string
    var1:= null;
   end;
   if assigned(act1.fonexecute) then begin
    act1.fonexecute(act1,atag,var1);
   end;
   if assigned(fonexecute) then begin
    fonexecute(act1,atag,var1);
   end;
   with act1 do begin
    if (faction <> nil) and faction.enabled then begin
     faction.execute;
    end;
   end;
  end;
 end;
end;

function tcustommodulelink.requestmodulereceived(const atag: integer;
            const aname: string; const asequence: sequencety): boolean;
var
 mo1: ttxlinkmodule;
 po1: pobjectdataty;
 str1,str2: string;
 po2,po3: pchar;
begin
 {$ifdef mse_debugifi}
 debugout(self,'requestmodule '+aname);
 {$endif}
 mo1:= ttxlinkmodule(fmodulestx.finditem(aname));
 result:= mo1 <> nil;
 if result and (mo1.fmoduleclassname <> '') then begin
  po1:= findmoduledata(mo1.fmoduleclassname,str2);
  if mo1.moduleparentclassname <> '' then begin
   str2:= mo1.moduleparentclassname;
  end;
  if po1 <> nil then begin
   mo1.inititemheader(str1,ik_moduledata,asequence,length(str2)+po1^.size,po2);
   with pmoduledatadataty(po2)^ do begin
    po3:= @parentclass;
    inc(po3,stringtoifiname(str2,pifinamety(po3)));
    setifibytes(@po1^.data,po1^.size,pifibytesty(po3));
   end;
   senddata(str1);
  end;
 end;
end;

procedure tcustommodulelink.connectmodule(const sender: tcustommodulelink);
begin
 if flo_useclientchannel in options then begin
  channel:= sender.channel;
 end;
end;

procedure tcustommodulelink.moduleloaded(const sender: tmsecomponent);
var
 int1: integer;
 intf1: iifimodulelink;
begin
 with sender do begin
  for int1:= 0 to componentcount - 1 do begin
   if mseclasses.getcorbainterface(components[int1],typeinfo(iifimodulelink),
                                                     intf1) then begin
    intf1.connectmodule(self);
   end;
  end;
 end;
end;

function tcustommodulelink.modulecommandreceived(const atag: integer; 
                  const aname: string; const adata: pmodulecommanddataty): boolean;
var
 mo1: trxlinkmodule;
begin
 mo1:= trxlinkmodule(fmodulesrx.finditem(aname));
 result:= mo1 <> nil;
 if result then begin
  with mo1 do begin
   if fmodule <> nil then begin
    if fcommandintf <> nil then begin
     fcommandintf.executeificommand(adata^.command);
    end;
   end;
  end;
 end;
end;

function tcustommodulelink.moduledatareceived(const atag: integer;
 const aname: string; const asequence: sequencety;
          const adata: pmoduledatadataty): boolean;
var
 mo1: trxlinkmodule;
 comp1: tmsecomponent;
 stream1: tmemorycopystream;
 po1: pchar;
 str1: string;
begin
 if csdesigning in componentstate then begin
  result:= false;
  exit;
 end;
 if asequence <> 0 then begin
  mo1:= fmodulesrx.finditem(asequence);
 end
 else begin
  mo1:= trxlinkmodule(fmodulesrx.finditem(aname));
 end;
 result:= mo1 <> nil;
 if result then begin
  with mo1 do begin
   po1:= adata^.parentclass;
   inc(po1,ifinametostring(pifinamety(po1),str1));
   freeandnil(fmodule);
   with pifibytesty(po1)^ do begin
    stream1:= tmemorycopystream.create(@data,length);
    try
     comp1:= createtmpmodule(str1,stream1,@moduleloaded);
     comp1.getcorbainterface(typeinfo(iificommand),fcommandintf);
    finally
     stream1.free;
    end;
   end;
   setlinkedvar(comp1,fmodule);
  end;
 end;
end;

function tcustommodulelink.propertychangereceived(const atag: integer;
                     const aname: string; const apropertyname: string;
                     const adata: pifidataty): boolean;
                     
 procedure check(const alinks: tvaluelinks);
 var
  wi1: tvaluelink;
 begin
  wi1:= tvaluelink(alinks.finditem(aname));
  result:= wi1 <> nil;
  if result then begin
   with wi1 do begin
    setdata(adata,apropertyname);
    if apropertyname = ifiwidgetstatename then begin
     if assigned(fonwidgetstatechanged) then begin
      fonwidgetstatechanged(wi1,atag,ifiwidgetstatesty(asinteger));
     end;
    end
    else begin
     if apropertyname = ifiwidgetmodalresultname then begin
      if assigned(fonmodalresult) then begin
       fonmodalresult(wi1,atag,modalresultty(asinteger));
      end;
     end
     else begin
      if assigned(fonpropertychanged) then begin
       fonpropertychanged(wi1,atag,apropertyname);
      end;
     end;
    end;
   end;
  end;    
 end; //check
 
begin
 check(fvalues);
 if not result then begin
  check(fvaluecomponents);
 end;
end;

procedure tcustommodulelink.valuechanged(const sender: iifiwidget);
begin
 //dummy
end;

procedure tcustommodulelink.statechanged(const sender: iifiwidget;
              const astate: ifiwidgetstatesty);
begin
 //dummy
end;

procedure tcustommodulelink.sendmodalresult(const sender: iifiwidget; 
                                         const amodalresult: modalresultty);
begin
 //dummy
end;

function tcustommodulelink.hasconnection: boolean;
begin
 result:= (fchannel <> nil) and fchannel.checkconnection;
end;

function tcustommodulelink.senddata(const adata: ansistring): sequencety;
begin
 if fchannel = nil then begin
  raise exception.create(name+': No IO channel assigned.');
 end;
 result:= fchannel.sequence;
 with pifirecty(adata)^.header do begin
  sequence:= result;
 end;
 fchannel.senddata(adata);
end;

procedure tcustommodulelink.setmodulestx(const avalue: ttxlinkmodules);
begin
 fmodulestx.assign(avalue);
end;

procedure tcustommodulelink.setmodulesrx(const avalue: trxlinkmodules);
begin
 fmodulesrx.assign(avalue);
end;

procedure tcustommodulelink.setvalues(const avalue: tvaluelinks);
begin
 fvalues.assign(avalue);
end;

procedure tcustommodulelink.setvaluecomponents(const avalue: tvaluecomponentlinks);
begin
 fvaluecomponents.assign(avalue);
end;

{ ttxlinkmodule }

procedure ttxlinkmodule.sendmodule;
begin
 tcustommodulelink(fowner).requestmodulereceived(tag,name,0);
end;

procedure ttxlinkmodule.close;
begin
 tcustommodulelink(fowner).closemodule(tag,name);
end;

{ tmoduledataevent }

constructor tmoduledataevent.create(const adata: ansistring; const dest: ievent;
               const amodulelink: trxlinkmodule;
               const amoduledata: pmoduledatadataty);
begin
 fmodulelink:= amodulelink;
 fmoduledata:= amoduledata;
 inherited create(adata,dest);
end;

{ tificontroller }

constructor tificontroller.create(const aowner: tcomponent);
begin
 foptions:= defaultifirxoptions;
 fdefaulttimeout:= defaultifirxtimeout;
 inherited create(aowner);
end;

procedure tificontroller.connectmodule(const sender: tcustommodulelink);
begin
 if irxo_useclientchannel in options then begin
  channel:= sender.channel;
 end;
end;

procedure tificontroller.inititemheader(out arec: string;
               const akind: ifireckindty; const asequence: sequencety; 
                const datasize: integer; out datapo: pchar);
begin
 mseifi.inititemheader(tag,flinkname,arec,akind,asequence,datasize,datapo);
end;

procedure tificontroller.setchannel(const avalue: tcustomiochannel);
begin
 setlinkedvar(avalue,fchannel);
end;

function tificontroller.senddata(const adata: ansistring; 
                         const asequence: sequencety = 0): sequencety;
begin
 if fchannel = nil then begin
  raise exception.create(fowner.name+': No IO channel assigned.');
 end;
 result:= asequence;
 if result = 0 then begin
  result:= fchannel.sequence;
 end;
 with pifirecty(adata)^.header do begin
  sequence:= result;
 end;
 fchannel.senddata(adata);
end;

function tificontroller.senddataandwait(const adata: ansistring;
            out asequence: sequencety; atimeoutus: integer = 0): boolean;
var
 client1: twaitingclient;
begin
 if fchannel = nil then begin
  raise exception.create(fowner.name+': No IO channel assigned.');
 end;             
 asequence:= fchannel.sequence;
 client1:= fchannel.synchronizer.preparewait(asequence);
 senddata(adata,asequence);
 if atimeoutus = 0 then begin
  atimeoutus:= timeoutus;
 end;
 result:= fchannel.synchronizer.waitforanswer(client1,atimeoutus);
 if not result then begin
  asequence:= 0;        //!!! race condition?
 end;
end;

function tificontroller.senditem(const kind: ifireckindty; 
                            const data: array of ansistring): sequencety;
                //returns sequence number
var
 str1: ansistring;
 po1: pchar;
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= 0 to high(data) do begin
  inc(int2,length(data[int1]));
 end;
 inititemheader(str1,ik_itemheader,0,int2,po1);
 pifirecty(str1)^.header.kind:= kind;
 for int1:= 0 to high(data) do begin
  int2:= length(data[int1]);
  move(pointer(data[int1])^,po1^,int2);
  inc(po1,int2);
 end; 
 result:= senddata(str1);
end;

procedure tificontroller.objectevent(const sender: tobject;
               const event: objecteventty);
var
 po1: pifirecty;
 tag1: integer;
 str1: string;
 po2: pchar;
 int1: integer;
 mstr1: msestring;
begin
 if (event = oe_dataready) and (sender = fchannel) then begin
  if (length(fchannel.rxdata) >= sizeof(ifiheaderty)) then begin
   with fchannel do begin
    po1:= pifirecty(rxdata);
    with po1^,header do begin
     if (size = length(rxdata)) and (kind in getifireckinds) then begin
      with itemheader do begin 
       tag1:= tag;
       po2:= @name;
      end;
      inc(po2,ifinametostring(pifinamety(po2),str1));
      if str1 = flinkname then begin
       processdata(po1,po2);
       if answersequence <> 0 then begin
        channel.synchronizer.answerreceived(answersequence);
       end;
       rxdata:= '';
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tificontroller.getifireckinds: ifireckindsty;
begin
 result:= [];
end;

function tificontroller.cansend: boolean;
begin
 result:= (channel <> nil) or 
             not ((csdesigning in fowner.componentstate) and 
                  (irxo_useclientchannel in foptions));
end;

{ tifidatacol }

destructor tifidatacol.destroy;
begin
 freedatalist;
 inherited;
end;

procedure tifidatacol.freedatalist;
begin
 fdatalist.free;
end;

procedure tifidatacol.setdatakind(const avalue: ifidatakindty);
begin
 if fdatakind <> avalue then begin
  freedatalist;
  fdatakind:= avalue;
 end;
end;

procedure tifidatacol.checkdatalist;
begin
 if fdatalist = nil then begin
  case datakind of
   idk_integer: begin
    fdatalist:= tintegerdatalist.create;
   end;
   {
   idk_int64: begin
    fdatalist:= tint64datalist.create;
   end;
   idk_currency: begin
    fdatalist:= tcurrencydatalist.create;
   end;
   }
   idk_real: begin
    fdatalist:= trealdatalist.create;
   end;
   idk_msestring: begin
    fdatalist:= tmsestringdatalist.create;
   end;
   idk_msestringint: begin
    fdatalist:= tmsestringintdatalist.create;
   end;
   idk_bytes: begin
    fdatalist:= tansistringdatalist.create;
   end;
   else begin
    raise exception.create('Invalid ifidatakind.');
   end;
  end;
 end;
 fdatalist.count:= ttxdatagrid(fowner).rowcount;
end;

procedure tifidatacol.checkdatalist(const akind: ifidatakindty);
begin
 if akind <> datakind then begin
  raise exception.create('Wrong datakind.');
 end;
 if fdatalist = nil then begin
  checkdatalist;
 end;
end;

function tifidatacol.getdatalist: tdatalist;
begin
 checkdatalist;
 result:= fdatalist;
end;

function tifidatacol.getasinteger(const index: integer): integer;
begin
 checkdatalist(idk_integer);
 result:= tintegerdatalist(fdatalist).items[index];
end;

procedure tifidatacol.setasinteger(const index: integer; const avalue: integer);
begin
 checkdatalist(idk_integer);
 tintegerdatalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getasint64(const index: integer): int64;
begin
 checkdatalist(idk_int64);
 result:= tint64datalist(fdatalist).items[index];
end;

procedure tifidatacol.setasint64(const index: integer; const avalue: int64);
begin
 checkdatalist(idk_int64);
 tint64datalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getascurrency(const index: integer): currency;
begin
 checkdatalist(idk_currency);
 result:= tcurrencydatalist(fdatalist).items[index];
end;

procedure tifidatacol.setascurrency(const index: integer;
               const avalue: currency);
begin
 checkdatalist(idk_currency);
 tcurrencydatalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getasreal(const index: integer): real;
begin
 checkdatalist(idk_real);
 result:= trealdatalist(fdatalist).items[index];
end;

procedure tifidatacol.setasreal(const index: integer; const avalue: real);
begin
 checkdatalist(idk_real);
 trealdatalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getasmsestring(const index: integer): msestring;
begin
 checkdatalist(idk_msestring);
 result:= tmsestringdatalist(fdatalist).items[index];
end;

procedure tifidatacol.setasmsestring(const index: integer;
               const avalue: msestring);
begin
 checkdatalist(idk_msestring);
 tmsestringdatalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getasbytes(const index: integer): ansistring;
begin
 checkdatalist(idk_bytes);
 result:= tansistringdatalist(fdatalist).items[index];
end;

procedure tifidatacol.setasbytes(const index: integer;
               const avalue: ansistring);
begin
 checkdatalist(idk_bytes);
 tansistringdatalist(fdatalist).items[index]:= avalue;
end;

function tifidatacol.getasmsestringint(const index: integer): msestringintty;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdatalist).doubleitems[index];
end;

procedure tifidatacol.setasmsestringint(const index: integer;
               const avalue: msestringintty);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdatalist).doubleitems[index]:= avalue;
end;

function tifidatacol.getasmsestringinti(const index: integer): integer;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdatalist).itemsb[index];
end;

procedure tifidatacol.setasmsestringinti(const index: integer;
               const avalue: integer);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdatalist).itemsb[index]:= avalue;
end;

function tifidatacol.getasmsestringints(const index: integer): msestring;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdatalist).items[index];
end;

procedure tifidatacol.setasmsestringints(const index: integer;
               const avalue: msestring);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdatalist).items[index]:= avalue;
end;

{ tifidatacols }

constructor tifidatacols.create(const aowner: ttxdatagrid);
begin
 frowstate:= tifirowstatelist.create;
 inherited create(aowner,tifidatacol);
end;

destructor tifidatacols.destroy;
begin
 inherited;
 frowstate.free;
end;

class function tifidatacols.getitemclasstype: persistentclassty;
begin
 result:= tifidatacol;
end;

function tifidatacols.getcols(const index: integer): tifidatacol;
begin
 result:= tifidatacol(inherited getitems(index));
end;

procedure tifidatacols.setcols(const index: integer; const avalue: tifidatacol);
begin
 tifidatacol(inherited getitems(index)).assign(avalue);
end;

function tifidatacols.colbyname(const aname: ansistring): tifidatacol;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to count - 1 do begin
  if tifidatacol(fitems[int1]).fname = aname then begin
   result:= tifidatacol(fitems[int1]);
   break;
  end;
 end;
end;

{ ttxdatagrid }

constructor ttxdatagrid.create(aowner: tcomponent);
begin
 fifi:= ttxdatagridcontroller.create(self);
 inherited;
 fdatacols:= tifidatacols.create(self);
end;

destructor ttxdatagrid.destroy;
begin
 fdatacols.free;
 inherited;
 fifi.free;
end;

procedure ttxdatagrid.setifi(const avalue: ttxdatagridcontroller);
begin
 fifi.assign(avalue);
end;

procedure ttxdatagrid.setdatacols(const avalue: tifidatacols);
begin
 fdatacols.assign(avalue);
end;

procedure ttxdatagrid.setrowcount(const avalue: integer);
var
 int1: integer;
begin
 if frowcount <> avalue then begin
  frowcount:= avalue;
  with fdatacols do begin
   for int1:= 0 to high(fitems) do begin
    with tifidatacol(fitems[int1]) do begin
     if fdatalist <> nil then begin
      fdatalist.count:= avalue;
     end;
    end;
   end;
   frowstate.count:= avalue;
  end;
 end;
end;

function ttxdatagrid.getrowhigh: integer;
begin
 result:= frowcount - 1;
end;

{ ttxdatagridcontroller }

constructor ttxdatagridcontroller.create(const aowner: ttxdatagrid);
begin
 inherited create(aowner);
end;

procedure ttxdatagridcontroller.processdata(const adata: pifirecty;
               var adatapo: pchar);
var
 int1: integer;
 rows1,cols1: integer;
 kind1: datatypty;
 po1: pchar;
 str1: ansistring;
 col1: tifidatacol;
 list1: tdatalist;
begin
 with adata^.header do begin
  case kind of
   ik_requestopen: begin
    senddata(encodegriddata(sequence));
   end;
   ik_griddata: begin
    with ttxdatagrid(fowner) do begin
     with pgriddatadataty(adatapo)^ do begin
      rows1:= rows;
      rowcount:= rows1;
      cols1:= cols;
      po1:= @data;
     end;
     for int1:= 0 to cols1 - 1 do begin
      with pcoldataty(po1)^ do begin
       kind1:= kind;
       po1:= @name;
       inc(po1,ifinametostring(pifinamety(po1),str1));
       col1:= datacols.colbyname(str1);
       if col1 <> nil then begin
        list1:= col1.datalist;
       end
       else begin
        list1:= nil;
       end;
       inc(po1,ifidatatodatalist(kind1,rows1,po1,list1));
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure ttxdatagridcontroller.setowneractive(const avalue: boolean);
begin
 //dummy
end;

function ttxdatagridcontroller.getifireckinds: ifireckindsty;
begin
 result:= [ik_requestopen,ik_griddata];
end;

function ifidatatodatalist(const akind: datatypty; const arowcount: integer;
                       const adata: pchar; const adatalist: tdatalist): integer;
       //returns datasize
var
 int1,int2: integer;
 po1: pmsestring; 
 po2: pinteger;
 po3: pansistring;
 po4: pmsestringintty;
begin
 if (adatalist <> nil) and (adatalist.datatyp <> akind) then begin
  raise exception.create('Datakinds do not match.');
 end;
 case akind of
  dl_integer: begin
   result:= arowcount * sizeof(integer);
   if adatalist <> nil then begin
    move(adata^,adatalist.datapo^,result);
   end;
  end;
  dl_int64: begin
   result:= arowcount * sizeof(int64);
   if adatalist <> nil then begin
    move(adata^,adatalist.datapo^,result);
   end;
  end;
  dl_currency: begin
   result:= arowcount * sizeof(currency);
   if adatalist <> nil then begin
    move(adata^,adatalist.datapo^,result);
   end;
  end;
  dl_real: begin
   result:= arowcount * sizeof(real);
   if adatalist <> nil then begin
    move(adata^,adatalist.datapo^,result);
   end;
  end;
  dl_msestring: begin
   po2:= pinteger(adata);
   result:= arowcount * sizeof(integer);
   if adatalist <> nil then begin
    po1:= adatalist.datapo;
    for int1:= 0 to arowcount - 1 do begin
     move(po2^,int2,sizeof(integer));
     setlength(po1[int1],int2);
     int2:= int2 * sizeof(msechar);
     result:= result + int2;
     inc(po2);
     move(po2^,po1[int1][1],int2);
     inc(pointer(po2),int2);
    end;
   end
   else begin
    for int1:= 0 to arowcount - 1 do begin
     int2:= po2^*sizeof(msechar);
     result:= result + int2;
     inc(po2);
     inc(pointer(po2),int2);
    end;
   end;    
  end;
  dl_msestringint: begin
   po2:= pinteger(adata);
   result:= arowcount * (sizeof(integer)+sizeof(integer));
   if adatalist <> nil then begin
    po4:= adatalist.datapo;
    for int1:= 0 to arowcount - 1 do begin
     move(po2^,po4[int1].int,sizeof(integer));
     inc(po2);
     move(po2^,int2,sizeof(integer));
     setlength(po4[int1].mstr,int2);
     int2:= int2 * sizeof(msechar);
     result:= result + int2;
     inc(po2);
     move(po2^,po4[int1].mstr[1],int2);
     inc(pointer(po2),int2);
    end;
   end
   else begin
    for int1:= 0 to arowcount - 1 do begin
     inc(po2);
     int2:= po2^*sizeof(msechar);
     result:= result + int2;
     inc(po2);
     inc(pointer(po2),int2);
    end;
   end;    
  end;
  dl_rowstate: begin
   result:= arowcount * sizeof(rowstatety);
   if adatalist <> nil then begin
    move(adata^,adatalist.datapo^,result);
   end;
  end;
  dl_ansistring: begin
   po2:= pinteger(adata);
   result:= arowcount * sizeof(integer);
   if adatalist <> nil then begin
    po3:= adatalist.datapo;
    for int1:= 0 to arowcount - 1 do begin
     move(po2^,int2,sizeof(integer));
     setlength(po3[int1],int2);
     result:= result + int2;
     inc(po2);
     move(po2^,po3[int1][1],int2);
     inc(pointer(po2),int2);
    end;
   end
   else begin
    for int1:= 0 to arowcount - 1 do begin
     int2:= po2^;
     result:= result + int2;
     inc(po2);
     inc(pointer(po2),int2);
    end;
   end;    
  end;
  else begin
   raise exception.create('Invalid datakind.');
  end;
 end;
 if adatalist <> nil then begin
  adatalist.change(-1);
 end;
end;

procedure datalisttoifidata(const adatalist: tdatalist;
                                         var dest: pchar); overload;
var
 int1,int2: integer;
 po4: pchar;
begin
 with adatalist do begin
  po4:= datapo;
  case datatyp of
   dl_integer: begin
    int2:= count * sizeof(integer);
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_int64: begin
    int2:= count * sizeof(int64);
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_currency: begin
    int2:= count * sizeof(currency);
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_real: begin
    int2:= count * sizeof(real);
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_msestring: begin
    for int1:= 0 to count - 1 do begin
     int2:= length(pmsestring(po4)[int1]);
     move(int2,dest^,sizeof(integer));
     int2:= int2 * sizeof(msechar);
     inc(dest,sizeof(integer));
     move(pointer(pmsestring(po4)[int1])^,dest^,int2);
     inc(dest,int2);
    end;
   end;
   dl_msestringint: begin
    for int1:= 0 to count - 1 do begin
     move(pmsestringintty(po4)[int1].int,dest^,sizeof(integer));
     inc(dest,sizeof(integer));
     int2:= length(pmsestringintty(po4)[int1].mstr);
     move(int2,dest^,sizeof(integer));
     int2:= int2 * sizeof(msechar);
     inc(dest,sizeof(integer));
     move(pmsestringintty(po4)[int1].mstr[1],dest^,int2);
     inc(dest,int2);
    end;
   end;
   dl_rowstate: begin
    int2:= count * sizeof(rowstatety);
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_ansistring: begin
    for int1:= 0 to count - 1 do begin
     int2:= length(pansistring(po4)[int1]);
     move(int2,dest^,sizeof(integer));
     inc(dest,sizeof(integer));
     move(pointer(pansistring(po4)[int1])^,dest^,int2);
     inc(dest,int2);
    end;
   end;
  end;
 end;
end;

function datalisttoifidata(const adatalist: tdatalist): integer; overload;
// returns size
var
 int1: integer;
 po1: pmsestring;
 po2: pansistring;
 po3: pmsestringintty;
begin
 with adatalist do begin
  case adatalist.datatyp of
   dl_integer: begin
    result:= count * sizeof(integer);
   end;
   dl_int64: begin
    result:= count * sizeof(int64);
   end;
   dl_currency: begin
    result:= count * sizeof(currency);
   end;
   dl_real: begin
    result:= count * sizeof(real);
   end;
   dl_msestring: begin
    po1:= datapo;
    result:= count * sizeof(integer);
    for int1:= 0 to count - 1 do begin
     result:= result + length(po1[int1]) * sizeof(msechar);
    end;
   end;
   dl_msestringint: begin
    po3:= datapo;
    result:= count * (sizeof(integer)+sizeof(integer));
    for int1:= 0 to count - 1 do begin
     result:= result + length(po3[int1].mstr) * sizeof(msechar);
    end;
   end;
   dl_rowstate: begin
    result:= count * sizeof(rowstatety);
   end;
   dl_ansistring: begin
    po2:= datapo;
    result:= count * sizeof(integer);
    for int1:= 0 to count - 1 do begin
     result:= result + length(po2[int1]);
    end;
   end;
  end;
 end;
end;

function ttxdatagridcontroller.encodegriddata(
                     const asequence: sequencety): ansistring;
var
 po1,po4: pchar;
 int1,int2,int3,int4: integer;
 po2: pmsestring;
 po3: pansistring;
 ar1: booleanarty;
begin
 with ttxdatagrid(fowner) do begin
  setlength(ar1,datacols.count);
  int2:= 0;
  for int1:= 0 to datacols.count - 1 do begin
   with datacols[int1] do begin
    checkdatalist;
    ar1[int1]:= (name <> '') and (datalist.datatyp in ifidatatypes);
    if ar1[int1] then begin
     int2:= int2 + (sizeof(datatypty)+1) + length(name) + 
                       datalisttoifidata(datalist);
    end;
   end;
  end;
  int2:= int2 + datalisttoifidata(datacols.frowstate);
  inititemheader(result,ik_griddata,asequence,int2,po1);
  with pgriddatadataty(po1)^ do begin
   rows:= rowcount;
   cols:= datacols.count;
   po1:= @data;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] then begin
     with datacols[int1] do begin
      with pcoldataty(po1)^ do begin
       kind:= datalist.datatyp;
       po1:= @name;   
      end;
      inc(po1,stringtoifiname(name,pifinamety(po1)));
      datalisttoifidata(datalist,po1);
     end;
    end;
   end;
   datalisttoifidata(datacols.frowstate,po1);
  end;
 end;
end;

end.
