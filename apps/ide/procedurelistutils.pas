unit procedurelistutils;

{$mode objfpc}{$h+}

interface

uses
  Classes, SysUtils;


// Extract the file extension from FileName and return it in all UPPERCASE.
function ExtractUpperFileExt(const FileName: string): string;

// Transforms all consecutive sequences of #10, #13, #32, and #9 in Str
// into a single space, and strips off whitespace at the beginning and
// end of the string
function CompressWhiteSpace(const Str: string): string;

// See if a string begins/ends with a specific substring
function StrBeginsWith(const SubStr, Str: string; CaseSensitive: Boolean = True): Boolean;
function StrEndsWith(const SubStr, Str: string; CaseSensitive: Boolean = True): Boolean;
// See is a string contains another substring
function StrContains(const SubStr, Str: string; CaseSensitive: Boolean = True): Boolean;

// Find SubString in S; do not consider case;
// this works exactly the same as the Pos function,
// except for case-INsensitivity.
function CaseInsensitivePos(Pat, Text: PChar): Integer; overload;
function CaseInsensitivePos(const Pat, Text: string): Integer; overload;
function AnsiCaseInsensitivePos(const SubString, S: string): Integer;

procedure MakeASCIICharTable;
procedure Initialize;

function IsCharAlpha(ch: Char): Boolean;
function IsCharUpper(ch: Char): Boolean;
function IsCharLower(ch: Char): Boolean;
function IsCharAlphaNumeric(ch: Char): Boolean;

// Emulates the VB $Right function to obtain up to n of the
// rightmost characters in a string.
function RightString(const Value: string; NumChars: Integer): string;

function IsPas(const FileName: string): Boolean;
function IsInc(const FileName: string): Boolean;
function IsProgram(const FileName: string): Boolean;


implementation

var
  LocaleIdentifierChars: set of Char;
  ASCIICharTable: array [#0..#255] of Byte;

const
  EmptyString = '';
  GxIdentChars       = ['A'..'Z', 'a'..'z', '0'..'9', '_'];
  GxIdentStartChars  = ['A'..'Z', 'a'..'z', '0'..'9'];
  GxAlphaChars       = ['A'..'Z', 'a'..'z'];
  GxUpperAlphaChars  = ['A'..'Z'];
  GxLowerAlphaChars  = ['a'..'z'];
  GxSentenceEndChars = ['.', '!', '?'];

  SAllAlphaNumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';


function ExtractUpperFileExt(const FileName: string): string;
begin
  Result := UpperCase(ExtractFileExt(FileName));
end;

function CompressWhiteSpace(const Str: string): string;
var
  i: Integer;
  Len: Integer;
  NextResultChar: Integer;
  CheckChar: Char;
  NextChar: Char;
begin
  Len := Length(Str);
  NextResultChar := 1;
  SetLength(Result, Len);

  for i := 1 to Len do
  begin
    CheckChar := Str[i];
    {$RANGECHECKS OFF}
    NextChar := Str[i + 1];
    {$RANGECHECKS ON}
    case CheckChar of
      #9, #10, #13, #32:
        begin
          if (NextChar in [#0, #9, #10, #13, #32]) or (NextResultChar = 1) then
            Continue
          else
          begin
            Result[NextResultChar] := #32;
            Inc(NextResultChar);
          end;
        end;
      else
        begin
          Result[NextResultChar] := Str[i];
          Inc(NextResultChar);
        end;
    end;
  end;
  if Len = 0 then
    Exit;
  SetLength(Result, NextResultChar - 1);
end;

function StrBeginsWith(const SubStr, Str: string; CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := Pos(SubStr, Str) = 1
  else
    Result := CaseInsensitivePos(SubStr, Str) = 1;
end;

function StrEndsWith(const SubStr, Str: string; CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := RightString(Str, Length(SubStr)) = SubStr
  else
    Result := SameText(RightString(Str, Length(SubStr)), SubStr);
end;

function StrContains(const SubStr, Str: string; CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := Pos(SubStr, Str) > 0
  else
    Result := CaseInsensitivePos(SubStr, Str) > 0;
end;

function CaseInsensitivePos(Pat, Text: PChar): Integer;
var
  RunPat, RunText, PosPtr: PChar;
begin
  Result := 0;
  RunPat := Pat;
  RunText := Text;
  while RunText^ <> #0 do
  begin
    if (ASCIICharTable[RunPat^] = ASCIICharTable[RunText^]) then
    begin
      PosPtr := RunText;
      while RunPat^ <> #0 do
      begin
        if ASCIICharTable[RunPat^] <> ASCIICharTable[RunText^] then
          Break;
        Inc(RunPat);
        Inc(RunText);
      end;
      if RunPat^ = #0 then
      begin
        Result := PosPtr - Text + 1;
        Break;
      end;
    end
    else
      Inc(RunText);
    RunPat := Pat;
  end;
end;

function CaseInsensitivePos(const Pat, Text: string): Integer; overload;
begin
  Result := CaseInsensitivePos(PChar(Pat), PChar(Text));
end;

function AnsiCaseInsensitivePos(const SubString, S: string): Integer;
begin
  Result := AnsiPos(AnsiUpperCase(SubString), AnsiUpperCase(S));
end;

procedure MakeASCIICharTable;
var
  i: Integer;
begin
  for i := 0 to 255 do
  begin
    If (I > 64) and (I < 91) then
      ASCIICharTable[Char(I)] := i + 32
    else
      ASCIICharTable[Char(I)] := i;
  end;
end;

procedure Initialize;
var
  i: Char;
begin
  for i := Low(Char) to High(Char) do
    if IsCharAlphaNumeric(i) then
      Include(LocaleIdentifierChars, i);
  Include(LocaleIdentifierChars, '_');
  MakeASCIICharTable;
end;

function IsCharAlpha(ch: Char): Boolean;
begin
 Result := (ch in GxAlphaChars);
end;

function IsCharUpper(ch: Char): Boolean;
begin
  Result := (ch in GxUpperAlphaChars);
end;

function IsCharLower(ch: Char): Boolean;
begin
  Result := (ch in GxLowerAlphaChars);
end;

function IsCharAlphaNumeric(ch: Char): Boolean;
begin
  Result := (ch in GxIdentStartChars);
end;

function RightString(const Value: string; NumChars: Integer): string;
begin
  Result := Copy(Value, (Length(Value) - NumChars) + 1, NumChars);
end;

function IsPas(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.PAS');
end;

function IsInc(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.INC');
end;

function IsProgram(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.LPR') or (FileExt = '.DPR');
end;


initialization
  Initialize;

end.

