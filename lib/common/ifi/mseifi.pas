unit mseifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msearrayprops,mseactions,msestrings,msetypes,mseevent,
 mseguiglob,msestream,msepipestream,msegui,mseifiglob,typinfo;
type

 ifireckindty = (ik_none,ik_data,ik_itemheader,ik_actionfired,ik_propertychanged,
                 ik_widgetcommand,ik_widgetproperties,ik_requestmodule,ik_moduledata);
 ifinamety = array[0..0] of char; //null terminated
 pifinamety = ^ifinamety;

 ifidatakindty = (idk_none,idk_int64,idk_real,idk_msestring,idk_ansistring);
 
 datarecty = record //dummy
 end;
 
 ifidataty = record
  kind: ifidatakindty;
  data: datarecty; //variable length
 end;
 pifidataty = ^ifidataty;

 ifibytesty = record
  length: integer;
  data: datarecty;
 end;
 pifibytesty = ^ifibytesty;
 
 itemheaderty = record  
  tag: integer;
  name: ifinamety;
 end;
 pitemheaderty = ^itemheaderty;
  
 actionfiredty = record
  header: itemheaderty;
 end;

 propertychangedty = record
  header: itemheaderty;
  propertyname: ifinamety;
  data: ifidataty;
 end;
 ppropertychangedty = ^propertychangedty;

 ifiwidgetcommandty = (iwc_enable,iwc_disable,iwc_show,iwc_hide);
 pifiwidgetcommandty = ^ifiwidgetcommandty;
 widgetcommandty = record
  header: itemheaderty;
  command: ifiwidgetcommandty;
 end;

 widgetpropertiesty = record
  header: itemheaderty;
  streamdata: ifibytesty;
 end;
 pwidgetpropertiesty = ^widgetpropertiesty;

 requestmodulety = record
  header: itemheaderty;
  moduleclassname: ifinamety;
 end;
 
 moduledatadataty = record
  sequence: longword;
  parentclass: ifinamety;
  data: ifibytesty;
 end;
 pmoduledatadataty = ^moduledatadataty;
 
 moduledataty = record
  header: itemheaderty;
  data: moduledatadataty;
 end;
  
const
 ifiitemkinds = [ik_actionfired,ik_propertychanged,ik_widgetcommand,
                 ik_widgetproperties,ik_requestmodule,ik_moduledata];
 
type 
 ifiheaderty = record
  size: integer;  //overall size
  sequence: longword;
  kind: ifireckindty;
 end;
 pifiheaderty = ^ifiheaderty;
 
 ifirecty = record
  header: ifiheaderty;
  case ifireckindty of
   ik_data:(
    data: ifidataty;
   );
   ik_itemheader:(
    itemheader: itemheaderty;
   );
   ik_actionfired:(
    actionfired: actionfiredty;
   );
   ik_propertychanged:(
    propertychanged: propertychangedty;
   );
   ik_widgetcommand: (
    widgetcommand: widgetcommandty;
   );
   ik_requestmodule: (
    requestmodule: requestmodulety;
   );
   ik_moduledata: (
    moduledata: moduledataty;
   )
 end;
 pifirecty = ^ifirecty;
  
 tformlinkarrayprop = class;
 
 tformlinkprop = class(townedeventpersistent)
  private
   fprop: tformlinkarrayprop;
   fname: ansistring;
   ftag: integer;
  protected
   procedure inititemheader(out arec: string;
                  const akind: ifireckindty; const datasize: integer;
                  out datapo: pchar); virtual;
 published
   property name: ansistring read fname write fname;
   property tag: integer read ftag write ftag;
 end;
 formlinkpropclassty = class of tformlinkprop;
   
 tcustomformlink = class;

 tformlinkarrayprop = class(tpersistentarrayprop)
  private
   fowner: tcustomformlink;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomformlink; 
                           const aitemclass: formlinkpropclassty);
   function finditem(const aname: string): tformlinkprop;
   function byname(const aname: string): tformlinkprop;
 end; 
 
 tlinkaction = class(tformlinkprop)
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
 end;
 
 tlinkactions = class(tformlinkarrayprop)
  private
  protected
  public
 end;

 trxlinkactions = class(tlinkactions)
  private
   fonexecute: integerchangedeventty;
   function getitems(const index: integer): trxlinkaction;
  public
   constructor create(const aowner: tcustomformlink);
   function byname(const aname: string): trxlinkaction;
   property items[const index: integer]: trxlinkaction read getitems; default;
  published
   property onexecute: integerchangedeventty read fonexecute write fonexecute;
 end;
 
 ttxlinkactions = class(tlinkactions)
  private
   function getitems(const index: integer): ttxlinkaction;
  public
   constructor create(const aowner: tcustomformlink);
   function byname(const aname: string): ttxlinkaction;
   property items[const index: integer]: ttxlinkaction read getitems; default;
 end;

 tlinkdatawidget = class;
 
 propertychangedeventty = procedure(const sender: tlinkdatawidget;
                 const tag: integer; const propertyname: string) of object;

