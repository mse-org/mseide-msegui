{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt, member of the
    Free Pascal development team

    TFields and related components implementations.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 Modified 2013 by Martin Schreiber

 **********************************************************************}
{Procedure DumpMem (P : Pointer;Size : Longint);

Var i : longint;

begin
  Write ('Memory dump : ');
  For I:=0 to Size-1 do
    Write (Pbyte(P)[i],' ');
  Writeln;
end;}

{ ---------------------------------------------------------------------
    TFieldDef
  ---------------------------------------------------------------------}

Constructor TFieldDef.Create(ACollection : TCollection);

begin
  Inherited create(ACollection);
  FFieldNo:=Index+1;
end;

Constructor TFieldDef.Create(AOwner: TFieldDefs; const AName: string;
      ADataType: TFieldType; ASize: Integer; ARequired: Boolean; AFieldNo: Longint);

begin
{$ifdef dsdebug }
  Writeln('TFieldDef.Create : ',Aname,'(',AFieldNo,')');
{$endif}
  Inherited Create(AOwner);
  Name:=Aname;
  FDatatype:=ADatatype;
  FSize:=ASize;
  FRequired:=ARequired;
  FPrecision:=-1;
  FFieldNo:=AFieldNo;
end;

Destructor TFieldDef.Destroy;

begin
  Inherited destroy;
end;

procedure TFieldDef.Assign(APersistent: TPersistent);
var fd: TFieldDef;
begin
  fd := nil;
  if APersistent is TFieldDef then
    fd := APersistent as TFieldDef;
  if Assigned(fd) then begin
    Collection.BeginUpdate;
    try
      Name := fd.Name;
      DataType := fd.DataType;
      Size := fd.Size;
      Precision := fd.Precision;
      FRequired := fd.Required;
    finally
      Collection.EndUpdate;
    end;
  end else
  inherited Assign(APersistent);
end;

Function TFieldDef.CreateField(AOwner: TComponent): TField;

Var TheField : TFieldClass;

begin
{$ifdef dsdebug}
  Writeln ('Creating field '+FNAME);
{$endif dsdebug}
  TheField:=GetFieldClass;
  if TheField=Nil then
    DatabaseErrorFmt(SUnknownFieldType,[FName]);
  Result:=Thefield.Create(AOwner);
  Try
    Result.Size:=FSize;
    Result.Required:=FRequired;
    Result.FFieldName:=FName;
    Result.FDisplayLabel:=DisplayName;
    Result.FFieldNo:=Self.FieldNo;
    Result.SetFieldType(DataType);
    Result.FReadOnly:= (faReadOnly in Attributes);
{$ifdef dsdebug}
    Writeln ('TFieldDef.CReateField : Trying to set dataset');
{$endif dsdebug}
{$ifdef dsdebug}
    Writeln ('TFieldDef.CReateField : Result Fieldno : ',Result.FieldNo,' Self : ',FieldNo);
{$endif dsdebug}
    Result.Dataset:=TFieldDefs(Collection).Dataset;
    If (Result is TFloatField) then
      TFloatField(Result).Precision:=FPrecision;
    if (Result is TBCDField) then
      TBCDField(Result).Precision:=FPrecision;
    if (Result is TFmtBCDField) then
      TFmtBCDField(Result).Precision:=FPrecision;
  except
    Result.Free;
    Raise;
  end;

end;

procedure TFieldDef.SetAttributes(AValue: TFieldAttributes);
begin
  FAttributes := AValue;
  Changed(False);
end;

procedure TFieldDef.SetDataType(AValue: TFieldType);
begin
  FDataType := AValue;
  Changed(False);
end;

procedure TFieldDef.SetPrecision(const AValue: Longint);
begin
  FPrecision := AValue;
  Changed(False);
end;

procedure TFieldDef.SetSize(const AValue: Integer);
begin
  FSize := AValue;
  Changed(False);
end;

procedure TFieldDef.SetRequired(const AValue: Boolean);
begin
  FRequired := AValue;
  Changed(False);
end;

Function TFieldDef.GetFieldClass : TFieldClass;

begin
  //!! Should be owner as tdataset but that doesn't work ??

  If Assigned(Collection) And
     (Collection is TFieldDefs) And
     Assigned(TFieldDefs(Collection).Dataset) then
    Result:=TFieldDefs(Collection).Dataset.GetFieldClass(FDataType)
  else
    Result:=Nil;
end;

{ ---------------------------------------------------------------------
    TFieldDefs
  ---------------------------------------------------------------------}

{
destructor TFieldDefs.Destroy;

begin
  FItems.Free;
  // This will destroy all fielddefs since we own them...
  Inherited Destroy;
end;
}

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType);

begin
  Add(AName,ADatatype,0,False);
end;

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType; ASize : Word);

begin
  Add(AName,ADatatype,ASize,False);
end;

procedure TFieldDefs.Add(const AName: string; ADataType: TFieldType; ASize: Word;
  ARequired: Boolean);

begin
  If Length(AName)=0 Then
    DatabaseError(SNeedFieldName);
  // the fielddef will register itself here as a owned component.
  // fieldno is 1 based !
  BeginUpdate;
  try
    TFieldDef.Create(Self,AName,ADataType,ASize,Arequired,Count+1);
  finally
    EndUpdate;
  end;
end;

function TFieldDefs.GetItem(Index: Longint): TFieldDef;

begin
  Result := TFieldDef(inherited Items[Index]);
end;

procedure TFieldDefs.SetItem(Index: Longint; const AValue: TFieldDef);
begin
  inherited Items[Index] := AValue;
end;

constructor TFieldDefs.Create(ADataset: TDataset);
begin
  Inherited Create(ADataset, Owner, TFieldDef);
end;

procedure TFieldDefs.Assign(FieldDefs: TFieldDefs);

Var I : longint;

begin
  Clear;
  For i:=0 to FieldDefs.Count-1 do
    With FieldDefs[i] do
      Add(Name,DataType,Size,Required);
end;

function TFieldDefs.Find(const AName: string): TFieldDef;
begin
  Result := (Inherited Find(AName)) as TFieldDef;
  if Result=nil then DatabaseErrorFmt(SFieldNotFound,[AName],FDataset);
end;

{
procedure TFieldDefs.Clear;

Var I : longint;

begin
  For I:=FItems.Count-1 downto 0 do
    TFieldDef(Fitems[i]).Free;
  FItems.Clear;
end;
}

procedure TFieldDefs.Update;

begin
  if not Updated then
    begin
    If Assigned(Dataset) then
      DataSet.InitFieldDefs;
    Updated := True;
    end;
end;

function TFieldDefs.MakeNameUnique(const AName: String): string;
var DblFieldCount : integer;
begin
  DblFieldCount := 0;
  Result := AName;
  while assigned(inherited Find(Result)) do
    begin
    inc(DblFieldCount);
    Result := AName + '_' + IntToStr(DblFieldCount);
    end;
end;

Function TFieldDefs.AddFieldDef : TFieldDef;

begin
  Result:=TFieldDef.Create(Self,'',ftUnknown,0,False,Count+1);
end;

{ ---------------------------------------------------------------------
    TField
  ---------------------------------------------------------------------}

Const
  SBCD = 'BCD';
  SBoolean = 'Boolean';
  SDateTime = 'TDateTime';
  SFloat = 'Float';
  SInteger = 'Integer';
  SLargeInt = 'LargeInt';
  SVariant = 'Variant';
  SString = 'String';
  SBytes = 'Bytes';

