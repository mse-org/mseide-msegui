{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2000 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{****************************************************************************}
{*                         TBinaryObjectWriter                              *}
{****************************************************************************}

constructor TBinaryObjectWriter.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EWriteError.Create(SEmptyStreamIllegalWriter);
  FStream := Stream;
  FBufSize := BufSize;
  GetMem(FBuffer, BufSize);
end;

destructor TBinaryObjectWriter.Destroy;
begin
  // Flush all data which hasn't been written yet
  FlushBuffer;

  if Assigned(FBuffer) then
    FreeMem(FBuffer, FBufSize);

  inherited Destroy;
end;

procedure TBinaryObjectWriter.BeginCollection;
begin
  WriteValue(vaCollection);
end;

procedure TBinaryObjectWriter.BeginComponent(Component: TComponent;
  Flags: TFilerFlags; ChildPos: Integer);
var
  Prefix: Byte;
begin
  if not FSignatureWritten then
  begin
    Write(FilerSignature, SizeOf(FilerSignature));
    FSignatureWritten := True;
  end;

  { Only write the flags if they are needed! }
  if Flags <> [] then
  begin
    Prefix := Integer(Flags) or $f0;
    Write(Prefix, 1);
    if ffChildPos in Flags then
      WriteInteger(ChildPos);
  end;

  WriteStr(Component.ClassName);
  WriteStr(Component.Name);
end;

procedure TBinaryObjectWriter.BeginList;
begin
  WriteValue(vaList);
end;

procedure TBinaryObjectWriter.EndList;
begin
  WriteValue(vaNull);
end;

procedure TBinaryObjectWriter.BeginProperty(const PropName: String);
begin
  WriteStr(PropName);
end;

procedure TBinaryObjectWriter.EndProperty;
begin
end;

procedure TBinaryObjectWriter.WriteBinary(const Buffer; Count: LongInt);
begin
  WriteValue(vaBinary);
  Write(Count, 4);
  Write(Buffer, Count);
end;

procedure TBinaryObjectWriter.WriteBoolean(Value: Boolean);
begin
  if Value then
    WriteValue(vaTrue)
  else
    WriteValue(vaFalse);
end;

procedure TBinaryObjectWriter.WriteFloat(const Value: Extended);
begin
  WriteValue(vaExtended);
  Write(Value, SizeOf(Value));
end;

procedure TBinaryObjectWriter.WriteSingle(const Value: Single);
begin
  WriteValue(vaSingle);
  Write(Value, SizeOf(Value));
end;

procedure TBinaryObjectWriter.WriteCurrency(const Value: Currency);
begin
  WriteValue(vaCurrency);
  Write(Value, SizeOf(Value));
end;


procedure TBinaryObjectWriter.WriteDate(const Value: TDateTime);
begin
  WriteValue(vaDate);
  Write(Value, SizeOf(Value));
end;

procedure TBinaryObjectWriter.WriteIdent(const Ident: string);
begin
  { Check if Ident is a special identifier before trying to just write
    Ident directly }
  if UpperCase(Ident) = 'NIL' then
    WriteValue(vaNil)
  else if UpperCase(Ident) = 'FALSE' then
    WriteValue(vaFalse)
  else if UpperCase(Ident) = 'TRUE' then
    WriteValue(vaTrue)
  else if UpperCase(Ident) = 'NULL' then
    WriteValue(vaNull) else
  begin
    WriteValue(vaIdent);
    WriteStr(Ident);
  end;
end;

procedure TBinaryObjectWriter.WriteInteger(Value: Int64);
var
  s: ShortInt;
  i: SmallInt;
  l: Longint;
begin
  { Use the smallest possible integer type for the given value: }
  if (Value >= -128) and (Value <= 127) then
  begin
    WriteValue(vaInt8);
    s := Value;
    Write(s, 1);
  end else if (Value >= -32768) and (Value <= 32767) then
  begin
    WriteValue(vaInt16);
    i := Value;
    Write(i, 2);
  end else if (Value >= -$80000000) and (Value <= $7fffffff) then
  begin
    WriteValue(vaInt32);
    l := Value;
    Write(l, 4);
  end else
  begin
    WriteValue(vaInt64);
    Write(Value, 8);
  end;
end;

procedure TBinaryObjectWriter.WriteMethodName(const Name: String);
begin
  if Length(Name) > 0 then
  begin
    WriteValue(vaIdent);
    WriteStr(Name);
  end else
    WriteValue(vaNil);
end;

procedure TBinaryObjectWriter.WriteSet(Value: LongInt; SetType: Pointer);
var
  i: Integer;
  Mask: LongInt;
begin
  WriteValue(vaSet);
  Mask := 1;
  for i := 0 to 31 do
  begin
    if (Value and Mask) <> 0 then
      WriteStr(GetEnumName(PTypeInfo(SetType), i));
    Mask := Mask shl 1;
  end;
  WriteStr('');
end;

procedure TBinaryObjectWriter.WriteString(const Value: String);
var
  i: Integer;
  b: byte;
begin
  i := Length(Value);
  if i <= 255 then
  begin
    WriteValue(vaString);
    b := i;
    Write(b, 1);
  end else
  begin
    WriteValue(vaLString);
    Write(i, 4);
  end;
  if i > 0 then
    Write(Value[1], i);
end;

procedure TBinaryObjectWriter.WriteWideString(const Value: WideString);
var
  i: Integer;
begin
  WriteValue(vaWString);
  i := Length(Value);
  Write(i, 4);
  Write(Pointer(Value)^, i * 2);
end;

procedure TBinaryObjectWriter.FlushBuffer;
begin
  FStream.WriteBuffer(FBuffer^, FBufPos);
  FBufPos := 0;
end;

procedure TBinaryObjectWriter.Write(const Buffer; Count: LongInt);
var
  CopyNow: LongInt;
  SourceBuf: PChar;
begin
  SourceBuf:=@Buffer;
  while Count > 0 do
  begin
    CopyNow := Count;
    if CopyNow > FBufSize - FBufPos then
      CopyNow := FBufSize - FBufPos;
    Move(SourceBuf^, PChar(FBuffer)[FBufPos], CopyNow);
    Dec(Count, CopyNow);
    Inc(FBufPos, CopyNow);
    inc(SourceBuf, CopyNow);
    if FBufPos = FBufSize then
      FlushBuffer;
  end;
end;

procedure TBinaryObjectWriter.WriteValue(Value: TValueType);
var
  b: byte;
begin
  b := byte(Value);
  Write(b, 1);
end;

procedure TBinaryObjectWriter.WriteStr(const Value: String);
var
  i: integer;
  b: byte;
begin
  i := Length(Value);
  if i > 255 then
    i := 255;
  b := i;
  Write(b, 1);
  if i > 0 then
    Write(Value[1], i);
end;



{****************************************************************************}
{*                             TWriter                                      *}
{****************************************************************************}


constructor TWriter.Create(ADriver: TAbstractObjectWriter);
begin
  inherited Create;
  FDriver := ADriver;
end;

constructor TWriter.Create(Stream: TStream; BufSize: Integer);
begin
  inherited Create;
  If (Stream=Nil) then
    Raise EWriteError.Create(SEmptyStreamIllegalWriter);
  FDriver := CreateDriver(Stream, BufSize);
  FDestroyDriver := True;
end;

destructor TWriter.Destroy;
begin
  if FDestroyDriver then
    FDriver.Free;
  inherited Destroy;
end;

function TWriter.CreateDriver(Stream: TStream; BufSize: Integer): TAbstractObjectWriter;
begin
  Result := TBinaryObjectWriter.Create(Stream, BufSize);
end;

// Used as argument for calls to TComponent.GetChildren:
procedure TWriter.AddToAncestorList(Component: TComponent);
begin
  FAncestorList.Add(Component);
end;

procedure TWriter.DefineProperty(const Name: String;
  ReadData: TReaderProc; AWriteData: TWriterProc; HasData: Boolean);
begin
  if HasData and Assigned(AWriteData) then
  begin
    // Write the property name and then the data itself
    Driver.BeginProperty(FPropPath + Name);
    AWriteData(Self);
    Driver.EndProperty;
  end;
end;

procedure TWriter.DefineBinaryProperty(const Name: String;
  ReadData, AWriteData: TStreamProc; HasData: Boolean);
begin
  if HasData and Assigned(AWriteData) then
  begin
    // Write the property name and then the data itself
    Driver.BeginProperty(FPropPath + Name);
    WriteBinary(AWriteData);
    Driver.EndProperty;
  end;
end;

procedure TWriter.SetRoot(ARoot: TComponent);
begin
  inherited SetRoot(ARoot);
  // Use the new root as lookup root too
  FLookupRoot := ARoot;
end;

procedure TWriter.WriteBinary(AWriteData: TStreamProc);
var
  MemBuffer: TMemoryStream;
  BufferSize: Longint;
begin
  { First write the binary data into a memory stream, then copy this buffered
    stream into the writing destination. This is necessary as we have to know
    the size of the binary data in advance (we're assuming that seeking within
    the writer stream is not possible) }
  MemBuffer := TMemoryStream.Create;
  try
    AWriteData(MemBuffer);
    BufferSize := MemBuffer.Size;
    Driver.WriteBinary(MemBuffer.Memory^, BufferSize);
  finally
    MemBuffer.Free;
  end;
end;

procedure TWriter.WriteBoolean(Value: Boolean);
begin
  Driver.WriteBoolean(Value);
end;

procedure TWriter.WriteChar(Value: Char);
begin
  WriteString(Value);
end;

procedure TWriter.WriteCollection(Value: TCollection);
var
  i: Integer;
begin
  Driver.BeginCollection;
  if Assigned(Value) then
    for i := 0 to Value.Count - 1 do
    begin
      { Each collection item needs its own ListBegin/ListEnd tag, or else the
        reader wouldn't be able to know where an item ends and where the next
        one starts }
      WriteListBegin;
      WriteProperties(Value.Items[i]);
      WriteListEnd;
    end;
  WriteListEnd;
end;

procedure TWriter.WriteComponent(Component: TComponent);
var
  SavedAncestor: TPersistent;
  SavedRootAncestor, AncestorComponent, CurAncestor: TComponent;
  i: Integer;
  s: String;
begin
  SavedAncestor := Ancestor;
  SavedRootAncestor := RootAncestor;

  try
    // The component has to know that it is being written now...
    Include(Component.FComponentState, csWriting);

    // Locate the component in the ancestor list, if necessary
    if Assigned(FAncestorList) then
    begin
      Ancestor := nil;
      s := UpperCase(Component.Name);
      for i := 0 to FAncestorList.Count - 1 do
      begin
        CurAncestor := TComponent(FAncestorList[i]);
        if UpperCase(CurAncestor.Name) = s then
        begin
          Ancestor := CurAncestor;
          break;
        end;
      end;
    end;

    // Do we have to call the OnFindAncestor callback?
    if Assigned(FOnFindAncestor) and
      ((not Assigned(Ancestor)) or Ancestor.InheritsFrom(TComponent)) then
    begin
      AncestorComponent := TComponent(Ancestor);
      FOnFindAncestor(Self, Component, Component.Name,
        AncestorComponent, FRootAncestor);
      Ancestor := AncestorComponent;
    end;

    // Finally write the component state
    Component.WriteState(Self);

    // The writing has been finished now...
    Exclude(Component.FComponentState, csWriting);

  finally
    Ancestor := SavedAncestor;
    FRootAncestor := SavedRootAncestor;
  end;
end;

procedure TWriter.WriteComponentData(Instance: TComponent);
var
  SavedAncestorList: TList;
  SavedRoot, SavedRootAncestor: TComponent;
  SavedAncestorPos, SavedChildPos: Integer;
  Flags: TFilerFlags;
begin
  // Determine the filer flags to store
  if Assigned(Ancestor) and ((not (csInline in Instance.ComponentState)) or
    ((csAncestor in Instance.ComponentState) and Assigned(FAncestorList))) then
    Flags := [ffInherited]
  else if csInline in Instance.ComponentState then
    Flags := [ffInline]
  else
    Flags := [];

  if Assigned(FAncestorList) and (FAncestorPos < FAncestorList.Count) and
    ((not Assigned(Ancestor)) or
    (TPersistent(FAncestorList[FAncestorPos]) <> Ancestor)) then
    Include(Flags, ffChildPos);

  Driver.BeginComponent(Instance, Flags, FChildPos);

  if Assigned(FAncestorList) and (FAncestorPos < FAncestorList.Count) then
  begin
    if Assigned(Ancestor) then
      Inc(FAncestorPos);
    Inc(FChildPos);
  end;

  // Write property list
  WriteProperties(Instance);
  WriteListEnd;

  // Write children list
  SavedAncestorList := FAncestorList;
  SavedAncestorPos := FAncestorPos;
  SavedChildPos := FChildPos;
  SavedRoot := FRoot;
  SavedRootAncestor := FRootAncestor;
  try
    FAncestorList := nil;
    FAncestorPos := 0;
    FChildPos := 0;
    if not IgnoreChildren then
      try
        // Set up the ancestor list if we have an ancestor
        if FAncestor is TComponent then
        begin
          if csInline in TComponent(FAncestor).ComponentState then
            FRootAncestor := TComponent(FAncestor);
          FAncestorList := TList.Create;
          TComponent(FAncestor).GetChildren(@AddToAncestorList, FRootAncestor);
        end;

        if csInline in Instance.ComponentState then
          FRoot := Instance;

        Instance.GetChildren(@WriteComponent, FRoot);

      finally
        FAncestorList.Free;
      end;

  finally
    FAncestorList := SavedAncestorList;
    FAncestorPos := SavedAncestorPos;
    FChildPos := SavedChildPos;
    FRoot := SavedRoot;
    FRootAncestor := SavedRootAncestor;
  end;

  WriteListEnd;
end;

procedure TWriter.WriteDescendent(ARoot: TComponent; AAncestor: TComponent);
begin
  FRoot := ARoot;
  FAncestor := AAncestor;
  FRootAncestor := AAncestor;
  FLookupRoot := ARoot;

  WriteComponent(ARoot);
end;

procedure TWriter.WriteFloat(const Value: Extended);
begin
  Driver.WriteFloat(Value);
end;

procedure TWriter.WriteSingle(const Value: Single);
begin
  Driver.WriteSingle(Value);
end;

procedure TWriter.WriteCurrency(const Value: Currency);
begin
  Driver.WriteCurrency(Value);
end;

procedure TWriter.WriteDate(const Value: TDateTime);
begin
  Driver.WriteDate(Value);
end;

procedure TWriter.WriteIdent(const Ident: string);
begin
  Driver.WriteIdent(Ident);
end;

procedure TWriter.WriteInteger(Value: LongInt);
begin
  Driver.WriteInteger(Value);
end;

procedure TWriter.WriteInteger(Value: Int64);
begin
  Driver.WriteInteger(Value);
end;

procedure TWriter.WriteListBegin;
begin
  Driver.BeginList;
end;

procedure TWriter.WriteListEnd;
begin
  Driver.EndList;
end;

procedure TWriter.WriteProperties(Instance: TPersistent);
var
  i, PropCount: Integer;
  PropInfo: PPropInfo;
  PropList: PPropList;
begin
  { First step: Write the properties given by the RTTI for Instance }
  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount > 0 then
  begin
    GetMem(PropList, PropCount * SizeOf(PPropInfo));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for i := 0 to PropCount - 1 do
      begin
        PropInfo := PropList^[i];
        if IsStoredProp(Instance, PropInfo) then
          WriteProperty(Instance, PropInfo);
      end;
    finally
      FreeMem(PropList);
    end;
  end;

  { Second step: Give Instance the chance to write its own private data }
  Instance.DefineProperties(Self);
end;

procedure TWriter.WriteProperty(Instance: TPersistent; PropInfo: Pointer);
var
  HasAncestor: Boolean;
  PropType: PTypeInfo;
  Value, DefValue: LongInt;
  Ident: String;
  IntToIdentFn: TIntToIdent;
  FloatValue, DefFloatValue: Extended;
  MethodValue: TMethod;
  DefMethodCodeValue: Pointer;
  WStrValue, WDefStrValue: WideString;
  StrValue, DefStrValue: String;
  AncestorObj: TObject;
  Component: TComponent;
  ObjValue: TObject;
  SavedAncestor: TPersistent;
  SavedPropPath, Name: String;
  Int64Value, DefInt64Value: Int64;
  BoolValue, DefBoolValue: boolean;
  Handled: Boolean;

begin

  if (not Assigned(PPropInfo(PropInfo)^.SetProc)) or
    (not Assigned(PPropInfo(PropInfo)^.GetProc)) then
    exit;

  { Check if the ancestor can be used }
  HasAncestor := Assigned(Ancestor) and ((Instance = Root) or
    (Instance.ClassType = Ancestor.ClassType));

  PropType := PPropInfo(PropInfo)^.PropType;
  case PropType^.Kind of
    tkInteger, tkChar, tkEnumeration, tkSet:
      begin
        Value := GetOrdProp(Instance, PropInfo);
        if HasAncestor then
          DefValue := GetOrdProp(Ancestor, PropInfo)
        else
          DefValue := PPropInfo(PropInfo)^.Default;
        if (Value <> DefValue) or (DefValue=longint($80000000)) then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          case PropType^.Kind of
            tkInteger:
              begin
                // Check if this integer has a string identifier
                IntToIdentFn := FindIntToIdent(PPropInfo(PropInfo)^.PropType);
                if Assigned(IntToIdentFn) and IntToIdentFn(Value, Ident) then
                  // Integer can be written a human-readable identifier
                  WriteIdent(Ident)
                else
                  // Integer has to be written just as number
                  WriteInteger(Value);
              end;
            tkChar:
              WriteChar(Chr(Value));
            tkSet:
              Driver.WriteSet(Value, GetTypeData(PropType)^.CompType);
            tkEnumeration:
              WriteIdent(GetEnumName(PropType, Value));
          end;
          Driver.EndProperty;
        end;
      end;
    tkFloat:
      begin
        FloatValue := GetFloatProp(Instance, PropInfo);
        if HasAncestor then
          DefFloatValue := GetFloatProp(Ancestor, PropInfo)
        else
          DefFloatValue := 0;
        if FloatValue <> DefFloatValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteFloat(FloatValue);
          Driver.EndProperty;
        end;
      end;
    tkMethod:
      begin
        MethodValue := GetMethodProp(Instance, PropInfo);
        if HasAncestor then
          DefMethodCodeValue := GetMethodProp(Ancestor, PropInfo).Code
        else
          DefMethodCodeValue := nil;

        Handled:=false;
        if Assigned(OnWriteMethodProperty) then
          OnWriteMethodProperty(Self,Instance,PPropInfo(PropInfo),MethodValue,
            DefMethodCodeValue,Handled);
        if (not Handled) and
          (MethodValue.Code <> DefMethodCodeValue) and
          ((not Assigned(MethodValue.Code)) or
          ((Length(FLookupRoot.MethodName(MethodValue.Code)) >= 0))) then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          if Assigned(MethodValue.Code) then
            Driver.WriteMethodName(FLookupRoot.MethodName(MethodValue.Code))
          else
            Driver.WriteMethodName('');
          Driver.EndProperty;
        end;
      end;
    tkSString, tkLString, tkAString:
      begin
        StrValue := GetStrProp(Instance, PropInfo);
        if HasAncestor then
          DefStrValue := GetStrProp(Ancestor, PropInfo)
        else
          SetLength(DefStrValue, 0);

        if StrValue <> DefStrValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          if Assigned(FOnWriteStringProperty) then
            FOnWriteStringProperty(Self,Instance,PropInfo,StrValue);
          WriteString(StrValue);
          Driver.EndProperty;
        end;
      end;
    tkWString:
      begin
        WStrValue := GetWideStrProp(Instance, PropInfo);
        if HasAncestor then
          WDefStrValue := GetWideStrProp(Ancestor, PropInfo)
        else
          SetLength(WDefStrValue, 0);

        if WStrValue <> WDefStrValue then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteWideString(WStrValue);
          Driver.EndProperty;
        end;
      end;
  {!!!: tkVariant:}
    tkClass:
      begin
        ObjValue := TObject(GetObjectProp(Instance, PropInfo));
        if HasAncestor then
        begin
          AncestorObj := TObject(GetObjectProp(Ancestor, PropInfo));
          if Assigned(AncestorObj) then
            if Assigned(ObjValue) and
              (TComponent(AncestorObj).Owner = FRootAncestor) and
              (TComponent(ObjValue).Owner = Root) and
              (UpperCase(TComponent(AncestorObj).Name) = UpperCase(TComponent(ObjValue).Name)) then
              AncestorObj := ObjValue
//            else
//              AncestorObj := nil;
        end else
          AncestorObj := nil;

        if not Assigned(ObjValue) then
        begin
          if ObjValue <> AncestorObj then
          begin
            Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
            Driver.WriteIdent('NIL');
            Driver.EndProperty;
          end
        end else if ObjValue.InheritsFrom(TPersistent) then
          { Subcomponents are streamed the same way as persistents }
          if ObjValue.InheritsFrom(TComponent)
          and not (csSubComponent in TComponent(ObjValue).ComponentStyle) then
          begin
            Component := TComponent(ObjValue);
            if (ObjValue <> AncestorObj)
            and not (csTransient in Component.ComponentStyle) then
            begin
              { Determine the correct name of the component this property contains }
              if Component.Owner = LookupRoot then
                Name := Component.Name
              else if Component = LookupRoot then
                Name := 'Owner'
              else if Assigned(Component.Owner) and (Length(Component.Owner.Name) > 0)
                and (Length(Component.Name) > 0) then
                Name := Component.Owner.Name + '.' + Component.Name
              else if Length(Component.Name) > 0 then
                Name := Component.Name + '.Owner'
              else
                SetLength(Name, 0);

              if Length(Name) > 0 then
              begin
                Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
                WriteIdent(Name);
                Driver.EndProperty;
              end;
            end;
          end else if ObjValue.InheritsFrom(TCollection) then
          begin
            if (not HasAncestor) or (not CollectionsEqual(TCollection(ObjValue),
              TCollection(GetObjectProp(Ancestor, PropInfo)))) then
            begin
              Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
              SavedPropPath := FPropPath;
              try
                SetLength(FPropPath, 0);
                WriteCollection(TCollection(ObjValue));
              finally
                FPropPath := SavedPropPath;
                Driver.EndProperty;
              end;
            end;
          end else
          begin
            SavedAncestor := Ancestor;
            SavedPropPath := FPropPath;
            try
              FPropPath := FPropPath + PPropInfo(PropInfo)^.Name + '.';
              if HasAncestor then
                Ancestor := TPersistent(GetObjectProp(Ancestor, PropInfo));
              WriteProperties(TPersistent(ObjValue));
            finally
              Ancestor := SavedAncestor;
              FPropPath := SavedPropPath;
            end;
          end;
      end;
    tkInt64, tkQWord:
      begin
        Int64Value := GetInt64Prop(Instance, PropInfo);
        if HasAncestor then
          DefInt64Value := GetInt64Prop(Ancestor, PropInfo)
        else
          DefInt64Value := 0;
        if Int64Value <> DefInt64Value then
        begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteInteger(Int64Value);
          Driver.EndProperty;
        end;
      end;
    tkBool:
      begin
        BoolValue := GetOrdProp(Instance, PropInfo)<>0;
        if HasAncestor then
          DefBoolValue := GetOrdProp(Ancestor, PropInfo)<>0
        else
          DefBoolValue := PPropInfo(PropInfo)^.Default<>0;
        if BoolValue <> DefBoolValue then
          begin
          Driver.BeginProperty(FPropPath + PPropInfo(PropInfo)^.Name);
          WriteBoolean(BoolValue);
          Driver.EndProperty;
          end;
      end;
  end;
end;

procedure TWriter.WriteRootComponent(ARoot: TComponent);
begin
  WriteDescendent(ARoot, nil);
end;

procedure TWriter.WriteString(const Value: String);
begin
  Driver.WriteString(Value);
end;

procedure TWriter.WriteWideString(const Value: WideString);
begin
  Driver.WriteWideString(Value);
end;

