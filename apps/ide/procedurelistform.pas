unit procedurelistform;

{$mode objfpc}{$h+}

// if enabled shows more debug output to the console window
{.$define gdebug}

// debug info to see what is called when
{.$define gTrace}

interface

uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msegui,
 msegraphics,msegraphutils,mseclasses,mseforms,msetoolbar,mseevent,
 msesimplewidgets,mseedit,msestrings,sysutils,
 msedataedits,msegrids,pparser, pastree,
 Classes,msedispwidgets,mserichstring;

type

  TSimpleEngine = class(TPasTreeContainer)
  public
    function CreateElement(AClass: TPTreeElement; const AName: String;
      AParent: TPasElement; AVisibility: TPasMemberVisibility;
      const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement; override;
    function FindElement(const AName: String): TPasElement; override;
  end;


  TSourceLanguage = (ltPas, ltCpp);


  TProcInfo = class(TObject)
  private
    FLineNo: Integer;
    FName: string;
    FDisplayName: string;
    FProcedureType: string;
    FProcArgs: string;
    FProcClass: string;
    FProcReturnType: string;
    FProcName: string;
    FProcIndex: Integer;
  public
    property LineNo: Integer read FLineNo write FLineNo;
    property Name: string read FName write FName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property ProcedureType: string read FProcedureType write FProcedureType;
    property ProcArgs: string read FProcArgs write FProcArgs;
    property ProcName: string read FProcName write FProcName;
    property ProcClass: string read FProcClass write FProcClass;
    property ProcReturnType: string read FProcReturnType write FProcReturnType;
    property ProcIndex: Integer read FProcIndex write FProcIndex;
  end;


 tprocedurelistfo = class(tmseform)
   ttoolbar1: ttoolbar;
   edtSearch: tedit;
   grdProcedures: tstringgrid;
   lblStatus: tstringdisp;
   cbObjects: tdropdownlistedit;
   procedure formcreated(const sender: TObject);
   procedure formdestroy(const sender: TObject);
   procedure FilterTextChanged(const sender: tcustomedit; var atext: msestring);
   procedure FilterTextKeyDown(const sender: twidget; var ainfo: keyeventinfoty);
   procedure ResultGridKeyDown(const sender: twidget;
                   var ainfo: keyeventinfoty);
   procedure JumpToSelectedLine;
 private
    FFilename: String;
    FLanguage: TSourceLanguage;
    FSortOnColumn: Integer;
    FSearchAll: Boolean;
    FProcList: TStringList;
    FObjectStrings: TStringList;
    procedure InitializeForm;
    procedure FillGrid;
    procedure LoadProcs;
    procedure AddProcedure(ProcedureInfo: TProcInfo);
    procedure ClearObjectStrings;
    procedure QuickSort(L, R: Integer);
    procedure LoadObjectCombobox;
    function  GetMethodName(const ProcName: string): string;
    function  GetTickCount: LongWord;
 public
    property  Language: TSourceLanguage read FLanguage write FLanguage default ltPas;
 end;

var
  procedurelistfo: tprocedurelistfo;

procedure doProcedureList;


implementation

uses
  procedurelistform_mfm,
  procedurelistutils,
  mPasLex,
  sourceform,
  msekeyboard;

const
  SAllString  = '<All>';
  SNoneString = '<None>';
  SUnknown = 'Unknown';
  SImplementationNotFound = 'Implementation section not found (parser error?)';
  SInvalidIndex = 'Invalid index number';
  SParseStatistics = 'Procedures processed in %.4g seconds';


procedure doProcedureList;
var
  fo: tprocedurelistfo;
begin
{$ifdef gTrace}
writeln('>> doProcedureList');
{$endif}
  fo := tprocedurelistfo.create(nil);
  try
    fo.show(true);
  finally
    {$ifdef gdebug}
    writeln('  before calling fo.free');
    {$endif}
//    FreeAndNil(fo);
//set procedurelistfo.options fo_freeonclose instead
    {$ifdef gdebug}
    writeln('  after calling fo.free');
    {$endif}
  end;
{$ifdef gTrace}
writeln('<< doProcedureList');
{$endif}
end;


procedure tprocedurelistfo.formcreated(const sender: TObject);
var
  LoadTime: LongWord;
begin
{$ifdef gTrace}
writeln('>> FormCreated');
{$endif}
  FLanguage := ltPas;
  FSearchAll := True; // search anywhere in a method name
  if Assigned(sourcefo.activepage) then
    FFilename := sourcefo.activepage.filepath
  else
    Close;
  LoadTime := GetTickCount;
  InitializeForm;
  LoadTime := GetTickCount - LoadTime;
  lblStatus.Text := Format(SParseStatistics, [LoadTime / 1000]);
{$ifdef gTrace}
writeln('<< FormCreated');
{$endif}
end;

procedure tprocedurelistfo.InitializeForm;
begin
{$ifdef gTrace}
writeln('>> InitializeForm');
{$endif}
  FObjectStrings := TStringList.Create;
  FObjectStrings.Sorted := True;
  FObjectStrings.Duplicates := dupIgnore;
  ClearObjectStrings;

  FSortOnColumn := 1;

  FProcList := TStringList.Create;

//  LoadSettings;
  try
    LoadProcs;
  except
    on E: Exception do
      begin
        // if not debugging, then silently ignore parsing errors
        {$ifdef gdebug}
        writeln('ERROR: ', E.Message);
        {$endif}
      end;
  end;

  FillGrid;
  edtSearch.SetFocus;
{$ifdef gTrace}
writeln('<< InitializeForm');
{$endif}
end;

procedure tprocedurelistfo.FillGrid;
var
  i: Integer;
  ProcName: string;
  IsObject: Boolean;
  ProcInfo: TProcInfo;

  procedure AddListItem(ProcInfo: TProcInfo);
  var
    r: integer;
    c: gridcoordty;
  begin
    r := grdProcedures.RowCount;
    grdProcedures.RowCount := grdProcedures.RowCount + 1;
//    grdProcedures.Objects[0, r] := ProcInfo;
//    case Language of
//      ltPas: ListItem.ImageIndex := GetPasImageIndex(ProcInfo.Name);
//      ltCpp: ListItem.ImageIndex := ProcInfo.ProcIndex;
//    end;

//    grdProcedures.Cells[1, r] := ProcInfo.DisplayName;
//    grdProcedures.Cells[2, r] := ProcInfo.ProcedureType;
//    grdProcedures.Cells[3, r] := IntToStr(ProcInfo.LineNo);
     c.row := r;
     c.col := 0;
     grdProcedures.Items[c] := IntToStr(i);
     c.col := 1;
     grdProcedures.Items[c] := ProcInfo.DisplayName;
     c.col := 2;
     grdProcedures.Items[c] := ProcInfo.ProcedureType;
     c.col := 3;
     grdProcedures.Items[c] := IntToStr(ProcInfo.LineNo);
  end;

  procedure FocusAndSelectFirstItem;
  begin
    if grdProcedures.RowCount > 0 then
      grdProcedures.Row := 0;
  end;

begin
{$ifdef gTrace}
writeln('>> FillGrid');
{$endif}
  {$ifdef gdebug}
  writeln('FProcList.Count = ', FProcList.Count);
  {$endif}
  grdProcedures.BeginUpdate;
  try
    grdProcedures.RowCount := 0;
    if (Length(edtSearch.Text) = 0) and (cbObjects.Text = SAllString) then
    begin
      for i := 0 to FProcList.Count - 1 do
        AddListItem(TProcInfo(FProcList.Objects[i]));
      FocusAndSelectFirstItem;
      Exit;
    end;

    for i := 0 to FProcList.Count - 1 do
    begin
      ProcInfo := TProcInfo(FProcList.Objects[i]);
      case Language of
        ltPas: ProcName := ProcInfo.Name;
        ltCpp: ProcName := ProcInfo.ProcClass;
      end;
      IsObject := Length(ProcInfo.ProcClass) > 0;

      // Is it the object we want?
      if cbObjects.Text <> SAllString then
      begin
        if cbObjects.Text = SNoneString then
        begin
          if IsObject then // Does it have an object?
            Continue;
          if Length(edtSearch.Text) = 0 then // If no filter is active, add
          begin
            AddListItem(ProcInfo);
            Continue;
          end;
        end // if/then
        else if not SameText(cbObjects.Text, ProcInfo.ProcClass) then
          Continue;
      end;

      case Language of
        ltPas: ProcName := GetMethodName(ProcName);
        ltCpp: ProcName := ProcInfo.ProcName;
      end;

      if Length(edtSearch.Text) = 0 then
        AddListItem(ProcInfo)
      else if not FSearchAll and SameText(edtSearch.Text, Copy(ProcName, 1, Length(edtSearch.Text))) then
        AddListItem(ProcInfo)
      else if FSearchAll and StrContains(edtSearch.Text, ProcName, False) then
        AddListItem(ProcInfo);
    end;
    FocusAndSelectFirstItem;
  finally
    grdProcedures.EndUpdate;
  end;
{$ifdef gTrace}
writeln('<< FillGrid');
{$endif}
end;

procedure tprocedurelistfo.LoadProcs;
var
  Parser: TmwPasLex;
//  CParser: TBCBTokenList;
  BeginBracePosition: Longint;
  BraceCount, PreviousBraceCount: Integer;

  function MoveToImplementation: Boolean;
  begin
    if IsProgram(FFileName) or (IsInc(FFileName)) then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    while Parser.TokenID <> tkNull do
    begin
      if Parser.TokenID = tkImplementation then
        Result := True;
      Parser.Next;
      if Result then
        Break;
    end;
  end;

  procedure FindProcs;

    function GetProperProcName(ProcType: TTokenKind; IsClass: Boolean): string;
    begin
      Result := SUnknown;
      if IsClass then
      begin
        if ProcType = tkFunction then
          Result := 'Class Func' // Do not localize.
        else if ProcType = tkProcedure then
          Result := 'Class Proc'; // Do not localize.
      end
      else
      begin
        case ProcType of
          // Do not localize.
          tkFunction: Result := 'Function';
          tkProcedure: Result := 'Procedure';
          tkConstructor: Result := 'Constructor';
          tkDestructor: Result := 'Destructor';
        end;
      end;
    end;

  var
    ProcLine: string;
    ProcType: TTokenKind;
    Line: Integer;
    ClassLast: Boolean;
    InParenthesis: Boolean;
    InTypeDeclaration: Boolean;
    FoundNonEmptyType: Boolean;
    IdentifierNeeded: Boolean;
    ProcedureInfo: TProcInfo;
    BeginProcHeaderPosition: Longint;
    i, j: Integer;
    LineNo: Integer;
    ProcName, ProcReturnType: string;
    ProcedureType, ProcClass, ProcArgs: string;
    ProcIndex: Integer;
    NameList: TStringList;
    NewName, TmpName, ProcClassAdd, ClassName: string;
    BraceCountDelta: Integer;
    TemplateArgs: string;

    procedure EraseName(Index: Integer);
    var
      NameIndex: Integer;
    begin
      NameIndex := NameList.IndexOfName(IntToStr(Index));
      if NameIndex <> -1 then
        NameList.Delete(NameIndex);
    end;

  begin
    {$ifdef gTrace}
    writeln('>> FindProcs');
    {$endif}
    FProcList.Capacity := 200;
    FProcList.BeginUpdate;
    try
      case Language of
        ltPas:
          begin
            if not MoveToImplementation then
              raise Exception.Create(SImplementationNotFound);
            ClassLast := False;
            InParenthesis := False;
            InTypeDeclaration := False;
            FoundNonEmptyType := False;

            while Parser.TokenID <> tkNull do
            begin
              if not InTypeDeclaration and
                (Parser.TokenID in [tkFunction, tkProcedure, tkConstructor, tkDestructor]) then
              begin
                IdentifierNeeded := True;
                ProcType := Parser.TokenID;
                Line := Parser.LineNumber + 1;
                ProcLine := '';
                while not (Parser.TokenId in [tkNull]) do
                begin
                  //{$IFOPT D+} SendDebug('Found Inner Token: '+ Parser.Token+ ' '+BTS(ClassLast)); {$ENDIF}
                  case Parser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  if (not InParenthesis) and (Parser.TokenID = tkSemiColon) then
                    Break;

                  if not (Parser.TokenID in [tkCRLF, tkCRLFCo]) then
                    ProcLine := ProcLine + Parser.Token;
                  Parser.Next;
                end; // while
                if Parser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.
                //{$IFOPT D+} SendDebug('FoundProc: ' + ProcLine); {$ENDIF}
                if not IdentifierNeeded then
                begin
                  ProcedureInfo := TProcInfo.Create;
                  ProcedureInfo.Name := ProcLine;
                  ProcedureInfo.ProcedureType := GetProperProcName(ProcType, ClassLast);
                  ProcedureInfo.LineNo := Line;
                  AddProcedure(ProcedureInfo);
                end;
              end;
              if (Parser.TokenID = tkClass) and Parser.IsClass then
              begin
                InTypeDeclaration := True;
                FoundNonEmptyType := False;
              end
              else if InTypeDeclaration and
                (Parser.TokenID in [tkProcedure, tkFunction, tkProperty,
                tkPrivate, tkProtected, tkPublic, tkPublished]) then
              begin
                FoundNonEmptyType := True;
              end
              else if InTypeDeclaration and
                ((Parser.TokenID = tkEnd) or
                ((Parser.TokenID = tkSemiColon) and not FoundNonEmptyType)) then
              begin
                InTypeDeclaration := False;
              end;
              //{$IFOPT D+} SendDebug('Found Token: '+ Parser.Token+ ' '+BTS(ClassLast)); {$ENDIF}
              ClassLast := (Parser.TokenID = tkClass);
              if ClassLast then
              begin
                Parser.NextNoJunk;
                //{$IFOPT D+} SendDebug('Found Class Token'+ ' '+BTS(ClassLast)); {$ENDIF}
              end
              else
                Parser.Next;
            end;
          end; //ltPas


        ltCpp:
          begin
            // code ommitted - we don't need C++ support
          end;

      end; //case Language
    finally
      FProcList.EndUpdate;
    end;
    {$ifdef gTrace}
    writeln('<< FindProcs');
    {$endif}
  end;

var
  SFile: TFileStream;
  MemStream: TMemoryStream;
const
  TheEnd: Char = #0; // Leave typed constant as is - needed for streaming code
begin
  {$ifdef gTrace}
  writeln('>> LoadProcs');
  {$endif}
  Parser := nil;
  case Language of
    ltPas: Parser := TmwPasLex.Create;
//    ltCpp: CParser := TBCBTokenList.Create;
  end;
  if not Assigned(Parser) then
    raise Exception.Create('No parser instance was created - maybe an unknown language?');
  try
    MemStream := TMemoryStream.Create;
    try
      // Read from file on disk and store in a memory stream
      SFile := TFileStream.Create(FFilename, fmOpenRead or fmShareDenyWrite);
      try
        SFile.Position := 0;
        MemStream.CopyFrom(SFile, SFile.Size);
        MemStream.Write(TheEnd, 1);
      finally
        SFile.Free;
      end;

      case Language of
        ltPas: Parser.Origin := MemStream.Memory;
//        ltCpp: CParser.SetOrigin(MemStream.Memory, MemStream.Size);
      end;
      Caption := Caption + ' - ' + ExtractFileName(FFileName);

      ClearObjectStrings;
      try
        FindProcs;
      finally
        LoadObjectCombobox;
      end;

      QuickSort(0, FProcList.Count - 1);
      lblStatus.Text := Trim(IntToStr(grdProcedures.RowCount));
    finally
      MemStream.Free;
    end;
  finally
    case Language of
      ltPas: Parser.Free;
//      ltCpp: CParser.Free;
    end;
  end;
  {$ifdef gTrace}
  writeln('<< LoadProcs');
  {$endif}
end;

procedure tprocedurelistfo.AddProcedure(ProcedureInfo: TProcInfo);
var
  TempStr: string;
  i: Integer;
begin
  ProcedureInfo.Name := CompressWhiteSpace(ProcedureInfo.Name);
  case Language of
    ltPas:
      begin
        TempStr := ProcedureInfo.Name;
        // Remove the class reserved word
        if StrBeginsWith('CLASS ', TempStr, False) then // Do not localize.
          Delete(TempStr, 1, 6); // Do not localize.
        // Remove 'function' or 'procedure'
        i := System.Pos(' ', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, i + 1, Length(TempStr));
        // Remove the paramater list
        i := System.Pos('(', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, 1, i - 1);
        // Remove the function return type
        i := System.Pos(':', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, 1, i - 1);
        // Check for an implementation procedural type
        if Length(TempStr) = 0 then
        begin
          ProcedureInfo.Free;
          Exit;
        end;
        // Remove any trailing ';'
        if TempStr[Length(TempStr)] = ';' then
          Delete(TempStr, Length(TempStr), 1);
        TempStr := Trim(TempStr);
        ProcedureInfo.DisplayName := TempStr;
        // Add to the object combobox and set the object name in ProcedureInfo
        i := System.Pos('.', TempStr);
        if i = 0 then
          FObjectStrings.Add(SNoneString)
        else
        begin
          ProcedureInfo.ProcClass := Copy(TempStr, 1, i - 1);
          FObjectStrings.Add(ProcedureInfo.ProcClass);
        end;
        FProcList.AddObject(#9 + TempStr + #9 + ProcedureInfo.ProcedureType + #9 + IntToStr(ProcedureInfo.LineNo), ProcedureInfo);
      end; //ltPas

    ltCpp:
      begin
        // code ommitted - we don't need C++ support
      end; //ltCpp

  end; //case Language
end;

procedure tprocedurelistfo.ClearObjectStrings;
begin
  FObjectStrings.Clear;
  FObjectStrings.Add(SAllString);
end;

procedure tprocedurelistfo.QuickSort(L: Integer; R: Integer);

  function GetValue(idx: Integer): string;
  var
    i: Integer;
    TabPos: Integer;
  begin
    if idx >= FProcList.Count then
      raise Exception.Create(SInvalidIndex);
    Result := FProcList.Strings[idx];
    for i := 0 to FSortOnColumn - 1 do
    begin
      TabPos := System.Pos(#9, Result);
      if TabPos > 0 then
        Delete(Result, 1, TabPos)
      else
        Exit;
    end;
    if FSortOnColumn = 3 then
    begin
      for i := Length(Result) to 5 do
        Result := ' ' + Result;
    end;
  end;

var
  I, J: Integer;
  P: string;
begin
  if FProcList.Count = 0 then
    Exit;
  repeat
    I := L;
    J := R;
    P := GetValue((L + R) shr 1);
    repeat
      while AnsiCompareText(GetValue(I), P) < 0 do
        Inc(I);
      while AnsiCompareText(GetValue(J), P) > 0 do
        Dec(J);
      if I <= J then
      begin
        FProcList.Exchange(I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J);
    L := I;
  until I >= R;
end;

procedure tprocedurelistfo.LoadObjectCombobox;
var
  i: integer;
begin
  cbObjects.dropdown.cols.BeginUpdate;
  for i := 0 to FObjectStrings.Count-1 do
    cbObjects.dropdown.cols.addrow([FObjectStrings[i]]);
  cbObjects.dropdown.cols.EndUpdate;
  cbObjects.dropdown.ItemIndex := 0;
end;

function tprocedurelistfo.GetMethodName(const ProcName: string): string;
var
  CharPos: Integer;
begin
  Result := ProcName;
  Delete(Result, 1, 1);

  CharPos := System.Pos(#9, Result);
  if CharPos <> 0 then
    Delete(Result, CharPos, Length(Result));

  CharPos := System.Pos(' ', Result);
  Result := Copy(Result, CharPos + 1, Length(Result));

  CharPos := System.Pos('(', Result);
  if CharPos > 0 then
    Result := Copy(Result, 1, CharPos - 1);

  CharPos := System.Pos('.', Result);
  if CharPos > 0 then
    Result := Copy(Result, CharPos + 1, Length(Result));

  Result := Trim(Result);
end;

function tprocedurelistfo.GetTickCount: LongWord;
begin
  Result := LongWord(Trunc(Now * MSecsPerDay));
end;

procedure tprocedurelistfo.formdestroy(const sender: TObject);
var
  i: Integer;
begin
{$ifdef gTrace}
writeln('>> FormDestroy');
{$endif}
  FreeAndNil(FObjectStrings);
  if FProcList <> nil then
  begin
    for i := 0 to FProcList.Count - 1 do
      FProcList.Objects[i].Free;
    FreeAndNil(FProcList);
  end;
/////////  inherited Destroy;
{$ifdef gTrace}
writeln('<< FormDestroy');
{$endif}
end;

procedure tprocedurelistfo.FilterTextChanged(const sender: tcustomedit;
               var atext: msestring);
begin
  FillGrid;
end;

procedure tprocedurelistfo.FilterTextKeyDown(const sender: twidget;
               var ainfo: keyeventinfoty);
begin
  include(ainfo.eventstate,es_processed);
  case ainfo.key of
    key_Up:
        begin
          grdProcedures.rowup();
//          edtSearch.SetFocus;
        end;
    key_Down:
        begin
          grdProcedures.rowdown();
//          edtSearch.SetFocus;
        end;
    key_Return:
        begin
          { Jump to the line of code for the procedure we selected. }
          JumpToSelectedLine;
          Close;
        end;
{
   key_Escape:
        begin
          Close;
        end;
}
     else
         begin
             exclude(ainfo.eventstate,es_processed); //unknown key
         end;
  end;
end;

procedure tprocedurelistfo.ResultGridKeyDown(const sender: twidget;
               var ainfo: keyeventinfoty);
begin
  include(ainfo.eventstate,es_processed);
  case ainfo.key of
    key_Return:
        begin
          { Jump to the line of code for the procedure we selected. }
          JumpToSelectedLine;
          Close;
        end;
     else
        begin
          exclude(ainfo.eventstate,es_processed); //unknown key
        end;
  end;
end;

procedure tprocedurelistfo.JumpToSelectedLine;
var
  int1: int32;
  lGotoLine: integer;
  c: gridcoordty;
begin
  c.row := grdProcedures.Row;
  c.col := 3;
  lGotoLine := StrToInt(grdProcedures.Items[c]);
  int1 := sourcefo.activepage.grid.rowwindowpos;
  sourcefo.activepage.grid.row := lGotoLine;
  sourcefo.activepage.grid.rowwindowpos := int1;
end;

{ TSimpleEngine }

function TSimpleEngine.CreateElement(AClass: TPTreeElement;
  const AName: String; AParent: TPasElement; AVisibility: TPasMemberVisibility;
  const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement;
begin
  Result := AClass.Create(AName, AParent);
  Result.Visibility := AVisibility;
  Result.SourceFilename := ASourceFilename;
  Result.SourceLinenumber := ASourceLinenumber;
end;

function TSimpleEngine.FindElement(const AName: String): TPasElement;
begin
  { dummy implementation, see TFPDocEngine.FindElement for a real example }
  Result := nil;
end;

end.