constructor TField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FVisible:=True;
  FValidChars:=[#0..#255];

  FProviderFlags := [pfInUpdate,pfInWhere];
end;

destructor TField.Destroy;

begin
  IF Assigned(FDataSet) then
    begin
    FDataSet.Active:=False;
    if Assigned(FFields) then
      FFields.Remove(Self);
    end;
  FLookupList.Free;
  Inherited Destroy;
end;

function TField.AccessError(const TypeName: string): EDatabaseError;

begin
  Result:=EDatabaseError.CreateFmt(SinvalidTypeConversion,[TypeName,FFieldName]);
end;

procedure TField.Assign(Source: TPersistent);

begin
  if Source = nil then Clear
  else if Source is TField then begin
    Value := TField(Source).Value;
  end else
    inherited Assign(Source);
end;

procedure TField.AssignValue(const AValue: TVarRec);
  procedure Error;
  begin
    DatabaseErrorFmt(SFieldValueError, [DisplayName]);
  end;

begin
  with AValue do
    case VType of
      vtInteger:
        AsInteger := VInteger;
      vtBoolean:
        AsBoolean := VBoolean;
      vtChar:
        AsString := VChar;
      vtExtended:
        AsFloat := VExtended^;
      vtString:
        AsString := VString^;
      vtPointer:
        if VPointer <> nil then Error;
      vtPChar:
        AsString := VPChar;
      vtObject:
        if (VObject = nil) or (VObject is TPersistent) then
          Assign(TPersistent(VObject))
        else
          Error;
      vtAnsiString:
        AsString := string(VAnsiString);
      vtCurrency:
        AsCurrency := VCurrency^;
      vtVariant:
        if not VarIsClear(VVariant^) then Self.Value := VVariant^;
      vtWideString:
        AsWideString := WideString(VWideString);
      vtInt64:
        AsLargeInt := VInt64^;
    else
      Error;
    end;
end;

procedure TField.Change;

begin
  If Assigned(FOnChange) Then
    FOnChange(Self);
end;

procedure TField.CheckInactive;

begin
  If Assigned(FDataSet) then
    FDataset.CheckInactive;
end;

procedure TField.Clear;

begin
  if FieldKind in [fkData, fkInternalCalc] then
    SetData(Nil);
end;

procedure TField.DataChanged;

begin
  FDataset.DataEvent(deFieldChange,ptrint(Self));
end;

procedure TField.FocusControl;
var
  Field1: TField;
begin
  Field1 := Self;
  FDataSet.DataEvent(deFocusControl,ptrint(@Field1));
end;

procedure TField.FreeBuffers;

begin
  // Empty. Provided for backward compatibiliy;
  // TDataset manages the buffers.
end;

function TField.GetAsBCD: TBCD;
begin
  raise AccessError(SBCD);
end;

function TField.GetAsBoolean: Boolean;
begin
  raise AccessError(SBoolean);
end;

function TField.GetAsBytes: TBytes;
begin
  SetLength(Result, DataSize);
  if assigned(result) and not GetData(@Result[0], False) then
    Result := nil;
end;

function TField.GetAsDateTime: TDateTime;

begin
  raise AccessError(SdateTime);
end;

function TField.GetAsFloat: Double;

begin
  raise AccessError(SDateTime);
end;

function TField.GetAsLongint: Longint;

begin
  raise AccessError(SInteger);
end;

function TField.GetAsVariant: Variant;

begin
  raise AccessError(SVariant);
end;


function TField.GetAsInteger: Integer;

begin
  Result:=GetAsLongint;
end;

function TField.GetAsString: string;

begin
  Result := GetClassDesc;
end;

function TField.GetAsWideString: WideString;
begin
  Result := GetAsString;
end;

function TField.GetOldValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsOldValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetNewValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsNewValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

procedure TField.SetNewValue(const AValue: Variant);

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsNewValue);
    SetAsVariant(AValue);
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetCurValue: Variant;

var SaveState : TDatasetState;

begin
  SaveState := FDataset.State;
  try
    FDataset.SetTempState(dsCurValue);
    Result := GetAsVariant;
  finally
    FDataset.RestoreState(SaveState);
  end;
end;

function TField.GetCanModify: Boolean;

begin
  Result:=Not ReadOnly;
  If Result then
    begin
    Result := FieldKind in [fkData, fkInternalCalc];
    if Result then
      begin
      Result:=Assigned(DataSet) and Dataset.Active;
      If Result then
        Result:= DataSet.CanModify;
      end;
    end;
end;

function TField.GetClassDesc: String;
var ClassN : string;
begin
  ClassN := copy(ClassName,2,pos('Field',ClassName)-2);
  if isNull then
    result := '(' + LowerCase(ClassN) + ')'
   else
    result := '(' + UpperCase(ClassN) + ')';
end;

function TField.GetData(Buffer: Pointer): Boolean;

begin
  Result:=GetData(Buffer,True);
end;

function TField.GetData(Buffer: Pointer; NativeFormat : Boolean): Boolean;

begin
  IF FDataset=Nil then
    DatabaseErrorFmt(SNoDataset,[FieldName]);
  If FVAlidating then
    begin
    result:=assigned(FValueBuffer);
    If Result and assigned(Buffer) then
      Move (FValueBuffer^,Buffer^ ,DataSize);
    end
  else
    Result:=FDataset.GetFieldData(Self,Buffer,NativeFormat);
end;

function TField.GetDataSize: Integer;

begin
  Result:=0;
end;

function TField.GetDefaultWidth: Longint;

begin
  Result:=10;
end;

function TField.GetDisplayName  : String;

begin
  If FDisplayLabel<>'' then
    result:=FDisplayLabel
  else
    Result:=FFieldName;
end;

Function TField.IsDisplayStored : Boolean;

begin
  Result:=(DisplayLabel<>FieldName);
end;

function TField.GetLookupList: TLookupList;
begin
  if not Assigned(FLookupList) then
    FLookupList := TLookupList.Create;
  Result := FLookupList;
end;

procedure TField.CalcLookupValue;
begin
  if FLookupCache then
    Value := LookupList.ValueOfKey(FDataSet.FieldValues[FKeyFields])
  else if Assigned(FLookupDataSet) and FDataSet.Active then
    Value := FLookupDataSet.Lookup(FLookupKeyfields, FDataSet.FieldValues[FKeyFields], FLookupresultField);
end;

function TField.getIndex : longint;

begin
  If Assigned(FDataset) then
    Result:=FDataset.FFieldList.IndexOf(Self)
  else
    Result:=-1;
end;

function TField.GetLookup: Boolean;
begin
  Result := FieldKind = fkLookup;
end;

function TField.GetAsLargeInt: LargeInt;
begin
  Raise AccessError(SLargeInt);
end;

function TField.GetAsCurrency: Currency;
begin
  Result := GetAsFloat;
end;

procedure TField.SetAlignment(const AValue: TAlignMent);
begin
  if FAlignment <> AValue then
    begin
    FAlignment := Avalue;
    PropertyChanged(false);
    end;
end;

procedure TField.SetIndex(const AValue: Integer);
begin
  if FFields <> nil then FFields.SetFieldIndex(Self, AValue)
end;

procedure TField.SetAsCurrency(AValue: Currency);
begin
  SetAsFloat(AValue);
end;

function TField.GetIsNull: Boolean;

begin
  Result:=Not(GetData (Nil));
end;

function TField.GetParentComponent: TComponent;

begin
  Result := DataSet;
end;

procedure TField.GetText(var AText: string; ADisplayText: Boolean);

begin
  AText:=GetAsString;
end;

function TField.HasParent: Boolean;

begin
  HasParent:=True;
end;

function TField.IsValidChar(InputChar: Char): Boolean;

begin
  // FValidChars must be set in Create.
  Result:=InputChar in FValidChars;
end;

procedure TField.RefreshLookupList;
var
  tmpActive: Boolean;
begin
  if not Assigned(FLookupDataSet) or (Length(FLookupKeyfields) = 0)
  or (Length(FLookupresultField) = 0) or (Length(FKeyFields) = 0) then
    Exit;
    
  tmpActive := FLookupDataSet.Active;
  try
    FLookupDataSet.Active := True;
    FFields.CheckFieldNames(FKeyFields);
    FLookupDataSet.Fields.CheckFieldNames(FLookupKeyFields);
    FLookupDataset.FieldByName(FLookupResultField); // I presume that if it doesn't exist it throws exception, and that a field with null value is still valid
    LookupList.Clear; // have to be F-less because we might be creating it here with getter!

    FLookupDataSet.DisableControls;
    try
      FLookupDataSet.First;
      while not FLookupDataSet.Eof do
      begin
        FLookupList.Add(FLookupDataSet.FieldValues[FLookupKeyfields], FLookupDataSet.FieldValues[FLookupResultField]);
        FLookupDataSet.Next;
      end;
    finally
      FLookupDataSet.EnableControls;
    end;
  finally
    FLookupDataSet.Active := tmpActive;
  end;
end;

procedure TField.Notification(AComponent: TComponent; Operation: TOperation);

begin
  Inherited Notification(AComponent,Operation);
  if (Operation = opRemove) and (AComponent = FLookupDataSet) then
    FLookupDataSet := nil;
end;

procedure TField.PropertyChanged(LayoutAffected: Boolean);

begin
  If (FDataset<>Nil) and (FDataset.Active) then
    If LayoutAffected then
      FDataset.DataEvent(deLayoutChange,0)
    else
      FDataset.DataEvent(deDatasetchange,0);
end;

procedure TField.ReadState(Reader: TReader);

begin
  inherited ReadState(Reader);
  if Reader.Parent is TDataSet then
    DataSet := TDataSet(Reader.Parent);
end;

procedure TField.SetAsBCD(const AValue: TBCD);
begin
  Raise AccessError(SBCD);
end;

procedure TField.SetAsBytes(const AValue: TBytes);
begin
  raise AccessError(SBytes);
end;

procedure TField.SetAsBoolean(AValue: Boolean);

