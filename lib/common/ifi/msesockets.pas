unit msesockets;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msesys,msestrings,msepipestream,msegui,msethread;

const
 defaultmaxconnections = 16;
  
type
 tcustomsocketpipes = class;
 socketpipeseventty = procedure(const sender: tcustomsocketpipes) of object;

 tcustomsocketpipes = class(tpersistent)
  private
   freader: tpipereader;
   fwriter: tpipewriter;
   foninputavailable: socketpipeseventty;
   fonsocketbroken: socketpipeseventty;
   fowner: tmsecomponent;
   function gethandle: integer;
   procedure sethandle(const avalue: integer);
   function getoverloadsleepus: integer;
   procedure setoverloadsleepus(const avalue: integer);
   procedure setoninputavailable(const avalue: socketpipeseventty);
   procedure setonsocketbroken(const avalue: socketpipeseventty);
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);   
  public
   constructor create(const aowner: tmsecomponent);
   destructor destroy; override;
   property handle: integer read gethandle write sethandle;
   property reader: tpipereader read freader;
   property writer: tpipewriter read fwriter;
   property overloadsleepus: integer read getoverloadsleepus 
                  write setoverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property oninputavailable: socketpipeseventty read foninputavailable write setoninputavailable;
   property onsocketbroken: socketpipeseventty read fonsocketbroken write setonsocketbroken;
 end;

 socketpipesarty = array of tcustomsocketpipes;

 tclientsocketpipes = class(tcustomsocketpipes)
  published
   property overloadsleepus;
   property oninputavailable;
   property onsocketbroken;
 end;
 
 tserversocketpipes = class(tcustomsocketpipes)
 end;
  
 tsocketcomp = class(tguicomponent)
  private
   fhandle: integer;
   furl: msestring;
   factive: boolean;
   procedure seturl(const avalue: filenamety);
   procedure setactive(const avalue: boolean);
  protected
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure connect; virtual; abstract;
   procedure disconnect; virtual;
   procedure checkinactive;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property active: boolean read factive write setactive;
   property url: filenamety read furl write seturl;
   property activator;
 end;

 tsocketclient = class(tsocketcomp)
  private
   procedure setpipes(const avalue: tcustomsocketpipes);
  protected
   fpipes: tcustomsocketpipes;
   procedure connect; override;
   procedure disconnect; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property pipes: tcustomsocketpipes read fpipes write setpipes;
 end;

 tsocketserver = class;
 socketaccepteventty = procedure(const sender: tsocketserver;
                     const addr: socketaddrty; var accept: boolean) of object;

 tsocketserver = class(tsocketcomp)
  private
   fthread: tmsethread;
   fmaxconnections: integer;
   fonaccept: socketaccepteventty;
   fpipes: socketpipesarty;
   foverloadsleepus: integer;
   foninputavailable: socketpipeseventty;
   fonsocketbroken: socketpipeseventty;
   function execthread(thread: tmsethread): integer;
  protected
   procedure connect; override;
   procedure disconnect; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property maxconnections: integer read fmaxconnections write fmaxconnections 
                             default defaultmaxconnections;
   property onaccept: socketaccepteventty read fonaccept write fonaccept;
   property overloadsleepus: integer read foverloadsleepus 
                  write foverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property oninputavailable: socketpipeseventty read foninputavailable 
                                 write foninputavailable;
   property onsocketbroken: socketpipeseventty read fonsocketbroken 
                                 write fonsocketbroken;
 end;
   
procedure checksyserror(const aresult: integer);

implementation
uses
 msefileutils,msesysintf,sysutils;
  
procedure checksyserror(const aresult: integer);
begin
 if aresult <> 0 then begin
  syserror(syelasterror);
 end;
end;

{ tcustomsocketpipes }

constructor tcustomsocketpipes.create(const aowner: tmsecomponent);
begin
 fowner:= aowner;
 freader:= tpipereader.create;
 fwriter:= tpipewriter.create;
end;

destructor tcustomsocketpipes.destroy;
begin
 freader.free;
 fwriter.free;
 inherited;
end;

function tcustomsocketpipes.gethandle: integer;
begin
 result:= fwriter.handle;
end;

procedure tcustomsocketpipes.sethandle(const avalue: integer);
var
 int1: integer;
begin
 fwriter.handle:= avalue;
 int1:= avalue;
 if avalue <> invalidfilehandle then begin
  syserror(sys_dup(avalue,int1));
 end;
 freader.handle:= int1;
end;

function tcustomsocketpipes.getoverloadsleepus: integer;
begin
 result:= freader.overloadsleepus;
end;

procedure tcustomsocketpipes.setoverloadsleepus(const avalue: integer);
begin
 freader.overloadsleepus:= avalue;
end;

procedure tcustomsocketpipes.setoninputavailable(const avalue: socketpipeseventty);
begin
 foninputavailable:= avalue;
 if assigned(avalue) then begin
  freader.oninputavailable:= @doinputavailable;
 end
 else begin
  freader.oninputavailable:= nil;
 end;
