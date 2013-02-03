unit SdfData;

{$mode objfpc}
{$h+}

//-----------------------------------------------------------------------------
{ Unit Name  : SdfData  Application : TSdfDataSet TFixedFormatDataSet Components
  Version    : 2.05
  Author     : Orlando Arrocha           email: oarrocha@hotmail.com
  Purpose    : This components are designed to access directly text files as
               database tables. The files may be limited (SDF) or fixed size
               columns.
---------------
Modifications
---------------
7/Jun/12 BigChimp:
      Quote fields with delimiters or quotes to match Delphi SDF definition
      (see e.g. help on TStrings.CommaText)
14/Jul/11 BigChimp:
      Added AllowMultiLine property so user can use fields that have line endings
      (Carriage Return and/or Line Feed) embedded in their fields (fields need to be
      quoted). For now: output only (reading these fields does not work yet)
12/Mar/04  Lazarus version (Sergey Smirnov AKA SSY)
      Locate and CheckString functions are removed because of Variant data type.
      Many things are changed for FPC/Lazarus compatibility.
02/Jun/02  Version 2.05 (Doriano Biondelli)
      TrimSpace property added for those cases where you need to retrieve the
      field with spaces.
01/Jan/02  Version 2.04 (Orlando Arrocha)
      FieldList is now populated.
      Locate was changed to improve speed and some bug fixing too. Thanks for
         asking and testing Marcelo Castro
16/Dec/01  Version 2.03 (Orlando Arrocha)
           Fixed some bugs and added some recomentdations. Here is a list:
      Quotations on the last field was not removed properly. Special thanks to
         Daniel Nakasone for helping with the solution.
      Appending first record to empty files was failing. Thanks again Daniel
         Nakasone for the report
      GetFieldData now trims the trailing spaces of the field, so users doesn't
         needs to do it by themselves anymore. Thanks for the recomendation
         Juergen Gehrke.
      FieldDefs is now available from the designer. Recomended by Leslie Drewery.
                ****** THANKS TO ALL & KEEP SENDING RECOMENDATIONS *****
05/Oct/01  Version 2.02 (Ben Hay)
      Locate function : implement the virtual tdataset method "Locate".
                ****** THANKS BEN *****
11/Sep/01  Version 2.01 (Leslie Drewery)
           Added additional logic to handle Corrupt Data by making sure the
           Quotes are closed and the delimiter/<CR>/<LF> are the next
           characters.
           Altered buffer method to create on constructor and cleared when opened.
      New Resource File. Nice Icons
      SavetoStream method included
      LoadFromStream method included
                ****** THANKS LESLIE *****
14/Ago/01  Version 2.00 (Orlando Arrocha)
           John Dung Nguyen showed me how to make this compatible with C-Builder
           and encouraged me to include a filter.
           Dimitry V. Borko says that russian CSV files used other delimiters,
           so now you can change it.
      OnFilter and other events included.
      Delimiter property added to TSdfDataSet. No more dependency on CommaText
         methodology -- choose your own delimiter.
      BufToStore/StoreToBuf methods lets you translate data records to and from
         your propietary storage format.
      TTextDataSet removed dependencies.
      TBaseTextDataSet class removed. // TBaseTextDataSet = TFixedFormatDataSet;
                ****** THANKS JOHN ******   ***** THANKS DIMMY *****
19/Jul/01  Version 1.03 (Orlando Arrocha)
      TBaseTextDataSet class introduced.
      FileName property changed datatype to TFileName and removed the property
         editor to segregate design-time code from runtime units.
      *** To add file browsing functionality please install
      *** TFileNamePropertyEditor -- also freeware.
                                     ********** THANKS WAYNE *********
18/Jun/01  Version 1.02 (Wayne Brantley)
      Schema replaces SchemaFileName property. Same as SchemaFileName, except
         you can define the schema inside the component. If you still need an
         external file, just use Schema.LoadFromFile()
      TFixedFormatDataSet class introduced. Use this class for a Fixed length
         format file (instead of delimited). The full schema definition
         (including lengths) is obviously required.
      Bug Fixed - When FirstLineSchema is true and there were no records, it
         would display garbage.

30/Mar/01  Version 1.01 (Orlando Arrocha)
           Ligia Maria Pimentel suggested to use the first line of the file to
           define the field names.  ****** THANKS LIGIA ******
      FileMustExist property. You must put this property to FALSE if you want to
         create a new file.
      FirstLineSchema property. You can define the field names on the first line
         of your file. Fields have to be defined with this format
            <field_name1> [= field_size1] , <field_name2> [= field_size2] ...
      SchemaFileName property.  (Changed to Schema by 1.02 Wayne)
         Lets you define the fields attributes (only supports field name and
         size). Have to be defined in this format (one field per line) :
            <field_name> [= field_size]
         NOTE: fields that doesn't define the length get the record size.
      RemoveBlankRecords procedure. Removes all the blank records from the file.
      RemoveExtraColumns procedure. If the file have more columns than the
         scheme or the field definition at design time, it remove the extra
         values from the file.
      SaveFileAs. Let you save the file to another filename.
         NOTE: This component save changes on closing the table, so you can use
               this to save data before that event.
Jan 2001 Version 1.0 TSdfDataSet introduced.
---------
TERMS
---------
 This component is provided AS-IS without any warranty of any kind, either
 express or implied. This component is freeware and can be used in any software
 product. Credits on applications will be welcomed.
 If you find it useful, improve it or have a wish list... please drop me a mail,
 I'll be glad to hear your comments.
----------------
How to Install
----------------
 1. Copy this SDFDATA.PAS and the associated SDFDATA.DCR to the folder from
    where you wish to install the component. This will probably be $(DELPHI)\lib
    or a sub-folder.
 2. Install the TSdfDataSet and TFixedFormatDataSet components by choosing the
    Component | Install Component menu option.
 3. Select the "Into exisiting package" page of the Install Components dialogue.
 4. Browse to the folder where you saved this file and select it.
 5. Ensure that the "Package file name" edit box contains $(DELPHI)\DCLUSR??.DPK
    or the one you prefer for DB related objects.
 6. Accept that the package will be rebuilt.
}
//-----------------------------------------------------------------------------
interface