begin
  Raise AccessError(SBoolean);
end;

procedure TField.SetAsDateTime(AValue: TDateTime);

begin
  Raise AccessError(SDateTime);
end;

procedure TField.SetAsFloat(AValue: Double);

begin
  Raise AccessError(SFloat);
end;

procedure TField.SetAsVariant(const AValue: Variant);

begin
  if VarIsNull(AValue) then
    Clear
  else
    try
      SetVarValue(AValue);
    except
      on EVariantError do DatabaseErrorFmt(SFieldValueError, [DisplayName]);
    end;
end;


procedure TField.SetAsLongint(AValue: Longint);

begin
  Raise AccessError(SInteger);
end;

procedure TField.SetAsInteger(AValue: Integer);

begin
  SetAsLongint(AValue);
end;

procedure TField.SetAsLargeint(AValue: Largeint);
begin
  Raise AccessError(SLargeInt);
end;

procedure TField.SetAsString(const AValue: string);

begin
  Raise AccessError(SString);
end;

procedure TField.SetAsWideString(const aValue: WideString);
begin
  SetAsString(aValue);
end;


procedure TField.SetData(Buffer: Pointer);

begin
 SetData(Buffer,True);
end;

procedure TField.SetData(Buffer: Pointer; NativeFormat : Boolean);

begin
  If Not Assigned(FDataset) then
    DatabaseErrorFmt(SNoDataset,[FieldName]);
  FDataSet.SetFieldData(Self,Buffer, NativeFormat);
end;

Procedure TField.SetDataset (AValue : TDataset);

begin
{$ifdef dsdebug}
  Writeln ('Setting dataset');
{$endif}
  If AValue=FDataset then exit;
  If Assigned(FDataset) Then
    begin
    FDataset.CheckInactive;
    FDataset.FFieldList.Remove(Self);
    end;
  If Assigned(AValue) then
    begin
    AValue.CheckInactive;
    AValue.FFieldList.Add(Self);
    end;
  FDataset:=AValue;
end;

procedure TField.SetDataType(AValue: TFieldType);

begin
  FDataType := AValue;
end;

procedure TField.SetFieldType(AValue: TFieldType);

begin
  { empty }
end;

procedure TField.SetParentComponent(AParent: TComponent);

begin
  if not (csLoading in ComponentState) then
    DataSet := AParent as TDataSet;
end;

procedure TField.SetSize(AValue: Integer);

begin
  CheckInactive;
  CheckTypeSize(AValue);
  FSize:=AValue;
end;

procedure TField.SetText(const AValue: string);

begin
  AsString:=AValue;
end;

procedure TField.SetVarValue(const AValue: Variant);
begin
  Raise AccessError(SVariant);
end;

procedure TField.Validate(Buffer: Pointer);

begin
  If assigned(OnValidate) Then
    begin
    FValueBuffer:=Buffer;
    FValidating:=True;
    Try
      OnValidate(Self);
    finally
      FValidating:=False;
    end;
    end;
end;

class function Tfield.IsBlob: Boolean;

begin
  Result:=False;
end;

class procedure TField.CheckTypeSize(AValue: Longint);

begin
  If (AValue<>0) and Not IsBlob Then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

// TField private methods

procedure TField.SetEditText(const AValue: string);
begin
  if Assigned(OnSetText) then
    OnSetText(Self, AValue)
  else
    SetText(AValue);
end;

function TField.GetEditText: String;
begin
  SetLength(Result, 0);
  if Assigned(OnGetText) then
    OnGetText(Self, Result, False)
  else
    GetText(Result, False);
end;

function TField.GetDisplayText: String;
begin
  SetLength(Result, 0);
  if Assigned(OnGetText) then
    OnGetText(Self, Result, True)
  else
    GetText(Result, True);
end;

procedure TField.SetDisplayLabel(const AValue: string);
begin
  if FDisplayLabel<>Avalue then
    begin
    FDisplayLabel:=Avalue;
    PropertyChanged(true);
    end;
end;

procedure TField.SetDisplayWidth(const AValue: Longint);
begin
  if FDisplayWidth<>AValue then
    begin
    FDisplayWidth:=AValue;
    PropertyChanged(True);
    end;
end;

function TField.GetDisplayWidth: integer;
begin
  if FDisplayWidth=0 then
    result:=GetDefaultWidth
  else
    result:=FDisplayWidth;
end;

procedure TField.SetLookup(const AValue: Boolean);
const
  ValueToLookupMap: array[Boolean] of TFieldKind = (fkData, fkLookup);
begin
  FieldKind := ValueToLookupMap[AValue];
end;

procedure TField.SetReadOnly(const AValue: Boolean);
begin
  if (FReadOnly<>Avalue) then
    begin
    FReadOnly:=AValue;
    PropertyChanged(True);
    end;
end;

procedure TField.SetVisible(const AValue: Boolean);
begin
  if FVisible<>Avalue then
    begin
    FVisible:=AValue;
    PropertyChanged(True);
    end;
end;


{ ---------------------------------------------------------------------
    TStringField
  ---------------------------------------------------------------------}


constructor TStringField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftString);
  FFixedChar := False;
  FTransliterate := False;
  FSize:=20;
end;

procedure TStringField.SetFieldType(AValue: TFieldType);
begin
  if avalue in [ftString, ftFixedChar] then
    SetDataType(AValue);
end;

class procedure TStringField.CheckTypeSize(AValue: Longint);

begin
// A size of 0 is allowed, since for example Firebird allows
// a query like: 'select '' as fieldname from table' which
// results in a string with size 0.
  If (AValue<0) Then
    databaseErrorFmt(SInvalidFieldSize,[AValue])
end;

function TStringField.GetAsBoolean: Boolean;

Var S : String;

begin
  S:=GetAsString;
  result := (Length(S)>0) and (Upcase(S[1]) in ['T',YesNoChars[True]]);
end;

function TStringField.GetAsDateTime: TDateTime;

begin
  Result:=StrToDateTime(GetAsString);
end;

function TStringField.GetAsFloat: Double;

begin
  Result:=StrToFloat(GetAsString);
end;

function TStringField.GetAsLongint: Longint;

begin
  Result:=StrToInt(GetAsString);
end;

function TStringField.GetAsString: string;

begin
  If Not GetValue(Result) then
    Result:='';
end;

function TStringField.GetAsVariant: Variant;

Var s : string;

begin
  If GetValue(s) then
    Result:=s
  else
    Result:=Null;
end;


function TStringField.GetDataSize: Integer;

begin
  Result:=Size+1;
end;

function TStringField.GetDefaultWidth: Longint;

begin
  result:=Size;
end;

Procedure TStringField.GetText(var AText: string; ADisplayText: Boolean);

begin
    AText:=GetAsString;
end;

function TStringField.GetValue(var AValue: string): Boolean;

Var Buf, TBuf : TStringFieldBuffer;
    DynBuf, TDynBuf : Array of char;

begin
  if DataSize <= dsMaxStringSize then
    begin
    Result:=GetData(@Buf);
    buf[Size]:=#0;  //limit string to Size
    If Result then
      begin
      if transliterate then
        begin
        DataSet.Translate(Buf,TBuf,False);
        AValue:=TBuf;
        end
      else
        AValue:=Buf
      end
    end
  else
    begin
    SetLength(DynBuf,DataSize);
    Result:=GetData(@DynBuf[0]);
    Dynbuf[Size]:=#0;  //limit string to Size
    If Result then
      begin
      if transliterate then
        begin
        SetLength(TDynBuf,DataSize);
        DataSet.Translate(@DynBuf[0],@TDynBuf[0],False);
        AValue:=pchar(TDynBuf);
        end
      else
        AValue:=pchar(DynBuf);
      end
    end;
end;

procedure TStringField.SetAsBoolean(AValue: Boolean);

begin
  If AValue Then
    SetAsString('T')
  else
    SetAsString('F');
end;

procedure TStringField.SetAsDateTime(AValue: TDateTime);

begin
  SetAsString(DateTimeToStr(AValue));
end;

procedure TStringField.SetAsFloat(AValue: Double);

begin
  SetAsString(FloatToStr(AValue));
end;

procedure TStringField.SetAsLongint(AValue: Longint);

begin
  SetAsString(intToStr(AValue));
end;

procedure TStringField.SetAsString(const AValue: string);

var Buf      : TStringFieldBuffer;

begin
  IF Length(AValue)=0 then
    begin
    Buf := #0;
    SetData(@buf);
    end
  else if FTransliterate then
    begin
    DataSet.Translate(@AValue[1],Buf,True);
    Buf[DataSize-1] := #0;
    SetData(@buf);
    end
  else
    begin
    // The data is copied into the buffer, since some TDataset descendents copy
    // the whole buffer-length in SetData. (See bug 8477)
    Buf := AValue;
    // If length(AValue) > Datasize the buffer isn't terminated properly
    Buf[DataSize-1] := #0;
    SetData(@Buf);
    end;
