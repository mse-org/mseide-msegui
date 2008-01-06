unit mseifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseapplication,mseclasses,msearrayprops,mseact,msestrings,msetypes,mseevent,
 mseglob,msestream,msepipestream,{msegui,}mseifiglob,typinfo,msebintree,
 msesys,msesockets,msecryptio,msethread;
type
 
 sequencety = longword;
 
 ifireckindty = (ik_none,ik_data,ik_itemheader,ik_actionfired,ik_propertychanged,
                 ik_widgetcommand,ik_widgetproperties,ik_requestmodule,ik_moduledata,
                 ik_requestfielddefs,ik_fielddefsdata,ik_fieldrec,
                 ik_requestopends,ik_dsdata,ik_postresult,ik_modulecommand);
const
 ifiitemkinds = [ik_actionfired,ik_propertychanged,ik_widgetcommand,
                 ik_widgetproperties,ik_requestmodule,ik_moduledata,
                 ik_modulecommand];
 ifiasynckinds = [ik_moduledata];
// mainloopifikinds = [ik_moduledata]; 
 
type 
 ifinamety = array[0..0] of char; //null terminated
 pifinamety = ^ifinamety;

 ifidatakindty = (idk_none,idk_null,idk_integer,idk_int64,idk_currency,idk_real,
                  idk_msestring,{idk_ansistring,}idk_bytes);
 
 datarecty = record //dummy
 end;

 ifibytesty = record
  length: integer;
  data: datarecty;
 end;
 pifibytesty = ^ifibytesty;

 ifidataheaderty = record
  kind: ifidatakindty;
 end;   
 ifidataty = record
  header: ifidataheaderty;
  data: datarecty; //variable length
 end;
 pifidataty = ^ifidataty;
 
 itemheaderty = record  
  tag: integer;
  name: ifinamety;
 end;
 pitemheaderty = ^itemheaderty;

 modulecommanddataty = record
  command: ificommandcodety;
 end;  
 pmodulecommanddataty = ^modulecommanddataty;
 modulecommandty = record
  header: itemheaderty;
  data: modulecommanddataty;
 end;
 pmodulecommandty = ^modulecommandty;
 
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
//  sequence: sequencety;
  parentclass: ifinamety;
  data: ifibytesty;
 end;
 pmoduledatadataty = ^moduledatadataty;
 
 moduledataty = record
  header: itemheaderty;
  data: moduledatadataty;
 end;

 requestfielddefsty = record
  header: itemheaderty;
 end;   
 fielddefsdatadataty = record
  data: datarecty; //dummy
 end;
 pfielddefsdatadataty = ^fielddefsdatadataty;
 
 fielddefsdataty = record
  header: itemheaderty;
  data: fielddefsdatadataty;
 end;

 postresultcodety = (pc_none,pc_ok,pc_error);
 
 postresultdataty = record
  code: postresultcodety;
  message: ifinamety; 
 end;
 ppostresultdataty = ^postresultdataty;
 
 postresultty = record
  header: itemheaderty;
  data: postresultdataty;
 end;
 
 fielddataheaderty = record
  index: integer;
 end;
 fielddataty = record
  header: fielddataheaderty;
  data: ifidataty;
 end;
 pfielddataty = ^fielddataty;

 requestopendsty = record
  header: itemheaderty;
 end;   
 fieldreckindty = (frk_edit,frk_insert,frk_delete);  
 fieldrecdataty = record
  kind: fieldreckindty;
  recno: integer;
  count: integer; 
  data: datarecty; //dummy, array[count] of fielddataty
 end;
 pfieldrecdataty = ^fieldrecdataty;
 
 fieldrecty = record
  header: itemheaderty;
  data: fieldrecdataty;
 end;

 recdataty = record
  count: integer; //recordcount
  data: datarecty; //dummy, array[count] of 
                            //array[fielddef count] of ifidataty
 end;
 precdataty = ^recdataty;
 
 dsdataty = record
  header: itemheaderty;
  fileddefs: fielddefsdatadataty;
  recdata: recdataty;
 end;
 
type 
 ifirecstatety = (irs_async);
 ifirecstatesty = set of ifirecstatety;
 ifiheaderty = record
  size: integer;  //overall size
  sequence: sequencety;
  answersequence: sequencety;
  kind: ifireckindty;
  state: ifirecstatesty;
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
   );
   ik_requestfielddefs: (
    requestfielddefs: requestfielddefsty;
   );
   ik_fielddefsdata: (
    fielddefsdata: fielddefsdataty;
   );
   ik_fieldrec: (
    fieldrec: fieldrecty;
   );
   ik_requestopends: (
    requestopends: requestopendsty;
   );
   ik_postresult: (
    postresult: postresultty;
   );
   ik_modulecommand: (
    modulecommand: modulecommandty;
   );
 end;
 pifirecty = ^ifirecty;
  
 twaitingclient = class(tintegeravlnode)
  private
   fsem: semty;
  public
   constructor create(const asequence: sequencety);
   destructor destroy; override;
   procedure answered;
   function wait(const awaitus: integer): boolean;
 end;

 tiosynchronizer = class;
