{ MSEgui Copyright (c) 2007-2013 by Martin Schreiber

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
 classes,mclasses,mseclasses,mseifiglob,mseifi,msearrayprops,mseapplication,
 mseact,mseinterfaces,
 mseevent,mseglob,msestrings,msetypes,msedatalist,msegraphutils,typinfo,
 mseeditglob;

type
 formlinkoptionty = (flo_useclientchannel);
 formlinkoptionsty = set of formlinkoptionty;
const
 defaultformlinkoptions = [flo_useclientchannel];
 ifidatatypes = [dl_integer,dl_int64,dl_currency,dl_real,
                 dl_msestring,dl_ansistring,dl_msestringint,
                 dl_realint,dl_realsum];
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

 iifitxaction = interface(inullinterface)[miid_iifitxaction]
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
   fowneractions: ttxlinkactions;
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

 rxlinkoptionty = (rlo_closeconnonfree);
 rxlinkoptionsty = set of rxlinkoptionty;
 
 trxlinkmodule = class(tlinkaction)
  private
   fmodule: tmsecomponent;
   fcommandintf: iificommand;
   fonmodulereceived: rxlinkmoduleeventty;
   fsequence: sequencety;
   foptions: rxlinkoptionsty;
  protected
   procedure objevent(const sender: iobjectlink;
                                const event: objecteventty); override;
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
   procedure domodulereceived;
  public
   procedure requestmodule;
   property module: tmsecomponent read fmodule;
  published
   property onmodulereceived: rxlinkmoduleeventty read fonmodulereceived 
                         write fonmodulereceived;
   property options: rxlinkoptionsty read foptions write foptions default [];
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

//todo: beginupdate/endupdate, use tifivaluelinkcontroller

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
   fintf: iificlient;
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

 iifimodulelink = interface(inullinterface)[miid_iifimodulelink]
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
   procedure execute(const sender: iificlient); virtual;
   procedure valuechanged(const sender: iificlient); virtual;
   procedure statechanged(const sender: iificlient;
                             const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(const sender: iificlient;
                     var avalue; var accept: boolean; const arow: integer);
   procedure dataentered(const sender: iificlient; const arow: integer);
   procedure updateoptionsedit(var avalue: optionseditty);
   procedure closequery(const sender: iificlient; 
                               var amodalresult: modalresultty);
   procedure sendmodalresult(const sender: iificlient; 
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
   constructor create(const aowner: tcomponent; const aintf: iactivatorclient);
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
{
 tifirxcontroller = class(tificontroller)
 end;
 tifitxcontroller = class(tificontroller)
 end;
}
 tifidatacol = class;
 
 ifidatacolchangeeventty = procedure(const sender: tifidatacol;
                                      const aindex: integer) of object;

 ifidatacolstatety = (icos_selected);
 ifidatacolstatesty = set of ifidatacolstatety;
 
 tifidatacol = class(tindexpersistent)
  private
   fdata: tdatalist;
   fdatakind: ifidatakindty;
   fname: ansistring;
   fonchange: ifidatacolchangeeventty;
   fstate: ifidatacolstatesty;
   fselectedrow: integer;
   fselectlock: integer;
   procedure setdatakind(const avalue: ifidatakindty);
   function getdatalist: tdatalist;
   function getasinteger(const aindex: integer): integer;
   procedure setasinteger(const aindex: integer; const avalue: integer);
   function getasint64(const aindex: integer): int64;
   procedure setasint64(const aindex: integer; const avalue: int64);
   function getascurrency(const aindex: integer): currency;
   procedure setascurrency(const aindex: integer; const avalue: currency);
   function getasreal(const aindex: integer): real;
   procedure setasreal(const aindex: integer; const avalue: real);
   function getasmsestring(const aindex: integer): msestring;
   procedure setasmsestring(const aindex: integer; const avalue: msestring);
   function getasbytes(const aindex: integer): ansistring;
   procedure setasbytes(const aindex: integer; const avalue: ansistring);
   function getasmsestringint(const aindex: integer): msestringintty;
   procedure setasmsestringint(const aindex: integer; const avalue: msestringintty);
   function getasmsestringinti(const aindex: integer): integer;
   procedure setasmsestringinti(const aindex: integer; const avalue: integer);
   function getasmsestringints(const aindex: integer): msestring;
   procedure setasmsestringints(const aindex: integer; const avalue: msestring);
   function getselected(row: integer): boolean;
   procedure setselected(row: integer; const avalue: boolean);
   function getmerged(const row: integer): boolean; virtual;
   procedure setmerged(const row: integer; const avalue: boolean); virtual;
   function getasrealint(const aindex: integer): realintty;
   procedure setasrealint(const aindex: integer; const avalue: realintty);
   function getasrealintr(const aindex: integer): realty;
   procedure setasrealintr(const aindex: integer; const avalue: realty);
   function getasrealinti(const aindex: integer): integer;
   procedure setasrealinti(const aindex: integer; const avalue: integer);
  protected
   procedure freedatalist;
   procedure checkdatalist; overload;
   procedure checkdatalist(const akind: ifidatakindty); overload;
   procedure dochange(const sender: tdatalist; const aindex: integer);
   procedure doselectionchanged;
   procedure beginselect;
   procedure endselect;
   procedure datachange(const aindex: integer);
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); override;
   destructor destroy; override;
   property datalist: tdatalist read getdatalist;
   
   property asinteger[const aindex: integer]: integer read getasinteger 
                               write setasinteger;
   property asint64[const aindex: integer]: int64 read getasint64 
                               write setasint64;
   property ascurrency[const aindex: integer]: currency read getascurrency 
                               write setascurrency;
   property asreal[const aindex: integer]: real read getasreal
                               write setasreal;
   property asmsestring[const aindex: integer]: msestring read getasmsestring 
                               write setasmsestring;
   property asmsestringint[const aindex: integer]: msestringintty
                         read getasmsestringint write setasmsestringint;
   property asmsestringinti[const aindex: integer]: integer
                         read getasmsestringinti write setasmsestringinti;
   property asmsestringints[const aindex: integer]: msestring
                         read getasmsestringints write setasmsestringints;
   property asrealint[const aindex: integer]: realintty read getasrealint write
                         setasrealint;
   property asrealintr[const aindex: integer]: realty read getasrealintr write
                         setasrealintr;
   property asrealinti[const aindex: integer]: integer read getasrealinti write
                         setasrealinti;
   property asbytes[const aindex: integer]: ansistring read getasbytes 
                               write setasbytes;
   property merged[const row: integer]: boolean read getmerged write setmerged;
   property selected[row: integer]: boolean read getselected write setselected;
  published
   property datakind: ifidatakindty read fdatakind write setdatakind 
                         default idk_none;
   property name: ansistring read fname write fname;
   property onchange: ifidatacolchangeeventty read fonchange write fonchange;
 end;
  
 ttxdatagrid = class;
 tifirowstatelist = class(tcustomrowstatelist)
  protected
   procedure sethidden(const index: integer; const avalue: boolean); override;
   procedure setfoldlevel(const index: integer; const avalue: byte);
   procedure setfoldissum(const index: integer; const avalue: boolean); override;
  public
   property hidden[const index: integer]: boolean read gethidden write sethidden;
   property foldlevel[const index: integer]: byte read getfoldlevel 
                                  write setfoldlevel;   //0..63
   property foldissum[const index: integer]: boolean read getfoldissum 
                                  write setfoldissum;
 end;
    
 tifidatacols = class(tindexpersistentarrayprop)
  private
   frowstate: tifirowstatelist;
   fselectedrow: integer; //-1 none, -2 more than one
   function getcols(const index: integer): tifidatacol;
   procedure setcols(const index: integer; const avalue: tifidatacol);
   function getselectedcells: gridcoordarty;
   procedure setselectedcells(const avalue: gridcoordarty);
   function Getselected(const cell: gridcoordty): boolean;
   procedure Setselected(const cell: gridcoordty; const avalue: boolean);
   procedure beginselect;
   procedure endselect;
  public 
   constructor create(const aowner: ttxdatagrid); reintroduce;
   destructor destroy; override;
   class function getitemclasstype: persistentclassty; override;
   function colbyname(const aname: ansistring): tifidatacol;
   function datalistbyname(const aname: ansistring): tdatalist;

   procedure clearselection;
   function hasselection: boolean;
   function selectedcellcount: integer;
   function hascolselection: boolean;
   property selectedcells: gridcoordarty read getselectedcells write setselectedcells;
   property selected[const cell: gridcoordty]: boolean read Getselected write Setselected;
               //col < 0 and row < 0 -> whole grid, col < 0 -> whole col,
               //row = < 0 -> whole row
   procedure setselectedrange(const rect: gridrectty; const value: boolean); overload;
   procedure setselectedrange(const start,stop: gridcoordty;
                    const value: boolean); overload;

   procedure mergecols(const arow: integer; const astart: longword = 0; 
                                              const acount: longword = bigint);
   procedure unmergecols(const arow: integer = invalidaxis);
                     //invalidaxis = all

   property rowstate: tifirowstatelist read frowstate;
   property cols[const index: integer]: tifidatacol read getcols write setcols;
                                                 default;
 end;

 ifigridoptionty = (
             igo_state,   //send the whole gridstate after endupdate
             igo_rowenter,igo_rowmove,igo_rowdelete,
             igo_rowinsert,igo_rowstate,igo_selection,igo_coldata);
 ifigridoptionsty = set of ifigridoptionty;

 tifigridcontroller = class(tificontroller)
  private
   fupdating: integer;
  protected
   foptionstx: ifigridoptionsty;
   foptionsrx: ifigridoptionsty;
   fdatasequence: sequencety;
   fcommandlock: integer;
   function encodegriddata(const asequence: sequencety): ansistring; 
                                                     virtual; abstract;
   function getifireckinds: ifireckindsty; override;
  public
   function cancommandsend(const akind: ifigridoptionty): boolean;
   procedure beginupdate;
   procedure endupdate;
   procedure sendstate;
  published
   property optionstx: ifigridoptionsty read foptionstx
                                           write foptionstx default[];
   property optionsrx: ifigridoptionsty read foptionsrx
                                           write foptionsrx default[];

 end;
 
 ttxdatagridcontroller = class(tifigridcontroller)
  private
  protected
//   function getifireckinds: ifireckindsty; override;
   procedure setowneractive(const avalue: boolean); override;
   procedure processdata(const adata: pifirecty; var adatapo: pchar); 
                                    override;
   function encodegriddata(const asequence: sequencety): ansistring; override;
  public
   constructor create(const aowner: ttxdatagrid; const aintf: iactivatorclient);
 end;

 ifigriditemeventty = procedure(const sender: ttxdatagrid;
                                    const aindex: integer) of object;
 ifigridblockeventty = procedure(const sender: ttxdatagrid; 
                  const aindex: integer; const acount: integer) of object;
 ifigridblockmovedeventty = procedure(const sender: ttxdatagrid; 
                  const fromindex,toindex,acount: integer) of object;
 ifigrideventty = procedure(const sender: ttxdatagrid) of object;

 ttxdatagrid = class(tactcomponent)
  private
   fifi: ttxdatagridcontroller;
   fdatacols: tifidatacols;
   frowcount: integer;
   frow: integer;
   fonrowsdeleted: ifigridblockeventty;
   fonrowsinserted: ifigridblockeventty;
   fonrowsmoved: ifigridblockmovedeventty;
   fonrowindexchanged: ifigrideventty;
   fonrowstatechanged: ifigriditemeventty;
   fonbeforeopen: ifigrideventty;
   procedure rowstatechanged(const aindex: integer);
   procedure setifi(const avalue: ttxdatagridcontroller);
   procedure setdatacols(const avalue: tifidatacols);
   procedure setrowcount(const avalue: integer);
   function getrowhigh: integer;
   procedure setrow(const avalue: integer);
   function getrowcolorstate(index: integer): rowstatenumty;
   procedure setrowcolorstate(index: integer; const avalue: rowstatenumty);
   function getrowfontstate(index: integer): rowstatenumty;
   procedure setrowfontstate(index: integer; const avalue: rowstatenumty);
   function getrowreadonlystate(const index: integer): boolean;
   procedure setrowreadonlystate(const index: integer; const avalue: boolean);
   function getrowhidden(const index: integer): boolean;
   procedure setrowhidden(const index: integer; const avalue: boolean);
   function getrowfoldlevel(const index: integer): byte;
   procedure setrowfoldlevel(const index: integer; const avalue: byte);
   function getrowfoldissum(const index: integer): boolean;
   procedure setrowfoldissum(const index: integer; const avalue: boolean);
  protected
   procedure setselected(const cell: gridcoordty; const avalue: boolean);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure beginupdate;
   procedure endupdate;   
   procedure clear;
   procedure moverow(const curindex,newindex: integer; const count: integer = 1);
   procedure insertrow(index: integer; count: integer = 1);
   procedure deleterow(index: integer; count: integer = 1);
   property rowhigh: integer read getrowhigh;
   property row: integer read frow write setrow;
   property rowcolorstate[index: integer]: rowstatenumty read getrowcolorstate 
                        write setrowcolorstate; //default = -1
   property rowfontstate[index: integer]: rowstatenumty read getrowfontstate 
                        write setrowfontstate;  //default = -1
   property rowreadonlystate[const index: integer]: boolean read getrowreadonlystate
                        write setrowreadonlystate;
   property rowhidden[const index: integer]: boolean read getrowhidden 
                        write setrowhidden;
   property rowfoldlevel[const index: integer]: byte read getrowfoldlevel
                        write setrowfoldlevel;
   property rowfoldissum[const index: integer]: boolean read getrowfoldissum 
                        write setrowfoldissum;
  published
   property ifi: ttxdatagridcontroller read fifi write setifi;
   property datacols: tifidatacols read fdatacols write setdatacols;
   property rowcount: integer read frowcount write setrowcount default 0;
   property onrowsdeleted: ifigridblockeventty read fonrowsdeleted 
                           write fonrowsdeleted;
   property onrowsinserted: ifigridblockeventty read fonrowsinserted 
                           write fonrowsinserted;
   property onrowsmoved: ifigridblockmovedeventty read fonrowsmoved
                           write fonrowsmoved;
   property onrowindexchanged: ifigrideventty read fonrowindexchanged 
                           write fonrowindexchanged;
   property onrowstatechanged: ifigriditemeventty read fonrowstatechanged 
                           write fonrowstatechanged;
   property onbeforeopen: ifigrideventty read fonbeforeopen write fonbeforeopen;
 end;
   
function ifidatatodatalist(const akind: listdatatypety; const arowcount: integer;
        const adata: pchar; const adatalist: tdatalist): integer; overload;
       //returns datasize
function ifidatatodatalist(const akind: listdatatypety; const arowcount: integer;
        const adata: pchar; const adatalist: subdatainfoty): integer; overload;
       //returns datasize
function datalisttoifidata(const adatalist: tdatalist): integer; overload;
procedure datalisttoifidata(const adatalist: tdatalist;
                                         var dest: pchar); overload;

function encodegridcommanddata(const akind: gridcommandkindty;
                               const asource,adest,acount: integer): string;
function decodegridcommanddata(const adata: pchar; out akind: gridcommandkindty;
                               out asource,adest,acount: integer): integer;
function encodecolchangedata(const acolname: string; const arow: integer;
                                     const alist: tdatalist): string; overload;
function encodecolchangedata(const acolname: string; const arow: integer;
                            const alist: tcustomrowstatelist;
                            const subindex: rowstatememberty): string; overload;
function encoderowstatedata(const arow: integer; 
                      const astate: rowstatety): string; overload;
function encoderowstatedata(const arow: integer;
                      const astate: rowstatecolmergety): string; overload;
function encoderowstatedata(const arow: integer;
                      const astate: rowstaterowheightty): string; overload;
function encodeselectiondata(const acell: gridcoordty;
                                            const avalue: boolean): string;

implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules,msebits,mseobjecttext,
 msestreaming{$ifndef FPC},classes_del{$endif};

type
 tcustomrowstatelist1 = class(tcustomrowstatelist);
 
 tmoduledataevent = class(tstringobjectevent)
  protected
   fmodulelink: trxlinkmodule;
   fmoduledata: pmoduledatadataty;
  public
   constructor create(const adata: ansistring; const dest: ievent;
        const amodulelink: trxlinkmodule; const amoduledata: pmoduledatadataty);
 end;

function encodegridcommanddata(const akind: gridcommandkindty;
                                      const asource,adest,acount: integer): string;
begin
 result:= nullstring(sizeof(gridcommanddatadataty));
 with pgridcommanddatadataty(result)^ do begin
  kind:= akind;
  dest:= adest;
  source:= asource;
  count:= acount;
 end;
end;

function decodegridcommanddata(const adata: pchar; out akind: gridcommandkindty;
                               out asource,adest,acount: integer): integer;
begin
 result:= sizeof(gridcommanddatadataty);
 with pgridcommanddatadataty(adata)^ do begin
  akind:= kind;
  adest:= dest;
  asource:= source;
  acount:= count;
 end;
end;

function encodecolchangedata(const acolname: string; const arow: integer;
                                     const alist: tdatalist): string;
begin
 result:= encodeifidata(alist,arow,sizeof(colitemheaderty)+length(acolname));
 if result <> '' then begin
  with pcolitemdataty(result)^.header do begin
   row:= arow;
   stringtoifiname(acolname,@name);
  end;
 end;
end;

function encodecolchangedata(const acolname: string; const arow: integer;
                            const alist: tcustomrowstatelist;
                            const subindex: rowstatememberty): string;
var
 int1: integer;
begin
 result:= '';
 int1:= sizeof(colitemheaderty)+length(acolname);
 case subindex of
  rsm_select: begin
   result:= encodeifidata(alist.selected[arow],int1);
  end;
  rsm_color: begin
   result:= encodeifidata(alist.color[arow],int1);
  end;
  rsm_font: begin
   result:= encodeifidata(alist.font[arow],int1);
  end;
  rsm_readonly: begin
   result:= encodeifidata(alist.readonly[arow],int1);
  end;
  rsm_foldlevel: begin
   result:= encodeifidata(alist.foldlevel[arow],int1);
  end;
  rsm_foldissum: begin
   result:= encodeifidata(alist.foldissum[arow],int1);
  end;
  rsm_hidden: begin
   result:= encodeifidata(alist.foldissum[arow],int1);
  end;
  rsm_merged: begin
   if alist.infolevel >= ril_colmerge then begin
    result:= encodeifidata(alist.merged[arow],int1);
   end;
  end;
  rsm_height: begin
   if alist.infolevel >= ril_rowheight then begin
    result:= encodeifidata(alist.height[arow],int1);
   end;
  end;
 end;
 if result <> '' then begin
  with pcolitemdataty(result)^.header do begin
   row:= arow;
   stringtoifiname(acolname,@name);
  end;
 end;
end;

function encoderowstatedata(const arow: integer; 
                               const astate: rowstatety): string;
begin
 result:= encodeifidata(astate,sizeof(rowstateheaderty));
 with prowstatedataty(result)^.header do begin
  row:= arow;
 end;
end;

function encoderowstatedata(const arow: integer; 
                               const astate: rowstatecolmergety): string;
begin
 result:= encodeifidata(astate,sizeof(rowstateheaderty));
 with prowstatedataty(result)^.header do begin
  row:= arow;
 end;
end;

function encoderowstatedata(const arow: integer; 
                               const astate: rowstaterowheightty): string;
begin
 result:= encodeifidata(astate,sizeof(rowstateheaderty));
 with prowstatedataty(result)^.header do begin
  row:= arow;
 end;
end;

function encodeselectiondata(const acell: gridcoordty; 
                                            const avalue: boolean): string;
var
 sel1: selectdataty;
begin
 fillchar(sel1,sizeof(sel1),0);
 sel1.col:= acell.col;
 sel1.row:= acell.row;
 sel1.select:= avalue;
 result:= encodeifidata(sel1);
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
 setlinkedvar(avalue,tmsecomponent(faction));
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
 fowneractions:= aowner;
 inherited create(nil);
end;

procedure ttxactiondestroyhandler.notification(acomponent: tcomponent;
               operation: toperation);
var
 int1: integer;
begin
 inherited;
 if operation = opremove then begin
  with fowneractions do begin
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

procedure trxlinkmodule.objevent(const sender: iobjectlink;
               const event: objecteventty);
var
 conn1: tcustomiochannel;
begin
 if (event = oe_destroyed) and (rlo_closeconnonfree in foptions) and 
                                    (sender.getinstance = fmodule) then begin
  conn1:= tcustommodulelink(fowner).channel;
  if conn1 <> nil then begin
   conn1.active:= false;
  end;
 end;
 inherited;
end;

procedure trxlinkmodule.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  requestmodule;
 end;
end;

procedure trxlinkmodule.domodulereceived;
begin
 if tcustommodulelink(fowner).canevent(tmethod(fonmodulereceived)) then begin
  fonmodulereceived(self);
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
 str2:= stringtoutf8ansi(avalue);
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
 datapo:= po1 + sizeof(ifidataheaderty);
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
    fmsestringvalue:= utf8tostringansi(str1);
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
 result:= ansistring(getasmsestring);
end;

procedure tvaluelink.setasansistring(const avalue: ansistring);
begin
 setasmsestring(msestring(avalue));
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
 po2:= nil;
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
      tkInteger,{$ifdef FPC}tkBool,{$endif}tkInt64,tkset: begin
       setordprop(instance,aproperty,aslargeint);
      end;
      tkFloat: begin
       setfloatprop(instance,aproperty,asfloat);
      end;
      tkWString: begin
       setwidestrprop(instance,aproperty,asmsestring);
      end;
     {$if defined(FPC) and (FPC_FULLVERSION >= 20300)}
//     {$ifdef mse_unicodestring}
      tkUString: begin
       setunicodestrprop(instance,aproperty,asmsestring);
      end;
     {$ifend}
     {$ifdef FPC}
      tkSString,tkLString,tkAString: begin
     {$else}
      tkString,tkLString: begin
     {$endif}
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
   tkInteger,{$ifdef FPC}tkBool,{$endif}tkInt64: begin
    sendvalue(aproperty^.name,getordprop(fcomponent,aproperty));
   end;
   tkFloat: begin
   {$ifdef FPC}
    sendvalue(aproperty^.name,double(getfloatprop(fcomponent,aproperty)));
   {$else}
    sendvalue(aproperty^.name,getfloatprop(fcomponent,aproperty));
   {$endif}
   end;
  {$if defined(FPC) and (FPC_FULLVERSION >= 20300)}
//  {$ifdef mse_unicodestring}
   tkUString: begin
    sendvalue(aproperty^.name,getunicodestrprop(fcomponent,aproperty));
   end;
  {$ifend}
   tkWString: begin
    sendvalue(aproperty^.name,getwidestrprop(fcomponent,aproperty));
   end;
  {$ifdef FPC}
   tkSString,tkLString,tkAString: begin
  {$else}
   tkString,tkLString: begin
  {$endif}
    sendvalue(aproperty^.name,getstrprop(fcomponent,aproperty));
   end;
  end;
 end;
end;

procedure tcustomvaluecomponentlink.sendstate(const astate: ifiwidgetstatesty);
begin
 sendvalue(ifiwidgetstatename,{$ifdef FPC}integer{$else}byte{$endif}(astate));
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
  writecomponentmse(stream1,fcomponent);
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
  objecttexttobinarymse(stream1,stream2);
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
// str1: string;
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
 result:= false;
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
// comp1: tmsecomponent;
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
       fmodule:= createtmpmodule(str1,stream1,{$ifdef FPC}@{$endif}moduleloaded);
       fmodule.getcorbainterface(typeinfo(iificommand),fcommandintf);
      finally
       stream1.free;
      end;
     end;
     setlinkedvar(fmodule,fmodule);
     domodulereceived;
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
// int1: integer;
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
  end
  else begin
   raise exception.create('Module resouces for "'+aname+'" class "'+
           mo1.fmoduleclassname+'" not found.');
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
     comp1:= createtmpmodule(str1,stream1,{$ifdef FPC}@{$endif}moduleloaded);
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
      fonwidgetstatechanged(wi1,atag,ifiwidgetstatesty(
      {$ifndef FPC}byte({$endif}asinteger{$ifndef FPC}){$endif}));
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
 result:= false;
 check(fvalues);
 if not result then begin
  check(fvaluecomponents);
 end;
end;

procedure tcustommodulelink.execute(const sender: iificlient);
begin
 //dummy
end;

procedure tcustommodulelink.valuechanged(const sender: iificlient);
begin
 //dummy
end;

procedure tcustommodulelink.dataentered(const sender: iificlient;
               const arow: integer);
begin
 //dummy
end;

procedure tcustommodulelink.updateoptionsedit(var avalue: optionseditty);
begin
 //dummy
end;

procedure tcustommodulelink.closequery(const sender: iificlient;
               var amodalresult: modalresultty);
begin
 //dummy
end;

procedure tcustommodulelink.statechanged(const sender: iificlient;
              const astate: ifiwidgetstatesty);
begin
 //dummy
end;

procedure tcustommodulelink.setvalue(const sender: iificlient; var avalue;
                               var accept: boolean; const arow: integer);
begin
 //dummy
end;

procedure tcustommodulelink.sendmodalresult(const sender: iificlient; 
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

constructor tificontroller.create(const aowner: tcomponent;
                                     const aintf: iactivatorclient);
begin
 foptions:= defaultifirxoptions;
 fdefaulttimeout:= defaultifirxtimeout;
 inherited create(aowner,aintf);
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
 setlinkedvar(avalue,tmsecomponent(fchannel));
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
// tag1: integer;
 str1: string;
 po2: pchar;
// int1: integer;
// mstr1: msestring;
begin
 if (event = oe_dataready) and (sender = fchannel) then begin
  if (length(fchannel.rxdata) >= sizeof(ifiheaderty)) then begin
   with fchannel do begin
    po1:= pifirecty(rxdata);
    with po1^,header do begin
     if (size = length(rxdata)) and (kind in getifireckinds) then begin
      with itemheader do begin 
//       tag1:= tag;
       po2:= @name;
      end;
      inc(po2,ifinametostring(pifinamety(po2),str1));
      if str1 = flinkname then begin
       processdata(po1,po2);
       if answersequence <> 0 then begin
        channel.synchronizer.answerreceived(answersequence);
       end;
//       rxdata:= '';
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

constructor tifidatacol.create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop);
begin
 fselectedrow:= -1;
 inherited;
end;

destructor tifidatacol.destroy;
begin
 freedatalist;
 inherited;
end;

procedure tifidatacol.freedatalist;
begin
 fdata.free;
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
 if fdata = nil then begin
  case datakind of
   idk_integer: begin
    fdata:= tintegerdatalist.create;
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
    fdata:= trealdatalist.create;
   end;
   idk_msestring: begin
    fdata:= tmsestringdatalist.create;
   end;
   idk_msestringint: begin
    fdata:= tmsestringintdatalist.create;
   end;
   idk_bytes: begin
    fdata:= tansistringdatalist.create;
   end;
   idk_realint: begin
    fdata:= trealintdatalist.create;
   end;
   else begin
    raise exception.create('Invalid ifidatakind.');
   end;
  end;
 end;
 fdata.count:= ttxdatagrid(fowner).rowcount;
 fdata.onitemchange:= {$ifdef FPC}@{$endif}dochange;
end;

procedure tifidatacol.checkdatalist(const akind: ifidatakindty);
begin
 if akind <> datakind then begin
  raise exception.create('Wrong datakind.');
 end;
 if fdata = nil then begin
  checkdatalist;
 end;
end;

procedure tifidatacol.dochange(const sender: tdatalist; const aindex: integer);
begin
 if ttxdatagrid(fowner).canevent(tmethod(fonchange)) then begin
  fonchange(self,aindex);
 end;
end;

function tifidatacol.getdatalist: tdatalist;
begin
 checkdatalist;
 result:= fdata;
end;

procedure tifidatacol.datachange(const aindex: integer);
begin
 with ttxdatagrid(fowner).fifi do begin
  if (self.name <> '') and cancommandsend(igo_coldata) and 
                                            (fdata <> nil) then begin
   senditem(ik_coldatachange,[encodecolchangedata(self.name,aindex,fdata)]);
  end;
 end;
end;

function tifidatacol.getasinteger(const aindex: integer): integer;
begin
 checkdatalist(idk_integer);
 result:= tintegerdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasinteger(const aindex: integer; const avalue: integer);
begin
 checkdatalist(idk_integer);
 tintegerdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasint64(const aindex: integer): int64;
begin
 checkdatalist(idk_int64);
 result:= tint64datalist(fdata).items[aindex];
end;

procedure tifidatacol.setasint64(const aindex: integer; const avalue: int64);
begin
 checkdatalist(idk_int64);
 tint64datalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getascurrency(const aindex: integer): currency;
begin
 checkdatalist(idk_currency);
 result:= tcurrencydatalist(fdata).items[aindex];
end;

procedure tifidatacol.setascurrency(const aindex: integer;
               const avalue: currency);
begin
 checkdatalist(idk_currency);
 tcurrencydatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasreal(const aindex: integer): real;
begin
 checkdatalist(idk_real);
 result:= trealdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasreal(const aindex: integer; const avalue: real);
begin
 checkdatalist(idk_real);
 trealdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasmsestring(const aindex: integer): msestring;
begin
 checkdatalist(idk_msestring);
 result:= tmsestringdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasmsestring(const aindex: integer;
               const avalue: msestring);
begin
 checkdatalist(idk_msestring);
 tmsestringdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasbytes(const aindex: integer): ansistring;
begin
 checkdatalist(idk_bytes);
 result:= tansistringdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasbytes(const aindex: integer;
               const avalue: ansistring);
begin
 checkdatalist(idk_bytes);
 tansistringdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasmsestringint(const aindex: integer): msestringintty;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdata).doubleitems[aindex];
end;

procedure tifidatacol.setasmsestringint(const aindex: integer;
               const avalue: msestringintty);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdata).doubleitems[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasmsestringinti(const aindex: integer): integer;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdata).itemsb[aindex];
