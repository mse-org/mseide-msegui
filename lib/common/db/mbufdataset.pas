{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team

    BufDataset implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
 
unit mbufdataset;
 
interface

uses
 db,classes,variants;
 
const
 nullmaskoffset = sizeof(pointer);
 
type
 tmbufdataset = class;
 
  TResolverErrorEvent = procedure(Sender: TObject; DataSet: tmbufdataset; E: EUpdateError;
    UpdateKind: TUpdateKind; var Response: TResolverResponse) of object;

// structure of internal recordbuffer:
//
// tbufreclinkitem, |blobinfoarty,fielddata  |
//                  |moved to tdataset buffer|
//                  |fieldoffsets are in ffieldbufpositions
//
  PBufRecLinkItem = ^TBufRecLinkItem;
  TBufRecLinkItem = record
    prior   : PBufRecLinkItem;
    next    : PBufRecLinkItem;
  end;

  PBufBookmark = ^TBufBookmark;
  TBufBookmark = record
    BookmarkData : PBufRecLinkItem;
    BookmarkFlag : TBookmarkFlag;
  end;

  PRecUpdateBuffer = ^TRecUpdateBuffer;
  TRecUpdateBuffer = record
    UpdateKind         : TUpdateKind;
    BookmarkData       : pointer;
    OldValuesBuffer    : pchar;
  end;

  TRecordsUpdateBuffer = array of TRecUpdateBuffer;
 
 blobinfoty = record
  field: tfield;
  data: pointer;
  datalength: integer;
  new: boolean;
 end;
 pblobinfoty = ^blobinfoty;
 blobinfoarty = array of blobinfoty;
 pblobinfoarty = ^blobinfoarty;
 
 tblobbuffer = class(tmemorystream)
  private
   fowner: tmbufdataset;
   ffield: tfield;
  public
   constructor create(const aowner: tmbufdataset; const afield: tfield);
   destructor destroy; override;
 end;

 tblobcopy = class(tmemorystream)
  public
   constructor create(const ablob: blobinfoty);
   destructor destroy; override;
 end;
   
 tmbufdataset = class(TDBDataSet)
  private
    FCurrentRecBuf  : PBufRecLinkItem;
    FLastRecBuf     : PBufRecLinkItem;
    FFirstRecBuf    : PBufRecLinkItem;
    FBRecordCount   : integer;

    FPacketRecords  : integer;
    FRecordSize     : Integer;
    FNullmaskSize   : byte;
    FOpen           : Boolean;
    FUpdateBuffer   : TRecordsUpdateBuffer;
    FCurrentUpdateBuffer : integer;

    FFieldBufPositions : array of longint;
    
    FAllPacketsFetched : boolean;
    FOnUpdateError  : TResolverErrorEvent;
    
    procedure CalcRecordSize;
    function LoadBuffer(Buffer : PChar): TGetResult;
    function GetFieldSize(FieldDef : TFieldDef) : longint;
    function GetRecordUpdateBuffer : boolean;
    procedure SetPacketRecords(aValue : integer);
    function  IntAllocRecordBuffer: PChar;    
    procedure intfreerecordbuffer(var buffer: pchar);
    
  protected
   fapplyindex: integer; //take care about canceled updates while applying
   ffailedcount: integer;
   
   function getblobpo: pblobinfoarty;   //in tdataset buffer
   function getintblobpo: pblobinfoarty;//in currentrecbuf
   procedure internalcancel; override;
   procedure cancelrecupdate(var arec: trecupdatebuffer);
   procedure setdatastringvalue(const afield: tfield; const avalue: string);
   
   function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
   procedure internalapplyupdate(const maxerrors: integer;
                const cancelonerror: boolean; 
                var arec: trecupdatebuffer; var response: tresolverresponse);
   procedure internalApplyUpdates(const MaxErrors: Integer;
                                       const cancelonerror: boolean);
    procedure freeblob(const ablob: blobinfoty);
    procedure freeblobs(var ablobs: blobinfoarty);
    procedure deleteblob(var ablobs: blobinfoarty; const aindex: integer); overload;
    procedure deleteblob(var ablobs: blobinfoarty; const afield: tfield); overload;
    procedure addblob(const ablob: tblobbuffer);
    
    procedure SetRecNo(Value: Longint); override;
    function  GetRecNo: Longint; override;
    function GetChangeCount: integer; virtual;
    function  AllocRecordBuffer: PChar; override;
    procedure ClearCalcFields(Buffer: PChar); override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure InternalInitRecord(Buffer: PChar); override;
    function  GetCanModify: Boolean; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode;
                                    DoCheck: Boolean): TGetResult; override;
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function getnextpacket : integer;
    function GetRecordSize: Word; override;
    procedure InternalPost; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function GetFieldData(Field: TField; Buffer: Pointer;
      NativeFormat: Boolean): Boolean; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer;
      NativeFormat: Boolean); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    function IsCursorOpen: Boolean; override;
    function  GetRecordCount: Longint; override;
    procedure ApplyRecUpdate(UpdateKind : TUpdateKind); virtual;
    procedure SetOnUpdateError(const aValue: TResolverErrorEvent);
  {abstracts, must be overidden by descendents}
    function Fetch : boolean; virtual; abstract;
    function LoadField(FieldDef : TFieldDef;buffer : pointer) : boolean; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function createblobbuffer(const afield: tfield): tblobbuffer;
    procedure ApplyUpdates; virtual; overload;
    procedure ApplyUpdates(MaxErrors: Integer); virtual; overload;
    procedure CancelUpdates; virtual;
    function Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean; override;
    function UpdateStatus: TUpdateStatus; override;
    property ChangeCount : Integer read GetChangeCount;
  published
    property PacketRecords : Integer read FPacketRecords write FPacketRecords default 10;
    property OnUpdateError: TResolverErrorEvent read FOnUpdateError write SetOnUpdateError;
  end;

