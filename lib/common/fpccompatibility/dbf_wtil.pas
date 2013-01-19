unit dbf_wtil;

{$I dbf_common.inc}

interface

{$ifndef WINDOWS}
uses
{$ifdef FPC}
  BaseUnix,
{$else}
  Libc, 
{$endif}
  Types, SysUtils, Classes;

const
  LCID_INSTALLED = $00000001;  { installed locale ids }
  LCID_SUPPORTED = $00000002;  { supported locale ids }
  CP_INSTALLED   = $00000001;  { installed code page ids }
  CP_SUPPORTED   = $00000002;  { supported code page ids }
(*
 *  Language IDs.
 *
 *  The following two combinations of primary language ID and
 *  sublanguage ID have special semantics:
 *
 *    Primary Language ID   Sublanguage ID      Result
 *    -------------------   ---------------     ------------------------
 *    LANG_NEUTRAL          SUBLANG_NEUTRAL     Language neutral
 *    LANG_NEUTRAL          SUBLANG_DEFAULT     User default language
 *    LANG_NEUTRAL          SUBLANG_SYS_DEFAULT System default language
 *)
{ Primary language IDs. }
  LANG_NEUTRAL                         = $00;
  LANG_AFRIKAANS                       = $36;
  LANG_ALBANIAN                        = $1c;
  LANG_ARABIC                          = $01;
  LANG_BASQUE                          = $2d;
  LANG_BELARUSIAN                      = $23;
  LANG_BULGARIAN                       = $02;
  LANG_CATALAN                         = $03;
  LANG_CHINESE                         = $04;
  LANG_CROATIAN                        = $1a;
  LANG_CZECH                           = $05;
  LANG_DANISH                          = $06;
  LANG_DUTCH                           = $13;
  LANG_ENGLISH                         = $09;
  LANG_ESTONIAN                        = $25;
  LANG_FAEROESE                        = $38;
  LANG_FARSI                           = $29;
  LANG_FINNISH                         = $0b;
  LANG_FRENCH                          = $0c;
  LANG_GERMAN                          = $07;
  LANG_GREEK                           = $08;
  LANG_HEBREW                          = $0d;
  LANG_HUNGARIAN                       = $0e;
  LANG_ICELANDIC                       = $0f;
  LANG_INDONESIAN                      = $21;
  LANG_ITALIAN                         = $10;
  LANG_JAPANESE                        = $11;
  LANG_KOREAN                          = $12;
  LANG_LATVIAN                         = $26;
  LANG_LITHUANIAN                      = $27;
  LANG_NORWEGIAN                       = $14;
  LANG_POLISH                          = $15;
  LANG_PORTUGUESE                      = $16;
  LANG_ROMANIAN                        = $18;
  LANG_RUSSIAN                         = $19;
  LANG_SERBIAN                         = $1a;
  LANG_SLOVAK                          = $1b;
  LANG_SLOVENIAN                       = $24;
  LANG_SPANISH                         = $0a;
  LANG_SWEDISH                         = $1d;
  LANG_THAI                            = $1e;
  LANG_TURKISH                         = $1f;
  LANG_UKRAINIAN                       = $22;
  LANG_VIETNAMESE                      = $2a;
{ Sublanguage IDs. }
  { The name immediately following SUBLANG_ dictates which primary
    language ID that sublanguage ID can be combined with to form a
    valid language ID.
  }
  SUBLANG_NEUTRAL                      = $00;    { language neutral }
  SUBLANG_DEFAULT                      = $01;    { user default }
  SUBLANG_SYS_DEFAULT                  = $02;    { system default }
  SUBLANG_ARABIC_SAUDI_ARABIA          = $01;    { Arabic (Saudi Arabia) }
  SUBLANG_ARABIC_IRAQ                  = $02;    { Arabic (Iraq) }
  SUBLANG_ARABIC_EGYPT                 = $03;    { Arabic (Egypt) }
  SUBLANG_ARABIC_LIBYA                 = $04;    { Arabic (Libya) }
  SUBLANG_ARABIC_ALGERIA               = $05;    { Arabic (Algeria) }
  SUBLANG_ARABIC_MOROCCO               = $06;    { Arabic (Morocco) }
  SUBLANG_ARABIC_TUNISIA               = $07;    { Arabic (Tunisia) }
  SUBLANG_ARABIC_OMAN                  = $08;    { Arabic (Oman) }
  SUBLANG_ARABIC_YEMEN                 = $09;    { Arabic (Yemen) }
  SUBLANG_ARABIC_SYRIA                 = $0a;    { Arabic (Syria) }
  SUBLANG_ARABIC_JORDAN                = $0b;    { Arabic (Jordan) }
  SUBLANG_ARABIC_LEBANON               = $0c;    { Arabic (Lebanon) }
  SUBLANG_ARABIC_KUWAIT                = $0d;    { Arabic (Kuwait) }
  SUBLANG_ARABIC_UAE                   = $0e;    { Arabic (U.A.E) }
  SUBLANG_ARABIC_BAHRAIN               = $0f;    { Arabic (Bahrain) }
  SUBLANG_ARABIC_QATAR                 = $10;    { Arabic (Qatar) }
  SUBLANG_CHINESE_TRADITIONAL          = $01;    { Chinese (Taiwan) }
  SUBLANG_CHINESE_SIMPLIFIED           = $02;    { Chinese (PR China) }
  SUBLANG_CHINESE_HONGKONG             = $03;    { Chinese (Hong Kong) }
  SUBLANG_CHINESE_SINGAPORE            = $04;    { Chinese (Singapore) }
  SUBLANG_DUTCH                        = $01;    { Dutch }
  SUBLANG_DUTCH_BELGIAN                = $02;    { Dutch (Belgian) }
  SUBLANG_ENGLISH_US                   = $01;    { English (USA) }
  SUBLANG_ENGLISH_UK                   = $02;    { English (UK) }
  SUBLANG_ENGLISH_AUS                  = $03;    { English (Australian) }
  SUBLANG_ENGLISH_CAN                  = $04;    { English (Canadian) }
  SUBLANG_ENGLISH_NZ                   = $05;    { English (New Zealand) }
  SUBLANG_ENGLISH_EIRE                 = $06;    { English (Irish) }
  SUBLANG_ENGLISH_SOUTH_AFRICA         = $07;    { English (South Africa) }
  SUBLANG_ENGLISH_JAMAICA              = $08;    { English (Jamaica) }
  SUBLANG_ENGLISH_CARIBBEAN            = $09;    { English (Caribbean) }
  SUBLANG_ENGLISH_BELIZE               = $0a;    { English (Belize) }
  SUBLANG_ENGLISH_TRINIDAD             = $0b;    { English (Trinidad) }
  SUBLANG_FRENCH                       = $01;    { French }
  SUBLANG_FRENCH_BELGIAN               = $02;    { French (Belgian) }
  SUBLANG_FRENCH_CANADIAN              = $03;    { French (Canadian) }
  SUBLANG_FRENCH_SWISS                 = $04;    { French (Swiss) }
  SUBLANG_FRENCH_LUXEMBOURG            = $05;    { French (Luxembourg) }
  SUBLANG_GERMAN                       = $01;    { German }
  SUBLANG_GERMAN_SWISS                 = $02;    { German (Swiss) }
  SUBLANG_GERMAN_AUSTRIAN              = $03;    { German (Austrian) }
  SUBLANG_GERMAN_LUXEMBOURG            = $04;    { German (Luxembourg) }
  SUBLANG_GERMAN_LIECHTENSTEIN         = $05;    { German (Liechtenstein) }
  SUBLANG_ITALIAN                      = $01;    { Italian }
  SUBLANG_ITALIAN_SWISS                = $02;    { Italian (Swiss) }
  SUBLANG_KOREAN                       = $01;    { Korean (Extended Wansung) }
  SUBLANG_KOREAN_JOHAB                 = $02;    { Korean (Johab) }
  SUBLANG_NORWEGIAN_BOKMAL             = $01;    { Norwegian (Bokmal) }
  SUBLANG_NORWEGIAN_NYNORSK            = $02;    { Norwegian (Nynorsk) }
  SUBLANG_PORTUGUESE                   = $02;    { Portuguese }
  SUBLANG_PORTUGUESE_BRAZILIAN         = $01;    { Portuguese (Brazilian) }
  SUBLANG_SERBIAN_LATIN                = $02;    { Serbian (Latin) }
  SUBLANG_SERBIAN_CYRILLIC             = $03;    { Serbian (Cyrillic) }
  SUBLANG_SPANISH                      = $01;    { Spanish (Castilian) }
  SUBLANG_SPANISH_MEXICAN              = $02;    { Spanish (Mexican) }
  SUBLANG_SPANISH_MODERN               = $03;    { Spanish (Modern) }
  SUBLANG_SPANISH_GUATEMALA            = $04;    { Spanish (Guatemala) }
  SUBLANG_SPANISH_COSTA_RICA           = $05;    { Spanish (Costa Rica) }
  SUBLANG_SPANISH_PANAMA               = $06;    { Spanish (Panama) }
  SUBLANG_SPANISH_DOMINICAN_REPUBLIC   = $07;  { Spanish (Dominican Republic) }
  SUBLANG_SPANISH_VENEZUELA            = $08;    { Spanish (Venezuela) }
  SUBLANG_SPANISH_COLOMBIA             = $09;    { Spanish (Colombia) }
  SUBLANG_SPANISH_PERU                 = $0a;    { Spanish (Peru) }
  SUBLANG_SPANISH_ARGENTINA            = $0b;    { Spanish (Argentina) }
  SUBLANG_SPANISH_ECUADOR              = $0c;    { Spanish (Ecuador) }
  SUBLANG_SPANISH_CHILE                = $0d;    { Spanish (Chile) }
  SUBLANG_SPANISH_URUGUAY              = $0e;    { Spanish (Uruguay) }
  SUBLANG_SPANISH_PARAGUAY             = $0f;    { Spanish (Paraguay) }
  SUBLANG_SPANISH_BOLIVIA              = $10;    { Spanish (Bolivia) }
  SUBLANG_SPANISH_EL_SALVADOR          = $11;    { Spanish (El Salvador) }
  SUBLANG_SPANISH_HONDURAS             = $12;    { Spanish (Honduras) }
  SUBLANG_SPANISH_NICARAGUA            = $13;    { Spanish (Nicaragua) }
  SUBLANG_SPANISH_PUERTO_RICO          = $14;    { Spanish (Puerto Rico) }
  SUBLANG_SWEDISH                      = $01;    { Swedish }
  SUBLANG_SWEDISH_FINLAND              = $02;    { Swedish (Finland) }
{ Sorting IDs. }
  SORT_DEFAULT                         = $0;     { sorting default }
  SORT_JAPANESE_XJIS                   = $0;     { Japanese XJIS order }
  SORT_JAPANESE_UNICODE                = $1;     { Japanese Unicode order }
  SORT_CHINESE_BIG5                    = $0;     { Chinese BIG5 order }
  SORT_CHINESE_PRCP                    = $0;     { PRC Chinese Phonetic order }
  SORT_CHINESE_UNICODE                 = $1;     { Chinese Unicode order }
  SORT_CHINESE_PRC                     = $2;     { PRC Chinese Stroke Count order }
  SORT_KOREAN_KSC                      = $0;     { Korean KSC order }
  SORT_KOREAN_UNICODE                  = $1;     { Korean Unicode order }
  SORT_GERMAN_PHONE_BOOK               = $1;     { German Phone Book order }