end;

procedure tifidatacol.setasmsestringinti(const aindex: integer;
               const avalue: integer);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdata).itemsb[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasmsestringints(const aindex: integer): msestring;
begin
 checkdatalist(idk_msestringint);
 result:= tmsestringintdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasmsestringints(const aindex: integer;
               const avalue: msestring);
begin
 checkdatalist(idk_msestringint);
 tmsestringintdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasrealint(const aindex: integer): realintty;
begin
 checkdatalist(idk_realint);
 result:= trealintdatalist(fdata).doubleitems[aindex];
end;

procedure tifidatacol.setasrealint(const aindex: integer;
               const avalue: realintty);
begin
 checkdatalist(idk_realint);
 trealintdatalist(fdata).doubleitems[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasrealintr(const aindex: integer): realty;
begin
 checkdatalist(idk_realint);
 result:= trealintdatalist(fdata).items[aindex];
end;

procedure tifidatacol.setasrealintr(const aindex: integer;
               const avalue: realty);
begin
 checkdatalist(idk_realint);
 trealintdatalist(fdata).items[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getasrealinti(const aindex: integer): integer;
begin
 checkdatalist(idk_realint);
 result:= trealintdatalist(fdata).itemsb[aindex];
end;

procedure tifidatacol.setasrealinti(const aindex: integer;
               const avalue: integer);
begin
 checkdatalist(idk_realint);
 trealintdatalist(fdata).itemsb[aindex]:= avalue;
 datachange(aindex);
end;

function tifidatacol.getmerged(const row: integer): boolean;
begin
 if index = 0 then begin
  result:= false;
 end
 else begin
  if index > mergedcolmax then begin
   result:= tifidatacols(prop).frowstate.getitempocolmerge(row)^.colmerge.merged = mergedcolall;
  end
  else begin
   result:= tifidatacols(prop).frowstate.getitempocolmerge(row)^.colmerge.merged and 
                                                          bits[index-1] <> 0;
  end;
 end;
end;

procedure tifidatacol.setmerged(const row: integer; const avalue: boolean);
begin
 if (index > 0) and (index <= mergedcolmax) then begin
  if updatebit(tifidatacols(prop).frowstate.getitempocolmerge(row)^.colmerge.merged,index-1,
                                   avalue) then begin
   ttxdatagrid(fowner).rowstatechanged(row);
  end;
 end;
end;

function tifidatacol.getselected(row: integer): boolean;
begin
 if ident <= selectedcolmax then begin
  if row >= 0 then begin
   result:= (icos_selected in fstate) or
    (tifidatacols(prop).frowstate.getitempo(row)^.selected and
     (bits[ident] or wholerowselectedmask) <> 0);
  end
  else begin
   result:= icos_selected in fstate;
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure tifidatacol.setselected(row: integer; const avalue: boolean);
var
 po1: prowstatety;
 ca1: longword;
 int1: integer;
begin
 if ident <= selectedcolmax then begin
  if row >= 0 then begin
   with tifidatacols(prop).frowstate.getitempo(row)^ do begin
    ca1:= selected;
    if avalue then begin
     ca1:= selected or bits[ident];
    end
    else begin
     ca1:= selected and not (bits[ident] {or wholerowselectedmask});
    end;
    if ca1 <> selected then begin
     if avalue then begin
      if fselectedrow = -1 then begin
       fselectedrow:= row;
      end
      else begin
       fselectedrow:= -2;
      end;
     end
     else begin
      if fselectedrow = row then begin
       fselectedrow:= -1;
      end;
     end;
//     invalidatecell(row);
     doselectionchanged;
    end;
   end;
  end
  else begin //row < 0
   if avalue then begin
    if not (icos_selected in fstate) then begin
     include(fstate,icos_selected);
     fselectedrow:= -2;
//     changed;
     doselectionchanged;
    end;
   end
   else begin
    exclude(fstate,icos_selected);
    if fselectedrow <> -1 then begin
     po1:= tifidatacols(prop).frowstate.datapo;
     ca1:= not (bits[ident] {or wholerowselectedmask});
     if fselectedrow >= 0 then begin
      prowstateaty(po1)^[fselectedrow].selected:= 
               prowstateaty(po1)^[fselectedrow].selected and ca1;
//      invalidatecell(fselectedrow);
//      cellchanged(fselectedrow);
     end
     else begin
      for int1:= 0 to ttxdatagrid(fowner).frowcount - 1 do begin
       po1^.selected:= po1^.selected and ca1;
       inc(po1);
      end;
//      changed;
     end;
     fselectedrow:= -1;
     doselectionchanged;
    end;
   end;
  end;
 end;
end;

procedure tifidatacol.doselectionchanged;
begin
 //dummy
end;

procedure tifidatacol.beginselect;
begin
end;

procedure tifidatacol.endselect;
begin
end;

{ tifidatacols }

constructor tifidatacols.create(const aowner: ttxdatagrid);
begin
 fselectedrow:= -1;
 frowstate:= tifirowstatelist.create(ril_colmerge);
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

function tifidatacols.datalistbyname(const aname: ansistring): tdatalist;
var
 col1: tifidatacol;
begin
 result:= nil;
 col1:= colbyname(aname);
 if col1 <> nil then begin
  result:= col1.datalist;
 end;
end;

function tifidatacols.getselectedcells: gridcoordarty;
const
 capacitystep = 64;
var
 int1,int2,int3: integer;
 cell: gridcoordty;
 bo1: boolean;
begin
 result:= nil;
 if hasselection then begin          //todo: optimize
  int3:= 0;
  bo1:= hascolselection;
  for int1:= 0 to frowstate.count - 1 do begin
   if bo1 or (frowstate.getitempo(int1)^.selected <> 0) then begin
    cell.row:= int1;
    for int2:= 0 to count - 1 do begin
     if tifidatacol(fitems[int2]).selected[int1] then begin
      if int3 >= length(result) then begin
       setlength(result,length(result)*2 + capacitystep);
      end;
      cell.col:= int2;
      result[int3]:= cell;
      inc(int3);
     end;
    end;
   end;
  end;
  setlength(result,int3);
 end;
end;

procedure tifidatacols.setselectedcells(const avalue: gridcoordarty);
var
 int1: integer;
begin
 ttxdatagrid(fowner).beginupdate;
 beginselect;
 clearselection;
 for int1:= 0 to high(avalue) do begin
  setselected(avalue[int1],true);
 end;
 endselect;
 ttxdatagrid(fowner).endupdate;
end;

function tifidatacols.Getselected(const cell: gridcoordty): boolean;
var
 int1: integer;
begin
 if cell.col >= 0 then begin
  result:= cols[cell.col].getselected(cell.row);
 end
 else begin
  if cell.row >= 0 then begin
   result:= (frowstate.getitempo(cell.row)^.selected and wholerowselectedmask <> 0);
  end
  else begin
   result:= true;
   for int1:= 0 to count - 1 do begin
    if not (icos_selected in cols[int1].fstate) then begin
     result:= false;
     break;
    end;
   end;
  end;
 end;
end;

procedure tifidatacols.Setselected(const cell: gridcoordty;
               const avalue: boolean);
var
 lwo1: longword;
// bo1: boolean;
 po1: prowstatety;
 int1: integer;
begin
 ttxdatagrid(fowner).setselected(cell,avalue);
 if cell.col >= 0 then begin
  cols[cell.col].setselected(cell.row,avalue);
 end
 else begin            //select-deselect whole row
//  fgrid.beginupdate;
//  try
  for int1:= 0 to count - 1 do begin
   cols[int1].setselected(cell.row,avalue);
  end;
  if avalue then begin
   lwo1:= $ffffffff;
  end
  else begin
   lwo1:= 0;
  end;
//  bo1:= false;
  if cell.row >= 0 then begin
   po1:= frowstate.getitempo(cell.row);
   if lwo1 <> po1^.selected then begin
    if avalue then begin
     if fselectedrow = -1 then begin
      fselectedrow:= cell.row;
     end
     else begin
      fselectedrow:= -2;
     end;
    end
    else begin
     if fselectedrow = cell.row then begin
      fselectedrow:= -1;
     end;
    end;
    po1^.selected:= lwo1;
//     fgrid.invalidaterow(cell.row); //for fixcols
//    bo1:= true;
   end;
  end
  else begin
   po1:= frowstate.datapo;
   if avalue then begin
    for int1:= 0 to frowstate.count - 1 do begin
//      if ca1 <> po1^.selected then begin
      po1^.selected:= lwo1;
//       fgrid.invalidaterow(int1); //for fixcols
//      end;
     inc(po1);
    end;
    fselectedrow:= -2;
   end
   else begin
    if fselectedrow <> -1 then begin
     if fselectedrow >= 0 then begin
      prowstateaty(po1)^[fselectedrow].selected:= lwo1;
//       fgrid.invalidaterow(fselectedrow); //for fixcols
//      bo1:= true;
     end
     else begin
      for int1:= 0 to frowstate.count - 1 do begin
       if lwo1 <> po1^.selected then begin
        po1^.selected:= lwo1;
//         fgrid.invalidaterow(int1); //for fixcols
//        bo1:= true;
       end;
       inc(po1);
      end;
     end;
     fselectedrow:= -1;
    end;
   end;
  end;
 end;
//   if bo1 then begin
//    fgrid.internalselectionchanged;
//   end;

end;

function tifidatacols.selectedcellcount: integer;
var
 int1,int2: integer;
 bo1: boolean;
begin
 result:= 0;
 if hasselection then begin
  bo1:= hascolselection;
  for int1:= 0 to frowstate.count - 1 do begin
   if bo1 or (frowstate.getitempo(int1)^.selected <> 0) then begin
    for int2:= 0 to count - 1 do begin
     if tifidatacol(fitems[int2]).selected[int1] then begin
      inc(result);
     end;
    end;
   end;
  end;
 end;
end;

function tifidatacols.hascolselection: boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to count - 1 do begin
  if icos_selected in tifidatacol(fitems[int1]).fstate then begin
   result:= true;
   exit;
  end;
 end;
end;

procedure tifidatacols.setselectedrange(const rect: gridrectty;
               const value: boolean);
begin
 setselectedrange(rect.pos,
      makegridcoord(rect.col+rect.colcount,rect.row+rect.rowcount),
      value);
end;

procedure tifidatacols.setselectedrange(const start: gridcoordty;
               const stop: gridcoordty; const value: boolean);
var
 int1,int2: integer;
// mo1: cellselectmodety;
 rect: gridrectty;
begin
 rect.pos:= start;
 rect.colcount:= stop.col - start.col;
 rect.rowcount:= stop.row - start.row;
 normalizerect1(rectty(rect)); 
 for int1:= rect.col to rect.col + rect.colcount - 1 do begin
  cols[int1].beginselect;   
  for int2:= rect.row to rect.row + rect.rowcount - 1 do begin
   selected[makegridcoord(int1,int2)]:= value;
  end;
 end;
 for int1:= rect.col to rect.col + rect.colcount - 1 do begin
  dec(cols[int1].fselectlock);
 end;
end;

procedure tifidatacols.mergecols(const arow: integer;
               const astart: longword = 0; const acount: longword = bigint);
begin
 if frowstate.mergecols(arow,astart,acount) then begin
  ttxdatagrid(fowner).rowstatechanged(arow);
 end;
end;

procedure tifidatacols.unmergecols(const arow: integer = invalidaxis);
begin
 if frowstate.unmergecols(arow) then begin
  ttxdatagrid(fowner).rowstatechanged(arow);
 end;
end;

function tifidatacols.hasselection: boolean;
var
 int1: integer;
begin
 result:= fselectedrow <> -1;
 if not result then begin
  for int1:= 0 to count - 1 do begin
   if cols[int1].fselectedrow <> -1 then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

procedure tifidatacols.beginselect;
begin
end;

procedure tifidatacols.endselect;
begin
end;

procedure tifidatacols.clearselection;
begin
 setselected(invalidcell,false);
end;

{ ttxdatagrid }

constructor ttxdatagrid.create(aowner: tcomponent);
begin
 fifi:= ttxdatagridcontroller.create(self,iactivatorclient(self));
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
     if fdata <> nil then begin
      fdata.count:= avalue;
     end;
    end;
   end;
   frowstate.count:= avalue;
  end;
 end;
end;

function ttxdatagrid.getrowcolorstate(index: integer): rowstatenumty;
begin
 result:= fdatacols.frowstate.color[index];
end;

procedure ttxdatagrid.setrowcolorstate(index: integer;
               const avalue: rowstatenumty);
begin
 fdatacols.frowstate.color[index]:= avalue;
 rowstatechanged(index);
end;

function ttxdatagrid.getrowfontstate(index: integer): rowstatenumty;
begin
 result:= fdatacols.frowstate.font[index];
end;

procedure ttxdatagrid.setrowfontstate(index: integer;
               const avalue: rowstatenumty);
begin
 fdatacols.frowstate.font[index]:= avalue;
 rowstatechanged(index);
end;

function ttxdatagrid.getrowreadonlystate(const index: integer): boolean;
begin
 result:= fdatacols.frowstate.readonly[index];
end;

procedure ttxdatagrid.setrowreadonlystate(const index: integer;
               const avalue: boolean);
begin
 fdatacols.frowstate.readonly[index]:= avalue;
 rowstatechanged(index);
end;

function ttxdatagrid.getrowhidden(const index: integer): boolean;
begin
 result:= fdatacols.frowstate.hidden[index];
end;

procedure ttxdatagrid.setrowhidden(const index: integer;
               const avalue: boolean);
begin
 fdatacols.frowstate.hidden[index]:= avalue;
end;

function ttxdatagrid.getrowfoldlevel(const index: integer): byte;
begin
 result:= fdatacols.frowstate.foldlevel[index];
end;

procedure ttxdatagrid.setrowfoldlevel(const index: integer;
               const avalue: byte);
begin
 fdatacols.frowstate.foldlevel[index]:= avalue;
end;

function ttxdatagrid.getrowfoldissum(const index: integer): boolean;
begin
 result:= fdatacols.frowstate.foldissum[index];
end;

procedure ttxdatagrid.setrowfoldissum(const index: integer;
               const avalue: boolean);
begin
 fdatacols.frowstate.foldissum[index]:= avalue;
end;

function ttxdatagrid.getrowhigh: integer;
begin
 result:= frowcount - 1;
end;

procedure ttxdatagrid.moverow(const curindex: integer; const newindex: integer;
               const count: integer = 1);
var
 int1: integer;
begin
 with fdatacols do begin
  for int1:= 0 to high(fitems) do begin
   with tifidatacol(fitems[int1]) do begin
    if fdata <> nil then begin
     fdata.blockmovedata(curindex,newindex,count);
    end;
   end;
  end;
  frowstate.blockmovedata(curindex,newindex,count);
 end;
 if canevent(tmethod(fonrowsmoved)) then begin
  fonrowsmoved(self,curindex,newindex,count);
 end;  
 with fifi do begin
  if cancommandsend(igo_rowmove) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_moverow,curindex,newindex,count)]);
  end;
 end;