//todo: beginupdate/endupdate
 tlinkdatawidget = class(tformlinkprop)
  private
   fwidget: twidget;
   fintf: iifiwidget;
   fvalueproperty: ppropinfo;
   fint64value: int64;
   fdoublevalue: double;
   fmsestringvalue: msestring;
   fansistringvalue: ansistring;
   fdatakind: ifidatakindty;
   fupdatelock: integer;
   fonpropertychanged: propertychangedeventty;
   procedure setwidget(const avalue: twidget);
   procedure setdata(const adata: pifidataty);
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
   procedure checkwidget;
  protected
   procedure initpropertyrecord(out arec: string; const apropertyname: string;
       const akind: ifidatakindty; const datasize: integer; out datapo: pchar);
   procedure sendvalue(const aproperty: ppropinfo); overload;
   procedure sendvalue(const aname: string; const avalue: int64); overload;
   procedure sendvalue(const aname: string; const avalue: double); overload;
   procedure sendvalue(const aname: string; const avalue: msestring); overload;
   procedure sendvalue(const aname: string; const avalue: ansistring); overload;
   procedure sendcommand(const acommand: ifiwidgetcommandty);
  public
   procedure sendproperties;
   property asinteger: integer read getasinteger write setasinteger;
   property aslargeint: int64 read getaslargeint write setaslargeint;
   property asfloat: double read getasfloat write setasfloat;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property asstring: string read getasansistring write setasansistring;
   property enabled: boolean write setenabled;
   property visible: boolean write setvisible;
  published
   property widget: twidget read fwidget write setwidget;
   property onpropertychanged: propertychangedeventty read fonpropertychanged 
                                     write fonpropertychanged;
 end;

 tlinkdatawidgets = class(tformlinkarrayprop) 
  private
   function getitems(const index: integer): tlinkdatawidget;
  protected
  public
   constructor create(const aowner: tcustomformlink);
   function byname(const aname: string): tlinkdatawidget;
   property items[const index: integer]: tlinkdatawidget read getitems; default;   
 end;

 tlinkmodule = class(tformlinkprop)
 end;
 
 ttxlinkmodule = class(tlinkmodule)
  private
   fmoduleclassname: string;
  published
   property moduleclassname: string read fmoduleclassname write fmoduleclassname;
 end;
  
 ttxlinkmodules = class(tformlinkarrayprop)
  private
   function getitems(const index: integer): ttxlinkmodule;
  protected
  public
   constructor create(const aowner: tcustomformlink);
   function byname(const aname: string): ttxlinkmodule;
   property items[const index: integer]: ttxlinkmodule read getitems; default;   
 end;

 trxlinkmodule = class;
 rxlinkmoduleeventty = procedure(sender: trxlinkmodule) of object;

 trxlinkmodule = class(tlinkmodule)
  private
   fmodule: tmsecomponent;
   fonmodulereceived: rxlinkmoduleeventty;
   fsequence: longword;
  public
   procedure requestmodule;
   property module: tmsecomponent read fmodule;
  published
   property onmodulereceived: rxlinkmoduleeventty read fonmodulereceived 
                         write fonmodulereceived;
 end;
  
 trxlinkmodules = class(tformlinkarrayprop)
  private
   function getitems(const index: integer): trxlinkmodule;
  protected
  public
   constructor create(const aowner: tcustomformlink);
   function byname(const aname: string): trxlinkmodule;
   property items[const index: integer]: trxlinkmodule read getitems; default;   
 end;
 
 tcustomiochannel = class(tmsecomponent)
  private
   frxdata: string;
   factive: boolean;
   procedure setactive(const avalue: boolean);
  protected
   function checkconnection: boolean;
   procedure datareceived(const adata: ansistring);
   procedure senddata(const adata: ansistring);   
   procedure open; virtual; abstract;
   procedure close; virtual; abstract;
   function commio: boolean; virtual; abstract;
   procedure internalsenddata(const adata: ansistring); virtual; abstract;
   procedure loaded; override;
  public
   destructor destroy; override;
   property active: boolean read factive write setactive;
   property rxdata: string read frxdata write frxdata;
 end;

 pipeiostatety = (pis_rxstarted);
 pipeiostatesty = set of pipeiostatety;
 
 tpipeiochannel = class(tcustomiochannel)
  private
   freader: tpipereader;
   fwriter: tpipewriter;
   fapplication: string;
   fprochandle: integer;
   fbuffer: string;
   fstate: pipeiostatesty;
   frxcheckedindex: integer;
   function stuff(const adata: string): string;
   function unstuff(const adata: string): string;
   procedure resetrxbuffer;
   procedure addata(const adata: string);
  protected
   procedure open; override;
   procedure close; override;   
   function commio: boolean; override;
   procedure internalsenddata(const adata: ansistring); override;
   procedure doinputavailable(const sender: tpipereader);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property application: string read fapplication write fapplication;
            //stdin, stdout if ''
   property active;
 end;
  
 tcustomformlink = class(tmsecomponent,iifiserver)
  private
   factionsrx: trxlinkactions;
   factionstx: ttxlinkactions;
   fdatawidgets: tlinkdatawidgets;
   fchannel: tcustomiochannel;
   fsequence: longword;
   fmodulestx: ttxlinkmodules;
   fmodulesrx: trxlinkmodules;
   procedure setactionsrx(const avalue: trxlinkactions);
   procedure setactionstx(const avalue: ttxlinkactions);
   procedure setchannel(const avalue: tcustomiochannel);
   procedure setdatawidgets(const avalue: tlinkdatawidgets);
   function hasconnection: boolean;
   procedure setmodulestx(const avalue: ttxlinkmodules);
   procedure setmodulesrx(const avalue: trxlinkmodules);
  protected
   procedure initifirec(out arec: string; const akind: ifireckindty; 
                             const datalength: integer; out datapo: pchar);
   function encodeactionfired(const atag: integer; const aname: string): string;
   procedure actionfired(const sender: tlinkaction); virtual;
   procedure actionreceived(const atag: integer; const aname: string);
   procedure propertychangereceived(const atag: integer; const aname: string;
                      const apropertyname: string; const adata: pifidataty);
   procedure widgetcommandreceived(const atag: integer; const aname: string;
                      const acommand: ifiwidgetcommandty);
   procedure widgetpropertiesreceived(const atag: integer; const aname: string;
                      const adata: pifibytesty);
   procedure requestmodulereceived(const atag: integer; const aname: string;
                                    const asequence: longword);
   procedure moduledatareceived(const atag: integer; const aname: string;
                                    const adata: pmoduledatadataty);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure processdata(const adata: pifirecty);
   procedure senddata(const adata: ansistring);
   //iifiserver
   procedure valuechanged(const sender: iifiwidget);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updatecomponent(const anamepath: ansistring;
                                const aobjecttext: ansistring);
   property actionsrx: trxlinkactions read factionsrx write setactionsrx;
   property actionstx: ttxlinkactions read factionstx write setactionstx;
   property datawidgets: tlinkdatawidgets read fdatawidgets 
                                         write setdatawidgets;
   property modulesrx: trxlinkmodules read fmodulesrx write setmodulesrx;
   property modulestx: ttxlinkmodules read fmodulestx write setmodulestx;
   property channel: tcustomiochannel read fchannel write setchannel;
 end;

 tformlink = class(tcustomformlink)
  published
   property actionsrx;
   property actionstx;
   property datawidgets;
   property modulesrx;
   property modulestx;
   property channel;
 end;
  
