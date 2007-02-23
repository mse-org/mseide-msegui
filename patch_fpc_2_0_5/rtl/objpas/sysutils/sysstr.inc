{
    *********************************************************************
    Copyright (C) 1997, 1998 Gertjan Schouten

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
    *********************************************************************

    System Utilities For Free Pascal
}

{   NewStr creates a new PString and assigns S to it
    if length(s) = 0 NewStr returns Nil   }

function NewStr(const S: string): PString;
begin
  if (S='') then
   Result:=nil
  else
   begin
     new(result);
     if (Result<>nil) then
       Result^:=s;
   end;
end;

{   DisposeStr frees the memory occupied by S   }

procedure DisposeStr(S: PString);
begin
  if S <> Nil then
   begin
     dispose(s);
     S:=nil;
   end;
end;

{   AssignStr assigns S to P^   }

procedure AssignStr(var P: PString; const S: string);
begin
  P^ := s;
end ;

{   AppendStr appends S to Dest   }

procedure AppendStr(var Dest: String; const S: string);
begin
Dest := Dest + S;
end ;

{   UpperCase returns a copy of S where all lowercase characters ( from a to z )
    have been converted to uppercase   }


Function UpperCase(Const S : String) : String;

Var
  i : Integer;
  P : PChar;

begin
  Result := S;
  UniqueString(Result);
  P:=Pchar(Result);
  for i := 1 to Length(Result) do
    begin
    if (P^ in ['a'..'z']) then P^ := char(byte(p^) - 32);
      Inc(P);
    end;
end;

{   LowerCase returns a copy of S where all uppercase characters ( from A to Z )
    have been converted to lowercase  }

Function Lowercase(Const S : String) : String;

Var
  i : Integer;
  P : PChar;

begin
  Result := S;
  UniqueString(Result);
  P:=Pchar(Result);
  for i := 1 to Length(Result) do
    begin
    if (P^ in ['A'..'Z']) then P^ := char(byte(p^) + 32);
      Inc(P);
    end;
end;

function LowerCase(const V: variant): string; overload;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=LowerCase(ansistring(V));
  end;


{   CompareStr compares S1 and S2, the result is the based on
    substraction of the ascii values of the characters in S1 and S2
    case     result
    S1 < S2  < 0
    S1 > S2  > 0
    S1 = S2  = 0     }

function CompareStr(const S1, S2: string): Integer;
var count, count1, count2: integer;
begin
  result := 0;
  Count1 := Length(S1);
  Count2 := Length(S2);
  if Count1>Count2 then
    Count:=Count2
  else
    Count:=Count1;
  result := CompareMemRange(Pointer(S1),Pointer(S2), Count);
  if result=0 then
    result:=Count1-Count2;
end;

{   CompareMemRange returns the result of comparison of Length bytes at P1 and P2
    case       result
    P1 < P2    < 0
    P1 > P2    > 0
    P1 = P2    = 0    }

function CompareMemRange(P1, P2: Pointer; Length: cardinal): integer;

var
  i: cardinal;

begin
  i := 0;
  result := 0;
  while (result=0) and (I<length) do
    begin
    result:=byte(P1^)-byte(P2^);
    P1:=pchar(P1)+1;            // VP compat.
    P2:=pchar(P2)+1;
    i := i + 1;
   end ;
end ;

function CompareMem(P1, P2: Pointer; Length: cardinal): Boolean;
var
  i: cardinal;
begin
  Result:=True;
  I:=0;
  If (P1)<>(P2) then
    While Result and (i<Length) do
      begin
      Result:=PByte(P1)^=PByte(P2)^;
      Inc(I);
      Inc(pchar(P1));
      Inc(pchar(P2));
      end;
end;


{   CompareText compares S1 and S2, the result is the based on
    substraction of the ascii values of characters in S1 and S2
    comparison is case-insensitive
    case     result
    S1 < S2  < 0
    S1 > S2  > 0
    S1 = S2  = 0     }

function CompareText(const S1, S2: string): integer;

var
  i, count, count1, count2: integer; Chr1, Chr2: byte;
begin
  result := 0;
  Count1 := Length(S1);
  Count2 := Length(S2);
  if (Count1>Count2) then
    Count := Count2
  else
    Count := Count1;
  i := 0;
  while (result=0) and (i<count) do
    begin
    inc (i);
     Chr1 := byte(s1[i]);
     Chr2 := byte(s2[i]);
     if Chr1 in [97..122] then
       dec(Chr1,32);
     if Chr2 in [97..122] then
       dec(Chr2,32);
     result := Chr1 - Chr2;
     end ;
  if (result = 0) then
    result:=(count1-count2);
end;

function SameText(const s1,s2:String):Boolean;

begin
 Result:=CompareText(S1,S2)=0;
end;

{==============================================================================}
{   Ansi string functions                                                      }
{   these functions rely on the character set loaded by the OS                 }
{==============================================================================}

function GenericAnsiUpperCase(const s: string): string;
  var
    len, i: integer;
begin
  len := length(s);
  SetLength(result, len);
  for i := 1 to len do
     result[i] := UpperCaseTable[ord(s[i])];
end;


function GenericAnsiLowerCase(const s: string): string;
  var
    len, i: integer;
begin
  len := length(s);
  SetLength(result, len);
  for i := 1 to len do
     result[i] := LowerCaseTable[ord(s[i])];
end;


function GenericAnsiCompareStr(const S1, S2: string): PtrInt;
  Var
    I,L1,L2 : SizeInt;
begin
  Result:=0;
  L1:=Length(S1);
  L2:=Length(S2);
  I:=1;
  While (Result=0) and ((I<=L1) and (I<=L2)) do
    begin
    Result:=Ord(S1[I])-Ord(S2[I]); //!! Must be replaced by ansi characters !!
    Inc(I);
    end;
  If Result=0 Then
    Result:=L1-L2;
end;

function GenericAnsiCompareText(const S1, S2: string): PtrInt;
  Var
    I,L1,L2 : SizeInt;
begin
  Result:=0;
  L1:=Length(S1);
  L2:=Length(S2);
  I:=1;
  While (Result=0) and ((I<=L1) and (I<=L2)) do
    begin
    Result:=Ord(LowerCaseTable[Ord(S1[I])])-Ord(LowerCaseTable[Ord(S2[I])]); //!! Must be replaced by ansi characters !!
    Inc(I);
    end;
  If Result=0 Then
    Result:=L1-L2;
end;

function AnsiSameText(const s1,s2:String):Boolean;{$ifdef SYSUTILSINLINE}inline;{$endif}

begin
 AnsiSameText:=AnsiCompareText(S1,S2)=0;
end;

function AnsiSameStr(const s1,s2:String):Boolean;{$ifdef SYSUTILSINLINE}inline;{$endif}

begin
  AnsiSameStr:=AnsiCompareStr(S1,S2)=0;
end;

function GenericAnsiStrComp(S1, S2: PChar): PtrInt;