const
 intbloboffset = sizeof(tbufreclinkitem);
   
implementation
uses
 dbconst,msedatalist;

procedure unSetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) and not (1 shl (x mod 8));
end;

procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
end;

function GetFieldIsNull(NullMask : pbyte;x : longint) : boolean; //inline;
begin
  result := ord(NullMask[x div 8]) and (1 shl (x mod 8)) > 0
end;


{ tblobbuffer }

constructor tblobbuffer.create(const aowner: tmbufdataset; const afield: tfield);
begin
 fowner:= aowner;
 ffield:= afield;
 inherited create;
end;

destructor tblobbuffer.destroy;
begin
 fowner.addblob(self);
 setpointer(nil,0);
 inherited;
end;

{ tblobcopy }

constructor tblobcopy.create(const ablob: blobinfoty);
begin
 inherited create;
 setpointer(ablob.data,ablob.datalength);
end;

destructor tblobcopy.destroy;
begin
 setpointer(nil,0);
 inherited;
end;

{ tmbufdataset }

constructor tmbufdataset.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  SetLength(FUpdateBuffer,0);
  BookmarkSize := sizeof(TBufBookmark);
  FPacketRecords := 10;
end;

procedure tmbufdataset.SetPacketRecords(aValue : integer);
begin
  if (aValue = -1) or (aValue > 0) then FPacketRecords := aValue
    else DatabaseError(SInvPacketRecordsValue);
end;

destructor tmbufdataset.Destroy;
begin
  inherited destroy;
end;

Function tmbufdataset.GetCanModify: Boolean;
begin
  Result:= False;
end;

function tmbufdataset.intAllocRecordBuffer: PChar;
begin
  // Note: Only the internal buffers of TDataset provide bookmark information
  result := AllocMem(FRecordsize+sizeof(TBufRecLinkItem));
  ppointer(result+intbloboffset)^:= nil; //blobbuffer
end;

procedure tmbufdataset.intFreeRecordBuffer(var Buffer: PChar);
begin
 if buffer <> nil then begin
  freeblobs(pblobinfoarty(buffer+sizeof(tbufreclinkitem))^);
  ReAllocMem(Buffer,0);
 end;
end;

function tmbufdataset.AllocRecordBuffer: PChar;
begin
 result := AllocMem(FRecordsize + sizeof(TBufBookmark) + calcfieldssize);
 initrecord(result);
end;

procedure tmbufdataset.ClearCalcFields(Buffer: PChar);
begin
 fillchar((buffer+FRecordsize + sizeof(TBufBookmark))^,calcfieldssize,0);
end;

procedure tmbufdataset.FreeRecordBuffer(var Buffer: PChar);
var
 int1: integer;
 bo1: boolean;
begin
 if buffer <> nil then begin
  bo1:= false;
  for int1:= high(pblobinfoarty(buffer)^) downto 0 do begin
   if pblobinfoarty(buffer)^[int1].new then begin
    freeblob(pblobinfoarty(buffer)^[int1]);
    bo1:= true;
   end;
  end;
  if bo1 then begin
   pblobinfoarty(buffer)^:= nil;
  end;
  ReAllocMem(Buffer,0);
 end;
end;

function tmbufdataset.getblobpo: pblobinfoarty;
begin
 result:= pointer(activebuffer);
end;

function tmbufdataset.getintblobpo: pblobinfoarty;
begin
 result:= pointer(pchar(fcurrentrecbuf)+sizeof(tbufreclinkitem));
end;

procedure tmbufdataset.freeblob(const ablob: blobinfoty);
begin
 with ablob do begin
  if datalength > 0 then begin
   freemem(data);
  end;
 end;
end;

function tmbufdataset.createblobbuffer(const afield: tfield): tblobbuffer;
begin
 result:= tblobbuffer.create(self,afield);
end;

procedure tmbufdataset.addblob(const ablob: tblobbuffer);
var
 po1: pblobinfoarty;
 int1,int2: integer;
 bo1: boolean;
 po2: pointer;
begin
 po1:= getblobpo;
 bo1:= false;
 int2:= -1;
 for int1:= high(po1^) downto 0 do begin
  with po1^[int1] do begin
   if new then begin
    bo1:= true;
   end;
   if field = ablob.ffield then begin
    int2:= int1;
   end;
  end;
 end;
 if not bo1 then begin //copy needed
  po2:= pointer(po1^);
  pointer(po1^):= nil;
  po1^:= copy(blobinfoarty(po2));
 end;
 if int2 >= 0 then begin
  deleteblob(po1^,int2);
 end;
 setlength(po1^,high(po1^)+2);
 with po1^[high(po1^)],ablob do begin
  data:= memory;
  reallocmem(data,size);
  datalength:= size;
  field:= ffield;
  new:= true;
  if size = 0 then begin
   setfieldisnull(pbyte(po1)+nullmaskoffset,field.fieldno-1);
  end
  else begin
   unsetfieldisnull(pbyte(po1)+nullmaskoffset,field.fieldno-1);
  end;
  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then begin
   DataEvent(deFieldChange, Ptrint(Field));
  end;
 end;
end;

procedure tmbufdataset.freeblobs(var ablobs: blobinfoarty);
var
 int1: integer;