implementation
uses
 sysutils,msedatalist,mseprocutils,msesysintf,mseforms,msetmpmodules;

const
 headersizes: array[ifireckindty] of integer = (
  sizeof(ifiheaderty),                           //ik_none
  sizeof(ifiheaderty),                           //ik_data
  sizeof(ifiheaderty)+sizeof(itemheaderty),      //ik_itemheader
  sizeof(ifiheaderty)+sizeof(actionfiredty),     //ik_actionfired
  sizeof(ifiheaderty)+sizeof(propertychangedty), //ik_propertychanged
  sizeof(ifiheaderty)+sizeof(widgetcommandty),   //ik_widgetcommand
  sizeof(ifiheaderty)+sizeof(widgetpropertiesty),//ik_widgetproperties
  sizeof(ifiheaderty)+sizeof(requestmodulety),   //ik_requestmodule
  sizeof(ifiheaderty)+sizeof(moduledataty)       //ik_moduledata
 );

 datarecsizes: array[ifidatakindty] of integer = (
  sizeof(ifidataty),                             //idk_none
  sizeof(ifidataty)+sizeof(int64),               //idk_int64
  sizeof(ifidataty)+sizeof(double),              //idk_real
  sizeof(ifidataty)+sizeof(ifinamety),           //idk_msestring
  sizeof(ifidataty)+sizeof(ifinamety)            //idk_ansistring
  );

 stuffchar = c_dle;
 stx = c_dle + c_stx;
 etx = c_dle + c_etx;

function stringtoifiname(const source: string;
               const dest: pifinamety): integer;
var
 int1: integer;
begin
 int1:= length(source);
 if int1 > 0 then begin
  move(source[1],dest^,int1);
 end;
 pchar(dest)[int1]:= #0;
 result:= int1 + 1;
end;

function ifinametostring(const source: pifinamety;
               out dest: string): integer;
begin
 dest:= pchar(source);
 result:= length(dest) + 1;
end;

function setifibytes(const source: pointer; const size: integer;
                 const dest: pifibytesty): integer;
