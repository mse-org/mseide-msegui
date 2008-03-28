{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatstr;     //stringwandelroutinen 31.5.99 mse

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 Classes, msetypes,msestrings,SysUtils,mseguiglob;
const
// noformatsettings = 14.5;    //rtlversion
 noformatsettings = 15;    //rtlversion
 fc_keinplatzchar = '*';
 nullen = '000000000000000000000000000000';

type
 numbasety = (nb_bin,nb_oct,nb_dec,nb_hex);

function formatfloatmse(const value: double; const format: msestring;
                         const dot: boolean = false): msestring;
                      //if dot -> always '.' as decimal separator
function realtostr(const value: double): string;     //immer'.' als separator
function strtoreal(const s: string): double;   //immer'.' als separator

function bytetohex(const inp: byte): string;
 //wandelt byte in zwei ascii hexzeichen
function wordtohex(const inp: word; lsbfirst: boolean = false): string;
 //wandelt word in vier ascii hexzeichen


function dectostr(const inp: integer; digits: integer): string;
          //leading zeroes if digits < 0
function bintostr(inp: longword; digits: integer): string;
   //convert longword to binstring, digits = bit count
function octtostr(inp: longword; digits: integer): string;
   //convert longword to octaltring, digits = octet count
function hextostr(inp: longword; digits: integer): string;
   //convert longword to hexstring, digits = nibble count
function hextocstr(const inp: longword; stellen: integer): string;
   //convert longword to 0x..., digits = nibble count
function ptrinttocstr(inp: ptrint): string;
   //convert ptrint to 0x...
function intvaluetostr(const value: integer; const base: numbasety = nb_dec;
                          const bitcount: integer = 32): string;

function trystrtoptrint(const inp: string; out value: ptrint): boolean;
function strtoptrint(const inp: string): ptrint;

 //todo: no exceptions, 64bit
function strtobin(const inp: string): longword;
function strtooct(const inp: string): longword;
function strtodec(const inp: string): longword;
function strtohex(const inp: string): longword;
function strtointvalue(const inp: string): longword; overload;
   //% prefix -> bin, & -> oct, # -> dez, $ -> hex 0x -> hex
function strtointvalue(const text: msestring; base: numbasety): integer; overload;


function bytestrtostr(const inp: ansistring; base: numbasety; abstand: boolean): string;
   //wandelt bytefolge in ascii hexstring
function bytestrtobin(const inp: ansistring; abstand: boolean): string;
   //wandelt bytefolge in ascii binstring,
   // letztes zeichen = anzahl gueltige bits in letztem byte
function bitmaske(const data: ansistring): integer; //anzahl gueltige bits in vorletztem byte
function bitcount(const data: ansistring): integer; //anzahl gueltige bits

function bcdtostr(inp: byte): string;
 //wandelt bcdwert in zwei ascii zeichen
function bytetobcd(inp: byte): word;
 //wandelt byte in bcdwert
function bcdtobyte(inp: byte): byte;
 //wandelt bcdbyte in byte
function strtobytestr(inp: string): ansistring;
 //wandelt hex asciistring in bytefolge
function strtobinstr(inp: string): ansistring;
 //wandelt bin asciistring in bytefolge
function strtobytes(const inp: string; out dest: bytearty): boolean;
//msb first, true if ok

function inttostrlen(inp: integer; len: integer;
     rechtsbuendig: boolean = true; fillchar: char = ' '): ansistring;
 //wandelt integer in string fester laenge
{
function filename(inp: string): string;
//bringt filenamen ohne pfad und extension
function replaceext(inp,ext: string): string;
//ersetzt fileextension
}
function bcdtoint(inp: byte): integer;
function inttobcd(inp: integer): byte;

function stringtotime(const avalue: msestring): tdatetime;
function timetostring(const avalue: tdatetime; const format: string = 't'): msestring;
function datetimetostring(const avalue: tdatetime; const format: string = 'c'): msestring;
function stringtodatetime(const avalue: msestring): tdatetime;

//function strtotime(ein: string; var resultat: tdatetime): boolean;
 //true bei fehler
{wandelt string in zeit, 0.0 -> leer,
                         friss -> 0.000001 ca. 1/10 sek, 0:0:0 -> 0.000002,}
//function strtodat(ein: string; var resultat: tdatetime): boolean;
 //true bei fehler
{wandelt string in datum year = 0 -> leer, bereich 1950..2049}

function timemse(const value: tdatetime): tdatetime;
  //bringt timeanteil im mseformat

function cstringtostring(inp: pchar): string; overload;
function cstringtostring(const inp: string): string; overload;
function cstringtostringvar(var inp: pchar): string;
function stringtocstring(const inp: msestring): string;
function stringtopascalstring(const value: msestring): string;
function pascalstringtostring(const value: string): msestring;

//{$ifdef FPC}
 {$undef withformatsettings}
//{$else}
// {$if rtlversion > noformatsettings}
//  {$define withformatsettings}
// {$ifend}
//{$endif}

{$ifdef withformatsettings}
var
 defaultformatsettings: tformatsettings; //mit '.' als dezitrenner
{$endif}

const
 charhex: array[0..15] of char = 
          ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
 hexchars: array[char] of byte = (
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //0
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //1
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //2
  $00,$01,$02,$03,$04,$05,$06,$07,$30,$09,$80,$80,$80,$80,$80,$80, //3
  $80,$0A,$0B,$0C,$0D,$0E,$0F,$80,$80,$80,$80,$80,$80,$80,$80,$80, //4
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //5
  $80,$0a,$0b,$0c,$0d,$0e,$0f,$80,$80,$80,$80,$80,$80,$80,$80,$80, //6
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //7
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //8
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //9
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //a
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //b
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //c
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //d
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, //e
  $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80);//f
  
implementation

uses
 sysconst,msedate,msereal,Math;
 
//copied from FPC sysstr.inc
//todo: optimize

Function FloatToTextFmt(Buffer: PmseChar; Value: Extended; format: PmseChar): Integer;

Var
  Digits: String[40];                         { String Of Digits                 }
  Exponent: String[8];                        { Exponent strin                   }
  FmtStart, FmtStop: PmseChar;                { Start And End Of relevant part   }
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

  Function GetSectionEnd(Var P: PmseChar): Boolean;
  Var
    C: mseChar;
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
    Sec: Array[1..3] Of PmseChar;
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
    Fmt: PmseChar;
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
                          (fmt^ >= '0') and (fmt^ <= '9') do
//                          (Fmt[0] In ['0'..'9']) Do
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
    Fmt, Buf: PmseChar;
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
                  Buf[0] := widechar(Digits[N]);
                  Inc(Buf);
                  If thousand And (Digits[N]<>'-') Then
                    Begin
                    If (DigitExponent Mod 3 = 0) And (DigitExponent>0) Then
                      Begin
                      Buf[0] := widechar(ThousandSeparator);
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
                  Buf[0] := widechar(DecimalSeparator)
                Else
                  Buf[0] := widechar(Digits[Dig]);
                Inc(Buf);
                If thousand And (DigitExponent Mod 3 = 0) And (DigitExponent > 0) Then
                  Begin
                  Buf[0] := widechar(ThousandSeparator);
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
//                  If Fmt[0] In ['+', '-'] Then
                  If (Fmt[0] = '+') or (fmt[0] = '-') Then
                    Begin
                    Inc(Fmt, ExpSize);
                    For N:=1 To Length(Exponent) Do
                      Buf[N-1] := widechar(Exponent[N]);
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
//    Result:=PtrInt(Buf)-PtrInt(Buffer);
    result:= buf - buffer;
  End;
var
 int1: integer;
begin
 if value > 0 then begin
  getsectionrange(1);
 end
 else begin
  if (value < 0) then begin
   getsectionrange(2)
  end
  else begin
   getsectionrange(3);
  end;
 end;
 if fmtstart = nil then begin
 {$ifdef FPC}
  result:= floattotext(pchar(buffer),value,ffgeneral,15,4);
 {$else}
  result:= floattotext(pchar(buffer),value,fvextended,ffgeneral,15,4);
 {$endif}
 end
 else begin
  getformatoptions;
  if (expfmt = 0) and (abs(value) >= 1e18) then begin
 {$ifdef FPC}
   result:= floattotext(pchar(buffer),value,ffgeneral,15,4);
 {$else}
   result:= floattotext(pchar(buffer),value,fvextended,ffgeneral,15,4);
 {$endif}
  end
  else begin
   floattostr;
   result:= putresult;
   exit;
  end;
 end;
 for int1:= result - 1 downto 0 do begin
  pmsecharaty(buffer)^[int1]:= widechar(pcharaty(buffer)^[int1]);
             //convert to widestring
 end;
end;

function cstringtostringvar(var inp: pchar): string;

const
 quotechar = '"';
 escapechar = '\';

var
 po1,po2: pchar;
 int1,int2: integer;
 ch1: char;

begin
 result:= '';
 if inp <> nil then begin
  po1:= inp;
  while true do begin
   while (po1^ = ' ') do begin //first quote
    inc(po1);
   end;
   if (po1^ <> quotechar) then begin
    break;  //end or no start quote
   end;
   inc(po1);
   po2:= po1;  //text
   while true do begin
    while (po1^ <> quotechar) and (po1^ <> escapechar) do begin
     if (po1^ = #0) then begin
      result:= '';
      inp:= nil;
      exit; //error: no end quote
     end;
     inc(po1);
    end;
    int1:= po1-po2; //text length
    int2:= length(result)+1;
    setlength(result,length(result) + int1);
    move(po2^,result[int2],int1); //add text
    if po1^ = escapechar then begin
     inc(po1);
     case po1^ of
      'a': ch1:= #$07;
      'b': ch1:= #$08;
      'f': ch1:= #$0c;
      'n': ch1:= #$0a;
      'r': ch1:= #$0d;
      't': ch1:= #$09;
      'v': ch1:= #$0b;
      '\': ch1:= '\';
      '''': ch1:= '''';
      '"': ch1:= '"';
      '?': ch1:= '?';
      '0'..'7': begin
       po2:= po1;
       for int1:= 0 to 2 do begin
        if (po1^ < '0') or (po1^ > '7') then begin
         break;
        end;
        inc(po1);
       end;
       ch1:= char(strtooct(psubstr(po2,po1)));
       dec(po1);
      end;
      'x','X': begin
       inc(po1);
       po2:= po1;
       while (po1^ >= '0') and (po1^ <= '9') or
             (po1^ >= 'a') and (po1^ <= 'f') or
             (po1^ >= 'A') and (po1^ <= 'F') do begin
        inc(po1);
       end;
       ch1:= char(strtohex(psubstr(po2,po1)));
       dec(po1);
      end;
      else begin
       ch1:= ' ';
      end;
     end;
     result:= result + ch1;
     inc(po1);
    end
    else begin
     inc(po1);
     break;
    end;
    po2:= po1; //past quote
   end;
  end;
  inp:= po1;
 end;
end;

function cstringtostring(inp: pchar): string;
begin
 result:= cstringtostringvar(inp);
end;

function cstringtostring(const inp: string): string;
var
 po1: pchar;
begin
 po1:= pchar(inp);
 result:= cstringtostringvar(po1);
end;

function stringtocstring(const inp: msestring): string;
var
 po1: pmsechar;
 innum: boolean;
begin
 result:= '"';
 po1:= pmsechar(inp);
 innum:= false;
 while po1^ <> #0 do begin
  if (po1^ < #$20) or (po1^ > #$ff) or (po1^ = #$7f) then begin
   innum:= true;
   if po1^ < #$100 then begin
    result:= result + '\x'+hextostr(ord(po1^),2);
   end
   else begin
    result:= result + '\x'+hextostr(ord(po1^),4);
   end;
  end
  else begin
   if po1^ = '"' then begin
    result:= result + '\"';
    innum:= false;
   end
   else begin
    if innum then begin
     result:= result + '" "'+po1^;
     innum:= false;
    end
    else begin
     result:= result + po1^;
    end;
   end;
  end;
  inc(po1);
 end;
 result:= result + '"';
end;

function stringtopascalstring(const value: msestring): string;
var
 int1,int2: integer;
 po1: pchar;
 str1: string;
 asciimode: boolean;
begin
 if length(value) = 0 then begin
  result:= '''''';
 end
 else begin
  asciimode:= false;
  setlength(result,2+6*length(value)); // maxlength for single char: '#65535' = 2 + 6
  po1:= pchar(pointer(result));
//  int2:= 1;
  for int1:= 1 to length(value) do begin
   int2:= ord(value[int1]);
   if (int2 >= 32) and (int2 < 127) then begin
    if not asciimode then begin
     asciimode:= true;
     po1^:= '''';
     inc(po1);
    end;
    if char(int2) = '''' then begin
     po1^:= ''''; //double quote
     inc(po1);
    end;
    po1^:= char(int2);
    inc(po1);
   end
   else begin
    if asciimode then begin
     asciimode:= false;
     po1^:= '''';
     inc(po1);
    end;
    po1^:= '#';
    inc(po1);
    str1:= inttostr(int2);
    move(pchar(pointer(str1))^,po1^,length(str1));
    inc(po1,length(str1));
   end;
  end;
  if asciimode then begin
   po1^:= '''';
   inc(po1);
  end;
  setlength(result,po1-pchar(pointer(result)));
 end;
end;

function pascalstringtostring(const value: string): msestring;

 procedure doerror;
 begin
  raise exception.Create('Invalid pascalstring: "'+value+'".');
 end;

var
 po1: pmsechar;
 po2,po3: pchar;
 int1: integer;
 str1: string;
begin
 setlength(result,length(value)); //max length
 po1:= pmsechar(pointer(result));
 po2:= pchar(value);
 while po2^ <> #0 do begin
  case po2^ of
   '#': begin
    inc(po2);
    po3:= po2;
    while (po2^ >= '0') and (po2^ <= '9') do begin
     inc(po2);
    end;
    setstring(str1,po3,po2-po3);
    po1^:= msechar(strtoint(str1));
    inc(po1);
   end;
   '''': begin               
    inc(po2);                  //'.....
    po3:= po2;
    while (po2^ <> '''') and (po2^ <> #0) do begin
     inc(po2)
    end;
    if po2^ <> #0 then begin   
     for int1:= 0 to po2 - po3 - 1 do begin //'abcd'......
      po1^:= msechar((po3+int1)^);
      inc(po1);
     end;
     inc(po2);
     if po2^ = '''' then begin //'abcd'?
      po1^:= '''';             //'abcd''
      inc(po1);                
//      inc(po2);
//      if po2^ = '''' then begin
//       inc(po2);
//      end;
     end;
    end
    else begin
     doerror;
    end;
   end;
   ' ',c_tab: begin
    inc(po2)
   end
   else begin
    doerror;
   end;
  end;
 end;
 setlength(result,po1-pmsechar(pointer(result)));
end;

function stringtotime(const avalue: msestring): tdatetime;
begin
 if avalue = ' ' then begin
  result:= frac(now);
 end
 else begin
  if avalue = '' then begin
   result:= emptydatetime;
  end
  else begin
   result:= sysutils.strtotime(avalue);
  end;
 end;
end;

function timetostring(const avalue: tdatetime; const format: string = 't'): msestring;
begin
 if isemptydatetime(avalue) then begin
  result:= '';
 end
 else begin
  if format = '' then begin
   result:= formatdatetime('t',avalue);
  end
  else begin
   result:= formatdatetime(format,avalue);
  end;
 end;
end;

function datetimetostring(const avalue: tdatetime; const format: string = 'c'): msestring;
begin
 if isemptydatetime(avalue) then begin
  result:= '';
 end
 else begin
  if format = '' then begin
   result:= formatdatetime('c',avalue);
  end
  else begin
   result:= formatdatetime(format,avalue);
  end;
 end;
end;

function stringtodatetime(const avalue: msestring): tdatetime;
begin
 if avalue = ' ' then begin
  result:= now;
 end
 else begin
  if avalue = '' then begin
   result:= emptydatetime;
  end
  else begin
   result:= strtodatetime(avalue);
  end;
 end;
end;
(*
function strtodat(ein: string; var resultat: tdatetime): boolean;
 //true bei fehler
{wandelt string in datum year = 0 -> leer, bereich 1950..2049}

var
 int1: integer;
 io: boolean;
 str1,str2,str3: string[10];
 erstpunkt,zweitpunkt: integer;
 jahr,monat,tag,year,month,day: word;
 res: tdatetime;

begin
 result:= false;
 res:= 0.0;
 decodedate(sysutils.date,jahr,monat,tag);
 year:= 0;
 month:= 0;
 day:= 0;
 if ein <> '' then begin
  ein:= trim(ein);
  if ein = '' then begin
   res:= int(sysutils.Now);
  end
  else begin
  {
   if ein = d_leerzeichen then begin
    res:= frissdate
   end
   else begin
   }
    erstpunkt:= pos('.',ein);
    if erstpunkt <> 0 then begin
     zweitpunkt:= pos('.',copy(ein,erstpunkt+1,20));
     if zweitpunkt <> 0 then
      zweitpunkt:= zweitpunkt + erstpunkt;
     end
    else
     zweitpunkt:= 0;
    str1:= '';
    str2:= '';
    str3:= '';
    if erstpunkt <> 0 then begin
     str1:= trim(copy(ein,1,erstpunkt-1));
     if zweitpunkt <> 0 then begin
      str2:= trim(copy(ein,erstpunkt+1,zweitpunkt-erstpunkt-1));
      str3:= trim(copy(ein,zweitpunkt+1,20));
     end
     else
      str2:= trim(copy(ein,erstpunkt+1,20));
    end
    else
     str1:= trim(ein);
    io:= true;
    if str1 <> '' then begin
     val(str1,tag,int1);
     io:= io and (int1 = 0);
    end;
    if str2 <> '' then begin
     val(str2,monat,int1);
     io:= io and (int1 = 0);
    end;
    if str3 <> '' then begin
     val(str3,jahr,int1);
     io:= io and (int1 = 0);
    end;
    if jahr < 100 then begin
     if (jahr >= 50) then
      jahr:= jahr + 1900
     else
      jahr:= jahr + 2000;
    end;
    if (io and {(jahr >= 1900) and (jahr <= 2100) and} (monat > 0)
      and (monat <= 12) and (tag >= 1) and (tag <= maxdays(jahr,monat))) then begin
       year:= jahr;
       month:= monat;
       day:= tag;
    end
    else begin
     result:= true;{ungueltig}
    end;
    if not result then begin
     res:= encodedate(year,month,day);
    end;
//   end;
  end;
 end
 else begin
  res:= emptydatetime;
 end;
 if not result then begin
  resultat:= res;
 end;
end;

function strtotime(ein: string; var resultat: tdatetime): boolean;
 //true bei fehler
{wandelt string in zeit, 0.0 -> leer,
                         friss -> 0.000001 ca. 1/10 sek, 0:0:0 -> 0.000002,}
var
 int1: integer;
 io: boolean;
 str1,str2,str3: string[10];
 erstpunkt,zweitpunkt: integer;
 stunde,minute,sekunde: word;
// wo1: word;
begin
 result:= false;
 stunde:= 0;
 minute:= 0;
 sekunde:= 0;
 if ein <> '' then begin
  ein:= trim(ein);
  if ein = '' then begin
   resultat:= frac(sysutils.now);
  end         //aktuelle zeit
  else begin
  {
   if ein = d_leerzeichen then begin
    resultat:= frisstime;
    result:= true;
    exit;
   end
   else begin
   }
    erstpunkt:= pos(':',ein);
    if erstpunkt <> 0 then begin
     zweitpunkt:= pos(':',copy(ein,erstpunkt+1,20));
     if zweitpunkt <> 0 then
      zweitpunkt:= zweitpunkt + erstpunkt;
     end
    else
     zweitpunkt:= 0;
    str1:= '';
    str2:= '';
    str3:= '';
    if erstpunkt <> 0 then begin
     str1:= trim(copy(ein,1,erstpunkt-1));
     if zweitpunkt <> 0 then begin
      str2:= trim(copy(ein,erstpunkt+1,zweitpunkt-erstpunkt-1));
      str3:= trim(copy(ein,zweitpunkt+1,20));
     end
     else
      str2:= trim(copy(ein,erstpunkt+1,20));
    end
    else
     str1:= trim(ein);
    io:= true;
    if str1 <> '' then begin
     val(str1,stunde,int1);
     io:= io and (int1 = 0);
    end;
    if str2 <> '' then begin
     val(str2,minute,int1);
     io:= io and (int1 = 0);
    end;
    if str3 <> '' then begin
     val(str3,sekunde,int1);
     io:= io and (int1 = 0);
    end;
    if io and (stunde < 24) and (minute < 60) and (sekunde < 60) then begin
     resultat:= encodetime(stunde,minute,sekunde,0);
     if resultat = 0 then begin
      resultat:= nulltime;
     end;
    end
    else begin
     result:= true;
    end;
   end;
//  end;
 end
 else begin
  resultat:= emptytime; //leere zeit
  exit;
 end;
end;
*)
function timemse(const value: tdatetime): tdatetime;
  //bringt timeanteil im mseformat
begin
 result:= frac(value);
// if result = 0 then begin
//  result:= nulltime;
// end;
end;

function bcdtoint(inp: byte): integer;
begin
 result:= ((inp and $f0) shr 4) * 10 + (inp and $0f);
end;

function inttobcd(inp: integer): byte;
begin
 result:= byte(((inp div 10) shl 4) + (inp mod 10))
end;

function formatfloatmse(const value: double; const format: msestring;
                                 const dot: boolean = false): msestring;
var
 int1: integer;
begin
 setlength(result,length(format)+200); //max
 int1:= floattotextfmt(pmsechar(result),value,pmsechar(format));
 setlength(result,int1);
 if dot then begin
  replacechar1(result,widechar(decimalseparator),widechar('.'));
 end;
end;

function realToStr(const value: double): string;     //immer'.' als separator
begin
 {$ifdef withformatsettings}
 result:= floattostr(value,defaultformatsettings)
 {$else}
 result:= replacechar(floattostr(value),decimalseparator,'.');
 {$endif}
end;

function StrToreal(const S: string): double;   //immer'.' als separator
begin
 {$ifdef withformatsettings}
 result:= strtofloat(s,defaultformatsettings);
 {$else}
 result:= strtofloat(replacechar(s,'.',decimalseparator));
 {$endif}
end;

function bcdtostr(inp: byte): string;
 //wandelt bcdwert in zwei ascii zeichen
begin
 result:= char(byte(inp shr byte(4)) + ord('0'))+
          char(byte(inp and $0f) + ord('0'));
end;

function bytetobcd(inp: byte): word;
 //wandelt byte in bcdwert
begin
 result:= (inp div 100 shl 8) or ((inp div 10) mod 10 shl 4) or (inp mod 10)
end;

function bcdtobyte(inp: byte): byte;
 //wandelt bcdbyte in byte
begin
 result:= (inp shr 4)*10 + inp and $0f;
end;

function bytetohex(const inp: byte): string;
 //wandelt byte in zwei ascii hexzeichen
var
 ch1,ch2: char;
begin
 ch1:= char((inp shr 4) + byte('0'));
 if ch1 > '9' then begin
  ch1:= char(byte(ch1) + byte('A')-byte('0')-10);
 end;
 ch2:= char((inp and $0f) + byte('0'));
 if ch2 > '9' then begin
  ch2:= char(byte(ch2) + byte('A')-byte('0')-10);
 end;
 result:= ch1 + ch2;
end;

function wordtohex(const inp: word; lsbfirst: boolean = false): string;
 //wandelt word in vier ascii hexzeichen
begin
 if lsbfirst then begin
  result:= bytetohex(inp) + bytetohex(inp shr 8);
 end
 else begin
  result:=  bytetohex(inp shr 8) + bytetohex(inp);
 end;
end;

function bytestrtostr(const inp: ansistring; base: numbasety; abstand: boolean): string;
   //wandelt bytefolge in ascii hexstring
var
 int1: integer;
begin
 result:= '';
 for int1:= 1 to length(inp) do begin
  result:= result + intvaluetostr(byte(inp[int1]),base,8);
  if abstand and (int1 <> length(inp)) then begin
    result:= result + ' ';
  end;
 end;
end;

function strtobytestr(inp: string): ansistring;
 //wandelt hex asciistring in bytefolge
var
 int1,int2, int3: integer;
 str1: string;
begin
 result:= '';
 removechar(inp,' ');
 int2:= length(inp);
 if int2 > 0 then begin
  setlength(result,(int2+1) div 2);
  setlength(str1,2);
  int1:= 1;
  int3:= 1;
  while int1 <= int2 do begin
   str1[1]:= inp[int1];
   inc(int1);
   if int1 > int2 then begin
    setlength(str1,1);
   end
   else begin
    str1[2]:= inp[int1];
   end;
   result[int3]:= char(strtoint('$'+str1));
   inc(int1);
   inc(int3);
  end;
 end;
end;

function strtobytes(const inp: string; out dest: bytearty): boolean;
var
 po1,po2: pchar;
 int1: integer;
 by1: shortint;
begin
 result:= false;
 int1:= length(inp)+1;
 setlength(dest,int1 div 2);
 po1:= @inp[int1];
 po2:= pchar(inp);
 int1:= high(dest);
 while po1 > po2 do begin
  dec(po1);
  by1:= hexchars[po1^];
  if by1 < 0 then begin
   exit;
  end;
  dest[int1]:= by1;

  if po1 = po2 then begin
   break;
  end;
  dec(po1);
  by1:= hexchars[po1^];
  if by1 < 0 then begin
   exit;
  end;
  dest[int1]:= dest[int1] or (by1 shl 4);
  dec(int1);
 end;
 result:= true;
end;

function bytestrtobin(const inp: ansistring; abstand: boolean): string;
   //wandelt bytefolge in ascii binstring,
   // letztes zeichen = anzahl gueltige bits in letztem byte
var
 int1,int2,int3,int4: integer;
// str1: string;
 by1,by2: byte;

begin
 result:= '';
 int2:= bitcount(inp)-1;
 int3:= 1;
 int4:= 0;
 while int2 >= 0 do begin
  by1:= byte(inp[int3]);
  by2:= $01;
  for int1:= 0 to 7 do begin
   if by1 and by2 <> 0 then begin
    result:= result + '1';
   end
   else begin
    result:= result + '0';
   end;
   if int4+int1 >= int2 then begin
    break;
   end;
   by2:= by2 shl 1;
  end;
  if int4+(int1 and $07) >= int2 then begin
   break;
  end;
  if abstand then begin
   result:= result + ' ';
  end;
  inc(int3);
  inc(int4,8);
 end;
end;

function strtobinstr(inp: string): ansistring;
 //wandelt bin asciistring in bytefolge,
 // letztes byte = anzahl gueltige bits in vorletztem byte
var
 int1,int2,int3: integer;
 by1,by2: byte;
 ch1: char;
begin
 result:= '';
 removechar(inp,' ');
 int1:= length(inp);
 int3:= 1;
 int2:= 0;
 while int3 <= int1 do begin
  by1:= 1;
  by2:= 0;
  for int2:= 0 to 7 do begin
   if int3 + int2 > int1 then begin
    break;
   end;
   ch1:= inp[int3+int2];
   if ch1 = '1' then begin
    by2:= by2 or by1;
   end
   else begin
    if ch1 <> '0' then begin
     raise EConvertError.CreateFmt(SInvalidInteger,[inp]);
    end;
   end;
   by1:= by1 shl 1;
  end;
  int3:= int3 + 8;
  result:= result + char(by2);
 end;
 if length(result) > 0 then begin
  result:= result + char(int2);
 end;
end;

function bitmaske(const data: ansistring): integer;
begin
 if length(data) > 1 then begin
  result:= byte(data[length(data)]);
  if result > 8 then begin
   result:= 8
  end;
 end
 else begin
  result:= 0;
 end;
end;

function bitcount(const data: ansistring): integer; //anzahl gueltige bits
var
 int1: integer;
begin
 int1:= length(data);
 if int1 > 1 then begin
  result:= 8*(int1-2) + bitmaske(data);
 end
 else begin
  result:= 0;
 end;
end;

function bintostr(inp: longword; digits: integer): string;
   //convert longword to binstring, digits = bit count
var
 int1: integer;
begin
 setlength(result,digits);
 for int1:= digits downto 1  do begin
  result[int1]:= char(ord('0') + (inp and $1));
  inp:= inp shr 1;
 end;
end;

function octtostr(inp: longword; digits: integer): string;
   //convert longword to octaltring, digits = octet count
var
 int1: integer;
begin
 setlength(result,digits);
 for int1:= digits downto 1  do begin
  result[int1]:= char(ord('0') + (inp and $7));
  inp:= inp shr 3;
 end;
end;

function dectostr(const inp: integer; digits: integer): string;
          //leading zeroes if digits < 0
begin
 result:= inttostr(abs(inp));
 if digits < 0 then begin
  digits:= -digits;
  if digits > length(nullen) then begin
   digits:= length(nullen);
  end;
  result:= copy(nullen,1,digits-length(result)) + result;
 end;
 result:= copy(result,length(result)-digits+1,bigint);
 if inp < 0 then begin
  result:= '-' + result;
 end;
end;

function hextostr(inp: longword; digits: integer): string;
   //wandelt longword in hexstring, stellen = anzahl nibbles
var
 int1: integer;
begin
 setlength(result,digits);
 for int1:= digits downto 1  do begin
  result[int1]:= char(ord('0') + (inp and $f));
  if result[int1] > '9' then begin
   inc(result[int1],ord('A')-ord('9')-1);
  end;
  inp:= inp shr 4;
 end;
end;

function hextocstr(const inp: longword; stellen: integer): string;
begin
 result:= '0x' + hextostr(inp, stellen);
end;

function ptrinttocstr(inp: ptrint): string;
   //convert ptrint to 0x...
var
 int1: integer;
begin
 result:= '0x';
 setlength(result,2+sizeof(ptrint)*2);
 for int1:= length(result) downto 3  do begin
  result[int1]:= char(ord('0') + (inp and $f));
  if result[int1] > '9' then begin
   inc(result[int1],ord('A')-ord('9')-1);
  end;
  inp:= inp shr 4;
 end;
end;

function strtointvalue(const text: msestring; base: numbasety): integer;
var
 str1: string;
begin
 str1:= trim(text);
 case base of
  nb_bin: begin
   result:= strtobin(str1);
  end;
  nb_oct: begin
   result:= strtooct(str1);
  end;
  nb_hex: begin
   result:= strtohex(str1);
  end
  else begin //nb_dec
   result:= strtodec(str1);
  end;
 end;
end;

function intvaluetostr(const value: integer; const base: numbasety = nb_dec;
                          const bitcount: integer = 32): string;
begin
 case base of
  nb_bin: begin
   result:= bintostr(value,abs(bitcount));
  end;
  nb_oct: begin
   result:= octtostr(value,(abs(bitcount)+2) div 3);
  end;
  nb_hex: begin
   result:= hextostr(value,(abs(bitcount)+3) div 4);
  end;
  else begin //nb_dec
   result:= dectostr(value,sign(bitcount)*(abs(bitcount)*100+331) div 332);
  end;
 end;
end;

procedure formaterror(const value: string);
begin
 raise exception.Create('Invalid number '''+value+'''.');
end;

function strtobin1(const inp: string): longword;
   //wandelt 1..0-string in longword)
var
 int1: integer;
 lwo1: longword;
begin
 if length(inp) = 0 then begin
  formaterror(inp);
 end;
 result:= 0;
 lwo1:= 1;
 for int1:= length(inp) downto 1 do begin
  if inp[int1] = '1' then begin
   result:= result + lwo1;
  end
  else begin
   if inp[int1] <> '0' then begin
    result:= strtoint(inp); //exception erzeugen
   end;
  end;
  lwo1:= lwo1 shl 1;
 end;
end;

function strtobin(const inp: string): longword;
   //wandelt 1..0-string in longword)
begin
 try
  result:= strtobin1(inp);
 except
  result:= strtointvalue(inp);
 end;
end;

function strtooct1(const inp: string): longword;
var
 int1: integer;
 ca1: cardinal;
 ch1: char;
begin
 if length(inp) = 0 then begin
  formaterror(inp);
 end;
 result:= 0;
 ca1:= 0;
 for int1:= length(inp) downto 1 do begin
  ch1:= inp[int1];
  if (ch1 < '0') or (ch1 > '7') then begin
   formaterror(inp);
  end
  else begin
   result:= result + cardinal(((ord(ch1) - ord('0'))) shl ca1);
  end;
  inc(ca1,3);
 end;
end;

function strtooct(const inp: string): longword;
   //wandelt 1..0-string in longword)
begin
 try
  result:= strtooct1(inp);
 except
  result:= strtointvalue(inp);
 end;
end;

function strtodec1(const inp: string): longword;
begin
 if length(inp) = 0 then begin
  formaterror(inp);
 end;
 result:= strtoint(inp);
end;

function strtodec(const inp: string): longword;
   //wandelt 1..0-string in longword)
begin
 try
  result:= strtodec1(inp);
 except
  result:= strtointvalue(inp);
 end;
end;

function strtohex1(const inp: string): longword;
begin
 if length(inp) = 0 then begin
  formaterror(inp);
 end;
 result:= strtoint('$'+inp);
end;

function strtohex(const inp: string): longword;
begin
 try
  result:= strtohex1(inp);
 except
  result:= strtointvalue(inp);
 end;
end;

function strtointvalue(const inp: string): longword;
begin
 if length(inp) > 0 then begin
  case inp[1] of
  '%': result:= strtobin1(copy(inp,2,length(inp)-1));
  '&': result:= strtooct1(copy(inp,2,length(inp)-1));
  '#': result:= strtoint(copy(inp,2,length(inp)-1));
  '$': result:= strtohex1(copy(inp,2,length(inp)-1));
   else begin
    if (length(inp) > 2) and
           ((inp[2] = 'x') or (inp[2] = 'X')) and (inp[1] = '0') then begin
     result:= strtohex1(copy(inp,3,length(inp)-2));
    end
    else begin
     result:= strtoint(inp);
    end;
   end;
  end;
 end
 else begin
  result:= strtoint(inp);
 end;
end;

function strtoptrint(const inp: string): ptrint;
begin
 result:= strtointvalue(inp);
end;

function trystrtoptrint(const inp: string; out value: ptrint): boolean;
begin
 try
  value:= strtoptrint(inp);
  result:= true;
 except
  result:= false;
 end;
end;

{
function filename(inp: string): string;
 //bringt filenamen ohne pfad und extension
begin
 result:= replaceext(extractfilename(inp),'');
end;
function replaceext(inp,ext: string): string;
 //ersetzt fileextension filenamen ohne pfad und extension

begin
 result:= changefileext(inp,ext);
end;
}

function inttostrlen(inp: integer; len: integer;
     rechtsbuendig: boolean = true; fillchar: char = ' '): ansistring;
 //wandelt integer in string fester laenge
var
 int1: integer;
begin
 result:= inttostr(inp);
 int1:= length(result);
 setlength(result,len);
 if int1 < len then begin
  if rechtsbuendig then begin
   move(result[1],result[len-int1+1],int1);
   system.fillchar(result[1],len-int1,fillchar);
  end
  else begin
   system.fillchar(result[int1+1],len-int1,fillchar);
  end;
 end
 else begin
  if int1 > len then begin
   system.fillchar(result[1],len,fc_keinplatzchar);
  end;
 end;
end;

{
function replacetabs(const inp: string): string; //ersetzt tabs durch ' '
var
 int1: integer;
begin
 result:= inp;
 for int1:= 1 to length(result) do begin
  if result[int1] = c_tab then begin
   result[int1]:= ' ';
  end;
 end;
end;
}

{$ifdef withformatsettings}
initialization
 getlocaleformatsettings(0,defaultformatsettings);
 defaultformatsettings.DecimalSeparator:= '.';
{$endif}
end.
