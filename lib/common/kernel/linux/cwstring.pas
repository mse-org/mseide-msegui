{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2005 by Florian Klaempfl,
    member of the Free Pascal development team.

    libc based wide string support

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 **********************************************************************}
{$ifdef FPC}{$mode objfpc}{$endif}

{$define unicodeversion}
{$if fpc_fullversion >= 30000}
 {$define fpcv3}
{$endif}
unit cwstring;
{$ifndef FPC}
interface          //dummy
implementation

{$else}

interface
uses
 sysutils,msesetlocale,mselibc;
type
 eiconv = class(econverterror)
 end;

procedure SetCWidestringManager();

implementation
{$ifdef FPC}{$linklib c}{$endif}

{$ifndef linux}  // Linux (and maybe glibc platforms in general), have iconv in glibc.
{$ifndef FreeBSD5}
 {$linklib iconv}
 {$define useiconv}
{$endif}
{$endif linux}

Uses
//  BaseUnix,
  msectypes,{$ifndef FPC}msetypes,{$endif}
//  unix,
//  unixtype,
//  sysutils,
//  initc,
  {msedatalist,}msesysintf1,msesysintf,msestrings;

Const
{$ifndef useiconv}
    libiconvname='c';  // is in libc under Linux.
{$else}
    libiconvname='iconv';
{$endif}

{ Case-mapping "arrays" }
//var
//  AnsiUpperChars: AnsiString; // 1..255
//  AnsiLowerChars: AnsiString; // 1..255
//  WideUpperChars: WideString; // 1..65535
//  WideLowerChars: WideString; // 1..65535

{ the following declarations are from the libc unit for linux so they
  might be very linux centric
  maybe this needs to be splitted in an os depend way later }
function towlower(__wc:wint_t):wint_t;cdecl;external libiconvname name 'towlower';
function towupper(__wc:wint_t):wint_t;cdecl;external libiconvname name 'towupper';
function wcscoll (__s1:pwchar_t; __s2:pwchar_t):cint;cdecl;external libiconvname name 'wcscoll';
function strcoll (__s1:pchar; __s2:pchar):cint;cdecl;external libiconvname name 'strcoll';

const
{$ifdef linux}
  __LC_CTYPE = 0;
  _NL_CTYPE_CLASS = (__LC_CTYPE shl 16);
  _NL_CTYPE_CODESET_NAME = (_NL_CTYPE_CLASS)+14;
  CODESET = _NL_CTYPE_CODESET_NAME;
{$else linux}
{$ifdef darwin}
  CODESET = 0;
{$else darwin}
{$ifdef FreeBSD} // actually FreeBSD5. internationalisation is afaik not default on 4.
  CODESET = 0;
{$else freebsd}
{$ifdef solaris}
  CODESET=49;
{$else}
{$error lookup the value of CODESET in /usr/include/langinfo.h for your OS }
// and while doing it, check if iconv is in libc, and if the symbols are prefixed with iconv_ or libiconv_
{$endif solaris}
{$endif FreeBSD}
{$endif darwin}
{$endif linux}

{ unicode encoding name }
{$ifdef FPC_LITTLE_ENDIAN}
  unicode_encoding = 'UNICODELITTLE';
{$else  FPC_LITTLE_ENDIAN}
  unicode_encoding = 'UNICODEBIG';
{$endif  FPC_LITTLE_ENDIAN}

type
 
  piconv_t = ^iconv_t;
  iconv_t = pointer;
  nl_item = cint;

function nl_langinfo(__item:nl_item):pchar;cdecl;external libiconvname name 'nl_langinfo';
{$ifndef Darwin}
function iconv_open(__tocode:pchar; __fromcode:pchar):iconv_t;cdecl;external libiconvname name 'iconv_open';
function iconv(__cd:iconv_t; __inbuf:ppchar; __inbytesleft:psize_t; __outbuf:ppchar; __outbytesleft:psize_t):size_t;cdecl;external libiconvname name 'iconv';
function iconv_close(__cd:iconv_t):cint;cdecl;external libiconvname name 'iconv_close';
{$else}
function iconv_open(__tocode:pchar; __fromcode:pchar):iconv_t;cdecl;external libiconvname name 'libiconv_open';
function iconv(__cd:iconv_t; __inbuf:ppchar; __inbytesleft:psize_t; __outbuf:ppchar; __outbytesleft:psize_t):size_t;cdecl;external libiconvname name 'libiconv';
function iconv_close(__cd:iconv_t):cint;cdecl;external libiconvname name 'libiconv_close';
{$endif}

var
//  iconv_ansi2ucs4,
//  iconv_ucs42ansi,
  iconv_ansi2wide,
  iconv_wide2ansi : iconv_t;
  