uses
  DB, Classes, SysUtils, DBConst;

type
//-----------------------------------------------------------------------------
// TRecInfo
  PRecInfo = ^TRecInfo;
  TRecInfo = packed record
    RecordNumber: PtrInt;
    BookmarkFlag: TBookmarkFlag;
  end;
//-----------------------------------------------------------------------------
// TBaseTextDataSet
  TFixedFormatDataSet = class(TDataSet)
  private
    FSchema             :TStringList;
    FFileName           :TFileName;
    FFilterBuffer       :TRecordBuffer;
    FFileMustExist      :Boolean;
    FReadOnly           :Boolean;
    FLoadfromStream     :Boolean;
    FTrimSpace          :Boolean;
    procedure SetSchema(const Value: TStringList);
    procedure SetFileName(Value : TFileName);
    procedure SetFileMustExist(Value : Boolean);
    procedure SetTrimSpace(Value : Boolean);
    procedure SetReadOnly(Value : Boolean);
    procedure RemoveWhiteLines(List : TStrings; IsFileRecord : Boolean);
    procedure LoadFieldScheme(List : TStrings; MaxSize : Integer);
    function GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
    procedure SetFieldPos(var Buffer : TRecordBuffer; FieldNo : Integer);
  protected
    FData               :TStringlist;
    FCurRec             :Integer;
    FRecBufSize         :Integer;
    FRecordSize         :Integer;
    FLastBookmark       :PtrInt;
    FRecInfoOfs         :Integer;
    FBookmarkOfs        :Integer;
    FSaveChanges        :Boolean;
    FDefaultRecordLength:Cardinal;
    FDataOffset         : Integer;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalAddRecord(Buffer: Pointer; DoAppend: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalEdit; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    procedure ClearCalcFields(Buffer: TRecordBuffer); override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    function GetCanModify: boolean; override;
    function TxtGetRecord(Buffer : TRecordBuffer; GetMode: TGetMode): TGetResult;
    function RecordFilter(RecBuf: Pointer; ARecNo: Integer): Boolean;
    function BufToStore(Buffer: TRecordBuffer): String; virtual;
    function StoreToBuf(Source: String): String; virtual;
  public
    property DefaultRecordLength: Cardinal read FDefaultRecordLength
      write FDefaultRecordLength default 250;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function  GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    procedure RemoveBlankRecords; dynamic;
    procedure RemoveExtraColumns; dynamic;
    procedure SaveFileAs(strFileName : String); dynamic;
    property  CanModify;
    procedure LoadFromStream(Stream :TStream);
    procedure SavetoStream(Stream :TStream);
  published
    property FileMustExist: Boolean read FFileMustExist write SetFileMustExist;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property FileName : TFileName read FFileName write SetFileName;
    property Schema: TStringList read FSchema write SetSchema;
    property TrimSpace: Boolean read FTrimSpace write SetTrimSpace default True;
    property FieldDefs;
    property Active;
    property AutoCalcFields;
    property Filtered;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
//    property BeforeRefresh;
//    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

//-----------------------------------------------------------------------------
// TSdfDataSet
  TSdfDataSet = class(TFixedFormatDataSet)
  private
    FDelimiter : Char;
    FFirstLineAsSchema : Boolean;
    FFMultiLine         :Boolean;
    procedure SetMultiLine(const Value: Boolean);
    procedure SetFirstLineAsSchema(Value : Boolean);
    procedure SetDelimiter(Value : Char);
  protected
    procedure InternalInitFieldDefs; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean)
             : TGetResult; override;
    function BufToStore(Buffer: TRecordBuffer): String; override;
    function StoreToBuf(Source: String): String; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AllowMultiLine: Boolean read FFMultiLine write SetMultiLine default True; //Whether or not to allow fields containing CR and/or LF
    property Delimiter: Char read FDelimiter write SetDelimiter;
    property FirstLineAsSchema: Boolean read FFirstLineAsSchema write SetFirstLineAsSchema;
  end;
