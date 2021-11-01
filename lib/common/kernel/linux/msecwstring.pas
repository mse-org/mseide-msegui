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
 {$define mse_fpc_3}
{$endif}
{$if fpc_fullversion >= 30001}
 {$define hascompareoptions}
{$endif}
{$if fpc_fullversion >= 030300}
 {$define mse_fpc_3_3}
 {$endif}

unit msecwstring;
{$ifndef FPC}
interface          //dummy
implementation

{$else}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 msetypes,sysutils,msesetlocale,mselibc{$ifdef mse_fpc_3},unixcp{$endif};
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

{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

Const
{$ifdef useiconv}
 libiconvname='iconv';
{$else}
 libiconvname='c';  // is in libc under Linux.
{$endif}

{$if defined(darwin) or defined(freebsd) and not defined(freebsd5)}
 prefix = 'lib';
{$else}
 prefix = '';
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
//{$ifdef linux}
//  __LC_CTYPE = 0;
//  _NL_CTYPE_CLASS = (__LC_CTYPE shl 16);
//  _NL_CTYPE_CODESET_NAME = (_NL_CTYPE_CLASS)+14;
//  CODESET = _NL_CTYPE_CODESET_NAME;
//{$else linux}
//{$ifdef darwin}
//  CODESET = 0;
//{$else darwin}
//{$ifdef FreeBSD} // actually FreeBSD5. internationalisation is afaik not default on 4.
//  CODESET = 0;
//{$else freebsd}
//{$ifdef solaris}
//  CODESET=49;
//{$else}
//{$error lookup the value of CODESET in /usr/include/langinfo.h for your OS }
// and while doing it, check if iconv is in libc, and if the symbols are prefixed with iconv_ or libiconv_
//{$endif solaris}
//{$endif FreeBSD}
//{$endif darwin}
//{$endif linux}

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

function nl_langinfo(__item:nl_item):pchar cdecl
                                external libiconvname name 'nl_langinfo';
function iconv_open(__tocode: pchar; __fromcode: pchar): iconv_t cdecl
                                external libiconvname name prefix+'iconv_open';
function iconv(__cd: iconv_t; __inbuf: ppchar; __inbytesleft: psize_t;
              __outbuf: ppchar; __outbytesleft: psize_t): size_t cdecl
                                external libiconvname name prefix+'iconv';
function iconv_close(__cd: iconv_t): cint cdecl
                                external libiconvname name prefix+'iconv_close';

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

{$ifdef mse_fpc_3}
Type
  PAnsiRec = ^TAnsiRec;
  TAnsiRec = Record
    CodePage    : TSystemCodePage;
    ElementSize : Word;
  {$if defined(mse_fpc_3_3)}
  {$ifdef CPU64}	
    Ref         : Longint;
  {$else}
    Ref         : SizeInt;
  {$endif}
{$else}
  {$ifdef CPU64}	
    { align fields  }
	Dummy       : DWord;
  {$endif CPU64}
    Ref         : SizeInt;
 {$endif}
    Len         : SizeInt;
  end;

procedure Wide2AnsiMove(source:pwidechar;var dest:RawByteString;
                                          cp : TSystemCodePage; len:SizeInt);
                            //todo: convert codepages
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
{$ifdef mse_fpc_3}
 if (cp = cp_utf8) or (cp = cp_acp) and
                          (DefaultSystemCodePage = cp_utf8) then begin
  dest:= stringtoutf8(source,len);
 end
 else begin
{$endif}
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
   {$ifdef mse_fpc_3}
    pansirec(pointer(dest)-sizeof(tansirec))^.codepage:= cp;
   {$endif}
{$ifdef mse_fpc_3}
 end;
{$endif}
end;

{$ifdef mse_fpc_3}
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
{$ifdef mse_fpc_3}
 if (cp = cp_utf8) or (cp = cp_acp) and
                          (DefaultSystemCodePage = cp_utf8) then begin
  dest:= utf8tostring(source,len);
 end
 else begin
{$endif}
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
{$ifdef mse_fpc_3}
 end;
{$endif}
end;


function lowerwidestring(const s : widestring) : widestring;
var
 i1: int32;
 ps,pd,pe: pmsechar;
begin
 i1:= length(s);
 setlength(result,i1);
 ps:= pointer(s);
 pd:= pointer(result);
 pe:= pd + i1;
 while pd < pe do begin
  pd^:= widechar(towlower(wint_t(ps^)));
  inc(ps);
  inc(pd);
 end;
end;

function upperwidestring(const s : widestring) : widestring;
var
 i1: int32;
 ps,pd,pe: pmsechar;
begin
 i1:= length(s);
 setlength(result,i1);
 ps:= pointer(s);
 pd:= pointer(result);
 pe:= pd + i1;
 while pd < pe do begin
  pd^:= widechar(towupper(wint_t(ps^)));
  inc(ps);
  inc(pd);
 end;
end;

function CompareTextWideString(const s1, s2 : WideString): PtrInt;
var                   //no surrogate pair handling, no decomposition handling
 w1,w2: array[0..1] of ucs4char;
 int1: integer;
 max: integer;
 pa,pb,pe: pmsechar;
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
    pa:= pointer(s1);
    pb:= pointer(s2);
    max:= length(s1);
    int1:= length(s2);
    if max > int1 then begin
     max:= int1;
    end;
    pe:= pa + max;
    while pa <= pe do begin //including terminating #0
     if pa^ <> pb^ then begin
      w1[0]:= towupper(wint_t(word(pa^)));
      w2[0]:= towupper(wint_t(word(pb^)));
      if w1[0] <> w2[0] then begin
       w1[1]:= 0;
       w2[1]:= 0;
       result:= wcscoll(pwchar_t(@w1),pwchar_t(@w2));
       break;
      end;
     end;
     inc(pa);
     inc(pb);
    end;
   end;
  end;
 end;
end;

function CompareWideString(const s1, s2 : WideString
          {$ifdef hascompareoptions};Options : TCompareOptions{$endif}): PtrInt;
var                   //no surrogate pair handling, no decomposition handling
 w1,w2: array[0..1] of ucs4char;
 int1: integer;
 max: integer;
 pa,pb,pe: pmsechar;
begin
{$ifdef hascompareoptions}
 if (coignorecase in options) then begin
  result:= comparetextwidestring(s1,s2);
  exit;
 end;
{$endif}
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
    pa:= pointer(s1);
    pb:= pointer(s2);
    max:= length(s1);
    int1:= length(s2);
    if max > int1 then begin
     max:= int1;
    end;
    pe:= pa + max;
    while pa <= pe do begin //including terminating #0
     if pa^ <> pb^ then begin
      w1[0]:= ord(pa^);
      w1[1]:= 0;
      w2[0]:= ord(pb^);
      w2[1]:= 0;
      result:= wcscoll(pwchar_t(@w1),pwchar_t(@w2));
      break;
     end;
     inc(pa);
     inc(pb);
    end;
   end;
  end;
 end;
end;

function StrCompAnsi(s1,s2 : PChar): PtrInt;
  begin
    result:=strcoll(s1,s2);
  end;

{$ifdef mse_fpc_3}
//copied from fpc rtl
{$ifdef FPC_HAS_CPSTRING}

function envvarset(const varname: pchar): boolean;
var
  varval: pchar;
begin
  varval:= getenv(varname);
  result:=
    assigned(varval) and
    (varval[0]<>#0);
end;

function GetStandardCodePage(
                      const stdcp: TStandardCodePageEnum): TSystemCodePage;
var
  langinfo: pchar;
begin
{$ifdef FPCRTL_FILESYSTEM_UTF8}
  if stdcp=scpFileSystemSingleByte then
    begin
      result:=CP_UTF8;
      exit;
    end;
{$endif}
  { if none of the relevant LC_* environment variables are set, fall back to
    UTF-8 (this happens under some versions of OS X for GUI applications, which
    otherwise get CP_ASCII) }
  if envvarset('LC_ALL') or
     envvarset('LC_CTYPE') or
     envvarset('LANG') then
    begin
      langinfo:=nl_langinfo(CODESET);
      { there's a bug in the Mac OS X 10.5 libc (based on FreeBSD's)
        that causes it to return an empty string of UTF-8 locales
        -> patch up (and in general, UTF-8 is a good default on
        Unix platforms) }
      if not assigned(langinfo) or
         (langinfo^=#0) then
        langinfo:='UTF-8';
      Result:= GetCodepageByName(ansistring(langinfo));
    end
  else
    Result:=unixcp.GetSystemCodepage;
end;

procedure SetStdIOCodePage(var T: Text); inline;
begin
  case TextRec(T).Mode of
    fmInput:TextRec(T).CodePage:=GetStandardCodePage(scpConsoleInput);
    fmOutput:TextRec(T).CodePage:=GetStandardCodePage(scpConsoleOutput);
  end;
end;

procedure SetStdIOCodePages; inline;
begin
  SetStdIOCodePage(system.Input);
  SetStdIOCodePage(system.Output);
  SetStdIOCodePage(system.ErrOutput);
  SetStdIOCodePage(system.StdOut);
  SetStdIOCodePage(system.StdErr);
end;
{$endif FPC_HAS_CPSTRING}

{$endif}

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
 {$ifndef hascompareoptions}
  CompareTextWideStringProc:= @CompareTextWideString;
 {$endif}
{$ifdef unicodeversion}
  Unicode2AnsiMoveProc:= @Wide2AnsiMove;
  Ansi2UnicodeMoveProc:= @Ansi2WideMove;

  UpperUnicodeStringProc:= @UpperWideString;
  LowerUnicodeStringProc:= @LowerWideString;

  CompareUnicodeStringProc:= @CompareWideString;
 {$ifndef hascompareoptions}
  CompareTextUnicodeStringProc:= @CompareTextWideString;
 {$endif}
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
 {$ifdef mse_fpc_3}
  GetStandardCodePageProc:=@GetStandardCodePage;
 {$endif}
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

{$ifdef mse_fpc_3}
  { set the DefaultSystemCodePage }
  DefaultSystemCodePage:=GetStandardCodePage(scpAnsi);
  DefaultFileSystemCodePage:=GetStandardCodePage(scpFileSystemSingleByte);
  DefaultRTLFileSystemCodePage:=DefaultFileSystemCodePage;

  {$ifdef FPC_HAS_CPSTRING}
  SetStdIOCodePages;
  {$endif FPC_HAS_CPSTRING}
{$endif}

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
