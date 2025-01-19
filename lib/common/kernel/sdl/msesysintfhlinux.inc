var
 thread1: threadty;

{$ifdef msedebug}
var                         //!!!!todo: link with correct location
 _IO_stdin: P_IO_FILE; cvar;
 _IO_stdout: P_IO_FILE; cvar;
 _IO_stderr: P_IO_FILE; cvar;
 __malloc_initialized : longint;cvar;
 h_errno : longint;cvar;
{$endif}

function timestampms: longword;
function blocksignal(const signum: integer): boolean;
              //true if blocked before
function unblocksignal(const signum: integer): boolean;
              //true if blocked before

function sigactionex(SigNum: Integer; var Action: TSigActionex; OldAction: PSigAction): Integer;

procedure setcloexec(const fd: integer);