// datasynchronizeprocty = procedure(const sender: tiosynchronizer;
//                               var adata: string) of object;
 stringdataprocty = procedure(var adata: string) of object;
  
 tiosynchronizer = class(teventthread)
  private
   fwaitingclients: tintegeravltree;   
   fondatareceived: stringdataprocty;
//   fonsynchronize: datasynchronizeprocty;
  protected
   procedure datareceived(const adata: string);
   procedure eventloop;
   function execute(thread: tmsethread): integer; override;
  public
   constructor create(const aondatareceived: stringdataprocty);
   destructor destroy; override;
   procedure answerreceived(const asequence: sequencety);
   function preparewait(const asequence: sequencety): twaitingclient;
   function waitforanswer(const aclient: twaitingclient; 
                   const waitus: integer): boolean; //false on timeout
//   property onsynchronize: datasynchronizeprocty read fonsynchronize 
//                                                          write fonsynchronize;
 end;

 tcustomiochannel = class;
 iochanneleventty = procedure(const sender: tcustomiochannel) of object;
 optioniochty = (oic_releaseondisconnect);
 optionsiochty = set of optioniochty;
   
 tcustomiochannel = class(tactcomponent)
  private
   frxdata: string;
   factive: boolean;
   fsequence: sequencety;
   fonbeforeconnect: iochanneleventty;
   fonafterconnect: iochanneleventty;
   fonbeforedisconnect: iochanneleventty;
   fonafterdisconnect: iochanneleventty;
   foptionsio: optionsiochty;
   procedure setactive(const avalue: boolean);
  protected
   fsynchronizer: tiosynchronizer;
   function canconnect: boolean; virtual;
//   procedure receiveevent(const event: tobjectevent); override;
   procedure datareceived(var adata: ansistring);
   procedure internalconnect; virtual; abstract;
   procedure internaldisconnect; virtual; abstract;
   function commio: boolean; virtual; abstract;
   procedure internalsenddata(const adata: ansistring); virtual; abstract;
   procedure loaded; override;
   procedure dobeforeconnect;
   procedure doafterconnect; virtual;
   procedure connect;
   procedure disconnect;
   procedure disconnected;
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure receiveevent(const event: tobjectevent); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function checkconnection: boolean;
   procedure senddata(const adata: ansistring);   
   function sequence: sequencety;
   procedure asyncrx; //posts current rxdata to application queue
   property synchronizer: tiosynchronizer read fsynchronizer;
   property active: boolean read factive write setactive;
   property rxdata: string read frxdata write frxdata;
  published
   property optionsio: optionsiochty read foptionsio write foptionsio;
   property onbeforeconnect: iochanneleventty read fonbeforeconnect 
                                              write fonbeforeconnect;
   property onafterconnect: iochanneleventty read fonafterconnect 
                                              write fonafterconnect;
   property onbeforedisconnect: iochanneleventty read fonbeforedisconnect 
                                              write fonbeforedisconnect;
   property onafterdisconnect: iochanneleventty read fonafterdisconnect 
                                              write fonafterdisconnect;
 end;

 pipeiostatety = (pis_rxstarted);
 pipeiostatesty = set of pipeiostatety;
 
 tstuffediochannel = class(tcustomiochannel)
  private
   fbuffer: string;
   fstate: pipeiostatesty;
   frxcheckedindex: integer;
  protected
   function stuff(const adata: string): string;
   function unstuff(const adata: string): string;
   procedure resetrxbuffer;
   procedure addata(const adata: string);
 end;
  
 tcustompipeiochannel = class(tstuffediochannel)
  private
   frx: tpipereader;
   ftx: tpipewriter;
   fserverapp: string;
   fprochandle: integer;
  protected
   procedure internalconnect; override;
   procedure internaldisconnect; override;   
   function commio: boolean; override;
   procedure internalsenddata(const adata: ansistring); override;
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property active;
 end;

 tpipeiochannel = class(tcustompipeiochannel)
  published
   property active;
   property activator;
   property serverapp: string read fserverapp write fserverapp;
            //stdin, stdout if ''
 end;
 
 tsocketstdiochannel = class(tcustompipeiochannel)
  private
   fcryptio: tcryptio;
   fcryptioinfo: cryptioinfoty;
   procedure setcryptio(const avalue: tcryptio);
  protected
   procedure internalconnect; override;