procedure Register;

implementation
//{$R *.Res}

//-----------------------------------------------------------------------------
// TFixedFormatDataSet
//-----------------------------------------------------------------------------
constructor TFixedFormatDataSet.Create(AOwner : TComponent);
begin
  FDefaultRecordLength := 250;
  FFileMustExist  := TRUE;
  FLoadfromStream := False;
  FRecordSize   := 0;
  FTrimSpace     := TRUE;
  FSchema       := TStringList.Create;
  FData         := TStringList.Create;  // Load the textfile into a stringlist
  inherited Create(AOwner);
end;

destructor TFixedFormatDataSet.Destroy;
begin
  inherited Destroy;
  FData.Free;
  FSchema.Free;
end;

procedure TFixedFormatDataSet.SetSchema(const Value: TStringList);
begin
  CheckInactive;
  FSchema.Assign(Value);
end;

procedure TFixedFormatDataSet.SetFileMustExist(Value : Boolean);
begin
  CheckInactive;
  FFileMustExist := Value;
end;

procedure TFixedFormatDataSet.SetTrimSpace(Value : Boolean);
begin
  CheckInactive;
  FTrimSpace := Value;
end;

procedure TFixedFormatDataSet.SetReadOnly(Value : Boolean);
begin
  CheckInactive;
  FReadOnly := Value;
end;

procedure TFixedFormatDataSet.SetFileName(Value : TFileName);
begin
  CheckInactive;
  FFileName := Value;
end;

procedure TFixedFormatDataSet.InternalInitFieldDefs;
var
  i, len, Maxlen :Integer;
  LstFields      :TStrings;
begin
  if not Assigned(FData) then
    exit;
  FRecordSize := 0;
  Maxlen := 0;
  FieldDefs.Clear;
  for i := FData.Count - 1 downto 0 do  // Find out the longest record
  begin
    len := Length(FData[i]);
    if len > Maxlen then
      Maxlen := len;
    FData.Objects[i] := TObject(Pointer(i+1));   // Fabricate Bookmarks
  end;
  if (Maxlen = 0) then
    Maxlen := FDefaultRecordLength;
  LstFields := TStringList.Create;
  try
    LoadFieldScheme(LstFields, Maxlen);
    for i := 0 to LstFields.Count -1 do  // Add fields
    begin
      len := StrToIntDef(LstFields.Values[LstFields.Names[i]], Maxlen);
      FieldDefs.Add(Trim(LstFields.Names[i]), ftString, len, False);
      Inc(FRecordSize, len);
    end;
  finally
    LstFields.Free;
  end;
end;

procedure TFixedFormatDataSet.InternalOpen;
var
  Stream : TStream;