begin
  Result:=0;
  If S1=Nil then
    begin
      If S2=Nil Then Exit;
      result:=-1;
      exit;
    end;
  If S2=Nil then
    begin
      Result:=1;
      exit;
    end;
  Repeat
    Result:=Ord(S1^)-Ord(S2^); //!! Must be replaced by ansi characters !!
    Inc(S1);
    Inc(S2);
  Until (Result<>0) or (S1^=#0) or (S2^=#0);
  if (Result=0) and (S1^<>S2^) then // loop ended because exactly one has #0
    if S1^=#0 then // shorter string is smaller
      result:=-1
    else
      result:=1;
end;


function GenericAnsiStrIComp(S1, S2: PChar): PtrInt;

begin
  Result:=0;
  If S1=Nil then
    begin
    If S2=Nil Then Exit;
    result:=-1;
    exit;
    end;
  If S2=Nil then
    begin
    Result:=1;
    exit;
    end;
  Repeat
    Result:=Ord(LowerCaseTable[Ord(S1[0])])-Ord(LowerCaseTable[Ord(S2[0])]); //!! Must be replaced by ansi characters !!
    Inc(S1);
    Inc(S2);
  Until (Result<>0) or ((S1[0]=#0) or (S2[0]=#0))
end;


function GenericAnsiStrLComp(S1, S2: PChar; MaxLen: PtrUInt): PtrInt;

Var I : cardinal;

begin
  Result:=0;
  If MaxLen=0 then exit;
  If S1=Nil then
    begin
    If S2=Nil Then Exit;
    result:=-1;
    exit;
    end;
  If S2=Nil then
    begin
    Result:=1;
    exit;
    end;
  I:=0;
  Repeat
    Result:=Ord(S1[0])-Ord(S2[0]); //!! Must be replaced by ansi characters !!
    Inc(S1);
    Inc(S2);
    Inc(I);
  Until (Result<>0) or ((S1[0]=#0) or (S2[0]=#0)) or (I=MaxLen)
end;


function GenericAnsiStrLIComp(S1, S2: PChar; MaxLen: PtrUInt): PtrInt;

Var I : cardinal;

begin
  Result:=0;
  If MaxLen=0 then exit;
  If S1=Nil then
    begin
    If S2=Nil Then Exit;
    result:=-1;
    exit;
    end;
  If S2=Nil then
    begin
    Result:=1;
    exit;
    end;
  I:=0;
  Repeat
    Result:=Ord(LowerCaseTable[Ord(S1[0])])-Ord(LowerCaseTable[Ord(S2[0])]); //!! Must be replaced by ansi characters !!
    Inc(S1);
    Inc(S2);
    Inc(I);
  Until (Result<>0) or ((S1[0]=#0) or (S2[0]=#0)) or (I=MaxLen)
end;


function GenericAnsiStrLower(Str: PChar): PChar;
begin
result := Str;
if Str <> Nil then begin
   while Str^ <> #0 do begin
      Str^ := LowerCaseTable[byte(Str^)];
      Str := Str + 1;
      end;
   end;
end;


function GenericAnsiStrUpper(Str: PChar): PChar;
begin
result := Str;
if Str <> Nil then begin
   while Str^ <> #0 do begin
      Str^ := UpperCaseTable[byte(Str^)];
      Str := Str + 1;
      end ;
   end ;
end ;

function AnsiLastChar(const S: string): PChar;

begin
  //!! No multibyte yet, so we return the last one.
  result:=StrEnd(Pchar(S));
  Dec(Result);
end ;

function AnsiStrLastChar(Str: PChar): PChar;
begin
  //!! No multibyte yet, so we return the last one.
  result:=StrEnd(Str);
  Dec(Result);
end ;


function AnsiUpperCase(const s: string): string;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.UpperAnsiStringProc(s);
  end;


function AnsiLowerCase(const s: string): string;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.LowerAnsiStringProc(s);
  end;


function AnsiCompareStr(const S1, S2: string): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.CompareStrAnsiStringProc(s1,s2);
  end;


function AnsiCompareText(const S1, S2: string): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.CompareTextAnsiStringProc(s1,s2);
  end;


function AnsiStrComp(S1, S2: PChar): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrCompAnsiStringProc(s1,s2);
  end;


function AnsiStrIComp(S1, S2: PChar): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrICompAnsiStringProc(s1,s2);
  end;


function AnsiStrLComp(S1, S2: PChar; MaxLen: cardinal): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrLCompAnsiStringProc(s1,s2,maxlen);
  end;


function AnsiStrLIComp(S1, S2: PChar; MaxLen: cardinal): integer;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrLICompAnsiStringProc(s1,s2,maxlen);
  end;


function AnsiStrLower(Str: PChar): PChar;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrLowerAnsiStringProc(Str);
  end;


function AnsiStrUpper(Str: PChar): PChar;{$ifdef SYSUTILSINLINE}inline;{$endif}
  begin
    result:=widestringmanager.StrUpperAnsiStringProc(Str);
  end;


{==============================================================================}
{  End of Ansi functions                                                       }
{==============================================================================}

{   Trim returns a copy of S with blanks characters on the left and right stripped off   }

Const WhiteSpace = [#0..' '];

function Trim(const S: string): string;
var Ofs, Len: integer;
begin
  len := Length(S);
  while (Len>0) and (S[Len] in WhiteSpace) do
   dec(Len);
  Ofs := 1;
  while (Ofs<=Len) and (S[Ofs] in WhiteSpace) do
   Inc(Ofs);
  result := Copy(S, Ofs, 1 + Len - Ofs);
end ;

{   TrimLeft returns a copy of S with all blank characters on the left stripped off  }

function TrimLeft(const S: string): string;
var i,l:integer;
begin
  l := length(s);
  i := 1;
  while (i<=l) and (s[i] in whitespace) do
   inc(i);
  Result := copy(s, i, l);
end ;

{   TrimRight returns a copy of S with all blank characters on the right stripped off  }

function TrimRight(const S: string): string;
var l:integer;
begin
  l := length(s);
  while (l>0) and (s[l] in whitespace) do
   dec(l);
  result := copy(s,1,l);
end ;

{   QuotedStr returns S quoted left and right and every single quote in S
    replaced by two quotes   }

function QuotedStr(const S: string): string;
begin
result := AnsiQuotedStr(s, '''');
end ;

{   AnsiQuotedStr returns S quoted left and right by Quote,
    and every single occurance of Quote replaced by two   }

function AnsiQuotedStr(const S: string; Quote: char): string;
var i, j, count: integer;
begin
result := '' + Quote;
count := length(s);
i := 0;
j := 0;
while i < count do begin
   i := i + 1;
   if S[i] = Quote then begin
      result := result + copy(S, 1 + j, i - j) + Quote;
      j := i;
      end ;
   end ;
if i <> j then
   result := result + copy(S, 1 + j, i - j);
result := result + Quote;
end ;

{   AnsiExtractQuotedStr returns a copy of Src with quote characters
    deleted to the left and right and double occurances
    of Quote replaced by a single Quote   }


function AnsiExtractQuotedStr(var  Src: PChar; Quote: Char): string;
var
  P,Q,R: PChar;
begin
 P := Src;
 Q := StrEnd(P);
 result:='';
 if P=Q then exit;
 if P^<>quote then exit;
 inc(p);

 setlength(result,(Q-P)+1);
 R:=@Result[1];
 while P <> Q do
   begin
     R^:=P^;
     inc(R);
     if (P^ = Quote) then
       begin
         P := P + 1;
         if (p^ <> Quote) then
          begin
            dec(R);
            break;
          end;
       end;
     P := P + 1;
   end ;
 src:=p;
 SetLength(result, (R-pchar(@Result[1])));
end ;


{   AdjustLineBreaks returns S with all CR characters not followed by LF
    replaced with CR/LF  }
//  under Linux all CR characters or CR/LF combinations should be replaced with LF

function AdjustLineBreaks(const S: string): string;

begin
  Result:=AdjustLineBreaks(S,DefaultTextLineBreakStyle);
end;

function AdjustLineBreaks(const S: string; Style: TTextLineBreakStyle): string;
var
  Source,Dest: PChar;
  DestLen: Integer;
  I,J,L: Longint;

begin
  Source:=Pointer(S);
  L:=Length(S);
  DestLen:=L;
  I:=1;
  while (I<=L) do
    begin
    case S[i] of
      #10: if (Style=tlbsCRLF) then
               Inc(DestLen);
      #13: if (Style=tlbsCRLF) then
             if (I<L) and (S[i+1]=#10) then
               Inc(I)
             else
               Inc(DestLen)
             else if (I<L) and (S[I+1]=#10) then
               Dec(DestLen);
    end;
    Inc(I);
    end;
  if (DestLen=L) then
    Result:=S
  else
    begin
    SetLength(Result, DestLen);
    FillChar(Result[1],DestLen,0);
    Dest := Pointer(Result);
    J:=0;
    I:=0;
    While I<L do
      case Source[I] of
        #10: begin
             if Style=tlbsCRLF then
               begin
               Dest[j]:=#13;
               Inc(J);
              end;
             Dest[J] := #10;
             Inc(J);
             Inc(I);
             end;
        #13: begin
             if Style=tlbsCRLF then
               begin
               Dest[j] := #13;
               Inc(J);
               end;
             Dest[j]:=#10;
             Inc(J);
             Inc(I);
             if Source[I]=#10 then
               Inc(I);
             end;
      else
        Dest[j]:=Source[i];
        Inc(J);
        Inc(I);
      end;
    end;
end;


{   IsValidIdent returns true if the first character of Ident is in:
    'A' to 'Z', 'a' to 'z' or '_' and the following characters are
    on of: 'A' to 'Z', 'a' to 'z', '0'..'9' or '_'    }

function IsValidIdent(const Ident: string): boolean;
var i, len: integer;
begin
result := false;
len := length(Ident);
if len <> 0 then begin
   result := Ident[1] in ['A'..'Z', 'a'..'z', '_'];
   i := 1;
   while (result) and (i < len) do begin
      i := i + 1;
      result := result and (Ident[i] in ['A'..'Z', 'a'..'z', '0'..'9', '_']);
      end ;
   end ;
end ;

{   IntToStr returns a string representing the value of Value    }

function IntToStr(Value: integer): string;
begin
 System.Str(Value, result);
end ;


function IntToStr(Value: int64): string;
begin
 System.Str(Value, result);
end ;

function IntToStr(Value: QWord): string;
begin
 System.Str(Value, result);
end ;


{   IntToHex returns a string representing the hexadecimal value of Value   }

const
   HexDigits: array[0..15] of char = '0123456789ABCDEF';

function IntToHex(Value: integer; Digits: integer): string;
var i: integer;
begin
 SetLength(result, digits);
 for i := 0 to digits - 1 do
  begin
   result[digits - i] := HexDigits[value and 15];
   value := value shr 4;
  end ;
 while value <> 0 do begin
   result := HexDigits[value and 15] + result;
   value := value shr 4;
 end;
end ;

function IntToHex(Value: int64; Digits: integer): string;
var i: integer;
begin
 SetLength(result, digits);
 for i := 0 to digits - 1 do
  begin
   result[digits - i] := HexDigits[value and 15];
   value := value shr 4;
  end ;
 while value <> 0 do begin
   result := HexDigits[value and 15] + result;
   value := value shr 4;
 end;
end ;


function TryStrToInt(const s: string; var i : integer) : boolean;
var Error : word;
begin
  Val(s, i, Error);
  TryStrToInt:=Error=0
end;

{   StrToInt converts the string S to an integer value,
    if S does not represent a valid integer value EConvertError is raised  }

function StrToInt(const S: string): integer;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then raise EConvertError.createfmt(SInvalidInteger,[S]);
end ;


function StrToInt64(const S: string): int64;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then raise EConvertError.createfmt(SInvalidInteger,[S]);
end;


function TryStrToInt64(const s: string; var i : int64) : boolean;
var Error : word;
begin
  Val(s, i, Error);
  TryStrToInt64:=Error=0
end;


function StrToQWord(const s: string): QWord;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then raise EConvertError.createfmt(SInvalidInteger,[S]);
end;


function TryStrToQWord(const s: string; var Q: QWord): boolean;
var Error : word;
begin
  Val(s, Q, Error);
  TryStrToQWord:=Error=0
end;

{   StrToIntDef converts the string S to an integer value,
    Default is returned in case S does not represent a valid integer value  }

function StrToIntDef(const S: string; Default: integer): integer;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then result := Default;
end ;

{   StrToInt64Def converts the string S to an int64 value,
    Default is returned in case S does not represent a valid int64 value  }

function StrToInt64Def(const S: string; Default: int64): int64;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then result := Default;
end ;

{   StrToQWordDef converts the string S to an QWord value,
    Default is returned in case S does not represent a valid QWord value  }

function StrToQWordDef(const S: string; Default: QWord): QWord;
var Error: word;
begin
  Val(S, result, Error);
  if Error <> 0 then result := Default;
end;

{   LoadStr returns the string resource Ident.   }

function LoadStr(Ident: integer): string;
begin
  result:='';
end ;

{   FmtLoadStr returns the string resource Ident and formats it accordingly   }


function FmtLoadStr(Ident: integer; const Args: array of const): string;
begin
  result:='';
end;

Const
  feInvalidFormat   = 1;
  feMissingArgument = 2;
  feInvalidArgIndex = 3;

{$ifdef fmtdebug}
Procedure Log (Const S: String);
begin
 Writeln (S);
end;
{$endif}


Procedure DoFormatError (ErrCode : Longint);
Var
  S : String;
begin
  //!! must be changed to contain format string...
  S:='';
  Case ErrCode of
   feInvalidFormat : raise EConvertError.Createfmt(SInvalidFormat,[s]);
   feMissingArgument : raise EConvertError.Createfmt(SArgumentMissing,[s]);
   feInvalidArgIndex : raise EConvertError.Createfmt(SInvalidArgIndex,[s]);
 end;
end;


{ we've no templates, but with includes we can simulate this :) }

{$macro on}
{$define INFORMAT}
{$define TFormatString:=ansistring}
{$define TFormatChar:=char}

Function Format (Const Fmt : AnsiString; const Args : Array of const) : AnsiString;
{$i sysformt.inc}

{$undef TFormatString}
{$undef TFormatChar}
{$undef INFORMAT}
{$macro off}

Function FormatBuf (Var Buffer; BufLen : Cardinal;
                     Const Fmt; fmtLen : Cardinal;
                     Const Args : Array of const) : Cardinal;

Var S,F : String;

begin
  Setlength(F,fmtlen);
  if fmtlen > 0 then
    Move(fmt,F[1],fmtlen);
  S:=Format (F,Args);
  If Cardinal(Length(S))<Buflen then
    Result:=Length(S)
  else
    Result:=Buflen;
  Move(S[1],Buffer,Result);
end;

Procedure FmtStr(Var Res: String; Const Fmt : String; Const args: Array of const);

begin
  Res:=Format(fmt,Args);
end;

Function StrFmt(Buffer,Fmt : PChar; Const args: Array of const) : Pchar;

begin
  Buffer[FormatBuf(Buffer^,Maxint,Fmt^,strlen(fmt),args)]:=#0;
  Result:=Buffer;
end;

Function StrLFmt(Buffer : PCHar; Maxlen : Cardinal;Fmt : PChar; Const args: Array of const) : Pchar;

begin
  Buffer[FormatBuf(Buffer^,MaxLen,Fmt^,strlen(fmt),args)]:=#0;
  Result:=Buffer;
end;

Function StrToFloat(Const S: String): Extended;

Begin
  If Not TextToFloat(Pchar(S),Result) then
    Raise EConvertError.createfmt(SInValidFLoat,[S]);
End;

function StrToFloatDef(const S: string; const Default: Extended): Extended;

begin
   if not TextToFloat(PChar(S),Result,fvExtended) then
     Result:=Default;
end;

Function TextToFloat(Buffer: PChar; Var Value: Extended): Boolean;

Var
  E,P : Integer;
  S : String;

Begin
  S:=StrPas(Buffer);
  P:=Pos(DecimalSeparator,S);
  If (P<>0) Then
    S[P] := '.';
  Val(trim(S),Value,E);
  Result:=(E=0);
End;

Function TextToFloat(Buffer: PChar; Var Value; ValueType: TFloatValue): Boolean;

Var
  E,P : Integer;
  S : String;
  TempValue: extended;

Begin
  S:=StrPas(Buffer);
  P:=Pos(ThousandSeparator,S);
  While (P<>0) do
    begin
    Delete(S,P,1);
    P:=Pos(ThousandSeparator,S);
    end;
  P:=Pos(DecimalSeparator,S);
  If (P<>0) Then
    S[P] := '.';
  case ValueType of
    fvCurrency:
      begin
        // needed for platforms where Currency = Int64
        Val(S,TempValue,E);
        Currency(Value) := TempValue;
      end;
    fvExtended:
      Val(S,Extended(Value),E);
    fvDouble:
      Val(S,Double(Value),E);
    fvSingle:
      Val(S,Single(Value),E);
    fvComp:
      Val(S,Comp(Value),E);
    fvReal:
      Val(S,Real(Value),E);
  end;
  Result:=(E=0);
End;

Function TryStrToFloat(Const S : String; Var Value: Single): Boolean;
Begin
  Result := TextToFloat(PChar(S), Value, fvSingle);
End;

Function TryStrToFloat(Const S : String; Var Value: Double): Boolean;
Begin
  Result := TextToFloat(PChar(S), Value, fvDouble);
End;

{$ifdef FPC_HAS_TYPE_EXTENDED}
Function TryStrToFloat(Const S : String; Var Value: Extended): Boolean;
Begin
  Result := TextToFloat(PChar(S), Value);
End;
{$endif FPC_HAS_TYPE_EXTENDED}


const
{$ifdef FPC_HAS_TYPE_EXTENDED}
  maxdigits = 15;
{$else}
  maxdigits = 14;
{$endif}

Function FloatToStrFIntl(Value: Extended; format: TFloatFormat; Precision, Digits: Integer; ValueType: TFloatValue): String;
Var
  P: Integer;
  Negative, TooSmall, TooLarge: Boolean;

Begin
  Case format Of

    ffGeneral:

      Begin
        If (Precision = -1) Or (Precision > maxdigits) Then Precision := maxdigits;
        TooSmall := (Abs(Value) < 0.00001) and (Value>0.0);
        If Not TooSmall Then
        Begin
          case ValueType of
            fvDouble:
              Str(Double(Value):digits:precision, Result);
            fvSingle:
              Str(Single(Value):digits:precision, Result);
            else
              Str(Extended(Value):digits:precision, Result);
          end;
          P := Pos('.', Result);
          if P<>0 then
            Result[P] := DecimalSeparator;
          TooLarge :=(P > Precision + 1) or (Pos('E', Result)<>0);
        End;

        If TooSmall Or TooLarge Then
          begin
            Result := FloatToStrF(Value, ffExponent, Precision, Digits);
            // Strip unneeded zeroes.
            P:=Pos('E',result)-1;
            If P<>-1 then
              begin
                { delete superfluous +? }
                if result[p+2]='+' then
                  system.Delete(Result,P+2,1);
                While (P>1) and (Result[P]='0') do
                  begin
                    system.Delete(Result,P,1);
                    Dec(P);
                  end;
                If (P>0) and (Result[P]=DecimalSeparator) Then
                  begin
                    system.Delete(Result,P,1);
                    Dec(P);
                  end;
              end;
            end
        else if (P<>0) then // we have a decimalseparator
          begin
            P := Length(Result);
            While (P>0) and (Result[P] = '0') Do
              Dec(P);
            If (P>0) and (Result[P]=DecimalSeparator) Then
              Dec(P);
            SetLength(Result, P);
          end;
      End;

    ffExponent:

      Begin
        If (Precision = -1) Or (Precision > maxdigits) Then Precision := maxdigits;
        case ValueType of
          fvDouble:
            Str(Double(Value):Precision+8, Result);
          fvSingle:
            Str(Single(Value):Precision+8, Result);
          else
            Str(Extended(Value):Precision+8, Result);
        end;
        Result[3] := DecimalSeparator;
        P:=4;
        While (P>0) and (Digits < P) And (Result[Precision + 5] = '0') do
          Begin
          If P<>1 then
            system.Delete(Result, Precision + 5, 1)
          else
            system.Delete(Result, Precision + 3, 3);
          Dec(P);
          end;
        If Result[1] = ' ' Then
          System.Delete(Result, 1, 1);
      End;

    ffFixed:

      Begin
        If Digits = -1 Then Digits := 2
        Else If Digits > 18 Then Digits := 18;
        case ValueType of
          fvDouble:
            Str(Double(Value):0:Digits, Result);
          fvSingle:
            Str(Single(Value):0:Digits, Result);
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        If Result[1] = ' ' Then
          System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then Result[P] := DecimalSeparator;
      End;

    ffNumber:

      Begin
        If Digits = -1 Then Digits := 2
        Else If Digits > maxdigits Then Digits := maxdigits;
        case ValueType of
          fvDouble:
            Str(Double(Value):0:Digits, Result);
          fvSingle:
            Str(Single(Value):0:Digits, Result);
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        If Result[1] = ' ' Then System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then
          Result[P] := DecimalSeparator
        else
          P := Length(Result)+1;
        Dec(P, 3);
        While (P > 1) Do
        Begin
          If Result[P - 1] <> '-' Then Insert(ThousandSeparator, Result, P);
          Dec(P, 3);
        End;
      End;

    ffCurrency:

      Begin
        If Value < 0 Then
        Begin
          Negative := True;
          Value := -Value;
        End
        Else Negative := False;

        If Digits = -1 Then Digits := CurrencyDecimals
        Else If Digits > 18 Then Digits := 18;
        case ValueType of
          fvDouble:
            Str(Double(Value):0:Digits, Result);
          fvSingle:
            Str(Single(Value):0:Digits, Result);
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        If Result[1] = ' ' Then System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then Result[P] := DecimalSeparator;
        Dec(P, 3);
        While (P > 1) Do
        Begin
          Insert(ThousandSeparator, Result, P);
          Dec(P, 3);
        End;

        If Not Negative Then
        Begin
          Case CurrencyFormat Of
            0: Result := CurrencyString + Result;
            1: Result := Result + CurrencyString;
            2: Result := CurrencyString + ' ' + Result;
            3: Result := Result + ' ' + CurrencyString;
          End
        End
        Else
        Begin
          Case NegCurrFormat Of
            0: Result := '(' + CurrencyString + Result + ')';
            1: Result := '-' + CurrencyString + Result;
            2: Result := CurrencyString + '-' + Result;
            3: Result := CurrencyString + Result + '-';
            4: Result := '(' + Result + CurrencyString + ')';
            5: Result := '-' + Result + CurrencyString;
            6: Result := Result + '-' + CurrencyString;
            7: Result := Result + CurrencyString + '-';
            8: Result := '-' + Result + ' ' + CurrencyString;
            9: Result := '-' + CurrencyString + ' ' + Result;
            10: Result := CurrencyString + ' ' + Result + '-';
          End;
        End;
      End;
  End;
End;

{$ifdef FPC_HAS_TYPE_EXTENDED}
Function FloatToStr(Value: Extended): String;
Begin
  Result := FloatToStrFIntl(Value, ffGeneral, 15, 0, fvExtended);
End;
{$endif FPC_HAS_TYPE_EXTENDED}

Function FloatToStr(Value: Currency): String;
Begin
  Result := FloatToStrFIntl(Value, ffGeneral, 15, 0, fvCurrency);
End;

Function FloatToStr(Value: Double): String;
Begin
  Result := FloatToStrFIntl(Value, ffGeneral, 15, 0, fvDouble);
End;

Function FloatToStr(Value: Single): String;
Begin
  Result := FloatToStrFIntl(Value, ffGeneral, 15, 0, fvSingle);
End;

Function FloatToStr(Value: Comp): String;
Begin
  Result := FloatToStrFIntl(Value, ffGeneral, 15, 0, fvComp);
End;

{$ifndef FPC_COMP_IS_INT64}
Function FloatToStr(Value: Int64): String;
Begin
  Result := FloatToStrFIntl(Comp(Value), ffGeneral, 15, 0, fvComp);
End;
{$endif FPC_COMP_IS_INT64}


Function FloatToText(Buffer: PChar; Value: Extended; format: TFloatFormat; Precision, Digits: Integer): Longint;
Var
  Tmp: String[40];
Begin
  Tmp := FloatToStrF(Value, format, Precision, Digits);
  Result := Length(Tmp);
  Move(Tmp[1], Buffer[0], Result);
End;

{$ifdef FPC_HAS_TYPE_EXTENDED}
Function FloatToStrF(Value: Extended; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(value,format,precision,digits,fvExtended);
end;
{$endif}

Function FloatToStrF(Value: Currency; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(value,format,precision,digits,fvCurrency);
end;

Function FloatToStrF(Value: Double; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(value,format,precision,digits,fvDouble);
end;

Function FloatToStrF(Value: Single; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(value,format,precision,digits,fvSingle);
end;

Function FloatToStrF(Value: Comp; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(value,format,precision,digits,fvComp);
end;

{$ifndef FPC_COMP_IS_INT64}
Function FloatToStrF(Value: Int64; format: TFloatFormat; Precision, Digits: Integer): String;
begin
  result := FloatToStrFIntl(Comp(value),format,precision,digits,fvComp);
end;
{$endif FPC_COMP_IS_INT64}


Function CurrToStrF(Value: Currency; Format: TFloatFormat; Digits: Integer): string;
  begin
    result:=FloatToStrF(Value,Format,19,Digits);
  end;


Function FloatToDateTime (Const Value : Extended) : TDateTime;
begin
  If (Value<MinDateTime) or (Value>MaxDateTime) then
    Raise EConvertError.CreateFmt (SInvalidDateTime,[Value]);
  Result:=Value;
end;

function TryFloatToCurr(const Value: Extended; var AResult: Currency): Boolean;

begin
  Result:=(Value>=MinCurrency) and (Value<=MaxCurrency);
  if Result then
    AResult := Value;
end;

function FloatToCurr(const Value: Extended): Currency;

begin
  if not TryFloatToCurr(Value, Result) then
    Raise EConvertError.CreateFmt(SInvalidCurrency, [FloatToStr(Value)]);
end;


Function CurrToStr(Value: Currency): string;
begin
  Result:=FloatToStrF(Value,ffNumber,15,2);
end;

function StrToCurr(const S: string): Currency;
begin
  if not TextToFloat(PChar(S), Result, fvCurrency) then
    Raise EConvertError.createfmt(SInValidFLoat,[S]);
end;


Function TryStrToCurr(Const S : String; Var Value: Currency): Boolean;
Begin
  Result := TextToFloat(PChar(S), Value, fvCurrency);
End;


function StrToCurrDef(const S: string; Default : Currency): Currency;
begin
  if not TextToFloat(PChar(S), Result, fvCurrency) then
    Result:=Default;
end;

function StrToBool(const S: string): Boolean;

Var
  Temp : String;
  D : Double;
  Code: word;

begin
  Temp:=upcase(S);
  Val(temp,D,code);
  If Code=0 then
    Result:=(D<>0.0)
  else If Temp='TRUE' then
    result:=true
  else if Temp='FALSE' then
    result:=false
  else
    Raise EConvertError.CreateFmt(SInvalidBoolean,[S]);
end;

function BoolToStr(B: Boolean): string;
begin
  If B then
    Result:='TRUE'
  else
    Result:='FALSE';
end;

Function FloatToTextFmt(Buffer: PChar; Value: Extended; format: PChar): Integer;

Var
  Digits: String[40];                         { String Of Digits                 }
  Exponent: String[8];                        { Exponent strin                   }
  FmtStart, FmtStop: PChar;                   { Start And End Of relevant part   }
                                              { Of format String                 }
  ExpFmt, ExpSize: Integer;                   { Type And Length Of               }
                                              { exponential format chosen        }
  Placehold: Array[1..4] Of Integer;          { Number Of placeholders In All    }
                                              { four Sections                    }
  thousand: Boolean;                          { thousand separators?             }
  UnexpectedDigits: Integer;                  { Number Of unexpected Digits that }
                                              { have To be inserted before the   }
                                              { First placeholder.               }
  DigitExponent: Integer;                     { Exponent Of First digit In       }
                                              { Digits Array.                    }

  { Find end of format section starting at P. False, if empty }

  Function GetSectionEnd(Var P: PChar): Boolean;
  Var
    C: Char;
    SQ, DQ: Boolean;
  Begin
    Result := False;
    SQ := False;
    DQ := False;
    C := P[0];
    While (C<>#0) And ((C<>';') Or SQ Or DQ) Do
      Begin
      Result := True;
      Case C Of
        #34: If Not SQ Then DQ := Not DQ;
        #39: If Not DQ Then SQ := Not SQ;
      End;
      Inc(P);
      C := P[0];
      End;
  End;

  { Find start and end of format section to apply. If section doesn't exist,
    use section 1. If section 2 is used, the sign of value is ignored.       }

  Procedure GetSectionRange(section: Integer);
  Var
    Sec: Array[1..3] Of PChar;
    SecOk: Array[1..3] Of Boolean;
  Begin
    Sec[1] := format;
    SecOk[1] := GetSectionEnd(Sec[1]);
    If section > 1 Then
      Begin
      Sec[2] := Sec[1];
      If Sec[2][0] <> #0 Then
        Inc(Sec[2]);
      SecOk[2] := GetSectionEnd(Sec[2]);
      If section > 2 Then
        Begin
        Sec[3] := Sec[2];
        If Sec[3][0] <> #0 Then
          Inc(Sec[3]);
        SecOk[3] := GetSectionEnd(Sec[3]);
        End;
      End;
    If Not SecOk[1] Then
      FmtStart := Nil
    Else
      Begin
      If Not SecOk[section] Then
        section := 1
      Else If section = 2 Then
        Value := -Value;   { Remove sign }
      If section = 1 Then FmtStart := format Else
        Begin
        FmtStart := Sec[section - 1];
        Inc(FmtStart);
        End;
      FmtStop := Sec[section];
      End;
  End;

  { Find format section ranging from FmtStart to FmtStop. }

  Procedure GetFormatOptions;
  Var
    Fmt: PChar;
    SQ, DQ: Boolean;
    area: Integer;
  Begin
    SQ := False;
    DQ := False;
    Fmt := FmtStart;
    ExpFmt := 0;
    area := 1;
    thousand := False;
    Placehold[1] := 0;
    Placehold[2] := 0;
    Placehold[3] := 0;
    Placehold[4] := 0;
    While Fmt < FmtStop Do
      Begin
      Case Fmt[0] Of
        #34:
          Begin
          If Not SQ Then
            DQ := Not DQ;
          Inc(Fmt);
          End;
        #39:
          Begin
          If Not DQ Then
            SQ := Not SQ;
          Inc(Fmt);
          End;
      Else
        { This was 'if not SQ or DQ'. Looked wrong... }
        If Not (SQ Or DQ) Then
          Begin
          Case Fmt[0] Of
            '0':
              Begin
              Case area Of
                1:
                  area := 2;
                4:
                  Begin
                  area := 3;
                  Inc(Placehold[3], Placehold[4]);
                  Placehold[4] := 0;
                  End;
              End;
              Inc(Placehold[area]);
              Inc(Fmt);
              End;

            '#':
              Begin
              If area=3 Then
                area:=4;
              Inc(Placehold[area]);
              Inc(Fmt);
              End;
            '.':
              Begin
              If area<3 Then
                area:=3;
              Inc(Fmt);
              End;
            ',':
              Begin
              thousand := True;
              Inc(Fmt);
              End;
            'e', 'E':
              If ExpFmt = 0 Then
                Begin
                If (Fmt[0]='E') Then
                  ExpFmt:=1
                Else
                  ExpFmt := 3;
                Inc(Fmt);
                If (Fmt<FmtStop) Then
                  Begin
                  Case Fmt[0] Of
                    '+':
                      Begin
                      End;
                    '-':
                      Inc(ExpFmt);
                  Else
                    ExpFmt := 0;
                  End;
                  If ExpFmt <> 0 Then
                    Begin
                    Inc(Fmt);
                    ExpSize := 0;
                    While (Fmt<FmtStop) And
                          (ExpSize<4) And
                          (Fmt[0] In ['0'..'9']) Do
                      Begin
                      Inc(ExpSize);
                      Inc(Fmt);
                      End;
                    End;
                  End;
                End
              Else
                Inc(Fmt);
          Else { Case }
            Inc(Fmt);
          End; { Case }
          End { Begin }
        Else 
          Begin
          Inc(Fmt)
          End;
      End; { Case }
      End; { While .. Begin }
  End;

  Procedure FloatToStr;

  Var
    I, J, Exp, Width, Decimals, DecimalPoint, len: Integer;

  Begin
    If ExpFmt = 0 Then
      Begin
      { Fixpoint }
      Decimals:=Placehold[3]+Placehold[4];
      Width:=Placehold[1]+Placehold[2]+Decimals;
      If (Decimals=0) Then
        Str(Value:Width:0,Digits)
      Else
        Str(Value:Width+1:Decimals,Digits);
      len:=Length(Digits);
      { Find the decimal point }
      If (Decimals=0) Then
        DecimalPoint:=len+1
      Else
        DecimalPoint:=len-Decimals;
      { If value is very small, and no decimal places
        are desired, remove the leading 0.            }
      If (Abs(Value) < 1) And (Placehold[2] = 0) Then
        Begin
        If (Placehold[1]=0) Then
          Delete(Digits,DecimalPoint-1,1)
        Else
          Digits[DecimalPoint-1]:=' ';
        End;

      { Convert optional zeroes to spaces. }
      I:=len;
      J:=DecimalPoint+Placehold[3];
      While (I>J) And (Digits[I]='0') Do
        Begin
        Digits[I] := ' ';
        Dec(I);
        End;
      { If integer value and no obligatory decimal
        places, remove decimal point. }
      If (DecimalPoint < len) And (Digits[DecimalPoint + 1] = ' ') Then
          Digits[DecimalPoint] := ' ';
      { Convert spaces left from obligatory decimal point to zeroes. }
      I:=DecimalPoint-Placehold[2];
      While (I<DecimalPoint) And (Digits[I]=' ') Do
        Begin
        Digits[I] := '0';
        Inc(I);
        End;
      Exp := 0;
      End
    Else
      Begin
      { Scientific: exactly <Width> Digits With <Precision> Decimals
        And adjusted Exponent. }
      If Placehold[1]+Placehold[2]=0 Then
        Placehold[1]:=1;
      Decimals := Placehold[3] + Placehold[4];
      Width:=Placehold[1]+Placehold[2]+Decimals;
      Str(Value:Width+8,Digits);
      { Find and cut out exponent. Always the
        last 6 characters in the string.
        -> 0000E+0000                         }
      I:=Length(Digits)-5;
      Val(Copy(Digits,I+1,5),Exp,J);
      Exp:=Exp+1-(Placehold[1]+Placehold[2]);
      Delete(Digits, I, 6);
      { Str() always returns at least one digit after the decimal point.
        If we don't want it, we have to remove it. }
      If (Decimals=0) And (Placehold[1]+Placehold[2]<= 1) Then
        Begin
        If (Digits[4]>='5') Then
          Begin
          Inc(Digits[2]);
          If (Digits[2]>'9') Then
            Begin
            Digits[2] := '1';
            Inc(Exp);
            End;
          End;
        Delete(Digits, 3, 2);
        DecimalPoint := Length(Digits) + 1;
        End
      Else
        Begin
        { Move decimal point at the desired position }
        Delete(Digits, 3, 1);
        DecimalPoint:=2+Placehold[1]+Placehold[2];
        If (Decimals<>0) Then
          Insert('.',Digits,DecimalPoint);
        End;

      { Convert optional zeroes to spaces. }
      I := Length(Digits);
      J := DecimalPoint + Placehold[3];
      While (I > J) And (Digits[I] = '0') Do
        Begin
        Digits[I] := ' ';
        Dec(I);
        End;

      { If integer number and no obligatory decimal paces, remove decimal point }

      If (DecimalPoint<Length(Digits)) And
         (Digits[DecimalPoint+1]=' ') Then
          Digits[DecimalPoint]:=' ';
      If (Digits[1]=' ') Then
        Begin
        Delete(Digits, 1, 1);
        Dec(DecimalPoint);
        End;
      { Calculate exponent string }
      Str(Abs(Exp), Exponent);
      While Length(Exponent)<ExpSize Do
        Insert('0',Exponent,1);
      If Exp >= 0 Then
        Begin
        If (ExpFmt In [1,3]) Then
          Insert('+', Exponent, 1);
        End
      Else
        Insert('-',Exponent,1);
      If (ExpFmt<3) Then
        Insert('E',Exponent,1)
      Else
        Insert('e',Exponent,1);
      End;
    DigitExponent:=DecimalPoint-2;
    If (Digits[1]='-') Then
      Dec(DigitExponent);
    UnexpectedDigits:=DecimalPoint-1-(Placehold[1]+Placehold[2]);
  End;

  Function PutResult: LongInt;

  Var
    SQ, DQ: Boolean;
    Fmt, Buf: PChar;
    Dig, N: Integer;

  Begin
    SQ := False;
    DQ := False;
    Fmt := FmtStart;
    Buf := Buffer;
    Dig := 1;
    While (Fmt<FmtStop) Do
      Begin
      //Write(Fmt[0]);
      Case Fmt[0] Of
        #34:
          Begin
          If Not SQ Then
            DQ := Not DQ;
          Inc(Fmt);
          End;
        #39:
          Begin
          If Not DQ Then
            SQ := Not SQ;
          Inc(Fmt);
          End;
      Else
        If Not (SQ Or DQ) Then
          Begin
          Case Fmt[0] Of
            '0', '#', '.':
              Begin
              If (Dig=1) And (UnexpectedDigits>0) Then
                Begin
                { Everything unexpected is written before the first digit }
                For N := 1 To UnexpectedDigits Do
                  Begin
                  Buf[0] := Digits[N];
                  Inc(Buf);
                  If thousand And (Digits[N]<>'-') Then
                    Begin
                    If (DigitExponent Mod 3 = 0) And (DigitExponent>0) Then
                      Begin
                      Buf[0] := ThousandSeparator;
                      Inc(Buf);
                      End;
                    Dec(DigitExponent);
                    End;
                  End;
                Inc(Dig, UnexpectedDigits);
                End;
              If (Digits[Dig]<>' ') Then
                Begin
                If (Digits[Dig]='.') Then
                  Buf[0] := DecimalSeparator
                Else
                  Buf[0] := Digits[Dig];
                Inc(Buf);
                If thousand And (DigitExponent Mod 3 = 0) And (DigitExponent > 0) Then
                  Begin
                  Buf[0] := ThousandSeparator;
                  Inc(Buf);
                  End;
                End;
              Inc(Dig);
              Dec(DigitExponent);
              Inc(Fmt);
              End;
            'e', 'E':
              Begin
              If ExpFmt <> 0 Then
                Begin
                Inc(Fmt);
                If Fmt < FmtStop Then
                  Begin
                  If Fmt[0] In ['+', '-'] Then
                    Begin
                    Inc(Fmt, ExpSize);
                    For N:=1 To Length(Exponent) Do
                      Buf[N-1] := Exponent[N];
                    Inc(Buf,Length(Exponent));
                    ExpFmt:=0;
                    End;
                  Inc(Fmt);
                  End;
                End
              Else
                Begin
                { No legal exponential format.
                  Simply write the 'E' to the result. }
                Buf[0] := Fmt[0];
                Inc(Buf);
                Inc(Fmt);
                End;
              End;
          Else { Case }
            { Usual character }
            If (Fmt[0]<>',') Then
              Begin
              Buf[0] := Fmt[0];
              Inc(Buf);
              End;
            Inc(Fmt);
          End; { Case }
          End
        Else { IF }
          Begin
          { Character inside single or double quotes }
          Buf[0] := Fmt[0];
          Inc(Buf);
          Inc(Fmt);
          End;
      End; { Case }
    End; { While .. Begin }
    Result:=PtrInt(Buf)-PtrInt(Buffer);
  End;

Begin
  If (Value>0) Then
    GetSectionRange(1)
  Else If (Value<0) Then
    GetSectionRange(2)
  Else
    GetSectionRange(3);
  If FmtStart = Nil Then
    Begin
    Result := FloatToText(Buffer, Value, ffGeneral, 15, 4);
    End
  Else
    Begin
    GetFormatOptions;
    If (ExpFmt = 0) And (Abs(Value) >= 1E18) Then
      Result := FloatToText(Buffer, Value, ffGeneral, 15, 4)
    Else
      Begin
      FloatToStr;
      Result := PutResult;
      End;
    End;
End;



Procedure FloatToDecimal(Var Result: TFloatRec; Value: Extended; Precision, Decimals : integer);

Var
  Buffer: String[24];
  Error, N: Integer;

Begin
  Str(Value:23, Buffer);
  Result.Negative := (Buffer[1] = '-');
  Val(Copy(Buffer, 19, 5), Result.Exponent, Error);
  Inc(Result. Exponent);
  Result.Digits[0] := Buffer[2];
  Move(Buffer[4], Result.Digits[1], 14);
  If Decimals + Result.Exponent < Precision Then
    N := Decimals + Result.Exponent
  Else
    N := Precision;
  If N > maxdigits Then
    N := maxdigits;
  If N = 0 Then
    Begin
    If Result.Digits[0] >= '5' Then
      Begin
      Result.Digits[0] := '1';
      Result.Digits[1] := #0;
      Inc(Result.Exponent);
      End
    Else
      Result.Digits[0] := #0;
    End
  Else If N > 0 Then
    Begin
    If Result.Digits[N] >= '5' Then
      Begin
      Repeat
        Result.Digits[N] := #0;
        Dec(N);
        Inc(Result.Digits[N]);
      Until (N = 0) Or (Result.Digits[N] < ':');
      If Result.Digits[0] = ':' Then
        Begin
        Result.Digits[0] := '1';
        Inc(Result.Exponent);
        End;
      End
    Else
      Begin
      Result.Digits[N] := '0';
      While (Result.Digits[N] = '0') And (N > -1) Do
        Begin
        Result.Digits[N] := #0;
        Dec(N);
        End;
      End;
    End
  Else
    Result.Digits[0] := #0;
  If Result.Digits[0] = #0 Then
    Begin
    Result.Exponent := 0;
    Result.Negative := False;
    End;
End;

Function FormatFloat(Const format: String; Value: Extended): String;

Var
  buf : Array[0..1024] of char;

Begin
  Buf[FloatToTextFmt(@Buf[0],Value,Pchar(Format))]:=#0;
  Result:=StrPas(@Buf);
End;

function FormatCurr(const Format: string; Value: Currency): string;
begin
  Result := FormatFloat(Format, Value);
end;


{==============================================================================}
{   extra functions                                                            }
{==============================================================================}

{   LeftStr returns Count left-most characters from S }

function LeftStr(const S: string; Count: integer): string;
begin
  result := Copy(S, 1, Count);
end ;

{ RightStr returns Count right-most characters from S }

function RightStr(const S: string; Count: integer): string;
begin
   If Count>Length(S) then
     Count:=Length(S);
   result := Copy(S, 1 + Length(S) - Count, Count);
end;

{    BCDToInt converts the BCD value Value to an integer   }

function BCDToInt(Value: integer): integer;
var i, j: integer;
begin
result := 0;
j := 1;
for i := 0 to SizeOf(Value) shr 1 - 1 do begin
   result := result + j * (Value and 15);
   j := j * 10;
   Value := Value shr 4;
   end ;
end ;

Function LastDelimiter(const Delimiters, S: string): Integer;

begin
  Result:=Length(S);
  While (Result>0) and (Pos(S[Result],Delimiters)=0) do
    Dec(Result);
end;


Function StringReplace(const S, OldPattern, NewPattern: string;  Flags: TReplaceFlags): string;
var
  Srch,OldP,RemS: string; // Srch and Oldp can contain uppercase versions of S,OldPattern
  P : Integer;
begin
  Srch:=S;
  OldP:=OldPattern;
  if rfIgnoreCase in Flags then
    begin
    Srch:=AnsiUpperCase(Srch);
    OldP:=AnsiUpperCase(OldP);
    end;
  RemS:=S;
  Result:='';
  while (Length(Srch)<>0) do
    begin
    P:=AnsiPos(OldP, Srch);
    if P=0 then
      begin
      Result:=Result+RemS;
      Srch:='';
      end
    else
      begin
      Result:=Result+Copy(RemS,1,P-1)+NewPattern;
      P:=P+Length(OldP);
      RemS:=Copy(RemS,P,Length(RemS)-P+1);
      if not (rfReplaceAll in Flags) then
        begin
        Result:=Result+RemS;
        Srch:='';
        end
      else
         Srch:=Copy(Srch,P,Length(Srch)-P+1);
      end;
    end;
end;


Function IsDelimiter(const Delimiters, S: string; Index: Integer): Boolean;

begin
  Result:=False;
  If (Index>0) and (Index<=Length(S)) then
    Result:=Pos(S[Index],Delimiters)<>0; // Note we don't do MBCS yet
end;

Function ByteToCharLen(const S: string; MaxLen: Integer): Integer;

begin
  Result:=Length(S);
  If Result>MaxLen then
    Result:=MaxLen;
end;

Function ByteToCharIndex(const S: string; Index: Integer): Integer;

begin
  Result:=Index;
end;


Function CharToByteLen(const S: string; MaxLen: Integer): Integer;

begin
  Result:=Length(S);
  If Result>MaxLen then
    Result:=MaxLen;
end;

Function CharToByteIndex(const S: string; Index: Integer): Integer;

begin
  Result:=Index;
end;

Function ByteType(const S: string; Index: Integer): TMbcsByteType;

begin
  Result:=mbSingleByte;
end;

Function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType;

begin
  Result:=mbSingleByte;
end;


Function StrCharLength(const Str: PChar): Integer;
begin
  result:=widestringmanager.CharLengthPCharProc(Str);
end;


Function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet;IgnoreCase: Boolean): Boolean;

Var
  I,L : Integer;
  S,T : String;

begin
  Result:=False;
  S:=Switch;
  If IgnoreCase then
    S:=UpperCase(S);
  I:=ParamCount;
  While (Not Result) and (I>0) do
    begin
    L:=Length(Paramstr(I));
    If (L>0) and (ParamStr(I)[1] in Chars) then
      begin
      T:=Copy(ParamStr(I),2,L-1);
      If IgnoreCase then
        T:=UpperCase(T);
      Result:=S=T;
      end;
    Dec(i);
    end;
end;

Function FindCmdLineSwitch(const Switch: string; IgnoreCase: Boolean): Boolean;

begin
  Result:=FindCmdLineSwitch(Switch,SwitchChars,IgnoreCase);
end;

Function FindCmdLineSwitch(const Switch: string): Boolean;

begin
  Result:=FindCmdLineSwitch(Switch,SwitchChars,False);
end;

function WrapText(const Line, BreakStr: string; const BreakChars: TSysCharSet;  MaxCol: Integer): string;

const
  Quotes = ['''', '"'];

Var
  L : String;
  C,LQ,BC : Char;
  P,BLen,Len : Integer;
  HB,IBC : Boolean;

begin
  Result:='';
  L:=Line;
  Blen:=Length(BreakStr);
  If (BLen>0) then
    BC:=BreakStr[1]
  else
    BC:=#0;
  Len:=Length(L);
  While (Len>0) do
    begin
    P:=1;
    LQ:=#0;
    HB:=False;
    IBC:=False;
    While ((P<=Len) and ((P<=MaxCol) or not IBC)) and ((LQ<>#0) or Not HB) do
      begin
      C:=L[P];
      If (C=LQ) then
        LQ:=#0
      else If (C in Quotes) then
        LQ:=C;
      If (LQ<>#0) then
        Inc(P)
      else
        begin
        HB:=((C=BC) and (BreakStr=Copy(L,P,BLen)));
        If HB then
          Inc(P,Blen)
        else
          begin
          If (P>MaxCol) then
            IBC:=C in BreakChars;
          Inc(P);
          end;
        end;
//      Writeln('"',C,'" : IBC : ',IBC,' HB  : ',HB,' LQ  : ',LQ,' P>MaxCol : ',P>MaxCol);
      end;
    Result:=Result+Copy(L,1,P-1);
    If Not HB then
      Result:=Result+BreakStr;
    Delete(L,1,P-1);
    Len:=Length(L);
    end;
end;

function WrapText(const Line: string; MaxCol: Integer): string;
begin
  Result:=WrapText(Line,sLineBreak, [' ', '-', #9], MaxCol);
end;


{
   Case Translation Tables
   Can be used in internationalization support.

   Although these tables can be obtained through system calls
   it is better to not use those, since most implementation are not 100%
   WARNING:
   before modifying a translation table make sure that the current codepage
   of the OS corresponds to the one you make changes to
}



const
   { upper case translation table for character set 850 }
   CP850UCT: array[128..255] of char =
   ('€', 'š', '', '¶', 'Ž', '¶', '', '€', 'Ò', 'Ó', 'Ô', 'Ø', '×', 'Þ', 'Ž', '',
    '', '’', '’', 'â', '™', 'ã', 'ê', 'ë', 'Y', '™', 'š', '', 'œ', '', 'ž', 'Ÿ',
    'µ', 'Ö', 'à', 'é', '¥', '¥', '¦', '§', '¨', '©', 'ª', '«', '¬', '­', '®', '¯',
    '°', '±', '²', '³', '´', 'µ', '¶', '·', '¸', '¹', 'º', '»', '¼', '½', '¾', '¿',
    'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Ç', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï',
    'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', '×', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß',
    'à', 'á', 'â', 'ã', 'å', 'å', 'æ', 'í', 'è', 'é', 'ê', 'ë', 'í', 'í', 'î', 'ï',
    'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'þ', 'ÿ');

   { lower case translation table for character set 850 }
   CP850LCT: array[128..255] of char =
   ('‡', '', '‚', 'ƒ', '„', '…', '†', '‡', 'ˆ', '‰', 'Š', '‹', 'Œ', '', '„', '†',
    '‚', '‘', '‘', '“', '”', '•', '–', '—', '˜', '”', '', '›', 'œ', '›', 'ž', 'Ÿ',
    ' ', '¡', '¢', '£', '¤', '¤', '¦', '§', '¨', '©', 'ª', '«', '¬', '­', '®', '¯',
    '°', '±', '²', '³', '´', ' ', 'ƒ', '…', '¸', '¹', 'º', '»', '¼', '½', '¾', '¿',
    'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Æ', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï',
    'Ð', 'Ñ', 'ˆ', '‰', 'Š', 'Õ', '¡', 'Œ', '‹', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', '', 'ß',
    '¢', 'á', '“', '•', 'ä', 'ä', 'æ', 'í', 'è', '£', '–', '—', 'ì', 'ì', 'î', 'ï',
    'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'þ', 'ÿ');

   { upper case translation table for character set ISO 8859/1  Latin 1  }
   CPISO88591UCT: array[192..255] of char =
   ( #192, #193, #194, #195, #196, #197, #198, #199,
     #200, #201, #202, #203, #204, #205, #206, #207,
     #208, #209, #210, #211, #212, #213, #214, #215,
     #216, #217, #218, #219, #220, #221, #222, #223,
     #192, #193, #194, #195, #196, #197, #198, #199,
     #200, #201, #202, #203, #204, #205, #206, #207,
     #208, #209, #210, #211, #212, #213, #214, #247,
     #216, #217, #218, #219, #220, #221, #222, #89 );

   { lower case translation table for character set ISO 8859/1  Latin 1  }
   CPISO88591LCT: array[192..255] of char =
   ( #224, #225, #226, #227, #228, #229, #230, #231,
     #232, #233, #234, #235, #236, #237, #238, #239,
     #240, #241, #242, #243, #244, #245, #246, #215,
     #248, #249, #250, #251, #252, #253, #254, #223,
     #224, #225, #226, #227, #228, #229, #230, #231,
     #232, #233, #234, #235, #236, #237, #238, #239,
     #240, #241, #242, #243, #244, #245, #246, #247,
     #248, #249, #250, #251, #252, #253, #254, #255 );


function sscanf(const s: string; const fmt : string;const Pointers : array of Pointer) : Integer;
  var
    i,j,n,m : SizeInt;
    s1      : string;

  function GetInt(unsigned : boolean=false) : Integer;
    begin
      s1 := '';
      while (s[n] = ' ')  and (Length(s) > n) do
        inc(n);
      { read sign }
      if (Length(s)>= n) and (s[n] in ['+', '-']) then
        begin
          { don't accept - when reading unsigned }
          if unsigned and (s[n]='-') then
            begin
              result:=length(s1);
              exit;
            end
          else
            begin
              s1:=s1+s[n];
              inc(n);
            end;
        end;
      { read numbers }
      while (s[n] in ['0'..'9'])
        and (Length(s) >= n) do
        begin
          s1 := s1+s[n];
          inc(n);
        end;
      Result := Length(s1);
    end;


  function GetFloat : Integer;
    begin
      s1 := '';
      while (s[n] = ' ')  and (Length(s) > n) do
        inc(n);
      while (s[n] in ['0'..'9', '+', '-', '.', 'e', 'E'])
        and (Length(s) >= n) do
        begin
          s1 := s1+s[n];
          inc(n);
        end;
      Result := Length(s1);
    end;


  function GetString : Integer;
    begin
      s1 := '';
      while (s[n] = ' ')  and (Length(s) > n) do
        inc(n);
      while (s[n] <> ' ') and (Length(s) >= n) do
        begin
          s1 := s1+s[n];
          inc(n);
        end;
      Result := Length(s1);
    end;


  function ScanStr(c : Char) : Boolean;
    begin
      while (s[n] <> c) and (Length(s) > n) do
        inc(n);
      inc(n);
      If (n <= Length(s)) then
        Result := True
      else
        Result := False;
    end;


  function GetFmt : Integer;
    begin
      Result := -1;
      while true do
        begin

          while (fmt[m] = ' ') and (Length(fmt) > m) do
            inc(m);

          if (m >= Length(fmt)) then
            break;

          if (fmt[m] = '%') then
            begin
              inc(m);
              case fmt[m] of
                'd':
                  Result:=vtInteger;
                'f':
                  Result:=vtExtended;
                's':
                  Result:=vtString;
                'c':
                  Result:=vtChar;
                else
                  raise EFormatError.CreateFmt(SInvalidFormat,[fmt]);
              end;
              inc(m);
              break;
            end;

          if not(ScanStr(fmt[m])) then
            break;
          inc(m);
        end;
    end;


  begin
    n := 1;
    m := 1;
    Result := 0;

    for i:=0 to High(Pointers) do
      begin
        j := GetFmt;
        case j of
          vtInteger :
            begin
              if GetInt>0 then
                begin
                  pLongint(Pointers[i])^:=StrToInt(s1);
                  inc(Result);
                end
              else
                break;

            end;

          vtchar :
            begin
              if Length(s)>n then
                begin
                  pchar(Pointers[i])^:=s[n];
                  inc(n);
                  inc(Result);
                end
              else
                break;

            end;

          vtExtended :
            begin
              if GetFloat>0 then
                begin
                  pextended(Pointers[i])^:=StrToFloat(s1);
                  inc(Result);
                end
              else
                break;
            end;

          vtString :
            begin
              if GetString > 0 then
                begin
                  pansistring(Pointers[i])^:=s1;
                  inc(Result);
                end
              else
                break;
            end;
          else
            break;
        end;
      end;
   end;
