unit mseifilink;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,mseifiglob,mseifi,msearrayprops,mseact,mseevent,mseglob,
 msestrings,msetypes,msedatalist;
 
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
   property tag: integer read ftag write ftag;
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
   function byname(const aname: string): trxlinkmodule;
   property items[const index: integer]: trxlinkmodule read getitems; default;   
 end;

 tvaluelink = class;
 
 propertychangedeventty = procedure(const sender: tvaluelink;
                 const atag: integer; const apropertyname: string) of object;

//todo: beginupdate/endupdate
 tvaluelink = class(tmodulelinkprop)
  private
   fint64value: int64;
   fdoublevalue: double;
   fmsestringvalue: msestring;
//   fansistringvalue: ansistring;
   fdatakind: ifidatakindty;
   fonpropertychanged: propertychangedeventty;
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
   procedure setdata(const adata: pifidataty); virtual;
   procedure initpropertyrecord(out arec: string; const apropertyname: string;
       const akind: ifidatakindty; const datasize: integer; out datapo: pchar);
   procedure sendvalue(const aname: string; const avalue: int64); overload;
   procedure sendvalue(const aname: string; const avalue: double); overload;
   procedure sendvalue(const aname: string; const avalue: msestring); overload;
   procedure sendvalue(const aname: string; const avalue: ansistring); overload;
   procedure sendcommand(const acommand: ifiwidgetcommandty);
  public
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
 end;

 tvaluelinks = class(tmodulelinkarrayprop) 
  private
   function getitems(const index: integer): tvaluelink;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   function byname(const aname: string): tvaluelink;
   property items[const index: integer]: tvaluelink read getitems; default;   
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
  protected
   fvalues: tvaluelinks;
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
   property channel;
   property options;
 end;

 ifirxoptionty = (irxo_useclientchannel,irxo_postecho); 
 ifirxoptionsty = set of ifirxoptionty;
const 
 defaultifirxoptions = [irxo_useclientchannel];
 defaultifirxtimeout = 10000000; //10 second
type 
 tificontroller = class(teventpersistent,iifimodulelink)
  private
   fchannel: tcustomiochannel;
   flinkname: string;
   ftag: integer;
   fdefaulttimeout: integer;
   procedure setchannel(const avalue: tcustomiochannel);
  protected
   fowner: tcomponent;
   foptions: ifirxoptionsty;
   procedure objectevent(const sender: tobject; const event: objecteventty);
                                                        override;   
   function senddata(const adata: ansistring; 
                         const asequence: sequencety = 0): sequencety;
   function senddataandwait(const adata: ansistring;
            out asequence: sequencety; atimeoutus: integer = 0): boolean;
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
  published
   property channel: tcustomiochannel read fchannel write setchannel;
   property linkname: string read flinkname write flinkname;
   property tag: integer read ftag write ftag;
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
   procedure setdatakind(const avalue: ifidatakindty);
  protected
   procedure freedatalist;
   procedure checkdatalist;
  public
   destructor destroy; override;
  published
   property datakind: ifidatakindty read fdatakind write setdatakind;
 end;
  
 ttxdatagrid = class;
 
 tifidatacols = class(townedpersistentarrayprop)
  public 
   constructor create(const aowner: ttxdatagrid);
 end;
 
 ttxdatagrid = class(tmsecomponent)
  private
   fifi: tifitxcontroller;
   fdatacols: tifidatacols;
   procedure setifi(const avalue: tifitxcontroller);
   procedure setdatacols(const avalue: tifidatacols);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property ifi: tifitxcontroller read fifi write setifi;
   property datacols: tifidatacols read fdatacols write setdatacols;
 end;
   
implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules,mseapplication;

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

procedure tvaluelink.setdata(const adata: pifidataty);
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
   {
   idk_ansistring: begin
    ifinametostring(pifinamety(@data),str1);
    fansistringvalue:= str1;
   end;
   }
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

{ tvaluelinks }

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

{ tcustommodulelink }

constructor tcustommodulelink.create(aowner: tcomponent);
begin
 foptions:= defaultformlinkoptions;
 factionsrx:= trxlinkactions.create(self);
 factionstx:= ttxlinkactions.create(self);
 fmodulestx:= ttxlinkmodules.create(self);
 fmodulesrx:= trxlinkmodules.create(self);
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
     fmodule:= createtmpmodule(str1,stream1,@moduleloaded);
     fmodule.getcorbainterface(typeinfo(iificommand),fcommandintf);
    finally
     stream1.free;
    end;
   end;
   setlinkedvar(fmodule,fmodule);
  end;
//  application.postevent(tmoduledataevent.create(fchannel.rxdata,ievent(self),
//                       mo1,adata));
 end;
end;

function tcustommodulelink.propertychangereceived(const atag: integer;
                     const aname: string; const apropertyname: string;
                     const adata: pifidataty): boolean;
var
 wi1: tvaluelink;
begin
 wi1:= tvaluelink(fvalues.finditem(aname));
 result:= wi1 <> nil;
 if result then begin
  with wi1 do begin
   setdata(adata);
   if assigned(fonpropertychanged) then begin
    fonpropertychanged(wi1,atag,apropertyname);
   end;
  end;
 end;    
end;

procedure tcustommodulelink.valuechanged(const sender: iifiwidget);
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
 fowner:= aowner;
 foptions:= defaultifirxoptions;
 fdefaulttimeout:= defaultifirxtimeout;
 inherited create;
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
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tificontroller.getifireckinds: ifireckindsty;
begin
 result:= [];
end;

{ ttxdatagrid }

constructor ttxdatagrid.create(aowner: tcomponent);
begin
 fifi:= tifitxcontroller.create(self);
 inherited;
 fdatacols:= tifidatacols.create(self);
end;

destructor ttxdatagrid.destroy;
begin
 inherited;
 fifi.free;
end;

procedure ttxdatagrid.setifi(const avalue: tifitxcontroller);
begin
 fifi.assign(avalue);
end;

procedure ttxdatagrid.setdatacols(const avalue: tifidatacols);
begin
 fdatacols.assign(avalue);
end;

{ tifidatacols }

constructor tifidatacols.create(const aowner: ttxdatagrid);
begin
 inherited create(aowner,tifidatacol);
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

end;

end.