//   procedure doafterconnect;
   procedure internaldisconnect; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property active;   
   property activator;
   property cryptio: tcryptio read fcryptio write setcryptio;
   property cryptiokindt: cryptiokindty read fcryptioinfo.kind
                               write fcryptioinfo.kind;
 end;

 tifisocketclient = class(tcustomsocketclient)
  published
   property pipes;
   property cryptio;   

   property kind;
   property url;
   property port;
 end;
 
 tsocketclientiochannel = class(tstuffediochannel)
  private
   fsocket: tifisocketclient;
   procedure setsocket(const avalue: tifisocketclient);
  protected
   procedure internalconnect; override;
   procedure internaldisconnect; override;   
   function commio: boolean; override;
   procedure internalsenddata(const adata: ansistring); override;
   procedure doinputavailable(const sender: tpipereader);
   procedure dobeforedisconnect(const sender: tcustomsocketpipes);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property active;
   property activator;
   property socket: tifisocketclient read fsocket write setsocket;
 end;

 tcustomsocketserveriochannel = class(tstuffediochannel)
  private
   fpipes: tcustomsocketpipes;
   funlinking: integer;
  protected
   procedure internalconnect; override;
   procedure internaldisconnect; override;   
   function commio: boolean; override;
   procedure internalsenddata(const adata: ansistring); override;
   procedure doinputavailable(const sender: tpipereader);
   procedure dobeforedisconnect(const sender: tcustomsocketpipes);
   procedure unlink;
   function canconnect: boolean; override;
  public
   destructor destroy; override;
 end;

 tsocketserveriochannel = class(tcustomsocketserveriochannel)
  public
   procedure link(const apipes: tcustomsocketpipes);
 end;
 
 tifiiolinkcomponent = class(tmsecomponent)
  private
   procedure setchannel(const avalue: tcustomiochannel);
  protected
   fchannel: tcustomiochannel;
  published
   property channel: tcustomiochannel read fchannel write setchannel;
 end;
 
procedure initifirec(out arec: string; const akind: ifireckindty; 
      const asequence: sequencety; const datalength: integer; out datapo: pchar);
procedure inititemheader(const atag: integer; const aname: string; 
       out arec: string; const akind: ifireckindty; 
        const asequence: sequencety; const datasize: integer; out datapo: pchar);
function ifinametostring(const source: pifinamety;
               out dest: string): integer;
function stringtoifiname(const source: string;
               const dest: pifinamety): integer;

function encodeifinull(const headersize: integer = 0): string;               
function encodeifidata(const avalue: integer; 
                       const headersize: integer = 0): string; overload;
function encodeifidata(const avalue: int64; 
                       const headersize: integer = 0): string; overload;
function encodeifidata(const avalue: currency; 
                       const headersize: integer = 0): string; overload;
function encodeifidata(const avalue: real; 
                       const headersize: integer = 0): string; overload;
function encodeifidata(const avalue: msestring; 
                       const headersize: integer = 0): string; overload;
function encodeifidata(const avalue: ansistring; 
                       const headersize: integer = 0): string; overload;

function skipifidata(const source: pifidataty): integer;
function decodeifidata(const source: pifidataty; out dest: msestring): integer;
function decodeifidata(const source: pifidataty; out dest: string): integer;
function decodeifidata(const source: pifidataty; out dest: integer): integer;
function decodeifidata(const source: pifidataty; out dest: int64): integer;
function decodeifidata(const source: pifidataty; out dest: real): integer;
function decodeifidata(const source: pifidataty; out dest: currency): integer;
function decodeifidata(const source: pifidataty; out dest: variant): integer;

procedure addifiintegervalue(var adata: ansistring; var adatapo: pchar; 
                                     const avalue: integer);
function readifivariant(const adata: pifirecty; var adatapo: pchar): variant;
function setifibytes(const source: pointer; const size: integer;
                 const dest: pifibytesty): integer; overload;

const 
 datarecsizes: array[ifidatakindty] of integer = (
  sizeof(ifidataty),                             //idk_none
  sizeof(ifidataty),                             //idk_null
  sizeof(ifidataty)+sizeof(integer),             //idk_integer
  sizeof(ifidataty)+sizeof(int64),               //idk_int64
  sizeof(ifidataty)+sizeof(currency),            //idk_currency
  sizeof(ifidataty)+sizeof(double),              //idk_real
  sizeof(ifidataty)+sizeof(ifinamety),           //idk_msestring
//  sizeof(ifidataty)+sizeof(ifinamety),         //idk_ansistring
  sizeof(ifidataty)+sizeof(ifibytesty)           //idk_bytes

 );
implementation
uses
 sysutils,msedatalist,mseprocutils,msesysintf,{mseforms,}msetmpmodules,
 msesysutils,variants;