begin
 for int1:= 0 to high(ablobs) do begin
  freeblob(ablobs[int1]);
 end;
 ablobs:= nil;
end;

procedure tmbufdataset.deleteblob(var ablobs: blobinfoarty; const aindex: integer);
begin
 freeblob(ablobs[aindex]);
 deleteitem(ablobs,typeinfo(blobinfoarty),aindex); 
end;

procedure tmbufdataset.deleteblob(var ablobs: blobinfoarty; const afield: tfield);
var
 int1: integer;
begin
 for int1:= high(ablobs) downto 0 do begin
  if ablobs[int1].field = afield then begin
   freeblob(ablobs[int1]);
   deleteitem(ablobs,typeinfo(blobinfoarty),int1); 
   break;
  end;
 end;
end;

procedure tmbufdataset.InternalOpen;

begin
  CalcRecordSize;

  FBRecordcount := 0;

  FFirstRecBuf := pointer(IntAllocRecordBuffer);
  FLastRecBuf := FFirstRecBuf;
  FCurrentRecBuf := FLastRecBuf;

  FAllPacketsFetched := False;
  FOpen:=True;
end;

procedure tmbufdataset.InternalClose;

var pc : pchar;
    r  : integer;

begin
  FOpen:= False;
  FCurrentRecBuf := FFirstRecBuf;
  while assigned(FCurrentRecBuf) do begin
   pc := pointer(FCurrentRecBuf);
   FCurrentRecBuf := FCurrentRecBuf^.next;
   intFreeRecordBuffer(pc);
  end;

  for r := 0 to high(FUpdateBuffer) do begin
   with FUpdateBuffer[r] do begin
    if assigned(BookmarkData) then begin
     intFreeRecordBuffer(OldValuesBuffer);
    end;
   end;
  end;
  SetLength(FUpdateBuffer,0);

  FFirstRecBuf:= nil;
  SetLength(FFieldBufPositions,0);
  bindfields(false);
end;

procedure tmbufdataset.InternalFirst;
begin
// if FCurrentRecBuf = FLastRecBuf then the dataset is just opened and empty
// in which case InternalFirst should do nothing (bug 7211)
  if FCurrentRecBuf <> FLastRecBuf then
    FCurrentRecBuf := nil;
end;

procedure tmbufdataset.InternalLast;
begin
  repeat
  until (getnextpacket < FPacketRecords) or (FPacketRecords = -1);
  if FLastRecBuf <> FFirstRecBuf then
    FCurrentRecBuf := FLastRecBuf;
end;

function tmbufdataset.GetRecord(Buffer: PChar; GetMode: TGetMode;
                                            DoCheck: Boolean): TGetResult;

begin
  Result := grOK;
  case GetMode of
    gmPrior :
      if not assigned(PBufRecLinkItem(FCurrentRecBuf)^.prior) then
        begin
        Result := grBOF;
        end
      else
        begin
        FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.prior;
        end;
    gmCurrent :
      if FCurrentRecBuf = FLastRecBuf then
        Result := grError;
    gmNext :
      if FCurrentRecBuf = FLastRecBuf then // Dataset is empty (just opened)
        begin
        if getnextpacket = 0 then result := grEOF;
        end
      else if FCurrentRecBuf = nil then FCurrentRecBuf := FFirstRecBuf
      else if (PBufRecLinkItem(FCurrentRecBuf)^.next = FLastRecBuf) then
        begin
        if getnextpacket > 0 then
          begin
          FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.next;
          end
        else
          begin
          result:=grEOF;
          end
        end
      else
        begin
        FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.next;
        end;
  end;

  if Result = grOK then begin
   with PBufBookmark(Buffer + FRecordSize)^ do  begin
    BookmarkData := FCurrentRecBuf;
    BookmarkFlag := bfCurrent;
   end;
   move((pointer(FCurrentRecBuf)+sizeof(TBufRecLinkItem))^,buffer^,FRecordSize);
   getcalcfields(buffer);
  end
  else begin
   if (Result = grError) and doCheck then begin
    DatabaseError('No record');
   end;
  end;
end;

function tmbufdataset.GetRecordUpdateBuffer : boolean;

var x : integer;
    CurrBuff : PChar;

begin
  GetBookmarkData(ActiveBuffer,@CurrBuff);
  if (FCurrentUpdateBuffer >= length(FUpdateBuffer)) or (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData <> CurrBuff) then
   for x := 0 to high(FUpdateBuffer) do
    if FUpdateBuffer[x].BookmarkData = CurrBuff then
      begin
      FCurrentUpdateBuffer := x;
      break;
      end;
  Result := (FCurrentUpdateBuffer < length(FUpdateBuffer))  and (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData = CurrBuff);
end;

procedure tmbufdataset.InternalSetToRecord(Buffer: PChar);
begin
  FCurrentRecBuf := PBufBookmark(Buffer + FRecordSize)^.BookmarkData;
end;

procedure tmbufdataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PBufBookmark(Buffer + FRecordSize)^.BookmarkData := pointer(Data^);
end;

procedure tmbufdataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PBufBookmark(Buffer + FRecordSize)^.BookmarkFlag := Value;
end;

procedure tmbufdataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  pointer(Data^) := PBufBookmark(Buffer + FRecordSize)^.BookmarkData;
end;

function tmbufdataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PBufBookmark(Buffer + FRecordSize)^.BookmarkFlag;
end;

procedure tmbufdataset.InternalGotoBookmark(ABookmark: Pointer);
begin
  // note that ABookMark should be a PBufBookmark. But this way it can also be
  // a pointer to a TBufRecLinkItem
  FCurrentRecBuf := pointer(ABookmark^);
