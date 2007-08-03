{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team
    
    Modified 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
 
unit msedatabase;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,sysutils,msedb,msestrings,mseclasses,mseguiglob,msetypes;
 
type
 tmdbdataset = class;
 tmdatabase = class;
 tmdbtransaction = class;
 
 idbclient = interface(inullinterface)
  function getinstance: tobject;
  function getname: ansistring;
  function getactive: boolean;
  procedure setactive(avalue: boolean);
 end; 
 
 itransactionclient = interface(idbclient)
  procedure settransaction(const avalue: tmdbtransaction);
 end;
 itransactionclientarty = array of itransactionclient;
 
 idatabaseclient = interface(idbclient)
  procedure setdatabase(const sender: tmdatabase);
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
    procedure RegisterDataset (const DS: itransactionclient);
    procedure UnRegisterDataset(const DS: itransactionclient);
    procedure RemoveDataSets;
    procedure SetActive(Value : boolean);
  Protected
//    FDataSets      : TList;
    fdatasets: itransactionclientarty;
    Procedure SetDatabase (Value : tmdatabase); virtual;
    procedure CloseTrans;
    procedure openTrans;
    Procedure CheckDatabase;
    Procedure CheckActive;
    Procedure CheckInactive;
    procedure EndTransaction; virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
  Public
    constructor Create(AOwner: TComponent); override;
    Destructor destroy; override;
    procedure CloseDataSets;
    Property DataBase : tmdatabase Read FDatabase Write SetDatabase;
    property datasets: itransactionclientarty read fdatasets;
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
    FLoginPrompt: Boolean;
    FOnLogin: TLoginEvent;
    FStreamedConnected: Boolean;
//    procedure SetAfterConnect(const AValue: TNotifyEvent);
//    procedure SetAfterDisconnect(const AValue: TNotifyEvent);
//    procedure SetBeforeConnect(const AValue: TNotifyEvent);
//    procedure SetBeforeDisconnect(const AValue: TNotifyEvent);
  protected
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    function GetConnected : boolean; virtual;
    Function GetDataset(Index : longint) : TDataset; virtual;
    Function GetDataSetCount : Longint; virtual;
    procedure InternalHandleException; virtual;
    procedure Loaded; override;
    procedure SetConnected (Value : boolean); virtual;
  public
    procedure Close;
    destructor Destroy; override;
    procedure Open;
    property DataSetCount: Longint read GetDataSetCount;
    property DataSets[Index: Longint]: TDataSet read GetDataSet;
  published
    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt;
    property Streamedconnected: Boolean read FStreamedConnected write FStreamedConnected;

//    property AfterConnect : TNotifyEvent read FAfterConnect write fafterconnect;
//    property AfterDisconnect : TNotifyEvent read FAfterDisconnect write fAfterDisconnect;
//    property BeforeConnect : TNotifyEvent read FBeforeConnect write fBeforeConnect;
//    property BeforeDisconnect : TNotifyEvent read FBeforeDisconnect write fBeforeDisconnect;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
  end;


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
    Function GetTransactionCount : Longint;
    Function GetTransaction(Index : longint) : tmdbtransaction;
//    procedure RegisterDataset (DS : tmdbdataset);
    procedure RegisterDataset(const DS: idatabaseclient);
    procedure RegisterTransaction (TA : tmdbtransaction);
    procedure UnRegisterDataset(const DS: idatabaseclient);
    procedure UnRegisterTransaction(TA : tmdbtransaction);
    procedure RemoveDataSets;
    procedure RemoveTransactions;
  protected
    FConnected : Boolean;
    FOpenAfterRead : boolean;
    Procedure CheckConnected;
    Procedure CheckDisConnected;
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    function GetConnected : boolean; override;
    Function GetDataset(Index : longint) : TDataset; override;
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
  published
    property Connected: Boolean read FConnected write SetConnected;
    property DatabaseName: string read FDatabaseName write FDatabaseName;
    property KeepConnection: Boolean read FKeepConnection write FKeepConnection;
    property Params : TStrings read FParams Write FParams;
  end;

 databaseeventty = procedure(const sender: tmdatabase) of object;
 databaseerroreventty = procedure(const sender: tmdatabase;
             const aexception: exception; var handled: boolean) of object;
             
  tmdbdatasetClass = Class of tmdbdataset;
  tmdbdataset = Class(TDataset,idatabaseclient,itransactionclient)
    Private
    Protected
      FDatabase : tmdatabase;
      FTransaction : tmdbtransaction;
      Procedure SetDatabase (const Value: tmdatabase); virtual;
      Procedure SetTransaction(const Value: tmdbtransaction); virtual;
//      Procedure CheckDatabase;
      //idbclient
      function getinstance: tobject;
      function getname: ansistring;
    Public
      Destructor destroy; override;
      Property DataBase : tmdatabase Read FDatabase Write SetDatabase;
      Property Transaction : tmdbtransaction Read FTransaction Write SetTransaction;
    end;

 ttacontroller = class(tactivatorcontroller)
  protected
   procedure setowneractive(const avalue: boolean); override;
  public
   constructor create(const aowner: tmdbtransaction);
 end;

 tdbcontroller = class(tactivatorcontroller)
  private
   fdatabasename: filenamety;
   fintf: idbcontroller;
   fonbeforeconnect: databaseeventty;
   fonconnecterror: databaseerroreventty;
   fonafterconnect: databaseeventty;
  protected
   procedure setowneractive(const avalue: boolean); override;
  public
   constructor create(const aowner: tmdatabase; const aintf: idbcontroller);
   function getdatabasename: filenamety;
   procedure setdatabasename(const avalue: filenamety);
  published
   property onbeforeconnect: databaseeventty read fonbeforeconnect 
                                   write fonbeforeconnect;  
   property onafterconnect: databaseeventty read fonafterconnect 
                                   write fonafterconnect;  
   property onconnecterror: databaseerroreventty read fonconnecterror 
                                   write fonconnecterror; 
 end;
 
procedure dosetdatabase(const sender: idatabaseclient; const avalue: tmdatabase;
                 var dest: tmdatabase);
procedure dosettransaction(const sender: itransactionclient; 
        const avalue: tmdbtransaction;var dest: tmdbtransaction);
procedure checkdatabase(const aname: ansistring; const adatabase: tmdatabase);
procedure checktransaction(const aname: ansistring; const atransaction: tmdbtransaction);
procedure checkinactive(const active: boolean; const aname: ansistring);
procedure checkactive(const active: boolean; const aname: ansistring);
                 
implementation
uses
 dbconst,msefileutils,msedatalist;
 
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
   raise edatabaseerror('Database client "'+sender.getname+'" is active.');
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
        const avalue: tmdbtransaction;var dest: tmdbtransaction);