begin
  FCurRec := -1;
  FSaveChanges := FALSE;
  if not Assigned(FData) then
    FData := TStringList.Create;
  if (not FileMustExist) and (not FileExists(FileName)) then
  begin
    Stream := TFileStream.Create(FileName, fmCreate);
    Stream.Free;
  end;
  if not FLoadfromStream then
    FData.LoadFromFile(FileName);
  FRecordSize := FDefaultRecordLength;
  InternalInitFieldDefs;
  if DefaultFields then
    CreateFields;
  BindFields(TRUE);
  if FRecordSize = 0 then
    FRecordSize := FDefaultRecordLength;
  BookmarkSize := SizeOf(PtrInt);
  FRecInfoOfs := FRecordSize + CalcFieldsSize; // Initialize the offset for TRecInfo in the buffer
  FBookmarkOfs := FRecInfoOfs + SizeOf(TRecInfo);
  FRecBufSize := FBookmarkOfs + BookmarkSize;
  FLastBookmark := FData.Count;
end;

procedure TFixedFormatDataSet.InternalClose;
begin
  if (not FReadOnly) and (FSaveChanges) then  // Write any edits to disk
    FData.SaveToFile(FileName);
  FLoadfromStream := False;
  FData.Clear;
  BindFields(FALSE);
  if DefaultFields then // Destroy the TField
    DestroyFields;
  FCurRec := -1;        // Reset these internal flags
  FLastBookmark := 0;
  FRecordSize := 0;
end;

function TFixedFormatDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FData) and (FRecordSize > 0);
end;

procedure TFixedFormatDataSet.InternalHandleException;
begin
{$ifndef fpc}
   Application.HandleException(Self);
{$else}
  inherited;
{$endif}
end;

// Loads Data from a stream.
procedure TFixedFormatDataSet.LoadFromStream(Stream: TStream);
begin
  if assigned(stream) then
  begin
    Active          := False; //Make sure the Dataset is Closed.
    Stream.Position := 0;     //Make sure you are at the top of the Stream.
    FLoadfromStream := True;
    if not Assigned(FData) then
     raise Exception.Create('Data buffer unassigned');
    FData.LoadFromStream(Stream);
    Active := True;
  end
  else
    raise exception.Create('Invalid Stream Assigned (Load From Stream');
end;

// Saves Data as text to a stream.
procedure TFixedFormatDataSet.SavetoStream(Stream: TStream);
begin
  if assigned(stream) then
    FData.SaveToStream(Stream)
  else
    raise exception.Create('Invalid Stream Assigned (Save To Stream');
end;

// Record Functions
function TFixedFormatDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  if FRecBufSize > 0 then
    Result := AllocMem(FRecBufSize)
  else
    Result := nil;
end;

procedure TFixedFormatDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  if Buffer <> nil then
    FreeMem(Buffer);
end;

procedure TFixedFormatDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillChar(Buffer[0], FRecordSize, 0);
end;

procedure TFixedFormatDataSet.ClearCalcFields(Buffer: TRecordBuffer);
begin
  FillChar(Buffer[RecordSize], CalcFieldsSize, 0);
end;

function TFixedFormatDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  if (FData.Count < (1+FDataOffset)) then
    Result := grEOF
  else
    Result := TxtGetRecord(Buffer, GetMode);
  if Result = grOK then
  begin
    if (CalcFieldsSize > 0) then
      GetCalcFields(Buffer);
    with PRecInfo(Buffer + FRecInfoOfs)^ do
    begin
      BookmarkFlag := bfCurrent;
      RecordNumber := PtrInt(FData.Objects[FCurRec]);
    end;
  end
  else
    if (Result = grError) and DoCheck then
      DatabaseError('No Records');
end;

function TFixedFormatDataSet.GetRecordCount: Longint;
begin
  Result := FData.Count;
end;

function TFixedFormatDataSet.GetRecNo: Longint;
var
  BufPtr: TRecordBuffer;
begin
  Result := -1;
  if GetActiveRecBuf(BufPtr) then
    Result := PRecInfo(BufPtr + FRecInfoOfs)^.RecordNumber;
end;

procedure TFixedFormatDataSet.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value >= 0) and (Value < FData.Count) and (Value <> RecNo) then
  begin
    DoBeforeScroll;
    FCurRec := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;

function TFixedFormatDataSet.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

function TFixedFormatDataSet.GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
begin
  case State of
    dsBrowse: if IsEmpty then RecBuf := nil else RecBuf := ActiveBuffer;
    dsEdit, dsInsert: RecBuf := ActiveBuffer;
    dsCalcFields: RecBuf := CalcBuffer;
    dsFilter: RecBuf := FFilterBuffer;
  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

function TFixedFormatDataSet.TxtGetRecord(Buffer : TRecordBuffer; GetMode: TGetMode): TGetResult;
var
  Accepted : Boolean;