begin
 result:= sizeof(ifibytesty) + size;
 dest^.length:= size;
 move(source^,dest^.data,size);
end;

{ tcustomiochannel }

destructor tcustomiochannel.destroy;
begin
 close;
 inherited;
end;

function tcustomiochannel.checkconnection: boolean;
begin
 result:= commio;
 if not result then begin
  close;
  open;
  result:= commio;
 end;
end;

procedure tcustomiochannel.senddata(const adata: ansistring);
begin
 checkconnection;
 internalsenddata(adata);
end;

procedure tcustomiochannel.datareceived(const adata: ansistring);
begin
 frxdata:= adata;
 sendchangeevent(oe_dataready);
end;

procedure tcustomiochannel.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  if componentstate * [csloading,csdesigning] = [] then begin
   if avalue then begin
    open;
   end
   else begin
    close;
   end;
  end;
 end;
end;

procedure tcustomiochannel.loaded;
begin
 inherited;
 if factive and not (csdesigning in componentstate) then begin
  open;
 end;
end;

{ tpipeiochannel }

constructor tpipeiochannel.create(aowner: tcomponent);
begin
 freader:= tpipereader.create;
 fwriter:= tpipewriter.create;
 fprochandle:= invalidprochandle;
 freader.oninputavailable:= @doinputavailable;
 inherited;
end;

destructor tpipeiochannel.destroy;
begin
 inherited;
 fwriter.free;
 freader.free;
end;

procedure tpipeiochannel.open;
begin
 if fapplication <> '' then begin
  fprochandle:= execmse2(fapplication,fwriter,freader);
 end
 else begin
  freader.handle:= sys_stdin;
  fwriter.handle:= sys_stdout;
 end;
end;

procedure tpipeiochannel.close;
var
 int1: integer;
begin
 freader.terminate; 
 fwriter.close;
 freader.close;
 fbuffer:= '';
 if fprochandle <> invalidprochandle then begin
  int1:= fprochandle;
  fprochandle:= invalidprochandle;
  killprocess(int1);
 end; 
end;

function tpipeiochannel.commio: boolean;
begin
 result:= ((fapplication = '') or (fprochandle <> invalidprochandle))
                     and freader.active;
end;

procedure tpipeiochannel.internalsenddata(const adata: ansistring);
begin
 fwriter.writestr(stx+stuff(adata)+etx);
end;

procedure tpipeiochannel.resetrxbuffer;
begin
 fbuffer:= '';
 exclude(fstate,pis_rxstarted); 
 frxcheckedindex:= 0;
end;

procedure tpipeiochannel.addata(const adata: string);
var
 int1,int2: integer;
 po1: pchar;
 str1: string;
begin
 fbuffer:= fbuffer + adata;
 int1:= length(fbuffer);
 if (pis_rxstarted in fstate) then begin
  if (int1 >= 2) then begin
   for int2:= int1 downto frxcheckedindex + 2 do begin
    if (fbuffer[int2] = c_etx) and (fbuffer[int2-1] = c_dle) then begin
     str1:= copy(fbuffer,int2+1,int1); //next frame
     setlength(fbuffer,int2-2);
     datareceived(unstuff(fbuffer));
     resetrxbuffer;
     if str1 <> '' then begin
      addata(str1);
     end;
     exit;
    end;
   end;
  end;
  frxcheckedindex:= int1 - 1;
 end
 else begin
  for int2:= 1 to int1-1 do begin
   if (fbuffer[int2] = c_dle) and (fbuffer[int2+1] = c_stx) then begin
    fbuffer:= copy(fbuffer,int2+2,int1);
    include(fstate,pis_rxstarted);
    addata('');
    break;
   end;
  end;
 end;
end;

procedure tpipeiochannel.doinputavailable(const sender: tpipereader);
var
 int1: integer;
begin
 addata(sender.readdatastring);
end;

function tpipeiochannel.stuff(const adata: string): string;
var
 int1: integer;
 po1,po2: pchar;
begin
 setlength(result,2*length(adata)); //max
 po1:= pointer(adata);
 po2:= pointer(result);
 for int1:= 0 to length(adata) - 1 do begin
  po2^:= po1[int1];
  if po2^ = stuffchar then begin
   inc(po2);
   po2^:= stuffchar;
  end;
  inc(po2);
 end;
 setlength(result,po2-pointer(result));
end;

function tpipeiochannel.unstuff(const adata: string): string;
var
 int1: integer;
 po1,po2,po3: pchar;
begin
 setlength(result,length(adata)); //max
 po1:= pointer(adata);
 po3:= po1 + length(adata);
 po2:= pointer(result);
 while po1 < po3 do begin
  po2^:= po1^;
  if (po1^ = stuffchar) and (po1[1] = stuffchar) then begin
   inc(po1);
  end;
  inc(po1);
  inc(po2);
 end;
 setlength(result,po2-pointer(result));
end;

{ tformlinkprop }