end;

function tmbufdataset.getnextpacket : integer;

var i : integer;
    pb : pchar;
    
begin
  if FAllPacketsFetched then
    begin
    result := 0;
    exit;
    end;
  i := 0;
  pb := pchar(pointer(FLastRecBuf)+sizeof(TBufRecLinkItem));
  while ((i < FPacketRecords) or (FPacketRecords = -1)) and (loadbuffer(pb) = grOk) do
    begin
    FLastRecBuf^.next := pointer(IntAllocRecordBuffer);
    FLastRecBuf^.next^.prior := FLastRecBuf;
    FLastRecBuf := FLastRecBuf^.next;
    pb := pchar(pointer(FLastRecBuf)+sizeof(TBufRecLinkItem));
    inc(i);
    end;
  FBRecordCount := FBRecordCount + i;
  result := i;
end;

function tmbufdataset.GetFieldSize(FieldDef : TFieldDef) : longint;

begin
  case FieldDef.DataType of
    ftString,
      ftFixedChar: result := FieldDef.Size + 1;
    ftSmallint,
      ftInteger,
      ftword     : result := sizeof(longint);
    ftBoolean    : result := sizeof(wordbool);
    ftBCD        : result := sizeof(currency);
    ftFloat      : result := sizeof(double);
    ftLargeInt   : result := sizeof(largeint);
    ftTime,
      ftDate,
      ftDateTime : result := sizeof(TDateTime);
    ftmemo,ftblob: result:= fielddef.size;
  else Result := 10
  end;

end;

function tmbufdataset.LoadBuffer(Buffer : PChar): TGetResult;

var NullMask     : pbyte;
    x            : longint;

begin
  if not Fetch then
    begin
    Result := grEOF;
    FAllPacketsFetched := True;
    Exit;
    end;
  ppointer(buffer)^:= nil; //blob buffer
  NullMask := pointer(buffer)+nullmaskoffset;
  fillchar(Nullmask^,FNullmaskSize,0);
  buffer:= pchar(nullmask+fnullmasksize);

  for x := 0 to FieldDefs.count-1 do
    begin
    if not LoadField(FieldDefs[x],buffer) then
      SetFieldIsNull(NullMask,x);
    inc(buffer,GetFieldSize(FieldDefs[x]));
    end;
  Result := grOK;
end;

function tmbufdataset.GetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean): Boolean;
begin
  Result := GetFieldData(Field, Buffer);
end;

function tmbufdataset.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var 
 CurrBuff : pchar;
begin
 Result := False;
 if state = dscalcfields then begin
  currbuff:= calcbuffer;
 end
 else begin
  CurrBuff := ActiveBuffer;
 end;
 If Field.Fieldno > 0 then begin 
       // If = 0, then calculated field or something similar
  if state = dsOldValue then begin
   if not GetRecordUpdateBuffer then begin
       // There is no old value available
    exit;
   end;
   currbuff := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer+
                           sizeof(TBufRecLinkItem);
  end
  else begin
   if not assigned(CurrBuff) then begin
    exit;
   end;
  end;
  if GetFieldIsnull(pbyte(CurrBuff+nullmaskoffset),Field.Fieldno-1) then begin
   exit;
  end;
  inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
  if assigned(buffer) then begin
   Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
  end;
  Result := True;
 end
 else begin //calc or lookup field
  if currbuff <> nil then begin
   currbuff:= currbuff + FRecordsize + sizeof(TBufBookmark) + field.offset;
   if (currbuff + field.datasize)^ <> #0 then begin
    result:= true;
    if buffer <> nil then begin
     move(currbuff^,buffer^,field.datasize);
    end;
   end;
  end;
 end;
end;

{
function tmbufdataset.GetFieldData(Field: TField; Buffer: Pointer): Boolean;

var CurrBuff : pchar;

begin
  Result := False;
  If Field.Fieldno > 0 then // If = 0, then calculated field or something similar
    begin
    if state = dsOldValue then
      begin
      if not GetRecordUpdateBuffer then
        begin
        // There is no old value available
        result := false;
        exit;
        end;
      currbuff := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer+sizeof(TBufRecLinkItem);
      end
    else
      begin
      CurrBuff := ActiveBuffer;
      if not assigned(CurrBuff) then
        begin
        result := false;
        exit;
        end;
      end;

    if GetFieldIsnull(pbyte(CurrBuff+nullmaskoffset),Field.Fieldno-1) then
      begin
      result := false;
      exit;
      end;

    inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
    if assigned(buffer) then Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
    Result := True;
    end;
end;
}
procedure tmbufdataset.SetFieldData(Field: TField; Buffer: Pointer);

var 
 CurrBuff : pointer;
 NullMask : pbyte;