begin
  Result := grOK;
  repeat
    Accepted := TRUE;
    case GetMode of
      gmNext:
        if FCurRec >= RecordCount - 1  then
          Result := grEOF
        else
          Inc(FCurRec);
      gmPrior:
        if FCurRec <= FDataOffset then
          Result := grBOF
        else
          Dec(FCurRec);
      gmCurrent:
        if (FCurRec < FDataOffset) or (FCurRec >= RecordCount) then
          Result := grError;
    end;
    if (Result = grOk) then
    begin
      Move(PChar(StoreToBuf(FData[FCurRec]))^, Buffer[0], FRecordSize);
      if Filtered then
      begin
        Accepted := RecordFilter(Buffer, FCurRec +1);
        if not Accepted and (GetMode = gmCurrent) then
          Inc(FCurRec);
      end;
    end;
  until Accepted;
end;

function TFixedFormatDataSet.RecordFilter(RecBuf: Pointer; ARecNo: Integer): Boolean;
var
  Accept: Boolean;
  SaveState: TDataSetState;
begin                          // Returns true if accepted in the filter
  SaveState := SetTempState(dsFilter);
  FFilterBuffer := RecBuf;
  PRecInfo(FFilterBuffer + FRecInfoOfs)^.RecordNumber := ARecNo;
  Accept := TRUE;
  if Accept and Assigned(OnFilterRecord) then
    OnFilterRecord(Self, Accept);
  RestoreState(SaveState);
  Result := Accept;
end;

function TFixedFormatDataSet.GetCanModify: boolean;
begin
  Result := not FReadOnly;
end;

// Field Related
procedure TFixedFormatDataSet.LoadFieldScheme(List : TStrings; MaxSize : Integer);
var
  tmpFieldName : string;
  tmpSchema : TStrings;
  i : Integer;
begin
  tmpSchema := TStringList.Create;
  try       // Load Schema Structure
    if (Schema.Count > 0) then
    begin
      tmpSchema.Assign(Schema);
      RemoveWhiteLines(tmpSchema, FALSE);
    end
    else
      tmpSchema.Add('Line');
    for i := 0 to tmpSchema.Count -1 do // Interpret Schema
    begin
      tmpFieldName := tmpSchema.Names[i];
      if (tmpFieldName = '') then
        tmpFieldName := Format('%s=%d', [tmpSchema[i], MaxSize])
      else
        tmpFieldName := tmpSchema[i];
      List.Add(tmpFieldName);
    end;
  finally
    tmpSchema.Free;
  end;
end;

function TFixedFormatDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  TempPos, recbuf : PChar;
begin
  Result := GetActiveRecBuf(TRecordBuffer(RecBuf));
  if Result then
  begin
    if Field.FieldNo > 0 then
    begin
      TempPos := RecBuf;
      SetFieldPos(TRecordBuffer(RecBuf), Field.FieldNo);
      Result := (RecBuf < StrEnd(TempPos));
    end
    else
      if (State in [dsBrowse, dsEdit, dsInsert, dsCalcFields]) then
      begin
        Inc(RecBuf, FRecordSize + Field.Offset);
        Result := Boolean(Byte(RecBuf[0]));
      end;
  end;
  if Result and (Buffer <> nil) then
  begin
    StrLCopy(Buffer, RecBuf, Field.Size);
    if FTrimSpace then
    begin
      TempPos := StrEnd(Buffer);
      repeat
        Dec(TempPos);
        if (TempPos[0] = ' ') then
          TempPos[0]:= #0
        else
          break;
      until (TempPos = Buffer);
    end;
  end;
end;

procedure TFixedFormatDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  RecBuf: PChar;
  BufEnd: PChar;
  p : Integer;
begin
  if not (State in dsWriteModes) then
    DatabaseError(SNotEditing, Self);
  GetActiveRecBuf(TRecordBuffer(RecBuf));
  if Field.FieldNo > 0 then
  begin
    if State = dsCalcFields then
      DatabaseError('Dataset not in edit or insert mode', Self);
    if Field.ReadOnly and not (State in [dsSetKey, dsFilter]) then
      DatabaseErrorFmt(SReadOnlyField, [Field.DisplayName]);
    if State in [dsEdit, dsInsert, dsNewValue] then
      Field.Validate(Buffer);
    if Field.FieldKind <> fkInternalCalc then
    begin
      SetFieldPos(TRecordBuffer(RecBuf), Field.FieldNo);
      BufEnd := StrEnd(pansichar(ActiveBuffer));  // Fill with blanks when necessary
      if BufEnd > RecBuf then
        BufEnd := RecBuf;
      FillChar(BufEnd[0], Field.Size + PtrInt(RecBuf) - PtrInt(BufEnd), Ord(' '));
      p := StrLen(Buffer);
      if p > Field.Size then
        p := Field.Size;
      Move(Buffer^, RecBuf[0], p);
    end;
  end
  else // fkCalculated, fkLookup
  begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Move(Buffer^, RecBuf[0], Field.Size);
  end;
  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, Ptrint(Field));
