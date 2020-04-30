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

function OemToCharBuffA(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
begin
  if lpszDst <> lpszSrc then
    StrLCopy(lpszDst, lpszSrc, cchDstLength);
{$ifdef HUNGARIAN}
  OemHunHun(lpszDst, cchDstLength);
{$endif}
  Result := true;
end;

function CharToOemBuffA(lpszSrc: PChar; lpszDst: PChar; cchDstLength: DWORD): BOOL;
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
{$WARNING Probably shall be implemented by parsing environment variable LANG}
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