begin
//  if not (state in [dsEdit, dsInsert, dsFilter]) then begin
 if not (state in dswritemodes) then begin
  DatabaseErrorFmt(SNotInEditState,[NAme],self);
  exit;
 end;
 if state = dscalcfields then begin
  currbuff:= calcbuffer;
 end
 else begin
  CurrBuff := ActiveBuffer;
 end;
 If Field.Fieldno > 0 then begin // If = 0, then calculated field or something
  if state = dsFilter then begin 
   // Set the value into the 'temporary' FLastRecBuf buffer for Locate and Lookup
     CurrBuff := pointer(FLastRecBuf) + sizeof(TBufRecLinkItem)
  end;
  NullMask := CurrBuff+nullmaskoffset;
  inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
  if assigned(buffer) then begin
   Move(Buffer^, CurrBuff^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
   unSetFieldIsNull(NullMask,Field.FieldNo-1);
  end
  else begin
   SetFieldIsNull(NullMask,Field.FieldNo-1);
  end;     
  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then begin
   DataEvent(deFieldChange, Ptrint(Field));
  end;
 end
 else begin //calc or lookup field
  currbuff:= currbuff + FRecordsize + sizeof(TBufBookmark) + field.offset;
  if buffer <> nil then begin
   pchar(currbuff+field.datasize)^:= #1;
   move(buffer^,currbuff^,field.datasize);
  end
  else begin
   pchar(currbuff+field.datasize)^:= #0;
  end;
 end;
end;

procedure tmbufdataset.SetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean);
begin
  SetFieldData(Field,Buffer);
end;
{
procedure tmbufdataset.SetFieldData(Field: TField; Buffer: Pointer);

var CurrBuff : pointer;
    NullMask : pbyte;

begin
  if not (state in [dsEdit, dsInsert, dsFilter]) then
    begin
    DatabaseErrorFmt(SNotInEditState,[NAme],self);
    exit;
    end;
  If Field.Fieldno > 0 then // If = 0, then calculated field or something
    begin
    if state = dsFilter then  // Set the value into the 'temporary' FLastRecBuf buffer for Locate and Lookup
      CurrBuff := pointer(FLastRecBuf) + sizeof(TBufRecLinkItem)
    else
      CurrBuff := ActiveBuffer;
    NullMask := CurrBuff+nullmaskoffset;

    inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
    if assigned(buffer) then
      begin
      Move(Buffer^, CurrBuff^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
      unSetFieldIsNull(NullMask,Field.FieldNo-1);
      end
    else
      SetFieldIsNull(NullMask,Field.FieldNo-1);
      
    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, Ptrint(Field));
    end;
end;
}
procedure tmbufdataset.InternalDelete;

begin
  GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

  if FCurrentRecBuf <> FFirstRecBuf then FCurrentRecBuf^.prior^.next := FCurrentRecBuf^.next
  else FFirstRecBuf := FCurrentRecBuf^.next;

  FCurrentRecBuf^.next^.prior :=  FCurrentRecBuf^.prior;

  if not GetRecordUpdateBuffer then
    begin
    FCurrentUpdateBuffer := length(FUpdateBuffer);
    SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);

    FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := pchar(FCurrentRecBuf);
    FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FCurrentRecBuf;

    FCurrentRecBuf := FCurrentRecBuf^.next;
    end
  else
    begin
    if FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind = ukModify then
      begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
      intFreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer;
      end
    else
      begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
      intFreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := nil;  //this 'disables' the updatebuffer
      end;
    end;

  dec(FBRecordCount);
  FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukDelete;
end;


procedure tmbufdataset.ApplyRecUpdate(UpdateKind : TUpdateKind);
begin
 raise EDatabaseError.Create(SApplyRecNotSupported);
end;

procedure tmbufdataset.CancelUpdates;
var
 r: Integer;
begin
 CheckBrowseMode;
 if high(FUpdateBuffer) >= 0 then begin
  r:= high(FUpdateBuffer);
  while r > -1 do begin
   with FUpdateBuffer[r] do begin
    if assigned(FUpdateBuffer[r].BookmarkData) then begin
     if UpdateKind = ukModify then begin
      freeblobs(pblobinfoarty(BookmarkData+intbloboffset)^);
      move(pchar(OldValuesBuffer+sizeof(TBufRecLinkItem))^,
              pchar(BookmarkData+sizeof(TBufRecLinkItem))^,FRecordSize);
      ppointer(BookmarkData+intbloboffset)^:= nil;
      intFreeRecordBuffer(OldValuesBuffer);
     end
     else begin
      if UpdateKind = ukDelete then begin
       if assigned(PBufRecLinkItem(BookmarkData)^.prior) then  begin
              // or else it was the first record
         PBufRecLinkItem(BookmarkData)^.prior^.next:= BookmarkData
       end
       else begin
        FFirstRecBuf := BookmarkData;
       end;
       PBufRecLinkItem(BookmarkData)^.next^.prior := BookmarkData;
       inc(FBRecordCount);
      end
      else begin
       if UpdateKind = ukInsert then begin
        if assigned(PBufRecLinkItem(BookmarkData)^.prior) then begin
                  // or else it was the first record
         PBufRecLinkItem(BookmarkData)^.prior^.next:= 
                                     PBufRecLinkItem(BookmarkData)^.next
        end
        else begin
         FFirstRecBuf := PBufRecLinkItem(BookmarkData)^.next;
        end;
        PBufRecLinkItem(BookmarkData)^.next^.prior:= 
                         PBufRecLinkItem(BookmarkData)^.prior;
                 // resync won't work if the currentbuffer is freed...
        if FCurrentRecBuf = BookmarkData then begin
         FCurrentRecBuf:= FCurrentRecBuf^.next;
        end;
        intFreeRecordBuffer(BookmarkData);
        dec(FBRecordCount);
       end;
      end;
     end;
     dec(r)
    end;
   end; 
   SetLength(FUpdateBuffer,0);
   Resync([]);
  end;
 end;
end;

procedure tmbufdataset.SetOnUpdateError(const AValue: TResolverErrorEvent);

begin
  FOnUpdateError := AValue;
end;