end;

procedure TFixedFormatDataSet.SetFieldPos(var Buffer : TRecordBuffer; FieldNo : Integer);
var
  i : Integer;
begin
  i := 1;
  while (i < FieldNo) and (i < FieldDefs.Count) do
  begin
    Inc(Buffer, FieldDefs.Items[i-1].Size);
    Inc(i);
  end;
end;

// Navigation / Editing
procedure TFixedFormatDataSet.InternalFirst;
begin
  FCurRec := -1;
end;

procedure TFixedFormatDataSet.InternalLast;
begin
  FCurRec := FData.Count;
end;

procedure TFixedFormatDataSet.InternalPost;
begin
  FSaveChanges := TRUE;
  inherited UpdateRecord;
  if (State = dsEdit) then // just update the data in the string list
  begin
    FData[FCurRec] := BufToStore(ActiveBuffer);
  end
  else
    InternalAddRecord(ActiveBuffer, FALSE);
end;

procedure TFixedFormatDataSet.InternalEdit;
begin

end;

procedure TFixedFormatDataSet.InternalDelete;
begin
  FSaveChanges := TRUE;
  FData.Delete(FCurRec);
  if FCurRec >= FData.Count then
    Dec(FCurRec);
end;

procedure TFixedFormatDataSet.InternalAddRecord(Buffer: Pointer; DoAppend: Boolean);
begin
  FSaveChanges := TRUE;
  Inc(FLastBookmark);
  if DoAppend then
    InternalLast;
  if (FCurRec >=0) then
    FData.InsertObject(FCurRec, BufToStore(Buffer), TObject(Pointer(FLastBookmark)))
  else
    FData.AddObject(BufToStore(Buffer), TObject(Pointer(FLastBookmark)));
end;

procedure TFixedFormatDataSet.InternalGotoBookmark(ABookmark: Pointer);
var
  Index: Integer;
begin
  Index := FData.IndexOfObject(TObject(PPtrInt(ABookmark)^));
  if Index <> -1 then
    FCurRec := Index
  else
    DatabaseError('Bookmark not found');
end;

procedure TFixedFormatDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  if (State <> dsInsert) then
    InternalGotoBookmark(@PRecInfo(Buffer + FRecInfoOfs)^.RecordNumber);
end;

function TFixedFormatDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer + FRecInfoOfs)^.BookmarkFlag;
end;

procedure TFixedFormatDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer + FRecInfoOfs)^.BookmarkFlag := Value;
end;

procedure TFixedFormatDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  Move(Buffer[FRecInfoOfs], Data^, BookmarkSize);
end;

procedure TFixedFormatDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  Move(Data^, Buffer[FRecInfoOfs], BookmarkSize);
end;

procedure TFixedFormatDataSet.RemoveWhiteLines(List : TStrings; IsFileRecord : Boolean);
var
  i : integer;
begin
  for i := List.Count -1 downto 0 do
  begin
    if (Trim(List[i]) = '' ) then
      if IsFileRecord then
      begin
        FCurRec := i;
        InternalDelete;
      end
      else
        List.Delete(i);
  end;
end;

procedure TFixedFormatDataSet.RemoveBlankRecords;
begin
  RemoveWhiteLines(FData, TRUE);
end;

procedure TFixedFormatDataSet.RemoveExtraColumns;
var
  i : Integer;
begin
  for i := FData.Count -1 downto 0 do
    FData[i] := BufToStore(trecordbuffer(StoreToBuf(FData[i])));
  FData.SaveToFile(FileName);
end;

procedure TFixedFormatDataSet.SaveFileAs(strFileName : String);
begin
  FData.SaveToFile(strFileName);
  FFileName := strFileName;
  FSaveChanges := FALSE;
end;

function TFixedFormatDataSet.StoreToBuf(Source: String): String;
begin
  Result := Source;
end;

function TFixedFormatDataSet.BufToStore(Buffer: TRecordBuffer): String;
begin
  Result := Copy(pansichar(Buffer), 1, FRecordSize);
