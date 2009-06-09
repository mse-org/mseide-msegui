{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team
    
    Modified 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
 
unit msedatabase;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 classes,db,sysutils,msedb,msestrings,mseclasses,mseglob,msetypes,
 mseapplication;

type
 databaseoptionty = (dbo_utf8,dbo_noutf8,dbo_utf8message);
 databaseoptionsty = set of databaseoptionty;
 
 tmdbdataset = class;
 tmdatabase = class;
 tmdbtransaction = class;
 
 idbclient = interface(inullinterface)
  function getinstance: tobject;
  function getname: ansistring;
  function getactive: boolean;
  procedure setactive(avalue: boolean);
  function gettransaction: tmdbtransaction;
  function getrecno: integer;
  procedure setrecno(value: integer);
  procedure disablecontrols;
  procedure enablecontrols;
  function moveby(distance: longint): longint;
 end; 
 
 itransactionclient = interface(idbclient)
  procedure settransaction(const avalue: tmdbtransaction);
  procedure settransactionwrite(const avalue: tmdbtransaction);
  function getactive: boolean;
  procedure refreshtransaction;
 end;
 itransactionclientarty = array of itransactionclient;
 pitransactionclientarty = ^itransactionclientarty;
 
 idatabaseclient = interface(idbclient)
  procedure setdatabase(const sender: tmdatabase);
  procedure setactive(avalue: boolean);
 end;
 idatabaseclientarty = array of idatabaseclient;
 
// tmdbtransactionClass = class of tmdbtransaction;
 tmdbtransaction = class(TComponent)
  Private
    FActive        : boolean;
    FDatabase      : tmdatabase;
    FOpenAfterRead : boolean;
//    Function GetDataSetCount : Longint;
//    Function GetDataset(Index : longint) : tmdbdataset;
   ftagpo: pointer;
    procedure RegisterDataset (const DS: itransactionclient; const awrite: boolean);
    procedure UnRegisterDataset(const DS: itransactionclient; const awrite: boolean);
    procedure RemoveDataSets;
    procedure SetActive(Value : boolean);
  Protected
//    FDataSets      : TList;
    fcloselock: integer;
    fdatasets: itransactionclientarty;
    fwritedatasets: itransactionclientarty;
    Procedure SetDatabase (Value : tmdatabase); virtual;
    procedure CloseTrans;
    procedure openTrans;
    Procedure CheckDatabase;
    Procedure CheckActive;
    Procedure CheckInactive;
    procedure EndTransaction; virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure finalizetransaction; virtual;
               //called on connection closing
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
  Public
    constructor Create(AOwner: TComponent); override;
    Destructor destroy; override;
    procedure CloseDataSets;
    procedure refreshdatasets(const awrite: boolean = true; 
                                  const aread: boolean = true);
//    procedure refresh; //closes transaction and reopens datasets
    Property DataBase : tmdatabase Read FDatabase Write SetDatabase;
    property datasets: itransactionclientarty read fdatasets;
    property writedatasets: itransactionclientarty read fdatasets;
   property tagpo: pointer read ftagpo write ftagpo;
  published
    property Active : boolean read FActive write setactive;
  end;

  TLoginEvent = procedure(Sender: TObject; Username, Password: string) of object;

  TCustomConnection = class(TComponent)
  private
//    FAfterConnect: TNotifyEvent;
//    FAfterDisconnect: TNotifyEvent;
//    FBeforeConnect: TNotifyEvent;
//    FBeforeDisconnect: TNotifyEvent;
//    FLoginPrompt: Boolean;
//    FOnLogin: TLoginEvent;
    FStreamedConnected: Boolean;
//    procedure SetAfterConnect(const AValue: TNotifyEvent);
//    procedure SetAfterDisconnect(const AValue: TNotifyEvent);
//    procedure SetBeforeConnect(const AValue: TNotifyEvent);
//    procedure SetBeforeDisconnect(const AValue: TNotifyEvent);
   ftagpo: pointer;
  protected
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    function GetConnected : boolean; virtual;
    Function GetDataset(Index : longint) : TDataset; virtual;
//    Function GetDataSetCount : Longint; virtual;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
    procedure SetConnected (const avalue : boolean); virtual;
  public
    procedure Close;
    destructor Destroy; override;
    procedure Open;
//    property DataSetCount: Longint read GetDataSetCount;
//    property DataSets[Index: Longint]: TDataSet read GetDataSet;
   property tagpo: pointer read ftagpo write ftagpo;
  published
    property Connected: Boolean read GetConnected write SetConnected;
//    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt;
//    property Streamedconnected: Boolean read FStreamedConnected write FStreamedConnected;

//    property AfterConnect : TNotifyEvent read FAfterConnect write fafterconnect;
//    property AfterDisconnect : TNotifyEvent read FAfterDisconnect write fAfterDisconnect;
//    property BeforeConnect : TNotifyEvent read FBeforeConnect write fBeforeConnect;
//    property BeforeDisconnect : TNotifyEvent read FBeforeDisconnect write fBeforeDisconnect;
//    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
  end;

 databaseeventty = procedure(const sender: tmdatabase) of object;
 databaseerroreventty = procedure(const sender: tmdatabase;
             const aexception: exception; var handled: boolean) of object;
             
 // tmdatabaseClass = Class Of tmdatabase;
  tmdatabase = class(TCustomConnection)
  private
   FDataBaseName : String;
//    FDataSets : TList;
   fdatasets: idatabaseclientarty;
   FTransactions : TList;
   FDirectory : String;
   FKeepConnection : Boolean;
   FParams : TStrings;
   FSQLBased : Boolean;
   fonbeforeconnect: databaseeventty;
   fonconnecterror: databaseerroreventty;
   fonafterconnect: databaseeventty;
   fonbeforedisconnect: databaseeventty;
   fonafterdisconnect: databaseeventty;
   Function GetTransactionCount : Longint;
   Function GetTransaction(Index : longint) : tmdbtransaction;
//    procedure RegisterDataset (DS : tmdbdataset);
   procedure RegisterDataset(const DS: idatabaseclient);
   procedure RegisterTransaction (TA : tmdbtransaction);
   procedure UnRegisterDataset(const DS: idatabaseclient);
   procedure UnRegisterTransaction(TA : tmdbtransaction);
   procedure RemoveDataSets;
   procedure RemoveTransactions;
   procedure setparams(const avalue: tstrings);
  protected
   FConnected : Boolean;
   FOpenAfterRead : boolean;
   procedure setconnected(const avalue: boolean); override;
   Procedure CheckConnected;
   Procedure CheckDisConnected;
   procedure DoConnect; override;
   procedure DoDisconnect; override;
   procedure doafterinternalconnect; virtual;
   procedure dobeforeinternaldisconnect; virtual;
   function GetConnected : boolean; override;
//   Function GetDataset(Index : longint) : TDataset; override;
//    Function GetDataSetCount : Longint; override;
   Procedure DoInternalConnect; Virtual;Abstract;
   Procedure DoInternalDisConnect; Virtual;Abstract;
  public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   procedure CloseDataSets;
   procedure CloseTransactions;
//    procedure ApplyUpdates;
   procedure StartTransaction; virtual; abstract;
   procedure EndTransaction; virtual; abstract;
   property TransactionCount: Longint read GetTransactionCount;
   property Transactions[Index: Longint]: tmdbtransaction read GetTransaction;
   property Directory: string read FDirectory write FDirectory;
   property IsSQLBased: Boolean read FSQLBased;
   property datasets: idatabaseclientarty read fdatasets;
  published
   property Connected: Boolean read FConnected write SetConnected default false;
   property DatabaseName: string read FDatabaseName write FDatabaseName;
   property KeepConnection: Boolean read FKeepConnection 
                              write FKeepConnection default false;
   property Params : TStrings read FParams Write setparams;
   property onbeforeconnect: databaseeventty read fonbeforeconnect 
                                   write fonbeforeconnect;  
   property onafterconnect: databaseeventty read fonafterconnect 
                                   write fonafterconnect;  
   property onconnecterror: databaseerroreventty read fonconnecterror 
                                   write fonconnecterror; 
   property onbeforedisconnect: databaseeventty read fonbeforedisconnect 
                                   write fonbeforedisconnect; 
   property onafterdisconnect: databaseeventty read fonafterdisconnect 
                                   write fonafterdisconnect; 
  end;

  tmdbdatasetClass = Class of tmdbdataset;
  tmdbdataset = Class(TDataset,idatabaseclient,itransactionclient)
   private
    ftagpo: pointer;
   protected
    fdatabase : tmdatabase;
    ftransaction : tmdbtransaction;
    ftransactionwrite : tmdbtransaction;
    procedure setdatabase (const value: tmdatabase); virtual;
    procedure settransaction(const value: tmdbtransaction); virtual;
    procedure settransactionwrite(const value: tmdbtransaction); virtual;
//      procedure checkdatabase;
    //idbclient
    function getinstance: tobject;
    function getname: ansistring;
    function gettransaction: tmdbtransaction;
    procedure refreshtransaction; virtual; abstract;
   public
    destructor destroy; override;
    property database : tmdatabase read fdatabase write setdatabase;
    property transaction : tmdbtransaction read ftransaction write settransaction;
    property transactionwrite : tmdbtransaction read ftransactionwrite 
                           write settransactionwrite;
    property tagpo: pointer read ftagpo write ftagpo;
  end;

 ttacontroller = class(tactivatorcontroller)
  protected
   procedure setowneractive(const avalue: boolean); override;
  public
   constructor create(const aowner: tmdbtransaction);
 end;

 
procedure dosetdatabase(const sender: idatabaseclient; const avalue: tmdatabase;
                 var dest: tmdatabase);
procedure dosettransaction(const sender: itransactionclient; 
        const avalue: tmdbtransaction; var dest: tmdbtransaction;
        const awrite: boolean);
procedure checkdatabase(const aname: ansistring; const adatabase: tmdatabase);
procedure checktransaction(const aname: ansistring; const atransaction: tmdbtransaction);
procedure checkinactive(const active: boolean; const aname: ansistring);
procedure checkactive(const active: boolean; const aname: ansistring);
                 
implementation
uses
 dbconst,msefileutils,msedatalist,msebits;
 
procedure checkdatabase(const aname: ansistring; const adatabase: tmdatabase);
begin
 if adatabase = nil then begin
  raise edatabaseerror.create(aname+': '+serrdatabasenassigned);
 end;
end;

procedure checktransaction(const aname: ansistring;
                                   const atransaction: tmdbtransaction);
begin
 if atransaction = nil then begin
  raise edatabaseerror.create(aname+': '+serrtransactionnset);
 end;
end;

procedure checkinactive(const active: boolean; const aname: ansistring);
begin
 if active then begin
  raise edatabaseerror.create(aname+': Component is active.');
 end;
end;
 
procedure checkactive(const active: boolean; const aname: ansistring);
begin
 if not active then begin
  raise edatabaseerror.create(aname+': Component is not active.');
 end;
end;

procedure dosetdatabase(const sender: idatabaseclient; const avalue: tmdatabase;
                 var dest: tmdatabase);
begin
 if avalue <> dest then begin
  if sender.getactive then begin
   raise edatabaseerror.create('Database client "'+sender.getname+'" is active.');
  end;
  if dest <> nil then begin
   dest.unregisterdataset(sender);
  end;
  dest:= nil;
  if avalue <> nil then begin
   avalue.registerdataset(sender);
  end;
  dest:= avalue;
 end;
end;

procedure dosettransaction(const sender: itransactionclient; 
        const avalue: tmdbtransaction; var dest: tmdbtransaction;
        const awrite: boolean);
begin
 if avalue <> dest then begin
  if not awrite and sender.getactive then begin
   raise edatabaseerror.create('Transaction client "'+sender.getname+'" is active.');
  end;
  if dest <> nil then begin
   dest.unregisterdataset(sender,awrite);
  end;
  dest:= nil;
  if avalue <> nil then begin
   avalue.registerdataset(sender,awrite);
  end;
  dest:= avalue;
 end;
end;

{ tmdatabase }

constructor tmdatabase.Create(AOwner: TComponent);
begin
 inherited create(aowner);
 fparams:= tstringlist.create;
 ftransactions:= tlist.create;
end;

destructor tmdatabase.Destroy;

begin
 removedatasets; //needs working connection for closing
 removetransactions;
 connected:= false;
 ftransactions.free;
 fparams.free;
 inherited destroy;
end;

procedure tmdatabase.doafterinternalconnect;
begin
 fconnected:= true;
end;

procedure tmdatabase.dobeforeinternaldisconnect;
begin
 //dummy
end;

procedure tmdatabase.setconnected(const avalue: boolean);
var
 int1: integer;
 bo1: boolean;
begin
 if avalue <> fconnected then begin
  if avalue then begin
   if csreading in componentstate then begin
    fopenafterread:= true;
    exit;
   end
   else begin
    if assigned(onbeforeconnect) then begin
     onbeforeconnect(self);
    end;
    try
     dointernalconnect;
     doafterinternalconnect;
     if assigned(onafterconnect) then begin
       onafterconnect(self);
     end;
    except
     on e: exception do begin
      if assigned(onconnecterror) then begin
       bo1:= false;
       onconnecterror(self,e,bo1);
       if not bo1 then begin
        raise;
       end
       else begin
        if not connected then begin
         abort;
        end;
       end;
      end
      else begin
       raise;
      end;
     end;
    end;
   end;
  end
  else begin
   if csloading in componentstate then begin
    fopenafterread := false;
   end
   else begin
    if assigned(onbeforedisconnect) then begin
     onbeforedisconnect(self);
    end;
    dobeforeinternaldisconnect;
    closetransactions;
    dointernaldisconnect;
    fconnected:= avalue;
    if assigned(onafterdisconnect) then begin
     onafterdisconnect(self);
    end;
   end;
  end;
 end;
end;

{procedure tmdatabase.setconnected(avalue: boolean);
var
 bo1: boolean;
begin
 if avalue <> connected then begin
  if avalue then begin
   if csreading in componentstate then begin
    fstreamedconnected := true;
    exit;
   end
   else begin
    if assigned(fonbeforeconnect) then begin
      fonbeforeconnect(self);
    end;
    try
     doconnect;
     if assigned(fonafterconnect) then begin
       fonafterconnect(self);
     end;
    except
     on e: exception do begin
      if assigned(fonconnecterror) then begin
       bo1:= false;
       fonconnecterror(self,e,bo1);
       if not bo1 then begin
        raise;
       end;
      end;
     end;
    end;
   end;
  end
  else begin
   if assigned(fonbeforedisconnect) then begin
     fonbeforedisconnect(self);
   end;
   dodisconnect;
   if assigned(fonafterdisconnect) then begin
     fonafterdisconnect(self);
   end;
  end;
 end;
end;
}
Procedure tmdatabase.CheckConnected;

begin
  If Not Connected Then
    DatabaseError(SNotConnected,Self);
end;


Procedure tmdatabase.CheckDisConnected;
begin
  If Connected Then
    DatabaseError(SConnected,Self);
end;

procedure tmdatabase.DoConnect;
begin
  DoInternalConnect;
  FConnected := True;
end;

procedure tmdatabase.DoDisconnect;
begin
  Closedatasets;
  Closetransactions;
  DoInternalDisConnect;
  if csloading in ComponentState then
    FOpenAfterRead := false;
  FConnected := False;
end;

function tmdatabase.GetConnected: boolean;
begin
  Result:= FConnected;
end;

procedure tmdatabase.CloseDataSets;
var
 int1: integer;
begin
 int1:= high(fdatasets);
 while int1 > 0 do begin
  fdatasets[int1].setactive(false);
  dec(int1);
  if int1 > high(fdatasets) then begin
   int1:= high(fdatasets);  //could be destroyed
  end;
 end;
end;

procedure tmdatabase.CloseTransactions;

Var I : longint;

begin
 If Assigned(FTransactions) then begin
  For I:=FTransactions.Count-1 downto 0 do begin
   with tmdbtransaction(FTransactions[i]) do begin
    try
     EndTransaction;
    except
    end;
    finalizetransaction;
   end; 
  end;
 end;
end;

procedure tmdatabase.RemoveDataSets;
var
 int1: integer;
begin
 for int1:= high(fdatasets) downto 0 do begin
  with fdatasets[int1] do begin
   setactive(false);
   setdatabase(nil);
  end;
 end;
end;

procedure tmdatabase.RemoveTransactions;

Var I : longint;

begin
 If Assigned(FTransactions) then begin
  For I:=FTransactions.Count-1 downto 0 do begin
   with tmdbtransaction(FTransactions[i]) do begin
    setactive(false);
    Database:=Nil;
   end;
  end;
 end;
end;
{
Function tmdatabase.GetDataSetCount : Longint;

begin
  If Assigned(FDatasets) Then
    Result:=FDatasets.Count
  else
    Result:=0;
end;
}
Function tmdatabase.GetTransactionCount : Longint;

begin
  If Assigned(FTransactions) Then
    Result:=FTransactions.Count
  else
    Result:=0;
end;
{
Function tmdatabase.GetDataset(Index : longint) : TDataset;

begin
  If Assigned(FDatasets) then
    Result:=TDataset(FDatasets[Index])
  else
    begin
    result := nil;
    DatabaseError(SNoDatasets);
    end;
end;
}
Function tmdatabase.GetTransaction(Index : longint) : tmdbtransaction;

begin
  If Assigned(FTransactions) then
    Result:=tmdbtransaction(FTransactions[Index])
  else
    begin
    result := nil;
    DatabaseError(SNoTransactions);
    end;
end;

procedure tmdatabase.RegisterDataset(const DS: idatabaseclient);
var
 int1: integer;
begin
 int1:= high(fdatasets);
 if adduniqueitem(pointerarty(fdatasets),ds) <= int1 then begin
  DatabaseErrorFmt(SDatasetRegistered,[DS.getname]);
 end;
end;

procedure tmdatabase.RegisterTransaction (TA : tmdbtransaction);

Var I : longint;

begin
  I:=FTransactions.IndexOf(TA);
  If I=-1 then
    FTransactions.Add(TA)
  else
    DatabaseErrorFmt(STransactionRegistered,[TA.Name]);
end;

procedure tmdatabase.UnRegisterDataset(const DS: idatabaseclient);
begin
 if removeitem(pointerarty(fdatasets),ds) < 0 then begin
  DatabaseErrorFmt(SNoDatasetRegistered,[DS.getName]);
 end;
end;

procedure tmdatabase.UnRegisterTransaction (TA : tmdbtransaction);

Var I : longint;

begin
  I:=FTransactions.IndexOf(TA);
  If I<>-1 then
    FTransactions.Delete(I)
  else
    DatabaseErrorFmt(SNoTransactionRegistered,[TA.Name]);
end;

procedure tmdatabase.setparams(const avalue: tstrings);
begin
 fparams.assign(avalue);
end;

{ tmdbdataset }

Procedure tmdbdataset.SetDatabase (const Value : tmdatabase);

begin
 dosetdatabase(idatabaseclient(self),value,fdatabase);
end;

Procedure tmdbdataset.SetTransaction (const Value : tmdbtransaction);
begin
 dosettransaction(itransactionclient(self),value,ftransaction,false);
end;

procedure tmdbdataset.settransactionwrite(const value : tmdbtransaction);
begin
 dosettransaction(itransactionclient(self),value,ftransactionwrite,true);
end;

function tmdbdataset.getinstance: tobject;
begin
 result:= self;
end;

function tmdbdataset.getname: ansistring;
begin
 result:= name;
end;

function tmdbdataset.gettransaction: tmdbtransaction;
begin
 result:= ftransaction;
end;

Destructor tmdbdataset.Destroy;

begin
  Database:=Nil;
  Transaction:=Nil;
  transactionwrite:= nil;
  Inherited;
end;

{ tmdbtransaction }

procedure tmdbtransaction.SetActive(Value : boolean);
begin
  if FActive and (not Value) then
    EndTransaction
  else if (not FActive) and Value then
    if csreading in ComponentState then
      begin
      FOpenAfterRead := true;
      exit;
      end
    else
      StartTransaction;
end;

procedure tmdbtransaction.Loaded;

begin
  inherited;
  try
    if FOpenAfterRead then SetActive(true);
  except
    if csDesigning in Componentstate then
      InternalHandleException
    else
      raise;
  end;
end;

Procedure tmdbtransaction.InternalHandleException;

begin
  if assigned(classes.ApplicationHandleException) then
    classes.ApplicationHandleException(self)
  else
    ShowException(ExceptObject,ExceptAddr);
end;

Procedure tmdbtransaction.CheckActive;

begin
  If not FActive Then
    DatabaseError(STransNotActive,Self);
end;

Procedure tmdbtransaction.CheckInActive;

begin
  If FActive Then
    DatabaseError(STransActive,Self);
end;

Procedure tmdbtransaction.CloseTrans;

begin
  FActive := false;
end;

Procedure tmdbtransaction.OpenTrans;

begin
  FActive := true;
end;

Procedure tmdbtransaction.SetDatabase (Value : tmdatabase);

begin
  If Value<>FDatabase then
    begin
    CheckInactive;
    If Assigned(FDatabase) then
      FDatabase.UnregisterTransaction(Self);
    If Value<>Nil Then
      Value.RegisterTransaction(Self);
    FDatabase:=Value;
    end;
end;

constructor tmdbtransaction.create(AOwner : TComponent);

begin
  inherited create(AOwner);
//  FDatasets:=TList.Create;
end;

Procedure tmdbtransaction.CheckDatabase;

begin
  If (FDatabase=Nil) then
    DatabaseError(SErrNoDatabaseAvailable,Self)
end;

procedure tmdbtransaction.CloseDataSets;
var
 int1: integer;
begin
 if fcloselock = 0 then begin
  for int1:= high(fdatasets) downto 0 do begin
   fdatasets[int1].setactive(false);
  end;
//  for int1:= high(fwritedatasets) downto 0 do begin
//   fwritedatasets[int1].setactive(false);
//  end;
 end;
end;

procedure tmdbtransaction.refreshdatasets(const awrite: boolean = true; 
                          const aread: boolean = true);
var
 int1: integer;
begin
 if awrite then begin
  for int1:= high(fwritedatasets) downto 0 do begin
   with fwritedatasets[int1] do begin
    if getactive then begin
     refreshtransaction;
    end;
   end;
  end;
 end;
 if aread then begin
  for int1:= high(fdatasets) downto 0 do begin
   with fdatasets[int1] do begin
    if getactive then begin
     refreshtransaction;
    end;
   end;
  end;
 end;
end;

Destructor tmdbtransaction.Destroy;

begin
  active:= false;
  RemoveDatasets;
  Database:=Nil;
//  FDatasets.Free;
  Inherited;
end;

procedure tmdbtransaction.RemoveDataSets;
var 
 int1: integer;
begin
 for int1:= high(fwritedatasets) downto 0 do begin
  fwritedatasets[int1].settransactionwrite(nil);
 end;
 for int1:= high(fdatasets) downto 0 do begin
  fdatasets[int1].settransaction(nil);
 end;
end;
{
Function tmdbtransaction.GetDataSetCount : Longint;
begin
  If Assigned(FDatasets) Then
    Result:=FDatasets.Count
  else
    Result:=0;
end;
}
procedure tmdbtransaction.UnRegisterDataset(const DS: itransactionclient;
                              const awrite: boolean);
var
 ar1: pitransactionclientarty;
begin
 if awrite then begin
  ar1:= @fwritedatasets;
 end
 else begin
  ar1:= @fdatasets;
 end;
 if removeitem(pointerarty(ar1^),ds) < 0 then begin
  DatabaseErrorFmt(SNoDatasetRegistered,[DS.getName]);
 end;
end;

procedure tmdbtransaction.RegisterDataset(const DS: itransactionclient;
                   const awrite: boolean);
var
 int1: integer;
 ar1: pitransactionclientarty;
begin
 if awrite then begin
  ar1:= @fwritedatasets;
 end
 else begin
  ar1:= @fdatasets;
 end;
 int1:= high(ar1^);
 if adduniqueitem(pointerarty(ar1^),ds) <= int1 then begin
  DatabaseErrorFmt(SDatasetRegistered,[DS.getname]);
 end;
end;

procedure tmdbtransaction.finalizetransaction;
begin
 //dummy
end;
{
Function tmdbtransaction.GetDataset(Index : longint) : tmdbdataset;

begin
  If Assigned(FDatasets) then
    Result:=tmdbdataset(FDatasets[Index])
  else
  begin
    result := nil;
    DatabaseError(SNoDatasets);
  end;
end;
}
{ TCustomConnection }
{
procedure TCustomConnection.SetAfterConnect(const AValue: TNotifyEvent);
begin
//  if FAfterConnect=AValue then exit;
  FAfterConnect:=AValue;
end;
}
function TCustomConnection.GetDataSet(Index: Longint): TDataSet;
begin
  Result := nil;
end;
{
function TCustomConnection.GetDataSetCount: Longint;
begin
  Result := 0;
end;
}
procedure TCustomConnection.InternalHandleException;
begin
  if assigned(classes.ApplicationHandleException) then
    classes.ApplicationHandleException(self)
  else
    ShowException(ExceptObject,ExceptAddr);
end;
{
procedure TCustomConnection.SetAfterDisconnect(const AValue: TNotifyEvent);
begin
//  if FAfterDisconnect=AValue then exit;
  FAfterDisconnect:=AValue;
end;

procedure TCustomConnection.SetBeforeConnect(const AValue: TNotifyEvent);
begin
//  if FBeforeConnect=AValue then exit;
  FBeforeConnect:=AValue;
end;
}
procedure TCustomConnection.SetConnected(const avalue: boolean);
begin
  If aValue<>Connected then
    begin
    If aValue then
      begin
      if csReading in ComponentState then
        begin
        FStreamedConnected := true;
        exit;
        end
      else
        begin
//        if Assigned(BeforeConnect) then
//          BeforeConnect(self);
//        if FLoginPrompt then if assigned(FOnLogin) then
//          FOnLogin(self,'','');
        DoConnect;
//        if Assigned(AfterConnect) then
//          AfterConnect(self);
        end;
      end
    else
      begin
//      if Assigned(BeforeDisconnect) then
//        BeforeDisconnect(self);
      DoDisconnect;
//      if Assigned(AfterDisconnect) then
//        AfterDisconnect(self);
      end;
    end;
end;
{
procedure TCustomConnection.SetBeforeDisconnect(const AValue: TNotifyEvent);
begin
//  if FBeforeDisconnect=AValue then exit;
  FBeforeDisconnect:=AValue;
end;
}
procedure TCustomConnection.DoConnect;

begin
  // Do nothing yet
end;

procedure TCustomConnection.DoDisconnect;

begin
  // Do nothing yet
end;

function TCustomConnection.GetConnected: boolean;

begin
  Result := False;
end;

procedure TCustomConnection.Loaded;
begin
  inherited Loaded;
  try
    if FStreamedConnected then
      SetConnected(true);
  except
    if csDesigning in Componentstate then
      InternalHandleException
    else
      raise;
  end;
end;

procedure TCustomConnection.Close;
begin
  Connected := False;
end;

destructor TCustomConnection.Destroy;
begin
  Connected:=False;
  Inherited Destroy;
end;

procedure TCustomConnection.Open;
begin
  Connected := True;
end;

{ ttacontroller }

constructor ttacontroller.create(const aowner: tmdbtransaction);
begin
 inherited create(aowner);
end;

procedure ttacontroller.setowneractive(const avalue: boolean);
begin
 tmdbtransaction(fowner).active:= avalue;
end;

end.
