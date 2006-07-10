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
{ ---------------------------------------------------------------------
    TBufDataSet
  ---------------------------------------------------------------------}

constructor TBufDataset.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  SetLength(FUpdateBuffer,0);
  BookmarkSize := sizeof(TBufBookmark);
  FPacketRecords := 10;
end;

procedure TBufDataset.SetPacketRecords(aValue : integer);
begin
  if (aValue = -1) or (aValue > 0) then FPacketRecords := aValue
    else DatabaseError(SInvPacketRecordsValue);
end;

destructor TBufDataset.Destroy;
begin
  inherited destroy;
end;

Function TBufDataset.GetCanModify: Boolean;
begin
  Result:= False;
end;

function TBufDataset.intAllocRecordBuffer: PChar;
begin
  // Note: Only the internal buffers of TDataset provide bookmark information
  result := AllocMem(FRecordsize+sizeof(TBufRecLinkItem));
end;

function TBufDataset.AllocRecordBuffer: PChar;
begin
  result := AllocMem(FRecordsize + sizeof(TBufBookmark));
end;

procedure TBufDataset.FreeRecordBuffer(var Buffer: PChar);
begin
  ReAllocMem(Buffer,0);
end;

procedure TBufDataset.InternalOpen;

begin
  CalcRecordSize;

  FBRecordcount := 0;

  FFirstRecBuf := pointer(IntAllocRecordBuffer);
  FLastRecBuf := FFirstRecBuf;
  FCurrentRecBuf := FLastRecBuf;

  FAllPacketsFetched := False;
  FOpen:=True;
end;

procedure TBufDataset.InternalClose;

var pc : pchar;

begin
 if fopen then begin
  FOpen:=False;
  FCurrentRecBuf := FFirstRecBuf;
  SetLength(FUpdateBuffer,0);
  while assigned(FCurrentRecBuf) do
    begin
    pc := pointer(FCurrentRecBuf);
    FCurrentRecBuf := FCurrentRecBuf^.next;
    FreeRecordBuffer(pc);
    end;
  SetLength(FFieldBufPositions,0);
 end;
end;

procedure TBufDataset.InternalFirst;
begin
  FCurrentRecBuf := nil;
end;

procedure TBufDataset.InternalLast;
begin
  repeat
  until (getnextpacket < FPacketRecords) or (FPacketRecords = -1);
  if FLastRecBuf <> FFirstRecBuf then
    FCurrentRecBuf := FLastRecBuf;
end;

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

function TBufDataset.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;

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

  if Result = grOK then
    begin

    with PBufBookmark(Buffer + RecordSize)^ do
      begin
      BookmarkData := FCurrentRecBuf;
      BookmarkFlag := bfCurrent;
      end;
    move((pointer(FCurrentRecBuf)+sizeof(TBufRecLinkItem))^,buffer^,RecordSize);
    end
  else if (Result = grError) and doCheck then
    DatabaseError('No record');
end;

function TBufDataset.GetRecordUpdateBuffer : boolean;

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

procedure TBufDataset.InternalSetToRecord(Buffer: PChar);
begin
  FCurrentRecBuf := PBufBookmark(Buffer + RecordSize)^.BookmarkData;
end;

procedure TBufDataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PBufBookmark(Buffer + RecordSize)^.BookmarkData := pointer(Data^);
end;

procedure TBufDataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PBufBookmark(Buffer + RecordSize)^.BookmarkFlag := Value;
end;

procedure TBufDataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  pointer(Data^) := PBufBookmark(Buffer + RecordSize)^.BookmarkData;
end;

function TBufDataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PBufBookmark(Buffer + RecordSize)^.BookmarkFlag;
end;

procedure TBufDataset.InternalGotoBookmark(ABookmark: Pointer);
begin
  // note that ABookMark should be a PBufBookmark. But this way it can also be
  // a pointer to a TBufRecLinkItem
  FCurrentRecBuf := pointer(ABookmark^);
end;

function TBufDataset.getnextpacket : integer;

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