procedure tformlinkprop.inititemheader(out arec: string;
               const akind: ifireckindty; const datasize: integer;
               out datapo: pchar);
var
 po1: pchar; 
begin
 tcustomformlink(fowner).initifirec(arec,akind,datasize+length(fname),po1);
 with pitemheaderty(po1)^ do begin
  tag:= ftag;
  po1:= @name;
 end;
 inc(po1,stringtoifiname(fname,pifinamety(po1)));
 datapo:= po1;
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
 
procedure ttxlinkaction.objectevent(const sender: tobject;
                                          const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  tcustomformlink(fowner).actionfired(self);
 end;
end;

{ tformlinkarrayprop }

constructor tformlinkarrayprop.create(const aowner: tcustomformlink; 
                                   const aitemclass: formlinkpropclassty);
begin
 fowner:= aowner;
 inherited create(aitemclass);
end;

procedure tformlinkarrayprop.createitem(const index: integer; var item: tpersistent);
begin
 item:= formlinkpropclassty(fitemclasstype).create(fowner);
 tformlinkprop(item).fprop:= self;
end;

function tformlinkarrayprop.finditem(const aname: string): tformlinkprop;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if tformlinkprop(fitems[int1]).fname = aname then begin
   result:= tformlinkprop(fitems[int1]);
   exit;
  end;
 end;
end;

function tformlinkarrayprop.byname(const aname: string): tformlinkprop;
begin
 result:= finditem(aname);
 if result = nil then begin
  raise exception.create(fowner.name+': array property "'+aname+'" not found.');
 end;
end;

{ trxlinkactions }

constructor trxlinkactions.create(const aowner: tcustomformlink);
begin
 inherited create(aowner,trxlinkaction);
end;

function trxlinkactions.getitems(const index: integer): trxlinkaction;
begin
 result:= trxlinkaction(inherited getitems(index));
end;

function trxlinkactions.byname(const aname: string): trxlinkaction;
begin
 result:= trxlinkaction(inherited byname(aname));
end;

{ ttxlinkactions }

constructor ttxlinkactions.create(const aowner: tcustomformlink);
begin
 inherited create(aowner,ttxlinkaction);
end;

function ttxlinkactions.getitems(const index: integer): ttxlinkaction;
begin
 result:= ttxlinkaction(inherited getitems(index));
end;

function ttxlinkactions.byname(const aname: string): ttxlinkaction;
begin
 result:= ttxlinkaction(inherited byname(aname));
end;

{ tlinkdatawidget }

procedure tlinkdatawidget.setwidget(const avalue: twidget);
var
 intf1: iifiwidget;
begin
 intf1:= nil;
 fvalueproperty:= nil;
 if (avalue <> nil) and 
    not getcorbainterface(avalue,typeinfo(iifiwidget),intf1) then begin
  raise exception.create(avalue.name+': No ifiwidget.');
 end;
 if fintf <> nil then begin
  fintf.setifiserverintf(nil);
 end;
 fintf:= intf1;
 if fintf <> nil then begin
  fintf.setifiserverintf(iifiserver(tcustomformlink(fowner)));
 end;
 fwidget:= avalue;
 if avalue <> nil then begin
  fvalueproperty:= getpropinfo(avalue,'value');
 end;
end;

procedure tlinkdatawidget.sendvalue(const aproperty: ppropinfo);
begin
 if aproperty <> nil then begin
  case aproperty^.proptype^.kind of
   tkInteger,tkBool,tkInt64: begin
    sendvalue(aproperty^.name,getordprop(fwidget,aproperty));
   end;
   tkFloat: begin
    sendvalue(aproperty^.name,double(getfloatprop(fwidget,aproperty)));
   end;
   tkWString: begin
    sendvalue(aproperty^.name,getwidestrprop(fwidget,aproperty));
   end;
   tkSString,tkLString,tkAString: begin
    sendvalue(aproperty^.name,getstrprop(fwidget,aproperty));
   end;
  end;
 end;
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: int64);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_real,0,po1); 
 pint64(po1)^:= avalue;
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: double);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_real,0,po1);
 pdouble(po1)^:= avalue;
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: msestring);
var
 str1,str2: string;
 po1: pchar;
begin
 str2:= stringtoutf8(avalue);
 initpropertyrecord(str1,aname,idk_msestring,length(str2),po1);
 stringtoifiname(str2,pifinamety(po1));
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: ansistring);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_ansistring,length(avalue),po1);
 stringtoifiname(avalue,pifinamety(po1));
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.initpropertyrecord(out arec: string;
          const apropertyname: string; const akind: ifidatakindty;
          const datasize: integer; out datapo: pchar);
var
 po1: pchar; 
begin
 inititemheader(arec,ik_propertychanged,datarecsizes[akind]+
                length(apropertyname)+datasize,po1);
       
 inc(po1,stringtoifiname(apropertyname,pifinamety(po1)));
 pifidataty(po1)^.kind:= akind;
 datapo:= po1 + sizeof(ifidataty.kind);