end;

procedure TStringField.SetVarValue(const AValue: Variant);
begin
  SetAsString(AValue);
end;

{ ---------------------------------------------------------------------
    TWideStringField
  ---------------------------------------------------------------------}

class procedure TWideStringField.CheckTypeSize(aValue: Integer);
begin
// A size of 0 is allowed, since for example Firebird allows
// a query like: 'select '' as fieldname from table' which
// results in a string with size 0.
  If (AValue<0) Then
    databaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

constructor TWideStringField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftWideString);
end;

procedure TWideStringField.SetFieldType(AValue: TFieldType);
begin
  if avalue in [ftWideString, ftFixedWideChar] then
    SetDataType(AValue);
end;

function TWideStringField.GetValue(var aValue: WideString): Boolean;
var
  FixBuffer : array[0..dsMaxStringSize div 2] of WideChar;
  DynBuffer : array of WideChar;
  Buffer    : PWideChar;
begin
  if DataSize <= dsMaxStringSize then begin
    Result := GetData(@FixBuffer, False);
    FixBuffer[Size]:=#0;     //limit string to Size
    aValue := FixBuffer;
  end else begin
    SetLength(DynBuffer, Succ(Size));
    Buffer := PWideChar(DynBuffer);
    Result := GetData(Buffer, False);
    Buffer[Size]:=#0;     //limit string to Size
    if Result then
      aValue := Buffer;
  end;
end;

function TWideStringField.GetAsString: string;
begin
  Result := GetAsWideString;
end;

procedure TWideStringField.SetAsString(const aValue: string);
begin
  SetAsWideString(aValue);
end;

function TWideStringField.GetAsVariant: Variant;
var
  ws: WideString;
begin
  if GetValue(ws) then
    Result := ws
  else
    Result := Null;
end;

procedure TWideStringField.SetVarValue(const aValue: Variant);
begin
  SetAsWideString(aValue);
end;

function TWideStringField.GetAsWideString: WideString;
begin
  if not GetValue(Result) then
    Result := '';
end;

procedure TWideStringField.SetAsWideString(const aValue: WideString);
const
  NullWideChar : WideChar = #0;
var
  Buffer : PWideChar;
begin
  if Length(aValue)>0 then
    Buffer := PWideChar(@aValue[1])
  else
    Buffer := @NullWideChar;
  SetData(Buffer, False);
end;

function TWideStringField.GetDataSize: Integer;
begin
  Result :=
    (Size + 1) * 2;
end;


{ ---------------------------------------------------------------------
    TNumericField
  ---------------------------------------------------------------------}


constructor TNumericField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  AlignMent:=taRightJustify;
end;

class procedure TNumericField.CheckTypeSize(AValue: Longint);
begin
  // This procedure is only added because some TDataset descendents have the
  // but that they set the Size property as if it is the DataSize property.
  // To avoid problems with those descendents, allow values <= 16.
  If (AValue>16) Then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

procedure TNumericField.RangeError(AValue, Min, Max: Double);

begin
  DatabaseErrorFMT(SRangeError,[AValue,Min,Max,FieldName]);
end;

procedure TNumericField.SetDisplayFormat(const AValue: string);

begin
 If FDisplayFormat<>AValue then
   begin
   FDisplayFormat:=AValue;
   PropertyChanged(True);
   end;
end;

procedure TNumericField.SetEditFormat(const AValue: string);

begin
  If FEDitFormat<>AValue then
    begin
    FEDitFormat:=AVAlue;
    PropertyChanged(True);
    end;
end;

function TNumericField.GetAsBoolean: Boolean;
begin
  Result:=GetAsInteger<>0;
end;

procedure TNumericField.SetAsBoolean(AValue: Boolean);
begin
  if AValue then
    SetAsLongint(1)
  else
    SetAsLongint(0);
end; 

{ ---------------------------------------------------------------------
    TLongintField
  ---------------------------------------------------------------------}


constructor TLongintField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftinteger);
  FMinRange:=Low(LongInt);
  FMaxRange:=High(LongInt);
  FValidchars:=['+','-','0'..'9'];
end;

function TLongintField.GetAsFloat: Double;

begin
  Result:=GetAsLongint;
end;

function TLongintField.GetAsLargeint: Largeint;
begin
  Result:=GetAsLongint;
end;

function TLongintField.GetAsLongint: Longint;

begin
  If Not GetValue(Result) then
    Result:=0;
end;

function TLongintField.GetAsVariant: Variant;

Var L : Longint;

begin
  If GetValue(L) then
    Result:=L
  else
    Result:=Null;
end;

function TLongintField.GetAsString: string;

Var L : Longint;

begin
  If GetValue(L) then
    Result:=IntTostr(L)
  else
    Result:='';
end;

function TLongintField.GetDataSize: Integer;

begin
  Result:=SizeOf(Longint);
end;

procedure TLongintField.GetText(var AText: string; ADisplayText: Boolean);

var l : longint;
    fmt : string;

begin
  Atext:='';
  If Not GetValue(l) then exit;
  If ADisplayText or (FEditFormat='') then
    fmt:=FDisplayFormat
  else
    fmt:=FEditFormat;
  If length(fmt)<>0 then
    AText:=FormatFloat(fmt,L)
  else
    Str(L,AText);
end;

function TLongintField.GetValue(var AValue: Longint): Boolean;

Var L : Longint;
    P : PLongint;

begin
  P:=@L;
  Result:=GetData(P);
  If Result then
    Case Datatype of
      ftInteger,ftautoinc  : AValue:=Plongint(P)^;
      ftword               : Avalue:=Pword(P)^;
      ftsmallint           : AValue:=PSmallint(P)^;
    end;
end;

procedure TLongintField.SetAsLargeint(AValue: Largeint);
begin
  if (AValue>=FMinRange) and (AValue<=FMaxRange) then
    SetAsLongint(AValue)
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

procedure TLongintField.SetAsFloat(AValue: Double);

begin
  SetAsLongint(Round(Avalue));
end;

procedure TLongintField.SetAsLongint(AValue: Longint);

begin
  If CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(Avalue,FMinrange,FMaxRange);
end;

procedure TLongintField.SetVarValue(const AValue: Variant);
begin
  SetAsLongint(AValue);
end;

procedure TLongintField.SetAsString(const AValue: string);

Var L,Code : longint;

begin
  If length(AValue)=0 then
    Clear
  else
    begin
    Val(AVAlue,L,Code);
    If Code=0 then
      SetAsLongint(L)
    else
      DatabaseErrorFMT(SNotAnInteger,[Avalue]);
    end;
end;

Function TLongintField.CheckRange(AValue : longint) : Boolean;

begin
  result := true;
  if (FMaxValue=0) then
    begin
    if (AValue>FMaxRange) Then result := false;
    end
  else
    if AValue>FMaxValue then result := false;

  if (FMinValue=0) then
    begin
    if (AValue<FMinRange) Then result := false;
    end
  else
    if AValue<FMinValue then result := false;
end;

