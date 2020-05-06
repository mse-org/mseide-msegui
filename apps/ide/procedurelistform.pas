unit procedurelistform;
{ by Graeme Geldenhuys 2020 }

{$mode objfpc}{$h+}

// if enabled shows more debug output to the console window
{.$define gdebug}

// debug info to see what is called when
{.$define gTrace}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6018 off}
 {$endif}
{$endif}

uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msegui,
 msegraphics,msegraphutils,mseclasses,mseforms,msetoolbar,mseevent,
 msesimplewidgets,mseedit,msestrings,sysutils,
 msedataedits,msegrids,pparser, pastree,
 Classes,msedispwidgets,mserichstring,msegridsglob;

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
    FName: msestring;
    FDisplayName: msestring;
    FProcedureType: msestring;
    FProcArgs: msestring;
    FProcClass: msestring;
    FProcReturnType: msestring;
    FProcName: msestring;
    FProcIndex: Integer;
  public
    property LineNo: Integer read FLineNo write FLineNo;
    property Name: msestring read FName write FName;
    property DisplayName: msestring read FDisplayName write FDisplayName;
    property ProcedureType: msestring read FProcedureType write FProcedureType;
    property ProcArgs: msestring read FProcArgs write FProcArgs;
    property ProcName: msestring read FProcName write FProcName;
    property ProcClass: msestring read FProcClass write FProcClass;
    property ProcReturnType: msestring read FProcReturnType write FProcReturnType;
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
   procedure DoubleClickedSelection(const sender: TObject;
                   var info: celleventinfoty);
   procedure onchangeev(const sender: TObject);
 private
    FFilename: string;
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
    function  GetMethodName(const ProcName: msestring): msestring;
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

  {$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6018 off}
 {$endif}
{$endif}

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
    FFilename := ansistring(sourcefo.activepage.filepath)
  else
    Close;
  LoadTime := GetTickCount;
  InitializeForm;
  LoadTime := GetTickCount - LoadTime;
  lblStatus.Text := UTF8Decode(Format(SParseStatistics, [LoadTime / 1000]));
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
  ProcName: msestring;
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
     grdProcedures.Items[c] := UTF8Decode(IntToStr(i));
     c.col := 1;
     grdProcedures.Items[c] := (ProcInfo.DisplayName);
     c.col := 2;
     grdProcedures.Items[c] := (ProcInfo.ProcedureType);
     c.col := 3;
     grdProcedures.Items[c] := UTF8Decode(IntToStr(ProcInfo.LineNo));
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
        else if not SameText(ansistring(cbObjects.Text), ansistring(ProcInfo.ProcClass)) then
          Continue;
      end;

      case Language of
        ltPas: ProcName := GetMethodName(ProcName);
        ltCpp: ProcName := ProcInfo.ProcName;
      end;

      if Length(edtSearch.Text) = 0 then
        AddListItem(ProcInfo)
      else if not FSearchAll and SameText(ansistring(edtSearch.Text), ansistring(Copy(ProcName, 1, Length(edtSearch.Text)))) then
        AddListItem(ProcInfo)
      else if FSearchAll and StrContains(ansistring(edtSearch.Text), ansistring(ProcName), False) then
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

    function GetProperProcName(ProcType: TTokenKind; IsClass: Boolean): msestring;
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
          else; // Case statment added to make compiler happy...
        end;
      end;
    end;

  var
    ProcLine: msestring;
    ProcType: TTokenKind;
    Line: Integer;
    ClassLast: Boolean;
    InParenthesis: Boolean;
    InTypeDeclaration: Boolean;
    FoundNonEmptyType: Boolean;
    IdentifierNeeded: Boolean;
    ProcedureInfo: TProcInfo;

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
                    ProcLine := ProcLine + UTF8Decode(Parser.Token);
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
    else; // Case statment added to make compiler happy...
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
        else; // Case statment added to make compiler happy...
      end;
      Caption := Caption + ' - ' + UTF8Decode(ExtractFileName(FFileName));

      ClearObjectStrings;
      try
        FindProcs;
      finally
        LoadObjectCombobox;
      end;

      QuickSort(0, FProcList.Count - 1);
      lblStatus.Text := UTF8Decode(Trim(IntToStr(grdProcedures.RowCount)));
    finally
      MemStream.Free;
    end;
  finally
    case Language of
      ltPas: Parser.Free;