end;

procedure tlinkdatawidget.sendcommand(const acommand: ifiwidgetcommandty);
var
 str1: string;
 po1: pchar;
begin
 inititemheader(str1,ik_widgetcommand,0,po1);
 pifiwidgetcommandty(po1)^:= acommand;
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.sendproperties;
var
 stream1: tmemorystream;
 str1: string;
 po1: pchar;
begin
 checkwidget;
 stream1:= tmemorystream.create;
 try
  stream1.writecomponent(fwidget);
  inititemheader(str1,ik_widgetproperties,stream1.size,po1);
  setifibytes(stream1.memory,stream1.size,pifibytesty(po1));
 finally
  stream1.free;
 end;
 tcustomformlink(fowner).senddata(str1);
end;

procedure tlinkdatawidget.setdata(const adata: pifidataty);
var
 str1: string;
begin
 with adata^ do begin
  fdatakind:= kind;
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
   idk_ansistring: begin
    ifinametostring(pifinamety(@data),str1);
    fansistringvalue:= str1;
   end;
  end;
  if fvalueproperty <> nil then begin
   inc(fupdatelock);
   try
    case fvalueproperty^.proptype^.kind of
     tkInteger,tkBool,tkInt64: begin
      setordprop(fwidget,fvalueproperty,aslargeint);
     end;
     tkFloat: begin
      setfloatprop(fwidget,fvalueproperty,asfloat);
     end;
     tkWString: begin
      setwidestrprop(fwidget,fvalueproperty,asmsestring);
     end;
     tkSString,tkLString,tkAString: begin
      setstrprop(fwidget,fvalueproperty,asstring);
     end;
    end;
   finally
    dec(fupdatelock);
   end;
  end;
 end;
end;

procedure tlinkdatawidget.checkdatakind(const akind: ifidatakindty);
begin
 if fdatakind <> akind then begin
  raise exception.create('Invalid datakind');
 end;
end;

function tlinkdatawidget.getasinteger: integer;
begin
 checkdatakind(idk_int64);
 result:= fint64value;
end;

procedure tlinkdatawidget.setasinteger(const avalue: integer);
begin
 setaslargeint(avalue);
end;

function tlinkdatawidget.getaslargeint: int64;
begin
 checkdatakind(idk_int64);
 result:= fint64value;
end;

procedure tlinkdatawidget.setaslargeint(const avalue: int64);
begin
 fdatakind:= idk_int64;
 fint64value:= avalue;
 sendvalue('value',fint64value);
end;

function tlinkdatawidget.getasfloat: double;
begin
 checkdatakind(idk_real);
 result:= fdoublevalue;
end;

procedure tlinkdatawidget.setasfloat(const avalue: double);
begin
 fdatakind:= idk_real;
 fdoublevalue:= avalue;
 sendvalue('value',fdoublevalue);
end;

function tlinkdatawidget.getasmsestring: msestring;
begin
 if fdatakind = idk_ansistring then begin
  result:= fansistringvalue;
 end
 else begin
  checkdatakind(idk_msestring);
  result:= fmsestringvalue;
 end;
end;

procedure tlinkdatawidget.setasmsestring(const avalue: msestring);
begin
 fdatakind:= idk_msestring;
 fmsestringvalue:= avalue;
 sendvalue('value',fmsestringvalue);
end;

function tlinkdatawidget.getasansistring: ansistring;
begin
 if fdatakind = idk_msestring then begin
  result:= fmsestringvalue;
 end
 else begin
  checkdatakind(idk_ansistring);
  result:= fansistringvalue;
 end;
end;

procedure tlinkdatawidget.setasansistring(const avalue: ansistring);
begin
 fdatakind:= idk_ansistring;
 fansistringvalue:= avalue;
 sendvalue('value',fansistringvalue);
end;

procedure tlinkdatawidget.setenabled(const avalue: boolean);
begin
 if avalue then begin
  sendcommand(iwc_enable);
 end
 else begin
  sendcommand(iwc_disable);
 end;
end;

procedure tlinkdatawidget.setvisible(const avalue: boolean);
begin
 if avalue then begin
  sendcommand(iwc_show);
 end
 else begin
  sendcommand(iwc_hide);
 end;
end;

procedure tlinkdatawidget.checkwidget;
begin
 if fwidget = nil then begin
  exception.create(tcustomformlink(fowner).name+': No widget.');
 end;
end;

{ tlinkdatawidgets }

constructor tlinkdatawidgets.create(const aowner: tcustomformlink);
begin
 inherited create(aowner,tlinkdatawidget);
end;

function tlinkdatawidgets.getitems(const index: integer): tlinkdatawidget;
begin
 result:= tlinkdatawidget(inherited getitems(index));
end;

function tlinkdatawidgets.byname(const aname: string): tlinkdatawidget;
begin
 result:= tlinkdatawidget(inherited byname(aname));
