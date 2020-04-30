uses
  DosCalls, DosCall2;

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

(*
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
*)
{$PACKRECORDS 1}
type
  Str3 = string [3];

  TLocaleRec = packed record
   case boolean of
    false:
     (LangCode: Str3;
      SubLangCode: Str3;
      SubLangID: byte;
      LangID: byte);
    true:
     (LangNum: dword;
      SubLangNum: dword;
      LCID: word)
  end;


const
  MaxLocale = 108;
  MinRealLocale = 4;
  LocaleMap: array [1..MaxLocale] of TLocaleRec = (
  (LangCode: #0;
   SubLangCode: #0;
   SubLangID: SUBLANG_DEFAULT; { user default }
   LangID: LANG_NEUTRAL),
  (LangCode: #0;
   SubLangCode: #0;
   SubLangID: SUBLANG_SYS_DEFAULT; { system default }
   LangID: LANG_NEUTRAL),
  (LangCode: 'UNI';
   SubLangCode: 'V';
   SubLangID: SUBLANG_NEUTRAL; { language neutral }
   LangID: LANG_NEUTRAL),
  (LangCode: 'AR';
   SubLangCode: '_SA';
   SubLangID: SUBLANG_ARABIC_SAUDI_ARABIA; { Arabic (Saudi Arabia) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_IQ';
   SubLangID: SUBLANG_ARABIC_IRAQ; { Arabic (Iraq) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_EG';
   SubLangID: SUBLANG_ARABIC_EGYPT; { Arabic (Egypt) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_LY';
   SubLangID: SUBLANG_ARABIC_LIBYA; { Arabic (Libya) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_DZ';
   SubLangID: SUBLANG_ARABIC_ALGERIA; { Arabic (Algeria) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_MA';
   SubLangID: SUBLANG_ARABIC_MOROCCO; { Arabic (Morocco) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_TN';
   SubLangID: SUBLANG_ARABIC_TUNISIA; { Arabic (Tunisia) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_OM';
   SubLangID: SUBLANG_ARABIC_OMAN; { Arabic (Oman) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_YE';
   SubLangID: SUBLANG_ARABIC_YEMEN; { Arabic (Yemen) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_SY';
   SubLangID: SUBLANG_ARABIC_SYRIA; { Arabic (Syria) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_JO';
   SubLangID: SUBLANG_ARABIC_JORDAN; { Arabic (Jordan) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_LB';
   SubLangID: SUBLANG_ARABIC_LEBANON; { Arabic (Lebanon) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_KW';
   SubLangID: SUBLANG_ARABIC_KUWAIT; { Arabic (Kuwait) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_AE';
   SubLangID: SUBLANG_ARABIC_UAE; { Arabic (U.A.E) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_BH';
   SubLangID: SUBLANG_ARABIC_BAHRAIN; { Arabic (Bahrain) }
   LangID: LANG_ARABIC),
  (LangCode: 'AR';
   SubLangCode: '_QA';
   SubLangID: SUBLANG_ARABIC_QATAR; { Arabic (Qatar) }
   LangID: LANG_ARABIC),
  (LangCode: 'BG';
   SubLangCode: '_BG';
   SubLangID: 0;
   LangID: LANG_BULGARIAN),
  (LangCode: 'CA';
   SubLangCode: '_ES';
   SubLangID: 0;
   LangID: LANG_CATALAN),
  (LangCode: 'ZH';
   SubLangCode: '_TW';
   SubLangID: SUBLANG_CHINESE_TRADITIONAL; { Chinese (Taiwan) }
   LangID: LANG_CHINESE),
  (LangCode: 'ZH';
   SubLangCode: '_CN';
   SubLangID: SUBLANG_CHINESE_SIMPLIFIED; { Chinese (PR China) }
   LangID: LANG_CHINESE),
  (LangCode: 'ZH';
   SubLangCode: '_HK';
   SubLangID: SUBLANG_CHINESE_HONGKONG; { Chinese (Hong Kong) }
   LangID: LANG_CHINESE),
  (LangCode: 'ZH';
   SubLangCode: '_SG';
   SubLangID: SUBLANG_CHINESE_SINGAPORE; { Chinese (Singapore) }
   LangID: LANG_CHINESE),
  (LangCode: 'CS';
   SubLangCode: '_CZ';
   SubLangID: 0;
   LangID: LANG_CZECH),
  (LangCode: 'DA';
   SubLangCode: '_DK';
   SubLangID: 0;
   LangID: LANG_DANISH),
  (LangCode: 'DE';
   SubLangCode: '_DE';
   SubLangID: SUBLANG_GERMAN; { German }
   LangID: LANG_GERMAN),
  (LangCode: 'DE';
   SubLangCode: '_CH';
   SubLangID: SUBLANG_GERMAN_SWISS; { German (Swiss) }
   LangID: LANG_GERMAN),
  (LangCode: 'DE';
   SubLangCode: '_AT';
   SubLangID: SUBLANG_GERMAN_AUSTRIAN; { German (Austrian) }
   LangID: LANG_GERMAN),
  (LangCode: 'DE';
   SubLangCode: '_LU';
   SubLangID: SUBLANG_GERMAN_LUXEMBOURG; { German (Luxembourg) }
   LangID: LANG_GERMAN),
  (LangCode: 'DE';
   SubLangCode: '_LI';
   SubLangID: SUBLANG_GERMAN_LIECHTENSTEIN; { German (Liechtenstein) }
   LangID: LANG_GERMAN),
  (LangCode: 'EL';
   SubLangCode: '_GR';
   SubLangID: 0;
   LangID: LANG_GREEK),
  (LangCode: 'EN';
   SubLangCode: '_US';
   SubLangID: SUBLANG_ENGLISH_US; { English (USA) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_GB';
   SubLangID: SUBLANG_ENGLISH_UK; { English (UK) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_AU';
   SubLangID: SUBLANG_ENGLISH_AUS; { English (Australian) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_CA';
   SubLangID: SUBLANG_ENGLISH_CAN; { English (Canadian) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_NZ';
   SubLangID: SUBLANG_ENGLISH_NZ; { English (New Zealand) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_IE';
   SubLangID: SUBLANG_ENGLISH_EIRE; { English (Irish) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_ZA';
   SubLangID: SUBLANG_ENGLISH_SOUTH_AFRICA; { English (South Africa) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_JM';
   SubLangID: SUBLANG_ENGLISH_JAMAICA; { English (Jamaica) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN_';
   SubLangCode: '029';
   SubLangID: SUBLANG_ENGLISH_CARIBBEAN; { English (Caribbean) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_BZ';
   SubLangID: SUBLANG_ENGLISH_BELIZE; { English (Belize) }
   LangID: LANG_ENGLISH),
  (LangCode: 'EN';
   SubLangCode: '_TT';
   SubLangID: SUBLANG_ENGLISH_TRINIDAD; { English (Trinidad) }
   LangID: LANG_ENGLISH),
  (LangCode: 'ES';
   SubLangCode: '_ES';
   SubLangID: SUBLANG_SPANISH; { Spanish (Castilian) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_MX';
   SubLangID: SUBLANG_SPANISH_MEXICAN; { Spanish (Mexican) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_EM';
   SubLangID: SUBLANG_SPANISH_MODERN; { Spanish (Modern) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_GT';
   SubLangID: SUBLANG_SPANISH_GUATEMALA; { Spanish (Guatemala) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_CR';
   SubLangID: SUBLANG_SPANISH_COSTA_RICA; { Spanish (Costa Rica) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_PA';
   SubLangID: SUBLANG_SPANISH_PANAMA; { Spanish (Panama) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_DO';
   SubLangID: SUBLANG_SPANISH_DOMINICAN_REPUBLIC; { Spanish (Dominican Republic) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_VE';
   SubLangID: SUBLANG_SPANISH_VENEZUELA; { Spanish (Venezuela) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_CO';
   SubLangID: SUBLANG_SPANISH_COLOMBIA; { Spanish (Colombia) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_PE';
   SubLangID: SUBLANG_SPANISH_PERU; { Spanish (Peru) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_AR';
   SubLangID: SUBLANG_SPANISH_ARGENTINA; { Spanish (Argentina) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_EC';
   SubLangID: SUBLANG_SPANISH_ECUADOR; { Spanish (Ecuador) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_CL';
   SubLangID: SUBLANG_SPANISH_CHILE; { Spanish (Chile) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_UY';
   SubLangID: SUBLANG_SPANISH_URUGUAY; { Spanish (Uruguay) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_PY';
   SubLangID: SUBLANG_SPANISH_PARAGUAY; { Spanish (Paraguay) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_BO';
   SubLangID: SUBLANG_SPANISH_BOLIVIA; { Spanish (Bolivia) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_SV';
   SubLangID: SUBLANG_SPANISH_EL_SALVADOR; { Spanish (El Salvador) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_HN';
   SubLangID: SUBLANG_SPANISH_HONDURAS; { Spanish (Honduras) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_NI';
   SubLangID: SUBLANG_SPANISH_NICARAGUA; { Spanish (Nicaragua) }
   LangID: LANG_SPANISH),
  (LangCode: 'ES';
   SubLangCode: '_PR';
   SubLangID: SUBLANG_SPANISH_PUERTO_RICO; { Spanish (Puerto Rico) }
   LangID: LANG_SPANISH),
  (LangCode: 'FI';
   SubLangCode: '_FI';
   SubLangID: 0;
   LangID: LANG_FINNISH),
  (LangCode: 'FR';
   SubLangCode: '_FR';
   SubLangID: SUBLANG_FRENCH; { French }
   LangID: LANG_FRENCH),
  (LangCode: 'FR';
   SubLangCode: '_BE';
   SubLangID: SUBLANG_FRENCH_BELGIAN; { French (Belgian) }
   LangID: LANG_FRENCH),
  (LangCode: 'FR';
   SubLangCode: '_CA';
   SubLangID: SUBLANG_FRENCH_CANADIAN; { French (Canadian) }
   LangID: LANG_FRENCH),
  (LangCode: 'FR';
   SubLangCode: '_CH';
   SubLangID: SUBLANG_FRENCH_SWISS; { French (Swiss) }
   LangID: LANG_FRENCH),
  (LangCode: 'FR';
   SubLangCode: '_LU';
   SubLangID: SUBLANG_FRENCH_LUXEMBOURG; { French (Luxembourg) }
   LangID: LANG_FRENCH),
  (LangCode: 'HE';
   SubLangCode: '_IL';
   SubLangID: 0;
   LangID: LANG_HEBREW),
  (LangCode: 'HU';
   SubLangCode: '_HU';
   SubLangID: 0;
   LangID: LANG_HUNGARIAN),
  (LangCode: 'IS';
   SubLangCode: '_IS';
   SubLangID: 0;
   LangID: LANG_ICELANDIC),
  (LangCode: 'IT';
   SubLangCode: '_IT';
   SubLangID: SUBLANG_ITALIAN; { Italian }
   LangID: LANG_ITALIAN),
  (LangCode: 'IT';
   SubLangCode: '_CH';
   SubLangID: SUBLANG_ITALIAN_SWISS; { Italian (Swiss) }
   LangID: LANG_ITALIAN),
  (LangCode: 'JA';
   SubLangCode: '_JP';
   SubLangID: 0;
   LangID: LANG_JAPANESE),
  (LangCode: 'KO';
   SubLangCode: '_KR';
   SubLangID: SUBLANG_KOREAN; { Korean (Extended Wansung) }
   LangID: LANG_KOREAN),
  (LangCode: 'KO';
   SubLangCode: '_';
   SubLangID: SUBLANG_KOREAN_JOHAB; { Korean (Johab) }
   LangID: LANG_KOREAN),
  (LangCode: 'NL';
   SubLangCode: '_NL';
   SubLangID: SUBLANG_DUTCH; { Dutch }
   LangID: LANG_DUTCH),
  (LangCode: 'NL';
   SubLangCode: '_BE';
   SubLangID: SUBLANG_DUTCH_BELGIAN; { Dutch (Belgian) }
   LangID: LANG_DUTCH),
  (LangCode: 'NB';
   SubLangCode: '_NO';
   SubLangID: SUBLANG_NORWEGIAN_BOKMAL; { Norwegian (Bokmal) }
   LangID: LANG_NORWEGIAN),
  (LangCode: 'NN';
   SubLangCode: '_NO';
   SubLangID: SUBLANG_NORWEGIAN_NYNORSK; { Norwegian (Nynorsk) }
   LangID: LANG_NORWEGIAN),
  (LangCode: 'PL';
   SubLangCode: '_PL';
   SubLangID: 0;
   LangID: LANG_POLISH),
  (LangCode: 'PT';
   SubLangCode: '_PT';
   SubLangID: SUBLANG_PORTUGUESE; { Portuguese }
   LangID: LANG_PORTUGUESE),
  (LangCode: 'PT';
   SubLangCode: '_BR';
   SubLangID: SUBLANG_PORTUGUESE_BRAZILIAN; { Portuguese (Brazilian) }
   LangID: LANG_PORTUGUESE),
  (LangCode: 'RO';
   SubLangCode: '_RO';
   SubLangID: 0;
   LangID: LANG_ROMANIAN),
  (LangCode: 'RU';
   SubLangCode: '_RU';
   SubLangID: 0;
   LangID: LANG_RUSSIAN),
  (LangCode: 'SR';
   SubLangCode: '_RS';
   SubLangID: SUBLANG_SERBIAN_LATIN; { Serbian (Latin) }
   LangID: LANG_SERBIAN),
  (LangCode: 'SR';
   SubLangCode: '_RS';
   SubLangID: SUBLANG_SERBIAN_CYRILLIC; { Serbian (Cyrillic) }
   LangID: LANG_SERBIAN),
  (LangCode: 'HR';
   SubLangCode: '_HR';
   SubLangID: 0;
   LangID: LANG_CROATIAN),
  (LangCode: 'SK';
   SubLangCode: '_SK';
   SubLangID: 0;
   LangID: LANG_SLOVAK),
  (LangCode: 'SQ';
   SubLangCode: '_AL';
   SubLangID: 0;
   LangID: LANG_ALBANIAN),
  (LangCode: 'SV';
   SubLangCode: '_SE';
   SubLangID: SUBLANG_SWEDISH; { Swedish }
   LangID: LANG_SWEDISH),
  (LangCode: 'SV';
   SubLangCode: '_FI';
   SubLangID: SUBLANG_SWEDISH_FINLAND; { Swedish (Finland) }
   LangID: LANG_SWEDISH),
  (LangCode: 'TH';
   SubLangCode: '_TH';
   SubLangID: 0;
   LangID: LANG_THAI),
  (LangCode: 'TR';
   SubLangCode: '_TR';
   SubLangID: 0;
   LangID: LANG_TURKISH),
  (LangCode: 'ID';
   SubLangCode: '_ID';
   SubLangID: 0;
   LangID: LANG_INDONESIAN),
  (LangCode: 'UK';
   SubLangCode: '_UA';
   SubLangID: 0;
   LangID: LANG_UKRAINIAN),
  (LangCode: 'BE';
   SubLangCode: '_BY';
   SubLangID: 0;
   LangID: LANG_BELARUSIAN),
  (LangCode: 'SL';
   SubLangCode: '_SI';
   SubLangID: 0;
   LangID: LANG_SLOVENIAN),
  (LangCode: 'ET';
   SubLangCode: '_EE';
   SubLangID: 0;
   LangID: LANG_ESTONIAN),
  (LangCode: 'LV';
   SubLangCode: '_LV';
   SubLangID: 0;
   LangID: LANG_LATVIAN),
  (LangCode: 'LT';
   SubLangCode: '_LT';
   SubLangID: 0;
   LangID: LANG_LITHUANIAN),
  (LangCode: 'FA';
   SubLangCode: '_IR';
   SubLangID: 0;
   LangID: LANG_FARSI),
  (LangCode: 'VI';
   SubLangCode: '_VN';
   SubLangID: 0;
   LangID: LANG_VIETNAMESE),
  (LangCode: 'EU';
   SubLangCode: '_ES';
   SubLangID: 0;
   LangID: LANG_BASQUE),
  (LangCode: 'AF';
   SubLangCode: '_ZA';
   SubLangID: 0;
   LangID: LANG_AFRIKAANS),
  (LangCode: 'FO';
   SubLangCode: '_FO';
   SubLangID: 0;
   LangID: LANG_FAEROESE));

const
  LastErr: cardinal = 0;

type
 TQRecL = record
  L1, L2: longint;
 end;

 TQRecC = record
  C1, C2: cardinal;
 end;

function LockFile (hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD;
               nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: DWORD): BOOL;
var
  FLock, FUnlock: TFileLockL;
  RC: Cardinal;
begin
  FillChar (FUnlock, SizeOf (FUnlock), 0);
  TQRecC (FLock.Offset).C2 := dwFileOffsetHigh;
  TQRecC (FLock.Offset).C1 := dwFileOffsetLow;
  TQRecC (FLock.Range).C2 := nNumberOfBytesToLockHigh;
  TQRecC (FLock.Range).C1 := nNumberOfBytesToLockLow;
  RC := DosSetFileLocksL (hFile, FUnlock, FLock, 50, 0);
  if RC <> 0 then
   begin
    LastErr := RC;
    Result := false;
   end
  else
   Result := true;
end;

function UnlockFile (hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: DWORD;
           nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: DWORD): BOOL;
var
  FLock, FUnlock: TFileLockL;
  RC: Cardinal;
begin
  FillChar (FLock, SizeOf (FLock), 0);
  TQRecC (FUnlock.Offset).C2 := dwFileOffsetHigh;
  TQRecC (FUnlock.Offset).C1 := dwFileOffsetLow;
  TQRecC (FUnlock.Range).C2 := nNumberOfBytesToUnlockHigh;
  TQRecC (FUnlock.Range).C1 := nNumberOfBytesToUnlockLow;
  RC := DosSetFileLocksL (hFile, FUnlock, FLock, 50, 0);
  if RC <> 0 then
   begin
    LastErr := RC;
    Result := false;
   end
  else
   Result := true;
end;

function GetOEMCP: Cardinal;
begin
  Result := DefaultSystemCodePage;
end;

function GetACP: Cardinal;
begin
  Result := DefaultSystemCodePage;
end;

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

function OemToCharBuffA(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrLCopy(lpszDst, lpszSrc, cchDstLength);
  Result := true;
end;

function CharToOemBuffA(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrLCopy(lpszDst, lpszSrc, cchDstLength);
  Result := true;
end;

function MultiByteToWideChar(CodePage: DWORD; dwFlags: DWORD; const lpMultiByteStr: LPCSTR; cchMultiByte: Integer; lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer;
var
  TempA: RawByteString;
  TempW: UnicodeString;
begin
  TempA := String (lpMultiByteStr);
  SetCodePage (TempA, CodePage, false);
  TempW := TempA;
  Result := Length(TempW);
  if cchWideChar <= Result then
   begin
    System.Move (TempW, lpWideCharStr^, Pred (cchWideChar) * SizeOf (WideChar));
    lpWideCharStr [Pred (cchWideChar)] := #0;
   end
  else
   begin
    System.Move (TempW, lpWideCharStr^, Result * SizeOf (WideChar));
    lpWideCharStr [Pred (Result)] := #0;
   end;
end;

function WideCharToMultiByte(CodePage: DWORD; dwFlags: DWORD; lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR; cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer;
var
  TempA: RawByteString;
  TempW: UnicodeString;
begin
  SetLength (TempW, cchWideChar);
  System.Move (lpWideCharStr^, TempW, cchWideChar * SizeOf (WideChar));
  TempA := '';
  SetCodePage (TempA, CodePage, false);
  TempA := TempW;
  Result := Length (TempA);
  if Result >= cchMultiByte then
   begin
    System.Move (TempA, lpMultiByteStr^, Pred (cchMultiByte));
    lpMultiByteStr [Pred (cchMultiByte)] := #0;
   end
  else
   begin
    System.Move (TempA, lpMultiByteStr^, Result);
    lpMultiByteStr [Pred (Result)] := #0;
   end;
end;

function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer;
begin
{$WARNING To be rewritten using the UnicodeStringManager and LIBUNI.DLL functionality!}
  Result := StrLComp(lpString1, lpString2, cchCount1) + 2;
  if Result > 2 then Result := 3;
  if Result < 2 then Result := 1;
end;

function EnumSystemCodePages(lpCodePageEnumProc: TFNCodepageEnumProc; dwFlags: DWORD): BOOL;

type
  TCodePagesProc = function (CodePageString: PChar): Cardinal; stdcall;

var
  CP: word;
  CP2: TSystemCodepage;
  S: AnsiString;
  CPProc: TCodePagesProc;

 function TestCPNum: boolean;
 var
  UConvObj: TUConvObject;
 begin
  CP2 := OS2CPToRtlCP (CP, 0, UConvObj);
  if UConvObj <> nil then
   begin
    Str (CP2, S);
    TestCPNum := true;
   end
  else
   TestCPNum := false;
 end;

begin
  CPProc := TCodePagesProc (lpCodepageEnumProc);
  if not (UniAPI) then
   begin
    Str (DefaultSystemCodepage, S);
    CPProc (PChar (S));
   end
  else
   begin
    for CP := 1 to 1386 do
(* Skip higher numbers which are not supported under OS/2 anyway *)
(* and testing them would take considerable amount of time.      *)
     if TestCPNum then
      CPProc (PChar (S));
    CP := 4946;
    if TestCPNum then
(* This one might be recognized... *)
     CPProc (PChar (S));
    CP := 28709;
    if TestCPNum then
(* ...and this one as well. *)
     CPProc (PChar (S));
   end;
  Result := True;
end;

function EnumSystemLocales(lpLocaleEnumProc: TFNLocaleEnumProc; dwFlags: DWORD): BOOL;
type
  TLocaleProc = function (LocaleString: PChar): Integer; stdcall;
var
  S: AnsiString;
  Loc: PtrInt;
  LocObj: TLocaleObject;
begin
  if UniAPI then
   begin
    for Loc := MinRealLocale to High (LocaleMap) do
     begin
      S := LocaleMap [Loc].LangCode + LocaleMap [Loc].SubLangCode;
      if Sys_UniCreateLocaleObject (2, PChar (S), LocObj) = 0 then
       begin
        S := HexStr (Pointer (PtrUInt (LocaleMap [Loc].LCID)));
        TLocaleProc (lpLocaleEnumProc) (PChar (S));
        Sys_UniFreeLocaleObject (LocObj);
       end;
     end;
   end
  else
   begin
    Str (GetUserDefaultLCID, S);
    TLocaleProc (lpLocaleEnumProc) (PChar (S));
   end;
  Result := True;
end;

function GetUserDefaultLCID: LCID;
var
  Loc: PtrInt;
  Lang: AnsiString;
  Res2: word;
begin
  Result := 0;
  Lang := UpCase (GetEnvironmentVariable ('LANG'));
  if Lang <> '' then
   begin
    Res2 := 0;
    for Loc := MinRealLocale to High (LocaleMap) do
     begin
      if Lang = LocaleMap [Loc].LangCode + LocaleMap [Loc].SubLangCode then
       Result := LocaleMap [Loc].LCID
      else
       if (Res2 = 0) and (Lang = LocaleMap [Loc].LangCode) then
        Res2 := LocaleMap [Loc].LangID;
     end;
    if (Result = 0) and (Res2 <> 0) then
     Result := Res2;
   end;
  if Result = 0 then
   Result := LANG_ENGLISH or (SUBLANG_ENGLISH_US shl 10);
end;

function GetLastError: Integer;
begin
  Result := Integer (LastErr);
end;

procedure SetLastError (Value: Integer);
begin
  LastErr := cardinal (Value);
end;