//      ltCpp: CParser.Free;
      else; // Case statment added to make compiler happy...
    end;
  end;
  {$ifdef gTrace}
  writeln('<< LoadProcs');
  {$endif}
end;

procedure tprocedurelistfo.AddProcedure(ProcedureInfo: TProcInfo);
var
  TempStr: msestring;
  i: Integer;
begin
 ProcedureInfo.Name := UTF8Decode(CompressWhiteSpace(ansistring(ProcedureInfo.Name)));
  case Language of
    ltPas:
      begin
        TempStr := ProcedureInfo.Name;
        // Remove the class reserved word
        if StrBeginsWith('CLASS ', ansistring(TempStr), False) then // Do not localize.
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
        ProcedureInfo.DisplayName := (TempStr);
        // Add to the object combobox and set the object name in ProcedureInfo
        i := System.Pos('.', TempStr);
        if i = 0 then
          FObjectStrings.Add(SNoneString)
        else
        begin
          ProcedureInfo.ProcClass := (Copy(TempStr, 1, i - 1));
          FObjectStrings.Add(ansistring(ProcedureInfo.ProcClass));
        end;
      FProcList.AddObject(ansistring(#9 + TempStr + #9 + (ProcedureInfo.ProcedureType) + #9 + UTF8Decode(IntToStr(ProcedureInfo.LineNo))), ProcedureInfo);

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

  function GetValue(idx: Integer): msestring;
  var
    i: Integer;
    TabPos: Integer;
  begin
    if idx >= FProcList.Count then
      raise Exception.Create(SInvalidIndex);
    Result := UTF8Decode(FProcList.Strings[idx]);
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
  P: msestring;
begin
  if FProcList.Count = 0 then
    Exit;
  repeat
    I := L;
    J := R;
    P := GetValue((L + R) shr 1);
    repeat
      while AnsiCompareText(ansistring(GetValue(I)), ansistring(P)) < 0 do
        Inc(I);
      while AnsiCompareText(ansistring(GetValue(J)), ansistring(P)) > 0 do
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
    cbObjects.dropdown.cols.addrow([UTF8Decode(FObjectStrings[i])]);
  cbObjects.dropdown.cols.EndUpdate;
  cbObjects.dropdown.ItemIndex := 0;
end;

function tprocedurelistfo.GetMethodName(const ProcName: msestring): msestring;
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
   key_Escape:
        begin
          Close;
        end;
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
  c, c2: gridcoordty;
begin
  c.row := grdProcedures.Row;
  c.col := 3;
  lGotoLine := StrToInt(ansistring(grdProcedures.Items[c]));
  c2.row := lGotoLine-1; // for color row selected
  c2.col := 1;
  { record current cursor position relative to source editor. We will restore this after the jump. }
  int1 := sourcefo.activepage.grid.rowwindowpos;
  sourcefo.activepage.grid.row := lGotoLine-1;
  sourcefo.activepage.grid.rowwindowpos := int1;
  sourcefo.activepage.grid.selectcell(c2, csm_select, False); // color of row selected
end;

procedure tprocedurelistfo.DoubleClickedSelection(const sender: TObject;
               var info: celleventinfoty);
begin
  if info.eventkind = cek_buttonrelease then
    if info.mouseeventinfopo^.shiftstate = [ss_double] then
    begin
      { Jump to the line of code for the procedure we selected. }
      JumpToSelectedLine;
      Close;
    end;
end;

procedure tprocedurelistfo.onchangeev(const sender: TObject);
begin
FillGrid;
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
