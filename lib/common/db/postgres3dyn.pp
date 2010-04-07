{
 modified 2009-2010 by Martin Schreiber
}

{
  Contains the Postgres protocol 3 functions calls

  Call InitialisePostgres3 before using any of the calls, and call ReleasePostgres3
  when finished.
}

unit postgres3dyn;

{$mode objfpc}{$H+}

interface

uses
  dynlibs, SysUtils, ctypes,msestrings;

const
{$ifdef mswindows}
 postgreslib: array[0..0] of filenamety = ('libpq.dll');
{$else}
 postgreslib: array[0..2] of filenamety = ('libpq.so.5.1','libpq.so.5','libpq.so');
{$endif}

procedure initializepostgres3(const sonames: array of filenamety);
procedure releasepostgres3;

(*
{$IFDEF Unix}
  const
    pqlib = 'libpq.'+sharedsuffix;
{$ENDIF}
{$IFDEF Win32}
  const
    pqlib = 'libpq.dll';
{$ENDIF}
*)

{$PACKRECORDS C}

//{$i postgres3types.inc}
Type
  size_t    = sizeint;
  psize_t   = ^size_t;
  TFILE     = Longint;
  PFIle     = ^TFILE;
  POid      = ^Oid;
  Oid       = dword;

type
   { Pointer types }
   PDllist= ^TDllist;
   PDlelem= ^TDlelem;

   TDlelem = record
        dle_next : PDlelem;
        dle_prev : PDlElem;
        dle_val : pointer;
        dle_list : PDllist;
     end;

   TDllist = record
        dll_head : PDlelem;
        dll_tail : PDlelem;
     end;

var
  DLNewList : function : PDllist;cdecl;
  DLFreeList : procedure (_para1:PDllist);cdecl;
  DLNewElem : function (val : pointer) :PDlelem;cdecl;
  DLFreeElem : procedure (_para1:PDlelem);cdecl;
  DLGetHead : function (_para1:PDllist):PDlelem;cdecl;
  DLGetTail : function (_para1:PDllist):PDlelem;cdecl;
  DLRemTail : function (l:PDllist):PDlelem;cdecl;
  DLGetPred : function (_para1:PDlelem):PDlelem;cdecl;
  DLGetSucc : function (_para1:PDlelem):PDlelem;cdecl;
  DLRemove : procedure (_para1:PDlelem);cdecl;
  DLAddHead : procedure (list:PDllist; node:PDlelem);cdecl;
  DLAddTail : procedure (list:PDllist; node:PDlelem);cdecl;
  DLRemHead : function (list:PDllist):PDlelem;cdecl;

{ Macro translated }
Function  DLE_VAL(elem : PDlelem) : pointer;

const
   ERROR_MSG_LENGTH = 4096;
   CMDSTATUS_LEN = 40;

