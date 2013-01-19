unit dbf_avl;

interface

{$I dbf_common.inc}

uses
  Dbf_Common;

type
  TBal = -1..1;

  TAvlTree = class;

  TKeyType = Cardinal;
  TExtraData = Pointer;

  PData = ^TData;
  TData = record
    ID: TKeyType;
    ExtraData: TExtraData;
  end;

  PNode = ^TNode;
  TNode = record
    Data: TData;
    Left: PNode;
    Right: PNode;
    Bal: TBal;    // balance factor: h(Right) - h(Left)
  end;

  TAvlTreeEvent = procedure(Sender: TAvlTree; Data: PData) of object;

  TAvlTree = class(TObject)
  private
    FRoot: PNode;
    FCount: Cardinal;
    FOnDelete: TAvlTreeEvent;
    FHeightChange: Boolean;

    function  InternalInsert(X: PNode; var P: PNode): Boolean;
    procedure InternalDelete(X: TKeyType; var P: PNode);

    procedure DeleteNode(X: PNode);
    procedure TreeDispose(X: PNode);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function  Find(Key: TKeyType): TExtraData;
    function  Insert(Key: TKeyType; Extra: TExtraData): Boolean;
    procedure Delete(Key: TKeyType);

    function  Lowest: PData;

    property Count: Cardinal read FCount;
    property OnDelete: TAvlTreeEvent read FOnDelete write FOnDelete;
  end;


implementation

uses
    Math;

procedure RotL(var P: PNode);
var
  P1: PNode;
begin
  P1 := P^.Right;
  P^.Right := P1^.Left;
  P1^.Left := P;
  P := P1;
end;

procedure RotR(var P: PNode);
var
  P1: PNode;
begin
  P1 := P^.Left;
  P^.Left := P1^.Right;
  P1^.Right := P;
  P := P1;
end;

function  Height(X: PNode): Integer;
begin
  if X = nil then
    Result := 0
  else
    Result := 1+Max(Height(X^.Left), Height(X^.Right));
end;

function  CheckTree_T(X: PNode; var H: Integer): Boolean;
var
  HR: Integer;
begin
  if X = nil then
  begin
    Result := true;
    H := 0;
  end else begin
    Result := CheckTree_T(X^.Left, H) and CheckTree_T(X^.Right, HR) and
        ((X^.Left = nil) or (X^.Left^.Data.ID < X^.Data.ID)) and
        ((X^.Right = nil) or (X^.Right^.Data.ID > X^.Data.ID)) and
//      ((Height(X^.Right) - Height(X^.Left)) = X^.Bal);
        (HR - H = X^.Bal);
    H := 1 + Max(H, HR);
  end;
end;

function  CheckTree(X: PNode): Boolean;
var
  H: Integer;
begin
  Result := CheckTree_T(X, H);
end;

procedure BalanceLeft(var P: PNode; var HeightChange: Boolean);
var
  B1, B2: TBal;
{HeightChange = true, left branch has become less high}
begin
  case P^.Bal of
   -1: begin P^.Bal := 0 end;
    0: begin P^.Bal := 1; HeightChange := false end;
    1: begin {Rebalance}
         B1 := P^.Right^.Bal;
         if B1 >= 0
         then {single L rotation}
           begin
             RotL(P);
             //adjust balance factors:
             if B1 = 0
             then
               begin P^.Bal :=-1; P^.Left^.Bal := 1; HeightChange := false end
             else
               begin P^.Bal := 0; P^.Left^.Bal := 0 end;
           end
         else {double RL rotation}
           begin
             B2 := P^.Right^.Left^.Bal;
             RotR(P^.Right);
             RotL(P);
             //adjust balance factors:
             if B2=+1 then P^.Left^.Bal := -1 else P^.Left^.Bal := 0;
             if B2=-1 then P^.Right^.Bal := 1 else P^.Right^.Bal := 0;
             P^.Bal := 0;
           end;
       end;{1}
  end{case}