end;

procedure ttxdatagrid.insertrow(index: integer; count: integer = 1);
var
 int1: integer;
begin
 with fdatacols do begin
  for int1:= 0 to high(fitems) do begin
   with tifidatacol(fitems[int1]) do begin
    if fdata <> nil then begin
     fdata.insertitems(index,count);
    end;
   end;
  end;
  frowstate.insertitems(index,count);
 end;
 if canevent(tmethod(fonrowsinserted)) then begin
  fonrowsinserted(self,index,count);
 end;  
 with fifi do begin
  if cancommandsend(igo_rowinsert) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_insertrow,index,index,count)]);
  end;
 end;
end;

procedure ttxdatagrid.deleterow(index: integer; count: integer = 1);
var
 int1: integer;
begin
 with fdatacols do begin
  for int1:= 0 to high(fitems) do begin
   with tifidatacol(fitems[int1]) do begin
    if fdata <> nil then begin
     fdata.deleteitems(index,count);
    end;
   end;
  end;
  frowstate.deleteitems(index,count);
 end;
 if canevent(tmethod(fonrowsdeleted)) then begin
  fonrowsdeleted(self,index,count);
 end;  
 with fifi do begin
  if cancommandsend(igo_rowdelete) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_deleterow,index,index,count)]);
  end;
 end;