end;

{ trxlinkmodule }

procedure trxlinkmodule.requestmodule;
var
 str1: string;
 po1: pchar;
begin
 inititemheader(str1,ik_requestmodule,0,po1);
 fsequence:= tcustomformlink(fowner).fsequence;
 tcustomformlink(fowner).senddata(str1);
end;

{ ttxlinkmodules }

constructor ttxlinkmodules.create(const aowner: tcustomformlink);
begin
 inherited create(aowner,ttxlinkmodule);
end;

function ttxlinkmodules.getitems(const index: integer): ttxlinkmodule;
begin
 result:= ttxlinkmodule(inherited getitems(index));
end;

function ttxlinkmodules.byname(const aname: string): ttxlinkmodule;
begin
 result:= ttxlinkmodule(inherited byname(aname));
end;

{ trxlinkmodules }

constructor trxlinkmodules.create(const aowner: tcustomformlink);
begin
 inherited create(aowner,trxlinkmodule);
end;

function trxlinkmodules.getitems(const index: integer): trxlinkmodule;
begin
 result:= trxlinkmodule(inherited getitems(index));
end;

function trxlinkmodules.byname(const aname: string): trxlinkmodule;
begin
 result:= trxlinkmodule(inherited byname(aname));
end;

{ tcustomformlink }

constructor tcustomformlink.create(aowner: tcomponent);
begin
 factionsrx:= trxlinkactions.create(self);
 factionstx:= ttxlinkactions.create(self);
 fdatawidgets:= tlinkdatawidgets.create(self);
 fmodulestx:= ttxlinkmodules.create(self);
 fmodulesrx:= trxlinkmodules.create(self);
 inherited;
end;

destructor tcustomformlink.destroy;
begin
 factionsrx.free;
 factionstx.free;
 fdatawidgets.free;
 fmodulesrx.free;
 fmodulestx.free;
 inherited;
end;

procedure tcustomformlink.setactionsrx(const avalue: trxlinkactions);
begin
 factionsrx.assign(avalue);
end;

procedure tcustomformlink.setactionstx(const avalue: ttxlinkactions);
begin
 factionstx.assign(avalue);
end;