type
 tsocketreader1 = class(tsocketreader);
 tsocketwriter1 = class(tsocketwriter);
 
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
  sizeof(ifiheaderty)+sizeof(moduledataty),      //ik_moduledata
  sizeof(ifiheaderty)+sizeof(requestfielddefsty),//ik_requestfielddefs
  sizeof(ifiheaderty)+sizeof(fielddefsdataty),   //ik_fielddefsdata
  sizeof(ifiheaderty)+sizeof(fieldrecty),        //ik_fieldrec
  sizeof(ifiheaderty)+sizeof(requestopendsty),   //ik_requestopends
  sizeof(ifiheaderty)+sizeof(dsdataty),          //ik_dsdata
  sizeof(ifiheaderty)+sizeof(postresultty),      //ik_postresult
  sizeof(ifiheaderty)+sizeof(modulecommandty)    //ik_modulecommand
 );

 stuffchar = c_dle;
 stx = c_dle + c_stx;
 etx = c_dle + c_etx;

function setifibytes(const source: pointer; const size: integer;
                 const dest: pifibytesty): integer; overload;
begin
 result:= sizeof(ifibytesty) + size;
 dest^.length:= size;
 move(source^,dest^.data,size);
end;

function setifibytes(const source: string;
                 const dest: pifibytesty): integer; overload;
var
 int1: integer;
begin
 int1:= length(source);
 result:= sizeof(ifibytesty) + int1;
 dest^.length:= int1;
 move(pointer(source)^,dest^.data,int1);
end;

function initdataheader(const headersize: integer; const kind: ifidatakindty;
                        const datasize: integer; out data: string): pchar;
begin
 setlength(data,headersize+datarecsizes[kind]+datasize);
 result:= pointer(data);
 fillchar(result^,headersize,0);
 inc(result,headersize);
 pifidataty(result)^.header.kind:= kind;
 inc(result,sizeof(ifidataty.header));
end;

function encodeifinull(const headersize: integer = 0): string;               
begin
 initdataheader(headersize,idk_null,0,result)
end;

function encodeifidata(const avalue: integer; 
                       const headersize: integer = 0): string; overload;
begin
 pinteger(initdataheader(headersize,idk_integer,0,result))^:= avalue;
// result:= encodeifidata(int64(avalue),headersize);
end;

function encodeifidata(const avalue: int64; 
                       const headersize: integer = 0): string; overload;
begin
 pint64(initdataheader(headersize,idk_int64,0,result))^:= avalue;
end;

function encodeifidata(const avalue: currency; 
                       const headersize: integer = 0): string; overload;
begin
 pcurrency(initdataheader(headersize,idk_currency,0,result))^:= avalue;
end;

function encodeifidata(const avalue: real; 
                       const headersize: integer = 0): string; overload;
begin
 preal(initdataheader(headersize,idk_real,0,result))^:= avalue;
end;

function encodeifidata(const avalue: msestring; 
                       const headersize: integer = 0): string; overload;
var
 str1: string;
begin
 str1:= stringtoutf8(avalue);
 stringtoifiname(str1,pifinamety(
      initdataheader(headersize,idk_msestring,length(str1),result)));
end;

function encodeifidata(const avalue: ansistring; 
                       const headersize: integer = 0): string; overload;
begin
 setifibytes(avalue,pifibytesty(
        initdataheader(headersize,idk_bytes,length(avalue),result))); 
end;

procedure addifiintegervalue(var adata: ansistring; var adatapo: pchar;
                                           const avalue: integer);
begin
 setlength(adata,adatapo-pointer(adata));
 adata:= adata + encodeifidata(avalue);
 pifirecty(adata)^.header.size:= length(adata);
 adatapo:= pointer(adata) + length(adata);
end;

function readifivariant(const adata: pifirecty; var adatapo: pchar): variant;
type
 variantarty = array of variant;
var
 ar1: variantarty;
 po1: pchar;
 int1: integer;
begin
 po1:= pchar(adata)+adata^.header.size;
 while adatapo < po1 do begin
  setlength(ar1,high(ar1)+2);
  inc(adatapo,decodeifidata(pifidataty(adatapo),ar1[high(ar1)]));
 end;
 case high(ar1) of
  -1: begin
   result:= null;
  end;
  0: begin
   result:= ar1[0];
  end;
  else begin
   dynarraytovariant(result,pointer(ar1),typeinfo(variantarty));
  end;
 end;
end;

procedure datakinderror;
begin
 raise exception.create('Wrong datakind.');
end;

function skipifidata(const source: pifidataty): integer;
var
 str1: string;
begin
 case source^.header.kind of
  idk_msestring: begin
   ifinametostring(pifinamety(@source^.data),str1);
   result:= length(str1);
  end;
  idk_bytes: begin
   result:= pifibytesty(@source^.data)^.length;
  end;
  else begin
   result:= 0;
  end;
 end;
 result:= result + datarecsizes[source^.header.kind];
end;

function decodeifidata(const source: pifidataty; out dest: msestring): integer;
var
 str1: string;
begin
 if source^.header.kind <> idk_msestring then begin
  datakinderror;
 end;
 ifinametostring(pifinamety(@source^.data),str1);
 dest:= utf8tostring(str1);
 result:= datarecsizes[idk_msestring] + length(str1);