end;

procedure ttxdatagrid.setrow(const avalue: integer);
begin
 frow:= avalue;
 if canevent(tmethod(fonrowindexchanged)) then begin
  fonrowindexchanged(self);
 end;
 with fifi do begin
  if cancommandsend(igo_rowenter) then begin
   senditem(ik_gridcommand,
                   [encodegridcommanddata(gck_rowenter,avalue,avalue,0)]);
  end;
 end;
end;

procedure ttxdatagrid.rowstatechanged(const aindex: integer);
begin
 if canevent(tmethod(fonrowstatechanged)) then begin
  fonrowstatechanged(self,aindex);
 end;
 with fifi do begin
  if cancommandsend(igo_rowstate) then begin
   senditem(ik_rowstatechange,
         [encoderowstatedata(aindex,fdatacols.rowstate.itemscolmerge[aindex])]);
  end;
 end;
end;

procedure ttxdatagrid.beginupdate;
begin
 fifi.beginupdate;
end;

procedure ttxdatagrid.endupdate;
begin
 fifi.endupdate;
end;

procedure ttxdatagrid.clear;
begin
 rowcount:= 0;
end;

procedure ttxdatagrid.setselected(const cell: gridcoordty;
               const avalue: boolean);
begin
 with fifi do begin
  if cancommandsend(igo_selection) then begin
   senditem(ik_selection,[encodeselectiondata(cell,avalue)]);
  end;
 end;