begin
 if avalue <> dest then begin
  if sender.getactive then begin
   raise edatabaseerror('Transaction client "'+sender.getname+'" is active.');
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

{ tmdatabase }

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

constructor tmdatabase.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FParams:=TStringlist.Create;
//  FDatasets:=TList.Create;
  FTransactions:=TList.Create;
end;

destructor tmdatabase.Destroy;

begin
  Connected:=False;
  RemoveDatasets;
  RemoveTransactions;
//  FDatasets.Free;
  FTransactions.Free;
  FParams.Free;
  Inherited Destroy;
end;

procedure tmdatabase.CloseDataSets;
var
 int1: integer;
begin
 for int1:= 0 to high(fdatasets) do begin
  fdatasets[int1].setactive(false);
 end;
end;

procedure tmdatabase.CloseTransactions;

Var I : longint;

begin
  If Assigned(FTransactions) then
    begin
    For I:=FTransactions.Count-1 downto 0 do
      tmdbtransaction(FTransactions[i]).EndTransaction;
    end;
end;

procedure tmdatabase.RemoveDataSets;
var
 int1: integer;
begin
 for int1:= high(fdatasets) downto 0 do begin
  fdatasets[int1].setdatabase(nil);
 end;
end;

procedure tmdatabase.RemoveTransactions;

Var I : longint;

begin
  If Assigned(FTransactions) then
    For I:=FTransactions.Count-1 downto 0 do
      tmdbtransaction(FTransactions[i]).Database:=Nil;
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

{ tmdbdataset }

Procedure tmdbdataset.SetDatabase (const Value : tmdatabase);