//  lock_ansi2ucs4 : integer = -1;
//  lock_ucs42ansi : integer = -1;
  lock_ansi2wide : integer = -1;
  lock_wide2ansi : integer = -1;

procedure lockiconv(var lockcount: integer);
begin
 while interlockedincrement(lockcount) <> 0 do begin
  interlockeddecrement(lockcount);
  sys_threadschedyield;
 end;
end;

procedure unlockiconv(var lockcount: integer);
begin
 interlockeddecrement(lockcount);
end;

{$ifdef fpcv3}
procedure Wide2AnsiMove(source:pwidechar;var dest:RawByteString;cp : TSystemCodePage;len:SizeInt);
                            //todo: codepages
{$else}
procedure Wide2AnsiMove(source:pwidechar; var dest:ansistring; len:SizeInt);
{$endif}
  var
    outlength,
    outoffset,
    srclen,
    outleft : size_t;
    srcpos : pwidechar;
    destpos: pchar;
    mynil : pchar;
    my0 : size_t;
  begin
    mynil:=nil;
    my0:=0;
    { rought estimation }
    setlength(dest,len*3);
    outlength:=len*3;
    srclen:=len*2;
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength;
    lockiconv(lock_wide2ansi);
    while iconv(iconv_wide2ansi,@srcpos,@srclen,@destpos,@outleft)=size_t(-1) do
      begin
        case __errno_location()^ of
//        case fpgetCerrno of
          EILSEQ:
            begin
              { skip and set to '?' }
              inc(srcpos);
              dec(srclen,2);
              destpos^:='?';
              inc(destpos);
              dec(outleft);
              { reset }
              iconv(iconv_wide2ansi,@mynil,@my0,@mynil,@my0);
            end;
          E2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len*3);
              inc(outleft,len*3);
              inc(outlength,len*3);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            begin
              unlockiconv(lock_wide2ansi);
              raise eiconv.Create('iconv error '+
                       IntToStr(sys_getlasterror{fpgetCerrno}));
            end;
        end;
      end;
    unlockiconv(lock_wide2ansi);
    // truncate string
    setlength(dest,length(dest)-outleft);
  end;

{$ifdef fpcv3}
procedure Ansi2WideMove(source:pchar;cp : TSystemCodePage;
                                          var dest:widestring;len:SizeInt);
                 //todo: codepages
{$else}
procedure Ansi2WideMove(source:pchar;var dest:widestring;len:SizeInt);
{$endif}
  var
    outlength,
    outoffset,
    outleft : size_t;
    srcpos,
    destpos: pchar;
    mynil : pchar;
    my0 : size_t;
  begin
    mynil:=nil;
    my0:=0;
    // extra space
    outlength:=len+1;
    setlength(dest,outlength);
    outlength:=len+1;
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength*2;
    lockiconv(lock_ansi2wide);
    while iconv(iconv_ansi2wide,@srcpos,@len,@destpos,@outleft)=size_t(-1) do
      begin
//        case fpgetCerrno of
        case __errno_location()^ of
         EILSEQ:
            begin
              { skip and set to '?' }
              inc(srcpos);
              dec(len);
              pwidechar(destpos)^:='?';
              inc(destpos,2);
              dec(outleft,2);
              { reset }
              iconv(iconv_ansi2wide,@mynil,@my0,@mynil,@my0);
            end;
          E2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len);
              inc(outleft,len*2);
              inc(outlength,len);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            begin
              unlockiconv(lock_ansi2wide);
              raise eiconv.Create('iconv error '+
                     IntToStr(sys_getlasterror{fpgetCerrno}));
            end;
        end;
      end;
    unlockiconv(lock_ansi2wide);
    // truncate string
    setlength(dest,length(dest)-outleft div 2);
  end;


function LowerWideString(const s : WideString) : WideString;
  var
    i : SizeInt;
  begin
    SetLength(result,length(s));
    for i:=1 to length(s) do
      result[i]:=WideChar(towlower(wint_t(s[i])));
  end;


function UpperWideString(const s : WideString) : WideString;
  var
    i : SizeInt;
  begin
    SetLength(result,length(s));
    for i:=1 to length(s) do
      result[i]:=WideChar(towupper(wint_t(s[i])));
  end;