procedure tmbufdataset.cancelrecupdate(var arec: trecupdatebuffer);
begin
 with arec do begin
  if bookmarkdata <> nil then begin
   case updatekind of
    ukmodify: begin
     freeblobs(pblobinfoarty(BookmarkData+sizeof(TBufRecLinkItem))^);
     move(pchar(OldValuesBuffer+sizeof(TBufRecLinkItem))^,
            pchar(BookmarkData+sizeof(TBufRecLinkItem))^,FRecordSize);
     intFreeRecordBuffer(OldValuesBuffer);
    end;
    ukdelete: begin
     if assigned(PBufRecLinkItem(BookmarkData)^.prior) then  begin
              // or else it was the first record
      PBufRecLinkItem(BookmarkData)^.prior^.next:= BookmarkData
     end
     else begin
      FFirstRecBuf:= BookmarkData;
     end;
     PBufRecLinkItem(BookmarkData)^.next^.prior:= BookmarkData;
     inc(FBRecordCount);
    end;
    ukInsert: begin
     if assigned(PBufRecLinkItem(BookmarkData)^.prior) then begin
      // or else it was the first record
      PBufRecLinkItem(BookmarkData)^.prior^.next:= 
                           PBufRecLinkItem(BookmarkData)^.next;
     end
     else begin
      FFirstRecBuf := PBufRecLinkItem(BookmarkData)^.next;
     end;
     PBufRecLinkItem(BookmarkData)^.next^.prior:= 
                                   PBufRecLinkItem(BookmarkData)^.prior;
     // resync won't work if the currentbuffer is freed...
     if FCurrentRecBuf = BookmarkData then begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
     end;
     intFreeRecordBuffer(BookmarkData);
     dec(FBRecordCount);
    end;
   end;
  end;
 end;
end;

procedure tmbufdataset.internalapplyupdate(const maxerrors: integer;
               const cancelonerror: boolean;
               var arec: trecupdatebuffer; var response: tresolverresponse);
               
 procedure checkcancel;
 begin
  if cancelonerror then begin
   cancelrecupdate(arec);
   arec.bookmarkdata:= nil;
   resync([]);
  end;
 end;
 
var
 EUpdErr: EUpdateError;

begin
 with arec do begin
  Response:= rrApply;
  try
   ApplyRecUpdate(UpdateKind);
  except
   on E: EDatabaseError do begin
    Inc(fFailedCount);
    if longword(ffailedcount) > longword(MaxErrors) then begin
     Response:= rrAbort
    end
    else begin
     Response:= rrSkip;
    end;
    EUpdErr:= EUpdateError.Create(SOnUpdateError,E.Message,0,0,E);
    if assigned(OnUpdateError) then begin
     OnUpdateError(Self,Self,EUpdErr,UpdateKind,Response);
    end
    else begin
     if Response = rrAbort then begin
      checkcancel;
      Raise EUpdErr;
     end;
    end;
    eupderr.free;
   end
   else begin
    raise;
   end;
  end;
  if response = rrApply then begin
   intFreeRecordBuffer(OldValuesBuffer);
   BookmarkData := nil;
  end
  else begin
   checkcancel;
  end;
 end;
end;

procedure tmbufdataset.internalApplyUpdates(const MaxErrors: Integer; 
                                            const cancelonerror: boolean);

var
 SaveBookmark: pchar;
//    r            : Integer;
// FailedCount: integer;
// EUpdErr: EUpdateError;
 Response: TResolverResponse;
 StoreRecBuf: PBufRecLinkItem;

begin
 CheckBrowseMode;
 StoreRecBuf := FCurrentRecBuf;
 try
  fapplyindex := 0;
  fFailedCount := 0;
  Response := rrApply;
  while (fapplyindex <= high(FUpdateBuffer)) and (Response <> rrAbort) do begin
   with FUpdateBuffer[fapplyindex] do begin
    if assigned(BookmarkData) then begin
     InternalGotoBookmark(@BookmarkData);
     Resync([rmExact,rmCenter]);
     internalapplyupdate(maxerrors,cancelonerror,FUpdateBuffer[fapplyindex],response);
    end;
    inc(fapplyindex);
   end;
  end;
  if ffailedcount = 0 then begin
   SetLength(FUpdateBuffer,0);
  end;
 finally 
  if active then begin
   FCurrentRecBuf := StoreRecBuf;
   Resync([]);
  end;
 end;
end;

procedure tmbufdataset.ApplyUpdates; // For backwards-compatibility

begin
  ApplyUpdates(0);
end;

procedure tmbufdataset.ApplyUpdates(MaxErrors: Integer);
begin
 internalapplyupdates(maxerrors,false);
end;