begin
 dosetdatabase(idatabaseclient(self),value,fdatabase);
{
  If Value<>FDatabase then
    begin
    CheckInactive;
    If Assigned(FDatabase) then
      FDatabase.UnregisterDataset(idatabaseclient(Self));
    If Value<>Nil Then
      Value.RegisterDataset(idatabaseclient(Self));
    FDatabase:=Value;
    end;
}
end;

Procedure tmdbdataset.SetTransaction (const Value : tmdbtransaction);
begin
 dosettransaction(itransactionclient(self),value,ftransaction);
 {
  CheckInactive;
  If Value<>FTransaction then
    begin
    If Assigned(FTransaction) then
      FTransaction.UnregisterDataset(itransactionclient(Self));
    If Value<>Nil Then
      Value.RegisterDataset(itransactionclient(Self));
    FTransaction:=Value;
    end;
}
end;
{
Procedure tmdbdataset.CheckDatabase;

begin
  If (FDatabase=Nil) then
    DatabaseError(SErrNoDatabaseAvailable,Self)
end;
}
function tmdbdataset.getinstance: tobject;
begin
 result:= self;
end;

function tmdbdataset.getname: ansistring;
begin
 result:= name;
end;

Destructor tmdbdataset.Destroy;

begin
  Database:=Nil;
  Transaction:=Nil;
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
 for int1:= high(fdatasets) downto 0 do begin
  fdatasets[int1].setactive(false);
 end;
end;

Destructor tmdbtransaction.Destroy;

begin
  Database:=Nil;
  RemoveDatasets;
//  FDatasets.Free;
  Inherited;
end;

procedure tmdbtransaction.RemoveDataSets;
var 
 int1: integer;
begin
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
procedure tmdbtransaction.UnRegisterDataset(const DS: itransactionclient);
begin
 if removeitem(pointerarty(fdatasets),ds) < 0 then begin
  DatabaseErrorFmt(SNoDatasetRegistered,[DS.getName]);
 end;
end;

procedure tmdbtransaction.RegisterDataset(const DS: itransactionclient);
var
 int1: integer;
begin
 int1:= high(fdatasets);
 if adduniqueitem(pointerarty(fdatasets),ds) <= int1 then begin
  DatabaseErrorFmt(SDatasetRegistered,[DS.getname]);
 end;
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

function TCustomConnection.GetDataSetCount: Longint;
begin
  Result := 0;
end;

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
procedure TCustomConnection.SetConnected(Value: boolean);
begin
  If Value<>Connected then
    begin
    If Value then
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
        if FLoginPrompt then if assigned(FOnLogin) then
          FOnLogin(self,'','');
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

{ tdbcontroller }

constructor tdbcontroller.create(const aowner: tmdatabase; const aintf: idbcontroller);
begin
 fintf:= aintf;
 inherited create(aowner);
end;

procedure tdbcontroller.setowneractive(const avalue: boolean);
var
 bo1: boolean;
begin
 if avalue then begin
  with tmdatabase(fowner) do begin
   if checkcanevent(fowner,tmethod(fonbeforeconnect)) then begin
    fonbeforeconnect(tmdatabase(fowner));
   end;
   try
    fintf.setinheritedconnected(avalue);
   except
    on e: exception do begin
     if checkcanevent(fowner,tmethod(fonconnecterror)) then begin
      bo1:= false;
      fonconnecterror(tmdatabase(fowner),e,bo1);
      if not bo1 then begin
       raise;
      end;
     end;
    end;
   end;
   if checkcanevent(fowner,tmethod(fonafterconnect)) then begin
    fonafterconnect(tmdatabase(fowner));
   end;
  end;
 end
 else begin
  fintf.setinheritedconnected(avalue);
//  tmdatabase(fowner).connected:= avalue;
 end;
end;

function tdbcontroller.getdatabasename: filenamety;
begin
 result:= fdatabasename;
end;

procedure tdbcontroller.setdatabasename(const avalue: filenamety);
var
 str1: filenamety;
begin
 str1:= trim(avalue);
 if (str1 <> '') and (str1[1] = '''') and 
                    (str1[length(str1)] = '''') then begin
  fdatabasename:= str1;
  tmdatabase(fowner).databasename:= copy(str1,2,length(str1)-2);
 end
 else begin
  fdatabasename:= tomsefilepath(str1);
  tmdatabase(fowner).databasename:= 
                   tosysfilepath(filepath(str1,fk_default,true));
 end;
end;

end.