(* not used
procedure Ansi2UCS4Move(source:pchar;var dest:UCS4String;len:SizeInt);
  var
    outlength,
    outoffset,
    outleft : size_t;
    srcpos,
    destpos: pchar;
//    mynil : pchar;
//    my0 : size_t;
   ustr1: unicodestring;
  begin
//    mynil:=nil;
//    my0:=0;
    // extra space
   if iconv_ansi2ucs4 = nil then begin
    ansi2widemove(source,dest);
    UnicodeStringToUCS4String(ustr1,dest);
   end
   else begin
    outlength:=len+1;
    setlength(dest,outlength);
    outlength:=len+1;
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength*4;
    lockiconv(lock_ansi2ucs4);
    while iconv(iconv_ansi2ucs4,@srcpos,@len,@destpos,@outleft)=size_t(-1) do
      begin
//        case fpgetCerrno of
        case __errno_location()^ of
          E2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len);
              inc(outleft,len*4);
              inc(outlength,len);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            begin
              unlockiconv(lock_ansi2ucs4);
              raise eiconv.Create('iconv error '+
                          IntToStr(sys_getlasterror{fpgetCerrno}));
            end;
        end;
      end;
    unlockiconv(lock_ansi2ucs4);
    // truncate string
    setlength(dest,length(dest)-outleft div 4);
   end;
  end;
*)
const
 colllen = 3;     //max len of collation element
 bufferhigh = 2*colllen-1;
 
function CompareWideString(const s1, s2 : WideString): PtrInt;
var                   //no surrogate pair handling, no decomposition handling
 w1,w2: array[0..bufferhigh] of ucs4char;
 int1,int2: integer;
 lena,lenb,max: integer;
 pa,pb: pmsecharaty;
begin
 result:= 0;
 if pointer(s1) <> pointer(s2) then begin
  if s1 = '' then begin
   result:= -1;
  end
  else begin
   if s2 = '' then begin
    result:= 1;
   end
   else begin
    result:= 0;
    lena:= length(s1);
    lenb:= length(s2);
    pa:= pointer(s1);
    pb:= pointer(s2);
    max:= lena;
    if max < lenb then begin
     max:= lenb;
    end;
    for int1:= 0 to max -1 do begin
     if pa^[int1] <> pb^[int1] then begin
      int2:= int1 - (colllen-1); //space for multi char collation elements
      if int2 < 0 then begin
       int2:= 0;
      end;
      inc(pmsechar(pointer(pa)),int2);
      inc(pmsechar(pointer(pb)),int2);
      w1[high(w1)]:= 0;
      w2[high(w1)]:= 0;
      for int2:= 0 to high(w1)-1 do begin
       w1[int2]:= word(pa^[0]);
       if pa^[0] <> #0 then begin
        inc(pmsechar(pointer(pa)));
       end;
       w2[int2]:= word(pb^[0]);
       if pb^[0] <> #0 then begin
        inc(pmsechar(pointer(pb)));
       end;
      end;
      result:= wcscoll(pwchar_t(@w1),pwchar_t(@w2));
      break;
     end;
    end;
   end;
  end;
 end;
end;

function CompareTextWideString(const s1, s2 : WideString): PtrInt;
var                   //no surrogate pair handling, no decomposition handling
 w1,w2: array[0..bufferhigh] of ucs4char;
 int1,int2: integer;
 lena,lenb,max: integer;
 pa,pb: pmsecharaty;
begin
 result:= 0;
 if pointer(s1) <> pointer(s2) then begin
  if s1 = '' then begin
   result:= -1;
  end
  else begin
   if s2 = '' then begin
    result:= 1;
   end
   else begin
    result:= 0;
    lena:= length(s1);
    lenb:= length(s2);
    pa:= pointer(s1);
    pb:= pointer(s2);
    max:= lena;
    if max < lenb then begin
     max:= lenb;
    end;
    for int1:= 0 to max -1 do begin
     if towupper(wint_t(word(pa^[int1]))) <> 
                                towupper(wint_t(word(pb^[int1]))) then begin
      int2:= int1 - (colllen-1); //space for multi char collation elements
      if int2 < 0 then begin
       int2:= 0;
      end;
      inc(pmsechar(pointer(pa)),int2);
      inc(pmsechar(pointer(pb)),int2);
      w1[high(w1)]:= 0;
      w2[high(w1)]:= 0;
      for int2:= 0 to high(w1)-1 do begin
       w1[int2]:= towupper(word(pa^[0]));
       if pa^[0] <> #0 then begin
        inc(pmsechar(pointer(pa)));
       end;
       w2[int2]:= towupper(word(pb^[0]));
       if pb^[0] <> #0 then begin
        inc(pmsechar(pointer(pb)));
       end;
      end;
      result:= wcscoll(pwchar_t(@w1),pwchar_t(@w2));
      break;
     end;
    end;
   end;
  end;
 end;
