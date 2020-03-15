unit mdbf_prscore;

{--------------------------------------------------------------
| TCustomExpressionParser
|
| - contains core expression parser
|
| This code is based on code from:
|
| Original author: Egbert van Nes
| With contributions of: John Bultena and Ralf Junker
| Homepage: http://www.slm.wau.nl/wkao/parseexpr.html
|
| see also: http://www.datalog.ro/delphi/parser.html
|   (Renate Schaaf (schaaf at math.usu.edu), 1993
|    Alin Flaider (aflaidar at datalog.ro), 1996
|    Version 9-10: Stefan Hoffmeister, 1996-1997)
|
|  Modified 2013 by Martin Schreiber
|
|---------------------------------------------------------------}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

{$I dbf_common.inc}

uses
  SysUtils,
  classes,mclasses,
  mdb,
  mdbf_prssupp,
  mdbf_prsdef;

{$define ENG_NUMBERS}

// ENG_NUMBERS will force the use of english style numbers 8.1 instead of 8,1
//   (if the comma is your decimal separator)
// the advantage is that arguments can be separated with a comma which is
// fairly common, otherwise there is ambuigity: what does 'var1,8,4,4,5' mean?
// if you don't define ENG_NUMBERS and DecimalSeparator is a comma then
// the argument separator will be a semicolon ';'

type

  TCustomExpressionParser = class(TObject)
  private
    FHexChar: Char;
    FArgSeparator: Char;
    FDecimalSeparator: Char;
    FOptimize: Boolean;
    FConstantsList: TOCollection;
    FLastRec: PExpressionRec;
    FCurrentRec: PExpressionRec;
    FExpResult: PChar;
    FExpResultPos: PChar;
    FExpResultSize: Integer;

    procedure ParseString(AnExpression: string; DestCollection: TExprCollection);
    function  MakeTree(Expr: TExprCollection; FirstItem, LastItem: Integer): PExpressionRec;
    procedure MakeLinkedList(var ExprRec: PExpressionRec; Memory: PPChar;
        MemoryPos: PPChar; MemSize: PInteger);
    procedure Check(AnExprList: TExprCollection);
    procedure CheckArguments(ExprRec: PExpressionRec);
    procedure RemoveConstants(var ExprRec: PExpressionRec);
    function ResultCanVary(ExprRec: PExpressionRec): Boolean;
  protected
    FWordsList: TSortedCollection;

    function MakeRec: PExpressionRec; virtual;
    procedure FillExpressList; virtual; abstract;
    procedure HandleUnknownVariable(VarName: string); virtual; abstract;

    procedure CompileExpression(AnExpression: string);
    procedure EvaluateCurrent;
    procedure DisposeList(ARec: PExpressionRec);
    procedure DisposeTree(ExprRec: PExpressionRec);
    function CurrentExpression: string; virtual; abstract;
    function GetResultType: TExpressionType; virtual;

    property CurrentRec: PExpressionRec read FCurrentRec write FCurrentRec;
    property LastRec: PExpressionRec read FLastRec write FLastRec;
    property ExpResult: PChar read FExpResult;
    property ExpResultPos: PChar read FExpResultPos write FExpResultPos;

  public
    constructor Create;
    destructor Destroy; override;

    function DefineFloatVariable(AVarName: string; AValue: PDouble): TExprWord;
    function DefineIntegerVariable(AVarName: string; AValue: PInteger): TExprWord;
//    procedure DefineSmallIntVariable(AVarName: string; AValue: PSmallInt);
{$ifdef SUPPORT_INT64}
    function DefineLargeIntVariable(AVarName: string; AValue: PLargeInt): TExprWord;
{$endif}
    function DefineDateTimeVariable(AVarName: string; AValue: PDateTimeRec): TExprWord;
    function DefineBooleanVariable(AVarName: string; AValue: PBoolean): TExprWord;
    function DefineStringVariable(AVarName: string; AValue: PPChar): TExprWord;
    function DefineFunction(AFunctName, AShortName, ADescription, ATypeSpec: string;
        AMinFunctionArg: Integer; AResultType: TExpressionType; AFuncAddress: TExprFunc): TExprWord;
    procedure Evaluate(AnExpression: string);
    function AddExpression(AnExpression: string): Integer;
    procedure ClearExpressions; virtual;
//    procedure GetGeneratedVars(AList: TList);
    procedure GetFunctionNames(AList: TStrings);
    function GetFunctionDescription(AFunction: string): string;
    property HexChar: Char read FHexChar write FHexChar;
    property ArgSeparator: Char read FArgSeparator write FArgSeparator;
    property Optimize: Boolean read FOptimize write FOptimize;
    property ResultType: TExpressionType read GetResultType;


    //if optimize is selected, constant expressions are tried to remove
    //such as: 4*4*x is evaluated as 16*x and exp(1)-4*x is repaced by 2.17 -4*x
  end;


//--Expression functions-----------------------------------------------------