function TBufDataset.GetFieldSize(FieldDef : TFieldDef) : longint;

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
      ftDateTime : result := sizeof(TDateTime)
  else Result := 10
  end;

end;

function TBufDataset.LoadBuffer(Buffer : PChar): TGetResult;

var NullMask     : pbyte;
    x            : longint;

begin
  if not Fetch then
    begin
    Result := grEOF;
    FAllPacketsFetched := True;
    Exit;
    end;

  NullMask := pointer(buffer);
  fillchar(Nullmask^,FNullmaskSize,0);
  inc(buffer,FNullmaskSize);

  for x := 0 to FieldDefs.count-1 do
    begin
    if not LoadField(FieldDefs[x],buffer) then
      SetFieldIsNull(NullMask,x);
    inc(buffer,GetFieldSize(FieldDefs[x]));
    end;
  Result := grOK;
end;

function TBufDataset.GetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean): Boolean;
begin
  Result := GetFieldData(Field, Buffer);
end;

function TBufDataset.GetFieldData(Field: TField; Buffer: Pointer): Boolean;

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

    if GetFieldIsnull(pbyte(CurrBuff),Field.Fieldno-1) then
      begin
      result := false;
      exit;
      end;

    inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
    if assigned(buffer) then Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
    Result := True;
    end;
end;

procedure TBufDataset.SetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean);
begin
  SetFieldData(Field,Buffer);
end;

procedure TBufDataset.SetFieldData(Field: TField; Buffer: Pointer);

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
    NullMask := CurrBuff;

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

procedure TBufDataset.InternalDelete;

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
      FreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer;
      end
    else
      begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
      FreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := nil;  //this 'disables' the updatebuffer
      end;
    end;

  dec(FBRecordCount);
  FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukDelete;
end;


procedure TBufDataset.ApplyRecUpdate(UpdateKind : TUpdateKind);

begin
  raise EDatabaseError.Create(SApplyRecNotSupported);
end;

procedure TBufDataset.CancelUpdates;

var r              : Integer;

begin
  CheckBrowseMode;

  if Length(FUpdateBuffer) > 0 then
    begin
    r := Length(FUpdateBuffer) -1;
    while r > -1 do with FUpdateBuffer[r] do
      begin
      if assigned(FUpdateBuffer[r].BookmarkData) then
        begin
        if UpdateKind = ukModify then
          begin
          move(pchar(OldValuesBuffer+sizeof(TBufRecLinkItem))^,pchar(BookmarkData+sizeof(TBufRecLinkItem))^,RecordSize);
          FreeRecordBuffer(OldValuesBuffer);
          end
        else if UpdateKind = ukDelete then
          begin
          if assigned(PBufRecLinkItem(BookmarkData)^.prior) then  // or else it was the first record
            PBufRecLinkItem(BookmarkData)^.prior^.next := BookmarkData
          else
            FFirstRecBuf := BookmarkData;
          PBufRecLinkItem(BookmarkData)^.next^.prior := BookmarkData;
          inc(FBRecordCount);
          end
        else if UpdateKind = ukInsert then
          begin
          if assigned(PBufRecLinkItem(BookmarkData)^.prior) then // or else it was the first record
            PBufRecLinkItem(BookmarkData)^.prior^.next := PBufRecLinkItem(BookmarkData)^.next
          else
            FFirstRecBuf := PBufRecLinkItem(BookmarkData)^.next;
          PBufRecLinkItem(BookmarkData)^.next^.prior := PBufRecLinkItem(BookmarkData)^.prior;
          // resync won't work if the currentbuffer is freed...
          if FCurrentRecBuf = BookmarkData then FCurrentRecBuf := FCurrentRecBuf^.next;
          FreeRecordBuffer(BookmarkData);
          dec(FBRecordCount);
          end;
        end;
      dec(r)
      end;

    SetLength(FUpdateBuffer,0);
    Resync([]);
    end;
end;

procedure TBufDataset.SetOnUpdateError(const AValue: TResolverErrorEvent);

begin
  FOnUpdateError := AValue;