(*
 *  A language ID is a 16 bit value which is the combination of a
 *  primary language ID and a secondary language ID.  The bits are
 *  allocated as follows:
 *
 *       +-----------------------+-------------------------+
 *       |     Sublanguage ID    |   Primary Language ID   |
 *       +-----------------------+-------------------------+
 *        15                   10 9                       0   bit
 *
 *
 *
 *  A locale ID is a 32 bit value which is the combination of a
 *  language ID, a sort ID, and a reserved area.  The bits are
 *  allocated as follows:
 *
 *       +-------------+---------+-------------------------+
 *       |   Reserved  | Sort ID |      Language ID        |
 *       +-------------+---------+-------------------------+
 *        31         20 19     16 15                      0   bit
 *
 *)
{ Default System and User IDs for language and locale. }
  LANG_SYSTEM_DEFAULT   = (SUBLANG_SYS_DEFAULT shl 10) or LANG_NEUTRAL;
  LANG_USER_DEFAULT     = (SUBLANG_DEFAULT shl 10) or LANG_NEUTRAL;
  LOCALE_SYSTEM_DEFAULT = (SORT_DEFAULT shl 16) or LANG_SYSTEM_DEFAULT;
  LOCALE_USER_DEFAULT   = (SORT_DEFAULT shl 16) or LANG_USER_DEFAULT;

