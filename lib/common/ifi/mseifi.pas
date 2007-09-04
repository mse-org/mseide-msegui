unit mseifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msearrayprops,mseactions,msestrings,msetypes,mseevent,
 mseguiglob,msestream,msepipestream;
type

 tlinkactions = class;
 
 tlinkaction = class(townedeventpersistent)
  private
   faction: tcustomaction;
   fprop: tlinkactions;
   fname: ansistring;
   procedure setaction(const avalue: tcustomaction);
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  public
   destructor destroy; override;
  published
   property action: tcustomaction read faction write setaction;
   property name: ansistring read fname write fname;
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
  protected
   procedure checkopen;
   procedure datareceived(const adata: ansistring);
   procedure senddata(const adata: ansistring);   
   procedure open; virtual; abstract;
   procedure close; virtual; abstract;
   function commio: boolean; virtual; abstract;
   procedure internalsenddata(const adata: ansistring); virtual; abstract;
  public
   destructor destroy; override;
 end;

 tpipeiochannel = class(tcustomiochannel)
  private
   freader: tpipereader;
   fwriter: tpipewriter;
   fapplication: string;
   fprochandle: integer;
  protected
   procedure open; override;
   procedure close; override;   
   function commio: boolean; override;
   procedure internalsenddata(const adata: ansistring); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property application: string read fapplication write fapplication;
            //stdin, stdout if ''
 end;
  
 tcustomformlink = class(tmsecomponent)
  private
   factions: tlinkactions;
   fchannel: tcustomiochannel;
   procedure setactions(const avalue: tlinkactions);
   procedure setchannel(const avalue: tcustomiochannel);
  protected
   procedure actionfired(const sender: tlinkaction); virtual;
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
end;

{ tpipeiochannel }

constructor tpipeiochannel.create(aowner: tcomponent);
begin
 freader:= tpipereader.create;
 fwriter:= tpipewriter.create;
 fprochandle:= invalidprochandle;
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
 fwriter.writestr(adata);
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
  fchannel.senddata('ACTIONFIRED '+sender.name);
 end;
end;

procedure tcustomformlink.setchannel(const avalue: tcustomiochannel);
begin
 setlinkedvar(avalue,fchannel);
end;


end.
