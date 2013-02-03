{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2003 by the Free Pascal development team

    TImageHandlers implementations

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{ TImageHandlersManager }

constructor TImageHandlersManager.Create;
begin
  inherited create;
  FData := Tlist.Create;
end;

destructor TImageHandlersManager.Destroy;
var r : integer;
begin
  for r := FData.count-1 downto 0 do
    TIHData(FData[r]).Free;
  FData.Free;
  inherited Destroy;
end;

function CalcDefExt (TheExtentions:string) : string;
var p : integer;
begin
  p := pos (';',TheExtentions);
  if p = 0 then
    result := TheExtentions
  else
    result := copy(TheExtentions, 1, p-1);
end;

procedure TImageHandlersManager.RegisterImageHandlers (const ATypeName,TheExtentions:string;
                   AReader:TFPCustomImageReaderClass; AWriter:TFPCustomImageWriterClass);
var ih : TIHData;
begin
  ih := GetData (ATypeName);
  if assigned (ih) then
    FPImgError (StrTypeAlreadyExist,[ATypeName]);
  ih := TIHData.Create;
  with ih do
    begin
    FTypeName := ATypeName;
    FExtention := lowercase(TheExtentions);
    FDefaultExt := CalcDefExt (TheExtentions);
    FReader := AReader;
    FWriter := AWriter;
    end;
  FData.Add (ih);
end;

procedure TImageHandlersManager.RegisterImageReader (const ATypeName,TheExtentions:string;
                   AReader:TFPCustomImageReaderClass);
var ih : TIHData;
begin
  ih := GetData (ATypeName);
  if assigned (ih) then
    begin
      if assigned (ih.FReader) then
        FPImgError (StrTypeReaderAlreadyExist,[ATypeName])
      else
        ih.FReader := AReader;
    end
  else
    begin
    ih := TIHData.Create;
    with ih do
      begin
      FTypeName := ATypeName;
      FExtention := Lowercase(TheExtentions);
      FDefaultExt := CalcDefExt (TheExtentions);
      FReader := AReader;
      FWriter := nil;
      end;
    FData.Add (ih);
    end;
end;

procedure TImageHandlersManager.RegisterImageWriter (const ATypeName,TheExtentions:string;
                   AWriter:TFPCustomImageWriterClass);
var ih : TIHData;
begin
  ih := GetData (ATypeName);
  if assigned (ih) then
    begin
    if assigned (ih.FWriter) then
      FPImgError (StrTypeWriterAlreadyExist,[ATypeName])
    else
      ih.FWriter := AWriter;
    end
  else
    begin
    ih := TIHData.Create;
    with ih do
      begin
      FTypeName := ATypeName;
      FExtention := lowercase(TheExtentions);
      FDefaultExt := CalcDefExt (TheExtentions);
      FReader := nil;
      FWriter := AWriter;
      end;
    FData.Add (ih);
    end;
end;

function TImageHandlersManager.GetCount : integer;
begin
  result := FData.Count;
end;

function TImageHandlersManager.GetData (const ATypeName:string) : TIHData;
var r : integer;
begin
  r := FData.count;
  repeat
    dec (r);
  until (r < 0) or (compareText (TIHData(FData[r]).FTypeName, ATypeName) = 0);
  if r >= 0 then
    result := TIHData(FData[r])
  else
    result := nil;
end;

function TImageHandlersManager.GetData (index:integer) : TIHData;
begin
  if (index >= 0) and (index < FData.count) then
    result := TIHData (FData[index])
  else
    result := nil;
end;

function TImageHandlersManager.GetTypeName (index:integer) : string;
var ih : TIHData;
begin
  ih := TIHData (FData[index]);
  result := ih.FTypeName;
end;

function TImageHandlersManager.GetReader (const TypeName:string) : TFPCustomImageReaderClass;
var ih : TIHData;
begin
  ih := GetData (TypeName);
  if assigned(ih) then
    result := ih.FReader
  else
    result := nil;
end;

function TImageHandlersManager.GetWriter (const TypeName:string) : TFPCustomImageWriterClass;
var ih : TIHData;
begin
  ih := GetData (TypeName);
  if assigned(ih) then
    result := ih.FWriter
  else
    result := nil;
end;

function TImageHandlersManager.GetExt (const TypeName:string) : string;
var ih : TIHData;
begin
  ih := GetData (TypeName);
  if assigned(ih) then
    result := ih.FExtention
  else
    result := '';
end;

function TImageHandlersManager.GetDefExt (const TypeName:string) : string;
var ih : TIHData;
begin
  ih := GetData (TypeName);
  if assigned(ih) then
    result := ih.FDefaultExt
  else
    result := '';
end;

{ TFPCustomImageHandler }

constructor TFPCustomImageHandler.create;
begin
  inherited create;
end;

procedure TFPCustomImageHandler.Progress(Stage: TProgressStage;
                         PercentDone: Byte;  RedrawNow: Boolean; const R: TRect;
                         const Msg: AnsiString; var Continue: Boolean);

begin
  If Assigned(FOnProgress) then
    FOnProgress(Self,Stage,PercentDone,RedrawNow,R,Msg,Continue)
  else If Assigned(FImage) then
    // It is debatable whether we should pass ourselves or the image ?
    FImage.Progress(Self,Stage,PercentDone,RedrawNow,R,Msg,Continue);
end;

{ TFPCustomImageReader }

constructor TFPCustomImageReader.Create;
begin
  inherited create;
  FDefImageClass := TFPMemoryImage;
end;

function TFPCustomImageReader.ImageRead (Str:TStream; Img:TFPCustomImage) : TFPCustomImage;
begin
  try
    if not assigned(Str) then
      raise FPImageException.Create(ErrorText[StrNoStream]);
    FStream := Str;
    if not assigned(img) then
      result := FDefImageClass.Create(0,0)
    else
      result := Img;
    FImage := result;
    if FImage.UsePalette then
      FImage.Palette.Clear;
    if CheckContents (Str) then
      begin
      InternalRead (Str, result)
      end
    else
      raise FPImageException.Create ('Wrong image format');
  finally
    FStream := nil;
    FImage := nil;
  end;
end;

function TFPCustomImageReader.CheckContents (Str:TStream) : boolean;
var InRead : boolean;
begin
  InRead := assigned(FStream);
  if not assigned(Str) then
    raise FPImageException.Create(ErrorText[StrNoStream]);
  try
    FSTream := Str;
    result := InternalCheck (Str);
  finally
    if not InRead then
      FStream := nil;
  end;
end;

{ TFPCustomImageWriter }

procedure TFPCustomImageWriter.ImageWrite (Str:TStream; Img:TFPCustomImage);
begin
  if not assigned(img) then
    raise FPImageException.Create(ErrorText[StrNoImageToWrite]);
  if not assigned(Str) then
    raise FPImageException.Create(ErrorText[StrNoStream]);
  try
    FStream := str;
    FImage := img;
    Str.position := 0;
    Str.Size := 0;
    InternalWrite(Str, Img);
  finally
    FStream := nil;
    FImage := nil;
  end;
end;