{
procedure tmbufdataset.ApplyUpdates(MaxErrors: Integer);

var SaveBookmark : pchar;
    r            : Integer;
    FailedCount  : integer;
    EUpdErr      : EUpdateError;
    Response     : TResolverResponse;

begin
  CheckBrowseMode;

  // There is no bookmark available if the dataset is empty
  if not IsEmpty then
    GetBookmarkData(ActiveBuffer,@SaveBookmark);

  r := 0;
  FailedCount := 0;
  Response := rrApply;
  while (r < Length(FUpdateBuffer)) and (Response <> rrAbort) do
    begin
    if assigned(FUpdateBuffer[r].BookmarkData) then
      begin
      InternalGotoBookmark(@FUpdateBuffer[r].BookmarkData);
      Resync([rmExact,rmCenter]);
      Response := rrApply;
      try
        ApplyRecUpdate(FUpdateBuffer[r].UpdateKind);
      except
        on E: EDatabaseError do
          begin
          Inc(FailedCount);
          if failedcount > word(MaxErrors) then Response := rrAbort
          else Response := rrSkip;
          EUpdErr := EUpdateError.Create(SOnUpdateError,E.Message,0,0,E);
          if assigned(FOnUpdateError) then FOnUpdateError(Self,Self,EUpdErr,FUpdateBuffer[r].UpdateKind,Response)
          else if Response = rrAbort then Raise EUpdErr
          end
        else
          raise;
      end;
      if response = rrApply then
        begin
        intFreeRecordBuffer(FUpdateBuffer[r].OldValuesBuffer);
        FUpdateBuffer[r].BookmarkData := nil;
        end
      end;
    inc(r);
    end;
  if failedcount = 0 then
    SetLength(FUpdateBuffer,0);

  if not IsEmpty then
    begin
    InternalGotoBookMark(@SaveBookMark);
    Resync([rmExact,rmCenter]);
    end
  else
    InternalFirst;
end;
}
procedure tmbufdataset.InternalPost;
Var
 tmpRecBuffer: PBufRecLinkItem;
 CurrBuff: PChar;
 po1,po2: pblobinfoarty;
 po3: pointer;
 int1: integer;
 bo1: boolean;
begin
 po1:= getblobpo;
 bo1:= false;
 for int1:= high(po1^) downto 0 do begin
  if po1^[int1].new then begin
   po1^[int1].new:= false;
   bo1:= true;
  end;
 end;
 if state = dsInsert then begin
  if GetBookmarkFlag(ActiveBuffer) = bfEOF then begin
    // Append
    FCurrentRecBuf := FLastRecBuf
  end
  else begin
    // The active buffer is the newly created TDataset record,
    // from which the bookmark is set to the record where the new record should be
    // inserted
    GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);
  end;
  // Create the new record buffer
  tmpRecBuffer := FCurrentRecBuf^.prior;

  FCurrentRecBuf^.prior := pointer(IntAllocRecordBuffer);
  FCurrentRecBuf^.prior^.next := FCurrentRecBuf;
  FCurrentRecBuf := FCurrentRecBuf^.prior;
  if assigned(tmpRecBuffer) then begin
        // if not, it's the first record
   FCurrentRecBuf^.prior := tmpRecBuffer;
   tmpRecBuffer^.next := FCurrentRecBuf
  end
  else begin
   FFirstRecBuf := FCurrentRecBuf;
  end;
  // Link the newly created record buffer to the newly created TDataset record
  with PBufBookmark(ActiveBuffer + FRecordSize)^ do  begin
   BookmarkData := FCurrentRecBuf;
   BookmarkFlag := bfInserted;
  end;      
  inc(FBRecordCount);
 end
 else begin
  GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);
 end;
 if not GetRecordUpdateBuffer then begin
  FCurrentUpdateBuffer := length(FUpdateBuffer);
  SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);

  FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FCurrentRecBuf;

  if state = dsEdit then begin
          // Update the oldvalues-buffer
   FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := intAllocRecordBuffer;
   move(FCurrentRecBuf^,FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer^,
           FRecordSize+sizeof(TBufRecLinkItem));
   po1:= getintblobpo;
   if po1^ <> nil then begin
    po2:= pblobinfoarty(FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer+
                                intbloboffset);
    pointer(po2^):= nil;
    setlength(po2^,length(po1^));
    for int1:= high(po1^) downto 0 do begin
     po2^[int1]:= po1^[int1];
     with po2^[int1] do begin
      if datalength > 0 then begin
       po3:= getmem(datalength);
       move(data^,po3^,datalength);
       data:= po3;
      end
      else begin
       data:= nil;
      end;
     end;
    end;
   end;
   FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukModify;
  end
  else begin
   FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukInsert;
  end;
 end;
 CurrBuff := pchar(FCurrentRecBuf);
 inc(Currbuff,sizeof(TBufRecLinkItem));
 if bo1 then begin
  pblobinfoarty(currbuff)^:= nil; //free old array
 end;
 move(ActiveBuffer^,CurrBuff^,FRecordSize);
end;

procedure tmbufdataset.CalcRecordSize;
var 
 x: longint;
begin
 frecordsize:= sizeof(blobinfoarty);
 FNullmaskSize:= 1+((FieldDefs.count-1) div 8);
 inc(FRecordSize,FNullmaskSize);
 SetLength(FFieldBufPositions,FieldDefs.count);
 for x:= 0 to FieldDefs.count-1 do begin
  FFieldBufPositions[x]:= FRecordSize;
  inc(FRecordSize,GetFieldSize(FieldDefs[x]));
 end;
end;

function tmbufdataset.GetRecordSize : Word;

begin
  result := FRecordSize;
end;

function tmbufdataset.GetChangeCount: integer;

begin
  result := length(FUpdateBuffer);
end;


procedure tmbufdataset.InternalInitRecord(Buffer: PChar);