(*
  Error const of File Locking
*)
{$ifdef FPC}
  ERROR_LOCK_VIOLATION = ESysEACCES;
{$else}  
  ERROR_LOCK_VIOLATION = EACCES;
{$endif}  

{ MBCS and Unicode Translation Flags. }
  MB_PRECOMPOSED = 1; { use precomposed chars }
  MB_COMPOSITE = 2; { use composite chars }
  MB_USEGLYPHCHARS = 4; { use glyph chars, not ctrl chars }

type
  LCID = DWORD;
  BOOL = LongBool;
  PBOOL = ^BOOL;
  WCHAR = WideChar;
  PWChar = PWideChar;
  LPSTR = PAnsiChar;
  PLPSTR = ^LPSTR;
  LPCSTR = PAnsiChar;
  LPCTSTR = PAnsiChar; { should be PWideChar if UNICODE }
  LPTSTR = PAnsiChar; { should be PWideChar if UNICODE }
  LPWSTR = PWideChar;
  PLPWSTR = ^LPWSTR;
  LPCWSTR = PWideChar;

  { System time is represented with the following structure: }
  PSystemTime = ^TSystemTime;
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;

  TFarProc = Pointer;
  TFNLocaleEnumProc = TFarProc;
  TFNCodepageEnumProc = TFarProc;
  TFNDateFmtEnumProc = TFarProc;
  TFNTimeFmtEnumProc = TFarProc;
  TFNCalInfoEnumProc = TFarProc;

function LockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD; nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: DWORD): BOOL;
function UnlockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD; nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: DWORD): BOOL;
procedure GetLocalTime(var lpSystemTime: TSystemTime);
function GetOEMCP: Cardinal;
function GetACP: Cardinal;
function OemToChar(lpszSrc: PChar; lpszDst: PChar): BOOL;
function CharToOem(lpszSrc: PChar; lpszDst: PChar): BOOL;
function OemToCharBuff(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
function CharToOemBuff(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
function MultiByteToWideChar(CodePage: DWORD; dwFlags: DWORD; const lpMultiByteStr: LPCSTR; cchMultiByte: Integer; lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer;
function WideCharToMultiByte(CodePage: DWORD; dwFlags: DWORD; lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR; cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer;
function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer;
function EnumSystemCodePages(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL;
function EnumSystemLocales(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL;
function GetUserDefaultLCID: LCID;

{$ifdef FPC}
function  GetLastError: Integer;
procedure SetLastError(Value: Integer);
{$endif}
{$endif}

implementation

{$ifndef WINDOWS}
{$ifdef FPC}
uses
  unix;
{$endif}

(*
NAME
       fcntl - manipulate file descriptor

SYNOPSIS
       #include <unistd.h>
       #include <fcntl.h>

       int fcntl(int fd, int cmd);
       int fcntl(int fd, int cmd, long arg);
       int fcntl(int fd, int cmd, struct flock * lock);

DESCRIPTION
       fcntl  performs one of various miscellaneous operations on
       fd.  The operation in question is determined by cmd:

       F_GETLK, F_SETLK and F_SETLKW are used to  manage  discreð
       tionary  file locks.  The third argument lock is a pointer
       to a struct flock (that may be overwritten by this  call).

       F_GETLK
              Return  the  flock  structure that prevents us from
              obtaining the lock, or set the l_type field of  the
              lock to F_UNLCK if there is no obstruction.

       F_SETLK
              The lock is set (when l_type is F_RDLCK or F_WRLCK)
              or cleared (when it is F_UNLCK).  If  the  lock  is
              held by someone else, this call returns -1 and sets
              errno to EACCES or EAGAIN.

       F_SETLKW
              Like F_SETLK, but instead of returning an error  we
              wait for the lock to be released.  If a signal that
              is to be caught is received while fcntl is waiting,
              it is interrupted and (after the signal handler has
              returned) returns immediately (with return value -1
              and errno set to EINTR).

       Using  these  mechanisms,  a  program  can implement fully
       asynchronous I/O without using select(2) or  poll(2)  most
       of the time.

       The  use of O_ASYNC, F_GETOWN, F_SETOWN is specific to BSD
       and Linux.   F_GETSIG  and  F_SETSIG  are  Linux-specific.
       POSIX  has asynchronous I/O and the aio_sigevent structure
       to achieve similar things; these  are  also  available  in
       Linux as part of the GNU C Library (Glibc).

RETURN VALUE
       For  a  successful  call,  the return value depends on the
       operation:

       F_GETFD  Value of flag.

       F_GETFL  Value of flags.

       F_GETOWN Value of descriptor owner.

       F_GETSIG Value of signal sent when read or  write  becomes
                possible,   or   zero   for   traditional   SIGIO
                behaviour.

       All other commands
                Zero.

       On error, -1 is returned, and errno is set  appropriately.

ERRORS
       EACCES   Operation  is  prohibited  by locks held by other
                processes.

       EAGAIN   Operation is prohibited because the file has been
                memory-mapped by another process.

       EBADF    fd is not an open file descriptor.

       EDEADLK  It  was detected that the specified F_SETLKW comð
                mand would cause a deadlock.

       EFAULT   lock is outside your accessible address space.

       EINTR    For F_SETLKW, the command was  interrupted  by  a
                signal.  For F_GETLK and F_SETLK, the command was
                interrupted by  a  signal  before  the  lock  was
                checked  or acquired.  Most likely when locking a
                remote file (e.g.  locking  over  NFS),  but  can
                sometimes happen locally.

       EINVAL   For  F_DUPFD,  arg is negative or is greater than
                the maximum allowable value.  For  F_SETSIG,  arg
                is not an allowable signal number.

       EMFILE   For  F_DUPFD, the process already has the maximum
                number of file descriptors open.

       ENOLCK   Too many segment locks open, lock table is  full,
                or a remote locking protocol failed (e.g. locking
                over NFS).

       EPERM    Attempted to clear the O_APPEND flag  on  a  file
                that has the append-only attribute set.

typedef long  __kernel_off_t;
typedef int   __kernel_pid_t;

struct flock {
        short l_type;
        short l_whence;
        off_t l_start;
        off_t l_len;
        pid_t l_pid;
};

whence:
--------
const
  SEEK_SET        = 0;      { Seek from beginning of file.  }
  SEEK_CUR        = 1;      { Seek from current position.  }
  SEEK_END        = 2;      { Seek from end of file.  }

{ Old BSD names for the same constants; just for compatibility.  }
  L_SET           = SEEK_SET;
  L_INCR          = SEEK_CUR;
  L_XTND          = SEEK_END;
*)


{$ifdef FPC}
const
   F_RDLCK = 0;
   F_WRLCK = 1;
   F_UNLCK = 2;
   F_EXLCK = 4;
   F_SHLCK = 8;

   LOCK_SH = 1;
   LOCK_EX = 2;
   LOCK_NB = 4;
   LOCK_UN = 8;

   LOCK_MAND = 32;
   LOCK_READ = 64;
   LOCK_WRITE = 128;
   LOCK_RW = 192;

   EACCES = ESysEACCES;
   EAGAIN = ESysEAGAIN;
{$endif}

function LockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD; nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: DWORD): BOOL;
var
  FLockInfo: {$ifdef FPC}BaseUnix.FLock{$else}TFLock{$endif};
  FLastError: Cardinal;
begin
  FLockInfo.l_type := F_WRLCK;
  FLockInfo.l_whence := SEEK_SET;
  FLockInfo.l_start := dwFileOffsetLow;
  FLockInfo.l_len := nNumberOfBytesToLockLow;
  FLockInfo.l_pid := {$ifdef FPC}fpgetpid{$else}getpid{$endif}();
  Result := {$ifdef FPC}fpfcntl{$else}fcntl{$endif}(hFile, F_SETLK, FLockInfo) <> -1;
  if not Result then
  begin
    FLastError := GetLastError();
    if (FLastError = EACCES) or (FLastError = EAGAIN) then
      SetLastError(ERROR_LOCK_VIOLATION)
    else
      Result := True; // If errno is ENOLCK or EINVAL
  end;
end;

function UnlockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD; nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: DWORD): BOOL;
var
  FLockInfo: {$ifdef FPC}BaseUnix.FLock{$else}TFLock{$endif};
begin
  FLockInfo.l_type := F_UNLCK;
  FLockInfo.l_whence := SEEK_SET;
  FLockInfo.l_start := dwFileOffsetLow;
  FLockInfo.l_len := nNumberOfBytesToUnLockLow;
  FLockInfo.l_pid := {$ifdef FPC}fpgetpid{$else}getpid{$endif}();
  Result := {$ifdef FPC}fpfcntl{$else}fcntl{$endif}(hFile, F_SETLK, FLockInfo) <> -1;
end;

procedure DateTimeToSystemTime(const DateTime: TDateTime; var SystemTime: TSystemTime);
begin
  with SystemTime do
  begin
    DecodeDateFully(DateTime, wYear, wMonth, wDay, wDayOfWeek);
    Dec(wDayOfWeek);
    DecodeTime(DateTime, wHour, wMinute, wSecond, wMilliseconds);
  end;
end;

function SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do
  begin
    Result := EncodeDate(wYear, wMonth, wDay);
    if Result >= 0 then
      Result := Result + EncodeTime(wHour, wMinute, wSecond, wMilliSeconds)
    else
      Result := Result - EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
  end;
end;

procedure GetLocalTime(var lpSystemTime: TSystemTime);
begin
  DateTimeToSystemTime(NOW, lpSystemTime);
end;

function GetOEMCP: Cardinal;
begin
{$ifdef HUNGARIAN}
  Result := 852;
{$else}
  Result := $FFFFFFFF;
{$endif}
end;

function GetACP: Cardinal;
begin
{$ifdef HUNGARIAN}
  Result := 1250;
{$else}
  Result := 1252;
{$endif}
end;

{$ifdef HUNGARIAN}

procedure OemHunHun(AnsiDst: PChar; cchDstLength: DWORD);
var
  Count: DWORD;
begin
  if Assigned(AnsiDst) and (cchDstLength<>0) then
  begin
    for Count:=0 to Pred(cchDstLength) do
    begin
      case AnsiDst^ of
        #160:      AnsiDst^:= #225; {á}
        #143,#181: AnsiDst^:= #193; {Á}
        #130:      AnsiDst^:= #233; {é}
        #144:      AnsiDst^:= #201; {É}
        #161:      AnsiDst^:= #237; {í}
        #141,#214: AnsiDst^:= #205; {Í}
        #162:      AnsiDst^:= #243; {ó}
        #149,#224: AnsiDst^:= #211; {Ó}
        #148:      AnsiDst^:= #246; {ö}
        #153:      AnsiDst^:= #214; {Ö}
        #147,#139: AnsiDst^:= #245; {õ}
        #167,#138: AnsiDst^:= #213; {Õ}
        #163:      AnsiDst^:= #250; {ú}
        #151,#233: AnsiDst^:= #218; {Ú}
        #129:      AnsiDst^:= #252; {ü}
        #154:      AnsiDst^:= #220; {Ü}
        #150,#251: AnsiDst^:= #251; {û}
        #152,#235: AnsiDst^:= #219; {Û}
      end;
      Inc(AnsiDst);
    end;
  end;
end;

procedure AnsiHunHun(AnsiDst: PChar; cchDstLength: DWORD);
var
  Count: DWORD;
begin
  if Assigned(AnsiDst) and (cchDstLength<>0) then
  begin
    for Count:=0 to Pred(cchDstLength) do
    begin
      case AnsiDst^ of
        #225:      AnsiDst^:= #160; {á}
        #193:      AnsiDst^:= #181; {Á}
        #233:      AnsiDst^:= #130; {é}
        #201:      AnsiDst^:= #144; {É}
        #237:      AnsiDst^:= #161; {í}
        #205:      AnsiDst^:= #214; {Í}
        #243:      AnsiDst^:= #162; {ó}
        #211:      AnsiDst^:= #224; {Ó}
        #246:      AnsiDst^:= #148; {ö}
        #214:      AnsiDst^:= #153; {Ö}
        #245:      AnsiDst^:= #139; {õ}
        #213:      AnsiDst^:= #138; {Õ}
        #250:      AnsiDst^:= #163; {ú}
        #218:      AnsiDst^:= #233; {Ú}
        #252:      AnsiDst^:= #129; {ü}
        #220:      AnsiDst^:= #154; {Ü}
        #251:      AnsiDst^:= #251; {û}
        #219:      AnsiDst^:= #235; {Û}
      end;
      Inc(AnsiDst);
    end;
  end;
end;

{$endif}

function OemToChar(lpszSrc: PChar; lpszDst: PChar): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrCopy(lpszDst, lpszSrc);
  Result := true;
end;

function CharToOem(lpszSrc: PChar; lpszDst: PChar): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrCopy(lpszDst, lpszSrc);
  Result := true;
end;

function OemToCharBuff(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrLCopy(lpszDst, lpszSrc, cchDstLength);
{$ifdef HUNGARIAN}
  OemHunHun(lpszDst, cchDstLength);
{$endif}
  Result := true;
end;

function CharToOemBuff(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrLCopy(lpszDst, lpszSrc, cchDstLength);
{$ifdef HUNGARIAN}
  AnsiHunHun(lpszDst, cchDstLength);
{$endif}
  Result := true;
end;

function MultiByteToWideChar(CodePage: DWORD; dwFlags: DWORD; const lpMultiByteStr: LPCSTR; cchMultiByte: Integer; lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer;
var
  TempA: AnsiString;
  TempW: WideString;
begin
  TempA := String(lpMultiByteStr^);
  TempW := TempA;
  Result := Length(TempW);
  System.Move(TempW, lpWideCharStr^, Result);
end;

function WideCharToMultiByte(CodePage: DWORD; dwFlags: DWORD; lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR; cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer;
var
  TempA: AnsiString;
  TempW: WideString;
begin
  TempW := WideString(lpWideCharStr^);
  TempA := TempW;
  Result := Length(TempA);
  System.Move(TempA, lpMultiByteStr^, Result);
end;

function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer;
begin
  Result := StrLComp(lpString1, lpString2, cchCount1) + 2;
  if Result > 2 then Result := 3;
  if Result < 2 then Result := 1;
end;

function EnumSystemCodePages(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL;
begin
  Result := True;
end;

function EnumSystemLocales(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL;
begin
  Result := True;
end;

function GetUserDefaultLCID: LCID;
begin
  Result := LANG_ENGLISH or (SUBLANG_ENGLISH_UK shl 10);
end;

{$ifdef FPC}

function GetLastError: Integer;
begin
  Result := FpGetErrno;
end;

procedure SetLastError(Value: Integer);
begin
  FpSetErrno(Value);
end;

{$endif}
{$endif}

end.