Procedure TLongintField.SetMaxValue (AValue : longint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMaxValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

Procedure TLongintField.SetMinValue (AValue : longint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMinValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

{ ---------------------------------------------------------------------
    TLargeintField
  ---------------------------------------------------------------------}


constructor TLargeintField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftLargeint);
  FMinRange:=Low(Largeint);
  FMaxRange:=High(Largeint);
  FValidchars:=['+','-','0'..'9'];
end;

function TLargeintField.GetAsFloat: Double;

begin
  Result:=GetAsLargeint;
end;

function TLargeintField.GetAsLargeint: Largeint;

begin
  If Not GetValue(Result) then
    Result:=0;
end;

function TLargeIntField.GetAsVariant: Variant;

Var L : Largeint;

begin
  If GetValue(L) then
    Result:=L
  else
    Result:=Null;
end;

function TLargeintField.GetAsLongint: Longint;

begin
  Result:=GetAsLargeint;
end;

function TLargeintField.GetAsString: string;

Var L : Largeint;

begin
  If GetValue(L) then
    Result:=IntTostr(L)
  else
    Result:='';
end;

function TLargeintField.GetDataSize: Integer;

begin
  Result:=SizeOf(Largeint);
end;

procedure TLargeintField.GetText(var AText: string; ADisplayText: Boolean);

var l : largeint;
    fmt : string;

begin
  Atext:='';
  If Not GetValue(l) then exit;
  If ADisplayText or (FEditFormat='') then
    fmt:=FDisplayFormat
  else
    fmt:=FEditFormat;
  If length(fmt)<>0 then
    AText:=FormatFloat(fmt,L)
  else
    Str(L,AText);
end;

function TLargeintField.GetValue(var AValue: Largeint): Boolean;

type
  PLargeint = ^Largeint;

Var P : PLargeint;

begin
  P:=@AValue;
  Result:=GetData(P);
end;

procedure TLargeintField.SetAsFloat(AValue: Double);

begin
  SetAsLargeint(Round(Avalue));
end;

procedure TLargeintField.SetAsLargeint(AValue: Largeint);

begin
  If CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(Avalue,FMinrange,FMaxRange);
end;

procedure TLargeintField.SetAsLongint(AValue: Longint);

begin
  SetAsLargeint(Avalue);
end;

procedure TLargeintField.SetAsString(const AValue: string);

Var L     : largeint;
    code  : longint;

begin
  If length(AValue)=0 then
    Clear
  else
    begin
    Val(AVAlue,L,Code);
    If Code=0 then
      SetAsLargeint(L)
    else
      DatabaseErrorFMT(SNotAnInteger,[Avalue]);
    end;
end;

procedure TLargeintField.SetVarValue(const AValue: Variant);
begin
  SetAsLargeint(AValue);
end;

Function TLargeintField.CheckRange(AValue : largeint) : Boolean;

begin
  result := true;
  if (FMaxValue=0) then
    begin
    if (AValue>FMaxRange) Then result := false;
    end
  else
    if AValue>FMaxValue then result := false;

  if (FMinValue=0) then
    begin
    if (AValue<FMinRange) Then result := false;
    end
  else
    if AValue<FMinValue then result := false;
end;

Procedure TLargeintField.SetMaxValue (AValue : largeint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMaxValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

Procedure TLargeintField.SetMinValue (AValue : largeint);

begin
  If (AValue>=FMinRange) and (AValue<=FMaxRange) then
    FMinValue:=AValue
  else
    RangeError(AValue,FMinRange,FMaxRange);
end;

{ TSmallintField }

function TSmallintField.GetDataSize: Integer;

begin
  Result:=SizeOf(SmallInt);
end;

constructor TSmallintField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftSmallInt);
  FMinRange:=-32768;
  FMaxRange:=32767;
end;


{ TWordField }

function TWordField.GetDataSize: Integer;

begin
  Result:=SizeOf(Word);
end;

constructor TWordField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftWord);
  FMinRange:=0;
  FMaxRange:=65535;
  FValidchars:=['+','0'..'9'];
end;

{ TAutoIncField }

constructor TAutoIncField.Create(AOwner: TComponent);

begin
  Inherited Create(AOWner);
  SetDataType(ftAutoInc);
  FReadOnly:=True;
  FProviderFlags:=FProviderFlags-[pfInUpdate];
end;

Procedure TAutoIncField.SetAsLongint(AValue : Longint);

begin
  // Some databases allows insertion of explicit values into identity columns
  // (some of them also allows (some not) updating identity columns)
  // So allow it at client side and leave check for server side
  if not(FDataSet.State in [dsFilter,dsSetKey,dsInsert]) then
    DataBaseError(SCantSetAutoIncFields);
  inherited;
end;

{ TFloatField }

procedure TFloatField.SetCurrency(const AValue: Boolean);
begin
  if FCurrency=AValue then exit;
  FCurrency:=AValue;
end;

procedure TFloatField.SetPrecision(const AValue: Longint);
begin
  if (AValue = -1) or (AValue > 1) then
    FPrecision := AValue
  else
    FPrecision := 2;
end;

function TFloatField.GetAsFloat: Double;

begin
  If Not GetData(@Result) Then
    Result:=0.0;
end;

function TFloatField.GetAsVariant: Variant;

Var f : Double;

begin
  If GetData(@f) then
    Result := f
  else
    Result:=Null;
end;

function TFloatField.GetAsLongint: Longint;

begin
  Result:=Round(GetAsFloat);
end;

function TFloatField.GetAsString: string;

Var R : Double;

begin
  If GetData(@R) then
    Result:=FloatToStr(R)
  else
    Result:='';
end;

function TFloatField.GetDataSize: Integer;

begin
  Result:=SizeOf(Double);
end;

procedure TFloatField.GetText(var TheText: string; ADisplayText: Boolean);

Var
    fmt : string;
    E : Double;
    Digits : integer;
    ff: TFloatFormat;

begin
  TheText:='';
  If Not GetData(@E) then exit;
  If ADisplayText or (Length(FEditFormat) = 0) Then
    Fmt:=FDisplayFormat
  else
    Fmt:=FEditFormat;
    
  Digits := 0;
  if not FCurrency then
    ff := ffGeneral
  else
    begin
    Digits := CurrencyDecimals;
    if ADisplayText then
      ff := ffCurrency
    else
      ff := ffFixed;
    end;


  If fmt<>'' then
    TheText:=FormatFloat(fmt,E)
  else
    TheText:=FloatToStrF(E,ff,FPrecision,Digits);
end;

procedure TFloatField.SetAsFloat(AValue: Double);

begin
  If CheckRange(AValue) then
    SetData(@Avalue)
  else
    RangeError(AValue,FMinValue,FMaxValue);
end;

procedure TFloatField.SetAsLongint(AValue: Longint);

begin
  SetAsFloat(Avalue);
end;

procedure TFloatField.SetAsString(const AValue: string);

Var R : Double;

begin
  If (AValue='') then
    Clear
  else  
    try
      R := StrToFloat(AValue);
      SetAsFloat(R);
    except
      DatabaseErrorFmt(SNotAFloat, [AValue]);
    end;
end;

procedure TFloatField.SetVarValue(const AValue: Variant);
begin
  SetAsFloat(Avalue);
end;

constructor TFloatField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDatatype(ftfloat);
  FPrecision:=15;
  FValidChars := [DecimalSeparator, '+', '-', '0'..'9', 'E', 'e'];
end;

Function TFloatField.CheckRange(AValue : Double) : Boolean;

begin
  If (FMinValue<>0) or (FmaxValue<>0) then
    Result:=(AValue>=FMinValue) and (AVAlue<=FMAxValue)
  else
    Result:=True;
end;

{ TCurrencyField }

Constructor TCurrencyField.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  SetDataType(ftCurrency);
  Currency := True;
end;

{ TBooleanField }

function TBooleanField.GetAsBoolean: Boolean;

var b : wordbool;

begin
  If GetData(@b) then
    result := b
  else
    Result:=False;
end;

function TBooleanField.GetAsVariant: Variant;

Var b : wordbool;

begin
  If GetData(@b) then
    Result := b
  else
    Result:=Null;
end;

function TBooleanField.GetAsString: string;

Var B : wordbool;

begin
  If Getdata(@B) then
    Result:=FDisplays[False,B]
  else
    result:='';
end;

function TBooleanField.GetDataSize: Integer;

begin
  Result:=SizeOf(wordBool);
end;

function TBooleanField.GetDefaultWidth: Longint;

begin
  Result:=Length(FDisplays[false,false]);
  If Result<Length(FDisplays[false,True]) then
    Result:=Length(FDisplays[false,True]);
end;

function TBooleanField.GetAsInteger: integer;
begin
   if GetAsBoolean then
    Result:=1
   else
    Result:=0;
end;

procedure TBooleanField.SetAsInteger(AValue: Integer);
begin
  SetAsBoolean(avalue<>0);
end;

procedure TBooleanField.SetAsBoolean(AValue: Boolean);

var b : wordbool;

begin
  b := AValue;
  SetData(@b);
end;

procedure TBooleanField.SetAsString(const AValue: string);

Var Temp : string;

begin
  Temp:=UpperCase(AValue);
  if Temp='' then
    Clear
  else if pos(Temp, FDisplays[True,True])=1 then
    SetAsBoolean(True)
  else if pos(Temp, FDisplays[True,False])=1 then
    SetAsBoolean(False)
  else
    DatabaseErrorFmt(SNotABoolean,[AValue]);
end;

procedure TBooleanField.SetVarValue(const AValue: Variant);
begin
  SetAsBoolean(AValue);
end;

constructor TBooleanField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftBoolean);
  DisplayValues:='True;False';
end;

Procedure TBooleanField.SetDisplayValues(const AValue : String);

Var I : longint;

begin
  If FDisplayValues<>AValue then
    begin
    I:=Pos(';',AValue);
    If (I<2) or (I=Length(AValue)) then
      DatabaseErrorFmt(SInvalidDisplayValues,[AValue]);
    FdisplayValues:=AValue;
    // Store display values and their uppercase equivalents;
    FDisplays[False,True]:=Copy(AValue,1,I-1);
    FDisplays[True,True]:=UpperCase(FDisplays[False,True]);
    FDisplays[False,False]:=Copy(AValue,I+1,Length(AValue)-i);
    FDisplays[True,False]:=UpperCase(FDisplays[False,False]);
    PropertyChanged(True);
    end;