end;
{
function CompareWideString(const s1, s2 : WideString) : PtrInt;
var                   //no surrogate pair handling
 w1,w2: ucs4string;
 int1: integer;
 po1: pwidechar;
 po2: pucs4char;
begin
 allocuninitedarray(length(s1)+1,sizeof(ucs4char),w1);
 allocuninitedarray(length(s2)+1,sizeof(ucs4char),w2);
 po1:= pwidechar(s1);
 po2:= pointer(w1);
 while po1^ <> #0 do begin
  po2^:= word(po1^);
  inc(po1);
  inc(po2);
 end;
 po2^:= 0;
 po1:= pwidechar(s2);
 po2:= pointer(w2);
 while po1^ <> #0 do begin
  po2^:= word(po1^);
  inc(po1);
  inc(po2);
 end;
 po2^:= 0;
 result:= wcscoll(pwchar_t(w1),pwchar_t(w2));
end;

function CompareTextWideString(const s1, s2 : WideString): PtrInt;
var                   //no surrogate pair handling
 w1,w2: ucs4string;
 int1: integer;
 po1: pwidechar;
 po2: pucs4char;
begin
 result:= 0;
 if pointer(s1) <> pointer(s2) then begin
  if s1 = '' then begin
   result:= -1;
  end
  else begin
   if s2 = '' then begin
    result:= 1;
   end
   else begin
    allocuninitedarray(length(s1)+1,sizeof(ucs4char),w1);
    allocuninitedarray(length(s2)+1,sizeof(ucs4char),w2);
    po1:= pwidechar(s1);
    po2:= pointer(w1);
    while po1^ <> #0 do begin
     po2^:= towupper(wint_t(po1^));
     inc(po1);
     inc(po2);
    end;
    po2^:= 0;
    po1:= pwidechar(s2);
    po2:= pointer(w2);
    while po1^ <> #0 do begin
     po2^:= towupper(wint_t(po1^));
     inc(po1);
     inc(po2);
    end;
    po2^:= 0;
    result:= wcscoll(pwchar_t(w1),pwchar_t(w2));
   end;
  end;
 end;
end;
}
function StrCompAnsi(s1,s2 : PChar): PtrInt;
  begin
    result:=strcoll(s1,s2);
  end;

var
{$ifdef unicodeversion}
  widestringmanagerbefore : TUnicodeStringManager;
{$else}
  widestringmanagerbefore : TWideStringManager;
{$endif}

Procedure SetCWideStringManager;
Var
{$ifdef unicodeversion}
  CWideStringManager : TUnicodeStringManager;
{$else}
  CWideStringManager : TWideStringManager;
{$endif}
begin
 widestringmanagerbefore:= widestringmanager;
 CWideStringManager:= widestringmanager;
 With CWideStringManager do begin
  Wide2AnsiMoveProc:= @Wide2AnsiMove;
  Ansi2WideMoveProc:= @Ansi2WideMove;

  UpperWideStringProc:= @UpperWideString;
  LowerWideStringProc:= @LowerWideString;

  CompareWideStringProc:= @CompareWideString;
  CompareTextWideStringProc:= @CompareTextWideString;
{$ifdef unicodeversion}
  Unicode2AnsiMoveProc:= @Wide2AnsiMove;
  Ansi2UnicodeMoveProc:= @Ansi2WideMove;

  UpperUnicodeStringProc:= @UpperWideString;
  LowerUnicodeStringProc:= @LowerWideString;

  CompareUnicodeStringProc:= @CompareWideString;
  CompareTextUnicodeStringProc:= @CompareTextWideString;
{$endif}
  {
  CharLengthPCharProc

  UpperAnsiStringProc
  LowerAnsiStringProc
  CompareStrAnsiStringProc
  CompareTextAnsiStringProc
  }
  StrCompAnsiStringProc:=@StrCompAnsi;
  {
  StrICompAnsiStringProc
  StrLCompAnsiStringProc
  StrLICompAnsiStringProc
  StrLowerAnsiStringProc
  StrUpperAnsiStringProc
  }
 end;
 SetWideStringManager(CWideStringManager);
end;

procedure unSetCWidestringManager();
begin
 widestringmanager:= widestringmanagerbefore;
end;

initialization
 setlocale(LC_ALL,'');
  { init conversion tables }
 iconv_wide2ansi:=iconv_open(nl_langinfo(CODESET),unicode_encoding);
 iconv_ansi2wide:=iconv_open(unicode_encoding,nl_langinfo(CODESET));
// iconv_ucs42ansi:=iconv_open(nl_langinfo(CODESET),'UCS4');
// iconv_ansi2ucs4:=iconv_open('UCS4',nl_langinfo(CODESET));
 SetCWideStringManager();
finalization
 unSetCWideStringManager();
 if iconv_wide2ansi <> nil then begin
  iconv_close(iconv_wide2ansi);
 end;
 if iconv_ansi2wide <> nil then begin
  iconv_close(iconv_ansi2wide);
 end;
// iconv_close(iconv_ucs42ansi);
// if iconv_ansi2ucs4 <> nil then begin
//  iconv_close(iconv_ansi2ucs4);
// end;
{$endif}
end.
