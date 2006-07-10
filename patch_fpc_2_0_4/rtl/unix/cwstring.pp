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

{$mode objfpc}

unit cwstring;

interface

procedure SetCWidestringManager;

implementation

{$linklib c}

{$ifndef linux}  // Linux (and maybe glibc platforms in general), have iconv in glibc.
{$ifndef FreeBSD5}
 {$linklib iconv}
 {$define useiconv}
{$endif}
{$endif linux}

Uses
  BaseUnix,
  ctypes,
  unix,
  unixtype,
  sysutils,
  initc;

Const
{$ifndef useiconv}
    libiconvname='c';  // is in libc under Linux.
{$else}
    libiconvname='iconv';
{$endif}

{ Case-mapping "arrays" }
var
  AnsiUpperChars: AnsiString; // 1..255
  AnsiLowerChars: AnsiString; // 1..255
  WideUpperChars: WideString; // 1..65535
  WideLowerChars: WideString; // 1..65535

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
{$error lookup the value of CODESET in /usr/include/langinfo.h for your OS }
// and while doing it, check if iconv is in libc, and if the symbols are prefixed with iconv_ or libiconv_
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
  iconv_ansi2ucs4,
  iconv_ucs42ansi,
  iconv_ansi2wide,
  iconv_wide2ansi : iconv_t;
  
  lock_ansi2ucs4 : integer = -1;
  lock_ucs42ansi : integer = -1;
  lock_ansi2wide : integer = -1;
  lock_wide2ansi : integer = -1;

procedure lockiconv(var lockcount: integer);
begin
 while interlockedincrement(lockcount) <> 0 do begin
  interlockeddecrement(lockcount);
  sleep(0);
 end;
end;

procedure unlockiconv(var lockcount: integer);
begin
 interlockeddecrement(lockcount);
end;
  
procedure Wide2AnsiMove(source:pwidechar;var dest:ansistring;len:SizeInt);
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
        case fpgetCerrno of
          ESysEILSEQ:
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
          ESysE2BIG:
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
              raise EConvertError.Create('iconv error '+IntToStr(fpgetCerrno));
            end;
        end;
      end;
    unlockiconv(lock_wide2ansi);
    // truncate string
    setlength(dest,length(dest)-outleft);
  end;


procedure Ansi2WideMove(source:pchar;var dest:widestring;len:SizeInt);
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
        case fpgetCerrno of
         ESysEILSEQ:
            begin
              { skip and set to '?' }
              inc(srcpos);
              pwidechar(destpos)^:='?';
              inc(destpos,2);
              dec(outleft,2);
              { reset }
              iconv(iconv_wide2ansi,@mynil,@my0,@mynil,@my0);
            end;
          ESysE2BIG:
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
              raise EConvertError.Create('iconv error '+IntToStr(fpgetCerrno));
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


procedure Ansi2UCS4Move(source:pchar;var dest:UCS4String;len:SizeInt);
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
    outleft:=outlength*4;
    lockiconv(lock_ansi2ucs4);
    while iconv(iconv_ansi2ucs4,@srcpos,@len,@destpos,@outleft)=size_t(-1) do
      begin
        case fpgetCerrno of
          ESysE2BIG:
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
              raise EConvertError.Create('iconv error '+IntToStr(fpgetCerrno));
            end;
        end;
      end;
    unlockiconv(lock_ansi2ucs4);
    // truncate string
    setlength(dest,length(dest)-outleft div 4);
  end;


function CompareWideString(const s1, s2 : WideString) : PtrInt;
  var
    hs1,hs2 : UCS4String;
  begin
    hs1:=WideStringToUCS4String(s1);
    hs2:=WideStringToUCS4String(s2);
    result:=wcscoll(pwchar_t(hs1),pwchar_t(hs2));
  end;


function CompareTextWideString(const s1, s2 : WideString): PtrInt;
  begin
    result:=CompareWideString(UpperWideString(s1),UpperWideString(s2));
  end;


function StrCompAnsi(s1,s2 : PChar): PtrInt;
  begin
    result:=strcoll(s1,s2);
  end;


Procedure SetCWideStringManager;
Var
  CWideStringManager : TWideStringManager;
begin
  CWideStringManager:=widestringmanager;
  With CWideStringManager do
    begin
      Wide2AnsiMoveProc:=@Wide2AnsiMove;
      Ansi2WideMoveProc:=@Ansi2WideMove;

      UpperWideStringProc:=@UpperWideString;
      LowerWideStringProc:=@LowerWideString;

      CompareWideStringProc:=@CompareWideString;
      CompareTextWideStringProc:=@CompareTextWideString;
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


initialization
  SetCWideStringManager;
  { init conversion tables }
  iconv_wide2ansi:=iconv_open(nl_langinfo(CODESET),unicode_encoding);
  iconv_ansi2wide:=iconv_open(unicode_encoding,nl_langinfo(CODESET));
  iconv_ucs42ansi:=iconv_open(nl_langinfo(CODESET),'UCS4');
  iconv_ansi2ucs4:=iconv_open('UCS4',nl_langinfo(CODESET));
finalization
  iconv_close(iconv_ansi2wide);
end.