end;

{ TDateTimeField }

procedure TDateTimeField.SetDisplayFormat(const AValue: string);
begin
  if FDisplayFormat<>AValue then begin
    FDisplayFormat:=AValue;
    PropertyChanged(True);
  end;
end;

function TDateTimeField.GetAsDateTime: TDateTime;

begin
  If Not GetData(@Result,False) then
    Result:=0;
end;

procedure TDateTimeField.SetVarValue(const AValue: Variant);
begin
  SetAsDateTime(AValue);
end;

function TDateTimeField.GetAsVariant: Variant;

Var d : tDateTime;

begin
  If Getdata(@d,False) then
    Result := d
  else
    Result:=Null;
end;

function TDateTimeField.GetAsFloat: Double;

begin
  Result:=GetAsdateTime;
end;


function TDateTimeField.GetAsString: string;

begin
  GetText(Result,False);
end;


function TDateTimeField.GetDataSize: Integer;

begin
  Result:=SizeOf(TDateTime);
end;


procedure TDateTimeField.GetText(var TheText: string; ADisplayText: Boolean);

Var R : TDateTime;
    F : String;

begin
  If Not Getdata(@R,False) then
    TheText:=''
  else
    begin
    If (ADisplayText) and (Length(FDisplayFormat)<>0) then
      F:=FDisplayFormat
    else
      Case DataType of
       ftTime : F:=LongTimeFormat;
       ftDate : F:=ShortDateFormat;
      else
       F:='c'
      end;
    TheText:=FormatDateTime(F,R);
    end;
end;


procedure TDateTimeField.SetAsDateTime(AValue: TDateTime);

begin
  SetData(@Avalue,False);
end;


procedure TDateTimeField.SetAsFloat(AValue: Double);

begin
  SetAsDateTime(AValue);
end;


procedure TDateTimeField.SetAsString(const AValue: string);

Var R : TDateTime;

begin
  if AValue<>'' then
    begin
    R:=StrToDateTime(AVAlue);
    SetData(@R,False);
    end
  else
    SetData(Nil);
end;


constructor TDateTimeField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftDateTime);
end;


{ TDateField }

constructor TDateField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftDate);
end;


{ TTimeField }

constructor TTimeField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftTime);
end;

procedure TTimeField.SetAsString(const AValue: string);
Var R : TDateTime;
begin
  if AValue='' then
    Clear    // set to NULL
  else
    begin
    R:=StrToTime(AVAlue);
    SetData(@R,False);
    end;
end;



{ TBinaryField }

class procedure TBinaryField.CheckTypeSize(AValue: Longint);

begin
  // Just check for really invalid stuff; actual size is
  // dependent on the record...
  If AValue<1 then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

function TBinaryField.GetAsBytes: TBytes;
var B: TBytes;
begin
  SetLength(B, DataSize);
  if not assigned(B) or not GetData(Pointer(B), True) then
    SetLength(Result, 0)
  else if DataType = ftVarBytes then
  begin
    SetLength(Result, PWord(B)^);
    Move(B[sizeof(Word)], Result[0], Length(Result));
  end
  else // ftBytes
    Result := B;
end;


function TBinaryField.GetAsString: string;
var B: TBytes;
begin
  B := GetAsBytes;
  if length(B) = 0 then
    Result := ''
  else
    SetString(Result, @B[0], length(B) div SizeOf(Char));
end;


function TBinaryField.GetAsVariant: Variant;
var B: TBytes;
    P: Pointer;
begin
  B := GetAsBytes;
  Result := VarArrayCreate([0, length(B)-1], varByte);
  P := VarArrayLock(Result);
  try
    Move(B[0], P^, length(B));
  finally
    VarArrayUnlock(Result);
  end;
end;


procedure TBinaryField.GetText(var TheText: string; ADisplayText: Boolean);

begin
  TheText:=GetAsString;
end;


procedure TBinaryField.SetAsBytes(const AValue: TBytes);
var Buf: array[0..dsMaxStringSize] of byte;
    DynBuf: TBytes;
    Len: Word;
    P: PByte;
begin
  Len := Length(AValue);
  if Len >= DataSize then
    P := @AValue[0]
  else begin
    if DataSize <= dsMaxStringSize then
      P := @Buf[0]
    else begin
      SetLength(DynBuf, DataSize);
      P := @DynBuf[0];
    end;

    if DataType = ftVarBytes then begin
      PWord(P)^ := Len;
      Move(AValue[0], P[sizeof(Word)], Len);
    end
    else begin // ftBytes
      Move(AValue[0], P^, Len);
      FillChar(P[Len], DataSize-Len, 0); // right pad with #0
    end;
  end;
  SetData(P, True)
end;


procedure TBinaryField.SetAsString(const AValue: string);
var B : TBytes;
begin
  If Length(AValue) = DataSize then
    SetData(PChar(AValue))
  else
  begin
    SetLength(B, Length(AValue) * SizeOf(Char));
    Move(AValue[1], B[0], Length(B));
    SetAsBytes(B);
  end;
end;


procedure TBinaryField.SetText(const AValue: string);

begin
  SetAsString(Avalue);
end;

procedure TBinaryField.SetVarValue(const AValue: Variant);
var P: Pointer;
    B: TBytes;
    Len: integer;
begin
  if VarIsArray(AValue) then
  begin
    P := VarArrayLock(AValue);
    try
      Len := VarArrayHighBound(AValue, 1) + 1;
      SetLength(B, Len);
      Move(P^, B[0], Len);
    finally
      VarArrayUnlock(AValue);
    end;
    SetAsBytes(B);
  end
  else
    SetAsString(AValue);
end;


constructor TBinaryField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
end;



{ TBytesField }

function TBytesField.GetDataSize: Integer;

begin
  Result:=Size;
end;


constructor TBytesField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftBytes);
  Size:=16;
end;



{ TVarBytesField }

function TVarBytesField.GetDataSize: Integer;

begin
  Result:=Size+2;
end;


constructor TVarBytesField.Create(AOwner: TComponent);

begin
  INherited Create(AOwner);
  SetDataType(ftvarbytes);
  Size:=16;
end;

{ TBCDField }

class procedure TBCDField.CheckTypeSize(AValue: Longint);

begin
  If not (AValue in [0..4]) then
    DatabaseErrorfmt(SInvalidFieldSize,[Avalue]);
end;

function TBCDField.GetAsCurrency: Currency;

begin
  if not GetData(@Result) then
    result := 0;
end;

function TBCDField.GetAsVariant: Variant;

Var c : system.Currency;

begin
  If GetData(@c) then
    Result := c
  else
    Result:=Null;
end;

function TBCDField.GetAsFloat: Double;

begin
  result := GetAsCurrency;
end;


function TBCDField.GetAsLongint: Longint;

begin
  result := round(GetAsCurrency);
end;


function TBCDField.GetAsString: string;

var c : system.currency;

begin
  If GetData(@C) then
    Result:=CurrToStr(C)
  else
    Result:='';
end;

function TBCDField.GetValue(var AValue: Currency): Boolean;

begin
  Result := GetData(@AValue);
end;

function TBCDField.GetDataSize: Integer;

begin
  result := sizeof(system.currency);
end;

function TBCDField.GetDefaultWidth: Longint;

begin
  if precision > 0 then result := precision
    else result := 10;
end;

procedure TBCDField.GetText(var TheText: string; ADisplayText: Boolean);
var
  c : system.currency;
  fmt: String;
begin
  if GetData(@C) then begin
    if aDisplayText or (FEditFormat='') then
      fmt := FDisplayFormat
    else
      fmt := FEditFormat;
    if fmt<>'' then
      TheText := FormatFloat(fmt,C)
    else if fCurrency then begin
      if aDisplayText then
        TheText := FloatToStrF(C, ffCurrency, FPrecision, 2{digits?})
      else
        TheText := FloatToStrF(C, ffFixed, FPrecision, 2{digits?});
    end else
      TheText := FloatToStrF(C, ffGeneral, FPrecision, 0{digits?});
  end else
    TheText := '';
end;

procedure TBCDField.SetAsCurrency(AValue: Currency);

begin
  If CheckRange(AValue) then
    setdata(@AValue)
  else
    RangeError(AValue,FMinValue,FMaxvalue);
end;

procedure TBCDField.SetVarValue(const AValue: Variant);
begin
  SetAsCurrency(AValue);
end;

Function TBCDField.CheckRange(AValue : Currency) : Boolean;