procedure FuncFloatToStr(Param: PExpressionRec);
procedure FuncIntToStr_Gen(Param: PExpressionRec; Val: {$ifdef SUPPORT_INT64}Int64{$else}Integer{$endif});
procedure FuncIntToStr(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure FuncInt64ToStr(Param: PExpressionRec);
{$endif}
procedure FuncDateToStr(Param: PExpressionRec);
procedure FuncSubString(Param: PExpressionRec);
procedure FuncUppercase(Param: PExpressionRec);
procedure FuncLowercase(Param: PExpressionRec);
procedure FuncAdd_F_FF(Param: PExpressionRec);
procedure FuncAdd_F_FI(Param: PExpressionRec);
procedure FuncAdd_F_II(Param: PExpressionRec);
procedure FuncAdd_F_IF(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure FuncAdd_F_FL(Param: PExpressionRec);
procedure FuncAdd_F_IL(Param: PExpressionRec);
procedure FuncAdd_F_LL(Param: PExpressionRec);
procedure FuncAdd_F_LF(Param: PExpressionRec);
procedure FuncAdd_F_LI(Param: PExpressionRec);
{$endif}
procedure FuncSub_F_FF(Param: PExpressionRec);
procedure FuncSub_F_FI(Param: PExpressionRec);
procedure FuncSub_F_II(Param: PExpressionRec);
procedure FuncSub_F_IF(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure FuncSub_F_FL(Param: PExpressionRec);
procedure FuncSub_F_IL(Param: PExpressionRec);
procedure FuncSub_F_LL(Param: PExpressionRec);
procedure FuncSub_F_LF(Param: PExpressionRec);
procedure FuncSub_F_LI(Param: PExpressionRec);
{$endif}
procedure FuncMul_F_FF(Param: PExpressionRec);
procedure FuncMul_F_FI(Param: PExpressionRec);
procedure FuncMul_F_II(Param: PExpressionRec);
procedure FuncMul_F_IF(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure FuncMul_F_FL(Param: PExpressionRec);
procedure FuncMul_F_IL(Param: PExpressionRec);
procedure FuncMul_F_LL(Param: PExpressionRec);
procedure FuncMul_F_LF(Param: PExpressionRec);
procedure FuncMul_F_LI(Param: PExpressionRec);
{$endif}
procedure FuncDiv_F_FF(Param: PExpressionRec);
procedure FuncDiv_F_FI(Param: PExpressionRec);
procedure FuncDiv_F_II(Param: PExpressionRec);
procedure FuncDiv_F_IF(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure FuncDiv_F_FL(Param: PExpressionRec);
procedure FuncDiv_F_IL(Param: PExpressionRec);
procedure FuncDiv_F_LL(Param: PExpressionRec);
procedure FuncDiv_F_LF(Param: PExpressionRec);
procedure FuncDiv_F_LI(Param: PExpressionRec);
{$endif}
procedure FuncStrI_EQ(Param: PExpressionRec);
procedure FuncStrI_NEQ(Param: PExpressionRec);
procedure FuncStrI_LT(Param: PExpressionRec);
procedure FuncStrI_GT(Param: PExpressionRec);
procedure FuncStrI_LTE(Param: PExpressionRec);
procedure FuncStrI_GTE(Param: PExpressionRec);
procedure FuncStrIP_EQ(Param: PExpressionRec);
procedure FuncStrP_EQ(Param: PExpressionRec);
procedure FuncStr_EQ(Param: PExpressionRec);
procedure FuncStr_NEQ(Param: PExpressionRec);
procedure FuncStr_LT(Param: PExpressionRec);
procedure FuncStr_GT(Param: PExpressionRec);
procedure FuncStr_LTE(Param: PExpressionRec);
procedure FuncStr_GTE(Param: PExpressionRec);
procedure Func_FF_EQ(Param: PExpressionRec);
procedure Func_FF_NEQ(Param: PExpressionRec);
procedure Func_FF_LT(Param: PExpressionRec);
procedure Func_FF_GT(Param: PExpressionRec);
procedure Func_FF_LTE(Param: PExpressionRec);
procedure Func_FF_GTE(Param: PExpressionRec);
procedure Func_FI_EQ(Param: PExpressionRec);
procedure Func_FI_NEQ(Param: PExpressionRec);
procedure Func_FI_LT(Param: PExpressionRec);
procedure Func_FI_GT(Param: PExpressionRec);
procedure Func_FI_LTE(Param: PExpressionRec);
procedure Func_FI_GTE(Param: PExpressionRec);
procedure Func_II_EQ(Param: PExpressionRec);
procedure Func_II_NEQ(Param: PExpressionRec);
procedure Func_II_LT(Param: PExpressionRec);
procedure Func_II_GT(Param: PExpressionRec);
procedure Func_II_LTE(Param: PExpressionRec);
procedure Func_II_GTE(Param: PExpressionRec);
procedure Func_IF_EQ(Param: PExpressionRec);
procedure Func_IF_NEQ(Param: PExpressionRec);
procedure Func_IF_LT(Param: PExpressionRec);
procedure Func_IF_GT(Param: PExpressionRec);
procedure Func_IF_LTE(Param: PExpressionRec);
procedure Func_IF_GTE(Param: PExpressionRec);
{$ifdef SUPPORT_INT64}
procedure Func_LL_EQ(Param: PExpressionRec);
procedure Func_LL_NEQ(Param: PExpressionRec);
procedure Func_LL_LT(Param: PExpressionRec);
procedure Func_LL_GT(Param: PExpressionRec);
procedure Func_LL_LTE(Param: PExpressionRec);
procedure Func_LL_GTE(Param: PExpressionRec);
procedure Func_LF_EQ(Param: PExpressionRec);
procedure Func_LF_NEQ(Param: PExpressionRec);
procedure Func_LF_LT(Param: PExpressionRec);
procedure Func_LF_GT(Param: PExpressionRec);
procedure Func_LF_LTE(Param: PExpressionRec);
procedure Func_LF_GTE(Param: PExpressionRec);
procedure Func_FL_EQ(Param: PExpressionRec);
procedure Func_FL_NEQ(Param: PExpressionRec);
procedure Func_FL_LT(Param: PExpressionRec);
procedure Func_FL_GT(Param: PExpressionRec);
procedure Func_FL_LTE(Param: PExpressionRec);
procedure Func_FL_GTE(Param: PExpressionRec);
procedure Func_LI_EQ(Param: PExpressionRec);
procedure Func_LI_NEQ(Param: PExpressionRec);
procedure Func_LI_LT(Param: PExpressionRec);
procedure Func_LI_GT(Param: PExpressionRec);
procedure Func_LI_LTE(Param: PExpressionRec);
procedure Func_LI_GTE(Param: PExpressionRec);
procedure Func_IL_EQ(Param: PExpressionRec);
procedure Func_IL_NEQ(Param: PExpressionRec);
procedure Func_IL_LT(Param: PExpressionRec);
procedure Func_IL_GT(Param: PExpressionRec);
procedure Func_IL_LTE(Param: PExpressionRec);
procedure Func_IL_GTE(Param: PExpressionRec);
{$endif}
procedure Func_AND(Param: PExpressionRec);
procedure Func_OR(Param: PExpressionRec);
procedure Func_NOT(Param: PExpressionRec);

var
  DbfWordsSensGeneralList, DbfWordsInsensGeneralList: TExpressList;
  DbfWordsSensPartialList, DbfWordsInsensPartialList: TExpressList;
  DbfWordsSensNoPartialList, DbfWordsInsensNoPartialList: TExpressList;
  DbfWordsGeneralList: TExpressList;

implementation
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

procedure LinkVariable(ExprRec: PExpressionRec);
begin
  with ExprRec^ do
  begin
    if ExprWord.IsVariable then
    begin
      // copy pointer to variable
      Args[0] := ExprWord.AsPointer;
      // store length as second parameter
      Args[1] := PChar(ExprWord.LenAsPointer);
    end;
  end;
end;

procedure LinkVariables(ExprRec: PExpressionRec);
var
  I: integer;
begin
  with ExprRec^ do
  begin
    I := 0;
    while (I < MaxArg) and (ArgList[I] <> nil) do
    begin
      LinkVariables(ArgList[I]);
      Inc(I);
    end;
  end;
  LinkVariable(ExprRec);
end;

{ TCustomExpressionParser }

constructor TCustomExpressionParser.Create;
begin
  inherited;

  FHexChar := '$';
{$IFDEF ENG_NUMBERS}
  FDecimalSeparator := '.';
  FArgSeparator := ',';
{$ELSE}
  FDecimalSeparator := DecimalSeparator;
  if DecimalSeparator = ',' then
    FArgSeparator := ';'
  else
    FArgSeparator := ',';
{$ENDIF}
  FConstantsList := TOCollection.Create;
  FWordsList := TExpressList.Create;
  GetMem(FExpResult, ArgAllocSize);
  FExpResultPos := FExpResult;
  FExpResultSize := ArgAllocSize;
  FOptimize := true;
  FillExpressList;
end;

destructor TCustomExpressionParser.Destroy;
begin
  ClearExpressions;
  FreeMem(FExpResult);
  FConstantsList.Free;
  FWordsList.Free;

  inherited;
end;

procedure TCustomExpressionParser.CompileExpression(AnExpression: string);
var
  ExpColl: TExprCollection;
  ExprTree: PExpressionRec;
begin
  if Length(AnExpression) > 0 then
  begin
    ExprTree := nil;
    ExpColl := TExprCollection.Create;
    try
      //    FCurrentExpression := anExpression;
      ParseString(AnExpression, ExpColl);
      Check(ExpColl);
      ExprTree := MakeTree(ExpColl, 0, ExpColl.Count - 1);
      FCurrentRec := nil;
      CheckArguments(ExprTree);
      LinkVariables(ExprTree);
      if Optimize then
        RemoveConstants(ExprTree);
      // all constant expressions are evaluated and replaced by variables
      FCurrentRec := nil;
      FExpResultPos := FExpResult;
      MakeLinkedList(ExprTree, @FExpResult, @FExpResultPos, @FExpResultSize);
    except
      on E: Exception do
      begin
        DisposeTree(ExprTree);
        ExpColl.Free;
        raise;
      end;
    end;
    ExpColl.Free;
  end;
end;

procedure TCustomExpressionParser.CheckArguments(ExprRec: PExpressionRec);
var
  TempExprWord: TExprWord;
  I, error, firstFuncIndex, funcIndex: Integer;
  foundAltFunc: Boolean;

  procedure FindAlternate;
  begin
    // see if we can find another function
    if funcIndex < 0 then
    begin
      firstFuncIndex := FWordsList.IndexOf(ExprRec^.ExprWord);
      funcIndex := firstFuncIndex;
    end;
    // check if not last function
    if (0 <= funcIndex) and (funcIndex < FWordsList.Count - 1) then
    begin
      inc(funcIndex);
      TempExprWord := TExprWord(FWordsList.Items[funcIndex]);
      if FWordsList.Compare(FWordsList.KeyOf(ExprRec^.ExprWord), FWordsList.KeyOf(TempExprWord)) = 0 then
      begin
        ExprRec^.ExprWord := TempExprWord;
        ExprRec^.Oper := ExprRec^.ExprWord.ExprFunc;
        foundAltFunc := true;
      end;
    end;
  end;

  procedure InternalCheckArguments;
  begin
    I := 0;
    error := 0;
    foundAltFunc := false;
    with ExprRec^ do
    begin
      if WantsFunction <> (ExprWord.IsFunction and not ExprWord.IsOperator) then
      begin
        error := 4;
        exit;
      end;

      while (I < ExprWord.MaxFunctionArg) and (ArgList[I] <> nil) and (error = 0) do
      begin
        // test subarguments first
        CheckArguments(ArgList[I]);

        // test if correct type
        if (ArgList[I]^.ExprWord.ResultType <> ExprCharToExprType(ExprWord.TypeSpec[I+1])) then
          error := 2;

        // goto next argument
        Inc(I);
      end;

      // test if enough parameters passed; I = num args user passed
      if (error = 0) and (I < ExprWord.MinFunctionArg) then
        error := 1;

      // test if too many parameters passed
      if (error = 0) and (I > ExprWord.MaxFunctionArg) then
        error := 3;
    end;
  end;

begin
  funcIndex := -1;
  repeat
    InternalCheckArguments;

    // error occurred?
    if error <> 0 then
      FindAlternate;
  until (error = 0) or not foundAltFunc;

  // maybe it's an undefined variable
  if (error <> 0) and not ExprRec^.WantsFunction and (firstFuncIndex >= 0) then
  begin
    HandleUnknownVariable(ExprRec^.ExprWord.Name);
    { must not add variable as first function in this set of duplicates,
      otherwise following searches will not find it }
    FWordsList.Exchange(firstFuncIndex, firstFuncIndex+1);
    ExprRec^.ExprWord := TExprWord(FWordsList.Items[firstFuncIndex+1]);
    ExprRec^.Oper := ExprRec^.ExprWord.ExprFunc;
    InternalCheckArguments;
  end;

  // fatal error?
  case error of
    1: raise EParserException.Create('Function or operand has too few arguments');
    2: raise EParserException.Create('Argument type mismatch');
    3: raise EParserException.Create('Function or operand has too many arguments');
    4: raise EParserException.Create('No function with this name, remove brackets for variable');
  end;
end;

function TCustomExpressionParser.ResultCanVary(ExprRec: PExpressionRec):
  Boolean;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    Result := ExprWord.CanVary;
    if not Result then
      for I := 0 to ExprWord.MaxFunctionArg - 1 do
        if (ArgList[I] <> nil) and ResultCanVary(ArgList[I]) then
        begin
          Result := true;
          Exit;
        end
  end;
end;

procedure TCustomExpressionParser.RemoveConstants(var ExprRec: PExpressionRec);
var
  I: Integer;
begin
  if not ResultCanVary(ExprRec) then
  begin
    if not ExprRec^.ExprWord.IsVariable then
    begin
      // reset current record so that make list generates new
      FCurrentRec := nil;
      FExpResultPos := FExpResult;
      MakeLinkedList(ExprRec, @FExpResult, @FExpResultPos, @FExpResultSize);

      try
        // compute result
        EvaluateCurrent;

        // make new record to store constant in
        ExprRec := MakeRec;

        // check result type
        with ExprRec^ do
        begin
          case ResultType of
            etBoolean: ExprWord := TBooleanConstant.Create(EmptyStr, PBoolean(FExpResult)^);
            etFloat: ExprWord := TFloatConstant.CreateAsDouble(EmptyStr, PDouble(FExpResult)^);
            etString: ExprWord := TStringConstant.Create(FExpResult);
          end;

          // fill in structure
          Oper := ExprWord.ExprFunc;
          Args[0] := ExprWord.AsPointer;
          FConstantsList.Add(ExprWord);
        end;
      finally
        DisposeList(FCurrentRec);
        FCurrentRec := nil;
      end;
    end;
  end else
    with ExprRec^ do
    begin
      for I := 0 to ExprWord.MaxFunctionArg - 1 do
        if ArgList[I] <> nil then
          RemoveConstants(ArgList[I]);
    end;
end;

procedure TCustomExpressionParser.DisposeTree(ExprRec: PExpressionRec);
var
  I: Integer;
begin
  if ExprRec <> nil then
  begin
    with ExprRec^ do
    begin
      if ExprWord <> nil then
        for I := 0 to ExprWord.MaxFunctionArg - 1 do
          DisposeTree(ArgList[I]);
      if Res <> nil then
        Res.Free;
    end;
    Dispose(ExprRec);
  end;
end;

procedure TCustomExpressionParser.DisposeList(ARec: PExpressionRec);
var
  TheNext: PExpressionRec;
  I: Integer;
begin
  if ARec <> nil then
    repeat
      TheNext := ARec^.Next;
      if ARec^.Res <> nil then
        ARec^.Res.Free;
      I := 0;
      while ARec^.ArgList[I] <> nil do
      begin
        FreeMem(ARec^.Args[I]);
        Inc(I);
      end;
      Dispose(ARec);
      ARec := TheNext;
    until ARec = nil;
end;

procedure TCustomExpressionParser.MakeLinkedList(var ExprRec: PExpressionRec;
  Memory: PPChar; MemoryPos: PPChar; MemSize: PInteger);
var
  I: Integer;
begin
  // test function type
  if @ExprRec^.ExprWord.ExprFunc = nil then
  begin
    // special 'no function' function
    // indicates no function is present -> we can concatenate all instances
    // we don't create new arguments...these 'fall' through
    // use destination as we got it
    I := 0;
    while ExprRec^.ArgList[I] <> nil do
    begin
      // convert arguments to list
      MakeLinkedList(ExprRec^.ArgList[I], Memory, MemoryPos, MemSize);
      // goto next argument
      Inc(I);
    end;
    // don't need this record anymore
    Dispose(ExprRec);
    ExprRec := nil;
  end else begin
    // inc memory pointer so we know if we are first
    ExprRec^.ResetDest := MemoryPos^ = Memory^;
    Inc(MemoryPos^);
    // convert arguments to list
    I := 0;
    while ExprRec^.ArgList[I] <> nil do
    begin
      // save variable type for easy access
      ExprRec^.ArgsType[I] := ExprRec^.ArgList[I]^.ExprWord.ResultType;
      // check if we need to copy argument, variables in general do not
      // need copying, except for fixed len strings which are not
      // null-terminated
//      if ExprRec^.ArgList[I].ExprWord.NeedsCopy then
//      begin
        // get memory for argument
        GetMem(ExprRec^.Args[I], ArgAllocSize);
        ExprRec^.ArgsPos[I] := ExprRec^.Args[I];
        ExprRec^.ArgsSize[I] := ArgAllocSize;
        MakeLinkedList(ExprRec^.ArgList[I], @ExprRec^.Args[I], @ExprRec^.ArgsPos[I],
            @ExprRec^.ArgsSize[I]);
//      end else begin
        // copy reference
//        ExprRec^.Args[I] := ExprRec^.ArgList[I].Args[0];
//        ExprRec^.ArgsPos[I] := ExprRec^.Args[I];
//        ExprRec^.ArgsSize[I] := 0;
//        FreeMem(ExprRec^.ArgList[I]);
//        ExprRec^.ArgList[I] := nil;
//      end;

      // goto next argument
      Inc(I);
    end;

    // link result to target argument
    ExprRec^.Res := TDynamicType.Create(Memory, MemoryPos, MemSize);

    // link to next operation
    if FCurrentRec = nil then
    begin
      FCurrentRec := ExprRec;
      FLastRec := ExprRec;
    end else begin
      FLastRec^.Next := ExprRec;
      FLastRec := ExprRec;
    end;
  end;
end;

function TCustomExpressionParser.MakeTree(Expr: TExprCollection;
  FirstItem, LastItem: Integer): PExpressionRec;

{
- This is the most complex routine, it breaks down the expression and makes
  a linked tree which is used for fast function evaluations
- it is implemented recursively
}

var
  I, IArg, IStart, IEnd, lPrec, brCount: Integer;
  ExprWord: TExprWord;
begin
  // remove redundant brackets
  brCount := 0;
  while (FirstItem+brCount < LastItem) and (TExprWord(
      Expr.Items[FirstItem+brCount]).ResultType = etLeftBracket) do
    Inc(brCount);
  I := LastItem;
  while (I > FirstItem) and (TExprWord(
      Expr.Items[I]).ResultType = etRightBracket) do
    Dec(I);
  // test max of start and ending brackets
  if brCount > (LastItem-I) then
    brCount := LastItem-I;
  // count number of bracket pairs completely open from start to end
  // IArg is min.brCount
  I := FirstItem + brCount;
  IArg := brCount;
  while (I <= LastItem - brCount) and (brCount > 0) do
  begin
    case TExprWord(Expr.Items[I]).ResultType of
      etLeftBracket: Inc(brCount);
      etRightBracket:
        begin
          Dec(brCount);
          if brCount < IArg then
            IArg := brCount;
        end;
    end;
    Inc(I);
  end;
  // useful pair bracket count, is in minimum, is IArg
  brCount := IArg;
  // check if subexpression closed within (bracket level will be zero)
  if brCount > 0 then
  begin
    Inc(FirstItem, brCount);
    Dec(LastItem, brCount);
  end;

  // check for empty range
  if LastItem < FirstItem then
  begin
    Result := nil;
    exit;
  end;

  // get new record
  Result := MakeRec;

  // simple constant, variable or function?
  if LastItem = FirstItem then
  begin
    Result^.ExprWord := TExprWord(Expr.Items[FirstItem]);
    Result^.Oper := Result^.ExprWord.ExprFunc;
    exit;
  end;

  // no...more complex, find operator with lowest precedence
  brCount := 0;
  IArg := 0;
  IEnd := FirstItem-1;
  lPrec := -1;
  for I := FirstItem to LastItem do
  begin
    ExprWord := TExprWord(Expr.Items[I]);
    if (brCount = 0) and ExprWord.IsOperator and (TFunction(ExprWord).OperPrec > lPrec) then
    begin
      IEnd := I;
      lPrec := TFunction(ExprWord).OperPrec;
    end;
    case ExprWord.ResultType of
      etLeftBracket: Inc(brCount);
      etRightBracket: Dec(brCount);
    end;
  end;

  // operator found ?
  if IEnd >= FirstItem then
  begin
    // save operator
    Result^.ExprWord := TExprWord(Expr.Items[IEnd]);
    Result^.Oper := Result^.ExprWord.ExprFunc;
    // recurse into left part if present
    if IEnd > FirstItem then
    begin
      Result^.ArgList[IArg] := MakeTree(Expr, FirstItem, IEnd-1);
      Inc(IArg);
    end;
    // recurse into right part if present
    if IEnd < LastItem then
      Result^.ArgList[IArg] := MakeTree(Expr, IEnd+1, LastItem);
  end else
  if TExprWord(Expr.Items[FirstItem]).IsFunction then
  begin
    // save function
    Result^.ExprWord := TExprWord(Expr.Items[FirstItem]);
    Result^.Oper := Result^.ExprWord.ExprFunc;
    Result^.WantsFunction := true;
    // parse function arguments
    IEnd := FirstItem + 1;
    IStart := IEnd;
    brCount := 0;
    if TExprWord(Expr.Items[IEnd]).ResultType = etLeftBracket then
    begin
      // opening bracket found, first argument expression starts at next index
      Inc(brCount);
      Inc(IStart);
      while (IEnd < LastItem) and (brCount <> 0) do
      begin
        Inc(IEnd);
        case TExprWord(Expr.Items[IEnd]).ResultType of
          etLeftBracket: Inc(brCount);
          etComma:
            if brCount = 1 then
            begin
              // argument separation found, build tree of argument expression
              Result^.ArgList[IArg] := MakeTree(Expr, IStart, IEnd-1);
              Inc(IArg);
              IStart := IEnd + 1;
            end;
          etRightBracket: Dec(brCount);
        end;
      end;

      // parse last argument
      Result^.ArgList[IArg] := MakeTree(Expr, IStart, IEnd-1);
    end;
  end else
    raise EParserException.Create('Operator/function missing');
end;

procedure TCustomExpressionParser.ParseString(AnExpression: string; DestCollection: TExprCollection);
var
  isConstant: Boolean;
  I, I1, I2, Len, DecSep: Integer;
  W, S: string;
  TempWord: TExprWord;

  procedure ReadConstant(AnExpr: string; isHex: Boolean);
  begin
    isConstant := true;
    while (I2 <= Len) and ((AnExpr[I2] in ['0'..'9']) or
      (isHex and (AnExpr[I2] in ['a'..'f', 'A'..'F']))) do
      Inc(I2);
    if I2 <= Len then
    begin
      if AnExpr[I2] = FDecimalSeparator then
      begin
        Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
      if (I2 <= Len) and (AnExpr[I2] = 'e') then
      begin
        Inc(I2);
        if (I2 <= Len) and (AnExpr[I2] in ['+', '-']) then
          Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
    end;
  end;

  procedure ReadWord(AnExpr: string);
  var
    OldI2: Integer;
    constChar: Char;
  begin
    isConstant := false;
    I1 := I2;
    while (I1 < Len) and (AnExpr[I1] = ' ') do
      Inc(I1);
    I2 := I1;
    if I1 <= Len then
    begin
      if AnExpr[I2] = HexChar then
      begin
        Inc(I2);
        OldI2 := I2;
        ReadConstant(AnExpr, true);
        if I2 = OldI2 then
        begin
          isConstant := false;
          while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) do
            Inc(I2);
        end;
      end
      else if AnExpr[I2] = FDecimalSeparator then
        ReadConstant(AnExpr, false)
      else
        case AnExpr[I2] of
          '''', '"':
            begin
              isConstant := true;
              constChar := AnExpr[I2];
              Inc(I2);
              while (I2 <= Len) and (AnExpr[I2] <> constChar) do
                Inc(I2);
              if I2 <= Len then
                Inc(I2);
            end;
          'a'..'z', 'A'..'Z', '_':
            begin
              while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) do
                Inc(I2);
            end;
          '>', '<':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['=', '<', '>'] then
                Inc(I2);
            end;
          '=':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['<', '>', '='] then
                Inc(I2);
            end;
          '&':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['&'] then
                Inc(I2);
            end;
          '|':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['|'] then
                Inc(I2);
            end;
          ':':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then
                Inc(I2);
            end;
          '!':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then //support for !=
                Inc(I2);
            end;
          '+':
            begin
              Inc(I2);
              if (AnExpr[I2] = '+') and FWordsList.Search(PChar('++'), I) then
                Inc(I2);
            end;
          '-':
            begin
              Inc(I2);
              if (AnExpr[I2] = '-') and FWordsList.Search(PChar('--'), I) then
                Inc(I2);
            end;
          '^', '/', '\', '*', '(', ')', '%', '~', '$':
            Inc(I2);
          '0'..'9':
            ReadConstant(AnExpr, false);
        else
          begin
            Inc(I2);
          end;
        end;
    end;
  end;

begin
  I2 := 1;
  S := Trim(AnExpression);
  Len := Length(S);
  repeat
    ReadWord(S);
    W := Trim(Copy(S, I1, I2 - I1));
    if isConstant then
    begin
      if W[1] = HexChar then
      begin
        // convert hexadecimal to decimal
        W[1] := '$';
        W := IntToStr(StrToInt(W));
      end;
      if (W[1] = '''') or (W[1] = '"') then
        TempWord := TStringConstant.Create(W)
      else begin
        DecSep := Pos(FDecimalSeparator, W);
        if (DecSep > 0) then
        begin
{$IFDEF ENG_NUMBERS}
          // we'll have to convert FDecimalSeparator into DecimalSeparator
          // otherwise the OS will not understand what we mean
          W[DecSep] := DefaultFormatSettings.DecimalSeparator;
{$ENDIF}
          TempWord := TFloatConstant.Create(W, W)
        end else begin
          TempWord := TIntegerConstant.Create(StrToInt(W));
        end;
      end;
      DestCollection.Add(TempWord);
      FConstantsList.Add(TempWord);
    end
    else if Length(W) > 0 then
      if FWordsList.Search(PChar(W), I) then
      begin
        DestCollection.Add(FWordsList.Items[I])
      end else begin
        // unknown variable -> fire event
        HandleUnknownVariable(W);
        // try to search again
        if FWordsList.Search(PChar(W), I) then
        begin
          DestCollection.Add(FWordsList.Items[I])
        end else begin
          raise EParserException.Create('Unknown variable '''+W+''' found.');
        end;
      end;
  until I2 > Len;
end;

procedure TCustomExpressionParser.Check(AnExprList: TExprCollection);
var
  I, J, K, L: Integer;
begin
  AnExprList.Check;
  with AnExprList do
  begin
    I := 0;
    while I < Count do
    begin
      {----CHECK ON DOUBLE MINUS OR DOUBLE PLUS----}
      if ((TExprWord(Items[I]).Name = '-') or
        (TExprWord(Items[I]).Name = '+'))
        and ((I = 0) or
        (TExprWord(Items[I - 1]).ResultType = etComma) or
        (TExprWord(Items[I - 1]).ResultType = etLeftBracket) or
        (TExprWord(Items[I - 1]).IsOperator and (TExprWord(Items[I - 1]).MaxFunctionArg
        = 2))) then
      begin
        {replace e.g. ----1 with +1}
        if TExprWord(Items[I]).Name = '-' then
          K := -1
        else
          K := 1;
        L := 1;
        while (I + L < Count) and ((TExprWord(Items[I + L]).Name = '-')
          or (TExprWord(Items[I + L]).Name = '+')) and ((I + L = 0) or
          (TExprWord(Items[I + L - 1]).ResultType = etComma) or
          (TExprWord(Items[I + L - 1]).ResultType = etLeftBracket) or
          (TExprWord(Items[I + L - 1]).IsOperator and (TExprWord(Items[I + L -
          1]).MaxFunctionArg = 2))) do
        begin
          if TExprWord(Items[I + L]).Name = '-' then
            K := -1 * K;
          Inc(L);
        end;
        if L > 0 then
        begin
          Dec(L);
          for J := I + 1 to Count - 1 - L do
            Items[J] := Items[J + L];
          Count := Count - L;
        end;
        if K = -1 then
        begin
          if FWordsList.Search(pchar('-@'), J) then
            Items[I] := FWordsList.Items[J];
        end
        else if FWordsList.Search(pchar('+@'), J) then
          Items[I] := FWordsList.Items[J];
      end;
      {----CHECK ON DOUBLE NOT----}
      if (TExprWord(Items[I]).Name = 'not')
        and ((I = 0) or
        (TExprWord(Items[I - 1]).ResultType = etLeftBracket) or
        TExprWord(Items[I - 1]).IsOperator) then
      begin
        {replace e.g. not not 1 with 1}
        K := -1;
        L := 1;
        while (I + L < Count) and (TExprWord(Items[I + L]).Name = 'not') and ((I
          + L = 0) or
          (TExprWord(Items[I + L - 1]).ResultType = etLeftBracket) or
          TExprWord(Items[I + L - 1]).IsOperator) do
        begin
          K := -K;
          Inc(L);
        end;
        if L > 0 then
        begin
          if K = 1 then
          begin //remove all
            for J := I to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
          else
          begin //keep one
            Dec(L);
            for J := I + 1 to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
        end;
      end;
      {-----MISC CHECKS-----}
      if (TExprWord(Items[I]).IsVariable) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).IsVariable)) then
        raise EParserException.Create('Missing operator between '''+TExprWord(Items[I]).Name+''' and '''+TExprWord(Items[I]).Name+'''');
      if (TExprWord(Items[I]).ResultType = etLeftBracket) and (I >= Count - 1) then
        raise EParserException.Create('Missing closing bracket');
      if (TExprWord(Items[I]).ResultType = etRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).ResultType = etLeftBracket)) then
        raise EParserException.Create('Missing operator between )(');
      if (TExprWord(Items[I]).ResultType = etRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).IsVariable)) then
        raise EParserException.Create('Missing operator between ) and constant/variable');
      if (TExprWord(Items[I]).ResultType = etLeftBracket) and ((I > 0) and
        (TExprWord(Items[I - 1]).IsVariable)) then
        raise EParserException.Create('Missing operator between constant/variable and (');

      {-----CHECK ON INTPOWER------}
      if (TExprWord(Items[I]).Name = '^') and ((I < Count - 1) and
          (TExprWord(Items[I + 1]).ClassType = TIntegerConstant)) then
        if FWordsList.Search(PChar('^@'), J) then
          Items[I] := FWordsList.Items[J]; //use the faster intPower if possible
      Inc(I);
    end;
  end;
end;

procedure TCustomExpressionParser.EvaluateCurrent;
var
  TempRec: PExpressionRec;
begin
  if FCurrentRec <> nil then
  begin
    // get current record
    TempRec := FCurrentRec;
    // execute list
    repeat
      with TempRec^ do
      begin
        // do we need to reset pointer?
        if ResetDest then
          Res.MemoryPos^ := Res.Memory^;

        Oper(TempRec);

        // goto next
        TempRec := Next;
      end;
    until TempRec = nil;
  end;
end;

function TCustomExpressionParser.DefineFunction(AFunctName, AShortName, ADescription, ATypeSpec: string;
  AMinFunctionArg: Integer; AResultType: TExpressionType; AFuncAddress: TExprFunc): TExprWord;
begin
  Result := TFunction.Create(AFunctName, AShortName, ATypeSpec, AMinFunctionArg, AResultType, AFuncAddress, ADescription);
  FWordsList.Add(Result);
end;

function TCustomExpressionParser.DefineIntegerVariable(AVarName: string; AValue: PInteger): TExprWord;
begin
  Result := TIntegerVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

{$ifdef SUPPORT_INT64}

function TCustomExpressionParser.DefineLargeIntVariable(AVarName: string; AValue: PLargeInt): TExprWord;
begin
  Result := TLargeIntVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

{$endif}

function TCustomExpressionParser.DefineDateTimeVariable(AVarName: string; AValue: PDateTimeRec): TExprWord;
begin
  Result := TDateTimeVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

function TCustomExpressionParser.DefineBooleanVariable(AVarName: string; AValue: PBoolean): TExprWord;
begin
  Result := TBooleanVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

function TCustomExpressionParser.DefineFloatVariable(AVarName: string; AValue: PDouble): TExprWord;
begin
  Result := TFloatVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

function TCustomExpressionParser.DefineStringVariable(AVarName: string; AValue: PPChar): TExprWord;
begin
  Result := TStringVariable.Create(AVarName, AValue);
  FWordsList.Add(Result);
end;

{
procedure TCustomExpressionParser.GetGeneratedVars(AList: TList);
var
  I: Integer;
begin
  AList.Clear;
  with FWordsList do
    for I := 0 to Count - 1 do
    begin
      if TObject(Items[I]).ClassType = TGeneratedVariable then
        AList.Add(Items[I]);
    end;
end;
}

function TCustomExpressionParser.GetResultType: TExpressionType;
begin
  Result := etUnknown;
  if FCurrentRec <> nil then
  begin
    //LAST operand should be boolean -otherwise If(,,) doesn't work
    while (FLastRec^.Next <> nil) do
      FLastRec := FLastRec^.Next;
    if FLastRec^.ExprWord <> nil then
      Result := FLastRec^.ExprWord.ResultType;
  end;
end;

function TCustomExpressionParser.MakeRec: PExpressionRec;
var
  I: Integer;
begin
  New(Result);
  Result^.Oper := nil;
  Result^.AuxData := nil;
  Result^.WantsFunction := false;
  for I := 0 to MaxArg - 1 do
  begin
    Result^.Args[I] := nil;
    Result^.ArgsPos[I] := nil;
    Result^.ArgsSize[I] := 0;
    Result^.ArgsType[I] := etUnknown;
    Result^.ArgList[I] := nil;
  end;
  Result^.Res := nil;
  Result^.Next := nil;
  Result^.ExprWord := nil;
  Result^.ResetDest := false;
end;

procedure TCustomExpressionParser.Evaluate(AnExpression: string);
begin
  if Length(AnExpression) > 0 then
  begin
    AddExpression(AnExpression);
    EvaluateCurrent;
  end;
end;

function TCustomExpressionParser.AddExpression(AnExpression: string): Integer;
begin
  if Length(AnExpression) > 0 then
  begin
    Result := 0;
    CompileExpression(AnExpression);
  end else
    Result := -1;
  //CurrentIndex := Result;
end;

procedure TCustomExpressionParser.ClearExpressions;
begin
  DisposeList(FCurrentRec);
  FCurrentRec := nil;
  FLastRec := nil;
end;

function TCustomExpressionParser.GetFunctionDescription(AFunction: string):
  string;
var
  S: string;
  p, I: Integer;
begin
  S := AFunction;
  p := Pos('(', S);
  if p > 0 then
    S := Copy(S, 1, p - 1);
  if FWordsList.Search(pchar(S), I) then
    Result := TExprWord(FWordsList.Items[I]).Description
  else
    Result := EmptyStr;
end;

procedure TCustomExpressionParser.GetFunctionNames(AList: TStrings);
var
  I, J: Integer;
  S: string;
begin
  with FWordsList do
    for I := 0 to Count - 1 do
      with TExprWord(FWordsList.Items[I]) do
        if Length(Description) > 0 then
        begin
          S := Name;
          if MaxFunctionArg > 0 then
          begin
            S := S + '(';
            for J := 0 to MaxFunctionArg - 2 do
              S := S + ArgSeparator;
            S := S + ')';
          end;
          AList.Add(S);
        end;
end;


//--Expression functions-----------------------------------------------------

procedure FuncFloatToStr(Param: PExpressionRec);
var
  width, numDigits, resWidth: Integer;
  extVal: Extended;
begin
  with Param^ do
  begin
    // get params;
    numDigits := 0;
    if Args[1] <> nil then
      width := PInteger(Args[1])^
    else
      width := 18;
    if Args[2] <> nil then
      numDigits := PInteger(Args[2])^;
    // convert to string
    Res.AssureSpace(width);
    extVal := PDouble(Args[0])^;
    resWidth := FloatToText(Res.MemoryPos^, extVal, {$ifndef FPC_VERSION}fvExtended,{$endif} ffFixed, 18, numDigits);
    // always use dot as decimal separator
    if numDigits > 0 then
      Res.MemoryPos^[resWidth-numDigits-1] := '.';
    // result width smaller than requested width? -> add space to compensate
    if (Args[1] <> nil) and (resWidth < width) then
    begin
      // move string so that it's right-aligned
      Move(Res.MemoryPos^^, (Res.MemoryPos^)[width-resWidth], resWidth);
      // fill gap with spaces
      FillChar(Res.MemoryPos^^, width-resWidth, ' ');
      // resWidth has been padded, update
      resWidth := width;
    end else if resWidth > width then begin
      // result width more than requested width, cut
      resWidth := width;
    end;
    // advance pointer
    Inc(Res.MemoryPos^, resWidth);
    // null-terminate
    Res.MemoryPos^^ := #0;
  end;
end;

procedure FuncIntToStr_Gen(Param: PExpressionRec; Val: {$ifdef SUPPORT_INT64}Int64{$else}Integer{$endif});
var
  width: Integer;
begin
  with Param^ do
  begin
    // width specified?
    if Args[1] <> nil then
    begin
      // convert to string
      width := PInteger(Args[1])^;
{$ifdef SUPPORT_INT64}
      GetStrFromInt64_Width
{$else}
      GetStrFromInt_Width
{$endif}
        (Val, width, Res.MemoryPos^, #32);
      // advance pointer
      Inc(Res.MemoryPos^, width);
      // need to add decimal?
      if Args[2] <> nil then
      begin
        // get number of digits
        width := PInteger(Args[2])^;
        // add decimal dot
        Res.MemoryPos^^ := '.';
        Inc(Res.MemoryPos^);
        // add zeroes
        FillChar(Res.MemoryPos^^, width, '0');
        // go to end
        Inc(Res.MemoryPos^, width);
      end;
    end else begin
      // convert to string
      width :=
{$ifdef SUPPORT_INT64}
        GetStrFromInt64
{$else}
        GetStrFromInt
{$endif}
          (Val, Res.MemoryPos^);
      // advance pointer
      Inc(Param^.Res.MemoryPos^, width);
    end;
    // null-terminate
    Res.MemoryPos^^ := #0;
  end;
end;

procedure FuncIntToStr(Param: PExpressionRec);
begin
  FuncIntToStr_Gen(Param, PInteger(Param^.Args[0])^);
end;

{$ifdef SUPPORT_INT64}

procedure FuncInt64ToStr(Param: PExpressionRec);
begin
  FuncIntToStr_Gen(Param, PInt64(Param^.Args[0])^);
end;

{$endif}

procedure FuncDateToStr(Param: PExpressionRec);
var
  TempStr: string;
begin
  with Param^ do
  begin
    // create in temporary string
    DateTimeToString(TempStr, 'yyyymmdd', PDateTimeRec(Args[0])^.DateTime);
    // copy to buffer
    Res.Append(PChar(TempStr), Length(TempStr));
  end;
end;

procedure FuncSubString(Param: PExpressionRec);
var
  srcLen, index, count: Integer;
begin
  with Param^ do
  begin
    srcLen := StrLen(Args[0]);
    index := PInteger(Args[1])^ - 1;
    if Args[2] <> nil then
    begin
      count := PInteger(Args[2])^;
      if index + count > srcLen then
        count := srcLen - index;
    end else
      count := srcLen - index;
    Res.Append(Args[0]+index, count)
  end;
end;

procedure FuncUppercase(Param: PExpressionRec);
var
  dest: PChar;
begin
  with Param^ do
  begin
    // first copy
    dest := (Res.MemoryPos)^;
    Res.Append(Args[0], StrLen(Args[0]));
    // make uppercase
    AnsiStrUpper(dest);
  end;
end;

procedure FuncLowercase(Param: PExpressionRec);
var
  dest: PChar;
begin
  with Param^ do
  begin
    // first copy
    dest := (Res.MemoryPos)^;
    Res.Append(Args[0], StrLen(Args[0]));
    // make lowercase
    AnsiStrLower(dest);
  end;
end;

procedure FuncAdd_F_FF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PDouble(Args[1])^;
end;

procedure FuncAdd_F_FI(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PInteger(Args[1])^;
end;

procedure FuncAdd_F_II(Param: PExpressionRec);
begin
  with Param^ do
    PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ + PInteger(Args[1])^;
end;

procedure FuncAdd_F_IF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ + PDouble(Args[1])^;
end;

{$ifdef SUPPORT_INT64}

procedure FuncAdd_F_FL(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PInt64(Args[1])^;
end;

procedure FuncAdd_F_IL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ + PInt64(Args[1])^;
end;

procedure FuncAdd_F_LL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ + PInt64(Args[1])^;
end;

procedure FuncAdd_F_LF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ + PDouble(Args[1])^;
end;

procedure FuncAdd_F_LI(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ + PInteger(Args[1])^;
end;

{$endif}

procedure FuncSub_F_FF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PDouble(Args[1])^;
end;

procedure FuncSub_F_FI(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PInteger(Args[1])^;
end;

procedure FuncSub_F_II(Param: PExpressionRec);
begin
  with Param^ do
    PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ - PInteger(Args[1])^;
end;

procedure FuncSub_F_IF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ - PDouble(Args[1])^;
end;

{$ifdef SUPPORT_INT64}

procedure FuncSub_F_FL(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PInt64(Args[1])^;
end;

procedure FuncSub_F_IL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ - PInt64(Args[1])^;
end;

procedure FuncSub_F_LL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ - PInt64(Args[1])^;
end;

procedure FuncSub_F_LF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ - PDouble(Args[1])^;
end;

procedure FuncSub_F_LI(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ - PInteger(Args[1])^;
end;

{$endif}

procedure FuncMul_F_FF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PDouble(Args[1])^;
end;

procedure FuncMul_F_FI(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PInteger(Args[1])^;
end;

procedure FuncMul_F_II(Param: PExpressionRec);
begin
  with Param^ do
    PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ * PInteger(Args[1])^;
end;

procedure FuncMul_F_IF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ * PDouble(Args[1])^;
end;

{$ifdef SUPPORT_INT64}

procedure FuncMul_F_FL(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PInt64(Args[1])^;
end;

procedure FuncMul_F_IL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ * PInt64(Args[1])^;
end;

procedure FuncMul_F_LL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ * PInt64(Args[1])^;
end;

procedure FuncMul_F_LF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ * PDouble(Args[1])^;
end;

procedure FuncMul_F_LI(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ * PInteger(Args[1])^;
end;

{$endif}

procedure FuncDiv_F_FF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PDouble(Args[1])^;
end;

procedure FuncDiv_F_FI(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PInteger(Args[1])^;
end;

procedure FuncDiv_F_II(Param: PExpressionRec);
begin
  with Param^ do
    PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ div PInteger(Args[1])^;
end;

procedure FuncDiv_F_IF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ / PDouble(Args[1])^;
end;

{$ifdef SUPPORT_INT64}

procedure FuncDiv_F_FL(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PInt64(Args[1])^;
end;

procedure FuncDiv_F_IL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ div PInt64(Args[1])^;
end;

procedure FuncDiv_F_LL(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ div PInt64(Args[1])^;
end;

procedure FuncDiv_F_LF(Param: PExpressionRec);
begin
  with Param^ do
    PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ / PDouble(Args[1])^;
end;

procedure FuncDiv_F_LI(Param: PExpressionRec);
begin
  with Param^ do
    PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ div PInteger(Args[1])^;
end;

{$endif}

procedure FuncStrI_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) = 0);
end;

procedure FuncStrIP_EQ(Param: PExpressionRec);
var
  arg0len, arg1len: integer;
  match: boolean;
  str0, str1: string;
begin
  with Param^ do
  begin
    arg1len := StrLen(Args[1]);
    if Args[1][0] = '*' then
    begin
      if Args[1][arg1len-1] = '*' then
      begin
        str0 := AnsiStrUpper(Args[0]);
        str1 := AnsiStrUpper(Args[1]+1);
        setlength(str1, arg1len-2);
        match := AnsiPos(str1, str0) <> 0;
      end else begin
        arg0len := StrLen(Args[0]);
        // at least length without asterisk
        match := arg0len >= arg1len - 1;
        if match then
          match := AnsiStrLIComp(Args[0]+(arg0len-arg1len+1), Args[1]+1, arg1len-1) = 0;
      end;
    end else
    if Args[1][arg1len-1] = '*' then
    begin
      arg0len := StrLen(Args[0]);
      match := arg0len >= arg1len - 1;
      if match then
        match := AnsiStrLIComp(Args[0], Args[1], arg1len-1) = 0;
    end else begin
      match := AnsiStrIComp(Args[0], Args[1]) = 0;
    end;
    Res.MemoryPos^^ := Char(match);
  end;
end;

procedure FuncStrI_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) <> 0);
end;

procedure FuncStrI_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) < 0);
end;

procedure FuncStrI_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) > 0);
end;

procedure FuncStrI_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) <= 0);
end;

procedure FuncStrI_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) >= 0);
end;

procedure FuncStrP_EQ(Param: PExpressionRec);
var
  arg0len, arg1len: integer;
  match: boolean;
begin
  with Param^ do
  begin
    arg1len := StrLen(Args[1]);
    if Args[1][0] = '*' then
    begin
      if Args[1][arg1len-1] = '*' then
      begin
        Args[1][arg1len-1] := #0;
        match := AnsiStrPos(Args[0], Args[1]+1) <> nil;
        Args[1][arg1len-1] := '*';
      end else begin
        arg0len := StrLen(Args[0]);
        // at least length without asterisk
        match := arg0len >= arg1len - 1;
        if match then
          match := AnsiStrLComp(Args[0]+(arg0len-arg1len+1), Args[1]+1, arg1len-1) = 0;
      end;
    end else
    if Args[1][arg1len-1] = '*' then
    begin
      arg0len := StrLen(Args[0]);
      match := arg0len >= arg1len - 1;
      if match then
        match := AnsiStrLComp(Args[0], Args[1], arg1len-1) = 0;
    end else begin
      match := AnsiStrComp(Args[0], Args[1]) = 0;
    end;
    Res.MemoryPos^^ := Char(match);
  end;
end;

procedure FuncStr_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) = 0);
end;

procedure FuncStr_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) <> 0);
end;

procedure FuncStr_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) < 0);
end;

procedure FuncStr_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) > 0);
end;

procedure FuncStr_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) <= 0);
end;

procedure FuncStr_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) >= 0);
end;

procedure Func_FF_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PDouble(Args[1])^);
end;

procedure Func_FF_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PDouble(Args[1])^);
end;

procedure Func_FF_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PDouble(Args[1])^);
end;

procedure Func_FF_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PDouble(Args[1])^);
end;

procedure Func_FF_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PDouble(Args[1])^);
end;

procedure Func_FF_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PDouble(Args[1])^);
end;

procedure Func_FI_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PInteger(Args[1])^);
end;

procedure Func_FI_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PInteger(Args[1])^);
end;

procedure Func_FI_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PInteger(Args[1])^);
end;

procedure Func_FI_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PInteger(Args[1])^);
end;

procedure Func_FI_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PInteger(Args[1])^);
end;

procedure Func_FI_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PInteger(Args[1])^);
end;

procedure Func_II_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PInteger(Args[1])^);
end;

procedure Func_II_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PInteger(Args[1])^);
end;

procedure Func_II_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PInteger(Args[1])^);
end;

procedure Func_II_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PInteger(Args[1])^);
end;

procedure Func_II_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PInteger(Args[1])^);
end;

procedure Func_II_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PInteger(Args[1])^);
end;

procedure Func_IF_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PDouble(Args[1])^);
end;

procedure Func_IF_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PDouble(Args[1])^);
end;

procedure Func_IF_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PDouble(Args[1])^);
end;

procedure Func_IF_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PDouble(Args[1])^);
end;

procedure Func_IF_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PDouble(Args[1])^);
end;

procedure Func_IF_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PDouble(Args[1])^);
end;

{$ifdef SUPPORT_INT64}

procedure Func_LL_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PInt64(Args[1])^);
end;

procedure Func_LL_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PInt64(Args[1])^);
end;

procedure Func_LL_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PInt64(Args[1])^);
end;

procedure Func_LL_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PInt64(Args[1])^);
end;

procedure Func_LL_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PInt64(Args[1])^);
end;

procedure Func_LL_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PInt64(Args[1])^);
end;

procedure Func_LF_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PDouble(Args[1])^);
end;

procedure Func_LF_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PDouble(Args[1])^);
end;

procedure Func_LF_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PDouble(Args[1])^);
end;

procedure Func_LF_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PDouble(Args[1])^);
end;

procedure Func_LF_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PDouble(Args[1])^);
end;

procedure Func_LF_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PDouble(Args[1])^);
end;

procedure Func_FL_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PInt64(Args[1])^);
end;

procedure Func_FL_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PInt64(Args[1])^);
end;

procedure Func_FL_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PInt64(Args[1])^);
end;

procedure Func_FL_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PInt64(Args[1])^);
end;

procedure Func_FL_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PInt64(Args[1])^);
end;

procedure Func_FL_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PInt64(Args[1])^);
end;

procedure Func_LI_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PInteger(Args[1])^);
end;

procedure Func_LI_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PInteger(Args[1])^);
end;

procedure Func_LI_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PInteger(Args[1])^);
end;

procedure Func_LI_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PInteger(Args[1])^);
end;

procedure Func_LI_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PInteger(Args[1])^);
end;

procedure Func_LI_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PInteger(Args[1])^);
end;

procedure Func_IL_EQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PInt64(Args[1])^);
end;

procedure Func_IL_NEQ(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PInt64(Args[1])^);
end;

procedure Func_IL_LT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PInt64(Args[1])^);
end;

procedure Func_IL_GT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PInt64(Args[1])^);
end;

procedure Func_IL_LTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PInt64(Args[1])^);
end;

procedure Func_IL_GTE(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PInt64(Args[1])^);
end;

{$endif}

procedure Func_AND(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(Boolean(Args[0]^) and Boolean(Args[1]^));
end;

procedure Func_OR(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(Boolean(Args[0]^) or Boolean(Args[1]^));
end;

procedure Func_NOT(Param: PExpressionRec);
begin
  with Param^ do
    Res.MemoryPos^^ := Char(not Boolean(Args[0]^));
end;

initialization

  DbfWordsGeneralList := TExpressList.Create;
  DbfWordsInsensGeneralList := TExpressList.Create;
  DbfWordsInsensNoPartialList := TExpressList.Create;
  DbfWordsInsensPartialList := TExpressList.Create;
  DbfWordsSensGeneralList := TExpressList.Create;
  DbfWordsSensNoPartialList := TExpressList.Create;
  DbfWordsSensPartialList := TExpressList.Create;

  with DbfWordsGeneralList do
  begin
    // basic function functionality
    Add(TLeftBracket.Create('(', nil));
    Add(TRightBracket.Create(')', nil));
    Add(TComma.Create(',', nil));

    // operators - name, param types, result type, func addr, precedence
    Add(TFunction.CreateOper('+', 'SS', etString,   nil,          40));
    Add(TFunction.CreateOper('+', 'FF', etFloat,    FuncAdd_F_FF, 40));
    Add(TFunction.CreateOper('+', 'FI', etFloat,    FuncAdd_F_FI, 40));
    Add(TFunction.CreateOper('+', 'IF', etFloat,    FuncAdd_F_IF, 40));
    Add(TFunction.CreateOper('+', 'II', etInteger,  FuncAdd_F_II, 40));
{$ifdef SUPPORT_INT64}
    Add(TFunction.CreateOper('+', 'FL', etFloat,    FuncAdd_F_FL, 40));
    Add(TFunction.CreateOper('+', 'IL', etLargeInt, FuncAdd_F_IL, 40));
    Add(TFunction.CreateOper('+', 'LF', etFloat,    FuncAdd_F_LF, 40));
    Add(TFunction.CreateOper('+', 'LL', etLargeInt, FuncAdd_F_LI, 40));
    Add(TFunction.CreateOper('+', 'LI', etLargeInt, FuncAdd_F_LL, 40));
{$endif}
    Add(TFunction.CreateOper('-', 'FF', etFloat,    FuncSub_F_FF, 40));
    Add(TFunction.CreateOper('-', 'FI', etFloat,    FuncSub_F_FI, 40));
    Add(TFunction.CreateOper('-', 'IF', etFloat,    FuncSub_F_IF, 40));
    Add(TFunction.CreateOper('-', 'II', etInteger,  FuncSub_F_II, 40));
{$ifdef SUPPORT_INT64}
    Add(TFunction.CreateOper('-', 'FL', etFloat,    FuncSub_F_FL, 40));
    Add(TFunction.CreateOper('-', 'IL', etLargeInt, FuncSub_F_IL, 40));
    Add(TFunction.CreateOper('-', 'LF', etFloat,    FuncSub_F_LF, 40));
    Add(TFunction.CreateOper('-', 'LL', etLargeInt, FuncSub_F_LI, 40));
    Add(TFunction.CreateOper('-', 'LI', etLargeInt, FuncSub_F_LL, 40));
{$endif}
    Add(TFunction.CreateOper('*', 'FF', etFloat,    FuncMul_F_FF, 40));
    Add(TFunction.CreateOper('*', 'FI', etFloat,    FuncMul_F_FI, 40));
    Add(TFunction.CreateOper('*', 'IF', etFloat,    FuncMul_F_IF, 40));
    Add(TFunction.CreateOper('*', 'II', etInteger,  FuncMul_F_II, 40));
{$ifdef SUPPORT_INT64}
    Add(TFunction.CreateOper('*', 'FL', etFloat,    FuncMul_F_FL, 40));
    Add(TFunction.CreateOper('*', 'IL', etLargeInt, FuncMul_F_IL, 40));
    Add(TFunction.CreateOper('*', 'LF', etFloat,    FuncMul_F_LF, 40));
    Add(TFunction.CreateOper('*', 'LL', etLargeInt, FuncMul_F_LI, 40));
    Add(TFunction.CreateOper('*', 'LI', etLargeInt, FuncMul_F_LL, 40));
{$endif}
    Add(TFunction.CreateOper('/', 'FF', etFloat,    FuncDiv_F_FF, 40));
    Add(TFunction.CreateOper('/', 'FI', etFloat,    FuncDiv_F_FI, 40));
    Add(TFunction.CreateOper('/', 'IF', etFloat,    FuncDiv_F_IF, 40));
    Add(TFunction.CreateOper('/', 'II', etInteger,  FuncDiv_F_II, 40));
{$ifdef SUPPORT_INT64}
    Add(TFunction.CreateOper('/', 'FL', etFloat,    FuncDiv_F_FL, 40));
    Add(TFunction.CreateOper('/', 'IL', etLargeInt, FuncDiv_F_IL, 40));
    Add(TFunction.CreateOper('/', 'LF', etFloat,    FuncDiv_F_LF, 40));
    Add(TFunction.CreateOper('/', 'LL', etLargeInt, FuncDiv_F_LI, 40));
    Add(TFunction.CreateOper('/', 'LI', etLargeInt, FuncDiv_F_LL, 40));
{$endif}

    Add(TFunction.CreateOper('=', 'FF', etBoolean, Func_FF_EQ , 80));
    Add(TFunction.CreateOper('<', 'FF', etBoolean, Func_FF_LT , 80));
    Add(TFunction.CreateOper('>', 'FF', etBoolean, Func_FF_GT , 80));
    Add(TFunction.CreateOper('<=','FF', etBoolean, Func_FF_LTE, 80));
    Add(TFunction.CreateOper('>=','FF', etBoolean, Func_FF_GTE, 80));
    Add(TFunction.CreateOper('<>','FF', etBoolean, Func_FF_NEQ, 80));
    Add(TFunction.CreateOper('=', 'FI', etBoolean, Func_FI_EQ , 80));
    Add(TFunction.CreateOper('<', 'FI', etBoolean, Func_FI_LT , 80));
    Add(TFunction.CreateOper('>', 'FI', etBoolean, Func_FI_GT , 80));
    Add(TFunction.CreateOper('<=','FI', etBoolean, Func_FI_LTE, 80));
    Add(TFunction.CreateOper('>=','FI', etBoolean, Func_FI_GTE, 80));
    Add(TFunction.CreateOper('<>','FI', etBoolean, Func_FI_NEQ, 80));
    Add(TFunction.CreateOper('=', 'II', etBoolean, Func_II_EQ , 80));
    Add(TFunction.CreateOper('<', 'II', etBoolean, Func_II_LT , 80));
    Add(TFunction.CreateOper('>', 'II', etBoolean, Func_II_GT , 80));
    Add(TFunction.CreateOper('<=','II', etBoolean, Func_II_LTE, 80));
    Add(TFunction.CreateOper('>=','II', etBoolean, Func_II_GTE, 80));
    Add(TFunction.CreateOper('<>','II', etBoolean, Func_II_NEQ, 80));
    Add(TFunction.CreateOper('=', 'IF', etBoolean, Func_IF_EQ , 80));
    Add(TFunction.CreateOper('<', 'IF', etBoolean, Func_IF_LT , 80));
    Add(TFunction.CreateOper('>', 'IF', etBoolean, Func_IF_GT , 80));
    Add(TFunction.CreateOper('<=','IF', etBoolean, Func_IF_LTE, 80));
    Add(TFunction.CreateOper('>=','IF', etBoolean, Func_IF_GTE, 80));
    Add(TFunction.CreateOper('<>','IF', etBoolean, Func_IF_NEQ, 80));
{$ifdef SUPPORT_INT64}
    Add(TFunction.CreateOper('=', 'LL', etBoolean, Func_LL_EQ , 80));
    Add(TFunction.CreateOper('<', 'LL', etBoolean, Func_LL_LT , 80));
    Add(TFunction.CreateOper('>', 'LL', etBoolean, Func_LL_GT , 80));
    Add(TFunction.CreateOper('<=','LL', etBoolean, Func_LL_LTE, 80));
    Add(TFunction.CreateOper('>=','LL', etBoolean, Func_LL_GTE, 80));
    Add(TFunction.CreateOper('<>','LL', etBoolean, Func_LL_NEQ, 80));
    Add(TFunction.CreateOper('=', 'LF', etBoolean, Func_LF_EQ , 80));
    Add(TFunction.CreateOper('<', 'LF', etBoolean, Func_LF_LT , 80));
    Add(TFunction.CreateOper('>', 'LF', etBoolean, Func_LF_GT , 80));
    Add(TFunction.CreateOper('<=','LF', etBoolean, Func_LF_LTE, 80));
    Add(TFunction.CreateOper('>=','LF', etBoolean, Func_LF_GTE, 80));
    Add(TFunction.CreateOper('<>','FI', etBoolean, Func_LF_NEQ, 80));
    Add(TFunction.CreateOper('=', 'LI', etBoolean, Func_LI_EQ , 80));
    Add(TFunction.CreateOper('<', 'LI', etBoolean, Func_LI_LT , 80));
    Add(TFunction.CreateOper('>', 'LI', etBoolean, Func_LI_GT , 80));
    Add(TFunction.CreateOper('<=','LI', etBoolean, Func_LI_LTE, 80));
    Add(TFunction.CreateOper('>=','LI', etBoolean, Func_LI_GTE, 80));
    Add(TFunction.CreateOper('<>','LI', etBoolean, Func_LI_NEQ, 80));
    Add(TFunction.CreateOper('=', 'FL', etBoolean, Func_FL_EQ , 80));
    Add(TFunction.CreateOper('<', 'FL', etBoolean, Func_FL_LT , 80));
    Add(TFunction.CreateOper('>', 'FL', etBoolean, Func_FL_GT , 80));
    Add(TFunction.CreateOper('<=','FL', etBoolean, Func_FL_LTE, 80));
    Add(TFunction.CreateOper('>=','FL', etBoolean, Func_FL_GTE, 80));
    Add(TFunction.CreateOper('<>','FL', etBoolean, Func_FL_NEQ, 80));
    Add(TFunction.CreateOper('=', 'IL', etBoolean, Func_IL_EQ , 80));
    Add(TFunction.CreateOper('<', 'IL', etBoolean, Func_IL_LT , 80));
    Add(TFunction.CreateOper('>', 'IL', etBoolean, Func_IL_GT , 80));
    Add(TFunction.CreateOper('<=','IL', etBoolean, Func_IL_LTE, 80));
    Add(TFunction.CreateOper('>=','IL', etBoolean, Func_IL_GTE, 80));
    Add(TFunction.CreateOper('<>','IL', etBoolean, Func_IL_NEQ, 80));
{$endif}

    Add(TFunction.CreateOper('NOT', 'B',  etBoolean, Func_NOT, 85));
    Add(TFunction.CreateOper('AND', 'BB', etBoolean, Func_AND, 90));
    Add(TFunction.CreateOper('OR',  'BB', etBoolean, Func_OR, 100));

    // Functions - name, description, param types, min params, result type, Func addr
    Add(TFunction.Create('STR',       '',      'FII', 1, etString, FuncFloatToStr, ''));
    Add(TFunction.Create('STR',       '',      'III', 1, etString, FuncIntToStr, ''));
    {$ifdef SUPPORT_INT64}
     Add(TFunction.Create('STR', '', 'LII', 1, etString, FuncInt64ToStr, ''));
    {$endif}
    Add(TFunction.Create('DTOS',      '',      'D',   1, etString, FuncDateToStr, ''));
    Add(TFunction.Create('SUBSTR',    'SUBS',  'SII', 3, etString, FuncSubString, ''));
    Add(TFunction.Create('UPPERCASE', 'UPPER', 'S',   1, etString, FuncUppercase, ''));
    Add(TFunction.Create('LOWERCASE', 'LOWER', 'S',   1, etString, FuncLowercase, ''));
  end;

  with DbfWordsInsensGeneralList do
  begin
    Add(TFunction.CreateOper('<', 'SS', etBoolean, FuncStrI_LT , 80));
    Add(TFunction.CreateOper('>', 'SS', etBoolean, FuncStrI_GT , 80));
    Add(TFunction.CreateOper('<=','SS', etBoolean, FuncStrI_LTE, 80));
    Add(TFunction.CreateOper('>=','SS', etBoolean, FuncStrI_GTE, 80));
    Add(TFunction.CreateOper('<>','SS', etBoolean, FuncStrI_NEQ, 80));
  end;

  with DbfWordsInsensNoPartialList do
    Add(TFunction.CreateOper('=', 'SS', etBoolean, FuncStrI_EQ , 80));

  with DbfWordsInsensPartialList do
    Add(TFunction.CreateOper('=', 'SS', etBoolean, FuncStrIP_EQ, 80));

  with DbfWordsSensGeneralList do
  begin
    Add(TFunction.CreateOper('<', 'SS', etBoolean, FuncStr_LT , 80));
    Add(TFunction.CreateOper('>', 'SS', etBoolean, FuncStr_GT , 80));
    Add(TFunction.CreateOper('<=','SS', etBoolean, FuncStr_LTE, 80));
    Add(TFunction.CreateOper('>=','SS', etBoolean, FuncStr_GTE, 80));
    Add(TFunction.CreateOper('<>','SS', etBoolean, FuncStr_NEQ, 80));
  end;

  with DbfWordsSensNoPartialList do
    Add(TFunction.CreateOper('=', 'SS', etBoolean, FuncStr_EQ , 80));

  with DbfWordsSensPartialList do
    Add(TFunction.CreateOper('=', 'SS', etBoolean, FuncStrP_EQ , 80));

finalization

  DbfWordsGeneralList.Free;
  DbfWordsInsensGeneralList.Free;
  DbfWordsInsensNoPartialList.Free;
  DbfWordsInsensPartialList.Free;
  DbfWordsSensGeneralList.Free;
  DbfWordsSensNoPartialList.Free;
  DbfWordsSensPartialList.Free;
end.

