{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestrings; 

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegraphutils,msetypes{$ifdef FPC},strings{$endif};
{$ifdef FPC}
 {$ifdef FPC_WINLIKEWIDESTRING}
  {$define msestringsarenotrefcounted}
 {$endif}
{$else}
 {$ifdef mswindows}
  {$define msestringsarenotrefcounted}
 {$endif}
{$endif}

type
 msestring = widestring;
 msechar = widechar;
 pmsechar = pwidechar;

const
 c_linefeed = #$0a;
 c_return = #$0d;
 c_tab = #$09;
 c_backspace = #$08;
 c_delete = #$7f;

 {$ifdef mswindows}
 pathdelim = '\';
 lineend = #$0d#$0a;
 {$else}
 pathdelim = '/';
 lineend = #$0a;
 {$endif}
 defaultdelimchars = ' '+c_tab+c_return+c_linefeed;
 defaultmsedelimchars = msestring(defaultdelimchars);

const
 maxdatasize = $7fffffff;
type
 pmsestring = ^msestring;
// strty = array[0..maxdatasize-1] of char;
// pstrty = ^strty;
// msestrty = array[0..maxdatasize div sizeof(msechar)-1] of msechar;
// pmsestrty = ^msestrty;
 msestringarty = array of msestring;
 pmsestringarty = ^msestringarty;
 msestringaty = array[0..0] of msestring;
 pmsestringaty = ^msestringaty;
 charaty = array[0..maxdatasize-1] of char;
 pcharaty = ^charaty;
 msecharaty = array[0..maxdatasize div sizeof(msechar)-1] of msechar;
 pmsecharaty = ^msecharaty;
 captionty = msestring;
 filenamety = msestring;
 pfilenamety = ^filenamety;
 filenamearty = msestringarty;

const
 upperchars: array[char] of char = (
  #$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,#$08,#$09,#$0a,#$0b,#$0c,#$0d,#$0e,#$0f,
  #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,#$18,#$19,#$1a,#$1b,#$1c,#$1d,#$1e,#$1f,
  #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,#$28,#$29,#$2a,#$2b,#$2c,#$2d,#$2e,#$2f,
  #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,#$38,#$39,#$3a,#$3b,#$3c,#$3d,#$3e,#$3f,
  #$40,#$41,#$42,#$43,#$44,#$45,#$46,#$47,#$48,#$49,#$4a,#$4b,#$4c,#$4d,#$4e,#$4f,
  #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,#$58,#$59,#$5a,#$5b,#$5c,#$5d,#$5e,#$5f,
  #$60,'A' ,'B' ,'C' ,'D' ,'E' ,'F' ,'G' ,'H' ,'I' ,'J' ,'K' ,'L' ,'M' ,'N' ,'O' ,
  'P' ,'Q' ,'R' ,'S' ,'T' ,'U' ,'V' ,'W' ,'X' ,'Y' ,'Z' ,#$7b,#$7c,#$7d,#$7e,#$7f,
  #$80,#$81,#$82,#$83,#$84,#$85,#$86,#$87,#$88,#$89,#$8a,#$8b,#$8c,#$8d,#$8e,#$8f,
  #$90,#$91,#$92,#$93,#$94,#$95,#$96,#$97,#$98,#$99,#$9a,#$9b,#$9c,#$9d,#$9e,#$9f,
  #$a0,#$a1,#$a2,#$a3,#$a4,#$a5,#$a6,#$a7,#$a8,#$a9,#$aa,#$ab,#$ac,#$ad,#$ae,#$af,
  #$b0,#$b1,#$b2,#$b3,#$b4,#$b5,#$b6,#$b7,#$b8,#$b9,#$ba,#$bb,#$bc,#$bd,#$be,#$bf,
  #$c0,#$c1,#$c2,#$c3,#$c4,#$c5,#$c6,#$c7,#$c8,#$c9,#$ca,#$cb,#$cc,#$cd,#$ce,#$cf,
  #$d0,#$d1,#$d2,#$d3,#$d4,#$d5,#$d6,#$d7,#$d8,#$d9,#$da,#$db,#$dc,#$dd,#$de,#$df,
  #$e0,#$e1,#$e2,#$e3,#$e4,#$e5,#$e6,#$e7,#$e8,#$e9,#$ea,#$eb,#$ec,#$ed,#$ee,#$ef,
  #$f0,#$f1,#$f2,#$f3,#$f4,#$f5,#$f6,#$f7,#$f8,#$f9,#$fa,#$fb,#$fc,#$fd,#$fe,#$ff);

type
 lstringty = record
  po: pchar;
  len: integer;
 end;

 lmsestringty = record
  po: pmsechar;
  len: integer;
 end;
 lstringarty = array of lstringty;
 lmsestringarty = array of lmsestringty;

const
 emptylstring: lstringty = (po: nil; len: 0);
 emptywstring: lmsestringty = (po: nil; len: 0);

type
 searchoptionty = (so_caseinsensitive,so_wholeword);
 searchoptionsty = set of searchoptionty;

function removechar(const source: string; a: char): string; overload;
function removechar(const source: msestring; a: msechar): msestring; overload;
procedure removechar1(var dest: string; a: char); overload;
procedure removechar1(var dest: msestring; a: msechar); overload;
  //removes all a
function printableascii(const source: string): string; 
                //removes all nonprintablechars and ' '
function replacechar(const source: string; a,b: char): string; overload;
function replacechar(const source: msestring; a,b: msechar): msestring; overload;
procedure replacechar1(var dest: string; a,b: char); overload;
procedure replacechar1(var dest: msestring; a,b: msechar); overload;
  //replaces a by b
function stringfromchar(achar: char; count : integer): string; overload;
function stringfromchar(achar: msechar; count : integer): msestring; overload;

function replacetext(const source: string; index: integer; a: string): string; overload;
function replacetext(const source: msestring; index: integer;
       a: msestring): msestring; overload;
procedure replacetext1(var dest: string; index: integer; const a: string); overload;
procedure replacetext1(var dest: msestring; index: integer; const a: msestring); overload;

procedure addstringsegment(var dest: msestring; const a,b: pmsechar);
               //add text from a^ to (b-1)^ to dest
function stringsegment(a,b: pmsechar): msestring;

function lstringtostring(const value: lmsestringty): msestring; overload;
function lstringtostring(const value: lstringty): string; overload;
procedure stringtolstring(const value: string; var{out} res: lstringty); overload;  //todo!!!!! fpbug 3221
procedure stringtolstring(const value: msestring; var{out} res: lmsestringty); overload;
function stringtolstring(const value: string): lstringty; overload;
function stringtolstring(const value: msestring): lstringty; overload;
function lstringartostringar(const value: lstringarty): stringarty;

procedure nextword(const value: msestring; out res: lmsestringty); overload;
procedure nextword(const value: string; out res: lstringty); overload;
procedure nextword(var value: lmsestringty; out res: lmsestringty); overload;
procedure nextword(var value: lstringty; out res: lstringty); overload;
procedure nextword(var value: lstringty; out res: string); overload;
function nextquotedstring(var value: lstringty; out res: string): boolean;
                   //false wenn kein quote vorhanden
procedure lstringgoback(var value: lstringty; const res: lstringty);
function issamelstring(const value: lmsestringty; const key: msestring;
             caseinsensitive: boolean = false): boolean; overload;
             //nur ascii caseinsens.
function issamelstring(const value: lstringty; const key: string;
             caseinsensitive: boolean = false): boolean; overload;
             //nur ascii caseinsens.
function lstringcomp(const a,b: lstringty): integer; overload;
function lstringcomp(const a: lstringty; const b: string): integer; overload;
function lstringicomp(const a,b: lstringty): integer; overload;
         //ascii case insensitive
function lstringicomp(const a: lstringty; const b: string): integer; overload;
         //ascii case insensitive
function lstringicomp1(const a,b: lstringty): integer; overload;
         //ascii case insensitive, b must be uppercase
function lstringicomp1(const a: lstringty; const b: string): integer; overload;
         //ascii case insensitive, b must be uppercase

function stringcomp(const a,b: string): integer;
function stringicomp(const a,b: string): integer;
         //ascii case insensitive
function stringicomp1(const a,upstr: string): integer;
         //ascii case insensitive, b must be uppercase

function msestringcomp(const a,b: msestring): integer;
function msestringicomp(const a,b: msestring): integer;
         //ascii case insensitive
function msestringicomp1(const a,upstr: msestring): integer;
         //ascii case insensitive, upstr must be uppercase

function comparestrlen(S1,S2: string): integer;
                //case sensitiv, beruecksichtigt nur s1 laenge
function msecomparestr(const S1, S2: msestring): Integer;
function msecomparetext(const S1, S2: msestring): Integer;
function msecomparestrlen(const S1, S2: msestring): Integer;
                //case sensitiv, beruecksichtigt nur s1 laenge
function mseCompareTextlen(const S1, S2: msestring): Integer;
                //case insensitiv, beruecksichtigt nur s1 laenge

function encodesearchoptions(caseinsensitive: boolean = false;
                        wholeword: boolean = false): searchoptionsty;
function msestringsearch(const substring,s: msestring; start: integer;
                      options: searchoptionsty;
                      const substringupcase: msestring = ''): integer; overload;
function stringsearch(const substring,s: string; start: integer;
                      options: searchoptionsty;
                      const substringupcase: string = ''): integer; overload;


function processeditchars(var value: msestring; stripcontrolchars: boolean): integer;
           //bringt offset durch backspace
function mseextractprintchars(const value: msestring): msestring;

function findchar(const str: string; achar: char): integer; overload;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
function findchar(const str: msestring; achar: msechar): integer; overload;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
function findchars(const str: string; const achars: string): integer; overload;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
function findchars(const str: msestring; const achars: msestring): integer; overload;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
function findlastchar(const str: string; achar: char): integer; overload;
  //bringt index des letzten vorkommens von zeichen in string, 0 wenn nicht gefunden
function findlastchar(const str: msestring; achar: msechar): integer; overload;
  //bringt index des letzten vorkommens von zeichen in string, 0 wenn nicht gefunden
function countchars(const str: string; achar: char): integer; overload;
function countchars(const str: msestring; achar: msechar): integer; overload;
function getcharpos(const str: msestring; achar: msechar): integerarty;

function strscan(const Str: PChar; Chr: Char): PChar; overload;
function strscan(const str: string; chr: char): integer; overload;
function msestrscan(const Str: PmseChar; Chr: mseChar): PmseChar; overload;
function msestrscan(const str: msestring; chr: msechar): integer; overload;

function StrLScan(const Str: PChar; Chr: Char; len: integer): PChar;
function mseStrLScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;

function StrNScan(const Str: PChar; Chr: Char): PChar;
function StrLNScan(const Str: PChar; Chr: Char; len: integer): PChar;
function mseStrNScan(const Str: PmseChar; Chr: mseChar): PmseChar;
function mseStrLNScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;

function StrRScan(const Str: PChar; Chr: Char): PChar;
function StrLRScan(const Str: PChar; Chr: Char; len: integer): PChar;
function mseStrRScan(const Str: PmseChar; Chr: mseChar): PmseChar; overload;
function msestrrscan(const str: msestring; chr: msechar): integer; overload;
function mseStrLRScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;

function mseStrLNRScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;

function StrLComp(const Str1, Str2: PChar; len: integer): Integer;
 
function mseStrComp(const Str1, Str2: PmseChar): Integer;
function mseStrLComp(const Str1, Str2: PmseChar; len: integer): Integer;
function mseStrLIComp(const Str1, upstr: PmseChar; len: integer): Integer;
                //ascii caseinsensitive, upstr muss upcase sein
function StrLIComp(const Str1, upstr: PChar; len: integer): Integer;
                //ascii caseinsensitive, upstr muss upcase sein
function startsstr(substring,s: pchar): boolean; overload;
function startsstr(const substring,s: string): boolean; overload;
function msestartsstr(substring,s: pmsechar): boolean; overload;
function msestartsstr(const substring,s: msestring): boolean; overload;

function isemptystring(const s: pchar): boolean; overload;
function isemptystring(const s: pmsechar): boolean; overload;
function isnamechar(achar: char): boolean; overload;
function isnamechar(achar: msechar): boolean; overload;
            //true if achar in 'a'..'z','A'..'Z','0'..'9','_';

function strlcopy(const str: pchar; len: integer): ansistring;
                       //nicht nullterminiert
function msestrlcopy(const str: pmsechar; len: integer): msestring;
                       //nicht nullterminiert
function psubstr(const start,stop: pchar): string;

function msePosEx(const SubStr, S: msestring; Offset: Cardinal = 1): Integer;

function mselowercase(const s: msestring): msestring;
function mseuppercase(const s: msestring): msestring;

function msestartstr(const atext: msestring; trenner: msechar): msestring;


function charuppercase(const c: char): char; overload;
function charuppercase(const c: msechar): msechar; overload;
function struppercase(const s: string): string; overload;
function struppercase(const s: msestring): msestring; overload;
function struppercase(const s: lmsestringty): msestring; overload;
function struppercase(const s: lstringty): string; overload;

function mseremspace(const s: msestring): msestring;
    //entfernt alle space und steuerzeichen
function removelinebreaks(const s: msestring): msestring;
    //replaces linebreaks with space

procedure msestrtotvarrec(const value: ansistring; out varrec: tvarrec); overload;
procedure msestrtotvarrec(const value: msestring; out varrec: tvarrec); overload;

function tvarrectoansistring(value: tvarrec): ansistring;
function tvarrectomsestring(value: tvarrec): msestring;

procedure stringaddref(var str: string); overload;
procedure stringaddref(var str: msestring); overload;

procedure reallocstring(var value: ansistring); overload;
                //macht datenkopie ohne free
procedure reallocstring(var value: msestring); overload;
                //macht datenkopie ohne free
procedure reallocarray(var value; elementsize: integer); overload;
                //macht datenkopie ohne free
procedure resizearray(var value; newlength, elementsize: integer);
                //ohne finalize

procedure wordatindex(const value: msestring; const index: integer;
                          out first,pastlast: pmsechar;
                     const delimchars: msestring {= defaultmsedelimchars)}); overload;
                          //index = 0..length(value)-1
function wordatindex(const value: msestring; const index: integer;
            const delimchars: msestring {= defaultmsedelimchars}): msestring; overload;

function quotestring(const value: string; quotechar: char): string; overload;
function quotestring(const value: msestring; quotechar: msechar): msestring; overload;
function extractquotedstr(const value: msestring): msestring;
                //entfernt vorhandene paare ' und "

function checkfirstchar(const value: string; achar: char): pchar;
           //nil wenn erster char nicht space <> achar, ^achar sonst
function firstline(atext: msestring): msestring;
function lastline(atext: msestring): msestring;
function textendpoint(const start: pointty; const text: msestring): pointty;
procedure textdim(const atext: msestring; out firstx,lastx,y: integer);

function shrinkpathellipse(var value: msestring): boolean;
function shrinkstring(const value: msestring; maxcharcount: integer): msestring;

function charstring(ch: char; count: integer): string; overload;
function charstring(ch: msechar; count: integer): msestring; overload;
function countleadingchars(const str: msestring;  char: msechar): integer; overload;
function countleadingchars(const str: string; char: char): integer; overload;
          //-1 = leer
function breaklines(const source: string): stringarty; overload;
function breaklines(const source: msestring): msestringarty; overload;
procedure splitstring(source: string;
                     var dest: stringarty; separator: char = c_tab;
                     trim: boolean = false); overload;
procedure splitstring(source: msestring;
                     var dest: msestringarty; separator: msechar = c_tab;
                     trim: boolean = false); overload;
          //length(dest) = 0 -> es werden die noetigen stellen erzeugt
          // sonst length(dest) <= length(dest uebergeben),
          // ganzer rest im letzten string, falls mehr vorhandene teile als
          // uebergebene strings
function splitstring(source: string; separator: char = c_tab;
                     trim: boolean = false): stringarty; overload;
function splitstring(source: msestring; separator: msechar = c_tab;
                     trim: boolean = false): msestringarty; overload;

procedure splitstringquoted(const source: string; out dest: stringarty;
                       quotechar: char = '"'; separator: char = #0); overload;
procedure splitstringquoted(const source: msestring; out dest: msestringarty;
                       quotechar: msechar = '"'; separator: msechar = #0); overload;
           //separator = #0 -> ' ' and c_tab for separators

function concatstrings(const source: msestringarty;
              const separator: msestring = ' '): msestring; overload;
function concatstrings(const source: stringarty;
              const separator: string = ' '): string; overload;

function parsecommandline(const s: pchar): stringarty;

function stringtoutf8(const value: msestring): utf8string;
function utf8tostring(const value: utf8string): msestring;
function stringtolatin1(const value: msestring): string;
function latin1tostring(const value: string): msestring;

type
// getkeystringfuncty = function (const index: integer;
//        var astring: msestring): boolean of object;
                           //false if no value
 getkeystringfuncty = function (const index: integer): msestring of object;

 locatestringoptionty = (lso_casesensitive,lso_exact);
 locatestringoptionsty = set of locatestringoptionty;

function locatestring(const afilter: msestring; const getkeystringfunc: getkeystringfuncty;
           const options: locatestringoptionsty;
           const count: integer; var aindex: integer): boolean;
               //true if found

implementation
uses
 sysutils,msedatalist,msesysintf;

function locatestring(const afilter: msestring; const getkeystringfunc: getkeystringfuncty;
           const options: locatestringoptionsty;
           const count: integer; var aindex: integer): boolean;
               //true if found
type
 locateinfoty = record
  filter: msestring;
  casesensitive: boolean;
  exact: boolean;
  result: boolean;
 end;

var
 locateinfo: locateinfoty;

// index1: integer;

 procedure check(index1: integer);
 var
  str1: msestring;
 begin
  str1:= getkeystringfunc(index1);
  with locateinfo do begin
   if exact then begin
    if casesensitive then begin
     result:= msecomparestr(filter,str1) = 0;
    end
    else begin
     result:= msecomparetext(filter,str1) = 0;
    end;
   end
   else begin
    if casesensitive then begin
     result:= msecomparestrlen(filter,str1) = 0;
    end
    else begin
     result:= msecomparetextlen(filter,str1) = 0;
    end;
   end;
   if result then begin
    aindex:= index1;
   end;
  end;
 end;

var
 int1,int2: integer;
begin
 if afilter = '' then begin
  result:= count > 0;
  if result then begin
   aindex:= 0;
  end;
 end
 else begin
  with locateinfo do begin
   casesensitive:= lso_casesensitive in options;
   if casesensitive then begin
    filter:= afilter;
   end
   else begin
    filter:= mseuppercase(afilter);
   end;
   result:= false;
   int1:= aindex;
   if int1 < 0 then begin
    int1:= 0;
   end;
   if int1 >= count then begin
    int1:= count - 1;
   end;
   if int1 >= 0 then begin
    exact:= true;
    for int2:= int1 to count - 1 do begin
     check(int2);
     if result then begin
      break;
     end;
    end;
    if not result then begin
     for int2:= int1-1 downto 0 do begin
      check(int2);
      if result then begin
       break;
      end;
     end;
     if not result and not (lso_exact in options) then begin
      exact:= false;
      for int2:= int1 to count - 1 do begin
       check(int2);
       if result then begin
        break;
       end;
      end;
      if not result then begin
       for int2:= int1 - 1 downto 0 do begin
        check(int2);
        if result then begin
         break;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  result:= locateinfo.result;
 end;
end;

function stringtoutf8(const value: msestring): utf8string;
var
 int1: integer;
 po1: pchar;
 wo1,wo2: word;
begin
 setlength(result,length(value)*3); //max
 po1:= pchar(pointer(result));
 for int1:= 1 to length(value) do begin
  wo1:= word(value[int1]);
  wo2:= wo1 and $ff80;
  if wo2 = 0 then begin
   po1^:= char(wo1);
   inc(po1);
  end
  else begin
   wo2:= wo2 and $f800;
   if wo2 = 0 then begin
    po1^:= char((wo1 shr 6) or $c0);
    inc(po1);
    po1^:= char(wo1 and $3f or $80);
    inc(po1);
   end
   else begin
    po1^:= char((wo1 shr 12) or $e0);
    inc(po1);
    po1^:= char((wo1 shr 6) and $3f or $80);
    inc(po1);
    po1^:= char(wo1 and $3f or $80);
    inc(po1);
   end;
  end;
 end;
 setlength(result,po1-pchar(pointer(result)));
end;

function utf8tostring(const value: utf8string): msestring;
var
 int1,int2: integer;
 by1: byte;
 po1: pmsechar;
begin
 setlength(result,length(value)); //max
 po1:= pmsechar(pointer(result));
 int1:= 1;
 int2:= length(value);
 while int1 <= int2 do begin
  by1:= byte(value[int1]);
  inc(int1);
  if by1 < $80 then begin //1 byte
   po1^:= msechar(by1);
  end
  else begin
   if by1 < $e0 then begin //2 byte
    po1^:= msechar(((by1 and $1f) shl word(6)) or byte(value[int1]) and $3f);
    inc(int1);
   end
   else begin
    if (by1 < $f0) and (int1 < int2) then begin //3byte
     po1^:= msechar((by1 shl word(12)) or ((byte(value[int1]) and $3f) shl word(6)) or
            byte(value[int1+1]) and $3f);
     inc(int1,2);
    end
    else begin
     po1^:= msechar($fffd);    //4byte
     inc(int1,3);
    end;
   end;
  end;
  inc(po1);
 end;
 setlength(result,po1-pmsechar(pointer(result)));
end;

function stringtolatin1(const value: msestring): string;
var
 int1: integer;
begin
 setlength(result,length(value));
 for int1:= 1 to length(result) do begin
  result[int1]:= char(value[int1]);
 end;
end;

function latin1tostring(const value: string): msestring;
var
 int1: integer;
begin
 setlength(result,length(value));
 for int1:= 1 to length(result) do begin
  result[int1]:= widechar(value[int1]);
 end;
end;

function psubstr(const start,stop: pchar): string;
var
 int1: integer;
begin
 if (start = nil) or (stop = nil) then begin
  result:= '';
 end
 else begin
  int1:= stop-start;
  setlength(result,int1);
  move(start^,result[1],int1);
 end;
end;

function concatstrings(const source: msestringarty;
        const separator: msestring = ' '): msestring;
var
 int1: integer;
begin
 if length(source) = 0 then begin
  result:= '';
 end
 else begin
  result:= source[0];
  for int1:= 1 to high(source) do begin
   result:= result + separator + source[int1];
  end;
 end;
end;

function concatstrings(const source: stringarty;
        const separator: string = ' '): string;
var
 int1: integer;
begin
 if length(source) = 0 then begin
  result:= '';
 end
 else begin
  result:= source[0];
  for int1:= 1 to high(source) do begin
   result:= result + separator + source[int1];
  end;
 end;
end;

procedure stringaddref(var str: string);
var
 po1: pinteger;
begin
 if pointer(str) <> nil then begin
  po1:= pinteger(pchar(pointer(str))-8);
  if po1^ >= 0 then begin
   inc(po1^);
  end;
 end;
end;

procedure stringaddref(var str: msestring);
var
 po1: pinteger;
begin
 if pointer(str) <> nil then begin
{$ifndef msestringsarenotrefcounted}
  po1:= pinteger(pchar(pointer(str))-8);
  if po1^ >= 0 then begin
   inc(po1^);
  end;
{$else}
  reallocstring(str); //delphi widestrings are not refcounted
{$endif}
 end;
end;

procedure splitstringquoted(const source: string; out dest: stringarty;
                       quotechar: char = '"'; separator: char = #0);
var
 po1,po2: pchar;
 count: integer;
 str1: string;

 procedure addsubstring;
 var
  int1: integer;
 begin
  if po1 <> po2 then begin
   int1:= length(str1);
   setlength(str1,int1+(po1-po2));
   move(po2^,str1[int1+1],(po1-po2)*sizeof(char));
  end;
 end;

begin
 dest:= nil;
 po1:= pointer(source);
 if po1 <> nil then begin
  count:= 0;
  while po1^ <> #0 do begin
   if separator = #0 then begin
    while (po1^ = ' ') or (po1^ = c_tab) do begin
     inc(po1);
    end;
   end
   else begin
    while true do begin
     if po1^ = quotechar then begin
      break;
     end;
     po2:= po1;
     while (po1^ <> separator) and (po1^ <> #0) do begin
      inc(po1);
     end;
     setstring(str1,po2,po1-po2);
     additem(dest,str1,count);
     if po1^ <> #0 then begin
      inc(po1);
     end
     else begin
      setlength(dest,count);
      exit;
     end;
    end;
   end;
   str1:= '';
   if po1^ <> quotechar then begin
    po2:= po1;
    while (po1^ <> quotechar) and (po1^ <> ' ') and (po1^ <> c_tab) and (po1^ <> #0) do begin
     inc(po1);
    end;
    addsubstring;
   end
   else begin
    while po1^ <> #0 do begin
     inc(po1);    //po1^ = quotechar
     po2:= po1;
     while (po1^ <> quotechar) and (po1^ <> #0) do begin
      inc(po1);
     end;
     if po1^ <> #0 then begin           //       ?
      if (po1+1)^ = quotechar then begin//  "....""...
       inc(po1);                        //        ?
       addsubstring;                    //  "....""...
      end
      else begin                        //       ?
       addsubstring;                    //  "...."....
       inc(po1);                        //        ?
                                        //  "...."....
                                        //  "...."..,..
       if (separator <> #0) then begin
        while (po1^ <> #0) and (po1^ <> separator) do begin
         inc(po1);
        end;
                                        //          ?
                                        //  "...."..,..
        if po1^ = separator then begin
         inc(po1);
        end;
                                        //           ?
                                        //  "...."..,..
       end;
       break;
      end;
     end;
    end;
   end;
   additem(dest,str1,count);
  end;
  setlength(dest,count);
 end;
end;

procedure splitstringquoted(const source: msestring; out dest: msestringarty;
                       quotechar: msechar = '"'; separator: msechar = #0);
var
 po1,po2: pmsechar;
 count: integer;
 str1: msestring;

 procedure addsubstring;
 var
  int1: integer;
 begin
  if po1 <> po2 then begin
   int1:= length(str1);
   setlength(str1,int1+(po1-po2));
   move(po2^,str1[int1+1],(po1-po2)*sizeof(msechar));
  end;
 end;

begin
 dest:= nil;
 po1:= pointer(source);
 if po1 <> nil then begin
  count:= 0;
  while po1^ <> #0 do begin
   if separator = #0 then begin
    while (po1^ = ' ') or (po1^ = c_tab) do begin
     inc(po1);
    end;
   end
   else begin
    while true do begin
     if po1^ = quotechar then begin
      break;
     end;
     po2:= po1;
     while (po1^ <> separator) and (po1^ <> #0) do begin
      inc(po1);
     end;
     setstring(str1,po2,po1-po2);
     additem(dest,str1,count);
     if po1^ <> #0 then begin
      inc(po1);
     end
     else begin
      setlength(dest,count);
      exit;
     end;
    end;
   end;
   str1:= '';
   if po1^ <> quotechar then begin
    po2:= po1;
    while (po1^ <> quotechar) and (po1^ <> ' ') and (po1^ <> c_tab) and (po1^ <> #0) do begin
     inc(po1);
    end;
    addsubstring;
   end
   else begin
    while po1^ <> #0 do begin
     inc(po1);    //po1^ = quotechar
     po2:= po1;
     while (po1^ <> quotechar) and (po1^ <> #0) do begin
      inc(po1);
     end;
     if po1^ <> #0 then begin           //       ?
      if (po1+1)^ = quotechar then begin//  "....""...
       inc(po1);                        //        ?
       addsubstring;                    //  "....""...
      end
      else begin                        //       ?
       addsubstring;                    //  "...."....
       inc(po1);                        //        ?
                                        //  "...."....
                                        //  "...."..,..
       if (separator <> #0) then begin
        while (po1^ <> #0) and (po1^ <> separator) do begin
         inc(po1);
        end;
                                        //          ?
                                        //  "...."..,..
        if po1^ = separator then begin
         inc(po1);
        end;
                                        //           ?
                                        //  "...."..,..
       end;
       break;
      end;
     end;
    end;
   end;
   additem(dest,str1,count);
  end;
  setlength(dest,count);
 end;
end;

function breaklines(const source: string): stringarty;
var
 int1,int2: integer;
begin
 result:= nil;
 splitstring(source,result,c_linefeed);
 for int1:= 0 to high(result) do begin
  int2:= length(result[int1]);
  if (int2 > 0) and (result[int1][int2] = c_return) then begin
   setlength(result[int1],int2-1);
  end;
 end;
end;

function breaklines(const source: msestring): msestringarty;
var
 int1,int2: integer;
begin
 result:= nil;
 splitstring(source,result,c_linefeed);
 for int1:= 0 to high(result) do begin
  int2:= length(result[int1]);
  if (int2 > 0) and (result[int1][int2] = c_return) then begin
   setlength(result[int1],int2-1);
  end;
 end;
end;

procedure splitstring(source: string;
                     var dest: stringarty; separator: char = c_tab;
                     trim: boolean = false);
          // dest = [] -> length(dest) = anzahl vorhandene teile
          // sonst length(dest) <= length(dest uebergeben),
          // ganzer rest im letzten string, fallse mehr vorhandene teile als
          // uebergebene strings
var
 int2,int3: integer;
 po,po1,po2: pchar;
 all: boolean;
 bo1: boolean;

begin
 all:= length(dest) = 0;
 if all then begin
  int2:= countchars(source,separator);
  setlength(dest,int2+1); //maximale zahl
 end
 else begin
  for int2:= 0 to length(dest)-1 do begin
   dest[int2]:= '';
  end;
 end;
 po:= pchar(source);
 int3:= length(source);
 bo1:= false;
 for int2:= 0 to length(dest) - 1 do begin
  if int3 <= 0 then begin
   if bo1 and (int2 < length(dest)) then begin
    setlength(dest,int2+1); //leerer schluss
   end
   else begin
    setlength(dest,int2);
   end;
   break;
  end;
  po2:= po;
  po1:= strlscan(po,separator,int3);
  if (po1 = nil) or (int2 = high(dest)) then begin
   po1:= po + int3;           //rest
   bo1:= false;
  end
  else begin
   bo1:= true;
  end;
  if trim then begin
   po:= strnscan(po,' ');
  end;
  if po <> nil then begin
   dest[int2]:= strlcopy(po,po1-po);
  end;
  if trim and (separator = ' ') then begin
   po1:= strlnscan(po1,separator,int3);
   if po1 = nil then begin
    int3:= 0;
   end;
  end
  else begin
   inc(po1);
  end;
  int3:= int3 - (po1 - po2);
             //verbrauchte stringlaenge
  po:= po1;
 end;
end;

procedure splitstring(source: msestring;
                     var dest: msestringarty; separator: msechar = c_tab;
                     trim: boolean = false);
          // dest = [] -> length(dest) = anzahl vorhandene teile
          // sonst length(dest) <= length(dest uebergeben),
          // ganzer rest im letzten string, fallse mehr vorhandene teile als
          // uebergebene strings
var
 int2,int3: integer;
 po,po1,po2: pmsechar;
 all: boolean;
 bo1: boolean;

begin
 all:= length(dest) = 0;
 if all then begin
  int2:= countchars(source,separator);
  setlength(dest,int2+1); //maximale zahl
 end
 else begin
  for int2:= 0 to length(dest)-1 do begin
   dest[int2]:= '';
  end;
 end;
 po:= pmsechar(source);
 int3:= length(source);
 bo1:= false;
 for int2:= 0 to length(dest) - 1 do begin
  if int3 <= 0 then begin
   if bo1 and (int2 < length(dest)) then begin
    setlength(dest,int2+1); //leerer schluss
   end
   else begin
    setlength(dest,int2);
   end;
   break;
  end;
  po2:= po;
  po1:= msestrlscan(po,separator,int3);
  if (po1 = nil) or (int2 = high(dest)) then begin
   po1:= po + int3;           //rest
   bo1:= false;
  end
  else begin
   bo1:= true;
  end;
  if trim then begin
   po:= msestrnscan(po,' ');
  end;
  if po <> nil then begin
   dest[int2]:= msestrlcopy(po,po1-po);
  end;
  if trim and (separator = ' ') then begin
   po1:= msestrlnscan(po1,separator,int3);
   if po1 = nil then begin
    int3:= 0;
   end;
  end
  else begin
   inc(po1);
  end;
  int3:= int3 - (po1 - po2);
             //verbrauchte stringlaenge
  po:= po1;
 end;
end;

function splitstring(source: string; separator: char = c_tab;
                     trim: boolean = false): stringarty;
begin
 result:= nil;
 splitstring(source,result,separator,trim);
end;

function splitstring(source: msestring; separator: msechar = c_tab;
                     trim: boolean = false): msestringarty;
begin
 result:= nil;
 splitstring(source,result,separator,trim);
end;

function stringfromchar(achar: char; count : integer): string;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 1 to count do begin
  result[int1]:= achar;
 end;
end;

function stringfromchar(achar: msechar; count : integer): msestring;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 1 to count do begin
  result[int1]:= achar;
 end;
end;

function parsecommandline(const s: pchar): stringarty;
var
 po1,po2: pchar;
 count: integer;
 str1: string;

 procedure addsubstring;
 var
  int1,int2: integer;
 begin
 {$ifdef FPC}{$checkpointer off}{$endif}
  int1:= po1-po2;
  int2:= length(str1);
  setlength(str1,int2+int1);
  move(po2^,str1[int2+1],int1);
  po2:= po1;
 {$ifdef FPC}{$checkpointer default}{$endif}
 end;

begin
 result:= nil;
 count:= 0;
 if s <> nil then begin
 {$ifdef FPC}{$checkpointer off}{$endif}
  po1:= s;
  while (po1^ <> #0) and (po1^ = ' ') do begin
   inc(po1);
  end;
  if po1^ <> #0 then begin
   po2:= po1;
   str1:= '';
   while true do begin
    case po1^ of
     ' ',#0: begin
      addsubstring;
      additem(result,str1,count);
      str1:= '';
      while (po1^ <> #0) and (po1^ = ' ') do begin
       inc(po1);
      end;
      if po1^ = #0 then begin
       break;
      end;
      po2:= po1;
     end;
     '"': begin
      addsubstring;
      po2:= po1 + 1;
      repeat
       inc(po1);
       case po1^ of
        '"': begin
         addsubstring;
         inc(po1);
         inc(po2);
         break;
        end;
        '\': begin
         if (po1+1)^ = '"' then begin
          addsubstring;
          inc(po1);
          inc(po2);
         end;
        end;
       end;
      until po1^ = #0;
     end;
     '\': begin
      if ((po1+1)^ < ' ') or ((po1+1)^ in ['"','\']) then begin
       addsubstring;
       inc(po1);
       if po1^ = #0 then begin
        break;
       end;
       inc(po1);
       inc(po2);
      end
      else begin
       inc(po1);
      end;
     end;
     else begin
      inc(po1);
     end;
    end;
   end;
  end;
 {$ifdef FPC}{$checkpointer default}{$endif}
  setlength(result,count);
 end;
end;

function printableascii(const source: string): string; 
                //removes all nonprintablechars and ' '
var
 int1,int2: integer;
 ca1: char;
begin
 setlength(result,length(source));
 int2:= 0;
 for int1:= 1 to length(source) do begin
  ca1:= source[int1];
  if (ca1 > ' ') and (ca1 < #127) then begin
   inc(int2);
   result[int2]:= source[int1];
  end;
 end;
 setlength(result,int2);
end;

function removechar(const source: string; a: char): string;
  //removes all a
var
 int1,int2: integer;
begin
 setlength(result,length(source));
 int2:= 0;
 for int1:= 1 to length(source) do begin
  if source[int1] <> a then begin
   pcharaty(result)^[int2]:= source[int1];
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

procedure removechar1(var dest: string; a: char);
  //removes all a
begin
 dest:= removechar(dest,a);
end;

function removechar(const source: msestring; a: msechar): msestring;
  //removes all a
var
 int1,int2: integer;
begin
 setlength(result,length(source));
 int2:= 0;
 for int1:= 1 to length(source) do begin
  if source[int1] <> a then begin
   pmsecharaty(result)^[int2]:= source[int1];
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

procedure removechar1(var dest: msestring; a: msechar);
  //removes all a
begin
 dest:= removechar(dest,a);
end;

function replacechar(const source: string; a,b: char): string;
  //replaces a by b
begin
 result:= source;
 replacechar1(result,a,b);
end;

procedure replacechar1(var dest: string; a,b: char);
  //replaces a by b
var
 int1: integer;
begin
 uniquestring(dest);
 for int1:= 0 to length(dest)-1 do begin
  if pcharaty(dest)^[int1] = a then begin
   pcharaty(dest)^[int1]:= b;
  end;
 end;
end;

function replacechar(const source: msestring; a,b: msechar): msestring;
  //replaces a by b
begin
 result:= source;
 replacechar1(result,a,b);
end;

procedure replacechar1(var dest: msestring; a,b: msechar);
  //replaces a by b
var
 int1: integer;
begin
 uniquestring(dest);
 for int1:= 0 to length(dest)-1 do begin
  if pmsecharaty(dest)^[int1] = a then begin
   pmsecharaty(dest)^[int1]:= b;
  end;
 end;
end;

procedure replacetext1(var dest: string; index: integer; const a: string);
 //dest will be extended with spaces if necessary
var
 int1,int2: integer;
begin
 uniquestring(dest);
 if length(dest) < index + length(a) then begin
  int1:= length(dest);
  setlength(dest,index+length(a)-1);
  for int2:= int1 to index - 2 do begin
   pcharaty(dest)^[int2]:= ' ';
  end;
 end;
 dec(index);
 int1:= length(a);
 if index < 0 then begin
  int1:= int1 + index;
  index:= 0;
 end;
 for int2:= 0 to int1-1 do begin
  pcharaty(dest)^[int2+index]:= pcharaty(a)^[int2];
 end;
end;

function replacetext(const source: string; index: integer; a: string): string;
begin
 result:= source;
 replacetext1(result,index,a);
end;

procedure replacetext1(var dest: msestring; index: integer; const a: msestring);
 //dest will be extended with spaces if necessary
var
 int1,int2: integer;
begin
 uniquestring(dest);
 if length(dest) < index + length(a) then begin
  int1:= length(dest);
  setlength(dest,index+length(a)-1);
  for int2:= int1 to index - 2 do begin
   pmsecharaty(dest)^[int2]:= ' ';
  end;
 end;
 dec(index);
 int1:= length(a);
 if index < 0 then begin
  int1:= int1 + index;
  index:= 0;
 end;
 for int2:= 0 to int1-1 do begin
  pmsecharaty(dest)^[int2+index]:= pmsecharaty(a)^[int2];
 end;
end;

function replacetext(const source: msestring; index: integer; a: msestring): msestring;
begin
 result:= source;
 replacetext1(result,index,a);
end;

procedure addstringsegment(var dest: msestring; const a,b: pmsechar);
var
 int1,int2: integer;
begin
 int1:= length(dest);
 int2:= b-a;
 setlength(dest,int1 + int2);
 move(a^,dest[int1+1],int2*sizeof(msechar));
end;

function stringsegment(a,b: pmsechar): msestring;
var
 int1: integer;
begin
 int1:= b - a;
 setlength(result,int1);
 move(a^,result[1],int1*sizeof(msechar));
end;

function countleadingchars(const str: msestring;  char: msechar): integer;
var
 int1: integer;
 po1,po2: pmsechar;
begin
 int1:= length(str);
 if int1 > 0 then begin
  po1:= pointer(str);
  po2:= msestrlnscan(po1,' ',int1);
  if po2 = nil then begin
   result:= int1;
  end
  else begin
   result:= po2-po1;
  end;
 end
 else begin
  result:= -1; //leer
 end;
end;

function countleadingchars(const str: string; char: char): integer;
var
 int1: integer;
 po1,po2: pchar;
begin
 int1:= length(str);
 if int1 > 0 then begin
  po1:= pointer(str);
  po2:= strlnscan(po1,' ',int1);
  if po2 = nil then begin
   result:= int1;
  end
  else begin
   result:= po2-po1;
  end;
 end
 else begin
  result:= -1; //leer
 end;
end;

function charstring(ch: char; count: integer): string; overload;
begin
 setlength(result,count);
 for count:= count downto 1 do begin
  result[count]:= ch;
 end;
end;

function charstring(ch: msechar; count: integer): msestring; overload;
begin
 setlength(result,count);
 for count:= count downto 1 do begin
  result[count]:= ch;
 end;
end;
{
function posmse(substring: pmsechar; const s: lmsestringty): pmsechar;
var
 po1: pmsechar;
 int1: integer;
begin
 if (substring <> nil) and (substring^ <> #0) and
               (s.po <> nil) and (s.len > 0) then begin
  result:= msestrlscan(s.po,substring^,s.len);
  int1:= s.len - (s.po-result) - 1;
  if result <> nil then begin
   po1:= result;
   while (substring^ <> #0) and (int1 > 0) do begin
    dec(int1);
    inc(substring);
    inc(po1);
    if po1^ <> substring^ then begin
     break;
    end;
   end;
   if po1^ <> #0 then begin
    result:= nil;
   end;
  end;
 end
 else begin
  result:= nil;
 end;
end;
}
{
function msestrpos(const substr: msestring; const s: msestring): integer;
var
 po1,po2,po3,po4: pmsechar;
begin
 po3:= pmsechar(substr);
 if po3^ <> #0 then begin
  po4:= pmsechar(s);
  repeat
   while (po4^ <> #0) and (po4^ <> po3^) do begin
    inc(po4);
   end;
   po1:= po3;
   po2:= po4;
   while (po1^ <> #0) and (po1^ = po2^) do begin
    inc(po1);
    inc(po2);
   end;
   if po1^ = #0 then begin
    result:= po4 - pmsechar(s) + 1;
    exit;
   end;
   inc(po4);
  until po2^ = #0;
 end;
 result:= 0;
end;

function msetextpos1(const substrlower,substrupper: msestring; const s: msestring): integer;
var
 po1l,po1u,po2,po3l,po3u,po4: pmsechar;
begin
 po3l:= pmsechar(substrlower);
 po3u:= pmsechar(substrupper);
 if po3l^ <> #0 then begin
  po4:= pmsechar(s);
  repeat
   while (po4^ <> #0) and (po4^ <> po3l^) and (po4^ <> po3u^) do begin
    inc(po4);
   end;
   po1l:= po3l;
   po1u:= po3u;
   po2:= po4;
   while (po1l^ <> #0) and ((po1l^ = po2^) or (po1u^ = po2^)) do begin
    inc(po1l);
    inc(po1u);
    inc(po2);
   end;
   if po1l^ = #0 then begin
    result:= po4 - pmsechar(s) + 1;
    exit;
   end;
   inc(po4);
  until po2^ = #0;
 end;
 result:= 0;
end;


function msetextpos(const substr: msestring; const s: msestring): integer;
                     //substr has to be uppercase
begin
 result:= msetextpos1(mseuppercase(substr),mseuppercase(substr),s);
end;
}

function charuppercase(const c: char): char;
begin
 result:= upperchars[c];
end;

function charuppercase(const c: msechar): msechar;
begin
 if ord(c) < $100 then begin
  result:= msechar(upperchars[char(c)]);
 end
 else begin
  result:= c;
 end;
end;

function struppercase(const s: string): string; overload;
var
 int1,int2: integer;
begin
 int1:= length(s);
 setlength(result,int1);
 for int2:= 0 to int1 - 1 do begin
  pcharaty(result)^[int2]:= upperchars[pcharaty(s)^[int2]];
 end;
end;

function struppercase(const s: msestring): msestring; overload;
var
 ch1: msechar;
 int1: integer;
 po1,po2: pmsecharaty;
begin
 setlength(result,length(s));
 po1:= pointer(s);
 po2:= pointer(result);
 for int1:= 0 to length(s) - 1 do begin
  ch1:= po1^[int1];
  if (ch1 >= 'a') and (ch1 <= 'z') then begin
   inc(ch1,ord('A') - ord('a'));
  end;
  po2^[int1]:= ch1;
 end;
end;

function struppercase(const s: lmsestringty): msestring; overload;
var
 Ch1: msechar;
 int1: Integer;
 Source, Dest: Pmsechar;
begin
 int1:= s.len;
 setlength(result,int1);
 Source := s.po;
 Dest := Pointer(Result);
 while int1 > 0 do begin
  Ch1 := Source^;
  if (Ch1 >= 'a') and (Ch1 <= 'z') then Dec(Ch1, 32);
  Dest^ := Ch1;
  Inc(Source);
  Inc(Dest);
  Dec(int1);
 end;
end;

function struppercase(const s: lstringty): string; overload;
var
 int1: integer;
begin
 setlength(result,s.len);
 for int1:= 0 to s.len - 1 do begin
  pcharaty(result)^[int1]:= upperchars[pcharaty(s.po)^[int1]];
 end;
end;

function lstringtostring(const value: lmsestringty): msestring; overload;
begin
 setlength(result,value.len);
 move(value.po^,result[1],value.len*sizeof(msechar));
end;

function lstringtostring(const value: lstringty): string; overload;
begin
 setlength(result,value.len);
 move(value.po^,result[1],value.len*sizeof(char));
end;

procedure stringtolstring(const value: string; var{out} res: lstringty);
begin
 res.po:= pointer(value);
 res.len:= length(value);
end;

procedure stringtolstring(const value: msestring; var{out} res: lmsestringty);
begin
 res.po:= pointer(value);
 res.len:= length(value);
end;

function stringtolstring(const value: string): lstringty;
begin
 result.po:= pointer(value);
 result.len:= length(value);
end;

function stringtolstring(const value: msestring): lstringty;
begin
 result.po:= pointer(value);
 result.len:= length(value);
end;

function lstringartostringar(const value: lstringarty): stringarty;
var
 int1: integer;
begin
 setlength(result,length(value));
 for int1:= 0 to high(value) do begin
  with value[int1] do begin
   setstring(result[int1],po,len);
  end;
 end;
end;

procedure nextword(const value: msestring; out res: lmsestringty); overload;
var
 po1: pmsechar;
begin
 res.po:= msestrlscan(pointer(value),' ',length(value));
 res.len:= length(value)-(res.po-pointer(value));
 po1:= msestrlnscan(res.po,' ',res.len);
 if po1 <> nil then begin
  res.len:= po1-res.po;
 end;
end;

procedure nextword(const value: string; out res: lstringty); overload;
var
 po1: pchar;
begin
 res.po:= strlnscan(pointer(value),' ',length(value));
 res.len:= length(value)-(res.po-pointer(value));
 po1:= strlscan(res.po,' ',res.len);
 if po1 <> nil then begin
  res.len:= po1-res.po;
 end;
end;

procedure nextword(var value: lmsestringty; out res: lmsestringty); overload;
var
 po1: pmsechar;
 int1: integer;
begin
 res.po:= msestrlnscan(value.po,' ',value.len);
 if res.po = nil then begin
  int1:= value.len;
 end
 else begin
  int1:= res.po-value.po;
 end;
 res.len:= value.len-int1;
 po1:= msestrlscan(res.po,' ',res.len);
 if po1 <> nil then begin
  res.len:= po1-res.po;
 end;
 int1:= int1 + res.len;
 inc(value.po,int1);
 dec(value.len,int1);
end;

procedure nextword(var value: lstringty; out res: lstringty); overload;
var
 po1: pchar;
 int1: integer;
begin
 res.po:= strlnscan(value.po,' ',value.len);
 if res.po = nil then begin
  int1:= value.len;
 end
 else begin
  int1:= res.po-value.po;
 end;
 res.len:= value.len-int1;
 po1:= strlscan(res.po,' ',res.len);
 if po1 <> nil then begin
  res.len:= po1-res.po;
 end;
 int1:= int1 + res.len;
 inc(value.po,int1);
 dec(value.len,int1);
end;

procedure nextword(var value: lstringty; out res: string); overload;
var
 lstr1: lstringty;
begin
 nextword(value,lstr1);
 setstring(res,lstr1.po,lstr1.len);
end;

procedure lstringgoback(var value: lstringty; const res: lstringty);
begin
 dec(value.po,res.len);
 inc(value.len,res.len);
end;

function nextquotedstring(var value: lstringty; out res: string): boolean;
var
 po1: pchar;
 int1,int2,int3: integer;
begin
 result:= false;
 res:= '';
 po1:= strlnscan(value.po,' ',value.len);
 if po1 = nil then begin
  int1:= value.len;
 end
 else begin
  int1:= po1-value.po;
 end;
 if (po1 <> nil) and (po1^ = '''') then begin
  result:= true;
  inc(po1);
  int2:= 0;
  int3:= value.len-int1;
  setlength(res,int3); //maximum
  while po1^ <> #0 do begin
   if po1^ <> '''' then begin
    inc(int2);
    res[int2]:= po1^;
   end
   else begin
    inc(po1);
    if po1^ = '''' then begin
     inc(int2);
     res[int2]:= po1^;
    end
    else begin
     break;
    end;
   end;
   inc(po1);
  end;
  setlength(res,int2);
  int1:= po1-value.po;
 end;
 inc(value.po,int1);
 dec(value.len,int1);
end;

function shrinkpathellipse(var value: msestring): boolean;
const
 ellipsis = '...' + pathdelim;
var
 po1,po2: pmsechar;
 int1,int2: integer;
begin
 result:= false;
 int1:= pos(ellipsis,value);
 if int1 = 0 then begin
  int1:= pos(pathdelim,value);
  if int1 > 0 then begin
   inc(int1);                //ellipsenstart
   int2:= int1;              //ellipsenend;
  end
  else exit;         //shrink unmoeglich
 end
 else begin
  int2:= int1 + length(ellipsis);
 end;
 po1:= @value[int2]; //ende ellipse
 po2:= msestrlscan(po1,pathdelim,length(value)-int2);
 if po2 <> nil then begin
  inc(po2);
  value:= copy(value,1,int1-1) + ellipsis + copy(value,int2 + (po2-po1),bigint);
  result:= true;
 end;
end;

function shrinkstring(const value: msestring; maxcharcount: integer): msestring;
begin
 result:= value;
 repeat
 until (length(result) <= maxcharcount) or not shrinkpathellipse(result);
end;

function checkfirstchar(const value: string; achar: char): pchar;
           //nil wenn ester char nicht space <> achar, ^achar sonst
begin
 result:= strlnscan(pointer(value),' ',length(value));
 if result <> nil then begin
  if result^ <> achar then begin
   result:= nil;
  end;
 end;
end;

function lastline(atext: msestring): msestring;
var
 po1: pmsechar;
begin
 po1:= msestrlrscan(pmsechar(atext),c_linefeed,length(atext));
 if po1 = nil then begin
  result:= atext;
 end
 else begin
  result:= po1;
 end;
end;

function firstline(atext: msestring): msestring;
var
 po1: pmsechar;
begin
 po1:= msestrlscan(pmsechar(atext),c_linefeed,length(atext));
 if po1 = nil then begin
  result:= atext;
 end
 else begin
  dec(po1);
  if po1 >= @atext[1] then begin
   if po1^ <> c_return then begin
    inc(po1);
   end;
  end
  else begin
   inc(po1);
  end;
  setlength(result,po1-pmsechar(@atext[1]));
  move(po1^,result[1],length(result)*sizeof(result[1]));
 end;
end;

procedure textdim(const atext: msestring; out firstx,lastx,y: integer);
begin
 Y:= countchars(atext,c_linefeed);
 if Y = 0 then begin
  firstx:= length(atext);
  lastx:= firstx;
 end
 else begin
  lastx:= length(lastline(atext));
  firstx:= length(firstline(atext));
 end;
end;

function textendpoint(const start: pointty; const text: msestring): pointty;
var
 y: integer;
begin
 y:= countchars(text,c_linefeed);
 result.y:= start.y + y;
 if y = 0 then begin
  result.x:= start.x + length(text);
 end
 else begin
  result.x:= length(lastline(text));
 end;
end;

function encodesearchoptions(caseinsensitive: boolean = false;
                        wholeword: boolean = false): searchoptionsty;
begin
 result:= [];
 if caseinsensitive then include(result,so_caseinsensitive);
 if wholeword then include(result,so_wholeword);
end;

function quotestring(const value: string; quotechar: char): string; overload;
var
 int1,int2: integer;
 ch1: char;
begin
 setlength(result,length(value)*2+2);
 int2:= 2;
 result[1]:= quotechar;
 for int1:= 1 to length(value) do begin
  ch1:= value[int1];
  result[int2]:= ch1;
  inc(int2);
  if ch1 = quotechar then begin
   result[int2]:= ch1;
   inc(int2);
  end;
 end;
 result[int2]:= quotechar;
 setlength(result,int2);
end;

function quotestring(const value: msestring; quotechar: msechar): msestring; overload;
var
 int1,int2: integer;
 ch1: msechar;
begin
 setlength(result,length(value)*2+2);
 int2:= 2;
 result[1]:= quotechar;
 for int1:= 1 to length(value) do begin
  ch1:= value[int1];
  result[int2]:= ch1;
  inc(int2);
  if ch1 = quotechar then begin
   result[int2]:= ch1;
   inc(int2);
  end;
 end;
 result[int2]:= quotechar;
 setlength(result,int2);
end;

function extractquotedstr(const value: msestring): msestring;
                //entfernt vorhandene paare ' und "
begin
 if (length(value) > 1) and
    ((value[1] = '''') and (value[length(value)] = '''') or
     (value[1] = '"') and (value[length(value)] = '"')) then begin
  result:= copy(value,2,length(value)-2);
 end
 else begin
  result:= value;
 end;
end;


procedure wordatindex(const value: msestring; const index: integer;
                          out first,pastlast: pmsechar;
                     const delimchars: msestring {= defaultmsedelimchars});

 function checkdelimchars(achar: msechar): boolean;
 var
  po1: pmsechar;
 begin
  po1:= pmsechar(delimchars);
  result:= false;
  while po1^ <> #0 do begin
   if po1^ = achar then begin
    result:= true;
    break;
   end;
   inc(po1);
  end;
 end;

var
 int1: integer;
 po1: pmsechar;
begin
 first:= nil;
 pastlast:= nil;
 if (index >= 0) and (index < length(value)) then begin
  first:= pmsechar(pointer(value)) + index;
  po1:= first;
  for int1:= index downto 0 do begin
   if checkdelimchars(po1^) then begin
    if po1 = first then begin
     first:= nil;
     exit;
    end;
    break;
   end;
   dec(po1);
  end;
  pastlast:= first + 1;
  first:= po1 + 1;
  for int1:= length(value) - index - 2 downto 0 do begin
   if checkdelimchars(pastlast^) then begin
    break;
   end;
   inc(pastlast);
  end;
 end;
end;

function wordatindex(const value: msestring; const index: integer;
            const delimchars: msestring {= defaultmsedelimchars}): msestring;
var
 po1,po2: pmsechar;
begin
 wordatindex(value,index,po1,po2,delimchars);
 result:= copy(msestring(po1),1,po2-po1);
end;

function msestringsearch(const substring,s: msestring; start: integer;
                 options: searchoptionsty; const substringupcase: msestring = ''): integer;
var
 int1,int2: integer;
 ch1,ch2: msechar;
 str1,str2: msestring;

begin
 result:= 0;
 if start = 0 then begin
  start:= 1;
 end;
 if (length(substring) = 0) or (length(s) = 0) then begin
  exit;
 end;
 if so_wholeword in options then begin
  exclude(options,so_wholeword);
  result:= start;
  repeat
   result:= msestringsearch(substring,s,result,options,substringupcase);
   if result <> 0 then begin
//    if ((result = 1) or (s[result-1] = ' ') or (s[result-1] = c_tab)) then begin
    if (result = 1) or not isnamechar(s[result-1]) then begin
     if (result + length(substring) > length(s)) then begin
      break;
     end
     else begin
//      ch1:= s[result + length(substring)];
//      if (ch1 = ' ') or (ch1 = c_tab) then begin
      if not isnamechar(s[result + length(substring)]) then begin
       break; //io
      end
      else begin
       inc(result); //kein ganzes wort
      end;
     end;
    end
    else begin
     inc(result);
    end;
   end
   else begin
    break;
   end;
  until result > length(s);
 end
 else begin
  if so_caseinsensitive in options then begin
   if substringupcase = '' then begin
    str1:= mseuppercase(substring);
    str2:= mselowercase(substring);
   end
   else begin
    str1:= substringupcase;
    str2:= substring;
   end;
   ch2:= str1[1];
   ch1:= str2[1];
   for int1:= start to length(s) do begin
    if (s[int1] = ch1) or (s[int1] = ch2) then begin
     result:= int1-1;
     for int2:= 1 to length(str1) do begin
      if (s[result+int2] <> str1[int2]) and
             (s[result+int2] <> str2[int2]) then begin
       result:= -1;
       break;
      end;
     end;
     inc(result);
    end;
    if result <> 0 then begin
     break;
    end;
   end
  end
  else begin
   ch1:= substring[1];
   for int1:= start to length(s) do begin
    if s[int1] = ch1 then begin
     result:= int1-1;
     for int2:= 1 to length(substring) do begin
      if s[result+int2] <> substring[int2] then begin
       result:= -1;
       break;
      end;
     end;
     inc(result);
    end;
    if result <> 0 then begin
     break;
    end;
   end
  end;
 end;
end;

function stringsearch(const substring,s: ansistring; start: integer;
                      options: searchoptionsty;
                      const substringupcase: ansistring = ''): integer; overload;
var
 int1,int2: integer;
 ch1,ch2: char;
 str1,str2: ansistring;

begin
 result:= 0;
 if start = 0 then begin
  start:= 1;
 end;
 if (length(substring) = 0) or (length(s) = 0) then begin
  exit;
 end;
 if so_wholeword in options then begin
  exclude(options,so_wholeword);
  result:= start;
  repeat
   result:= stringsearch(substring,s,result,options,substringupcase);
   if result <> 0 then begin
//    if ((result = 1) or (s[result-1] = ' ') or (s[result-1] = c_tab)) then begin
    if (result = 1) or not isnamechar(s[result-1]) then begin
     if (result + length(substring) > length(s)) then begin
      break;
     end
     else begin
//      ch1:= s[result + length(substring)];
//      if (ch1 = ' ') or (ch1 = c_tab) then begin
      if not isnamechar(s[result + length(substring)]) then begin
       break; //io
      end
      else begin
       inc(result); //kein ganzes wort
      end;
     end;
    end
    else begin
     inc(result);
    end;
   end
   else begin
    break;
   end;
  until result > length(s);
 end
 else begin
  if so_caseinsensitive in options then begin
   if substringupcase = '' then begin
    str1:= uppercase(substring);
    str2:= lowercase(substring);
   end
   else begin
    str1:= substringupcase;
    str2:= substring;
   end;
   ch2:= str1[1];
   ch1:= str2[1];
   for int1:= start to length(s) do begin
    if (s[int1] = ch1) or (s[int1] = ch2) then begin
     result:= int1-1;
     for int2:= 1 to length(str1) do begin
      if (s[result+int2] <> str1[int2]) and
             (s[result+int2] <> str2[int2]) then begin
       result:= -1;
       break;
      end;
     end;
     inc(result);
    end;
    if result <> 0 then begin
     break;
    end;
   end
  end
  else begin
   ch1:= substring[1];
   for int1:= start to length(s) do begin
    if s[int1] = ch1 then begin
     result:= int1-1;
     for int2:= 1 to length(substring) do begin
      if s[result+int2] <> substring[int2] then begin
       result:= -1;
       break;
      end;
     end;
     inc(result);
    end;
    if result <> 0 then begin
     break;
    end;
   end
  end;
 end;
end;

function msePosEx(const SubStr, S: msestring; Offset: Cardinal = 1): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

procedure reallocstring(var value: ansistring);
                //macht datenkopie ohne free
var
 po1: pointer;
 int1: integer;
begin
 po1:= pointer(value);
 if po1 <> nil then begin
  int1:= length(value);
  pointer(value):= nil;
  if int1 > 0 then begin
   setlength(value,int1);
   move(po1^,pointer(value)^,int1);
  end;
 end;
end;

procedure reallocstring(var value: msestring);
                //macht datenkopie ohne free
var
 po1: pointer;
 int1: integer;
begin
 po1:= pointer(value);
 if po1 <> nil then begin
  int1:= length(value);
  pointer(value):= nil;
  if int1 > 0 then begin
   setlength(value,int1);
   move(po1^,pointer(value)^,int1*sizeof(msechar));
  end;
 end;
end;

procedure reallocarray(var value; elementsize: integer); overload;
                //macht datenkopie ohne free
var
 po1,po2: ^longword;
 lwo1: longword;
begin
 if pointer(value) <> nil then begin
  lwo1:= length(bytearty(value))*elementsize + 8;
  getmem(po1,lwo1);
  po1^:= 1; //refcount
  inc(po1);
  po2:= pointer(value);
  dec(po2);
  move(po2^,po1^,lwo1-4); //size+data
  inc(po1);
  pointer(value):= po1;
 end;
end;

procedure resizearray(var value; newlength, elementsize: integer);
var
 po1: ^longword;
 lwo1,lwo2: longword;
begin
 if pointer(value) <> nil then begin
  po1:= pointer(value);
  lwo1:= newlength*elementsize;
  if po1 <> nil then begin
   dec(po1);
   {$ifdef FPC}
   lwo2:= (po1^+1)*cardinal(elementsize);
   {$else}
   lwo2:= po1^*cardinal(elementsize);
   {$endif}
   dec(po1);
  end
  else begin
   lwo2:= 0;
  end;
  if lwo1 = 0 then begin
   dispose(po1);
   pointer(value):= nil;
  end
  else begin
   reallocmem(po1,lwo1 + 2*sizeof(longint));
   inc(po1);
   {$ifdef FPC}
   po1^:= newlength-1;
   {$else}
   po1^:= newlength;
   {$endif}
   inc(po1);
   pointer(value):= po1;
   if lwo1 > lwo2 then begin
    fillchar((pchar(po1)+lwo2)^,lwo1-lwo2,0);
   end;
  end;
 end;
end;

procedure msestrtotvarrec(const value: ansistring; out varrec: tvarrec);
begin
 varrec.vtype:= vtansistring;
 varrec.vansistring:= pointer(value);
end;

procedure msestrtotvarrec(const value: msestring; out varrec: tvarrec);
begin
 varrec.vtype:= vtwidestring;
 varrec.vwidestring:= pointer(value); //msestringimplementation
end;

function tvarrectoansistring(value: tvarrec): ansistring;
begin
 result:= ansistring(value.vansistring^);
end;

function tvarrectomsestring(value: tvarrec): msestring;
begin
 result:= msestring(value.vwidestring^); //msestringimplementation
end;

function processeditchars(var value: msestring; stripcontrolchars: boolean): integer;
               //bringt -anzahl rueckwaerts gefressene zeichen, -grosse zahl bei c_return
var
 int1,int2,int3: integer;
 str1: msestring;
 ch1: msechar;
begin
 setlength(str1,length(value));
 int2:= 0;
 int3:= 1;
 for int1:= 1 to length(value) do begin
  ch1:= value[int1];
  if ch1 = c_return then begin
   int2:= -bigint div 2;
   int3:= 1;
  end
  else begin
   if ch1 = c_backspace then begin
    dec(int3);
    if int3 <= 0 then begin
     dec(int2);
     inc(int3);
    end;
   end
   else begin
    if not stripcontrolchars or (ord(ch1) >= ord(' ')) or (ch1 = c_tab) then begin
     str1[int3]:= ch1;
     inc(int3);
    end;
   end;
  end;
 end;
 setlength(str1,int3-1);
 value:= str1;
 result:= int2;
end;

function mseextractprintchars(const value: msestring): msestring;
var
 int1,int2: integer;
 ch1: msechar;
begin
 setlength(result,length(value));
 int2:= 0;
 for int1:= 1 to length(value) do begin
  ch1:= value[int1];
  if (ch1 >= ' ') and (ch1 <> c_delete) then begin
   pmsecharaty(pointer(result))^[int2]:= ch1;
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

function countchars(const str: string; achar: char): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = achar then begin
   inc(result);
  end;
 end;
end;

function countchars(const str: msestring; achar: msechar): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = achar then begin
   inc(result);
  end;
 end;
end;

function getcharpos(const str: msestring; achar: msechar): integerarty;
var
 count: integer;
 int1: integer;
begin
 result:= nil;
 count:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = achar then begin
   additem(result,int1,count);
  end;
 end;
 setlength(result,count);
end;

function findchar(const str: string; achar: char): integer;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = achar then begin
   result:= int1;
   exit;
  end;
 end;
end;

function findchar(const str: msestring; achar: msechar): integer;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = achar then begin
   result:= int1;
   exit;
  end;
 end;
end;

function findchars(const str: string; const achars: string): integer;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
 po1: pchar;
begin
 result:= 0;
 po1:= pchar(str);
 while po1^ <> #0 do begin
  for int1:= 1 to length(achars) do begin
   if achars[int1] = po1^ then begin
    result:= po1-pchar(str)+1;
    exit;
   end;
  end;
  inc(po1);
 end;
end;

function findchars(const str: msestring; const achars: msestring): integer;
  //bringt index des ersten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
 po1: pmsechar;
begin
 result:= 0;
 po1:= pmsechar(str);
 while po1^ <> #0 do begin
  for int1:= 1 to length(achars) do begin
   if achars[int1] = po1^ then begin
    result:= po1-pmsechar(str)+1;
    exit;
   end;
  end;
  inc(po1);
 end;
end;

function findlastchar(const str: string; achar: char): integer;
  //bringt index des letzten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
begin
 result:= 0;
 for int1:= length(str) downto 1 do begin
  if str[int1] = achar then begin
   result:= int1;
   exit;
  end;
 end;
end;

function findlastchar(const str: msestring; achar: msechar): integer;
  //bringt index des letzten vorkommens von zeichen in string, 0 wenn nicht gefunden
var
 int1: integer;
begin
 result:= 0;
 for int1:= length(str) downto 1 do begin
  if str[int1] = achar then begin
   result:= int1;
   exit;
  end;
 end;
end;

function StrLScan(const Str: PChar; Chr: Char; len: integer): PChar;
var
 int1: integer;
 po1: pcharaty;
begin
 result:= nil;
 if str <> nil then begin
  po1:= pointer(str);
  for int1:= 0 to len - 1 do begin
   if po1^[int1] = chr then begin
    result:= @(po1^[int1]);
    break;
   end;
  end;
 end;
end;

function mseStrLScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;
var
 int1: integer;
 po1: pmsecharaty;
begin
 result:= nil;
 if str <> nil then begin
  po1:= pointer(str);
  for int1:= 0 to len - 1 do begin
   if po1^[int1] = chr then begin
    result:= @(po1^[int1]);
    break;
   end;
  end;
 end;
end;

function StrLNScan(const Str: PChar; Chr: Char; len: integer): PChar;
var
 int1: integer;
 po1: pcharaty;
begin
 result:= nil;
 if str <> nil then begin
  po1:= pointer(str);
  for int1:= 0 to len - 1 do begin
   if po1^[int1] <> chr then begin
    result:= @(po1^[int1]);
    break;
   end;
  end;
 end;
end;

function mseStrLNScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;
var
 int1: integer;
 po1: pmsecharaty;
begin
 result:= nil;
 if str <> nil then begin
  po1:= pointer(str);
  for int1:= 0 to len - 1 do begin
   if po1^[int1] <> chr then begin
    result:= @(po1^[int1]);
    break;
   end;
  end;
 end;
end;

function strscan(const str: string; chr: char): integer; overload;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = chr then begin
   result:= int1;
   break;
  end;
 end;
end;

function msestrscan(const str: msestring; chr: msechar): integer; overload;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 1 to length(str) do begin
  if str[int1] = chr then begin
   result:= int1;
   break;
  end;
 end;
end;

function StrScan(const Str: PChar; Chr: Char): PChar;
var
 po1: pchar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
   inc(po1);
  end;
 end;
end;

function mseStrScan(const Str: PmseChar; Chr: mseChar): Pmsechar;
var
 po1: pmsechar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
   inc(po1);
  end;
 end;
end;

function StrNScan(const Str: PChar; Chr: Char): PChar;
var
 po1: pchar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   if po1^ <> chr then begin
    result:= po1;
    break;
   end;
   inc(po1);
  end;
 end;
end;

function mseStrNScan(const Str: PmseChar; Chr: mseChar): Pmsechar;
var
 po1: pmsechar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   if po1^ <> chr then begin
    result:= po1;
    break;
   end;
   inc(po1);
  end;
 end;
end;

function StrRScan(const Str: PChar; Chr: Char): PChar;
var
 po1: pchar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   inc(po1);
  end;
  while po1 > str do begin
   dec(po1);
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function mseStrRScan(const Str: PmseChar; Chr: mseChar): PmseChar;
var
 po1: pmsechar;
begin
 po1:= str;
 result:= nil;
 if po1 <> nil then begin
  while po1^ <> #0 do begin
   inc(po1);
  end;
  while po1 > str do begin
   dec(po1);
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function msestrrscan(const str: msestring; chr: msechar): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= length(str) downto 1 do begin
  if str[int1] = chr then begin
   result:= int1;
   break;
  end;
 end;
end;

function StrLRScan(const Str: PChar; Chr: Char; len: integer): PChar;
var
 po1: pchar;
begin
 result:= nil;
 if str <> nil then begin
  po1:= str+len;
  while po1 > str do begin
   dec(po1);
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function mseStrLRScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;
var
 po1: pmsechar;
begin
 result:= nil;
 if str <> nil then begin
  po1:= str+len;
  while po1 > str do begin
   dec(po1);
   if po1^ = chr then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function mseStrLNRScan(const Str: PmseChar; Chr: mseChar; len: integer): PmseChar;
var
 po1: pmsechar;
begin
 result:= nil;
 if str <> nil then begin
  po1:= str+len;
  while po1 > str do begin
   dec(po1);
   if po1^ <> chr then begin
    result:= po1;
    break;
   end;
  end;
 end;
end;

function mseStrComp(const Str1, Str2: PmseChar): Integer;
var
 po1,po2: pmsechar;
 wo1: word;
begin
 po1:= str1;
 po2:= str2;
 if po1 <> po2 then begin
  repeat
   wo1:= word(po1^) - word(po2^);
   if po2^ = #0 then begin
    break;
   end;
   inc(po1);
   inc(po2);
  until (wo1 <> 0);
  result:= smallint(wo1);
 end
 else begin
  result:= 0;
 end;
end;

function StrLComp(const Str1, Str2: PChar; len: integer): Integer;
var
 po1,po2: pchar;
 by1: byte;
begin
 by1:= 0;
 if len > 0 then begin
  po1:= str1;
  po2:= str2;
  repeat
   by1:= byte(po1^) - byte(po2^);
   if po2^ = #0 then begin
    break;
   end;
   inc(po1);
   inc(po2);
   dec(len);
  until (len <= 0) or (by1 <> 0);
 end;
 result:= shortint(by1);
end;

function mseStrLComp(const Str1, Str2: PmseChar; len: integer): Integer;
var
 po1,po2: pmsechar;
 wo1: word;
begin
 wo1:= 0;
 if len > 0 then begin
  po1:= str1;
  po2:= str2;
  repeat
   wo1:= word(po1^) - word(po2^);
   if po2^ = #0 then begin
    break;
   end;
   inc(po1);
   inc(po2);
   dec(len);
  until (len <= 0) or (wo1 <> 0);
 end;
 result:= smallint(wo1);
end;

function StrLIComp(const Str1, upstr: PChar; len: integer): Integer;
                //ascii caseinsensitive, str2 muss upcase sein
var
 po1,po2: pcharaty;
 int1: integer;
 by1: byte;
begin
 by1:= 0;
 if not((len = 0) or (str1 = upstr)) then begin
  po1:= pointer(str1);
  po2:= pointer(upstr);
  for int1:= 0 to len - 1 do begin
   by1:= ord(upperchars[po1^[int1]])-ord(po2^[int1]);
   if (by1 <> 0) then begin
    break;
   end;
  end;
 end;
 result:= shortint(by1);
end;

function mseStrLIComp(const Str1, upstr: PmseChar; len: integer): Integer;
                //ascii caseinsensitive, str2 muss upcase sein
var
 po1,po2: pmsecharaty;
 int1: integer;
 ch1: msechar;
 wo1: word;
begin
 wo1:= 0;
 if not((len = 0) or (str1 = upstr)) then begin
  po1:= pointer(str1);
  po2:= pointer(upstr);
  for int1:= 0 to len - 1 do begin
   ch1:= po1^[int1];
   if (ch1 <= 'a') and (ch1 <= 'z') then begin
    inc(ch1,ord('A')-ord('a'));
   end;
   wo1:= ord(ch1)-ord(po2^[int1]);
   if (wo1 <> 0) then begin
    break;
   end;
  end;
 end;
 result:= smallint(wo1);
end;

function issamelstring(const value: lmsestringty; const key: msestring;
             caseinsensitive: boolean = false): boolean;
              //nur ascii caseinsens., key muss upcase sein
begin
 if caseinsensitive then begin
  result:= msestrlicomp(value.po,pointer(key),value.len) = 0;
 end
 else begin
  result:= msestrlcomp(value.po,pointer(key),value.len) = 0;
 end;
end;

function issamelstring(const value: lstringty; const key: string;
             caseinsensitive: boolean = false): boolean;
              //nur ascii caseinsens., key muss upcase sein
begin
 if caseinsensitive then begin
  result:= strlicomp(value.po,pointer(key),value.len) = 0;
 end
 else begin
  result:= strlcomp(value.po,pointer(key),value.len) = 0;
 end;
end;

function minhigh(const a,b: lstringty): integer; overload;
begin
 if a.len < b.len then begin
  result:= a.len;
 end
 else begin
  result:= b.len;
 end;
 dec(result);
end;

function minhigh(const a: lstringty; const b: string): integer; overload;
begin
 if a.len < length(b) then begin
  result:= a.len;
 end
 else begin
  result:= length(b);
 end;
 dec(result);
end;

function minhigh(const a,b: string): integer; overload;
begin
 if length(a) < length(b) then begin
  result:= length(a);
 end
 else begin
  result:= length(b);
 end;
 dec(result);
end;

function lstringcomp(const a,b: lstringty): integer;
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b.po);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(po1^[int1]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - b.len;
 end
 else begin
  result:= shortint(by1);
 end;
end;

function lstringcomp(const a: lstringty; const b: string): integer;
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(po1^[int1]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - length(b);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function lstringicomp1(const a,b: lstringty): integer;
         //case insensitive, b must be uppercase
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b.po);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - b.len;
 end
 else begin
  result:= shortint(by1);
 end;
end;

function lstringicomp1(const a: lstringty; const b: string): integer; overload;
         //ansi case insensitive, b must be uppercase
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - length(b);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function lstringicomp(const a,b: lstringty): integer;
         //case insensitive
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b.po);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(upperchars[po2^[int1]]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - b.len;
 end
 else begin
  result:= shortint(by1);
 end;
end;

function lstringicomp(const a: lstringty; const b: string): integer;
         //case insensitive,
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a.po);
 po2:= pointer(b);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(upperchars[po2^[int1]]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= a.len - length(b);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function stringcomp(const a,b: string): integer;
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a);
 po2:= pointer(b);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(po1^[int1]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= length(a) - length(b);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function stringicomp(const a,b: string): integer;
         //case insensitive
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a);
 po2:= pointer(b);
 by1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(upperchars[po2^[int1]]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= length(a) - length(b);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function stringicomp1(const a,upstr: string): integer;
         //case insensitive, b must be uppercase
var
 int1: integer;
 by1: byte;
 po1,po2: pcharaty;
begin
 po1:= pointer(a);
 po2:= pointer(upstr);
 by1:= 0;
 for int1:= 0 to minhigh(a,upstr) do begin
  by1:= byte(upperchars[po1^[int1]]) - byte(po2^[int1]);
  if by1 <> 0 then begin
   break;
  end;
 end;
 if by1 = 0 then begin
  result:= length(a) - length(upstr);
 end
 else begin
  result:= shortint(by1);
 end;
end;

function msestringcomp(const a,b: msestring): integer;
var
 int1: integer;
 wo1: word;
 po1,po2: pmsecharaty;
begin
 po1:= pointer(a);
 po2:= pointer(b);
 wo1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  wo1:= word(po1^[int1]) - word(po2^[int1]);
  if wo1 <> 0 then begin
   break;
  end;
 end;
 if wo1 = 0 then begin
  result:= length(a) - length(b);
 end
 else begin
  result:= smallint(wo1);
 end;
end;

function msestringicomp(const a,b: msestring): integer;
         //ascii case insensitive
var
 int1: integer;
 wo1: word;
 ch1,ch2: msechar;
 po1,po2: pmsecharaty;
begin
 po1:= pointer(a);
 po2:= pointer(b);
 wo1:= 0;
 for int1:= 0 to minhigh(a,b) do begin
  ch1:= po1^[int1];
  if (ch1 >= 'a') and (ch1 <= 'z') then begin
   inc(ch1,ord('A')-ord('a'));
  end;
  ch2:= po2^[int1];
  if (ch2 >= 'a') and (ch2 <= 'z') then begin
   inc(ch2,ord('A')-ord('a'));
  end;
  wo1:= word(ch1) - word(ch2);
  if wo1 <> 0 then begin
   break;
  end;
 end;
 if wo1 = 0 then begin
  result:= length(a) - length(b);
 end
 else begin
  result:= smallint(wo1);
 end;
end;

function msestringicomp1(const a,upstr: msestring): integer;
         //case insensitive, b must be uppercase
var
 int1: integer;
 wo1: word;
 ch1: msechar;
 po1,po2: pmsecharaty;
begin
 po1:= pointer(a);
 po2:= pointer(upstr);
 wo1:= 0;
 for int1:= 0 to minhigh(a,upstr) do begin
  ch1:= po1^[int1];
  if (ch1 >= 'a') and (ch1 <= 'z') then begin
   inc(ch1,ord('A')-ord('a'));
  end;
  wo1:= word(ch1) - word(po2^[int1]);
  if wo1 <> 0 then begin
   break;
  end;
 end;
 if wo1 = 0 then begin
  result:= length(a) - length(upstr);
 end
 else begin
  result:= smallint(wo1);
 end;
end;

function isemptystring(const s: pchar): boolean;
begin
 result:= (s = nil) or (s^ = char(0));
end;

function isemptystring(const s: pmsechar): boolean;
begin
 result:= (s = nil) or (s^ = msechar(0));
end;

function isnamechar(achar: char): boolean;
            //true if achar in 'a'..'z','A'..'Z','0'..'9','_';
begin
 result:= (achar >= 'a') and (achar <= 'z') or (achar >= 'A') and (achar <= 'Z') or
                (achar >= '0') and (achar <= '9') or (achar = '_');
end;

function isnamechar(achar: msechar): boolean;
            //true if achar in 'a'..'z','A'..'Z','0'..'9','_';
begin
 result:= (achar >= 'a') and (achar <= 'z') or (achar >= 'A') and (achar <= 'Z') or
                (achar >= '0') and (achar <= '9') or (achar = '_');
end;

function startsstr(substring: pchar; s: pchar): boolean;
begin
 result:= substring = s;
 if not result then begin
  if (substring <> nil) and (s <> nil) then begin
   while (substring^ = s^) and (substring^ <> #0) do begin
    inc(substring);
    inc(s);
   end;
   result:= substring^= #0;
  end
  else begin
   result:= isemptystring(substring) and isemptystring(s);
  end;
 end;
end;

function StartsStr(const substring,s: string): boolean;
begin
 result:= startsstr(pchar(substring),pchar(s));
end;

function msestartsstr(substring: pmsechar; s: pmsechar): boolean;
begin
 result:= substring = s;
 if not result then begin
  if (substring <> nil) and (s <> nil) then begin
   while (substring^ = s^) and (substring^ <> #0) do begin
    inc(substring);
    inc(s);
   end;
   result:= substring^= #0;
  end
  else begin
   result:= isemptystring(substring) and isemptystring(s);
  end;
 end;
end;

function mseStartsStr(const substring,s: msestring): boolean;
begin
 result:= msestartsstr(pmsechar(substring),pmsechar(s));
end;

function strlcopy(const str: pchar; len: integer): ansistring;
                       //nicht nullterminiert
begin
 setlength(result,len);
 move(str^,result[1],len*sizeof(char));
end;

function msestrlcopy(const str: pmsechar; len: integer): msestring;
                       //nicht nullterminiert
begin
 setlength(result,len);
 move(str^,result[1],len*sizeof(msechar));
end;

function comparestrlen(S1,S2: string): integer;
                //case sensitiv, beruecksichtigt nur s1 laenge
begin
 if (length(s1) = 0) or (pointer(s1) = pointer(s2)) then begin
  result:= 0;
  exit;
 end;
 if length(s2) = 0 then begin
  result:= 1;
  exit;
 end
 else begin
  result:= strlcomp(pointer(s1),pointer(s2),length(s1));
 end;
end;

function msecomparestr(const S1, S2: msestring): Integer;
begin
{$ifdef FPC}
 {$ifdef mswindows}
 if iswin95 then begin
  result:= comparestr(s1,s2);
 end
 else begin
  result:= widecomparestr(s1,s2); 
 end;
 {$else}
  result:= widecomparestr(s1,s2);
 {$endif}
{$else}
 result:= widecomparestr(s1,s2);
{$endif}
end;

function msecomparetext(const S1, S2: msestring): Integer;
begin
{$ifdef FPC}
 {$ifdef mswindows}
 if iswin95 then begin
  result:= comparetext(s1,s2);
 end
 else begin
  result:= widecomparetext(s1,s2);
 end;
 {$else}
  result:= widecomparetext(s1,s2);
 {$endif}
{$else}
 result:= widecomparetext(s1,s2);
{$endif}
end;

function mseCompareStrlen(const S1, S2: msestring): Integer;
                //case sensitiv, beruecksichtigt nur s1 laenge
var
 str1: msestring;
begin
 str1:= copy(s2,1,length(s1)); //todo: optimize
 result:= msecomparestr(s1,str1);
end;

function mseCompareTextlen(const S1, S2: msestring): Integer;
                //case insensitiv, beruecksichtigt nur s1 laenge
var
 str1: msestring;
begin
 str1:= copy(s2,1,length(s1));  //todo: optimize
 result:= msecomparetext(s1,str1);
end;

function mselowercase(const s: msestring): msestring;
begin
{$ifdef FPC}
 {$ifdef mswindows}
 if iswin95 then begin
  result:= lowercase(s);
 end
 else begin
  result:= widelowercase(s);    
 end;
 {$else}
 result:= widelowercase(s);    
 {$endif}
{$else}
 result:= widelowercase(s);    
{$endif}
end;

function mseuppercase(const s: msestring): msestring;
begin
{$ifdef FPC}
 {$ifdef mswindows}
 if iswin95 then begin
  result:= uppercase(s);
 end
 else begin
  result:= wideuppercase(s);    
 end;
 {$else}
 result:= wideuppercase(s);    
 {$endif}
{$else}
 result:= wideuppercase(s);    
{$endif}
end;

function msestartstr(const atext: msestring; trenner: msechar): msestring;
var
 po1: pmsechar;
begin
 po1:= msestrlscan(pmsechar(atext),trenner,length(atext));
 if po1 = nil then begin
  result:= atext;
 end
 else begin
  result:= copy(atext,1,po1-pmsechar(atext));
 end;
end;

function mseremspace(const s: msestring): msestring;
var
 int1,int2: integer;
 ch: msechar;
begin
 int2:= 0;
 setlength(result,length(s));
 for int1:= 1 to length(s) do begin
  ch:= s[int1];
  if ch > ' ' then begin
   inc(int2);
   pmsecharaty(result)^[int2]:= ch;
  end;
 end;
 setlength(result,int2);
end;

function removelinebreaks(const s: msestring): msestring;
    //replaces linebreaks with space
begin
 result:= concatstrings(breaklines(s),' ');
end;

end.