Type
  TSockAddr = Array [1..112] of byte;
  TPGresAttDesc = record
       name : Pchar;
       adtid : Oid;
       adtsize : integer;
    end;
  PPGresAttDesc= ^TPGresAttDesc;
  PPPGresAttDesc= ^PPGresAttDesc;
  TPGresAttValue = record
       len : longint;
       value : Pchar;
    end;
  PPGresAttValue= ^TPGresAttValue;
  PPPGresAttValue= ^PPGresAttValue;

  PExecStatusType = ^TExecStatusType;
  TExecStatusType = (PGRES_EMPTY_QUERY := 0,PGRES_COMMAND_OK,
       PGRES_TUPLES_OK,PGRES_COPY_OUT,PGRES_COPY_IN,
       PGRES_BAD_RESPONSE,PGRES_NONFATAL_ERROR,
       PGRES_FATAL_ERROR);


  TPGlobjfuncs = record
        fn_lo_open   : Oid;
        fn_lo_close  : Oid;
        fn_lo_creat  : Oid;
        fn_lo_unlink : Oid;
        fn_lo_lseek  : Oid;
        fn_lo_tell   : Oid;
        fn_lo_read   : Oid;
        fn_lo_write  : Oid;
    end;
  PPGlobjfuncs= ^TPGlobjfuncs;

  PConnStatusType = ^TConnStatusType;
  TConnStatusType = (CONNECTION_OK,CONNECTION_BAD,CONNECTION_STARTED,
       CONNECTION_MADE,CONNECTION_AWAITING_RESPONSE,
       CONNECTION_AUTH_OK,CONNECTION_SETENV,
       CONNECTION_SSL_STARTUP,CONNECTION_NEEDED);

   TPGconn = record
        pghost : Pchar;
        pgtty : Pchar;
        pgport : Pchar;
        pgoptions : Pchar;
        dbName : Pchar;
        status : TConnStatusType;
        errorMessage : array[0..(ERROR_MSG_LENGTH)-1] of char;
        Pfin : PFILE;
        Pfout : PFILE;
        Pfdebug : PFILE;
        sock : longint;
        laddr : TSockAddr;
        raddr : TSockAddr;
        salt : array[0..(2)-1] of char;
        asyncNotifyWaiting : longint;
        notifyList : PDllist;
        pguser : Pchar;
        pgpass : Pchar;
        lobjfuncs : PPGlobjfuncs;
    end;
  PPGconn= ^TPGconn;

  TPGresult = record
        ntups : longint;
        numAttributes : longint;
        attDescs : PPGresAttDesc;
        tuples : PPPGresAttValue;
        tupArrSize : longint;
        resultStatus : TExecStatusType;
        cmdStatus : array[0..(CMDSTATUS_LEN)-1] of char;
        binary : longint;
        conn : PPGconn;
    end;
  PPGresult= ^TPGresult;





  PPostgresPollingStatusType = ^PostgresPollingStatusType;
  PostgresPollingStatusType = (PGRES_POLLING_FAILED := 0,PGRES_POLLING_READING,
       PGRES_POLLING_WRITING,PGRES_POLLING_OK,
       PGRES_POLLING_ACTIVE);


  PPGTransactionStatusType = ^PGTransactionStatusType;
  PGTransactionStatusType = (PQTRANS_IDLE,PQTRANS_ACTIVE,PQTRANS_INTRANS,
       PQTRANS_INERROR,PQTRANS_UNKNOWN);

  PPGVerbosity = ^PGVerbosity;
  PGVerbosity = (PQERRORS_TERSE,PQERRORS_DEFAULT,PQERRORS_VERBOSE);

  PpgNotify = ^pgNotify;
  pgNotify = record
          relname : Pchar;
          be_pid : longint;
          extra : Pchar;
    end;