end;{BalanceLeft}

procedure BalanceRight(var P: PNode; var HeightChange: Boolean);
var
  B1, B2: TBal;
{HeightChange = true, right branch has become less high}
begin
  case P^.Bal of
    1: begin P^.Bal := 0 end;
    0: begin P^.Bal := -1; HeightChange := false end;
   -1: begin {Rebalance}
         B1 := P^.Left^.Bal;
         if B1 <= 0
         then {single R rotation}
           begin
             RotR(P);
             //adjust balance factors}
             if B1 = 0
             then
               begin P^.Bal :=1; P^.Right^.Bal :=-1; HeightChange:= false end
             else
               begin P^.Bal := 0; P^.Right^.Bal := 0 end;
           end
         else {double LR rotation}
           begin
             B2 := P^.Left^.Right^.Bal;
             RotL(P^.Left);
             RotR(P);
             //adjust balance factors
             if B2=-1 then P^.Right^.Bal := 1 else P^.Right^.Bal := 0;
             if B2= 1 then P^.Left^.Bal := -1 else P^.Left^.Bal := 0;
             P^.Bal := 0;
           end;
       end;{-1}
  end{case}
end;{BalanceRight}

procedure DelRM(var R: PNode; var S: PNode; var HeightChange: Boolean);
// Make S refer to rightmost element of tree with root R;
// Remove that element from the tree
begin
  if R^.Right = nil then
    begin S := R; R := R^.Left; HeightChange := true end
  else
    begin
      DelRM(R^.Right, S, HeightChange);
      if HeightChange then BalanceRight(R, HeightChange)
    end
end;

//---------------------------------------
//---****--- Class TAvlTree ---*****-----
//---------------------------------------

constructor TAvlTree.Create;
begin
  inherited;

  FRoot := nil;
end;

destructor TAvlTree.Destroy;
begin
  Clear;

  inherited;
end;

procedure TAvlTree.Clear;
begin
  TreeDispose(FRoot);
  FRoot := nil;
end;

procedure TAvlTree.DeleteNode(X: PNode);
begin
  // delete handler installed?
  if Assigned(FOnDelete) then
    FOnDelete(Self, @X^.Data);

  // dispose of memory
  Dispose(X);
  Dec(FCount);
end;

procedure TAvlTree.TreeDispose(X: PNode);
var
  P: PNode;
begin
  // nothing to dispose of?
  if X = nil then
    exit;

  // use in-order visiting, maybe someone likes sequential ordering
  TreeDispose(X^.Left);
  P := X^.Right;

  // free mem
  DeleteNode(X);

  // free right child
  TreeDispose(P);
end;

function TAvlTree.Find(Key: TKeyType): TExtraData;
var
  H: PNode;
begin
  H := FRoot;
  while (H <> nil) and (H^.Data.ID <> Key) do // use conditional and
    if Key < H^.Data.ID then
      H := H^.Left
    else
      H := H^.Right;

  if H <> nil then
    Result := H^.Data.ExtraData
  else
    Result := nil;
end;

function TAvlTree.Insert(Key: TKeyType; Extra: TExtraData): boolean;
var
  H: PNode;
begin
  // make new node
  New(H);
  with H^ do
  begin
    Data.ID := Key;
    Data.ExtraData := Extra;
    Left := nil;
    Right := nil;
    Bal := 0;
  end;
  // insert new node
  Result := InternalInsert(H, FRoot);
  if not Result then
    Dispose(H);
  // check tree
//  assert(CheckTree(FRoot));
end;

procedure TAvlTree.Delete(Key: TKeyType);
begin
  InternalDelete(Key, FRoot);
//  assert(CheckTree(FRoot));
end;