end;

{ tifigridcontroller }

function tifigridcontroller.getifireckinds: ifireckindsty;
begin
 result:= [ik_griddata,ik_requestopen,ik_gridcommand,
           ik_coldatachange,ik_rowstatechange,ik_selection];
end;

function tifigridcontroller.cancommandsend(
          const akind: ifigridoptionty): boolean;
begin
 result:= (akind in foptionstx) and (fcommandlock = 0) and 
                                        (fupdating = 0) and cansend;
end;

procedure tifigridcontroller.sendstate;
begin
 if cansend then begin
  senddata(encodegriddata(0));  
 end;
end;

procedure tifigridcontroller.beginupdate;
begin
 inc(fupdating);
end;

procedure tifigridcontroller.endupdate;
begin
 dec(fupdating);
 if (fupdating = 0) and cancommandsend(igo_state) then begin
  sendstate;
 end;
end;

{ ttxdatagridcontroller }

constructor ttxdatagridcontroller.create(const aowner: ttxdatagrid;
                    const aintf: iactivatorclient);
begin
 inherited create(aowner,aintf);
end;

procedure ttxdatagridcontroller.processdata(const adata: pifirecty;
               var adatapo: pchar);
var
 int1: integer;
 rows1,cols1: integer;
 kind1: listdatatypety;
 po1: pchar;
 str1: ansistring;
 datalist1: tdatalist;
 ckind1: gridcommandkindty;
 source1,dest1,count1: integer;
 rowstate1: rowstatecolmergety;
 lwo1: longword;
 select1: selectdataty;

