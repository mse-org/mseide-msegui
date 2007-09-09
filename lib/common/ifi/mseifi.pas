unit mseifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msearrayprops,mseactions,msestrings,msetypes,mseevent,
 mseguiglob,msestream,msepipestream,msegui,mseifiglob,typinfo;
type

 ifireckindty = (ik_none,ik_data,ik_actionfired,ik_propertychanged);
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
  
 actionfiredty = record
  tag: integer;
  name: ifinamety;
 end;

 propertychangedty = record
  tag: integer;
  name: ifinamety;
  propertyname: ifinamety;
  data: ifidataty;
 end;
 ppropertychangedty = ^propertychangedty;
  
 ifiheaderty = record
  size: integer;  //overall size
  kind: ifireckindty;
 end;
 pifiheaderty = ^ifiheaderty;
 
 ifirecty = record
  header: ifiheaderty;
  case ifireckindty of
   ik_data:(
    data: ifidataty;
   );
   ik_actionfired:(
    actionfired: actionfiredty;
   );
   ik_propertychanged:(
    propertychanged: propertychangedty;
   );
 end;
 pifirecty = ^ifirecty;
  
 tformlinkarrayprop = class;
 
 tformlinkprop = class(townedeventpersistent)
  private
   fprop: tformlinkarrayprop;
   fname: ansistring;
   ftag: integer;
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
  protected
   procedure initpropertyrecord(out arec: string; const apropertyname: string;
       const akind: ifidatakindty; const datasize: integer; out datapo: pchar);
   procedure sendvalue(const aproperty: ppropinfo); overload;
   procedure sendvalue(const aname: string; const avalue: int64); overload;
   procedure sendvalue(const aname: string; const avalue: double); overload;
   procedure sendvalue(const aname: string; const avalue: msestring); overload;
   procedure sendvalue(const aname: string; const avalue: ansistring); overload;
  public
   property asinteger: integer read getasinteger write setasinteger;
   property aslargeint: int64 read getaslargeint write setaslargeint;
   property asfloat: double read getasfloat write setasfloat;
   property asmsestring: msestring read getasmsestring write setasmsestring;
   property asstring: string read getasansistring write setasansistring;
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
   procedure setactionsrx(const avalue: trxlinkactions);
   procedure setactionstx(const avalue: ttxlinkactions);
   procedure setchannel(const avalue: tcustomiochannel);
   procedure setdatawidgets(const avalue: tlinkdatawidgets);
   function hasconnection: boolean;
  protected
   procedure initifirec(out arec: string; const akind: ifireckindty; 
                             const datalength: integer; out datapo: pchar);
   function encodeactionfired(const atag: integer; const aname: string): string;
   procedure actionfired(const sender: tlinkaction); virtual;
   procedure actionreceived(const atag: integer; const aname: string);
   procedure propertychangereceived(const atag: integer; const aname: string;
                      const apropertyname: string; const adata: pifidataty);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure processdata(const adata: pifirecty);
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
   property channel: tcustomiochannel read fchannel write setchannel;
 end;

 tformlink = class(tcustomformlink)
  published
   property actionsrx;
   property actionstx;
   property datawidgets;
   property channel;
 end;
  
implementation
uses
 sysutils,msedatalist,mseprocutils,msesysintf;

const
 headersizes: array[ifireckindty] of integer = (
  sizeof(ifiheaderty),                          //ik_none
  sizeof(ifiheaderty),                          //ik_data
  sizeof(ifiheaderty)+sizeof(actionfiredty),    //ik_actionfired
  sizeof(ifiheaderty)+sizeof(propertychangedty) //ik_propertychanged
 );

 datarecsizes: array[ifidatakindty] of integer = (
  sizeof(ifidataty),                  //idk_none
  sizeof(ifidataty)+sizeof(int64),    //idk_int64
  sizeof(ifidataty)+sizeof(double),   //idk_real
  sizeof(ifidataty)+sizeof(ifinamety),//idk_msestring
  sizeof(ifidataty)+sizeof(ifinamety) //idk_ansistring
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

function tformlinkarrayprop.byname(const aname: string): tformlinkprop;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  if tformlinkprop(fitems[int1]).fname = aname then begin
   result:= tformlinkprop(fitems[int1]);
   exit;
  end;
 end;
 raise exception.create(fowner.name+': array property "'+aname+'" not found.');
end;

{ tlinkactions }

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
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: double);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_real,0,po1);
 pdouble(po1)^:= avalue;
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: msestring);
var
 str1,str2: string;
 po1: pchar;