begin
  If (FMinValue<>0) or (FmaxValue<>0) then
    Result:=(AValue>=FMinValue) and (AVAlue<=FMaxValue)
  else
    Result:=True;
end;

procedure TBCDField.SetAsFloat(AValue: Double);

begin
  SetAsCurrency(AValue);
end;


procedure TBCDField.SetAsLongint(AValue: Longint);

begin
  SetAsCurrency(AValue);
end;


procedure TBCDField.SetAsString(const AValue: string);

begin
  if AValue='' then
    Clear    // set to NULL
  else
    SetAsCurrency(strtocurr(AValue));
end;

constructor TBCDField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  FMaxvalue := 0;
  FMinvalue := 0;
  FValidChars := [DecimalSeparator, '+', '-', '0'..'9'];
  SetDataType(ftBCD);
  FPrecision := 15;
  Size:=4;
end;


{ TFMTBCDField }

class procedure TFMTBCDField.CheckTypeSize(AValue: Longint);
begin
  If AValue > MAXFMTBcdFractionSize then
    DatabaseErrorfmt(SInvalidFieldSize,[AValue]);
end;

constructor TFMTBCDField.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FMaxValue := 0;
  FMinValue := 0;
  FValidChars := [DecimalSeparator, '+', '-', '0'..'9'];
  SetDataType(ftFMTBCD);
// Max.precision for NUMERIC,DECIMAL datatypes supported by some databases:
//  Firebird-18; Oracle,SqlServer-38; MySQL-65; PostgreSQL-1000
  Precision := 15; //default number of digits
  Size:=4; //default number of digits after decimal place
end;

function TFMTBCDField.GetDataSize: Integer;
begin
  Result := sizeof(TBCD);
end;

function TFMTBCDField.GetDefaultWidth: Longint;
begin
  if Precision > 0 then Result := Precision+1
  else Result := inherited GetDefaultWidth;
end;

function TFMTBCDField.GetAsBCD: TBCD;
begin
  if not GetData(@Result) then
    Result := NullBCD;
end;

function TFMTBCDField.GetAsCurrency: Currency;
var bcd: TBCD;
begin
  if GetData(@bcd) then
    BCDToCurr(bcd, Result)
  else
    Result := 0;
end;

function TFMTBCDField.GetAsVariant: Variant;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result := VarFMTBcdCreate(bcd)
  else
    Result := Null;
end;

function TFMTBCDField.GetAsFloat: Double;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result := BCDToDouble(bcd)
  else
    Result := 0;
end;

function TFMTBCDField.GetAsLongint: Longint;
begin
  Result := round(GetAsFloat);
end;

function TFMTBCDField.GetAsString: string;
var bcd: TBCD;
begin
  If GetData(@bcd) then
    Result:=BCDToStr(bcd)
  else
    Result:='';
end;

procedure TFMTBCDField.GetText(var TheText: string; ADisplayText: Boolean);
var
  bcd: TBCD;
  fmt: String;
begin
  if GetData(@bcd) then begin
    if aDisplayText or (FEditFormat='') then
      fmt := FDisplayFormat
    else
      fmt := FEditFormat;
    if fmt<>'' then
      TheText := BCDToStr(bcd)
      //TheText := FormatBCD(fmt,bcd) //uncomment when formatBCD in fmtbcd.pp will be implemented
    else if fCurrency then begin
      if aDisplayText then
        TheText := BcdToStrF(bcd, ffCurrency, FPrecision, 2)
      else
        TheText := BcdToStrF(bcd, ffFixed, FPrecision, 2);
    end else
      TheText := BcdToStrF(bcd, ffGeneral, FPrecision, FSize);
  end else
    TheText := '';
end;

function TFMTBCDField.GetMaxValue: string;
begin
  Result:=BCDToStr(FMaxValue);
end;

function TFMTBCDField.GetMinValue: string;
begin
  Result:=BCDToStr(FMinValue);
end;

procedure TFMTBCDField.SetMaxValue(const AValue: string);
begin
  FMaxValue:=StrToBCD(AValue);
end;

procedure TFMTBCDField.SetMinValue(const AValue: string);
begin
  FMinValue:=StrToBCD(AValue);
end;

Function TFMTBCDField.CheckRange(AValue: TBCD) : Boolean;
begin
  If (FMinValue<>0) or (FMaxValue<>0) then
    Result:=(AValue>=FMinValue) and (AValue<=FMaxValue)
  else
    Result:=True;
end;

procedure TFMTBCDField.SetAsBCD(const AValue: TBCD);
begin
  if CheckRange(AValue) then
    SetData(@AValue)
  else
    RangeError(AValue, BCDToDouble(FMinValue), BCDToDouble(FMaxValue));
end;

procedure TFMTBCDField.SetAsCurrency(AValue: Currency);
var bcd: TBCD;
begin
  if CurrToBCD(AValue, bcd, 32, Size) then
    SetAsBCD(bcd);
end;

procedure TFMTBCDField.SetVarValue(const AValue: Variant);
begin
  SetAsBCD(VarToBCD(AValue));
end;

procedure TFMTBCDField.SetAsFloat(AValue: Double);
begin
  SetAsBCD(DoubleToBCD(AValue));
end;


procedure TFMTBCDField.SetAsLongint(AValue: Longint);
begin
  SetAsBCD(IntegerToBCD(AValue));
end;


procedure TFMTBCDField.SetAsString(const AValue: string);
begin
  if AValue='' then
    Clear    // set to NULL
  else
    SetAsBCD(StrToBCD(AValue));
end;


{ TBlobField }

Function TBlobField.GetBlobStream(Mode : TBlobStreamMode) : TStream;

begin
  Result:=FDataset.CreateBlobStream(Self,Mode);
end;

procedure TBlobField.FreeBuffers;

begin
end;


function TBlobField.GetAsString: string;
var
  Stream : TStream;
  Len    : Integer;
begin
  Stream := GetBlobStream(bmRead);
  if Stream <> nil then
    With Stream do
      try
        Len := Size;
        SetLength(Result, Len);
        if Len > 0 then
          ReadBuffer(Result[1], Len);
      finally
        Free
      end
  else
    Result := '';
end;

function TBlobField.GetAsWideString: WideString;
var
  Stream : TStream;
  Len    : Integer;
begin
  Stream := GetBlobStream(bmRead);
  if Stream <> nil then
    With Stream do
      try
        Len := Size;
        SetLength(Result,Len div 2);
        if Len > 0 then
          ReadBuffer(Result[1] ,Len);
      finally
        Free
      end
  else
    Result := '';
end;

function TBlobField.GetAsVariant: Variant;

Var s : string;

begin
  if not GetIsNull then
    begin
    s := GetAsString;
    result := s;
    end
  else result := Null;
end;


function TBlobField.GetBlobSize: Longint;
var
  Stream: TStream;
begin
  Stream := GetBlobStream(bmread);
  if Stream <> nil then
    With Stream do
      try
        Result:=Size;
      finally
        Free;
      end
  else
    result := 0;
end;


function TBlobField.GetIsNull: Boolean;

begin
  If Not Modified then
    result:= inherited GetIsnull
  else
    With GetBlobStream(bmread) do
      try
        Result:=(Size=0);
      Finally
        Free;
      end;
end;


procedure TBlobField.GetText(var TheText: string; ADisplayText: Boolean);

begin
  TheText:=inherited GetAsString;
end;


procedure TBlobField.SetAsString(const AValue: string);
var
  Len : Integer;
begin
  With GetBlobStream(bmwrite) do
    try
      Len := Length(Avalue);
      if Len > 0 then
        WriteBuffer(aValue[1], Len);
    finally
      Free;
    end;
end;


procedure TBlobField.SetAsWideString(const AValue: WideString);
var
  Len : Integer;
begin
  With GetBlobStream(bmwrite) do
    try
      Len := Length(Avalue) * 2;
      if Len > 0 then
        WriteBuffer(aValue[1], Len);
    finally
      Free;
    end;
end;


procedure TBlobField.SetText(const AValue: string);

begin
  SetAsString(AValue);
end;

procedure TBlobField.SetVarValue(const AValue: Variant);
begin
  SetAsString(AValue);
end;


constructor TBlobField.Create(AOwner: TComponent);

begin
  Inherited Create(AOWner);
  SetDataType(ftBlob);
end;


procedure TBlobField.Clear;

begin
  GetBlobStream(bmWrite).free;
end;


class function TBlobField.IsBlob: Boolean;

begin
  Result:=True;
end;


procedure TBlobField.LoadFromFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create(FileName,fmOpenRead);
  try
    LoadFromStream(S);
  finally
    S.Free;
  end;
end;


procedure TBlobField.LoadFromStream(Stream: TStream);

begin
  With GetBlobStream(bmWrite) do
    Try
      CopyFrom(Stream,0);
    finally
      Free;
    end;