procedure tcustomformlink.updatecomponent(const anamepath: ansistring;
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

procedure tcustomformlink.actionfired(const sender: tlinkaction);
begin
 if fchannel <> nil then begin
  fchannel.senddata(encodeactionfired(sender.tag,sender.name));
 end;
end;

procedure tcustomformlink.setchannel(const avalue: tcustomiochannel);
begin
 setlinkedvar(avalue,fchannel);
end;

function tcustomformlink.encodeactionfired(const atag: integer;
               const aname: string): string;
var
 po1: pchar;
begin
 initifirec(result,ik_actionfired,length(aname),po1);
 with pifirecty(result)^.actionfired.header do begin
  tag:= atag;
  stringtoifiname(aname,@name);
 end;
end;

procedure tcustomformlink.initifirec(out arec: string;
               const akind: ifireckindty; const datalength: integer;
               out datapo: pchar);
var
 int1: integer;
begin
 int1:= headersizes[akind] + datalength;
 setlength(arec,int1);
 fillchar(arec[1],int1,0);
 inc(fsequence);
 if fsequence = 0 then begin
  inc(fsequence);
 end;
 with pifiheaderty(arec)^ do begin
  size:= int1;
  sequence:= fsequence;
  kind:= akind;
 end;
 datapo:= pointer(arec) + sizeof(ifiheaderty);
end;

procedure tcustomformlink.objectevent(const sender: tobject;
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

procedure tcustomformlink.processdata(const adata: pifirecty);
var 
 tag1: integer;
 str1,str2: string;
 po1: pchar;
 command1: ifiwidgetcommandty;
begin 
 with adata^ do begin
  if header.kind in ifiitemkinds then begin
   with itemheader do begin 
    tag1:= tag;
    po1:= @name;
   end;
   inc(po1,ifinametostring(pifinamety(po1),str1));
   case header.kind of
    ik_actionfired: begin
     actionreceived(tag1,str1);
    end;
    ik_propertychanged: begin
     with propertychanged.header do begin
      inc(po1,ifinametostring(pifinamety(po1),str2));
      propertychangereceived(tag1,str1,str2,pifidataty(po1));
     end;
    end;
    ik_widgetcommand: begin
     command1:= pifiwidgetcommandty(po1)^;
     widgetcommandreceived(tag1,str1,command1);
    end;
    ik_widgetproperties: begin
     widgetpropertiesreceived(tag1,str1,pifibytesty(po1));     
    end;
    ik_requestmodule: begin
     requestmodulereceived(tag1,str1,adata^.header.sequence);          
    end;
    ik_moduledata: begin
     moduledatareceived(tag1,str1,pmoduledatadataty(po1));
    end;
   end;
  end;
 end;
end;

procedure tcustomformlink.actionreceived(const atag: integer;
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

procedure tcustomformlink.propertychangereceived(const atag: integer;
                     const aname: string; const apropertyname: string;
                     const adata: pifidataty);
var
 wi1: tlinkdatawidget;
begin
 wi1:= tlinkdatawidget(fdatawidgets.finditem(aname));
 if wi1 <> nil then begin
  with wi1 do begin
   setdata(adata);
   if assigned(fonpropertychanged) then begin
    fonpropertychanged(wi1,atag,apropertyname);
   end;
  end;
 end;    
end;

procedure tcustomformlink.widgetcommandreceived(const atag: integer;
             const aname: string; const acommand: ifiwidgetcommandty);
var
 wi1: tlinkdatawidget;
begin
 wi1:= tlinkdatawidget(fdatawidgets.finditem(aname));
 if (wi1 <> nil) and (wi1.fwidget <> nil) then begin
  with wi1.widget do begin
   case acommand of
    iwc_enable: begin
     enabled:= true;
    end;
    iwc_disable: begin
     enabled:= false;
    end;
    iwc_show: begin
     visible:= true;
    end;
    iwc_hide: begin
     visible:= false;
    end;
   end;
  end;
 end;    
end;

procedure tcustomformlink.widgetpropertiesreceived(const atag: integer;
                     const aname: string; const adata: pifibytesty);
var
 wi1: tlinkdatawidget;
 stream1: tmemorystream;
begin
 wi1:= tlinkdatawidget(fdatawidgets.finditem(aname));
 if (wi1 <> nil) and (wi1.fwidget <> nil) then begin
  stream1:= tmemorycopystream.create(@adata^.data,adata^.length);
  try
   stream1.readcomponent(wi1.fwidget);
  finally
   stream1.free;
  end;
 end;
end;

procedure tcustomformlink.requestmodulereceived(const atag: integer;
            const aname: string; const asequence: longword);
var
 mo1: ttxlinkmodule;
 po1: pobjectdataty;
 str1,str2: string;
 po2,po3: pchar;
begin
 mo1:= ttxlinkmodule(fmodulestx.finditem(aname));
 if (mo1 <> nil) and (mo1.fmoduleclassname <> '') then begin
  po1:= findmoduledata(mo1.fmoduleclassname,str2);
  if po1 <> nil then begin
   mo1.inititemheader(str1,ik_moduledata,length(str2)+po1^.size,po2);
   with pmoduledatadataty(po2)^ do begin
    sequence:= asequence;
    po3:= @parentclass;
    inc(po3,stringtoifiname(str2,pifinamety(po3)));
    setifibytes(@po1^.data,po1^.size,pifibytesty(po3));
   end;
   senddata(str1);
  end;
 end;
end;

procedure tcustomformlink.moduledatareceived(const atag: integer;
 const aname: string; const adata: pmoduledatadataty);
var
 mo1: trxlinkmodule;
 comp1: tmsecomponent;
 stream1: tmemorycopystream;
 str1: string;
 po1: pchar;
begin
 mo1:= trxlinkmodule(fmodulesrx.finditem(aname));
 if mo1 <> nil then begin
  if mo1.fsequence = adata^.sequence then begin
   po1:= @adata^.parentclass;
   inc(po1,ifinametostring(pifinamety(po1),str1));
   with mo1 do begin
    freeandnil(fmodule);
    with pifibytesty(po1)^ do begin
     stream1:= tmemorycopystream.create(@data,length);
     try
      fmodule:= createtmpmodule(str1,stream1);
     finally
      stream1.free;
     end;
    end;
    setlinkedvar(fmodule,fmodule);
   end;
  end;
 end;
end;

procedure tcustomformlink.setdatawidgets(const avalue: tlinkdatawidgets);
begin
 fdatawidgets.assign(avalue);
end;

procedure tcustomformlink.valuechanged(const sender: iifiwidget);
var
 int1: integer;
begin
 if hasconnection then begin
  with fdatawidgets do begin
   for int1:= 0 to high(fitems) do begin
    with tlinkdatawidget(fitems[int1]) do begin
     if fupdatelock = 0 then begin
      if (fintf = sender) then begin
       sendvalue(fvalueproperty);
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomformlink.hasconnection: boolean;
begin
 result:= (fchannel <> nil) and fchannel.checkconnection;
end;

procedure tcustomformlink.senddata(const adata: ansistring);
begin
 if fchannel = nil then begin
  raise exception.create(name+': No IO channel assigned.');
 end;
 fchannel.senddata(adata);
end;

procedure tcustomformlink.setmodulestx(const avalue: ttxlinkmodules);
begin
 fmodulestx.assign(avalue);
end;

procedure tcustomformlink.setmodulesrx(const avalue: trxlinkmodules);
begin
 fmodulesrx.assign(avalue);
end;

end.
