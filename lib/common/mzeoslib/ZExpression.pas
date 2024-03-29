{*********************************************************}
{                                                         }
{                 Zeos Database Objects                   }
{             Expression classes and interfaces           }
{                                                         }
{          Originally written by Sergey Seroukhov         }
{                                                         }
{*********************************************************}

{@********************************************************}
{    Copyright (c) 1999-2020 Zeos Development Group       }
{                                                         }
{ License Agreement:                                      }
{                                                         }
{ This library is distributed in the hope that it will be }
{ useful, but WITHOUT ANY WARRANTY; without even the      }
{ implied warranty of MERCHANTABILITY or FITNESS FOR      }
{ A PARTICULAR PURPOSE.  See the GNU Lesser General       }
{ Public License for more details.                        }
{                                                         }
{ The source code of the ZEOS Libraries and packages are  }
{ distributed under the Library GNU General Public        }
{ License (see the file COPYING / COPYING.ZEOS)           }
{ with the following  modification:                       }
{ As a special exception, the copyright holders of this   }
{ library give you permission to link this library with   }
{ independent modules to produce an executable,           }
{ regardless of the license terms of these independent    }
{ modules, and to copy and distribute the resulting       }
{ executable under terms of your choice, provided that    }
{ you also meet, for each linked independent module,      }
{ the terms and conditions of the license of that module. }
{ An independent module is a module which is not derived  }
{ from or based on this library. If you modify this       }
{ library, you may extend this exception to your version  }
{ of the library, but you are not obligated to do so.     }
{ If you do not wish to do so, delete this exception      }
{ statement from your version.                            }
{                                                         }
{                                                         }
{ The project web site is located on:                     }
{   http://zeos.firmos.at  (FORUM)                        }
{   http://sourceforge.net/p/zeoslib/tickets/ (BUGTRACKER)}
{   svn://svn.code.sf.net/p/zeoslib/code-0/trunk (SVN)    }
{                                                         }
{   http://www.sourceforge.net/projects/zeoslib.          }
{                                                         }
{                                                         }
{                                 Zeos Development Group. }
{********************************************************@}

unit ZExpression;

interface

{$I ZCore.inc}

uses SysUtils, Classes, {$IFDEF WITH_TOBJECTLIST_REQUIRES_SYSTEM_TYPES}System.Contnrs, {$ENDIF}
  ZClasses, ZCompatibility, ZVariant, ZTokenizer, ZExprParser;

type
  {** Defines an expression exception. }
  TZExpressionError = class (Exception);

  {** Defines an execution stack object. }
  TZExecutionStack = class (TObject)
  private
    FValues: TZVariantDynArray;
    FCount: Integer;
    FCapacity: Integer;

    function GetValue(Index: Integer): TZVariant;
  public
    constructor Create;

    procedure DecStackPointer(const Value : integer);
    function Pop: TZVariant;
    function Peek: TZVariant;
    procedure Push(const Value: TZVariant);
    function GetParameter(Index: Integer): TZVariant;
    procedure Swap;

    procedure Clear;

    property Count: Integer read FCount;
    property Values[Index: Integer]: TZVariant read GetValue;
  end;

  {** Defines a list of variables. }
  IZVariablesList = interface (IZInterface)
    ['{F4347F46-32F3-4021-B6DB-7A39BF171275}']

    function GetCount: Integer;
    function GetName(Index: Integer): string;
    function GetValue(Index: Integer): TZVariant;
    procedure SetValue(Index: Integer; const Value: TZVariant);
    function GetValueByName(const Name: string): TZVariant;
    procedure SetValueByName(const Name: string; const Value: TZVariant);

    procedure Add(const Name: string; const Value: TZVariant);
    procedure Remove(const Name: string);
    function FindByName(const Name: string): Integer;

    procedure ClearValues;
    procedure Clear;

    property Count: Integer read GetCount;
    property Names[Index: Integer]: string read GetName;
    property Values[Index: Integer]: TZVariant read GetValue write SetValue;
    property NamedValues[const Index: string]: TZVariant read GetValueByName
      write SetValueByName;
  end;

  {** Defines a function interface. }
  IZFunction = interface (IZInterface)
    ['{E9B3AFF9-6CD9-49C8-AB66-C8CF60ED8686}']

    function GetName: string;

    function Execute(Stack: TZExecutionStack;
      const VariantManager: IZVariantManager): TZVariant;

    property Name: string read GetName;
  end;

  {** Defines a list of functions. }
  IZFunctionsList = interface (IZInterface)
    ['{54453054-F012-475B-84C3-7E5C46187FDB}']

    function GetCount: Integer;
    function GetName(Index: Integer): string;
    function GetFunction(Index: Integer): IZFunction;

    procedure Add(const Func: IZFunction);
    procedure Remove(const Name: string);
    function FindByName(const Name: string): Integer;
    procedure Clear;

    property Count: Integer read GetCount;
    property Names[Index: Integer]: string read GetName;
    property Functions[Index: Integer]: IZFunction read GetFunction;
  end;

  {** Defines an interface to expression calculator. }
  IZExpression = interface (IZInterface)
    ['{26F9D379-5618-446C-8999-D50FBB2F8560}']

    function GetTokenizer: IZTokenizer;
    procedure SetTokenizer(const Value: IZTokenizer);
    function GetExpression: string;
    procedure SetExpression(const Value: string);
    function GetVariantManager: IZVariantManager;
    procedure SetVariantManager(const Value: IZVariantManager);
    function GetDefaultVariables: IZVariablesList;
    procedure SetDefaultVariables(const Value: IZVariablesList);
    function GetDefaultFunctions: IZFunctionsList;
    procedure SetDefaultFunctions(const Value: IZFunctionsList);
    function GetAutoVariables: Boolean;
    procedure SetAutoVariables(Value: Boolean);

    function Evaluate: TZVariant;
    function Evaluate2(const Variables: IZVariablesList): TZVariant;
    function Evaluate3(const Variables: IZVariablesList;
      const Functions: IZFunctionsList): TZVariant;
    function Evaluate4(const Variables: IZVariablesList;
      const Functions: IZFunctionsList; Stack: TZExecutionStack): TZVariant;

    procedure CreateVariables(const Variables: IZVariablesList);
    procedure Clear;

    property Tokenizer: IZTokenizer read GetTokenizer write SetTokenizer;
    property Expression: string read GetExpression write SetExpression;
    property VariantManager: IZVariantManager read GetVariantManager
      write SetVariantManager;
    property DefaultVariables: IZVariablesList read GetDefaultVariables
      write SetDefaultVariables;
    property DefaultFunctions: IZFunctionsList read GetDefaultFunctions
      write SetDefaultFunctions;
    property AutoVariables: Boolean read GetAutoVariables
      write SetAutoVariables;
  end;

  {** Implements an expression calculator class. }
  TZExpression = class (TInterfacedObject, IZExpression)
  private
    FTokenizer: IZTokenizer;
    FDefaultVariables: IZVariablesList;
    FDefaultFunctions: IZFunctionsList;
    FVariantManager: IZVariantManager;
    FParser: TZExpressionParser;
    FAutoVariables: Boolean;

    function GetTokenizer: IZTokenizer;
    procedure SetTokenizer(const Value: IZTokenizer);
    function GetExpression: string;
    procedure SetExpression(const Value: string);
    function GetVariantManager: IZVariantManager;
    procedure SetVariantManager(const Value: IZVariantManager);
    function GetDefaultVariables: IZVariablesList;
    procedure SetDefaultVariables(const Value: IZVariablesList);
    function GetDefaultFunctions: IZFunctionsList;
    procedure SetDefaultFunctions(const Value: IZFunctionsList);
    function GetAutoVariables: Boolean;
    procedure SetAutoVariables(Value: Boolean);
  protected
    function NormalizeValues(var Val1, Val2: TZVariant): Boolean;
  public
    constructor Create;
    constructor CreateWithExpression(const Expression: string);
    destructor Destroy; override;

    function Evaluate: TZVariant;
    function Evaluate2(const Variables: IZVariablesList): TZVariant;
    function Evaluate3(const Variables: IZVariablesList;
      const Functions: IZFunctionsList): TZVariant;
    function Evaluate4(const Variables: IZVariablesList;
      const Functions: IZFunctionsList; Stack: TZExecutionStack): TZVariant;

    procedure CreateVariables(const Variables: IZVariablesList);
    procedure Clear;

    property Expression: string read GetExpression write SetExpression;
    property VariantManager: IZVariantManager read GetVariantManager
      write SetVariantManager;
    property DefaultVariables: IZVariablesList read GetDefaultVariables
      write SetDefaultVariables;
    property DefaultFunctions: IZFunctionsList read GetDefaultFunctions
      write SetDefaultFunctions;
    property AutoVariables: Boolean read GetAutoVariables
      write SetAutoVariables;
  end;

implementation

uses
  ZMessages, ZExprToken, ZVariables, ZFunctions, ZMatchPattern;

{ TZExecutionStack }

{**
  Creates this object.
}
constructor TZExecutionStack.Create;
begin
  FCapacity := 100;
  SetLength(FValues, FCapacity);
  FCount := 0;
end;

{**
  Gets a value from absolute position in the stack.
  @param Index a value index.
  @returns a variant value from requested position.
}
function TZExecutionStack.GetValue(Index: Integer): TZVariant;
begin
  Result := FValues[Index];
end;

{**
  Gets a value from the top of the stack without removing it.
  @returns a value from the top.
}
function TZExecutionStack.Peek: TZVariant;
begin
  if FCount > 0 then
    Result := FValues[FCount - 1]
  else Result := NullVariant;
end;

{**
  Gets a function parameter by index.
  @param a function parameter index. O is used for parameter count.
  @returns a parameter value.
}
function TZExecutionStack.GetParameter(Index: Integer): TZVariant;
begin
  if FCount <= Index then
    raise TZExpressionError.Create(SStackIsEmpty);
  Result := FValues[FCount - Index - 1];
end;

procedure TZExecutionStack.DecStackPointer(const Value : integer);
begin
  Dec(FCount, Value);
  if FCount < 0 then
  begin
    FCount := 0;
    raise TZExpressionError.Create(SStackIsEmpty);
  end;
end;

{**
  Gets a value from the top and removes it from the stack.
  @returns a value from the top.
}
function TZExecutionStack.Pop: TZVariant;
begin
  Result := NullVariant;
  if FCount <= 0 then
    raise TZExpressionError.Create(SStackIsEmpty);
  Dec(FCount);
  Result := FValues[FCount];
end;

{**
  Puts a value to the top of the stack.
}
procedure TZExecutionStack.Push(const Value: TZVariant);
begin
  if FCapacity = FCount then
  begin
    Inc(FCapacity, 64);
    SetLength(FValues, FCapacity);
  end;
  SoftVarManager.Assign(Value, FValues[FCount]);
  if Value.VString <> '' then
    FValues[FCount].VString := Value.VString; //keep parsed value alive
  Inc(FCount);
end;

{**
  Swaps two values on the top of the stack.
}
procedure TZExecutionStack.Swap;
var
  Temp: TZVariant;
begin
  if FCount <= 1 then
    raise TZExpressionError.Create(SStackIsEmpty);

  Temp := FValues[FCount - 1];
  FValues[FCount - 1] := FValues[FCount - 2];
  FValues[FCount - 2] := Temp;
end;

{**
  Clears this stack.
}
procedure TZExecutionStack.Clear;
begin
  FCount := 0;
end;

{ TZExpression }

{**
  Creates this expression calculator object.
}
constructor TZExpression.Create;
begin
  FTokenizer := TZExpressionTokenizer.Create;
  FDefaultVariables := TZVariablesList.Create;
  FDefaultFunctions := TZDefaultFunctionsList.Create;
  FVariantManager := TZSoftVariantManager.Create;
  FParser := TZExpressionParser.Create(FTokenizer);
  FAutoVariables := True;
end;

{**
  Creates this expression calculator and assignes expression string.
  @param Expression an expression string.
}
constructor TZExpression.CreateWithExpression(const Expression: string);
begin
  Create;
  SetExpression(Expression);
end;

{**
  Destroys this object and cleanups the memory.
}
destructor TZExpression.Destroy;
begin
  FTokenizer := nil;
  FDefaultVariables := nil;
  FDefaultFunctions := nil;
  FVariantManager := nil;
  FParser.Free;

  inherited Destroy;
end;

{**
  Gets the current auto variables create flag.
  @returns the auto variables create flag.
}
function TZExpression.GetAutoVariables: Boolean;
begin
  Result := FAutoVariables;
end;

{**
  Sets a new auto variables create flag.
  @param value a new auto variables create flag.
}
procedure TZExpression.SetAutoVariables(Value: Boolean);
begin
  FAutoVariables := Value;
end;

{**
  Gets a list of default functions.
  @returns a list of default functions.
}
function TZExpression.GetDefaultFunctions: IZFunctionsList;
begin
  Result := FDefaultFunctions;
end;

{**
  Sets a new list of functions.
  @param Value a new list of functions.
}
procedure TZExpression.SetDefaultFunctions(const Value: IZFunctionsList);
begin
  FDefaultFunctions := Value;
end;

{**
  Gets a list of default variables.
  @returns a list of default variables.
}
function TZExpression.GetDefaultVariables: IZVariablesList;
begin
  Result := FDefaultVariables;
end;

{**
  Sets a new list of variables.
  @param Value a new list of variables.
}
procedure TZExpression.SetDefaultVariables(const Value: IZVariablesList);
begin
  FDefaultVariables := Value;
end;

{**
  Gets the current set expression string.
  @returns the current expression string.
}
function TZExpression.GetExpression: string;
begin
  Result := FParser.Expression;
end;

{**
  Sets a new expression string.
  @param Value a new expression string.
}
procedure TZExpression.SetExpression(const Value: string);
begin
  FParser.Expression := Value;
  if FAutoVariables then
    CreateVariables(FDefaultVariables);
end;

{**
  Gets a reference to the current variant manager.
  @returns a reference to the current variant manager.
}
function TZExpression.GetVariantManager: IZVariantManager;
begin
  Result := FVariantManager;
end;

Function TZExpression.NormalizeValues(var Val1, Val2: TZVariant): Boolean;
begin
  Result := (Val1.VType in [vtString..vtUnicodeString]) and
        not (Val2.VType in [vtString..vtUnicodeString]) and (Val2.VString <> '');
  if Result then
    Val2 := EncodeString(Val2.VString);
end;

{**
  Sets a new variant manager.
  @param Value a new variant manager.
}
procedure TZExpression.SetVariantManager(const Value: IZVariantManager);
begin
  FVariantManager := Value;
end;

{**
  Gets the current expression tokenizer.
  @returns the current expression tokenizer.
}
function TZExpression.GetTokenizer: IZTokenizer;
begin
  Result := FTokenizer;
end;

{**
  Sets a new expression tokenizer.
  @param Value a new expression tokenizer.
}
procedure TZExpression.SetTokenizer(const Value: IZTokenizer);
begin
  FTokenizer := Value;
  FParser.Tokenizer := Value;
end;

{**
  Clears this class from all data.
}
procedure TZExpression.Clear;
begin
  FParser.Clear;
  FDefaultVariables.Clear;
end;

{**
  Creates an empty variables.
  @param Variables a list of variables.
}
procedure TZExpression.CreateVariables(const Variables: IZVariablesList);
var
  I: Integer;
  Name: string;
begin
  for I := 0 to FParser.Variables.Count - 1 do
  begin
    Name := FParser.Variables[I];
    if Variables.FindByName(Name) < 0 then
      Variables.Add(Name, NullVariant);
  end;
end;

{**
  Evaluates this expression.
  @returns an evaluated expression value.
}
function TZExpression.Evaluate: TZVariant;
begin
  Result := Evaluate3(FDefaultVariables, FDefaultFunctions);
end;

{**
  Evaluates this expression.
  @param Variables a list of variables.
  @returns an evaluated expression value.
}
function TZExpression.Evaluate2(const Variables: IZVariablesList): TZVariant;
begin
  Result := Evaluate3(Variables, FDefaultFunctions);
end;

{**
  Evaluates this expression.
  @param Variables a list of variables.
  @param Functions a list of functions.
  @returns an evaluated expression value.
}
function TZExpression.Evaluate3(const Variables: IZVariablesList;
  const Functions: IZFunctionsList): TZVariant;
var
  Stack: TZExecutionStack;
begin
  Stack := TZExecutionStack.Create;
  try
    Result := Evaluate4(Variables, Functions, Stack);
  finally
    Stack.Free;
  end;
end;

{**
  Evaluates this expression.
  @param Variables a list of variables.
  @param Functions a list of functions.
  @param Stack an execution stack.
  @returns an evaluated expression value.
}
function TZExpression.Evaluate4(const Variables: IZVariablesList;
  const Functions: IZFunctionsList; Stack: TZExecutionStack): TZVariant;
var
  I, Index, ParamsCount: Integer;
  Current: TZExpressionToken;
  Value1, Value2: TZVariant;
begin
  Stack.Clear;

  for I := 0 to FParser.ResultTokens.Count - 1 do
  begin
    Current := TZExpressionToken(FParser.ResultTokens[I]);
    case Current.TokenType of
      ttConstant:
        Stack.Push(Current.Value);
{      ttVariable:
        begin
          Index := Variables.FindByName(SoftVarManager.GetAsString(Current.Value));
          if Index < 0 then
          begin
            raise TZExpressionError.Create(
              Format(SVariableWasNotFound, [SoftVarManager.GetAsString(Current.Value)]));
          end;
          Value1 := Variables.Values[Index];
          Stack.Push(Value1)
        end;
}      ttVariable:
        begin
          if Current.Value.VType = vtString then
          begin
            Index := Variables.FindByName(Current.Value.VString);
            if Index < 0 then
            begin
              raise TZExpressionError.Create(
                Format(SVariableWasNotFound, [Current.Value.VString]));
            end;
           Current.Value := EncodeInteger(Index);
          end;
          if Current.Value.VType = vtInteger then
            Stack.Push(Variables.Values[Current.Value.VInteger])
          else
            raise TZExpressionError.Create(
                Format(SSyntaxErrorNear, [SoftVarManager.GetAsString(Current.Value)]));
        end;
{      ttFunction:
        begin
          Index := Functions.FindByName(SoftVarManager.GetAsString(Current.Value));
          if Index < 0 then
          begin
            raise TZExpressionError.Create(
              Format(SFunctionWasNotFound, [SoftVarManager.GetAsString(Current.Value)]));
          end;
          Value1 := Functions.Functions[Index].Execute(Stack, FVariantManager);
          ParamsCount := SoftVarManager.GetAsInteger(Stack.Pop);
          while ParamsCount > 0 do
          begin
            Stack.Pop;
            Dec(ParamsCount);
          end;
          Stack.Push(Value1);
        end;
}      ttFunction:
        begin
          if Current.Value.VType = vtString then
          begin
            Index := Functions.FindByName(Current.Value.VString);
            if Index < 0 then
            begin
              raise TZExpressionError.Create(
                Format(SFunctionWasNotFound, [Current.Value.VString]));
            end;
            Current.Value := EncodeInterface(Functions.Functions[Index]);
          end;
          if Current.Value.VType = vtInterface then
          begin
           {$push}
         {$objectChecks off}          
            Value1 := IZFunction(Current.Value.VInterface).Execute(Stack, FVariantManager);
         {$pop}
            ParamsCount := FVariantManager.GetAsInteger(Stack.Pop);
            Stack.DecStackPointer(ParamsCount);
            Stack.Push(Value1);
          end
          else
            raise TZExpressionError.Create(
                Format(SSyntaxErrorNear, [SoftVarManager.GetAsString(Current.Value)]));
        end;
      ttAnd:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpAnd(Value1, Value2));
        end;
      ttOr:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpOr(Value1, Value2));
        end;
      ttXor:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpXor(Value1, Value2));
        end;
      ttNot:
        Stack.Push(FVariantManager.OpNot(Stack.Pop));
      ttPlus:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpAdd(Value1, Value2));
        end;
      ttMinus:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpSub(Value1, Value2));
        end;
      ttStar:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpMul(Value1, Value2));
        end;
      ttSlash:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpDiv(Value1, Value2));
        end;
      ttProcent:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpMod(Value1, Value2));
        end;
      ttEqual:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          NormalizeValues(Value1, Value2);
          Stack.Push(FVariantManager.OpEqual(Value1, Value2));
        end;
      ttNotEqual:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          NormalizeValues(Value1, Value2);
          Stack.Push(FVariantManager.OpNotEqual(Value1, Value2));
        end;
      ttMore:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          NormalizeValues(Value1, Value2);
          Stack.Push(FVariantManager.OpMore(Value1, Value2));
        end;
      ttLess:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          NormalizeValues(Value1, Value2);
          Stack.Push(FVariantManager.OpLess(Value1, Value2));
        end;
      ttEqualMore:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpMoreEqual(Value1, Value2));
        end;
      ttEqualLess:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpLessEqual(Value1, Value2));
        end;
      ttPower:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(FVariantManager.OpPow(Value1, Value2));
        end;
      ttUnary:
        Stack.Push(FVariantManager.OpNegative(Stack.Pop));
      ttLike:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(EncodeBoolean(
                       IsMatch(FVariantManager.GetAsString(Value2),
                               FVariantManager.GetAsString(Value1))));
        end;
      ttNotLike:
        begin
          Value2 := Stack.Pop;
          Value1 := Stack.Pop;
          Stack.Push(EncodeBoolean(
                       not IsMatch(FVariantManager.GetAsString(Value2),
                                   FVariantManager.GetAsString(Value1))));
        end;
      ttIsNull:
        begin
          Value1 := Stack.Pop;
          Stack.Push(EncodeBoolean(FVariantManager.IsNull(Value1)));
        end;
      ttIsNotNull:
        begin
          Value1 := Stack.Pop;
          Stack.Push(EncodeBoolean(not FVariantManager.IsNull(Value1)));
        end;
      else
        raise TZExpressionError.Create(SInternalError);
    end;
  end;

  if Stack.Count <> 1 then
    raise TZExpressionError.Create(SInternalError);
  Result := Stack.Pop;
end;

end.