function TAvlTree.InternalInsert(X: PNode; var P: PNode): boolean;
begin
  if P = nil then 
  begin 
    P := X; 
    Inc(FCount); 
    FHeightChange := true;
    Result := true;
  end else begin
    if X^.Data.ID < P^.Data.ID then
    begin
      { less }
      Result := InternalInsert(X, P^.Left);
      if FHeightChange then {Left branch has grown higher}
        case P^.Bal of
          1: begin P^.Bal := 0; FHeightChange := false end;
          0: begin P^.Bal := -1 end;
         -1: begin {Rebalance}
               if P^.Left^.Bal = -1
               then {single R rotation}
                 begin
                   RotR(P);
                   //adjust balance factor:
                   P^.Right^.Bal := 0;
                 end
               else {double LR rotation}
                 begin
                   RotL(P^.Left);
                   RotR(P);
                   //adjust balance factor:
                   case P^.Bal of
                     -1: begin P^.Left^.Bal :=  0; P^.Right^.Bal := 1 end;
                      0: begin P^.Left^.Bal :=  0; P^.Right^.Bal := 0 end;
                      1: begin P^.Left^.Bal := -1; P^.Right^.Bal := 0 end;
                   end;
                 end;
               P^.Bal := 0;
               FHeightChange := false;
//               assert(CheckTree(P));
             end{-1}
        end{case}
    end else
    if X^.Data.ID > P^.Data.ID then
    begin
      { greater }
      Result := InternalInsert(X, P^.Right);
      if FHeightChange then {Right branch has grown higher}
        case P^.Bal of
          -1: begin P^.Bal := 0; FHeightChange := false end;
           0: begin P^.Bal := 1 end;
           1: begin {Rebalance}
                if P^.Right^.Bal = 1
                then {single L rotation}
                  begin
                    RotL(P);
                    //adjust balance factor:
                    P^.Left.Bal := 0;
                  end
                else {double RL rotation}
                  begin
                    RotR(P^.Right);
                    RotL(P);
                    //adjust balance factor
                    case P^.Bal of
                       1: begin P^.Right^.Bal := 0; P^.Left^.Bal := -1 end;
                       0: begin P^.Right^.Bal := 0; P^.Left^.Bal :=  0 end;
                      -1: begin P^.Right^.Bal := 1; P^.Left^.Bal :=  0 end;
                    end;
                  end;
                P^.Bal := 0;
                FHeightChange := false;
//                assert(CheckTree(P));
              end{1}
         end{case}
    end {greater} else begin
      {X already present; do not insert again}
      FHeightChange := false;
      Result := false;
    end;
  end;
//  assert(CheckTree(P));
end;{InternalInsert}

procedure TAvlTree.InternalDelete(X: TKeyType; var P: PNode);
var
  Q: PNode;
  H: TData;
begin
  if P = nil then
    FHeightChange := false
  else
    if X < P^.Data.ID then
    begin
      InternalDelete(X, P^.Left);
      if FHeightChange then BalanceLeft(P, FHeightChange)
    end else
    if X > P^.Data.ID then
    begin
      InternalDelete(X, P^.Right);
      if FHeightChange then BalanceRight(P, FHeightChange)
    end else begin
      if P^.Right = nil then
      begin Q := P; P := P^.Left; FHeightChange := true end
      else if P^.Left = nil then
      begin Q := P; P := P^.Right; FHeightChange := true end
      else
        begin
          DelRM(P^.Left, Q, FHeightChange);
          H := P^.Data;
          P^.Data := Q^.Data;
          Q^.Data := H;
          if FHeightChange then BalanceLeft(P, FHeightChange)
        end;
      DeleteNode(Q)
    end;{eq}
end;{InternalDelete}

function TAvlTree.Lowest: PData;
var
  H: PNode;
begin
  H := FRoot;
  if H = nil then
  begin
    Result := nil;
    exit;
  end;

  while H^.Left <> nil do
    H := H^.Left;
  Result := @H^.Data;
end;

end.