end;

function decodeifidata(const source: pifidataty; out dest: string): integer;
begin
 if source^.header.kind <> idk_bytes then begin
  datakinderror;
 end;
 with pifibytesty(@source^.data)^ do begin
  setlength(dest,length);
  if length > 0 then begin
   move(data,pointer(dest)^,length);
  end;
  result:= datarecsizes[idk_bytes] + length;
 end;
end;

function decodeifidata(const source: pifidataty; out dest: integer): integer;
begin
 if source^.header.kind <> idk_integer then begin
  datakinderror;
 end;
 dest:= pinteger(@source^.data)^;
 result:= datarecsizes[idk_integer];
end;

function decodeifidata(const source: pifidataty; out dest: int64): integer;
begin
 if source^.header.kind <> idk_int64 then begin
  datakinderror;
 end;
 dest:= pint64(@source^.data)^;
 result:= datarecsizes[idk_int64];
end;

function decodeifidata(const source: pifidataty; out dest: real): integer;
begin
 if source^.header.kind <> idk_real then begin
  datakinderror;
 end;
 dest:= preal(@source^.data)^;
 result:= datarecsizes[idk_real];
end;

function decodeifidata(const source: pifidataty; out dest: currency): integer;
begin
 if source^.header.kind <> idk_currency then begin
  datakinderror;
 end;
 dest:= pcurrency(@source^.data)^;
 result:= datarecsizes[idk_currency];
end;

function decodeifidata(const source: pifidataty; out dest: variant): integer;
var
 integer1: integer;
 int641: int64;
 currency1: currency;
 real1: real;
 msestring1: msestring;
 ansistring1: ansistring;
begin
 case source^.header.kind of
  idk_null: begin
   dest:= null;
   result:= sizeof(ifidataty);   
  end;
  idk_integer: begin
   result:= decodeifidata(source,integer1);
   dest:= integer1;
  end;
  idk_int64: begin
   result:= decodeifidata(source,int641);
   dest:= int641;
  end;
  idk_currency: begin
   result:= decodeifidata(source,currency1);
   dest:= currency1;
  end;
  idk_real: begin
   result:= decodeifidata(source,real1);
   dest:= real1;
  end;
  idk_msestring: begin
   result:= decodeifidata(source,msestring1);
   dest:= msestring1;
  end;
  idk_bytes: begin
   result:= decodeifidata(source,ansistring1);
   dest:= ansistring1;
  end;
  else begin
   raise exception.create('Invalid IfI data');
  end;
 end;
end;

procedure initifirec(out arec: string; const akind: ifireckindty;
                      const asequence: sequencety; const datalength: integer;
                      out datapo: pchar);
var
 int1: integer;
begin
 int1:= headersizes[akind] + datalength;
 setlength(arec,int1);
 fillchar(arec[1],int1,0);
 with pifiheaderty(arec)^ do begin
  size:= int1;
  answersequence:= asequence;
//  sequence:= fsequence;
  kind:= akind;
 end;
 datapo:= pointer(arec) + sizeof(ifiheaderty);
end;

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
{
procedure ifidatasynchronize(const sender: tiosynchronizer; var adata: string);
begin
 if length(adata) >= sizeof(ifiheaderty) then begin
  with pifiheaderty(adata)^ do begin
   if answersequence <> 0 then begin
    sender.answerreceived(answersequence);
   end;
  end;
 end;
end;
}
procedure inititemheader(const atag: integer; const aname: string; 
       out arec: string; const akind: ifireckindty;  const asequence: sequencety;
       const datasize: integer; out datapo: pchar);
var
 po1: pchar; 
begin
 initifirec(arec,akind,asequence,datasize+length(aname),po1);
 with pitemheaderty(po1)^ do begin
  tag:= atag;
  po1:= @name;
 end;
 inc(po1,stringtoifiname(aname,pifinamety(po1)));
 datapo:= po1;
end;

{ tcustomiochannel }

constructor tcustomiochannel.create(aowner: tcomponent);
begin
 fsynchronizer:= tiosynchronizer.create(@datareceived);
 inherited;
end;

destructor tcustomiochannel.destroy;
begin
 fsynchronizer.free;
 active:= false;
 inherited;
end;

function tcustomiochannel.checkconnection: boolean;
begin
 result:= commio;
 if not result then begin
  disconnect;
  if canconnect then begin
   connect;
   result:= commio;
  end;
 end;
end;

function tcustomiochannel.sequence: sequencety;
begin
 inc(fsequence);
 if fsequence = 0 then begin
  inc(fsequence);
 end;
end;

procedure tcustomiochannel.senddata(const adata: ansistring);
begin
 if checkconnection then begin
  internalsenddata(adata);
 end;
end;

procedure tcustomiochannel.datareceived(var adata: ansistring);
var
 str1: string;
