unit mseifilink;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,mseifiglob,mseifi,msearrayprops,mseact,mseevent,mseglob,
 msestrings,msetypes;
 
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
 
 trxlinkaction = class(tlinkaction)
 end;
 ttxlinkaction = class(tlinkaction)
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  public
   procedure execute;
 end;
 
 tlinkactions = class(tmodulelinkarrayprop)
  private
  protected
  public
 end;

 trxlinkactions = class(tlinkactions)
  private
   fonexecute: integerchangedeventty;
   function getitems(const index: integer): trxlinkaction;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   function byname(const aname: string): trxlinkaction;
   property items[const index: integer]: trxlinkaction read getitems; default;
  published
   property onexecute: integerchangedeventty read fonexecute write fonexecute;
               //sender = item, avalue = tx tag
 end;
 
 ttxlinkactions = class(tlinkactions)
  private
   function getitems(const index: integer): ttxlinkaction;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   constructor create(const aowner: tcustommodulelink);
   function byname(const aname: string): ttxlinkaction;
   property items[const index: integer]: ttxlinkaction read getitems; default;
 end;

 tlinkmodule = class(tmodulelinkprop)
 end;
 
 ttxlinkmodule = class(tlinkmodule)
  private
   fmoduleclassname: string;
  published
   property moduleclassname: string read fmoduleclassname write fmoduleclassname;
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

 tcustommodulelink = class(tifiiolinkcomponent,iifiserver)
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
   function encodeactionfired(const atag: integer; const aname: string): string;
   procedure actionfired(const sender: tlinkaction); virtual;
   procedure actionreceived(const atag: integer; const aname: string);
   procedure requestmodulereceived(const atag: integer; const aname: string;
                                    const asequence: sequencety);
   procedure moduledatareceived(const atag: integer; const aname: string;
                   const asequence: sequencety; const adata: pmoduledatadataty);
   procedure propertychangereceived(const atag: integer; const aname: string;
                      const apropertyname: string; const adata: pifidataty);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure processdataitem(const adata: pifirecty; var adatapo: pchar;
                  const atag: integer; const aname: string); virtual;
   procedure processdata(const adata: pifirecty);
   function senddata(const adata: ansistring): sequencety;
                //returns sequence number
   //iifiserver
   procedure valuechanged(const sender: iifiwidget); virtual;
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
 
implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules;
 
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
 tcustommodulelink(fowner).actionfired(self);
end;