begin
 str2:= stringtoutf8(avalue);
 initpropertyrecord(str1,aname,idk_msestring,length(str2),po1);
 stringtoifiname(str2,pifinamety(po1));
 tcustomformlink(fowner).fchannel.senddata(str1);
end;

procedure tlinkdatawidget.sendvalue(const aname: string; const avalue: ansistring);
var
 str1: string;
 po1: pchar;
begin
 initpropertyrecord(str1,aname,idk_ansistring,length(avalue),po1);
 stringtoifiname(avalue,pifinamety(po1));
 tcustomformlink(fowner).fchannel.senddata(str1);
end;

procedure tlinkdatawidget.initpropertyrecord(out arec: string;
          const apropertyname: string; const akind: ifidatakindty;
          const datasize: integer; out datapo: pchar);
var
 po1: pchar; 
begin
 tcustomformlink(fowner).initifirec(arec,ik_propertychanged,
       (sizeof(propertychangedty)-sizeof(ifidataty))+datarecsizes[akind]+
       length(fname)+length(apropertyname)+datasize,po1);
 with ppropertychangedty(po1)^ do begin
  tag:= ftag;
  po1:= @name;
 end;
 inc(po1,stringtoifiname(fname,pifinamety(po1)));
 inc(po1,stringtoifiname(apropertyname,pifinamety(po1)));
 pifidataty(po1)^.kind:= akind;
 datapo:= po1 + sizeof(ifidataty.kind);
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
  fansistringvalue;
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
  fmsestringvalue;
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

{ tcustomformlink }

constructor tcustomformlink.create(aowner: tcomponent);
begin
 factionsrx:= trxlinkactions.create(self);
 factionstx:= ttxlinkactions.create(self);
 fdatawidgets:= tlinkdatawidgets.create(self);
 inherited;
end;

destructor tcustomformlink.destroy;
begin
 factionsrx.free;
 factionstx.free;
 fdatawidgets.free;
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
 with pifirecty(result)^.actionfired do begin
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
 with pifiheaderty(arec)^ do begin
  size:= int1;
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
begin
 with adata^ do begin
  case header.kind of
   ik_actionfired: begin
    with actionfired do begin
     tag1:= tag;
     ifinametostring(@name,str1);
     actionreceived(tag1,str1);
    end;
   end;
   ik_propertychanged: begin
    with propertychanged do begin
     tag1:= tag;
     po1:= @name;
     inc(po1,ifinametostring(pifinamety(po1),str1));
     inc(po1,ifinametostring(pifinamety(po1),str2));
     propertychangereceived(tag1,str1,str2,pifidataty(po1));
    end;
   end;
  end;
 end;
end;

procedure tcustomformlink.actionreceived(const atag: integer;
               const aname: string);
var
 act1: tlinkaction;
 int1: integer;
begin
 with factionsrx do begin
  for int1:= 0 to high(fitems) do begin
   act1:= trxlinkaction(fitems[int1]);
   with act1 do begin
    if name = aname then begin
     if assigned(fonexecute) then begin
      fonexecute(act1,atag);
     end;
     if (faction <> nil) and faction.enabled then begin
      action.execute;
     end;
     break;
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
 int1: integer;
begin
 with fdatawidgets do begin
  for int1:= 0 to high(fitems) do begin
   wi1:= tlinkdatawidget(fitems[int1]);
   with wi1 do begin
    if name = aname then begin
     setdata(adata);
     if assigned(fonpropertychanged) then begin
      fonpropertychanged(wi1,atag,apropertyname);
     end;
     break;
    end;
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

end.
