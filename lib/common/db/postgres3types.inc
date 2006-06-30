{
  Contains the types needed for use with Postgres protocol v3
}

Type
  size_t    = sizeint;
  psize_t   = ^size_t;
  TFILE     = Longint;
  PFIle     = ^TFILE;
  POid      = ^Oid;
  Oid       = dword;

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