begin
 FillChar(Buffer^, FRecordSize, #0);
 fillchar((Buffer+nullmaskoffset)^,FNullmaskSize,255);
end;

procedure tmbufdataset.SetRecNo(Value: Longint);

var recnr        : integer;
    TmpRecBuffer : PBufRecLinkItem;

begin
  checkbrowsemode;
  if value > RecordCount then
    begin
    repeat until (getnextpacket < FPacketRecords) or (value <= RecordCount) or (FPacketRecords = -1);
    if value > RecordCount then
      begin
      DatabaseError(SNoSuchRecord,self);
      exit;
      end;
    end;
  TmpRecBuffer := FFirstRecBuf;
  for recnr := 1 to value-1 do
    TmpRecBuffer := TmpRecBuffer^.next;
  GotoBookmark(@TmpRecBuffer);
end;

function tmbufdataset.GetRecNo: Longint;

Var SearchRecBuffer : PBufRecLinkItem;
    TmpRecBuffer    : PBufRecLinkItem;
    recnr           : integer;
    abuf            : PChar;

begin
  abuf := ActiveBuffer;
  // If abuf isn't assigned, the recordset probably isn't opened.
  if assigned(abuf) and (FBRecordCount>0) and (state <> dsInsert) then
    begin
    GetBookmarkData(abuf,@SearchRecBuffer);
    TmpRecBuffer := FFirstRecBuf;
    recnr := 1;
    while TmpRecBuffer <> SearchRecBuffer do
      begin
      inc(recnr);
      TmpRecBuffer := TmpRecBuffer^.next;
      end;
    result := recnr;
    end
  else result := 0;
end;

function tmbufdataset.IsCursorOpen: Boolean;

begin
  Result := FOpen;
end;

Function tmbufdataset.GetRecordCount: Longint;

begin
  Result := FBRecordCount;
end;

Function tmbufdataset.UpdateStatus: TUpdateStatus;

begin
  Result:=usUnmodified;
  if GetRecordUpdateBuffer then
    case FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind of
      ukModify : Result := usModified;
      ukInsert : Result := usInserted;
      ukDelete : Result := usDeleted;
    end;
end;

Function tmbufdataset.Locate(const KeyFields: string; const KeyValues: Variant; options: TLocateOptions) : boolean;


  function CompareText0(substr, astr: pchar; len : integer; options: TLocateOptions): integer;

  var
    i : integer; Chr1, Chr2: byte;
  begin
    result := 0;
    i := 0;
    chr1 := 1;
    while (result=0) and (i<len) and (chr1 <> 0) do
      begin
      Chr1 := byte(substr[i]);
      Chr2 := byte(astr[i]);
      inc(i);
      if loCaseInsensitive in options then
        begin
        if Chr1 in [97..122] then
          dec(Chr1,32);
        if Chr2 in [97..122] then
          dec(Chr2,32);
        end;
      result := Chr1 - Chr2;
      end;
    if (result <> 0) and (chr1 = 0) and (loPartialKey in options) then result := 0;
  end;


var keyfield    : TField;     // Field to search in
    ValueBuffer : pchar;      // Pointer to value to search for, in TField' internal format
    VBLength    : integer;

    FieldBufPos : PtrInt;     // Amount to add to the record buffer to get the FieldBuffer
    CurrLinkItem: PBufRecLinkItem;
    CurrBuff    : pchar;
    bm          : TBufBookmark;

    CheckNull   : Boolean;
    SaveState   : TDataSetState;

begin
// For now it is only possible to search in one field at the same time
  result := False;

  if IsEmpty then exit;

  keyfield := FieldByName(keyfields);
  CheckNull := VarIsNull(KeyValues);

  if not CheckNull then
    begin
    SaveState := State;
    SetTempState(dsFilter);
    keyfield.Value := KeyValues;
    RestoreState(SaveState);

    FieldBufPos := FFieldBufPositions[keyfield.FieldNo-1];
    VBLength := keyfield.DataSize;
    ValueBuffer := AllocMem(VBLength);
    currbuff := pointer(FLastRecBuf)+sizeof(TBufRecLinkItem)+FieldBufPos;
    move(currbuff^,ValueBuffer^,VBLength);
    end;

  CurrLinkItem := FFirstRecBuf;

  if CheckNull then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      result := True;
      break;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else if keyfield.DataType = ftString then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareText0(ValueBuffer,CurrBuff,VBLength,options) = 0 then
        begin
        result := True;
        break;
        end;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareByte(ValueBuffer^,CurrBuff^,VBLength) = 0 then
        begin
        result := True;
        break;
        end;
      end;

    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end;


  if Result then
    begin
    bm.BookmarkData := CurrLinkItem;
    bm.BookmarkFlag := bfCurrent;
    GotoBookmark(@bm);
    end;

  ReAllocmem(ValueBuffer,0);
end;

procedure tmbufdataset.internalcancel;
var
 po1: pblobinfoarty;
 int1: integer;
begin
 po1:= getblobpo;
 for int1:= high(po1^) downto 0 do begin
  if po1^[int1].new then begin
   deleteblob(po1^,int1);
  end;
 end;
end;

function tmbufdataset.CreateBlobStream(Field: TField;
               Mode: TBlobStreamMode): TStream;
var
 po1: pblobinfoarty;
 int1: integer;
begin
 if (mode <> bmread) and not (state in dseditmodes) then begin
  DatabaseErrorFmt(SNotInEditState,[NAme],self);
 end;  
 result:= nil;
 if mode = bmread then begin
  po1:= getblobpo;
  for int1:= high(po1^) downto 0 do begin
   if po1^[int1].field = field then begin
    result:= tblobcopy.create(po1^[int1]);
    break;
   end;
  end;
 end;
end;

procedure tmbufdataset.setdatastringvalue(const afield: tfield; const avalue: string);
var
 po1: pbyte;
 int1: integer;
begin
 po1:= pbyte(fcurrentrecbuf)+sizeof(tbufreclinkitem);
 int1:= afield.fieldno - 1;
 if avalue <> '' then begin
  move(avalue[1],(po1+ffieldbufpositions[int1])^,length(avalue));
  unsetfieldisnull(po1+nullmaskoffset,int1);
 end
 else begin
  setfieldisnull(po1+nullmaskoffset,int1);
 end;
end;

end.
