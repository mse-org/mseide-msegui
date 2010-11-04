{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2000 by Michael Van Canneyt and Florian Klaempfl

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    
    Modified 2010 by Martin Schreiber
}
unit mseobjecttext;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes;
 
procedure objectbinarytotextmse(input, output: tstream);
procedure objecttexttobinarymse(input, output: tstream);

implementation
uses
 sysutils,rtlconsts;
{$ifdef FPC} {$define CLASSESINLINE} {$endif}

{ Object conversion routines }

type
  TObjectTextEncoding = (
    oteDFM,
    oteLFM
    );
  CharToOrdFuncty = Function(var charpo: Pointer): Cardinal;

function CharToOrd(var P: Pointer): Cardinal;
begin
  result:= ord(pchar(P)^);
  inc(pchar(P));
end;

function WideCharToOrd(var P: Pointer): Cardinal;
begin
  result:= ord(pwidechar(P)^);
  inc(pwidechar(P));
end;

function Utf8ToOrd(var P:Pointer): Cardinal;
begin
  // Should also check for illegal utf8 combinations
  Result := Ord(PChar(P)^);
  Inc(P);
  if (Result and $80) <> 0 then
    if (Ord(Result) and %11100000) = %11000000 then begin
      Result := ((Result and %00011111) shl 6)
                or (ord(PChar(P)^) and %00111111);
      Inc(P);
    end else if (Ord(Result) and %11110000) = %11100000 then begin
      Result := ((Result and %00011111) shl 12)
                or ((ord(PChar(P)^) and %00111111) shl 6)
                or (ord((PChar(P)+1)^) and %00111111);
      Inc(P,2);
    end else begin
      Result := ((ord(Result) and %00011111) shl 18)
                or ((ord(PChar(P)^) and %00111111) shl 12)
                or ((ord((PChar(P)+1)^) and %00111111) shl 6)
                or (ord((PChar(P)+2)^) and %00111111);
      Inc(P,3);
    end;
end;