begin
 with adata^.header do begin
  case kind of
   ik_requestopen: begin
    with ttxdatagrid(fowner) do begin
     if canevent(tmethod(fonbeforeopen)) then begin
      inc(fcommandlock);
      inc(fupdating);
      try
       fonbeforeopen(ttxdatagrid(fowner));
      finally
       dec(fcommandlock);
       dec(fupdating);
      end;      
     end;
    end;
    senddata(encodegriddata(sequence));
   end;
   ik_griddata: begin
    if (igo_state in foptionsrx) then begin
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
        inc(po1,ifidatatodatalist(kind1,rows1,po1,
                       datacols.datalistbyname(str1)));
       end;
      end;
     end;
    end;
   end;
   ik_gridcommand: begin
    inc(adatapo,decodegridcommanddata(adatapo,ckind1,source1,dest1,count1));
    with ttxdatagrid(fowner) do begin
     inc(fcommandlock);
     try
      case ckind1 of
       gck_insertrow: begin
        if igo_rowinsert in foptionsrx then begin
         insertrow(dest1,count1);       
        end;
       end;
       gck_deleterow: begin
        if igo_rowdelete in foptionsrx then begin
         deleterow(dest1,count1);       
        end;
       end;
       gck_moverow: begin
        if igo_rowmove in foptionsrx then begin
         moverow(source1,dest1,count1);       
        end;
       end;
       gck_rowenter: begin
        if igo_rowenter in foptionsrx then begin
         row:= dest1;
        end;
       end;
      end;
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_coldatachange: begin
    if igo_coldata in foptionsrx then begin
     inc(fcommandlock);
     try
      int1:= pcolitemdataty(adatapo)^.header.row;
      ifinametostring(@pcolitemdataty(adatapo)^.header.name,str1);
      inc(adatapo,sizeof(colitemheaderty)+length(str1));
      datalist1:= nil;
      if igo_coldata in foptionsrx then begin
       datalist1:= ttxdatagrid(fowner).fdatacols.datalistbyname(str1);
      end;    //skip data otherwise
      inc(adatapo,decodeifidata(pifidataty(adatapo),int1,datalist1));
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_rowstatechange: begin
    if igo_rowstate in foptionsrx then begin
     inc(fcommandlock);
     try
      int1:= prowstatedataty(adatapo)^.header.row;
      inc(adatapo,sizeof(rowstateheaderty));
      inc(adatapo,decodeifidata(pifidataty(adatapo),rowstate1));
      with ttxdatagrid(fowner),rowstate1 do begin
       rowcolorstate[int1]:= normal.color;
       rowfontstate[int1]:= normal.font;
       lwo1:= fdatacols.rowstate[int1].selected;
       if lwo1 <> normal.selected then begin
        fdatacols.rowstate.getitempo(int1)^.selected:= lwo1;
       end;
       rowhidden[int1]:= normal.fold and foldhiddenmask <> 0;
       rowfoldlevel[int1]:= normal.fold and foldlevelmask;
      end;
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_selection: begin
    if igo_selection in foptionsrx then begin
     inc(fcommandlock);
     try
      inc(adatapo,decodeifidata(pifidataty(adatapo),select1));
      with ttxdatagrid(fowner),select1 do begin
       fdatacols.selected[makegridcoord(col,row)]:= select;
      end;
     finally
      dec(fcommandlock);
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
{
function ttxdatagridcontroller.getifireckinds: ifireckindsty;
begin
 result:= [ik_requestopen,ik_griddata,ik_gridcommand,ik_coldatachange,
           ik_rowstatechange];
end;
}
function ifidatatodatalist(const akind: listdatatypety; const arowcount: integer;
                       const adata: pchar; const adatalist: tdatalist): integer;
       //returns datasize