end;

procedure tcustomsocketpipes.setonsocketbroken(const avalue: socketpipeseventty);
begin
 fonsocketbroken:= avalue;
 if assigned(avalue) then begin
  freader.onpipebroken:= @dopipebroken;
 end
 else begin
  freader.onpipebroken:= nil;
 end;
end;

procedure tcustomsocketpipes.doinputavailable(const sender: tpipereader);
begin
 if fowner.canevent(tmethod(foninputavailable)) then begin
  foninputavailable(self);
 end;
end;

procedure tcustomsocketpipes.dopipebroken(const sender: tpipereader);
begin
 if fowner.canevent(tmethod(fonsocketbroken)) then begin
  fonsocketbroken(self);
 end;
end;

{ tsocketcomp }

constructor tsocketcomp.create(aowner: tcomponent);
begin
 fhandle:= invalidfilehandle;
 inherited;
end;

destructor tsocketcomp.destroy;
begin
 inherited;
end;

procedure tsocketcomp.doactivated;
begin
 if factive then begin
  connect;
 end;
end;

procedure tsocketcomp.dodeactivated;
begin
 active:= false;
end;

procedure tsocketcomp.seturl(const avalue: filenamety);
begin
 checkinactive;
 furl:= avalue;
end;

procedure tsocketcomp.disconnect;
begin
 fhandle:= invalidfilehandle;
 factive:= false;
end;

procedure tsocketcomp.checkinactive;
begin
 if not (csloading in componentstate) and active then begin
  raise exception.create('Socket must be inactive.');
 end;
end;

procedure tsocketcomp.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  if not (csloading in componentstate) then begin
   if avalue then begin
    connect;
   end
   else begin
    disconnect;
   end;
  end
  else begin
   factive:= avalue;
  end;
 end;
end;

{ tsocketclient }

constructor tsocketclient.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tclientsocketpipes.create(self);
 end;
 inherited;
end;

destructor tsocketclient.destroy;
begin
 fpipes.free;
 inherited;
end;

procedure tsocketclient.setpipes(const avalue: tcustomsocketpipes);
begin
 fpipes.assign(avalue);
end;

procedure tsocketclient.connect;
begin
 syserror(sys_opensocket(sok_local,fhandle));
 try
  syserror(sys_connectlocalsocket(fhandle,furl));
 except
  sys_closefile(fhandle);
  fhandle:= invalidfilehandle;
  raise;
 end;
 try
  fpipes.handle:= fhandle;
 except
  disconnect;
  raise;
 end;
 factive:= true;
end;

procedure tsocketclient.disconnect;
begin
 fpipes.handle:= invalidfilehandle;
 inherited
end;

{ tsocketserver }

constructor tsocketserver.create(aowner: tcomponent);
begin
 fmaxconnections:= defaultmaxconnections;
 foverloadsleepus:= -1;
 inherited;
end;

destructor tsocketserver.destroy;
var
 int1: integer;
begin
 inherited;
 freeandnil(fthread);
 for int1:= 0 to high(fpipes) do begin
  fpipes[int1].free;
 end;
end;

procedure tsocketserver.connect;
begin
 syserror(sys_opensocket(sok_local,fhandle));
 try
  syserror(sys_bindlocalsocket(fhandle,furl));
 except
  sys_closefile(fhandle);
  fhandle:= invalidfilehandle;
  raise;
 end;
 try
  syserror(sys_listen(fhandle,fmaxconnections));
 except
  disconnect;
  raise;
 end;
 factive:= true;
 fthread:= tmsethread.create(@execthread);
end;

function tsocketserver.execthread(thread: tmsethread): integer;
var
 addr: socketaddrty;
 conn: integer;
 bo1: boolean;
 int1,int2: integer;
begin
 while not thread.terminated do begin
  if sys_accept(fhandle,conn,addr) = sye_ok then begin
   application.lock;
   try
    if canevent(tmethod(fonaccept)) then begin
     bo1:= false;
     fonaccept(self,addr,bo1);
    end
    else begin
     bo1:= true;
    end;
    if bo1 then begin
     int2:= -1;
     for int1:= 0 to high(fpipes) do begin
      if fpipes[int1] = nil then begin
       int2:= int1;
       break;
      end;
     end;
     if int2 < 0 then begin
      setlength(fpipes,high(fpipes)+2);
      int2:= high(fpipes);
     end;
     fpipes[int2]:= tserversocketpipes.create(self);
     with fpipes[int2] do begin
      overloadsleepus:= self.foverloadsleepus;
      oninputavailable:= self.foninputavailable;
      onsocketbroken:= self.fonsocketbroken;
      handle:= conn;
     end;
    end
    else begin
     sys_closesocket(conn);
    end;
   finally
    application.unlock;
   end;
  end;
 end;
end;

procedure tsocketserver.disconnect;
begin
 if fthread <> nil then begin
  fthread.terminate;
 end;
 inherited;
 freeandnil(fthread);
end;

end.