{ Function types for notice-handling callbacks  }
  PQnoticeReceiver = procedure (arg:pointer; res:PPGresult);cdecl;
  PQnoticeProcessor = procedure (arg:pointer; message:Pchar);cdecl;
{ Print options for PQprint()  }
  Ppqbool = ^pqbool;
  pqbool = char;

  P_PQprintOpt = ^_PQprintOpt;
  _PQprintOpt = record
          header : pqbool;
          align : pqbool;
          standard : pqbool;
          html3 : pqbool;
          expanded : pqbool;
          pager : pqbool;
          fieldSep : Pchar;
          tableOpt : Pchar;
          caption : Pchar;
          fieldName : ^Pchar;
    end;
  PQprintOpt = _PQprintOpt;
  PPQprintOpt = ^PQprintOpt;

  { ----------------
   * Structure for the conninfo parameter definitions returned by PQconndefaults
   *
   * All fields except "val" point at static strings which must not be altered.
   * "val" is either NULL or a malloc'd current-value string.  PQconninfoFree()
   * will release both the val strings and the PQconninfoOption array itself.
   * ----------------
    }

     P_PQconninfoOption = ^_PQconninfoOption;
     _PQconninfoOption = record
          keyword : Pchar;
          envvar : Pchar;
          compiled : Pchar;
          val : Pchar;
          _label : Pchar;
          dispchar : Pchar;
          dispsize : longint;
       end;
     PQconninfoOption = _PQconninfoOption;
     PPQconninfoOption = ^PQconninfoOption;
  { ----------------
   * PQArgBlock -- structure for PQfn() arguments
   * ----------------
    }
  { can't use void (dec compiler barfs)   }

     PPQArgBlock = ^PQArgBlock;
     PQArgBlock = record
          len : longint;
          isint : longint;
          u : record
              case longint of
                 0 : ( ptr : Plongint );
                 1 : ( integer : longint );
              end;
       end;

var
{ ----------------
* Exported functions of libpq
* ----------------
}
{ ===   in fe-connect.c ===  }
{ make a new client connection to the backend  }
{ Asynchronous (non-blocking)  }
(* Const before type ignored *)
  PQconnectStart : function (conninfo:Pchar):PPGconn;cdecl;
  PQconnectPoll : function (conn:PPGconn):PostgresPollingStatusType;cdecl;
{ Synchronous (blocking)  }
(* Const before type ignored *)
  PQconnectdb : function (conninfo:Pchar):PPGconn;cdecl;
  PQsetdbLogin : function (pghost:Pchar; pgport:Pchar; pgoptions:Pchar; pgtty:Pchar; dbName:Pchar;login:Pchar; pwd:Pchar):PPGconn;cdecl;
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
{ close the current connection and free the PGconn data structure  }
  PQfinish : procedure (conn:PPGconn);cdecl;
{ get info about connection options known to PQconnectdb  }
  PQconndefaults : function : PPQconninfoOption;cdecl;
{ free the data structure returned by PQconndefaults()  }
  PQconninfoFree : procedure (connOptions:PPQconninfoOption);cdecl;
{
* close the current connection and restablish a new one with the same
* parameters
}
{ Asynchronous (non-blocking)  }
  PQresetStart : function (conn:PPGconn):longint;cdecl;
  PQresetPoll : function (conn:PPGconn):PostgresPollingStatusType;cdecl;
{ Synchronous (blocking)  }
  PQreset : procedure (conn:PPGconn);cdecl;
{ issue a cancel request  }
  PQrequestCancel : function (conn:PPGconn):longint;cdecl;
{ Accessor functions for PGconn objects  }
  PQdb : function (conn:PPGconn):Pchar;cdecl;
  PQuser : function (conn:PPGconn):Pchar;cdecl;
  PQpass : function (conn:PPGconn):Pchar;cdecl;
  PQhost : function (conn:PPGconn):Pchar;cdecl;
  PQport : function (conn:PPGconn):Pchar;cdecl;
  PQtty : function (conn:PPGconn):Pchar;cdecl;
  PQoptions : function (conn:PPGconn):Pchar;cdecl;
  PQstatus : function (conn:PPGconn):TConnStatusType;cdecl;
  PQtransactionStatus : function (conn:PPGconn):PGTransactionStatusType;cdecl;
  PQparameterStatus : function (conn:PPGconn; paramName:Pchar):Pchar;cdecl;
  PQprotocolVersion : function (conn:PPGconn):longint;cdecl;
  PQerrorMessage : function (conn:PPGconn):Pchar;cdecl;
  PQsocket : function (conn:PPGconn):longint;cdecl;
  PQbackendPID : function (conn:PPGconn):longint;cdecl;
  PQclientEncoding : function (conn:PPGconn):longint;cdecl;
  PQsetClientEncoding : function (conn:PPGconn; encoding:Pchar):longint;cdecl;
{ Set verbosity for PQerrorMessage and PQresultErrorMessage  }
  PQsetErrorVerbosity : function (conn:PPGconn; verbosity:PGVerbosity):PGVerbosity;cdecl;
{ Enable/disable tracing  }
  PQtrace : procedure (conn:PPGconn; debug_port:PFILE);cdecl;
  PQuntrace : procedure (conn:PPGconn);cdecl;
{ Override default notice handling routines  }
  PQsetNoticeReceiver : function (conn:PPGconn; proc:PQnoticeReceiver; arg:pointer):PQnoticeReceiver;cdecl;
  PQsetNoticeProcessor : function (conn:PPGconn; proc:PQnoticeProcessor; arg:pointer):PQnoticeProcessor;cdecl;
{ === in fe-exec.c ===  }
{ Simple synchronous query  }
  PQexec : function (conn:PPGconn; query:Pchar):PPGresult;cdecl;
  PQexecParams : function (conn:PPGconn; command:Pchar; nParams:longint; paramTypes:POid; paramValues:PPchar;paramLengths:Plongint; paramFormats:Plongint; resultFormat:longint):PPGresult;cdecl;
  PQexecPrepared : function (conn:PPGconn; stmtName:Pchar; nParams:longint; paramValues:PPchar; paramLengths:Plongint;paramFormats:Plongint; resultFormat:longint):PPGresult;cdecl;
  PQPrepare : function (conn:PPGconn; stmtName:Pchar; query:Pchar; nParams:longint; paramTypes:POid):PPGresult;cdecl;
{ Interface for multiple-result or asynchronous queries  }
  PQsendQuery : function (conn:PPGconn; query:Pchar):longint;cdecl;
  PQsendQueryParams : function (conn:PPGconn; command:Pchar; nParams:longint; paramTypes:POid; paramValues:PPchar;paramLengths:Plongint; paramFormats:Plongint; resultFormat:longint):longint;cdecl;
  PQsendQueryPrepared : function (conn:PPGconn; stmtName:Pchar; nParams:longint; paramValues:PPchar; paramLengths:Plongint;paramFormats:Plongint; resultFormat:longint):longint;cdecl;
  PQgetResult : function (conn:PPGconn):PPGresult;cdecl;
{ Routines for managing an asynchronous query  }
  PQisBusy : function (conn:PPGconn):longint;cdecl;
  PQconsumeInput : function (conn:PPGconn):longint;cdecl;
{ LISTEN/NOTIFY support  }
  PQnotifies : function (conn:PPGconn):PPGnotify;cdecl;
{ Routines for copy in/out  }
  PQputCopyData : function (conn:PPGconn; buffer:Pchar; nbytes:longint):longint;cdecl;
  PQputCopyEnd : function (conn:PPGconn; errormsg:Pchar):longint;cdecl;
  PQgetCopyData : function (conn:PPGconn; buffer:PPchar; async:longint):longint;cdecl;
{ Deprecated routines for copy in/out  }
  PQgetline : function (conn:PPGconn; _string:Pchar; length:longint):longint;cdecl;
  PQputline : function (conn:PPGconn; _string:Pchar):longint;cdecl;
  PQgetlineAsync : function (conn:PPGconn; buffer:Pchar; bufsize:longint):longint;cdecl;
  PQputnbytes : function (conn:PPGconn; buffer:Pchar; nbytes:longint):longint;cdecl;
  PQendcopy : function (conn:PPGconn):longint;cdecl;
{ Set blocking/nonblocking connection to the backend  }
  PQsetnonblocking : function (conn:PPGconn; arg:longint):longint;cdecl;
  PQisnonblocking : function (conn:PPGconn):longint;cdecl;
{ Force the write buffer to be written (or at least try)  }
  PQflush : function (conn:PPGconn):longint;cdecl;
{
* "Fast path" interface --- not really recommended for application
* use
}
  PQfn : function (conn:PPGconn; fnid:longint; result_buf:Plongint; result_len:Plongint; result_is_int:longint;args:PPQArgBlock; nargs:longint):PPGresult;cdecl;
{ Accessor functions for PGresult objects  }
  PQresultStatus : function (res:PPGresult):TExecStatusType;cdecl;
  PQresStatus : function (status:TExecStatusType):Pchar;cdecl;
  PQresultErrorMessage : function (res:PPGresult):Pchar;cdecl;
  PQresultErrorField : function (res:PPGresult; fieldcode:longint):Pchar;cdecl;
  PQntuples : function (res:PPGresult):longint;cdecl;
  PQnfields : function (res:PPGresult):longint;cdecl;
  PQbinaryTuples : function (res:PPGresult):longint;cdecl;
  PQfname : function (res:PPGresult; field_num:longint):Pchar;cdecl;
  PQfnumber : function (res:PPGresult; field_name:Pchar):longint;cdecl;
  PQftable : function (res:PPGresult; field_num:longint):Oid;cdecl;
  PQftablecol : function (res:PPGresult; field_num:longint):longint;cdecl;
  PQfformat : function (res:PPGresult; field_num:longint):longint;cdecl;
  PQftype : function (res:PPGresult; field_num:longint):Oid;cdecl;
  PQfsize : function (res:PPGresult; field_num:longint):longint;cdecl;
  PQfmod : function (res:PPGresult; field_num:longint):longint;cdecl;
  PQcmdStatus : function (res:PPGresult):Pchar;cdecl;
  PQoidStatus : function (res:PPGresult):Pchar;cdecl;
{ old and ugly  }
  PQoidValue : function (res:PPGresult):Oid;cdecl;
{ new and improved  }
  PQcmdTuples : function (res:PPGresult):Pchar;cdecl;
  PQgetvalue : function (res:PPGresult; tup_num:longint; field_num:longint):Pchar;cdecl;
  PQgetlength : function (res:PPGresult; tup_num:longint; field_num:longint):longint;cdecl;
  PQgetisnull : function (res:PPGresult; tup_num:longint; field_num:longint):longint;cdecl;
{ Delete a PGresult  }
  PQclear : procedure (res:PPGresult);cdecl;
{ For freeing other alloc'd results, such as PGnotify structs  }
  PQfreemem : procedure (ptr:pointer);cdecl;
{ Exists for backward compatibility.  bjm 2003-03-24  }
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
//  function PQfreeNotify(ptr : longint) : longint;
{
* Make an empty PGresult with given status (some apps find this
* useful). If conn is not NULL and status indicates an error, the
* conn's errorMessage is copied.
}
  PQmakeEmptyPGresult : function (conn:PPGconn; status:TExecStatusType):PPGresult;cdecl;
{ Quoting strings before inclusion in queries.  }
  PQescapeString : function (till:Pchar; from:Pchar; length:size_t):size_t;cdecl;
  PQescapeBytea : function (bintext:Pbyte; binlen:size_t; bytealen:Psize_t):Pbyte;cdecl;
  PQunescapeBytea : function (strtext:Pbyte; retbuflen:Psize_t):Pbyte;cdecl;
{ === in fe-print.c ===  }
{ output stream  }
  PQprint : procedure (fout:PFILE; res:PPGresult; ps:PPQprintOpt);cdecl;
{ option structure  }
{
* really old printing routines
}
{ where to send the output  }
{ pad the fields with spaces  }
{ field separator  }
{ display headers?  }
  PQdisplayTuples : procedure (res:PPGresult; fp:PFILE; fillAlign:longint; fieldSep:Pchar; printHeader:longint;quiet:longint);cdecl;
(* Const before type ignored *)
{ output stream  }
{ print attribute names  }
{ delimiter bars  }
  PQprintTuples : procedure (res:PPGresult; fout:PFILE; printAttName:longint; terseOutput:longint; width:longint);cdecl;
{ width of column, if 0, use variable
* width  }
{ === in fe-lobj.c ===  }
{ Large-object access routines  }
  lo_open : function (conn:PPGconn; lobjId:Oid; mode:longint):longint;cdecl;
  lo_close : function (conn:PPGconn; fd:longint):longint;cdecl;
  lo_read : function (conn:PPGconn; fd:longint; buf:Pchar; len:size_t):longint;cdecl;
  lo_write : function (conn:PPGconn; fd:longint; buf:Pchar; len:size_t):longint;cdecl;
  lo_lseek : function (conn:PPGconn; fd:longint; offset:longint; whence:longint):longint;cdecl;
  lo_creat : function (conn:PPGconn; mode:longint):Oid;cdecl;
  lo_tell : function (conn:PPGconn; fd:longint):longint;cdecl;
  lo_unlink : function (conn:PPGconn; lobjId:Oid):longint;cdecl;
  lo_import : function (conn:PPGconn; filename:Pchar):Oid;cdecl;
  lo_export : function (conn:PPGconn; lobjId:Oid; filename:Pchar):longint;cdecl;
{ === in fe-misc.c ===  }
{ Determine length of multibyte encoded char at *s  }
  PQmblen : function (s:Pbyte; encoding:longint):longint;cdecl;
{ Get encoding id from environment variable PGCLIENTENCODING  }
  PQenv2encoding: function :longint;cdecl;

//{$ifdef USE_SSL}
{ Get the SSL structure associated with a connection  }
//  PQgetssl : function (conn:PPGconn):PSSL;cdecl;
  PQgetssl : function (conn:PPGconn): pointer;cdecl;
//{$endif}

implementation
uses
 {msesonames,}msedynload,msesys;

var
 libinfo: dynlibinfoty;

// This function is also defined in postgres3!
function PQsetdb(M_PGHOST,M_PGPORT,M_PGOPT,M_PGTTY,M_DBNAME : pchar) : ppgconn;
begin
   PQsetdb:=PQsetdbLogin(M_PGHOST,M_PGPORT,M_PGOPT,M_PGTTY,M_DBNAME,'','');
end;

// This function is also defined in Dllist!
Function DLE_VAL(elem : PDlelem) : pointer;
begin
  DLE_VAL:=elem^.dle_val
end;

procedure initializepostgres3(const sonames: array of filenamety);
const
 funcs: array[0..97] of funcinfoty = (
  (n: 'PQconnectStart'; d: @PQconnectStart),
  (n: 'PQconnectPoll'; d: @PQconnectPoll),
  (n: 'PQconnectdb'; d: @PQconnectdb),
  (n: 'PQsetdbLogin'; d: @PQsetdbLogin),
  (n: 'PQfinish'; d: @PQfinish),
  (n: 'PQconndefaults'; d: @PQconndefaults),
  (n: 'PQconninfoFree'; d: @PQconninfoFree),
  (n: 'PQresetStart'; d: @PQresetStart),
  (n: 'PQresetPoll'; d: @PQresetPoll),
  (n: 'PQreset'; d: @PQreset),
  (n: 'PQrequestCancel'; d: @PQrequestCancel),
  (n: 'PQdb'; d: @PQdb),
  (n: 'PQuser'; d: @PQuser),
  (n: 'PQpass'; d: @PQpass),
  (n: 'PQhost'; d: @PQhost),
  (n: 'PQport'; d: @PQport),
  (n: 'PQtty'; d: @PQtty),
  (n: 'PQoptions'; d: @PQoptions),
  (n: 'PQstatus'; d: @PQstatus),
  (n: 'PQtransactionStatus'; d: @PQtransactionStatus),
  (n: 'PQparameterStatus'; d: @PQparameterStatus),
  (n: 'PQprotocolVersion'; d: @PQprotocolVersion),
  (n: 'PQerrorMessage'; d: @PQerrorMessage),
  (n: 'PQsocket'; d: @PQsocket),
  (n: 'PQbackendPID'; d: @PQbackendPID),
  (n: 'PQclientEncoding'; d: @PQclientEncoding),
  (n: 'PQsetClientEncoding'; d: @PQsetClientEncoding),
  (n: 'PQsetErrorVerbosity'; d: @PQsetErrorVerbosity),
  (n: 'PQtrace'; d: @PQtrace),
  (n: 'PQuntrace'; d: @PQuntrace),
  (n: 'PQsetNoticeReceiver'; d: @PQsetNoticeReceiver),
  (n: 'PQsetNoticeProcessor'; d: @PQsetNoticeProcessor),
  (n: 'PQexec'; d: @PQexec),
  (n: 'PQexecParams'; d: @PQexecParams),
  (n: 'PQexecPrepared'; d: @PQexecPrepared),
  (n: 'PQprepare'; d: @PQprepare),
  (n: 'PQsendQuery'; d: @PQsendQuery),
  (n: 'PQsendQueryParams'; d: @PQsendQueryParams),
  (n: 'PQsendQueryPrepared'; d: @PQsendQueryPrepared),
  (n: 'PQgetResult'; d: @PQgetResult),
  (n: 'PQisBusy'; d: @PQisBusy),
  (n: 'PQconsumeInput'; d: @PQconsumeInput),
  (n: 'PQnotifies'; d: @PQnotifies),
  (n: 'PQputCopyData'; d: @PQputCopyData),
  (n: 'PQputCopyEnd'; d: @PQputCopyEnd),
  (n: 'PQgetCopyData'; d: @PQgetCopyData),
  (n: 'PQgetline'; d: @PQgetline),
  (n: 'PQputline'; d: @PQputline),
  (n: 'PQgetlineAsync'; d: @PQgetlineAsync),
  (n: 'PQputnbytes'; d: @PQputnbytes),
  (n: 'PQendcopy'; d: @PQendcopy),
  (n: 'PQsetnonblocking'; d: @PQsetnonblocking),
  (n: 'PQisnonblocking'; d: @PQisnonblocking),
  (n: 'PQflush'; d: @PQflush),
  (n: 'PQfn'; d: @PQfn),
  (n: 'PQresultStatus'; d: @PQresultStatus),
  (n: 'PQresStatus'; d: @PQresStatus),
  (n: 'PQresultErrorMessage'; d: @PQresultErrorMessage),
  (n: 'PQresultErrorField'; d: @PQresultErrorField),
  (n: 'PQntuples'; d: @PQntuples),
  (n: 'PQnfields'; d: @PQnfields),
  (n: 'PQbinaryTuples'; d: @PQbinaryTuples),
  (n: 'PQfname'; d: @PQfname),
  (n: 'PQfnumber'; d: @PQfnumber),
  (n: 'PQftable'; d: @PQftable),
  (n: 'PQftablecol'; d: @PQftablecol),
  (n: 'PQfformat'; d: @PQfformat),
  (n: 'PQftype'; d: @PQftype),
  (n: 'PQfsize'; d: @PQfsize),
  (n: 'PQfmod'; d: @PQfmod),
  (n: 'PQcmdStatus'; d: @PQcmdStatus),
  (n: 'PQoidStatus'; d: @PQoidStatus),
  (n: 'PQoidValue'; d: @PQoidValue),
  (n: 'PQcmdTuples'; d: @PQcmdTuples),
  (n: 'PQgetvalue'; d: @PQgetvalue),
  (n: 'PQgetlength'; d: @PQgetlength),
  (n: 'PQgetisnull'; d: @PQgetisnull),
  (n: 'PQclear'; d: @PQclear),
  (n: 'PQfreemem'; d: @PQfreemem),
  (n: 'PQmakeEmptyPGresult'; d: @PQmakeEmptyPGresult),
  (n: 'PQescapeString'; d: @PQescapeString),
  (n: 'PQescapeBytea'; d: @PQescapeBytea),
  (n: 'PQunescapeBytea'; d: @PQunescapeBytea),
  (n: 'PQprint'; d: @PQprint),
  (n: 'PQdisplayTuples'; d: @PQdisplayTuples),
  (n: 'PQprintTuples'; d: @PQprintTuples),
  (n: 'lo_open'; d: @lo_open),
  (n: 'lo_close'; d: @lo_close),
  (n: 'lo_read'; d: @lo_read),
  (n: 'lo_write'; d: @lo_write),
  (n: 'lo_lseek'; d: @lo_lseek),
  (n: 'lo_creat'; d: @lo_creat),
  (n: 'lo_tell'; d: @lo_tell),
  (n: 'lo_unlink'; d: @lo_unlink),
  (n: 'lo_import'; d: @lo_import),
  (n: 'lo_export'; d: @lo_export),
  (n: 'PQmblen'; d: @PQmblen),
  (n: 'PQenv2encoding'; d: @PQenv2encoding)
 );

 funcsopt: array[0..13] of funcinfoty = (
  (n: 'PQgetssl'; d: @PQgetssl),
  
  (n: 'DLNewList'; d: @DLNewList),  //these functions seem not to be exported by
  (n: 'DLFreeList'; d: @DLFreeList),//pqlib??
  (n: 'DLNewElem'; d: @DLNewElem),
  (n: 'DLFreeElem'; d: @DLFreeElem),
  (n: 'DLGetHead'; d: @DLGetHead),
  (n: 'DLGetTail'; d: @DLGetTail),
  (n: 'DLRemTail'; d: @DLRemTail),
  (n: 'DLGetPred'; d: @DLGetPred),
  (n: 'DLGetSucc'; d: @DLGetSucc),
  (n: 'DLRemove'; d: @DLRemove),
  (n: 'DLAddHead'; d: @DLAddHead),
  (n: 'DLAddTail'; d: @DLAddTail),
  (n: 'DLRemHead'; d: @DLRemHead)
 );
  
begin
 try
  if length(sonames) = 0 then begin
   initializedynlib(libinfo,postgreslib,funcs,funcsopt);
  end
  else begin
   initializedynlib(libinfo,sonames,funcs,funcsopt);
  end;
 except
  on e: exception do begin
   e.message:= 'Can not load Postgres library. '+e.message;
   raise;
  end;  
 end;
end;

procedure releasepostgres3;
begin
 releasedynlib(libinfo);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
