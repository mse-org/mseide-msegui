{ Contributed module by Mikhail Kozlov (mihnik_k@mail.ru) for MSEgui(c)

    See the file COPYING.MSE the part of the MSEgui distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit GuiMDIChild;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
 
interface

uses
  msegui,mseclasses,mseforms,msedock,MSESysUtils,msegraphics,Classes,SysUtils,
  mseactions, msemenus, mseshapes;

type
  TMDIController = class;

  IMDIChild = interface
    procedure MDIStateChanged(const OldState, NewState: mdistatety);
  end;

  TMDIDockController = class(tformdockcontroller)
  private
    FMDIIntf: IMDIChild;
  protected
    procedure SetMDIState(const AValue: mdistatety); override;
  public
    constructor Create(aintf: idockcontroller; AMDIIntf: IMDIChild); reintroduce;
  end;

  TGuiMDIChildFo = class(tdockform, IMDIChild)
    ActionActivate: TAction;
    procedure OnExecuteActionActivate(const sender: TObject);
  private
    FKey: String;
    FCollection: TMDIController;
  protected
    procedure SetVisible(const Value: Boolean); override;
    procedure ActiveChanged; override;
    procedure SetKey(AValue: String); virtual;
    procedure MDIStateChanged(const OldState, NewState: mdistatety);
  public
    constructor Create(AMDICollection: TMDIController); reintroduce;
    destructor Destroy; override;
    property Key: String read FKey write SetKey;
  end;
  
  TMDIController = class(TMSEComponent)
  private
    FMainMDIWidget: TDockPanel;
    FChildren: TList;
    FMenu: TMenuItem;
    FWindowsMenu: TMenuItem;
    FActionMinAll: TAction;
    FActionMaxAll: TAction;
    FHideMinimized: Boolean;
    FLocked: Boolean;
  protected
    function GetCount(): Integer;
    function GetForm(Index: Integer): TGuiMDIChildFo;
    procedure Changed(); virtual;
    procedure SetMenu(AValue: TMenuItem); virtual;
    procedure UpdateActions(const Sender: TCustomAction);
    procedure ExecuteActions(const Sender: TObject);
    procedure SetHideMinimized(AValue: Boolean);
  public
    constructor Create(AOwner: TComponent; AMainMDIWidget: TDockPanel); reintroduce;
    destructor Destroy; override;
    function IndexOf(AChild: TGuiMDIChildFo): Integer;
    function IndexByKey(AKey: String): Integer;
    function ChildByKey(AKey: String): TGuiMDIChildFo;
    procedure Activate(AChild: TGuiMDIChildFo);
    procedure Deactivate(AChild: TGuiMDIChildFo);
    procedure Add(AChild: TGuiMDIChildFo);
    procedure Remove(AChild: TGuiMDIChildFo);
    procedure PlaceChild(AChild: TGuiMDIChildFo);
    procedure LockSequence;
    procedure UnlockSequence;
    property Locked: Boolean read FLocked;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TGuiMDIChildFo read GetForm; default;
  published
    property MainMDIWidget: TDockPanel read FMainMDIWidget write FMainMDIWidget;
    property Menu: TMenuItem read FMenu write SetMenu;
    property WindowsMenu: TMenuItem read FMenu;
    property ActionMinAll: TAction read FActionMinAll;
    property ActionMaxAll: TAction read FActionMaxAll;
    property HideMinimized: Boolean read FHideMinimized write SetHideMinimized;
  end;

const
  MDI_HSTEP = 20;
  MDI_VSTEP = 20;
  MDI_MAX_CONTROLPOS = 100;

implementation

uses
  GuiMDIChild_mfm;

//TMDIDockController >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

constructor TMDIDockController.Create(aintf: idockcontroller; AMDIIntf: IMDIChild);
begin
  inherited Create(aintf);
  FMDIIntf := AMDIIntf;
end;

procedure TMDIDockController.SetMDIState(const AValue: mdistatety);
var
  OldState: mdistatety;
begin
  OldState := MDIState;
  inherited SetMDIState(AValue);
  if Assigned(FMDIIntf) then
    FMDIIntf.MDIStateChanged(OldState, AValue);
end;

// TGuiMDIChildFo >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

constructor TGuiMDIChildFo.Create(AMDICollection: TMDIController);
begin
  if fdragdock = nil then 
    fdragdock:= TMDIDockController.create(idockcontroller(self), IMDIChild(Self));
  inherited Create(nil, True);
  if AMDICollection = nil then
    raise Exception.Create('MDICollection is nil');
  FCollection := AMDICollection;
  ParentWidget := FCollection.MainMDIWidget.Container;
  FCollection.Add(Self);
  if Visible then
    FCollection.Activate(Self);
end;

destructor TGuiMDIChildFo.Destroy;
begin
  FCollection.Remove(Self);
  inherited;
end;

procedure TGuiMDIChildFo.ActiveChanged;
begin
  inherited;
  if Active then
  begin
    Color := cl_selectedtextbackground;
    FCollection.Activate(Self);
    BringToFront;
    SetFocus;
  end
  else begin
    Color := cl_noedit;
  end;
end;

procedure TGuiMDIChildFo.SetKey(AValue: String);
begin
  FKey := AValue;
  ActionActivate.Caption := FKey;
end;

procedure TGuiMDIChildFo.MDIStateChanged(const OldState, NewState: mdistatety);
begin
  if (OldState = mds_minimized) and not (NewState = mds_minimized) then
    Activate;
  if NewState = mds_minimized then
  begin
    if FCollection.HideMinimized then
      Visible := False;
  end;
end;

procedure TGuiMDIChildFo.SetVisible(const Value: Boolean);
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    if Value then
    begin
      FCollection.Activate(Self);
    end
    else begin
      FCollection.Deactivate(Self);
    end;
  end;
end;

procedure TGuiMDIChildFo.OnExecuteActionActivate(const sender: TObject);
begin
  Self.Visible := True;
  Self.Activate;
end;

// TMDIController >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
constructor TMDIController.Create(AOwner: TComponent; AMainMDIWidget: TDockPanel);
begin
  inherited Create(AOwner);
  FMainMDIWidget := AMainMDIWidget;
  FChildren := TList.Create;
  FActionMinAll := TAction.Create(AOwner);
  FActionMinAll.Caption := 'Minimize all';
  FActionMinAll.OnUpdate := @UpdateActions;
  FActionMinAll.OnExecute := @ExecuteActions;
  FActionMaxAll := TAction.Create(AOwner);
  FActionMaxAll.Caption := 'Maximize all';
  FActionMaxAll.OnUpdate := @UpdateActions;
  FActionMaxAll.OnExecute := @ExecuteActions;
  FLocked := False;
  Changed;
end;

destructor TMDIController.Destroy;
begin
  FChildren.Free;
  inherited;
end;

function TMDIController.GetCount(): Integer;
begin
  Result := FChildren.Count;
end;

function TMDIController.GetForm(Index: Integer): TGuiMDIChildFo;
begin
  Result := TGuiMDIChildFo(FChildren[Index]);
end;

procedure TMDIController.Changed();
var
  I: Integer;
  M: TMenuItem;
begin
  if Assigned(FMenu) then
  begin
    if not Assigned(FWindowsMenu) then
    begin

      M := TMenuItem.Create(FMenu, FMenu.Owner);
      M.Action := FActionMinAll;
      FMenu.SubMenu.Insert(FMenu.SubMenu.Count, M);

      M := TMenuItem.Create(FMenu, FMenu.Owner);
      M.Action := FActionMaxAll;
      FMenu.SubMenu.Insert(FMenu.SubMenu.Count, M);

      FMenu.SubMenu.InsertSeparator(FMenu.SubMenu.Count);

      FWindowsMenu := TMenuItem.Create(FMenu, FMenu.Owner);
      FWindowsMenu.Caption := 'Windows';
      FMenu.Submenu.Insert(FMenu.Submenu.Count, FWindowsMenu);

    end;
    FWindowsMenu.SubMenu.Count := 0;
    for I := FChildren.Count - 1 downto 0 do
    begin
      M := TMenuItem.Create(FWindowsMenu, FMenu.Owner);
      M.Action := TGuiMDIChildFo(FChildren[I]).ActionActivate;
      FWindowsMenu.SubMenu.Insert(FWindowsMenu.Count, M);
    end;
  end;
end;

procedure TMDIController.SetMenu(AValue: TMenuItem);
begin
  FMenu := AValue;
  Changed;
end;

procedure TMDIController.UpdateActions(const Sender: TCustomAction);
var
  I: Integer;
  Enabled: Boolean;
begin
  Enabled := False;
  if Sender = FActionMinAll then
  begin
    for I := 0 to FChildren.Count - 1 do
      if not (TGuiMDIChildFo(FChildren[I]).DragDock.MDIState = mds_minimized) then
      begin
        Enabled := True;
        Break;
      end;
  end
  else if Sender = FActionMaxAll then
  begin
    for I := 0 to FChildren.Count - 1 do
      if not (TGuiMDIChildFo(FChildren[I]).DragDock.MDIState = mds_maximized) then
      begin
        Enabled := True;
        Break;
      end;
  end;
  if Enabled then
    Sender.State := Sender.State - [as_disabled]
  else
    Sender.State := Sender.State + [as_disabled];
end;

procedure TMDIController.ExecuteActions(const Sender: TObject);
var
  I: Integer;
begin
  LockSequence;
  try
    for I := 0 to FChildren.Count - 1 do
      if Sender is TMenuItem then
      begin
        if TMenuItem(Sender).Action = FActionMinAll then
          TGuiMDIChildFo(FChildren[I]).DragDock.MDIState := mds_minimized
        else if TMenuItem(Sender).Action = FActionMaxAll then
          TGuiMDIChildFo(FChildren[I]).DragDock.MDIState := mds_maximized;
      end;
  finally
    UnlockSequence;
  end;
end;

procedure TMDIController.SetHideMinimized(AValue: Boolean);
var
  I: Integer;
begin
  LockSequence;
  FHideMinimized := AValue;
  try
    for I := 0 to FChildren.Count - 1 do
    begin
      if TGuiMDIChildFo(FChildren[I]).DragDock.MDIState = mds_minimized then
        TGuiMDIChildFo(FChildren[I]).Visible := not AValue;
    end;
  finally
    UnlockSequence;
  end;
end;

function TMDIController.IndexOf(AChild: TGuiMDIChildFo): Integer;
begin
  Result := FChildren.IndexOf(AChild);
end;

function TMDIController.IndexByKey(AKey: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I :=0 to FChildren.Count - 1 do
    if Assigned(FChildren[I]) then
      if TGuiMDIChildFo(FChildren[I]).Key = AKey then
      begin
        Result := I;
        Break;
      end;
end;

function TMDIController.ChildByKey(AKey: String): TGuiMDIChildFo;
var
  I: Integer;
begin
  Result := nil;
  I := IndexByKey(AKey);
  if I >= 0 then
    Result := TGuiMDIChildFo(FChildren[I]);
end;

procedure TMDIController.Activate(AChild: TGuiMDIChildFo);
var
  Index, I: Integer;
begin
  if FLocked then
    Exit;
  Index := IndexOf(AChild);
  if Index = FChildren.Count - 1 then
    Exit;
  if Index >= 0 then
    for I := Index + 1 to FChildren.Count - 1 do
      FChildren.Exchange(I - 1, I);
  if not AChild.Active then
    AChild.Activate;
  Changed;
end;

procedure TMDIController.Deactivate(AChild: TGuiMDIChildFo);
begin
  if FLocked then
    Exit;
  if IndexOf(AChild) < FChildren.Count - 1 then
    Exit;
  if FChildren.Count > 1 then
  begin
    FChildren.Exchange(FChildren.Count - 1, FChildren.Count - 2);
    Children[Count - 1].Activate;
  end;
  Changed;
end;

procedure TMDIController.Add(AChild: TGuiMDIChildFo);
begin
  FChildren.Add(AChild);
  PlaceChild(AChild);
  Changed;
end;

procedure TMDIController.Remove(AChild: TGuiMDIChildFo);
var
  I: Integer;
begin
  if FLocked then
    Exit;
  if Assigned(FChildren) then
  begin
    I := FChildren.IndexOf(AChild);
    if I >= 0 then
      FChildren.Remove(AChild);
    Changed;
  end;
end;

procedure TMDIController.PlaceChild(AChild: TGuiMDIChildFo);
type
  TPosDescr = record
    X: Integer;
    Y: Integer;
    Weight: Integer;
  end;
  
var
  I, CurX, CurY, InitX, InitY, Weight, Min, Index: Integer;
  AvPositions: array of TPosDescr;
  BuildPositions: Boolean;
  
  function ChildrenCountByCorner(CornerX, CornerY: Integer): Integer;
  var
    I: Integer;
    Child: TGuiMDIChildFo;
  begin
    Result := 0;
    for I := 0 to FChildren.Count - 1 do
    begin
      Child := TGuiMDIChildFo(FChildren[I]);
      if (Child.bounds_x = CurX) and (Child.bounds_y = CurY) 
        and (Child <> AChild) then
        Result := Result + 1;
    end;
  end;
  
begin
  CurX := FMainMDIWidget.Container.bounds_x + 
    FMainMDIWidget.Frame.framei_left - FMainMDIWidget.Frame.leveli;
  CurY := FMainMDIWidget.Container.bounds_y + 
    FMainMDIWidget.Frame.framei_top - FMainMDIWidget.Frame.leveli;
  InitX := CurX;
  InitY := CurY;
  SetLength(AvPositions, 1);
  AvPositions[0].X := CurX;
  AvPositions[0].Y := CurY;
  AvPositions[0].Weight := ChildrenCountByCorner(CurX, CurY);
  Min := AvPositions[0].Weight;
  BuildPositions := True;
  while BuildPositions do
  begin
    CurX := CurX + MDI_HSTEP;
    CurY := CurY + MDI_VSTEP;
    if (CurX + AChild.bounds_cx) > FMainMDIWidget.Container.bounds_cx then
      CurX := InitX;
    if (CurY + AChild.bounds_cy) > FMainMDIWidget.Container.bounds_cy then
      CurY := InitY;
    BuildPositions := not (((CurY = InitY) and (CurX = InitX)) 
      or (Length(AvPositions) > MDI_MAX_CONTROLPOS));
    if BuildPositions then
    begin
      Weight := ChildrenCountByCorner(CurX, CurY);
      if Weight < Min then
        Min := Weight;
      SetLength(AvPositions, Length(AvPositions) + 1);
      AvPositions[High(AvPositions)].X := CurX;
      AvPositions[High(AvPositions)].Y := CurY;
      AvPositions[High(AvPositions)].Weight := Weight;
    end;
    BuildPositions := BuildPositions and (Weight > 0);
  end;
  Index := 0;
  Min := MDI_MAX_CONTROLPOS;
  for I := 0 to Length(AvPositions) - 1 do
  begin
    Weight := AvPositions[I].Weight;
    if Weight < Min then
    begin
      Min := Weight;
      Index := I;
    end;
  end;
  AChild.bounds_x := AvPositions[Index].X;
  AChild.bounds_y := AvPositions[Index].Y;
end;

procedure TMDIController.LockSequence;
begin
  FLocked := True;
end;

procedure TMDIController.UnlockSequence;
begin
  FLocked := False;
end;

end.