procedure ttxlinkaction.objectevent(const sender: tobject;
                                          const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  execute;
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

{ ttxlinkactions }

constructor ttxlinkactions.create(const aowner: tcustommodulelink);
begin
 inherited create(aowner);
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

procedure tcustommodulelink.actionfired(const sender: tlinkaction);
begin
 if fchannel <> nil then begin
  fchannel.senddata(encodeactionfired(sender.tag,sender.name));
 end;
end;

function tcustommodulelink.encodeactionfired(const atag: integer;
               const aname: string): string;
var
 po1: pchar;
begin
 initifirec(result,ik_actionfired,0,length(aname),po1);
 with pifirecty(result)^.actionfired.header do begin
  tag:= atag;
  stringtoifiname(aname,@name);
 end;
end;

procedure tcustommodulelink.objectevent(const sender: tobject;
               const event: objecteventty);
var
 po1: pifirecty;
begin
 if (event = oe_dataready) and (sender = fchannel) then begin
  if (length(fchannel.rxdata) >= sizeof(ifiheaderty)) then begin
   with fchannel do begin
    po1:= pifirecty(rxdata);
    with po1^.header do begin
     if size = length(rxdata) then begin
      processdata(po1);
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustommodulelink.processdataitem(const adata: pifirecty; 
           var adatapo: pchar; const atag: integer; const aname: string);
var
 str2: string;
begin
 with adata^ do begin
  case header.kind of
   ik_actionfired: begin
    actionreceived(atag,aname);
   end;
   ik_propertychanged: begin
    with propertychanged.header do begin
     inc(adatapo,ifinametostring(pifinamety(adatapo),str2));
     propertychangereceived(atag,aname,str2,pifidataty(adatapo));
    end;
   end;
   ik_requestmodule: begin
    requestmodulereceived(atag,aname,adata^.header.sequence);          
   end;
   ik_moduledata: begin
    moduledatareceived(atag,aname,header.answersequence,
                           pmoduledatadataty(adatapo));
   end;
  end;
 end;
end;

procedure tcustommodulelink.processdata(const adata: pifirecty);
         //todo: optimize link name check
var 
 tag1: integer;
 str1: string;
 po1: pchar;
 ar1: stringarty;
begin 
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
   processdataitem(adata,po1,tag1,str1);
  end;
 end;
end;

procedure tcustommodulelink.actionreceived(const atag: integer;
               const aname: string);
var
 act1: trxlinkaction;
 int1: integer;
begin
 with factionsrx do begin
  act1:= trxlinkaction(finditem(aname));
  if act1 <> nil then begin
   if assigned(fonexecute) then begin
    fonexecute(act1,atag);
   end;
   with act1 do begin
    if (faction <> nil) and faction.enabled then begin
     faction.execute;
    end;
   end;
  end;
 end;
end;

procedure tcustommodulelink.requestmodulereceived(const atag: integer;
            const aname: string; const asequence: sequencety);
var
 mo1: ttxlinkmodule;
 po1: pobjectdataty;
 str1,str2: string;
 po2,po3: pchar;
begin
debugwriteln('requestmodule '+aname);
 mo1:= ttxlinkmodule(fmodulestx.finditem(aname));
 if (mo1 <> nil) and (mo1.fmoduleclassname <> '') then begin
  po1:= findmoduledata(mo1.fmoduleclassname,str2);
  if po1 <> nil then begin
   mo1.inititemheader(str1,ik_moduledata,asequence,length(str2)+po1^.size,po2);
   with pmoduledatadataty(po2)^ do begin
//    sequence:= asequence;
    po3:= @parentclass;
    inc(po3,stringtoifiname(str2,pifinamety(po3)));
    setifibytes(@po1^.data,po1^.size,pifibytesty(po3));
   end;
   senddata(str1);
  end;
 end;
end;

procedure tcustommodulelink.moduledatareceived(const atag: integer;
 const aname: string; const asequence: sequencety; const adata: pmoduledatadataty);
var
 mo1: trxlinkmodule;
 comp1: tmsecomponent;
 stream1: tmemorycopystream;
 str1: string;
 po1: pchar;
 int1: integer;
 comp2: tcomponent;
begin
 mo1:= fmodulesrx.finditem(asequence);
 if mo1 <> nil then begin
  po1:= @adata^.parentclass;
  inc(po1,ifinametostring(pifinamety(po1),str1));
  with mo1 do begin
   freeandnil(fmodule);
   with pifibytesty(po1)^ do begin
    stream1:= tmemorycopystream.create(@data,length);
    try
     fmodule:= createtmpmodule(str1,stream1);
     with fmodule do begin
      for int1:= 0 to componentcount - 1 do begin
       comp2:= components[int1];
       if comp2 is tcustommodulelink then begin
        with tcustommodulelink(comp2) do begin
         if flo_useclientchannel in options then begin
          channel:= self.channel;
         end;
        end;
       end; 
      end;
     end;
    finally
     stream1.free;
    end;
   end;
   setlinkedvar(fmodule,fmodule);
  end;
 end;
end;

procedure tcustommodulelink.propertychangereceived(const atag: integer;
                     const aname: string; const apropertyname: string;
                     const adata: pifidataty);
var
 wi1: tvaluelink;
begin
 wi1:= tvaluelink(fvalues.finditem(aname));
 if wi1 <> nil then begin
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

end.