procedure ObjectBinaryToText(Input, Output: TStream; Encoding: TObjectTextEncoding);

  procedure OutStr(s: String);
  begin
    if Length(s) > 0 then
      Output.Write(s[1], Length(s));
  end;

  procedure OutLn(s: String);
  begin
    OutStr(s + LineEnding);
  end;

  procedure Outchars(P, LastP : Pointer; CharToOrdFunc: CharToOrdFuncty;
    UseBytes: boolean = false);

  var
    res, NewStr: String;
    w: Cardinal;
    InString, NewInString: Boolean;
  begin
   if p = nil then begin
    res:= '''''';
   end
   else 
    begin
    res := '';
    InString := False;
    while P < LastP do 
      begin
      NewInString := InString;
      w := CharToOrdfunc(P);
      if w = ord('''') then 
        begin //quote char
        if not InString then
          NewInString := True;
        NewStr := '''''';
        end 
      else if (Ord(w) >= 32) and ((Ord(w) < 127) or (UseBytes and (Ord(w)<256))) then
        begin //printable ascii or bytes
        if not InString then
          NewInString := True;
        NewStr := char(w);
        end 
      else 
        begin //ascii control chars, non ascii
        if InString then
          NewInString := False;
        NewStr := '#' + IntToStr(w);
        end;
      if NewInString <> InString then 
        begin
        NewStr := '''' + NewStr;
        InString := NewInString;
        end;
      res := res + NewStr;
      end;
    if InString then 
      res := res + '''';
    end;
   OutStr(res);
  end;

  procedure OutString(s: String);
  begin
    OutChars(Pointer(S),PChar(S)+Length(S),@CharToOrd,Encoding=oteLFM);
  end;

  procedure OutWString(W: WideString);
  begin
    OutChars(Pointer(W),pwidechar(W)+Length(W),@WideCharToOrd);
  end;

  procedure OutUString(W: UnicodeString);
  begin
    OutChars(Pointer(W),pwidechar(W)+Length(W),@WideCharToOrd);
  end;

  procedure OutUtf8Str(s: String);
  begin
    if Encoding=oteLFM then
      OutChars(Pointer(S),PChar(S)+Length(S),@CharToOrd)
    else
      OutChars(Pointer(S),PChar(S)+Length(S),@Utf8ToOrd);
  end;

  function ReadWord : word; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    Result:=Input.ReadWord;
    Result:=LEtoN(Result);
  end;

  function ReadDWord : longword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    Result:=Input.ReadDWord;
    Result:=LEtoN(Result);
  end;

  function ReadQWord : qword; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    Input.ReadBuffer(Result,sizeof(Result));
    Result:=LEtoN(Result);
  end;

{$ifndef FPUNONE}
  {$IFNDEF FPC_HAS_TYPE_EXTENDED}
  function ExtendedToDouble(e : pointer) : double;
  var mant : qword;
      exp : smallint;
      sign : boolean;
      d : qword;
  begin
    move(pbyte(e)[0],mant,8); //mantissa         : bytes 0..7
    move(pbyte(e)[8],exp,2);  //exponent and sign: bytes 8..9
    mant:=LEtoN(mant);
    exp:=LetoN(word(exp));
    sign:=(exp and $8000)<>0;
    if sign then exp:=exp and $7FFF;
    case exp of
          0 : mant:=0;  //if denormalized, value is too small for double,
                        //so it's always zero
      $7FFF : exp:=2047 //either infinity or NaN
      else
      begin
        dec(exp,16383-1023);
        if (exp>=-51) and (exp<=0) then //can be denormalized
        begin
          mant:=mant shr (-exp);
          exp:=0;
        end
        else
        if (exp<-51) or (exp>2046) then //exponent too large.
        begin
          Result:=0;
          exit;
        end
        else //normalized value
          mant:=mant shl 1; //hide most significant bit
      end;
    end;
    d:=word(exp);
    d:=d shl 52;

    mant:=mant shr 12;
    d:=d or mant;
    if sign then d:=d or $8000000000000000;
    Result:=pdouble(@d)^;
  end;
  {$ENDIF}
{$endif}

  function ReadInt(ValueType: TValueType): Int64;
  begin
    case ValueType of
      vaInt8: Result := ShortInt(Input.ReadByte);
      vaInt16: Result := SmallInt(ReadWord);
      vaInt32: Result := LongInt(ReadDWord);
      vaInt64: Result := Int64(ReadQWord);
    end;
  end;

  function ReadInt: Int64;
  begin
    Result := ReadInt(TValueType(Input.ReadByte));
  end;

{$ifndef FPUNONE}
  function ReadExtended : extended;
  {$IFNDEF FPC_HAS_TYPE_EXTENDED}
  var ext : array[0..9] of byte;
  {$ENDIF}
  begin
    {$IFNDEF FPC_HAS_TYPE_EXTENDED}
    Input.ReadBuffer(ext[0],10);
    Result:=ExtendedToDouble(@(ext[0]));
    {$ELSE}
    Input.ReadBuffer(Result,sizeof(Result));
    {$ENDIF}
  end;
{$endif}

  function ReadSStr: String;
  var
    len: Byte;
  begin
    len := Input.ReadByte;
    SetLength(Result, len);
    if (len > 0) then
      Input.ReadBuffer(Result[1], len);
  end;

  function ReadLStr: String;
  var
    len: DWord;
  begin
    len := ReadDWord;
    SetLength(Result, len);
    if (len > 0) then
      Input.ReadBuffer(Result[1], len);
  end;

  function ReadWStr: WideString;
  var
    len: DWord;
  {$IFDEF ENDIAN_BIG}
    i : integer;
  {$ENDIF}
  begin
    len := ReadDWord;
    SetLength(Result, len);
    if (len > 0) then
    begin
      Input.ReadBuffer(Pointer(@Result[1])^, len*2);
      {$IFDEF ENDIAN_BIG}
      for i:=1 to len do
        Result[i]:=widechar(SwapEndian(word(Result[i])));
      {$ENDIF}
    end;
  end;

  function ReadUStr: UnicodeString;
  var
    len: DWord;
  {$IFDEF ENDIAN_BIG}
    i : integer;
  {$ENDIF}
  begin
    len := ReadDWord;
    SetLength(Result, len);
    if (len > 0) then
    begin
      Input.ReadBuffer(Pointer(@Result[1])^, len*2);
      {$IFDEF ENDIAN_BIG}
      for i:=1 to len do
        Result[i]:=widechar(SwapEndian(word(Result[i])));
      {$ENDIF}
    end;
  end;

  procedure ReadPropList(indent: String);

    procedure ProcessValue(ValueType: TValueType; Indent: String);

      procedure ProcessBinary;
      var
        ToDo, DoNow, i: LongInt;
        lbuf: array[0..31] of Byte;
        s: String;
      begin
        ToDo := ReadDWord;
        OutLn('{');
        while ToDo > 0 do begin
          DoNow := ToDo;
          if DoNow > 32 then DoNow := 32;
          Dec(ToDo, DoNow);
          s := Indent + '  ';
          Input.ReadBuffer(lbuf, DoNow);
          for i := 0 to DoNow - 1 do
            s := s + IntToHex(lbuf[i], 2);
          OutLn(s);
        end;
        OutLn(indent + '}');
      end;

    var
      s: String;
{      len: LongInt; }
      IsFirst: Boolean;
{$ifndef FPUNONE}
      ext: Extended;
{$endif}

    begin
      case ValueType of
        vaList: begin
            OutStr('(');
            IsFirst := True;
            while True do begin
              ValueType := TValueType(Input.ReadByte);
              if ValueType = vaNull then break;
              if IsFirst then begin
                OutLn('');
                IsFirst := False;
              end;
              OutStr(Indent + '  ');
              ProcessValue(ValueType, Indent + '  ');
            end;
            OutLn(Indent + ')');
          end;
        vaInt8: OutLn(IntToStr(ShortInt(Input.ReadByte)));
        vaInt16: OutLn( IntToStr(SmallInt(ReadWord)));
        vaInt32: OutLn(IntToStr(LongInt(ReadDWord)));
        vaInt64: OutLn(IntToStr(Int64(ReadQWord)));
{$ifndef FPUNONE}
        vaExtended: begin
            ext:=ReadExtended;
            Str(ext,S);// Do not use localized strings.
            OutLn(S);
          end;
{$endif}
        vaString: begin
            OutString(ReadSStr);
            OutLn('');
          end;
        vaIdent: OutLn(ReadSStr);
        vaFalse: OutLn('False');
        vaTrue: OutLn('True');
        vaBinary: ProcessBinary;
        vaSet: begin
            OutStr('[');
            IsFirst := True;
            while True do begin
              s := ReadSStr;
              if Length(s) = 0 then break;
              if not IsFirst then OutStr(', ');
              IsFirst := False;
              OutStr(s);
            end;
            OutLn(']');
          end;
        vaLString:
          begin
          OutString(ReadLStr);
          OutLn('');
          end;
        vaWString:
          begin
          OutWString(ReadWStr);
          OutLn('');
          end;
        vaUString:
          begin
          OutWString(ReadWStr);
          OutLn('');
          end;
        vaNil:
          OutLn('nil');
        vaNull:
          OutLn('null');
        vaCollection: begin
            OutStr('<');
            while Input.ReadByte <> 0 do begin
              OutLn(Indent);
              Input.Seek(-1, soFromCurrent);
              OutStr(indent + '  item');
              ValueType := TValueType(Input.ReadByte);
              if ValueType <> vaList then
                OutStr('[' + IntToStr(ReadInt(ValueType)) + ']');
              OutLn('');
              ReadPropList(indent + '    ');
              OutStr(indent + '  end');
            end;
            OutLn('>');
          end;
        {vaSingle: begin OutLn('!!Single!!'); exit end;
        vaCurrency: begin OutLn('!!Currency!!'); exit end;
        vaDate: begin OutLn('!!Date!!'); exit end;}
        vaUTF8String: begin
            OutUtf8Str(ReadLStr);
            OutLn('');
          end;
        else
          Raise EReadError.CreateFmt(SErrInvalidPropertyType,[Ord(ValueType)]);
      end;
    end;

  begin
    while Input.ReadByte <> 0 do begin
      Input.Seek(-1, soFromCurrent);
      OutStr(indent + ReadSStr + ' = ');
      ProcessValue(TValueType(Input.ReadByte), Indent);
    end;
  end;

  procedure ReadObject(indent: String);
  var
    b: Byte;
    ObjClassName, ObjName: String;
    ChildPos: LongInt;
  begin
    // Check for FilerFlags
    b := Input.ReadByte;
    if (b and $f0) = $f0 then begin
      if (b and 2) <> 0 then ChildPos := ReadInt;
    end else begin
      b := 0;
      Input.Seek(-1, soFromCurrent);
    end;

    ObjClassName := ReadSStr;
    ObjName := ReadSStr;

    OutStr(Indent);
    if (b and 1) <> 0 then OutStr('inherited')
    else
     if (b and 4) <> 0 then OutStr('inline')
     else OutStr('object');
    OutStr(' ');
    if ObjName <> '' then
      OutStr(ObjName + ': ');
    OutStr(ObjClassName);
    if (b and 2) <> 0 then OutStr('[' + IntToStr(ChildPos) + ']');
    OutLn('');

    ReadPropList(indent + '  ');

    while Input.ReadByte <> 0 do begin
      Input.Seek(-1, soFromCurrent);
      ReadObject(indent + '  ');
    end;
    OutLn(indent + 'end');
  end;

type
  PLongWord = ^LongWord;
const
  signature: PChar = 'TPF0';
  
begin
  if Input.ReadDWord <> PLongWord(Pointer(signature))^ then
    raise EReadError.Create('Illegal stream image' {###SInvalidImage});
  ReadObject('');
end;

procedure ObjectBinaryToText(Input, Output: TStream);
begin
  ObjectBinaryToText(Input,Output,oteDFM);
end;

procedure ObjectTextToBinary(Input, Output: TStream);
var
  parser: TParser;

  procedure WriteWord(w : word); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    w:=NtoLE(w);
    Output.WriteWord(w);
  end;

  procedure WriteDWord(lw : longword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    lw:=NtoLE(lw);
    Output.WriteDWord(lw);
  end;

  procedure WriteQWord(qw : qword); {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    qw:=NtoLE(qw);
    Output.WriteBuffer(qw,sizeof(qword));
  end;

{$ifndef FPUNONE}
  {$IFNDEF FPC_HAS_TYPE_EXTENDED}
  procedure DoubleToExtended(d : double; e : pointer);
  var mant : qword;
      exp : smallint;
      sign : boolean;
  begin
    mant:=(qword(d) and $000FFFFFFFFFFFFF) shl 12;
    exp :=(qword(d) shr 52) and $7FF;
    sign:=(qword(d) and $8000000000000000)<>0;
    case exp of
         0 : begin
               if mant<>0 then  //denormalized value: hidden bit is 0. normalize it
               begin
                 exp:=16383-1022;
                 while (mant and $8000000000000000)=0 do
                 begin
                   dec(exp);
                   mant:=mant shl 1;
                 end;
                 dec(exp); //don't shift, most significant bit is not hidden in extended
               end;
             end;
      2047 : exp:=$7FFF //either infinity or NaN
      else
      begin
        inc(exp,16383-1023);
        mant:=(mant shr 1) or $8000000000000000; //unhide hidden bit
      end;
    end;
    if sign then exp:=exp or $8000;
    mant:=NtoLE(mant);
    exp:=NtoLE(word(exp));
    move(mant,pbyte(e)[0],8); //mantissa         : bytes 0..7
    move(exp,pbyte(e)[8],2);  //exponent and sign: bytes 8..9
  end;
  {$ENDIF}

  procedure WriteExtended(e : extended);
  {$IFNDEF FPC_HAS_TYPE_EXTENDED}
  var ext : array[0..9] of byte;
  {$ENDIF}
  begin
    {$IFNDEF FPC_HAS_TYPE_EXTENDED}
    DoubleToExtended(e,@(ext[0]));
    Output.WriteBuffer(ext[0],10);
    {$ELSE}
    Output.WriteBuffer(e,sizeof(e));
    {$ENDIF}
  end;
{$endif}

  procedure WriteString(s: String);
  var size : byte;
  begin
    if length(s)>255 then size:=255
    else size:=length(s);
    Output.WriteByte(size);
    if Length(s) > 0 then
      Output.WriteBuffer(s[1], size);
  end;

  procedure WriteLString(Const s: String);
  begin
    WriteDWord(Length(s));
    if Length(s) > 0 then
      Output.WriteBuffer(s[1], Length(s));
  end;

  procedure WriteWString(Const s: WideString);
  var len : longword;
  {$IFDEF ENDIAN_BIG}
      i : integer;
      ws : widestring;
  {$ENDIF}
  begin
    len:=Length(s);
    WriteDWord(len);
    if len > 0 then
    begin
      {$IFDEF ENDIAN_BIG}
      setlength(ws,len);
      for i:=1 to len do
        ws[i]:=widechar(SwapEndian(word(s[i])));
      Output.WriteBuffer(ws[1], len*sizeof(widechar));
      {$ELSE}
      Output.WriteBuffer(s[1], len*sizeof(widechar));
      {$ENDIF}
    end;
  end;

  procedure WriteInteger(value: Int64);
  begin
    if (value >= -128) and (value <= 127) then begin
      Output.WriteByte(Ord(vaInt8));
      Output.WriteByte(byte(value));
    end else if (value >= -32768) and (value <= 32767) then begin
      Output.WriteByte(Ord(vaInt16));
      WriteWord(word(value));
    end else if (value >= -2147483648) and (value <= 2147483647) then begin
      Output.WriteByte(Ord(vaInt32));
      WriteDWord(longword(value));
    end else begin
      Output.WriteByte(ord(vaInt64));
      WriteQWord(qword(value));
    end;
  end;

  procedure ProcessWideString(const left : widestring);
  var ws : widestring;
  begin
    ws:=left+parser.TokenWideString;
    while parser.NextToken = '+' do
    begin
      parser.NextToken;   // Get next string fragment
      if not (parser.Token in [toString,toWString]) then
        parser.CheckToken(toWString);
      ws:=ws+parser.TokenWideString;
    end;
    Output.WriteByte(Ord(vaWstring));
    WriteWString(ws);
  end;
  
  procedure ProcessProperty; forward;

  procedure ProcessValue;
  var
{$ifndef FPUNONE}
    flt: Extended;
{$endif}
    s: String;
    stream: TMemoryStream;
  begin
    case parser.Token of
      toInteger:
        begin
          WriteInteger(parser.TokenInt);
          parser.NextToken;
        end;
{$ifndef FPUNONE}
      toFloat:
        begin
          Output.WriteByte(Ord(vaExtended));
          flt := Parser.TokenFloat;
          WriteExtended(flt);
          parser.NextToken;
        end;
{$endif}
      toString:
        begin
          s := parser.TokenString;
          while parser.NextToken = '+' do
          begin
            parser.NextToken;   // Get next string fragment
            case parser.Token of
              toString  : s:=s+parser.TokenString;
              toWString : begin
                            ProcessWideString(s);
                            exit;
                          end
              else parser.CheckToken(toString);
            end;
          end;
          if (length(S)>255) then
          begin
            Output.WriteByte(Ord(vaLString));
            WriteLString(S);
          end
          else
          begin
            Output.WriteByte(Ord(vaString));
            WriteString(s);
          end;
        end;
      toWString:
        ProcessWideString('');
      toSymbol: begin
       if CompareText(parser.TokenString, 'True') = 0 then begin
         Output.WriteByte(Ord(vaTrue));
       end
       else begin
        if CompareText(parser.TokenString, 'False') = 0 then begin
         Output.WriteByte(Ord(vaFalse));
        end
        else begin
         if CompareText(parser.TokenString, 'nil') = 0 then begin
          Output.WriteByte(Ord(vaNil));
         end
         else begin
          if CompareText(parser.TokenString, 'null') = 0 then begin
           Output.WriteByte(Ord(vaNull));
          end
          else begin
           Output.WriteByte(Ord(vaIdent));
           WriteString(parser.TokenComponentIdent);
          end;
         end;
        end;
       end;
       Parser.NextToken;
      end;
      // Set
      '[':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaSet));
          if parser.Token <> ']' then
            while True do
            begin
              parser.CheckToken(toSymbol);
              WriteString(parser.TokenString);
              parser.NextToken;
              if parser.Token = ']' then
                break;
              parser.CheckToken(',');
              parser.NextToken;
            end;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // List
      '(':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaList));
          while parser.Token <> ')' do
            ProcessValue;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // Collection
      '<':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaCollection));
          while parser.Token <> '>' do
          begin
            parser.CheckTokenSymbol('item');
            parser.NextToken;
            // ConvertOrder
            Output.WriteByte(Ord(vaList));
            while not parser.TokenSymbolIs('end') do
              ProcessProperty;
            parser.NextToken;   // Skip 'end'
            Output.WriteByte(0);
          end;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // Binary data
      '{':
        begin
          Output.WriteByte(Ord(vaBinary));
          stream := TMemoryStream.Create;
          try
            parser.HexToBinary(stream);
            WriteDWord(stream.Size);
            Output.WriteBuffer(Stream.Memory^, stream.Size);
          finally
            stream.Free;
          end;
          parser.NextToken;
        end;
      else
        parser.Error(SInvalidProperty);
    end;
  end;

  procedure ProcessProperty;
  var
    name: String;
  begin
    // Get name of property
    parser.CheckToken(toSymbol);
    name := parser.TokenString;
    while True do begin
      parser.NextToken;
      if parser.Token <> '.' then break;
      parser.NextToken;
      parser.CheckToken(toSymbol);
      name := name + '.' + parser.TokenString;
    end;
    WriteString(name);
    parser.CheckToken('=');
    parser.NextToken;
    ProcessValue;
  end;

  procedure ProcessObject;
  var
    Flags: Byte;
    ObjectName, ObjectType: String;
    ChildPos: Integer;
  begin
    if parser.TokenSymbolIs('OBJECT') then
      Flags :=0  { IsInherited := False }
    else begin
      if parser.TokenSymbolIs('INHERITED') then
        Flags := 1 { IsInherited := True; }
      else begin
        parser.CheckTokenSymbol('INLINE');
        Flags := 4;
      end;
    end;
    parser.NextToken;
    parser.CheckToken(toSymbol);
    ObjectName := '';
    ObjectType := parser.TokenString;
    parser.NextToken;
    if parser.Token = ':' then begin
      parser.NextToken;
      parser.CheckToken(toSymbol);
      ObjectName := ObjectType;
      ObjectType := parser.TokenString;
      parser.NextToken;
      if parser.Token = '[' then begin
        parser.NextToken;
        ChildPos := parser.TokenInt;
        parser.NextToken;
        parser.CheckToken(']');
        parser.NextToken;
        Flags := Flags or 2;
      end;
    end;
    if Flags <> 0 then begin
      Output.WriteByte($f0 or Flags);
      if (Flags and 2) <> 0 then
        WriteInteger(ChildPos);
    end;
    WriteString(ObjectType);
    WriteString(ObjectName);

    // Convert property list
    while not (parser.TokenSymbolIs('END') or
      parser.TokenSymbolIs('OBJECT') or
      parser.TokenSymbolIs('INHERITED') or
      parser.TokenSymbolIs('INLINE')) do
      ProcessProperty;
    Output.WriteByte(0);        // Terminate property list

    // Convert child objects
    while not parser.TokenSymbolIs('END') do ProcessObject;
    parser.NextToken;           // Skip end token
    Output.WriteByte(0);        // Terminate property list
  end;

const
  signature: PChar = 'TPF0';
begin
  parser := TParser.Create(Input);
  try
    Output.WriteBuffer(signature[0], 4);
    ProcessObject;
  finally
    parser.Free;
  end;
end;













procedure objectbinarytotextmse(input, output: tstream);
                //workaround for FPC bug with localized float strings
{$ifdef FPC}
var
 ch1: char;
{$endif}
begin
 {$ifdef FPC}
 ch1:= decimalseparator;
 decimalseparator:= '.';
 try
  objectbinarytotext(input,output);
 finally
  decimalseparator:= ch1;
 end;  
 {$else}
  objectbinarytotext(input,output);
 {$endif}
end;

procedure objecttexttobinarymse(input, output: tstream);
begin
 objecttexttobinary(input,output);
end;

end.