begin
 str1:= frxdata;
 frxdata:= adata;
 try
  sendchangeevent(oe_dataready);
 finally
  frxdata:= str1;
 end;
end;

procedure tcustomiochannel.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_objectdata) and (event is tstringobjectevent) then begin
  datareceived(tstringobjectevent(event).fdata);
 end
 else begin
  inherited;
 end;
end;

procedure tcustomiochannel.asyncrx; //posts current rxdata to application queue
var
 str1: ansistring;
begin
 str1:= frxdata;
 frxdata:= '';
 application.postevent(tstringobjectevent.create(str1,ievent(self)));
end;

procedure tcustomiochannel.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  if componentstate * [csloading,csdesigning] = [] then begin
   if avalue then begin
    connect;
   end
   else begin
    disconnect;
   end;
  end;
 end;
end;

procedure tcustomiochannel.loaded;
begin
 inherited;
 if factive and not (csdesigning in componentstate) then begin
  connect;
 end;
end;

procedure tcustomiochannel.dobeforeconnect;
begin
 if canevent(tmethod(fonbeforeconnect)) then begin
  fonbeforeconnect(self);
 end;
end;

procedure tcustomiochannel.doafterconnect;
begin
 if canevent(tmethod(fonafterconnect)) then begin
  fonafterconnect(self);
 end;
end;

procedure tcustomiochannel.connect;
begin
{$ifdef mse_debugsockets}
 debugout(self,'connect');
{$endif}
 dobeforeconnect;
 internalconnect;
 doafterconnect;
{$ifdef mse_debugsockets}
 debugout(self,'connected');
{$endif}
end;

procedure tcustomiochannel.disconnected;
begin
{$ifdef mse_debugsockets}
 debugout(self,'disconnected');
{$endif}
 if canevent(tmethod(fonafterdisconnect)) then begin
  fonafterdisconnect(self);
 end;
 if (oic_releaseondisconnect in foptionsio) and 
  not (csdesigning in componentstate) and (owner is tactcomponent) then begin
  tactcomponent(owner).release;
 end;
end;

procedure tcustomiochannel.disconnect;
begin
{$ifdef mse_debugsockets}
 debugout(self,'disconnect');
{$endif}
 if canevent(tmethod(fonbeforedisconnect)) then begin
  fonbeforedisconnect(self);
 end;
 internaldisconnect;
 disconnected;
end;

function tcustomiochannel.canconnect: boolean;
begin
 result:= true;
end;

procedure tcustomiochannel.doactivated;
begin
 active:= true;
// if factive then begin
//  connect;
// end;
end;

procedure tcustomiochannel.dodeactivated;
begin
 active:= false;
end;

{ tstuffediochannel }

procedure tstuffediochannel.resetrxbuffer;
begin
 fbuffer:= '';
 exclude(fstate,pis_rxstarted); 
 frxcheckedindex:= 0;
end;

procedure tstuffediochannel.addata(const adata: string);
var
 int1,int2: integer;
 po1: pchar;
 str1: string;
begin
 fbuffer:= fbuffer + adata;
 int1:= length(fbuffer);
 if (int1 >= 2) then begin
  po1:= pointer(fbuffer);
  if (pis_rxstarted in fstate) then begin
   for int2:= frxcheckedindex to int1-2 do begin
    if (po1[int2] = c_dle) and (po1[int2+1] = c_etx) and
     ((int2 = 0) or (po1[int2-1] <> c_dle))  then begin
     str1:= copy(fbuffer,int2+3,int1); //next frame
     setlength(fbuffer,int2);
     try
      fsynchronizer.datareceived(unstuff(fbuffer));
     except
      application.handleexception(self);
     end;
     resetrxbuffer;
     if str1 <> '' then begin
      addata(str1);
     end;
     exit;
    end;
   end;
  end
  else begin
   for int2:= 0 to int1-2 do begin
    if (po1[int2] = c_dle) and (po1[int2+1] = c_stx) and
         ((int2 = 0) or (po1[int2-1] <> c_dle)) then begin
     fbuffer:= copy(fbuffer,int2+3,int1);
     include(fstate,pis_rxstarted);
     addata('');
     exit;
    end;
   end;
  end;
  repeat
   dec(int1);
  until (int1 = 0) or (po1[int1] <> c_dle);
  frxcheckedindex:= int1;
 end;
end;

function tstuffediochannel.stuff(const adata: string): string;
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

function tstuffediochannel.unstuff(const adata: string): string;
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

{ tcustompipeiochannel }

constructor tcustompipeiochannel.create(aowner: tcomponent);
begin
 if frx = nil then begin
  frx:= tpipereader.create;
 end;
 if ftx = nil then begin
  ftx:= tpipewriter.create;
 end;
 fprochandle:= invalidprochandle;
 frx.oninputavailable:= @doinputavailable;
 frx.onpipebroken:= @dopipebroken;
 inherited;