var
 info1: subdatainfoty;
begin
 info1.subindex:= 0;
 info1.list:= adatalist;
 result:= ifidatatodatalist(akind,arowcount,adata,info1);
end;

function ifidatatodatalist(const akind: listdatatypety; const arowcount: integer;
                       const adata: pchar; const adatalist: subdatainfoty): integer;
var
 int1,int2: integer;
 posource,podest: pchar;
 movesize,sourcestep,deststep: integer;
 po1: pmsestring; 
 po2: pinteger;
 po3: pansistring;
 po4: pmsestringintty;
begin
 with adatalist do begin
  if (list <> nil) and (list.datatype <> akind) and 
      not((akind = dl_realint) and (list.datatype = dl_realsum)) then begin
   raise exception.create('Datakinds do not match.');
  end;
  case akind of
   dl_integer: begin
    result:= arowcount * sizeof(integer);
    if list <> nil then begin
     move(adata^,list.datapo^,result);
    end;
   end;
   dl_int64: begin
    result:= arowcount * sizeof(int64);
    if list <> nil then begin
     move(adata^,list.datapo^,result);
    end;
   end;
   dl_currency: begin
    result:= arowcount * sizeof(currency);
    if list <> nil then begin
     move(adata^,list.datapo^,result);
    end;
   end;
   dl_real: begin
    result:= arowcount * sizeof(real);
    if list <> nil then begin
     move(adata^,list.datapo^,result);
    end;
   end;
   dl_msestring: begin
    po2:= pinteger(adata);
    result:= arowcount * sizeof(integer);
    if list <> nil then begin
     deststep:= list.size;
     po1:= list.datapo;
     for int1:= 0 to arowcount - 1 do begin
      move(po2^,int2,sizeof(integer));
      setlength(po1^,int2);
      int2:= int2 * sizeof(msechar);
      result:= result + int2;
      inc(po2);
      move(po2^,pointer(po1^)^,int2);
      inc(pchar(pointer(po2)),int2);
      inc(pchar(po1),deststep);
     end;
    end
    else begin
     for int1:= 0 to arowcount - 1 do begin
      int2:= po2^*sizeof(msechar);
      result:= result + int2;
      inc(po2);
      inc(pchar(pointer(po2)),int2);
     end;
    end;    
   end;
   dl_msestringint: begin
    po2:= pinteger(adata);
    result:= arowcount * (sizeof(integer)+sizeof(integer));
    if list <> nil then begin
     po4:= list.datapo;
     deststep:= list.size;
     for int1:= 0 to arowcount - 1 do begin
      move(po2^,po4^.int,sizeof(integer));
      inc(po2);
      move(po2^,int2,sizeof(integer));
      setlength(po4^.mstr,int2);
      int2:= int2 * sizeof(msechar);
      result:= result + int2;
      inc(po2);
      move(po2^,po4^.mstr[1],int2);
      inc(pchar(pointer(po2)),int2);
      inc(pchar(po4),deststep);
     end;
    end
    else begin
     for int1:= 0 to arowcount - 1 do begin
      inc(po2);
      int2:= po2^*sizeof(msechar);
      result:= result + int2;
      inc(po2);
      inc(pchar(pointer(po2)),int2);
     end;
    end;
   end;
   dl_realint,dl_realsum: begin
    result:= list.setdatablock(adata,sizeof(ifirealintty),arowcount);
    exit;
   end;
   dl_rowstate: begin
    move(adata^,int1,sizeof(int1));
    posource:= adata;
    inc(posource,sizeof(int1));
    sourcestep:= rowinfosizes[rowinfolevelty(int1)];
    result:= arowcount * sourcestep;
    if list <> nil then begin
 //    tcustomrowstatelist1(adatalist).initdirty;
     if tcustomrowstatelist(list).infolevel = 
                  rowinfolevelty(int1) then begin
      move(posource^,list.datapo^,result);
     end
     else begin
      podest:= list.datapo;
      deststep:= list.size;
      movesize:= deststep;
      if movesize > sourcestep then begin
       movesize:= sourcestep;
      end;
      for int2:= 0 to arowcount - 1 do begin
       move(posource^,podest^,movesize);
       inc(posource,sourcestep);
       inc(podest,deststep);
      end;
     end;
     tcustomrowstatelist1(list).recalchidden;
    end;
    result:= result + sizeof(int1);
   end;
   dl_ansistring: begin
    po2:= pinteger(adata);
    result:= arowcount * sizeof(integer);
    if list <> nil then begin
     deststep:= list.size;
     po3:= list.datapo;
     for int1:= 0 to arowcount - 1 do begin
      move(po2^,int2,sizeof(integer));
      setlength(po3^,int2);
      result:= result + int2;
      inc(po2);
      move(po2^,pansistringaty(po3)^[int1][1],int2);
      inc(pchar(pointer(po2)),int2);
      inc(pchar(po3),deststep);
     end;
    end
    else begin
     for int1:= 0 to arowcount - 1 do begin
      int2:= po2^;
      result:= result + int2;
      inc(po2);
      inc(pchar(pointer(po2)),int2);
     end;
    end;    
   end;
   else begin
    raise exception.create('Invalid datakind.');
   end;
  end;
  if list <> nil then begin
   list.change(-1);
  end;
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
  case datatype of
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
   dl_realint,dl_realsum: begin
    inc(dest,getdatablock(dest,sizeof(ifirealintty)));
   end;
   dl_msestring: begin
    for int1:= 0 to count - 1 do begin
     int2:= length(pmsestringaty(po4)^[int1]);
     move(int2,dest^,sizeof(integer));
     int2:= int2 * sizeof(msechar);
     inc(dest,sizeof(integer));
     move(pointer(pmsestringaty(po4)^[int1])^,dest^,int2);
     inc(dest,int2);
    end;
   end;
   dl_msestringint: begin
    for int1:= 0 to count - 1 do begin
     move(pmsestringintaty(po4)^[int1].int,dest^,sizeof(integer));
     inc(dest,sizeof(integer));
     int2:= length(pmsestringintaty(po4)^[int1].mstr);
     move(int2,dest^,sizeof(integer));
     int2:= int2 * sizeof(msechar);
     inc(dest,sizeof(integer));
     move(pmsestringintaty(po4)^[int1].mstr[1],dest^,int2);
     inc(dest,int2);
    end;
   end;
   dl_rowstate: begin
    int1:= integer(tcustomrowstatelist(adatalist).infolevel);
    move(int1,dest^,sizeof(integer));
    inc(dest,sizeof(integer));
    int2:= count * size;
    move(po4^,dest^,int2);
    inc(dest,int2);
   end;
   dl_ansistring: begin
    for int1:= 0 to count - 1 do begin
     int2:= length(pansistringaty(po4)^[int1]);
     move(int2,dest^,sizeof(integer));
     inc(dest,sizeof(integer));
     move(pointer(pansistringaty(po4)^[int1])^,dest^,int2);
     inc(dest,int2);
    end;
   end;
   else begin
    raise exception.create('No ifi datalist');
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
 s1: integer;