end;

//-----------------------------------------------------------------------------
// TSdfDataSet
//-----------------------------------------------------------------------------
constructor TSdfDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDelimiter := ',';
  FFirstLineAsSchema := FALSE;
  FFMultiLine :=False;
end;

procedure TSdfDataSet.InternalInitFieldDefs;
var
  pStart, pEnd, len : Integer;
begin
  if not IsCursorOpen then
    exit;
  if (FData.Count = 0) and (Schema.Count > 0) and FirstLineAsSchema then
  begin
    Schema.Delimiter := Delimiter;
    FData.Append(Schema.DelimitedText);
  end
  else if (FData.Count = 0) or (Trim(FData[0]) = '') then
    begin
    FirstLineAsSchema := FALSE;
    FDataOffset:=0;
    end
  else if (Schema.Count = 0) or (FirstLineAsSchema) then
  begin
    Schema.Clear;
    len := Length(FData[0]);
    pEnd := 1;
    repeat
      while (pEnd <= len) and (FData[0][pEnd] in [#1..' ']) do
        Inc(pEnd);

      if (pEnd > len) then
        break;

      pStart := pEnd;

      if (FData[0][pStart] = '"') then
       begin
        repeat
          Inc(pEnd);
        until (pEnd > len)  or (FData[0][pEnd] = '"');

        if (FData[0][pEnd] = '"') then
          Inc(pStart);
       end
      else
       while (pEnd <= len) and (FData[0][pEnd]  <> Delimiter) do
        Inc(pEnd);

      if (FirstLineAsSchema) then
       Schema.Add(Copy(FData[0], pStart, pEnd - pStart))
      else
       Schema.Add(Format('Field%d', [Schema.Count + 1]));

      if (FData[0][pEnd] = '"') then
        while (pEnd <= len) and (FData[0][pEnd] <> Delimiter) do
          Inc(pEnd);

      if (FData[0][pEnd] = Delimiter) then
          Inc(pEnd);

    until (pEnd > len);
  end;
  inherited;
end;

function TSdfDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  if FirstLineAsSchema then
  begin
    if (FData.Count < 2) then
      begin
      if GetMode=gmPrior then
       Result := grBOF
      else
       Result := grEOF
      end
    else
      begin
      If (FCurrec=-1) and (GetMode=gmNext) then
        inc(FCurrec);
      Result := inherited GetRecord(Buffer, GetMode, DoCheck);
      end;
  end
  else
    Result := inherited GetRecord(Buffer, GetMode, DoCheck);
end;

function TSdfDataSet.StoreToBuf(Source: String): String;
const
 CR    :char = #13;
 LF    :char = #10;
 Quote :char = #34; // Character that encloses field if quoted. Hard-coded to "
var
  IsQuoted   // Whether or not field starts with a quote
                :Boolean;
  FieldMaxSize, // Maximum fields size as defined in FieldDefs
  i,         // Field counter (0..)
  p          // Length of string in field
                :Integer;
  pDeQuoted, // Temporary buffer for dedoubling quotes
  pRet,      // Pointer to insertion point in return value
  pStr,      // Beginning of field
  pStrEnd    // End of field
                :PChar;
  Ret           :String;
begin
  SetLength(Ret, FRecordSize);
  FillChar(PChar(Ret)^, FRecordSize, Ord(' '));

  PStrEnd := PChar(Source);
  pRet := PChar(Ret);

  for i := 0 to FieldDefs.Count - 1 do
   begin
    FieldMaxSize := FieldDefs[i].Size;
    IsQuoted := false;
    while Boolean(Byte(pStrEnd[0])) and (pStrEnd[0] in [#1..' ']) do
    begin
     if FFMultiLine then
      begin
       if ((pStrEnd[0]=CR) or (pStrEnd[0]=LF)) then
        begin
         //view this as text, not control characters, so do nothing
         //todo: check if this is really necessary, probably revert
         //to original code as quoted case is handled below
        end;
      end
     else
      begin
       Inc(pStrEnd);
      end;
    end;

    if not Boolean(Byte(pStrEnd[0])) then
     break;

    pStr := pStrEnd;

    if (pStr[0] = Quote) then
     begin
      IsQuoted := true; // See below: accept end of string without explicit quote
      if FFMultiLine then
       begin
        repeat
         Inc(pStrEnd);
        until not Boolean(Byte(pStrEnd[0])) or
         ((pStrEnd[0] = Quote) and ((pStrEnd + 1)[0] in [Delimiter,#0]));
       end
      else
       begin
        // No multiline, so treat cr/lf as end of record
         repeat
          Inc(pStrEnd);
         until not Boolean(Byte(pStrEnd[0])) or
          ((pStrEnd[0] = Quote) and ((pStrEnd + 1)[0] in [Delimiter,CR,LF,#0]));
       end;

      if (pStrEnd[0] = Quote) then
       Inc(pStr); //Skip final quote
     end
    else
      while Boolean(Byte(pStrEnd[0])) and (pStrEnd[0] <> Delimiter) do
        Inc(pStrEnd);

    // Copy over entire field (or at least up to field length):
    p := pStrEnd - pStr;
    if IsQuoted then
    begin
     pDeQuoted := pRet; //Needed to avoid changing insertion point
     // Copy entire field but not more than maximum field length:
     // (We can mess with pStr now; the next loop will reset it after
     // pStrEnd):
     while (pstr < pStrEnd) and (pDeQuoted-pRet <= FieldMaxSize) do
     begin
      if pStr^ = Quote then inc(pStr);// skip first quote
      pDeQuoted^ := pStr^;
      inc(pStr);
      inc(pDeQuoted);
     end;
    end
    else
    begin
     if (p > FieldMaxSize) then
       p := FieldMaxSize;
     Move(pStr[0], pRet[0], p);
    end;

    Inc(pRet, FieldMaxSize);

    // Move the end of field position past quotes and delimiters
    // ready for processing the next field
    if (pStrEnd[0] = Quote) then
      while Boolean(Byte(pStrEnd[0])) and (pStrEnd[0] <> Delimiter) do
        Inc(pStrEnd);

    if (pStrEnd[0] = Delimiter) then
     Inc(pStrEnd);
   end;

  Result := ret;
end;

function TSdfDataSet.BufToStore(Buffer: TRecordBuffer): String;
const
 QuoteDelimiter='"';
var
  Str : String;
  p, i : Integer;
  QuoteMe: boolean;
begin
  Result := '';
  p := 1;
  for i := 0 to FieldDefs.Count - 1 do
  begin
    QuoteMe:=false;
    Str := Trim(Copy(pansichar(Buffer), p, FieldDefs[i].Size));
    Inc(p, FieldDefs[i].Size);
    if FFMultiLine then
      begin
       // If multiline enabled, quote whenever we find carriage return or linefeed
       if (not QuoteMe) and (StrScan(PChar(Str), #10) <> nil) then QuoteMe:=true;
       if (not QuoteMe) and (StrScan(PChar(Str), #13) <> nil) then QuoteMe:=true;
      end
    else
      begin
       // If we don't allow multiline, remove all CR and LF because they mess with the record ends:
       Str := StringReplace(Str, #10, '', [rfReplaceAll]);
       Str := StringReplace(Str, #13, '', [rfReplaceAll]);
      end;
    // Check for any delimiters or quotes occurring in field text  
    if (not QuoteMe) then
	  if (StrScan(PChar(Str), FDelimiter) <> nil) or
	    (StrScan(PChar(Str), QuoteDelimiter) <> nil) then QuoteMe:=true;
    if (QuoteMe) then
      begin
      Str := Stringreplace(Str, QuoteDelimiter, QuoteDelimiter+QuoteDelimiter, [rfReplaceAll]);
      Str := QuoteDelimiter + Str + QuoteDelimiter;
      end;
    Result := Result + Str + FDelimiter;
  end;
  p := Length(Result);
  while (p > 0) and (Result[p] = FDelimiter) do
  begin
    System.Delete(Result, p, 1);
    Dec(p);
  end;
end;

procedure TSdfDataSet.SetDelimiter(Value : Char);
begin
  CheckInactive;
  FDelimiter := Value;
end;

procedure TSdfDataSet.SetFirstLineAsSchema(Value : Boolean);
begin
  CheckInactive;
  FFirstLineAsSchema := Value;
  FDataOffset:=Ord(FFirstLineAsSchema);
end;

procedure TSdfDataSet.SetMultiLine(const Value: Boolean);
begin
  FFMultiLine:=Value;
end;


//-----------------------------------------------------------------------------
// This procedure is used to register this component on the component palette
//-----------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('Data Access', [TFixedFormatDataSet]);
  RegisterComponents('Data Access', [TSdfDataSet]);
end;

end.
