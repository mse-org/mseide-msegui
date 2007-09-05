unit mseifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msearrayprops,mseactions,msestrings,msetypes,mseevent,
 mseguiglob,msestream,msepipestream;
type

 ifireckindty = (ik_none,ik_data,ik_actionfired);
 ifinamety = array[0..0] of char; //null terminated
 pifinamety = ^ifinamety;
 
 actionfiredty = record
  tag: integer;
  name: ifinamety;
 end;
  
 ifiheaderty = record
  size: integer;  //overall size
  kind: ifireckindty;
 end;
 pifiheaderty = ^ifiheaderty;
 
 ifirecty = record
  header: ifiheaderty;
  case ifireckindty of
   ik_data:(
    data: array[0..0] of byte;
   );
   ik_actionfired:(
    actionfired: actionfiredty;
   );
 end;
 pifirecty = ^ifirecty;
  
 tlinkactions = class;
 
 tlinkaction = class(townedeventpersistent)
  private
   faction: tcustomaction;
   fprop: tlinkactions;
   fname: ansistring;
   ftag: integer;
   procedure setaction(const avalue: tcustomaction);
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  public
   destructor destroy; override;
  published
   property action: tcustomaction read faction write setaction;
   property name: ansistring read fname write fname;
   property tag: integer read ftag write ftag;
 end;

 tcustomformlink = class;
  
 tlinkactions = class(tpersistentarrayprop)
  private
   fowner: tcustomformlink;
   function getitems(const index: integer): tlinkaction;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomformlink);
   property items[const index: integer]: tlinkaction read getitems; default;
 end;
 
 tcustomiochannel = class(tmsecomponent)
  private
   frxdata: string;
   factive: boolean;
   procedure setactive(const avalue: boolean);
  protected
   procedure checkopen;
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
  
 tcustomformlink = class(tmsecomponent)
  private
   factions: tlinkactions;
   fchannel: tcustomiochannel;
   procedure setactions(const avalue: tlinkactions);
   procedure setchannel(const avalue: tcustomiochannel);
  protected
   function stringtoifiname(const source: string; const dest: pifinamety): integer;
   function ifinametostring(const source: pifinamety; out dest: string): integer;
                    //returns source size
   procedure initifirec(var arec: string; const akind: ifireckindty; 
                             const datalength: integer);
   function encodeactionfired(const atag: integer; const aname: string): string;
   procedure actionfired(const sender: tlinkaction); virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure processdata(const adata: pifirecty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updatecomponent(const anamepath: ansistring;
                                const aobjecttext: ansistring);
   property actions: tlinkactions read factions write setactions;
   property channel: tcustomiochannel read fchannel write setchannel;
 end;

 tformlink = class(tcustomformlink)
  published
   property actions;
   property channel;
 end;
  
implementation
uses
 sysutils,msedatalist,mseprocutils,msesysintf;

const
 headersizes: array[ifireckindty] of integer = (
  sizeof(ifiheaderty),                       //ik_none
  sizeof(ifiheaderty),                       //ik_data
  sizeof(ifiheaderty)+sizeof(actionfiredty)  //ik_actionfiredty
 );
 stuffchar = c_dle;
 stx = c_dle + c_stx;
 etx = c_dle + c_etx;
 
{ tcustomiochannel }

destructor tcustomiochannel.destroy;
begin
 close;
 inherited;
end;

procedure tcustomiochannel.checkopen;
begin
 if not commio then begin
  close;
  open;
  if not commio then begin
   //error message
  end;
 end;
end;

procedure tcustomiochannel.senddata(const adata: ansistring);
begin
 checkopen;
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

procedure tlinkaction.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_fired) and (sender = faction) then begin
  tcustomformlink(fowner).actionfired(self);
 end;
end;

{ tlinkactions }

constructor tlinkactions.create(const aowner: tcustomformlink);
begin
 fowner:= aowner;
 inherited create(tlinkaction);
end;

procedure tlinkactions.createitem(const index: integer; var item: tpersistent);
begin
 item:= tlinkaction.create(fowner);
 tlinkaction(item).fprop:= self;
end;

function tlinkactions.getitems(const index: integer): tlinkaction;
begin
 result:= tlinkaction(inherited getitems(index));
end;

{ tcustomformlink }

constructor tcustomformlink.create(aowner: tcomponent);
begin
 factions:= tlinkactions.create(self);
 inherited;
end;

destructor tcustomformlink.destroy;
begin
 factions.free;
 inherited;
end;

procedure tcustomformlink.setactions(const avalue: tlinkactions);
begin
 factions.assign(avalue);
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
begin
 initifirec(result,ik_actionfired,length(aname));
 with pifirecty(result)^.actionfired do begin
  tag:= atag;
  stringtoifiname(aname,@name);
 end;
end;

function tcustomformlink.stringtoifiname(const source: string;
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

function tcustomformlink.ifinametostring(const source: pifinamety;
               out dest: string): integer;
begin
 dest:= pchar(source);
 result:= length(dest) + 1;
end;

procedure tcustomformlink.initifirec(var arec: string;
               const akind: ifireckindty; const datalength: integer);
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
 str1: string;
begin
 with adata^ do begin
  case header.kind of
   ik_actionfired: begin
    with actionfired do begin
     tag1:= tag;
     ifinametostring(@name,str1);
    end;
   end;
  end;
 end;
end;

end.