end;

procedure TBufDataset.ApplyUpdates; // For backwards-compatibility

begin
  ApplyUpdates(0);
end;

procedure TBufDataset.ApplyUpdates(MaxErrors: Integer);

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
        FreeRecordBuffer(FUpdateBuffer[r].OldValuesBuffer);
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

procedure TBufDataset.InternalPost;

Var tmpRecBuffer : PBufRecLinkItem;
    CurrBuff     : PChar;

begin
  if state = dsInsert then
    begin
    if GetBookmarkFlag(ActiveBuffer) = bfEOF then
      // Append
      FCurrentRecBuf := FLastRecBuf
    else
      // The active buffer is the newly created TDataset record,
      // from which the bookmark is set to the record where the new record should be
      // inserted
      GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

    // Create the new record buffer
    tmpRecBuffer := FCurrentRecBuf^.prior;

    FCurrentRecBuf^.prior := pointer(IntAllocRecordBuffer);
    FCurrentRecBuf^.prior^.next := FCurrentRecBuf;
    FCurrentRecBuf := FCurrentRecBuf^.prior;
    If assigned(tmpRecBuffer) then // if not, it's the first record
      begin
      FCurrentRecBuf^.prior := tmpRecBuffer;
      tmpRecBuffer^.next := FCurrentRecBuf
      end
    else
      FFirstRecBuf := FCurrentRecBuf;

    // Link the newly created record buffer to the newly created TDataset record
    with PBufBookmark(ActiveBuffer + RecordSize)^ do
      begin
      BookmarkData := FCurrentRecBuf;
      BookmarkFlag := bfInserted;
      end;
      
    inc(FBRecordCount);
    end
  else
    GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

  if not GetRecordUpdateBuffer then
    begin
    FCurrentUpdateBuffer := length(FUpdateBuffer);
    SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);

    FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FCurrentRecBuf;

    if state = dsEdit then
      begin
      // Update the oldvalues-buffer
      FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := intAllocRecordBuffer;
      move(FCurrentRecBuf^,FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer^,RecordSize+sizeof(TBufRecLinkItem));
      FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukModify;
      end
    else
      FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukInsert;
    end;

  CurrBuff := pchar(FCurrentRecBuf);
  inc(Currbuff,sizeof(TBufRecLinkItem));
  move(ActiveBuffer^,CurrBuff^,RecordSize);
end;

procedure TBufDataset.CalcRecordSize;

var x : longint;

begin
  FNullmaskSize := 1+((FieldDefs.count-1) div 8);
  FRecordSize := FNullmaskSize;
  SetLength(FFieldBufPositions,FieldDefs.count);
  for x := 0 to FieldDefs.count-1 do
    begin
    FFieldBufPositions[x] := FRecordSize;
    inc(FRecordSize, GetFieldSize(FieldDefs[x]));
    end;
end;

function TBufDataset.GetRecordSize : Word;

begin
  result := FRecordSize;
end;

function TBufDataset.GetChangeCount: integer;

begin
  result := length(FUpdateBuffer);
end;


procedure TBufDataset.InternalInitRecord(Buffer: PChar);

begin
  FillChar(Buffer^, FRecordSize, #0);

  fillchar(Buffer^,FNullmaskSize,255);
end;

procedure TBufDataset.SetRecNo(Value: Longint);

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

function TBufDataset.GetRecNo: Longint;

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

function TBufDataset.IsCursorOpen: Boolean;

begin
  Result := FOpen;
end;

Function TBufDataset.GetRecordCount: Longint;

begin
  Result := FBRecordCount;
end;

Function TBufDataSet.UpdateStatus: TUpdateStatus;

begin
  Result:=usUnmodified;
  if GetRecordUpdateBuffer then
    case FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind of
      ukModify : Result := usModified;
      ukInsert : Result := usInserted;
      ukDelete : Result := usDeleted;
    end;
end;

Function TBufDataset.Locate(const KeyFields: string; const KeyValues: Variant; options: TLocateOptions) : boolean;


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