end;

destructor tcustompipeiochannel.destroy;
begin
 inherited;
 ftx.free;
 frx.free;
end;

procedure tcustompipeiochannel.internalconnect;
begin
 resetrxbuffer;
 if fserverapp <> '' then begin
  fprochandle:= execmse2(fserverapp,ftx,frx);
 end
 else begin
debugwriteln('internalconnect');
  ftx.handle:= sys_stdout;
  frx.handle:= sys_stdin;
 end;
end;

procedure tcustompipeiochannel.internaldisconnect;
var
 int1: integer;
begin
 frx.terminate; 
 ftx.close;
 frx.close;
 fbuffer:= '';
 if fprochandle <> invalidprochandle then begin
  int1:= fprochandle;
  fprochandle:= invalidprochandle;
  killprocess(int1);
 end; 
end;

function tcustompipeiochannel.commio: boolean;
begin
 result:= ((fserverapp = '') or (fprochandle <> invalidprochandle))
                     and frx.active;
end;

procedure tcustompipeiochannel.internalsenddata(const adata: ansistring);
begin
 ftx.writestr(stx+stuff(adata)+etx);
end;

procedure tcustompipeiochannel.doinputavailable(const sender: tpipereader);
begin
 addata(sender.readdatastring);
end;

procedure tcustompipeiochannel.dopipebroken(const sender: tpipereader);
begin
 asyncevent(closepipestag);
end;

procedure tcustompipeiochannel.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end
 else begin
  inherited;
 end; 
end;

{ tpipeifichannel }
{
constructor tpipeifichannel.create(aowner: tcomponent);
begin
 fsynchronizer:= tifisynchronizer.create;
 inherited;
end;
}
{ tsocketpipeiochannel }
{
constructor tsocketpipeiochannel.create(aowner: tcomponent);
begin
 if freader = nil then begin
  freader:= tsocketreader.create;
 end;
 if fwriter = nil then begin
  fwriter:= tsocketwriter.create;
 end;
 inherited;
end;
}
{ tiosynchronizer }

constructor tiosynchronizer.create(const aondatareceived: stringdataprocty);
begin
 fondatareceived:= aondatareceived;
 fwaitingclients:= tintegeravltree.create;
 inherited create;
end;

destructor tiosynchronizer.destroy;
begin
 fwaitingclients.free;
 inherited;
end;

procedure tiosynchronizer.answerreceived(const asequence: sequencety);
var
 client1: twaitingclient;
begin
 if fwaitingclients.find(integer(asequence),client1) then begin
  client1.answered;
 end;
end;

function tiosynchronizer.preparewait(const asequence: sequencety): twaitingclient;
begin
 if getcurrentthreadid = id then begin
  raise exception.create('Deadlock in tiosynchrionizer.waitforanswer.');
 end;
 result:= twaitingclient.create(asequence);
 fwaitingclients.addnode(result);
end;

function tiosynchronizer.waitforanswer(const aclient: twaitingclient;
               const waitus: integer): boolean;
var
 int1: integer;
begin
 int1:= application.unlockall;
 try
  result:= aclient.wait(waitus);
 finally
  application.relockall(int1);
 end;
 fwaitingclients.removenode(aclient);
 aclient.free;
end;

procedure tiosynchronizer.datareceived(const adata: string);
begin
 postevent(tstringevent.create(adata));
end;

procedure tiosynchronizer.eventloop;
var
 str1: string;
 event: tstringevent;
begin
 while not terminated do begin
  event:= tstringevent(waitevent);
  if event <> nil then begin
   str1:= event.data;
   event.free;
   application.lock;
   try
    fondatareceived(str1);
   except
    application.handleexception(self);
   end;
   application.unlock;   
  end;
 end;
end;

function tiosynchronizer.execute(thread: tmsethread): integer;
begin
 eventloop;
end;

{ twaitingclient }

constructor twaitingclient.create(const asequence: sequencety);
begin
 sys_semcreate(fsem,0);
 inherited create(integer(asequence));
end;

destructor twaitingclient.destroy;
begin
 sys_semdestroy(fsem);
end;

procedure twaitingclient.answered;
begin
 sys_sempost(fsem);
end;

function twaitingclient.wait(const awaitus: integer): boolean;
begin
 result:= sys_semwait(fsem,awaitus) = sye_ok;
// application.processmessages;
end;

{ tifisocketclient }
{
constructor tifisocketclient.create(aowner: tcomponent);
begin
 fpipes:= tifisocketclientpipes.create(self);
 inherited;
end;
}
{ tsocketclientiochannel }

constructor tsocketclientiochannel.create(aowner: tcomponent);
begin
 fsocket:= tifisocketclient.create(nil);
 fsocket.setsubcomponent(true);
 fsocket.pipes.rx.oninputavailable:= @doinputavailable;
 fsocket.pipes.onbeforedisconnect:= @dobeforedisconnect;
 inherited;