begin
 with adatalist do begin
  s1:= size;
  case adatalist.datatype of
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
     result:= result + length(po1^) * sizeof(msechar);
     inc(pchar(po1),s1);
    end;
   end;
   dl_msestringint: begin
    po3:= datapo;
    result:= count * (sizeof(integer)+sizeof(integer));
    for int1:= 0 to count - 1 do begin
     result:= result + length(po3^.mstr) * sizeof(msechar);
     inc(pchar(po3),s1);
    end;
   end;
   dl_realint,dl_realsum: begin
    result:= count * sizeof(ifirealintty);
   end;
   dl_rowstate: begin
    result:= count * size + sizeof(integer);
   end;
   dl_ansistring: begin
    po2:= datapo;
    result:= count * sizeof(integer);
    for int1:= 0 to count - 1 do begin
     result:= result + length(po2^);
     inc(pchar(po2),s1);
    end;
   end;
   else begin
    raise exception.create('No ifi datalist.');
   end;
  end;
 end;
end;

function ttxdatagridcontroller.encodegriddata(
                     const asequence: sequencety): ansistring;
var
 po1{,po4}: pchar;
 int1,int2{,int3,int4}: integer;
// po2: pmsestring;
// po3: pansistring;
 ar1: booleanarty;
begin
 with ttxdatagrid(fowner) do begin
  setlength(ar1,datacols.count);
  int2:= 0;
  for int1:= 0 to datacols.count - 1 do begin
   with datacols[int1] do begin
    checkdatalist;
    ar1[int1]:= (name <> '') and (datalist.datatype in ifidatatypes);
    if ar1[int1] then begin
     int2:= int2 + (sizeof(listdatatypety)+1) + length(name) + 
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
       kind:= datalist.datatype;
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

{ tifirowstatelist }

procedure tifirowstatelist.sethidden(const index: integer;
               const avalue: boolean);
begin
 updatebit(getitempo(index)^.fold,foldhiddenbit,avalue);
end;

procedure tifirowstatelist.setfoldlevel(const index: integer;
               const avalue: byte);
begin
 replacebits1(byte(getitempo(index)^.fold),byte(avalue),byte(foldlevelmask));
end;

procedure tifirowstatelist.setfoldissum(const index: integer;
               const avalue: boolean);
begin
 updatebit(getitempo(index)^.flags,foldissumbit,avalue);
end;

end.