end;


procedure TBlobField.SaveToFile(const FileName: string);

Var S : TFileStream;

begin
  S:=TFileStream.Create(FileName,fmCreate);
  try
    SaveToStream(S);
  finally
    S.Free;
  end;
end;


procedure TBlobField.SaveToStream(Stream: TStream);

Var S : TStream;

begin
  S:=GetBlobStream(bmRead);
  Try
    If Assigned(S) then
      Stream.CopyFrom(S,0);
  finally
    S.Free;
  end;
end;

procedure TBlobField.SetFieldType(AValue: TFieldType);

begin
  If AValue in [Low(TBlobType)..High(TBlobType)] then
    SetDatatype(Avalue);
end;

{ TMemoField }

constructor TMemoField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftMemo);
end;

function TMemoField.GetAsWideString: WideString;
begin
  Result := GetAsString;
end;

procedure TMemoField.SetAsWideString(const aValue: WideString);
begin
  SetAsString(aValue);
end;

{ TWideMemoField }

constructor TWideMemoField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftWideMemo);
end;

function TWideMemoField.GetAsString: string;
begin
  Result := GetAsWideString;
end;

procedure TWideMemoField.SetAsString(const aValue: string);
begin
  SetAsWideString(aValue);
end;

function TWideMemoField.GetAsVariant: Variant;

Var s : string;

begin
  if not GetIsNull then
    begin
    s := GetAsWideString;
    result := s;
    end
  else result := Null;
end;

procedure TWideMemoField.SetVarValue(const AValue: Variant);
begin
  SetAsWideString(AValue);
end;

{ TGraphicField }

constructor TGraphicField.Create(AOwner: TComponent);

begin
  Inherited Create(AOwner);
  SetDataType(ftGraphic);
end;

{ TGuidField }

constructor TGuidField.Create(AOwner: TComponent);
begin
  Size := 38;
  inherited Create(AOwner);
  SetDataType(ftGuid);
end;

class procedure TGuidField.CheckTypeSize(AValue: LongInt);
begin
  if aValue <> 38 then
    DatabaseErrorFmt(SInvalidFieldSize,[AValue]);
end;

function TGuidField.GetAsGuid: TGUID;
const
  nullguid: TGUID = '{00000000-0000-0000-0000-000000000000}';
var
  S: string;
begin
  S := GetAsString;
  if S = '' then
    Result := nullguid
  else
    Result := StringToGuid(S);
end;

function TGuidField.GetDefaultWidth: LongInt;
begin
  Result := 38;
end;

procedure TGuidField.SetAsGuid(const aValue: TGUID);
begin
  SetAsString(GuidToString(aValue));
end;

function TVariantField.GetDefaultWidth: Integer;
begin
  Result := 15;
end;

{ TVariantField }

constructor TVariantField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftVariant);
end;

class procedure TVariantField.CheckTypeSize(aValue: Integer);
begin
  { empty }
end;

function TVariantField.GetAsBoolean: Boolean;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsDateTime: TDateTime;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsFloat: Double;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsInteger: Longint;
begin
  Result := GetAsVariant;
end;

function TVariantField.GetAsString: string;
begin
  Result := VarToStr(GetAsVariant);
end;

function TVariantField.GetAsWideString: WideString;
begin
  Result := VarToWideStr(GetAsVariant);
end;

function TVariantField.GetAsVariant: Variant;
begin
  if not GetData(@Result) then
    Result := Null;
end;

procedure TVariantField.SetAsBoolean(aValue: Boolean);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsDateTime(aValue: TDateTime);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsFloat(aValue: Double);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsInteger(aValue: Longint);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsString(const aValue: string);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetAsWideString(const aValue: WideString);
begin
  SetVarValue(aValue);
end;

procedure TVariantField.SetVarValue(const aValue: Variant);
begin
  SetData(@aValue);
end;

{ TFieldsEnumerator }

function TFieldsEnumerator.GetCurrent: TField;
begin
  Result := FFields[FPosition];
end;

constructor TFieldsEnumerator.Create(AFields: TFields);
begin
  inherited Create;
  FFields := AFields;
  FPosition := -1;
end;

function TFieldsEnumerator.MoveNext: Boolean;
begin
  inc(FPosition);
  Result := FPosition < FFields.Count;
end;

{ TFields }

Constructor TFields.Create(ADataset : TDataset);

begin
  FDataSet:=ADataset;
  FFieldList:=TFpList.Create;
  FValidFieldKinds:=[fkData..fkInternalcalc];
end;

Destructor TFields.Destroy;

begin
  if Assigned(FFieldList) then
    Clear;
  FreeAndNil(FFieldList);
  inherited Destroy;
end;

Procedure Tfields.Changed;

begin
  if (FDataSet <> nil) and not (csDestroying in FDataSet.ComponentState) and FDataset.Active then
    FDataSet.DataEvent(deFieldListChange, 0);
  If Assigned(FOnChange) then
    FOnChange(Self);
end;

Procedure TFields.CheckfieldKind(Fieldkind : TFieldKind; Field : TField);

begin
  If Not (FieldKind in ValidFieldKinds) Then
    DatabaseErrorFmt(SInvalidFieldKind,[Field.FieldName]);
end;

Function Tfields.GetCount : Longint;

begin
  Result:=FFieldList.Count;
end;


Function TFields.GetField (Index : longint) : TField;

begin
  Result:=Tfield(FFieldList[Index]);
end;

procedure Tfields.SetField(Index: Integer; Value: TField);
begin
  Fields[Index].Assign(Value);
end;

Procedure TFields.SetFieldIndex (Field : TField;Value : Integer);

Var Old : Longint;

begin
  Old := FFieldList.indexOf(Field);
  If Old=-1 then
    Exit;
  // Check value
  If Value<0 Then Value:=0;
  If Value>=Count then Value:=Count-1;
  If Value<>Old then
    begin
    FFieldList.Delete(Old);
    FFieldList.Insert(Value,Field);
    Field.PropertyChanged(True);
    Changed;
    end;
end;

Procedure TFields.Add(Field : TField);

begin
  CheckFieldName(Field.FieldName);
  FFieldList.Add(Field);
  Field.FFields:=Self;
  Changed;
end;

Procedure TFields.CheckFieldName (Const Value : String);

begin
  If FindField(Value)<>Nil then
    DataBaseErrorFmt(SDuplicateFieldName,[Value],FDataset);
end;

Procedure TFields.CheckFieldNames (Const Value : String);


Var I : longint;
    S,T : String;
begin
  T:=Value;
  Repeat
    I:=Pos(';',T);
    If I=0 Then I:=Length(T)+1;
    S:=Copy(T,1,I-1);
    Delete(T,1,I);
    // Will raise an error if no such field...
    FieldByName(S);
  Until (T='');
end;

Procedure TFields.Clear;
var
  AField: TField;
begin
  while FFieldList.Count > 0 do 
    begin
    AField := TField(FFieldList.Last);
    AField.FDataSet := Nil;
    AField.Free;
    FFieldList.Delete(FFieldList.Count - 1);
    end;
  Changed;
end;

Function TFields.FindField (Const Value : String) : TField;

Var S : String;
    I : longint;

begin
  Result:=Nil;
  S:=UpperCase(Value);
  For I:=0 To FFieldList.Count-1 do
    If S=UpperCase(TField(FFieldList[i]).FieldName) Then
      Begin
      {$ifdef dsdebug}
      Writeln ('Found field ',Value);
      {$endif}
      Result:=TField(FFieldList[I]);
      Exit;
      end;
end;

Function TFields.FieldByName (Const Value : String) : TField;

begin
  Result:=FindField(Value);
  If result=Nil then
    DatabaseErrorFmt(SFieldNotFound,[Value],FDataset);
end;

Function TFields.FieldByNumber(FieldNo : Integer) : TField;

Var i : Longint;

begin
  Result:=Nil;
  For I:=0 to FFieldList.Count-1 do
    If FieldNo=TField(FFieldList[I]).FieldNo then
      begin
      Result:=TField(FFieldList[i]);
      Exit;
      end;
end;

Function TFields.GetEnumerator: TFieldsEnumerator;

begin
  Result:=TFieldsEnumerator.Create(Self);
end;

Procedure TFields.GetFieldNames (Values : TStrings);

Var i : longint;

begin
  Values.Clear;
  For I:=0 to FFieldList.Count-1 do
    Values.Add(Tfield(FFieldList[I]).FieldName);
end;

Function TFields.IndexOf(Field : TField) : Longint;

begin
  Result:=FFieldList.IndexOf(Field);
end;

procedure TFields.Remove(Value : TField);

begin
  FFieldList.Remove(Value);
  Value.FFields := nil;
  Changed;
end;

