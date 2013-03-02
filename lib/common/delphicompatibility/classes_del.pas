{
    This file is part of the Free Pascal Run Time Library (rtl)
    Copyright (c) 1999-2008 by Michael Van Canneyt, Florian Klaempfl,
    and Micha Nelissen

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
//modified 2013 by Martin Schreiber

unit classes_del;

interface
uses
 msetypes,sysutils,msesystypes,{$ifdef mswindows}windows,{$endif}msectypes;
 
const
  MaxListSize = Maxint div 16;
  GUID_NULL: TGuid = '{00000000-0000-0000-0000-000000000000}';
  OrdinalVarTypes = [varSmallInt, varInteger, varBoolean, varShortInt,
                     varByte, varWord,varLongWord,varInt64];

type
 ar4ty = packed array[0..3] of byte;
 ar8ty = packed array[0..7] of byte;
 culongaty = array[0..0] of culong;
 pculongaty = ^culongaty;
 tlibhandle = thandle;

{
 TSystemTime = packed record
    Year: Word;
    Month: Word;
    DayOfWeek: Word;
    Day: Word;
    Hour: Word;
    Minute: Word;
    Second: Word;
    Millisecond: Word;
  end;
}
       TGuid_fpc = packed record
          case integer of
             1 : (
                  Data1 : DWord;
                  Data2 : word;
                  Data3 : word;
                  Data4 : array[0..7] of byte;
                 );
             2 : (
                  D1 : DWord;
                  D2 : word;
                  D3 : word;
                  D4 : array[0..7] of byte;
                 );
             3 : ( { uuid fields according to RFC4122 }
                  time_low : dword;			// The low field of the timestamp
                  time_mid : word;                      // The middle field of the timestamp
                  time_hi_and_version : word;           // The high field of the timestamp multiplexed with the version number
                  clock_seq_hi_and_reserved : byte;     // The high field of the clock sequence multiplexed with the variant
                  clock_seq_low : byte;                 // The low field of the clock sequence
                  node : array[0..5] of byte;           // The spatially unique node identifier
                 );
       end;
       pguid_fpc = ^tguid_fpc;

  EListError = class(Exception);

{ TFPList class }

  PPointerList = ^TPointerList;
  TPointerList = array[0..MaxListSize - 1] of Pointer;
  TListSortCompare = function (Item1, Item2: Pointer): Integer;
//  TListCallback = Types.TListCallback;
//  TListStaticCallback = Types.TListStaticCallback;


  TListAssignOp = (laCopy, laAnd, laOr, laXor, laSrcUnique, laDestUnique);
//  TFPList = class;
{
  TFPListEnumerator = class
  private
    FList: TFPList;
    FPosition: Integer;
  public
    constructor Create(AList: TFPList);
    function GetCurrent: Pointer;
    function MoveNext: Boolean;
    property Current: Pointer read GetCurrent;
  end;
 }
//type
  TDirection = (FromBeginning, FromEnd);

  TFPList = class(TObject)
  private
    FList: PPointerList;
    FCount: Integer;
    FCapacity: Integer;
    procedure CopyMove (aList : TFPList);
    procedure MergeMove (aList : TFPList);
    procedure DoCopy(ListA, ListB : TFPList);
    procedure DoSrcUnique(ListA, ListB : TFPList);
    procedure DoAnd(ListA, ListB : TFPList);
    procedure DoDestUnique(ListA, ListB : TFPList);
    procedure DoOr(ListA, ListB : TFPList);
    procedure DoXOr(ListA, ListB : TFPList);
  protected
    function Get(Index: Integer): Pointer; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    procedure Put(Index: Integer; Item: Pointer); {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    Procedure RaiseIndexError(Index: Integer);
  public
    destructor Destroy; override;
    Procedure AddList(AList : TFPList);
    function Add(Item: Pointer): Integer; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    procedure Clear;
    procedure Delete(Index: Integer); {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    class procedure Error(const Msg: string; Data: PtrInt);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TFPList; {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    function Extract(Item: Pointer): Pointer;
    function First: Pointer;
//    function GetEnumerator: TFPListEnumerator;
    function IndexOf(Item: Pointer): Integer;
    function IndexOfItem(Item: Pointer; Direction: TDirection): Integer;
    procedure Insert(Index: Integer; Item: Pointer); {$ifdef CLASSESINLINE} inline; {$endif CLASSESINLINE}
    function Last: Pointer;
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Assign (ListA: TFPList; AOperator: TListAssignOp=laCopy; ListB: TFPList=nil);
    function Remove(Item: Pointer): Integer;
    procedure Pack;
    procedure Sort(Compare: TListSortCompare);
//    procedure ForEachCall(proc2call:TListCallback;arg:pointer);
//    procedure ForEachCall(proc2call:TListStaticCallback;arg:pointer);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Pointer read Get write Put; default;
    property List: PPointerList read FList;
  end;

function NtoLE(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function NtoLE(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function NtoLE(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function NtoLE(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function NtoLE(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function NtoLE(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function LEtoN(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
function BEtoN(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;

function SwapEndian(const AValue: SmallInt): SmallInt; overload;
function SwapEndian(const AValue: Word): Word; overload;
function SwapEndian(const AValue: LongInt): LongInt; overload;
function SwapEndian(const AValue: DWord): DWord; overload;
function SwapEndian(const AValue: Int64): Int64; overload;
function SwapEndian(const AValue: QWord): QWord; overload;

function Unassigned: Variant; // Unassigned standard constant
function Null: Variant;       // Null standard constant

function  GetCurrentThreadId : threadty;
Function GetProcedureAddress(Lib : TLibHandle;
                  const ProcName : AnsiString) : Pointer;
procedure copycharbuf(const asource: string; const asize: integer; out buffer);
//Function FileTruncate (Handle : THandle;Size: Int64) : boolean;
{$ifndef FPC}
 {$ifdef MSWINDOWS}
function InterlockedIncrement(var I: Integer): Integer;
function InterlockedDecrement(var I: Integer): Integer;
function InterlockedExchange(var A: Integer; B: Integer): Integer;
function InterlockedExchangeAdd(var A: Integer; B: Integer): Integer;
 {$endif}
{$endif}
function LeftStr(const S: string; Count: integer): string;

implementation
uses
 rtlconsts,msesysintf;
{$ifndef FPC}
{$define endian_little}
{$define FPC_HAS_TYPE_EXTENDED}
{$endif}

function LeftStr(const S: string; Count: integer): string;
begin
  result := Copy(S, 1, Count);
end ;

{$ifndef FPC}
 {$ifdef MSWINDOWS}
function InterlockedIncrement(var I: Integer): Integer;
begin
 result:= windows.interlockedincrement(i);
end;

function InterlockedDecrement(var I: Integer): Integer;
begin
 result:= windows.interlockeddecrement(i);
end;

function InterlockedExchange(var A: Integer; B: Integer): Integer;
begin
 result:= windows.interlockedexchange(a,b);
end;

function InterlockedExchangeAdd(var A: Integer; B: Integer): Integer;
begin
 result:= windows.interlockedexchangeadd(a,b);
end;
 {$endif}
{$endif}

function Unassigned: Variant; // Unassigned standard constant
begin
//  VarClearProc(TVarData(Result));
  VarClear(variant(Result));
  TVarData(Result).VType := varempty;
end;


function Null: Variant;       // Null standard constant
  begin
//    VarClearProc(TVarData(Result));
    VarClear(variant(Result));
    TVarData(Result).VType := varnull;
  end;

function SwapEndian(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
  begin
    { the extra Word type cast is necessary because the "AValue shr 8" }
    { is turned into "longint(AValue) shr 8", so if AValue < 0 then    }
    { the sign bits from the upper 16 bits are shifted in rather than  }
    { zeroes.                                                          }
    Result := SmallInt((Word(AValue) shr 8) or (Word(AValue) shl 8));
  end;


function SwapEndian(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
                               overload;
  begin
    Result := Word((AValue shr 8) or (AValue shl 8));
  end;


function SwapEndian(const AValue: LongInt): LongInt;
                               overload;
  begin
    Result := (AValue shl 24)
           or ((AValue and $0000FF00) shl 8)
           or ((AValue and $00FF0000) shr 8)
           or (AValue shr 24);
  end;


function SwapEndian(const AValue: DWord): DWord;
                               overload;
  begin
    Result := (AValue shl 24)
           or ((AValue and $0000FF00) shl 8)
           or ((AValue and $00FF0000) shr 8)
           or (AValue shr 24);
  end;


function SwapEndian(const AValue: Int64): Int64;
                               overload;
  begin
    Result := (AValue shl 56)
           or ((AValue and $000000000000FF00) shl 40)
           or ((AValue and $0000000000FF0000) shl 24)
           or ((AValue and $00000000FF000000) shl 8)
           or ((AValue and $000000FF00000000) shr 8)
           or ((AValue and $0000FF0000000000) shr 24)
           or ((AValue and $00FF000000000000) shr 40)
           or (AValue shr 56);
  end;

function SwapEndiani64(const AValue: Int64): Int64;
  begin
    Result := (AValue shl 56)
           or ((AValue and $000000000000FF00) shl 40)
           or ((AValue and $0000000000FF0000) shl 24)
           or ((AValue and $00000000FF000000) shl 8)
           or ((AValue and $000000FF00000000) shr 8)
           or ((AValue and $0000FF0000000000) shr 24)
           or ((AValue and $00FF000000000000) shr 40)
           or (AValue shr 56);
  end;


function SwapEndian(const AValue: QWord): QWord;
                               overload;
  begin
    Result := (AValue shl 56)
           or ((AValue and $000000000000FF00) shl 40)
           or ((AValue and $0000000000FF0000) shl 24)
           or ((AValue and $00000000FF000000) shl 8)
           or ((AValue and $000000FF00000000) shr 8)
           or ((AValue and $0000FF0000000000) shr 24)
           or ((AValue and $00FF000000000000) shr 40)
           or (AValue shr 56);
  end;

function SwapEndianq64(const AValue: QWord): QWord;
  begin
    Result := (AValue shl 56)
           or ((AValue and $000000000000FF00) shl 40)
           or ((AValue and $0000000000FF0000) shl 24)
           or ((AValue and $00000000FF000000) shl 8)
           or ((AValue and $000000FF00000000) shr 8)
           or ((AValue and $0000FF0000000000) shr 24)
           or ((AValue and $00FF000000000000) shr 40)
           or (AValue shr 56);
  end;

function NtoLE(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function NtoLE(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function NtoLE(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function NtoLE(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function NtoLE(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function NtoLE(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;

function LEtoN(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function LEtoN(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function LEtoN(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function LEtoN(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function LEtoN(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function LEtoN(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_LITTLE}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;

function BEtoN(const AValue: SmallInt): SmallInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function BEtoN(const AValue: Word): Word;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function BEtoN(const AValue: LongInt): LongInt;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function BEtoN(const AValue: DWord): DWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndian(AValue);
    {$ENDIF}
  end;


function BEtoN(const AValue: Int64): Int64;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndiani64(AValue);
    {$ENDIF}
  end;


function BEtoN(const AValue: QWord): QWord;{$ifdef SYSTEMINLINE}inline;{$endif}
  begin
    {$IFDEF ENDIAN_BIG}
      Result := AValue;
    {$ELSE}
      Result := SwapEndianq64(AValue);
    {$ENDIF}
  end;
(*
Function FileTruncate (Handle : THandle;Size: Int64) : boolean;
begin
{
  Result:=longint(SetFilePointer(handle,Size,nil,FILE_BEGIN))<>-1;
}
  if FileSeek (Handle, Size, FILE_BEGIN) = Size then
   Result:=SetEndOfFile(handle)
  else
   Result := false;
end;
*)
procedure copycharbuf(const asource: string; const asize: integer; out buffer);
var
 int1: integer;
begin
 if asize > 0 then begin
  if asource = '' then begin
   pchar(@buffer)^:= #0;
  end
  else begin
   int1:= length(asource)+1;
   if int1 > asize then begin
    int1:= asize;
   end;
   move(pchar(pointer(asource))^,pchar(@buffer)^,int1);
  end;
 end;
end;

Function GetProcedureAddress(Lib : TLibHandle;
                  const ProcName : AnsiString) : Pointer;
begin
  Result:= {$ifdef mswindows}Windows.{$endif}GetProcAddress(Lib,PChar(ProcName));
end;

function  GetCurrentThreadId : threadty;
begin
 result:= sys_getcurrentthread;
// result:= getcurrentthread;
end;

{****************************************************************************}
{*                           TFPList                                        *}
{****************************************************************************}

Const
  // Ratio of Pointer and Word Size.
  WordRatio = SizeOf(Pointer) Div SizeOf(Word);

procedure TFPList.RaiseIndexError(Index : Integer);
begin
  Error(SListIndexError, Index);
end;

function TFPList.Get(Index: Integer): Pointer;
begin
  If (Index < 0) or (Index >= FCount) then
    RaiseIndexError(Index);
  Result:=FList^[Index];
end;

procedure TFPList.Put(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    RaiseIndexError(Index);
  Flist^[Index] := Item;
end;

function TFPList.Extract(Item: Pointer): Pointer;
var
  i : Integer;
begin
  i := IndexOf(item);
  if i >= 0 then
   begin
     Result := item;
     Delete(i);
   end
  else
    result := nil;
end;

procedure TFPList.SetCapacity(NewCapacity: Integer);
begin
  If (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
     Error (SListCapacityError, NewCapacity);
  if NewCapacity = FCapacity then
    exit;
  ReallocMem(FList, SizeOf(Pointer)*NewCapacity);
  FCapacity := NewCapacity;
end;

procedure TFPList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize)then
    Error(SListCountError, NewCount);
  If NewCount > FCount then
    begin
    If NewCount > FCapacity then
      SetCapacity(NewCount);
    If FCount < NewCount then
      Fillchar(Flist^[FCount], (NewCount-FCount) *  sizeof(pointer), 0);
    end;
  FCount := Newcount;
end;

destructor TFPList.Destroy;
begin
  Self.Clear;
  inherited Destroy;
end;

Procedure TFPList.AddList(AList : TFPList);

Var
  I : Integer;

begin
  If (Capacity<Count+AList.Count) then
    Capacity:=Count+AList.Count;
  For I:=0 to AList.Count-1 do
    Add(AList[i]);
end;


function TFPList.Add(Item: Pointer): Integer;
begin
  if FCount = FCapacity then
    Self.Expand;
  FList^[FCount] := Item;
  Result := FCount;
  FCount := FCount + 1;
end;

procedure TFPList.Clear;
begin
  if Assigned(FList) then
  begin
    SetCount(0);
    SetCapacity(0);
    FList := nil;
  end;
end;

procedure TFPList.Delete(Index: Integer);
begin
  If (Index<0) or (Index>=FCount) then
    Error (SListIndexError, Index);
  FCount := FCount-1;
  System.Move (FList^[Index+1], FList^[Index], (FCount - Index) * SizeOf(Pointer));
  // Shrink the list if appropriate
  if (FCapacity > 256) and (FCount < FCapacity shr 2) then
  begin
    FCapacity := FCapacity shr 1;
    ReallocMem(FList, SizeOf(Pointer) * FCapacity);
  end;
end;

class procedure TFPList.Error(const Msg: string; Data: PtrInt);
begin
  Raise EListError.CreateFmt(Msg,[Data]){ at get_caller_addr(get_frame)};
end;

procedure TFPList.Exchange(Index1, Index2: Integer);
var
  Temp : Pointer;
begin
  If ((Index1 >= FCount) or (Index1 < 0)) then
    Error(SListIndexError, Index1);
  If ((Index2 >= FCount) or (Index2 < 0)) then
    Error(SListIndexError, Index2);
  Temp := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Temp;
end;

function TFPList.Expand: TFPList;
var
  IncSize : Longint;
begin
  if FCount < FCapacity then begin
   result:= self;
   exit;
  end;
  IncSize := 4;
  if FCapacity > 3 then IncSize := IncSize + 4;
  if FCapacity > 8 then IncSize := IncSize+8;
  if FCapacity > 127 then Inc(IncSize, FCapacity shr 2);
  SetCapacity(FCapacity + IncSize);
  Result := Self;
end;

function TFPList.First: Pointer;
begin
  If FCount = 0 then
    Result := Nil
  else
    Result := Items[0];
end;

function TFPList.IndexOf(Item: Pointer): Integer;

Var
  C : Integer;

begin
  Result:=0;
  C:=Count;
  while (Result<C) and (Flist^[Result]<>Item) do
    Inc(Result);
  If Result>=C then
    Result:=-1;
end;

function TFPList.IndexOfItem(Item: Pointer; Direction: TDirection): Integer;

Var
  C : Integer;

begin
  if Direction=fromBeginning then
    Result:=IndexOf(Item)
  else
    begin
    Result:=Count-1;
    while (Result >=0) and (Flist^[Result]<>Item) do
      Result:=Result - 1;
    end;      
end;

procedure TFPList.Insert(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index > FCount )then
    Error(SlistIndexError, Index);
  iF FCount = FCapacity then Self.Expand;
  if Index<FCount then
    System.Move(Flist^[Index], Flist^[Index+1], (FCount - Index) * SizeOf(Pointer));
  FList^[Index] := Item;
  FCount := FCount + 1;
end;

function TFPList.Last: Pointer;
begin
{ Wouldn't it be better to return nil if the count is zero ?}
  If FCount = 0 then
    Result := nil
  else
    Result := Items[FCount - 1];
end;

procedure TFPList.Move(CurIndex, NewIndex: Integer);
var
  Temp : Pointer;
begin
  if ((CurIndex < 0) or (CurIndex > Count - 1)) then
    Error(SListIndexError, CurIndex);
  if ((NewIndex < 0) or (NewIndex > Count -1)) then
    Error(SlistIndexError, NewIndex);
  Temp := FList^[CurIndex];
  if NewIndex > CurIndex then
    System.Move(FList^[CurIndex+1], FList^[CurIndex], (NewIndex - CurIndex) * SizeOf(Pointer))
  else
    System.Move(FList^[NewIndex], FList^[NewIndex+1], (CurIndex - NewIndex) * SizeOf(Pointer));
  FList^[NewIndex] := Temp;
end;

function TFPList.Remove(Item: Pointer): Integer;
begin
  Result := IndexOf(Item);
  If Result <> -1 then
    Self.Delete(Result);
end;

procedure TFPList.Pack;
var
  NewCount,
  i : integer;
  pdest,
  psrc : PPointer;
begin
  NewCount:=0;
  psrc:=@FList^[0];
  pdest:=psrc;
  For I:=0 To FCount-1 Do
    begin
      if assigned(psrc^) then
        begin
          pdest^:=psrc^;
          inc(pdest);
          inc(NewCount);
        end;
      inc(psrc);
    end;
  FCount:=NewCount;
end;

// Needed by Sort method.

Procedure QuickSort(FList: PPointerList; L, R : Longint;
                     Compare: TListSortCompare);
var
  I, J : Longint;
  P, Q : Pointer;
begin
 repeat
   I := L;
   J := R;
   P := FList^[ (L + R) div 2 ];
   repeat
     while Compare(P, FList^[i]) > 0 do
       I := I + 1;
     while Compare(P, FList^[J]) < 0 do
       J := J - 1;
     If I <= J then
     begin
       Q := FList^[I];
       Flist^[I] := FList^[J];
       FList^[J] := Q;
       I := I + 1;
       J := J - 1;
     end;
   until I > J;
   // sort the smaller range recursively
   // sort the bigger range via the loop
   // Reasons: memory usage is O(log(n)) instead of O(n) and loop is faster than recursion
   if J - L < R - I then
   begin
     if L < J then
       QuickSort(FList, L, J, Compare);
     L := I;
   end
   else
   begin
     if I < R then
       QuickSort(FList, I, R, Compare);
     R := J;
   end;
 until L >= R;
end;

procedure TFPList.Sort(Compare: TListSortCompare);
begin
  if Not Assigned(FList) or (FCount < 2) then exit;
  QuickSort(Flist, 0, FCount-1, Compare);
end;

procedure TFPList.CopyMove (aList : TFPList);
var r : integer;
begin
  Clear;
  for r := 0 to aList.count-1 do
    Add (aList[r]);
end;

procedure TFPList.MergeMove (aList : TFPList);
var r : integer;
begin
  For r := 0 to aList.count-1 do
    if self.indexof(aList[r]) < 0 then
      self.Add (aList[r]);
end;

procedure TFPList.DoCopy(ListA, ListB : TFPList);
begin
  if assigned (ListB) then
    CopyMove (ListB)
  else
    CopyMove (ListA);
end;

procedure TFPList.DoDestUnique(ListA, ListB : TFPList);
  procedure MoveElements (src, dest : TFPList);
  var r : integer;
  begin
    self.clear;
    for r := 0 to src.count-1 do
      if dest.indexof(src[r]) < 0 then
        self.Add (src[r]);
  end;
  
var dest : TFPList;
begin
  if assigned (ListB) then
    MoveElements (ListB, ListA)
  else
    try
      dest := TFPList.Create;
      dest.CopyMove (self);
      MoveElements (ListA, dest)
    finally
      dest.Free;
    end;
end;

procedure TFPList.DoAnd(ListA, ListB : TFPList);
var r : integer;
begin
  if assigned (ListB) then
    begin
    self.clear;
    for r := 0 to ListA.count-1 do
      if ListB.indexOf (ListA[r]) >= 0 then
        self.Add (ListA[r]);
    end
  else
    begin
    for r := self.Count-1 downto 0 do
      if ListA.indexof (Self[r]) < 0 then
        self.delete (r);
    end;
end;

procedure TFPList.DoSrcUnique(ListA, ListB : TFPList);
var r : integer;
begin
  if assigned (ListB) then
    begin
    self.Clear;
    for r := 0 to ListA.Count-1 do
      if ListB.indexof (ListA[r]) < 0 then
        self.Add (ListA[r]);
    end
  else
    begin
    for r := self.count-1 downto 0 do
      if ListA.indexof (self[r]) >= 0 then
        self.delete (r);
    end;
end;

procedure TFPList.DoOr(ListA, ListB : TFPList);
begin
  if assigned (ListB) then
    begin
    CopyMove (ListA);
    MergeMove (ListB);
    end
  else
    MergeMove (ListA);
end;

procedure TFPList.DoXOr(ListA, ListB : TFPList);
var r : integer;
    l : TFPList;
begin
  if assigned (ListB) then
    begin
    self.Clear;
    for r := 0 to ListA.count-1 do
      if ListB.indexof (ListA[r]) < 0 then
        self.Add (ListA[r]);
    for r := 0 to ListB.count-1 do
      if ListA.indexof (ListB[r]) < 0 then
        self.Add (ListB[r]);
    end
  else
    try
      l := TFPList.Create;
      l.CopyMove (Self);
      for r := self.count-1 downto 0 do
        if listA.indexof (self[r]) >= 0 then
          self.delete (r);
      for r := 0 to ListA.count-1 do
        if l.indexof (ListA[r]) < 0 then
          self.add (ListA[r]);
    finally
      l.Free;
    end;
end;


procedure TFPList.Assign (ListA: TFPList; AOperator: TListAssignOp=laCopy; ListB: TFPList=nil);
begin
  case AOperator of
    laCopy : DoCopy (ListA, ListB);             // replace dest with src
    laSrcUnique : DoSrcUnique (ListA, ListB);   // replace dest with src that are not in dest
    laAnd : DoAnd (ListA, ListB);               // remove from dest that are not in src
    laDestUnique : DoDestUnique (ListA, ListB); // remove from dest that are in src
    laOr : DoOr (ListA, ListB);                 // add to dest from src and not in dest
    laXOr : DoXOr (ListA, ListB);               // add to dest from src and not in dest, remove from dest that are in src
  end;
end;

end.