end;

destructor tsocketclientiochannel.destroy;
begin
 inherited;
 fsocket.free;
end;

procedure tsocketclientiochannel.internalconnect;
begin
 fsocket.active:= true;
end;

procedure tsocketclientiochannel.internaldisconnect;
begin
 fsocket.active:= false;
end;

function tsocketclientiochannel.commio: boolean;
begin
 result:= fsocket.active and fsocket.pipes.rx.active;
end;

procedure tsocketclientiochannel.internalsenddata(const adata: ansistring);
begin
 fsocket.pipes.tx.writestr(stx+stuff(adata)+etx);
end;

procedure tsocketclientiochannel.doinputavailable(const sender: tpipereader);
begin
 addata(sender.readdatastring);
end;

procedure tsocketclientiochannel.setsocket(const avalue: tifisocketclient);
begin
 fsocket.assign(avalue);
end;

procedure tsocketclientiochannel.dobeforedisconnect(const sender: tcustomsocketpipes);
begin
 disconnect;
end;

{ tsocketclientifichannel }
{
constructor tsocketclientifichannel.create(aowner: tcomponent);
begin
 fsynchronizer:= tifisynchronizer.create;
 inherited;
end;
}
{ tcustomsocketserveriochannel }

destructor tcustomsocketserveriochannel.destroy;
begin
 unlink;
 inherited;
end;

procedure tcustomsocketserveriochannel.unlink;
begin
 if funlinking = 0 then begin
  inc(funlinking);
  try
   if fpipes <> nil then begin
    fpipes.rx.oninputavailable:= nil;
    fpipes.close;
   end;
  finally
   fpipes:= nil;
   dec(funlinking);
  end;
 end;
end;

procedure tcustomsocketserveriochannel.internalconnect;
begin
 raise exception.create('Not implemented.');
end;

procedure tcustomsocketserveriochannel.internaldisconnect;
begin
 if fpipes <> nil then begin
  fpipes.close;
 end;
end;

function tcustomsocketserveriochannel.commio: boolean;
begin
 result:= (fpipes <> nil) and fpipes.rx.active;
end;

procedure tcustomsocketserveriochannel.internalsenddata(const adata: ansistring);
begin
 fpipes.tx.writestr(stx+stuff(adata)+etx);
end;

procedure tcustomsocketserveriochannel.doinputavailable(const sender: tpipereader);
begin
 addata(sender.readdatastring);
end;

procedure tcustomsocketserveriochannel.dobeforedisconnect(const sender: tcustomsocketpipes);
begin
 disconnect;
 unlink;
end;

function tcustomsocketserveriochannel.canconnect: boolean;
begin
 result:= false;
end;

{ tsocketserveriochannel }

procedure tsocketserveriochannel.link(const apipes: tcustomsocketpipes);
begin
 unlink;
 dobeforeconnect;
 setlinkedvar(apipes,fpipes);
 fpipes.onbeforedisconnect:= @dobeforedisconnect;
 fpipes.rx.oninputavailable:= @doinputavailable;
 doafterconnect; 
end;

{ tifiiolinkcomponent }

procedure tifiiolinkcomponent.setchannel(const avalue: tcustomiochannel);
begin
 setlinkedvar(avalue,fchannel);
// avalue.fsynchronizer.onsynchronize:= @ifidatasynchronize;
end;

{ tsocketserverifichannel }
{
constructor tsocketserverifichannel.create(aowner: tcomponent);
begin
 fsynchronizer:= tifisynchronizer.create;
 inherited;
end;
}
{ tsocketserverstdifichannel }
{
constructor tsocketserverstdifichannel.create(aowner: tcomponent);
begin
 fsynchronizer:= tifisynchronizer.create;
 inherited;
end;
}
{ tsocketstdiochannel }

constructor tsocketstdiochannel.create(aowner: tcomponent);
begin
 frx:= tsocketreader.create;
 tsocketreader1(frx).fonafterconnect:= @doafterconnect;
 ftx:= tsocketwriter.create;
 inherited;
end;

procedure tsocketstdiochannel.setcryptio(const avalue: tcryptio);
begin
 setlinkedvar(avalue,fcryptio);
end;
{
procedure tsocketstdiochannel.doafterconnect;
begin
 fcryptioinfo.handler:= fcryptio;
 connectcryptio(tsocketwriter(ftx),tsocketreader(frx),fcryptioinfo);
end;
}
procedure tsocketstdiochannel.internalconnect;
begin
// fcryptioinfo.handler:= fcryptio;
 connectcryptio(fcryptio,tsocketwriter(ftx),tsocketreader(frx),fcryptioinfo,
                           sys_stdout,sys_stdin);
 inherited;
end;

procedure tsocketstdiochannel.internaldisconnect;
begin
 inherited;
 cryptunlink(fcryptioinfo);
end;

end.
