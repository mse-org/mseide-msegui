unit sqlite3dyn;
{$ifdef FPC}{$mode objfpc} {$h+}{$endif}

{$ifdef BSD}
  {$linklib c}
  {$linklib pthread}
{$endif}

// use mse_sqlite3static for static linking of the SQLite3 library
//

interface
uses
 {msesonames,}msedynload,msestrings{$ifndef FPC},msetypes{$endif};
const
{$ifdef mswindows}
 sqlite3lib: array[0..0] of filenamety = ('sqlite3.dll');  
{$else}
 sqlite3lib: array[0..1] of filenamety = ('libsqlite3.so.0','libsqlite3.so'); 
{$endif}
 
{
  Automatically converted by H2Pas 0.99.16 from sqlite3.h
  The following command line parameters were used:
    -D
    -c
    sqlite3.h

  Manual corrections made by Luiz Am?rico - 2005
  Martin Schreiber 2007
}

procedure initializesqlite3(const sonames: array of filenamety); //[] = default
procedure releasesqlite3;

{$ifdef FPC}{$PACKRECORDS C}{$endif} //todo: check delphi recordpacking
const

{$ifdef mse_sqlite3static}
 {$ifdef mswindows}
  sqlite3lib = 'sqlite3.dll';
 {$else}
  sqlite3lib = 'libsqlite3.so';
 {$endif}
{$endif}

  SQLITE_INTEGER = 1;   
  SQLITE_FLOAT = 2;   
{ #define SQLITE_TEXT  3  // See below  }
  SQLITE_BLOB = 4;   
  SQLITE_NULL = 5;   
  SQLITE_TEXT = 3;   
  SQLITE3_TEXT = 3;   
  SQLITE_UTF8 = 1;       
  SQLITE_UTF16LE = 2;       
  SQLITE_UTF16BE = 3;       
{ Use native byte order  }
  SQLITE_UTF16 = 4;       
{ sqlite3_create_function only  }
  SQLITE_ANY = 5;  
   
   //sqlite_exec return values
  SQLITE_OK = 0;   
  SQLITE_ERROR = 1;{ SQL error or missing database  }
  SQLITE_INTERNAL = 2;{ An internal logic error in SQLite  }
  SQLITE_PERM = 3;   { Access permission denied  }
  SQLITE_ABORT = 4; { Callback routine requested an abort  }
  SQLITE_BUSY = 5;  { The database file is locked  }
  SQLITE_LOCKED = 6;{ A table in the database is locked  }
  SQLITE_NOMEM = 7; { A malloc() failed  }
  SQLITE_READONLY = 8;{ Attempt to write a readonly database  }
  SQLITE_INTERRUPT = 9;{ Operation terminated by sqlite3_interrupt() }
  SQLITE_IOERR = 10;   { Some kind of disk I/O error occurred  }
  SQLITE_CORRUPT = 11;   { The database disk image is malformed  }
  SQLITE_NOTFOUND = 12;   { (Internal Only) Table or record not found  }
  SQLITE_FULL = 13;   { Insertion failed because database is full  }
  SQLITE_CANTOPEN = 14;   { Unable to open the database file  }
  SQLITE_PROTOCOL = 15;   { Database lock protocol error  }
  SQLITE_EMPTY = 16;   { Database is empty  }
  SQLITE_SCHEMA = 17;   { The database schema changed  }
  SQLITE_TOOBIG = 18;   { Too much data for one row of a table  }
  SQLITE_CONSTRAINT = 19;   { Abort due to contraint violation  }
  SQLITE_MISMATCH = 20;   { Data type mismatch  }
  SQLITE_MISUSE = 21;   { Library used incorrectly  }
  SQLITE_NOLFS = 22;   { Uses OS features not supported on host  }
  SQLITE_AUTH = 23;   { Authorization denied  }
  SQLITE_FORMAT = 24;   { Auxiliary database format error  }
  SQLITE_RANGE = 25;   { 2nd parameter to sqlite3_bind out of range  }
  SQLITE_NOTADB = 26;   { File opened that is not a database file  }
  SQLITE_ROW = 100;   { sqlite3_step() has another row ready  }
  SQLITE_DONE = 101;   { sqlite3_step() has finished executing  }

  sqliteerrormax = 99;
    
type
  sqlite_int64 = int64;
  sqlite_uint64 = qword;
  PPPChar = ^PPChar;
  Psqlite3  = Pointer;
  PPSqlite3 = ^PSqlite3;
  Psqlite3_context  = Pointer;
  Psqlite3_stmt  = Pointer;
  PPsqlite3_stmt = ^Psqlite3_stmt;
  Psqlite3_value  = Pointer;
  PPsqlite3_value  = ^Psqlite3_value;

//Callback function types
//Notice that most functions were named using as prefix the function name that uses them,
//rather than describing their functions  

//  sqlite3_callback = function (_para1:pointer; _para2:longint; _para3:PPchar; _para4:PPchar):longint;cdecl;
  sqlite3_callback = function (var _para1; _para2:longint;
              _para3:PPchar; _para4:PPchar):longint;cdecl;
  //@ operator does not work with dynamic arrays, -O2 and FPC 2_2            
  busy_handler_func = function (_para1:pointer; _para2:longint):longint;cdecl;
  sqlite3_set_authorizer_func = function (_para1:pointer; _para2:longint; _para3:Pchar; _para4:Pchar; _para5:Pchar; _para6:Pchar):longint;cdecl;
  sqlite3_trace_func = procedure (_para1:pointer; _para2:Pchar);cdecl;
  sqlite3_progress_handler_func = function (_para1:pointer):longint;cdecl;
  sqlite3_commit_hook_func = function (_para1:pointer):longint;cdecl;
  bind_destructor_func = procedure (_para1:pointer);cdecl;
  create_function_step_func = procedure (_para1:Psqlite3_context; _para2:longint; _para3:PPsqlite3_value);cdecl;
  create_function_func_func = procedure (_para1:Psqlite3_context; _para2:longint; _para3:PPsqlite3_value);cdecl;
  create_function_final_func = procedure (_para1:Psqlite3_context);cdecl;
  sqlite3_set_auxdata_func = procedure (_para1:pointer);cdecl;
  sqlite3_result_func = procedure (_para1:pointer);cdecl;
  sqlite3_create_collation_func = function (_para1:pointer; _para2:longint; _para3:pointer; _para4:longint; _para5:pointer):longint;cdecl;
  sqlite3_collation_needed_func = procedure (_para1:pointer; _para2:Psqlite3; eTextRep:longint; _para4:Pchar);cdecl;

//{$ifndef win32}
//var
//  //This is not working under windows. Any clues?
//  sqlite3_temp_directory : Pchar;cvar;external;
//{$endif}

const
   SQLITE_COPY = 0;   
{ Index Name      Table Name       }
   SQLITE_CREATE_INDEX = 1;   
{ Table Name      NULL             }
   SQLITE_CREATE_TABLE = 2;   
{ Index Name      Table Name       }
   SQLITE_CREATE_TEMP_INDEX = 3;   
{ Table Name      NULL             }
   SQLITE_CREATE_TEMP_TABLE = 4;   
{ Trigger Name    Table Name       }
   SQLITE_CREATE_TEMP_TRIGGER = 5;   
{ View Name       NULL             }
   SQLITE_CREATE_TEMP_VIEW = 6;   
{ Trigger Name    Table Name       }
   SQLITE_CREATE_TRIGGER = 7;   
{ View Name       NULL             }
   SQLITE_CREATE_VIEW = 8;   
{ Table Name      NULL             }
   SQLITE_DELETE = 9;   
{ Index Name      Table Name       }
   SQLITE_DROP_INDEX = 10;   
{ Table Name      NULL             }
   SQLITE_DROP_TABLE = 11;   
{ Index Name      Table Name       }
   SQLITE_DROP_TEMP_INDEX = 12;   
{ Table Name      NULL             }
   SQLITE_DROP_TEMP_TABLE = 13;   
{ Trigger Name    Table Name       }
   SQLITE_DROP_TEMP_TRIGGER = 14;   
{ View Name       NULL             }
   SQLITE_DROP_TEMP_VIEW = 15;   
{ Trigger Name    Table Name       }
   SQLITE_DROP_TRIGGER = 16;   
{ View Name       NULL             }
   SQLITE_DROP_VIEW = 17;   
{ Table Name      NULL             }
   SQLITE_INSERT = 18;   
{ Pragma Name     1st arg or NULL  }
   SQLITE_PRAGMA = 19;   
{ Table Name      Column Name      }
   SQLITE_READ = 20;   
{ NULL            NULL             }
   SQLITE_SELECT = 21;   
{ NULL            NULL             }
   SQLITE_TRANSACTION = 22;   
{ Table Name      Column Name      }
   SQLITE_UPDATE = 23;   
{ Filename        NULL             }
   SQLITE_ATTACH = 24;   
{ Database Name   NULL             }
   SQLITE_DETACH = 25;   
{ Database Name   Table Name       }
   SQLITE_ALTER_TABLE = 26;   
{ Index Name      NULL             }
   SQLITE_REINDEX = 27;   

{ #define SQLITE_OK  0   // Allow access (This is actually defined above)  }
{ Abort the SQL statement with an error  }
  SQLITE_DENY = 1;   
{ Don't allow access, but don't generate an error  }
  SQLITE_IGNORE = 2;   

// Original from sqlite3.h: 
//#define SQLITE_STATIC      ((void(*)(void *))0)
//#define SQLITE_TRANSIENT   ((void(*)(void *))-1)
Const
  SQLITE_STATIC    =  0;
  SQLITE_TRANSIENT =  -1;

{$ifdef mse_sqlite3static}
 function sqlite3_close(_para1:Psqlite3):longint; cdecl; external sqlite3lib;
// sqlite3_exec: function(_para1: Psqlite3; sql: Pchar; _para3: sqlite3_callback;
//              _para4: pointer; errmsg: PPchar): longint; cdecl;
 function sqlite3_exec(_para1: Psqlite3; sql: Pchar; _para3: sqlite3_callback;
              var _para4; errmsg: PPchar): longint; cdecl; external sqlite3lib;
 function sqlite3_last_insert_rowid(_para1: Psqlite3): sqlite_int64; cdecl; external sqlite3lib;
 function sqlite3_changes(_para1: Psqlite3): longint; cdecl; external sqlite3lib;
 function sqlite3_total_changes(_para1: Psqlite3): longint; cdecl; external sqlite3lib;
 procedure sqlite3_interrupt(_para1: Psqlite3); cdecl; external sqlite3lib;
 function sqlite3_complete(sql: Pchar): longint; cdecl; external sqlite3lib;
 function sqlite3_complete16(sql: pointer):longint; cdecl; external sqlite3lib;
 function sqlite3_busy_handler(_para1: Psqlite3; _para2: busy_handler_func;
                      _para3: pointer):longint; cdecl; external sqlite3lib;
 function sqlite3_busy_timeout(_para1: Psqlite3; ms: longint):longint; cdecl; external sqlite3lib;
 function sqlite3_get_table(_para1: Psqlite3; sql: Pchar; resultp: PPPchar;
               nrow: Plongint; ncolumn: Plongint; errmsg: PPchar):longint;cdecl; external sqlite3lib;
 procedure sqlite3_free_table(result:PPchar);cdecl; external sqlite3lib;

// Todo: see how translate sqlite3_mprintf, sqlite3_vmprintf, sqlite3_snprintf
// function sqlite3_mprintf(_para1:Pchar; args:array of const):Pchar;cdecl;external External_library name 'sqlite3_mprintf';
 function sqlite3_mprintf(_para1:Pchar):Pchar;cdecl; external sqlite3lib;
//function sqlite3_vmprintf(_para1:Pchar; _para2:va_list):Pchar;cdecl;external External_library name 'sqlite3_vmprintf';
 procedure sqlite3_free(z:Pchar);cdecl; external sqlite3lib;
//function sqlite3_snprintf(_para1:longint; _para2:Pchar; _para3:Pchar; args:array of const):Pchar;cdecl;external External_library name 'sqlite3_snprintf';
 function sqlite3_snprintf(_para1:longint; _para2:Pchar; _para3:Pchar):Pchar;cdecl; external sqlite3lib;

 function sqlite3_set_authorizer(_para1:Psqlite3; xAuth:sqlite3_set_authorizer_func; pUserData:pointer):longint;cdecl; external sqlite3lib;


 function sqlite3_trace(_para1:Psqlite3; xTrace:sqlite3_trace_func;
                     _para3:pointer):pointer;cdecl; external sqlite3lib;
 procedure sqlite3_progress_handler(_para1:Psqlite3; _para2:longint;
                  _para3:sqlite3_progress_handler_func; _para4:pointer);cdecl; external sqlite3lib;
 function sqlite3_commit_hook(_para1:Psqlite3; 
           _para2:sqlite3_commit_hook_func; _para3:pointer):pointer;cdecl; external sqlite3lib;
 function sqlite3_open(filename:Pchar; ppDb:PPsqlite3):longint;cdecl; external sqlite3lib;
 function sqlite3_open16(filename:pointer; ppDb:PPsqlite3):longint;cdecl; external sqlite3lib;
 function sqlite3_errcode(db:Psqlite3):longint;cdecl; external sqlite3lib;
 function sqlite3_errmsg(_para1:Psqlite3):Pchar;cdecl; external sqlite3lib;
 function sqlite3_errmsg16(_para1:Psqlite3):pointer;cdecl; external sqlite3lib;
 function sqlite3_prepare(db:Psqlite3; zSql:Pchar; nBytes:longint;
                          ppStmt:PPsqlite3_stmt; pzTail:PPchar):longint;cdecl; external sqlite3lib;
 function sqlite3_prepare16(db:Psqlite3; zSql:pointer; nBytes:longint;
                        ppStmt:PPsqlite3_stmt; pzTail:Ppointer):longint;cdecl; external sqlite3lib;
// sqlite3_prepare_v2: function(db:Psqlite3; zSql:Pchar; nBytes:longint;
//                          ppStmt:PPsqlite3_stmt; pzTail:PPchar):longint;cdecl; external sqlite3lib;
// sqlite3_prepare16_v2: function(db:Psqlite3; zSql:pointer; nBytes:longint;
//                        ppStmt:PPsqlite3_stmt; pzTail:Ppointer):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_blob(_para1:Psqlite3_stmt; _para2:longint;
          _para3:pointer; n:longint; _para5:bind_destructor_func):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_double(_para1:Psqlite3_stmt; _para2:longint;
           _para3:double):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_int(_para1:Psqlite3_stmt; _para2:longint;
           _para3:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_int64(_para1:Psqlite3_stmt; _para2:longint;
            _para3:sqlite_int64):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_null(_para1:Psqlite3_stmt;
             _para2:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_text(_para1:Psqlite3_stmt; _para2:longint;
          _para3:Pchar; n:longint; _para5:bind_destructor_func):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_text16(_para1:Psqlite3_stmt; _para2:longint;
   _para3:pointer; _para4:longint; _para5:bind_destructor_func):longint;cdecl; external sqlite3lib;
//function sqlite3_bind_value(_para1:Psqlite3_stmt; _para2:longint; _para3:Psqlite3_value):longint;cdecl; external sqlite3lib;external External_library name 'sqlite3_bind_value';

  
//These overloaded functions were introduced to allow the use of SQLITE_STATIC and SQLITE_TRANSIENT
//It's the c world man ;-)
 function sqlite3_bind_blob1(_para1:Psqlite3_stmt; _para2:longint;
                    _para3:pointer; n:longint; _para5:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_text1(_para1:Psqlite3_stmt; _para2:longint;
                   _para3:Pchar; n:longint; _para5:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_text161(_para1:Psqlite3_stmt; _para2:longint;
                _para3:pointer; _para4:longint; _para5:longint):longint;cdecl; external sqlite3lib;

 function sqlite3_bind_parameter_count(_para1:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_bind_parameter_name(_para1:Psqlite3_stmt;
                                                 _para2:longint):Pchar;cdecl; external sqlite3lib;
 function sqlite3_bind_parameter_index(_para1:Psqlite3_stmt;
                                                  zName:Pchar):longint;cdecl; external sqlite3lib;
 function sqlite3_clear_bindings(_para1:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_column_count(pStmt:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_column_name(_para1:Psqlite3_stmt;
                                          _para2:longint):Pchar;cdecl; external sqlite3lib;
 function sqlite3_column_name16(_para1:Psqlite3_stmt;
                                        _para2:longint):pointer;cdecl; external sqlite3lib;
 function sqlite3_column_decltype(_para1:Psqlite3_stmt;
                                              i:longint):Pchar;cdecl; external sqlite3lib;
 function sqlite3_column_decltype16(_para1:Psqlite3_stmt;
                                        _para2:longint):pointer;cdecl; external sqlite3lib;
 function sqlite3_step(_para1:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_data_count(pStmt:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_column_blob(_para1:Psqlite3_stmt;
                                              iCol:longint):pointer;cdecl; external sqlite3lib;
 function sqlite3_column_bytes(_para1:Psqlite3_stmt;
                                              iCol:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_column_bytes16(_para1:Psqlite3_stmt;
                                               iCol:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_column_double(_para1:Psqlite3_stmt;
                                                iCol:longint):double;cdecl; external sqlite3lib;
 function sqlite3_column_int(_para1:Psqlite3_stmt;
                                               iCol:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_column_int64(_para1:Psqlite3_stmt; 
                                           iCol:longint):sqlite_int64;cdecl; external sqlite3lib;
 function sqlite3_column_text(_para1:Psqlite3_stmt;
                                                   iCol:longint):PChar;cdecl; external sqlite3lib;
 function sqlite3_column_text16(_para1:Psqlite3_stmt; 
                                                  iCol:longint):pointer;cdecl; external sqlite3lib;
 function sqlite3_column_type(_para1:Psqlite3_stmt; iCol:longint):longint;cdecl; external sqlite3lib;
 function sqlite3_finalize(pStmt:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_reset(pStmt:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
 function sqlite3_create_function(_para1:Psqlite3; zFunctionName:Pchar;
                    nArg:longint; eTextRep:longint; _para5:pointer; 
           xFunc:create_function_func_func; xStep:create_function_step_func; 
                    xFinal:create_function_final_func):longint;cdecl; external sqlite3lib;
 function sqlite3_create_function16(_para1:Psqlite3; zFunctionName:pointer;
                   nArg:longint; eTextRep:longint; _para5:pointer; 
           xFunc:create_function_func_func; xStep:create_function_step_func; 
                     xFinal:create_function_final_func):longint;cdecl; external sqlite3lib;
 function sqlite3_aggregate_count(_para1:Psqlite3_context):longint;cdecl; external sqlite3lib;
 function sqlite3_value_blob(_para1:Psqlite3_value):pointer;cdecl; external sqlite3lib;
 function sqlite3_value_bytes(_para1:Psqlite3_value):longint;cdecl; external sqlite3lib;
 function sqlite3_value_bytes16(_para1:Psqlite3_value):longint;cdecl; external sqlite3lib;
 function sqlite3_value_double(_para1:Psqlite3_value):double;cdecl; external sqlite3lib;
 function sqlite3_value_int(_para1:Psqlite3_value):longint;cdecl; external sqlite3lib;
 function sqlite3_value_int64(_para1:Psqlite3_value):sqlite_int64;cdecl; external sqlite3lib;
 function sqlite3_value_text(_para1:Psqlite3_value):PChar;cdecl; external sqlite3lib;
 function sqlite3_value_text16(_para1:Psqlite3_value):pointer;cdecl; external sqlite3lib;
 function sqlite3_value_text16le(_para1:Psqlite3_value):pointer;cdecl; external sqlite3lib;
 function sqlite3_value_text16be(_para1:Psqlite3_value):pointer;cdecl; external sqlite3lib;
 function sqlite3_value_type(_para1:Psqlite3_value):longint;cdecl; external sqlite3lib;
 function sqlite3_aggregate_context(_para1:Psqlite3_context;
                                           nBytes:longint):pointer;cdecl; external sqlite3lib;
 function sqlite3_user_data(_para1:Psqlite3_context):pointer;cdecl; external sqlite3lib;
 function sqlite3_get_auxdata(_para1:Psqlite3_context;
                                           _para2:longint):pointer;cdecl; external sqlite3lib;
 procedure sqlite3_set_auxdata(_para1:Psqlite3_context; _para2:longint; 
                   _para3:pointer; _para4:sqlite3_set_auxdata_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_blob(_para1:Psqlite3_context; _para2:pointer;
                          _para3:longint; _para4:sqlite3_result_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_double(_para1:Psqlite3_context;
                                               _para2:double);cdecl; external sqlite3lib;
 procedure sqlite3_result_error(_para1:Psqlite3_context;
                                     _para2:Pchar; _para3:longint);cdecl; external sqlite3lib;
 procedure sqlite3_result_error16(_para1:Psqlite3_context;
                                    _para2:pointer; _para3:longint);cdecl; external sqlite3lib;
 procedure sqlite3_result_int(_para1:Psqlite3_context; _para2:longint);cdecl; external sqlite3lib;
 procedure sqlite3_result_int64(_para1:Psqlite3_context; 
                                               _para2:sqlite_int64);cdecl; external sqlite3lib;
 procedure sqlite3_result_null(_para1:Psqlite3_context);cdecl; external sqlite3lib;
 procedure sqlite3_result_text(_para1:Psqlite3_context; _para2:Pchar; 
                          _para3:longint; _para4:sqlite3_result_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_text16(_para1:Psqlite3_context; _para2:pointer;
                           _para3:longint; _para4:sqlite3_result_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_text16le(_para1:Psqlite3_context; _para2:pointer; 
                            _para3:longint; _para4:sqlite3_result_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_text16be(_para1:Psqlite3_context; _para2:pointer;
                            _para3:longint; _para4:sqlite3_result_func);cdecl; external sqlite3lib;
 procedure sqlite3_result_value(_para1:Psqlite3_context;
                                                 _para2:Psqlite3_value);cdecl; external sqlite3lib;
    
 function sqlite3_create_collation(_para1:Psqlite3; zName:Pchar;
               eTextRep:longint; _para4:pointer; 
               xCompare:sqlite3_create_collation_func):longint;cdecl; external sqlite3lib;
 function sqlite3_create_collation16(_para1:Psqlite3; zName:Pchar; 
                 eTextRep:longint; _para4:pointer; 
                 xCompare:sqlite3_create_collation_func):longint;cdecl; external sqlite3lib;
 
 function sqlite3_collation_needed(_para1:Psqlite3; _para2:pointer;
                            _para3:sqlite3_collation_needed_func):longint;cdecl; external sqlite3lib;
 function sqlite3_collation_needed16(_para1:Psqlite3; _para2:pointer;
                            _para3:sqlite3_collation_needed_func):longint;cdecl; external sqlite3lib;

 function sqlite3_libversion:PChar;cdecl; external sqlite3lib;
//Alias for allowing better code portability (win32 is not working with external variables) 
 function sqlite3_version: PChar;cdecl; external sqlite3lib;

// Not published functions
 function sqlite3_libversion_number:longint;cdecl; external sqlite3lib;
// sqlite3_key: function(db:Psqlite3; pKey:pointer; nKey:longint):longint;cdecl; external sqlite3lib;
// sqlite3_rekey: function(db:Psqlite3; pKey:pointer; nKey:longint):longint;cdecl; external sqlite3lib;
// sqlite3_sleep: function(_para1:longint):longint;cdecl; external sqlite3lib;
// sqlite3_expired: function(_para1:Psqlite3_stmt):longint;cdecl; external sqlite3lib;
// sqlite3_global_recover: function:longint;cdecl; external sqlite3lib;
{$else}
var
 sqlite3_close: function(_para1:Psqlite3):longint; cdecl;
// sqlite3_exec: function(_para1: Psqlite3; sql: Pchar; _para3: sqlite3_callback;
//              _para4: pointer; errmsg: PPchar): longint; cdecl;
 sqlite3_exec: function(_para1: Psqlite3; sql: Pchar; _para3: sqlite3_callback;
              var _para4; errmsg: PPchar): longint; cdecl;
 sqlite3_last_insert_rowid: function(_para1: Psqlite3): sqlite_int64; cdecl;
 sqlite3_changes: function(_para1: Psqlite3): longint; cdecl;
 sqlite3_total_changes: function(_para1: Psqlite3): longint; cdecl;
 sqlite3_interrupt: procedure(_para1: Psqlite3); cdecl;
 sqlite3_complete: function(sql: Pchar): longint; cdecl;
 sqlite3_complete16: function(sql: pointer):longint; cdecl;
 sqlite3_busy_handler: function(_para1: Psqlite3; _para2: busy_handler_func;
                      _para3: pointer):longint; cdecl;
 sqlite3_busy_timeout: function(_para1: Psqlite3; ms: longint):longint; cdecl;
 sqlite3_get_table: function(_para1: Psqlite3; sql: Pchar; resultp: PPPchar;
               nrow: Plongint; ncolumn: Plongint; errmsg: PPchar):longint;cdecl;
 sqlite3_free_table: procedure(result:PPchar);cdecl;

// Todo: see how translate sqlite3_mprintf, sqlite3_vmprintf, sqlite3_snprintf
// function sqlite3_mprintf(_para1:Pchar; args:array of const):Pchar;cdecl;external External_library name 'sqlite3_mprintf';
 sqlite3_mprintf: function(_para1:Pchar):Pchar;cdecl;
//function sqlite3_vmprintf(_para1:Pchar; _para2:va_list):Pchar;cdecl;external External_library name 'sqlite3_vmprintf';
 sqlite3_free: procedure(z:Pchar);cdecl;
//function sqlite3_snprintf(_para1:longint; _para2:Pchar; _para3:Pchar; args:array of const):Pchar;cdecl;external External_library name 'sqlite3_snprintf';
 sqlite3_snprintf: function(_para1:longint; _para2:Pchar; _para3:Pchar):Pchar;cdecl;

 sqlite3_set_authorizer: function(_para1:Psqlite3; xAuth:sqlite3_set_authorizer_func; pUserData:pointer):longint;cdecl;


 sqlite3_trace: function(_para1:Psqlite3; xTrace:sqlite3_trace_func;
                     _para3:pointer):pointer;cdecl;
 sqlite3_progress_handler: procedure(_para1:Psqlite3; _para2:longint;
                  _para3:sqlite3_progress_handler_func; _para4:pointer);cdecl;
 sqlite3_commit_hook: function(_para1:Psqlite3; 
           _para2:sqlite3_commit_hook_func; _para3:pointer):pointer;cdecl;
 sqlite3_open: function(filename:Pchar; ppDb:PPsqlite3):longint;cdecl;
 sqlite3_open16: function(filename:pointer; ppDb:PPsqlite3):longint;cdecl;
 sqlite3_errcode: function(db:Psqlite3):longint;cdecl;
 sqlite3_errmsg: function(_para1:Psqlite3):Pchar;cdecl;
 sqlite3_errmsg16: function(_para1:Psqlite3):pointer;cdecl;
 sqlite3_prepare: function(db:Psqlite3; zSql:Pchar; nBytes:longint;
                          ppStmt:PPsqlite3_stmt; pzTail:PPchar):longint;cdecl;
 sqlite3_prepare16: function(db:Psqlite3; zSql:pointer; nBytes:longint;
                        ppStmt:PPsqlite3_stmt; pzTail:Ppointer):longint;cdecl;
// sqlite3_prepare_v2: function(db:Psqlite3; zSql:Pchar; nBytes:longint;
//                          ppStmt:PPsqlite3_stmt; pzTail:PPchar):longint;cdecl;
// sqlite3_prepare16_v2: function(db:Psqlite3; zSql:pointer; nBytes:longint;
//                        ppStmt:PPsqlite3_stmt; pzTail:Ppointer):longint;cdecl;
 sqlite3_bind_blob: function(_para1:Psqlite3_stmt; _para2:longint;
          _para3:pointer; n:longint; _para5:bind_destructor_func):longint;cdecl;
 sqlite3_bind_double: function(_para1:Psqlite3_stmt; _para2:longint;
           _para3:double):longint;cdecl;
 sqlite3_bind_int: function(_para1:Psqlite3_stmt; _para2:longint;
           _para3:longint):longint;cdecl;
 sqlite3_bind_int64: function(_para1:Psqlite3_stmt; _para2:longint;
            _para3:sqlite_int64):longint;cdecl;
 sqlite3_bind_null: function(_para1:Psqlite3_stmt;
             _para2:longint):longint;cdecl;
 sqlite3_bind_text: function(_para1:Psqlite3_stmt; _para2:longint;
          _para3:Pchar; n:longint; _para5:bind_destructor_func):longint;cdecl;
 sqlite3_bind_text16: function(_para1:Psqlite3_stmt; _para2:longint;
   _para3:pointer; _para4:longint; _para5:bind_destructor_func):longint;cdecl;
//function sqlite3_bind_value(_para1:Psqlite3_stmt; _para2:longint; _para3:Psqlite3_value):longint;cdecl;external External_library name 'sqlite3_bind_value';

  
//These overloaded functions were introduced to allow the use of SQLITE_STATIC and SQLITE_TRANSIENT
//It's the c world man ;-)
 sqlite3_bind_blob1: function(_para1:Psqlite3_stmt; _para2:longint;
                    _para3:pointer; n:longint; _para5:longint):longint;cdecl;
 sqlite3_bind_text1: function(_para1:Psqlite3_stmt; _para2:longint;
                   _para3:Pchar; n:longint; _para5:longint):longint;cdecl;
 sqlite3_bind_text161: function(_para1:Psqlite3_stmt; _para2:longint;
                _para3:pointer; _para4:longint; _para5:longint):longint;cdecl;

 sqlite3_bind_parameter_count: function(_para1:Psqlite3_stmt):longint;cdecl;
 sqlite3_bind_parameter_name: function(_para1:Psqlite3_stmt;
                                                 _para2:longint):Pchar;cdecl;
 sqlite3_bind_parameter_index: function(_para1:Psqlite3_stmt;
                                                  zName:Pchar):longint;cdecl;
 sqlite3_clear_bindings: function(_para1:Psqlite3_stmt):longint;cdecl;
 sqlite3_column_count: function(pStmt:Psqlite3_stmt):longint;cdecl;
 sqlite3_column_name: function(_para1:Psqlite3_stmt;
                                          _para2:longint):Pchar;cdecl;
 sqlite3_column_name16: function(_para1:Psqlite3_stmt;
                                        _para2:longint):pointer;cdecl;
 sqlite3_column_decltype: function(_para1:Psqlite3_stmt;
                                              i:longint):Pchar;cdecl;
 sqlite3_column_decltype16: function(_para1:Psqlite3_stmt;
                                        _para2:longint):pointer;cdecl;
 sqlite3_step: function(_para1:Psqlite3_stmt):longint;cdecl;
 sqlite3_data_count: function(pStmt:Psqlite3_stmt):longint;cdecl;
 sqlite3_column_blob: function(_para1:Psqlite3_stmt;
                                              iCol:longint):pointer;cdecl;
 sqlite3_column_bytes: function(_para1:Psqlite3_stmt;
                                              iCol:longint):longint;cdecl;
 sqlite3_column_bytes16: function(_para1:Psqlite3_stmt;
                                               iCol:longint):longint;cdecl;
 sqlite3_column_double: function(_para1:Psqlite3_stmt;
                                                iCol:longint):double;cdecl;
 sqlite3_column_int: function(_para1:Psqlite3_stmt;
                                               iCol:longint):longint;cdecl;
 sqlite3_column_int64: function(_para1:Psqlite3_stmt; 
                                           iCol:longint):sqlite_int64;cdecl;
 sqlite3_column_text: function(_para1:Psqlite3_stmt;
                                                   iCol:longint):PChar;cdecl;
 sqlite3_column_text16: function(_para1:Psqlite3_stmt; 
                                                  iCol:longint):pointer;cdecl;
 sqlite3_column_type: function(_para1:Psqlite3_stmt; iCol:longint):longint;cdecl;
 sqlite3_finalize: function(pStmt:Psqlite3_stmt):longint;cdecl;
 sqlite3_reset: function(pStmt:Psqlite3_stmt):longint;cdecl;
 sqlite3_create_function: function(_para1:Psqlite3; zFunctionName:Pchar;
                    nArg:longint; eTextRep:longint; _para5:pointer; 
           xFunc:create_function_func_func; xStep:create_function_step_func; 
                    xFinal:create_function_final_func):longint;cdecl;
 sqlite3_create_function16: function(_para1:Psqlite3; zFunctionName:pointer;
                   nArg:longint; eTextRep:longint; _para5:pointer; 
           xFunc:create_function_func_func; xStep:create_function_step_func; 
                     xFinal:create_function_final_func):longint;cdecl;
 sqlite3_aggregate_count: function(_para1:Psqlite3_context):longint;cdecl;
 sqlite3_value_blob: function(_para1:Psqlite3_value):pointer;cdecl;
 sqlite3_value_bytes: function(_para1:Psqlite3_value):longint;cdecl;
 sqlite3_value_bytes16: function(_para1:Psqlite3_value):longint;cdecl;
 sqlite3_value_double: function(_para1:Psqlite3_value):double;cdecl;
 sqlite3_value_int: function(_para1:Psqlite3_value):longint;cdecl;
 sqlite3_value_int64: function(_para1:Psqlite3_value):sqlite_int64;cdecl;
 sqlite3_value_text: function(_para1:Psqlite3_value):PChar;cdecl;
 sqlite3_value_text16: function(_para1:Psqlite3_value):pointer;cdecl;
 sqlite3_value_text16le: function(_para1:Psqlite3_value):pointer;cdecl;
 sqlite3_value_text16be: function(_para1:Psqlite3_value):pointer;cdecl;
 sqlite3_value_type: function(_para1:Psqlite3_value):longint;cdecl;
 sqlite3_aggregate_context: function(_para1:Psqlite3_context;
                                           nBytes:longint):pointer;cdecl;
 sqlite3_user_data: function(_para1:Psqlite3_context):pointer;cdecl;
 sqlite3_get_auxdata: function(_para1:Psqlite3_context;
                                           _para2:longint):pointer;cdecl;
 sqlite3_set_auxdata: procedure(_para1:Psqlite3_context; _para2:longint; 
                   _para3:pointer; _para4:sqlite3_set_auxdata_func);cdecl;
 sqlite3_result_blob: procedure(_para1:Psqlite3_context; _para2:pointer;
                          _para3:longint; _para4:sqlite3_result_func);cdecl;
 sqlite3_result_double: procedure(_para1:Psqlite3_context;
                                               _para2:double);cdecl;
 sqlite3_result_error: procedure(_para1:Psqlite3_context;
                                     _para2:Pchar; _para3:longint);cdecl;
 sqlite3_result_error16: procedure(_para1:Psqlite3_context;
                                    _para2:pointer; _para3:longint);cdecl;
 sqlite3_result_int: procedure(_para1:Psqlite3_context; _para2:longint);cdecl;
 sqlite3_result_int64: procedure(_para1:Psqlite3_context; 
                                               _para2:sqlite_int64);cdecl;
 sqlite3_result_null: procedure(_para1:Psqlite3_context);cdecl;
 sqlite3_result_text: procedure(_para1:Psqlite3_context; _para2:Pchar; 
                          _para3:longint; _para4:sqlite3_result_func);cdecl;
 sqlite3_result_text16: procedure(_para1:Psqlite3_context; _para2:pointer;
                           _para3:longint; _para4:sqlite3_result_func);cdecl;
 sqlite3_result_text16le: procedure(_para1:Psqlite3_context; _para2:pointer; 
                            _para3:longint; _para4:sqlite3_result_func);cdecl;
 sqlite3_result_text16be: procedure(_para1:Psqlite3_context; _para2:pointer;
                            _para3:longint; _para4:sqlite3_result_func);cdecl;
 sqlite3_result_value: procedure(_para1:Psqlite3_context;
                                                 _para2:Psqlite3_value);cdecl;
    
 sqlite3_create_collation: function(_para1:Psqlite3; zName:Pchar;
               eTextRep:longint; _para4:pointer; 
               xCompare:sqlite3_create_collation_func):longint;cdecl;
 sqlite3_create_collation16: function(_para1:Psqlite3; zName:Pchar; 
                 eTextRep:longint; _para4:pointer; 
                 xCompare:sqlite3_create_collation_func):longint;cdecl;
 
 sqlite3_collation_needed: function(_para1:Psqlite3; _para2:pointer;
                            _para3:sqlite3_collation_needed_func):longint;cdecl;
 sqlite3_collation_needed16: function(_para1:Psqlite3; _para2:pointer;
                            _para3:sqlite3_collation_needed_func):longint;cdecl;

 sqlite3_libversion: function:PChar;cdecl;
//Alias for allowing better code portability (win32 is not working with external variables) 
// sqlite3_version: function:PChar;cdecl; macro in 3.7.7

// Not published functions
 sqlite3_libversion_number: function:longint;cdecl;
// sqlite3_key: function(db:Psqlite3; pKey:pointer; nKey:longint):longint;cdecl;
// sqlite3_rekey: function(db:Psqlite3; pKey:pointer; nKey:longint):longint;cdecl;
// sqlite3_sleep: function(_para1:longint):longint;cdecl;
// sqlite3_expired: function(_para1:Psqlite3_stmt):longint;cdecl;
// sqlite3_global_recover: function:longint;cdecl;

function sqlite3_version: PChar;

{$endif} //not mse_sqlite3static
implementation
uses
 sysutils,{$ifndef mse_sqlite3static}{$ifdef FPC}dynlibs,{$endif}{$endif}msesys,msesysintf;
{$ifndef mse_sqlite3static}
var
 libinfo: dynlibinfoty;

function sqlite3_version: PChar;
begin
 result:= sqlite3_libversion();
end;

(*  
function tryinitialisesqlite3(const alibnames: array of filenamety): boolean;
var
 mstr1: filenamety;
begin
 sys_mutexlock(liblock); 
 try
  result:= true;
  if refcount = 0 then begin
   sqlite3libraryhandle:= loadlib(alibnames,mstr1);
   if sqlite3libraryhandle = nilhandle then begin
    result:= false;
    exit;
   end;
   try
    getprocaddresses(sqlite3libraryhandle,
     [
    'sqlite3_close',                //0
    'sqlite3_exec',                 //1
    'sqlite3_last_insert_rowid',    //2
    'sqlite3_changes',              //3
    'sqlite3_total_changes',        //4
    'sqlite3_interrupt',            //5
    'sqlite3_complete',             //6
    'sqlite3_complete16',           //7
    'sqlite3_busy_handler',         //8
    'sqlite3_busy_timeout',         //9
    'sqlite3_get_table',            //10
    'sqlite3_free_table',           //11
    'sqlite3_mprintf',              //12
    'sqlite3_free',                 //13
    'sqlite3_snprintf',             //14
    'sqlite3_set_authorizer',       //15
    'sqlite3_trace',                //16
    'sqlite3_progress_handler',     //17
    'sqlite3_commit_hook',          //18
    'sqlite3_open',                 //19
    'sqlite3_open16',               //20
    'sqlite3_errcode',              //21
    'sqlite3_errmsg',               //22
    'sqlite3_errmsg16',             //23
    'sqlite3_prepare',              //24
    'sqlite3_prepare16',            //25
    'sqlite3_bind_blob',            //26
    'sqlite3_bind_double',          //27
    'sqlite3_bind_int',             //28
    'sqlite3_bind_int64',           //29
    'sqlite3_bind_null',            //30
    'sqlite3_bind_text',            //31
    'sqlite3_bind_text16',          //32
    'sqlite3_bind_blob',            //33
    'sqlite3_bind_text',            //34
    'sqlite3_bind_text16',          //35
    'sqlite3_bind_parameter_count', //36
    'sqlite3_bind_parameter_name',  //37
    'sqlite3_bind_parameter_index', //38
    'sqlite3_column_count',         //39
    'sqlite3_column_name',          //40
    'sqlite3_column_name16',        //41
    'sqlite3_column_decltype',      //42
    'sqlite3_column_decltype16',    //43
    'sqlite3_step',                 //44
    'sqlite3_data_count',           //45
    'sqlite3_column_blob',          //46
    'sqlite3_column_bytes',         //47
    'sqlite3_column_bytes16',       //48
    'sqlite3_column_double',        //49
    'sqlite3_column_int',           //50
    'sqlite3_column_int64',         //51
    'sqlite3_column_text',          //52
    'sqlite3_column_text16',        //53
    'sqlite3_column_type',          //54
    'sqlite3_finalize',             //55
    'sqlite3_reset',                //56
    'sqlite3_create_function',      //57
    'sqlite3_create_function16',    //58
    'sqlite3_aggregate_count',      //59
    'sqlite3_value_blob',           //60
    'sqlite3_value_bytes',          //61
    'sqlite3_value_bytes16',        //62
    'sqlite3_value_double',         //63
    'sqlite3_value_int',            //64
    'sqlite3_value_int64',          //65
    'sqlite3_value_text',           //66
    'sqlite3_value_text16',         //67
    'sqlite3_value_text16le',       //68
    'sqlite3_value_text16be',       //69
    'sqlite3_value_type',           //70
    'sqlite3_aggregate_context',    //71
    'sqlite3_user_data',            //72
    'sqlite3_get_auxdata',          //73
    'sqlite3_set_auxdata',          //74
    'sqlite3_result_blob',          //75
    'sqlite3_result_double',        //76
    'sqlite3_result_error',         //77
    'sqlite3_result_error16',       //78
    'sqlite3_result_int',           //79
    'sqlite3_result_int64',         //80
    'sqlite3_result_null',          //81
    'sqlite3_result_text',          //82
    'sqlite3_result_text16',        //83
    'sqlite3_result_text16le',      //84
    'sqlite3_result_text16be',      //85
    'sqlite3_result_value',         //86
    'sqlite3_create_collation',     //87
    'sqlite3_create_collation16',   //88
    'sqlite3_collation_needed',     //89
    'sqlite3_collation_needed16',   //90
    'sqlite3_libversion',           //91
    'sqlite3_version',              //92
    'sqlite3_libversion_number',    //93
    'sqlite3_clear_bindings'        //94 
      ],
      [
    @sqlite3_close,                 //0
    @sqlite3_exec,                  //1
    @sqlite3_last_insert_rowid,     //2
    @sqlite3_changes,               //3
    @sqlite3_total_changes,         //4
    @sqlite3_interrupt,             //5
    @sqlite3_complete,              //6
    @sqlite3_complete16,            //7
    @sqlite3_busy_handler,          //8
    @sqlite3_busy_timeout,          //9
    @sqlite3_get_table,             //10
    @sqlite3_free_table,            //11
    @sqlite3_mprintf,               //12
    @sqlite3_free,                  //13
    @sqlite3_snprintf,              //14
    @sqlite3_set_authorizer,        //15
    @sqlite3_trace,                 //16
    @sqlite3_progress_handler,      //17
    @sqlite3_commit_hook,           //18
    @sqlite3_open,                  //19
    @sqlite3_open16,                //20
    @sqlite3_errcode,               //21
    @sqlite3_errmsg,                //22
    @sqlite3_errmsg16,              //23
    @sqlite3_prepare,               //24
    @sqlite3_prepare16,             //25
    @sqlite3_bind_blob,             //26
    @sqlite3_bind_double,           //27
    @sqlite3_bind_int,              //28
    @sqlite3_bind_int64,            //29
    @sqlite3_bind_null,             //30
    @sqlite3_bind_text,             //31
    @sqlite3_bind_text16,           //32
    @sqlite3_bind_blob1,            //33
    @sqlite3_bind_text1,            //34
    @sqlite3_bind_text161,          //35
    @sqlite3_bind_parameter_count,  //36
    @sqlite3_bind_parameter_name,   //37
    @sqlite3_bind_parameter_index,  //38
    @sqlite3_column_count,          //39
    @sqlite3_column_name,           //40
    @sqlite3_column_name16,         //41
    @sqlite3_column_decltype,       //42
    @sqlite3_column_decltype16,     //43
    @sqlite3_step,                  //44
    @sqlite3_data_count,            //45
    @sqlite3_column_blob,           //46
    @sqlite3_column_bytes,          //47
    @sqlite3_column_bytes16,        //48
    @sqlite3_column_double,         //49
    @sqlite3_column_int,            //50
    @sqlite3_column_int64,          //51
    @sqlite3_column_text,           //52
    @sqlite3_column_text16,         //53
    @sqlite3_column_type,           //54
    @sqlite3_finalize,              //55
    @sqlite3_reset,                 //56
    @sqlite3_create_function,       //57
    @sqlite3_create_function16,     //58
    @sqlite3_aggregate_count,       //59
    @sqlite3_value_blob,            //60
    @sqlite3_value_bytes,           //61
    @sqlite3_value_bytes16,         //62
    @sqlite3_value_double,          //63
    @sqlite3_value_int,             //64
    @sqlite3_value_int64,           //65
    @sqlite3_value_text,            //66
    @sqlite3_value_text16,          //67
    @sqlite3_value_text16le,        //68
    @sqlite3_value_text16be,        //69
    @sqlite3_value_type,            //70
    @sqlite3_aggregate_context,     //71
    @sqlite3_user_data,             //72
    @sqlite3_get_auxdata,           //73
    @sqlite3_set_auxdata,           //74
    @sqlite3_result_blob,           //75
    @sqlite3_result_double,         //76
    @sqlite3_result_error,          //77
    @sqlite3_result_error16,        //78
    @sqlite3_result_int,            //79
    @sqlite3_result_int64,          //80
    @sqlite3_result_null,           //81
    @sqlite3_result_text,           //82
    @sqlite3_result_text16,         //83
    @sqlite3_result_text16le,       //84
    @sqlite3_result_text16be,       //85
    @sqlite3_result_value,          //86
    @sqlite3_create_collation,      //87
    @sqlite3_create_collation16,    //88
    @sqlite3_collation_needed,      //89
    @sqlite3_collation_needed16,    //90
    @sqlite3_libversion,            //91
    @sqlite3_version,               //92
    @sqlite3_libversion_number,     //93
    @sqlite3_clear_bindings         //94
      ]);
   except
    on e: exception do begin
     e.message:= 'Library "'+mstr1+'": '+e.message;
     result:= false;
     if unloadlibrary(sqlite3libraryhandle) then begin
      sqlite3libraryhandle:= nilhandle;
     end;
     raise;
    end;
   end;
  end;
  inc(refcount);
 finally
  sys_mutexunlock(liblock);
 end;
end;
*)

procedure initializesqlite3(const sonames: array of filenamety);
const
 funcs: array[0..93] of funcinfoty = (
  (n: 'sqlite3_close'; d: {$ifndef FPC}@{$endif}@sqlite3_close),
  (n: 'sqlite3_exec'; d: {$ifndef FPC}@{$endif}@sqlite3_exec),
  (n: 'sqlite3_last_insert_rowid'; d: {$ifndef FPC}@{$endif}@sqlite3_last_insert_rowid),
  (n: 'sqlite3_changes'; d: {$ifndef FPC}@{$endif}@sqlite3_changes),
  (n: 'sqlite3_total_changes'; d: {$ifndef FPC}@{$endif}@sqlite3_total_changes),
  (n: 'sqlite3_interrupt'; d: {$ifndef FPC}@{$endif}@sqlite3_interrupt),
  (n: 'sqlite3_complete'; d: {$ifndef FPC}@{$endif}@sqlite3_complete),
  (n: 'sqlite3_complete16'; d: {$ifndef FPC}@{$endif}@sqlite3_complete16),
  (n: 'sqlite3_busy_handler'; d: {$ifndef FPC}@{$endif}@sqlite3_busy_handler),
  (n: 'sqlite3_busy_timeout'; d: {$ifndef FPC}@{$endif}@sqlite3_busy_timeout),
  (n: 'sqlite3_get_table'; d: {$ifndef FPC}@{$endif}@sqlite3_get_table),
  (n: 'sqlite3_free_table'; d: {$ifndef FPC}@{$endif}@sqlite3_free_table),
  (n: 'sqlite3_mprintf'; d: {$ifndef FPC}@{$endif}@sqlite3_mprintf),
  (n: 'sqlite3_free'; d: {$ifndef FPC}@{$endif}@sqlite3_free),
  (n: 'sqlite3_snprintf'; d: {$ifndef FPC}@{$endif}@sqlite3_snprintf),
  (n: 'sqlite3_set_authorizer'; d: {$ifndef FPC}@{$endif}@sqlite3_set_authorizer),
  (n: 'sqlite3_trace'; d: {$ifndef FPC}@{$endif}@sqlite3_trace),
  (n: 'sqlite3_progress_handler'; d: {$ifndef FPC}@{$endif}@sqlite3_progress_handler),
  (n: 'sqlite3_commit_hook'; d: {$ifndef FPC}@{$endif}@sqlite3_commit_hook),
  (n: 'sqlite3_open'; d: {$ifndef FPC}@{$endif}@sqlite3_open),
  (n: 'sqlite3_open16'; d: {$ifndef FPC}@{$endif}@sqlite3_open16),
  (n: 'sqlite3_errcode'; d: {$ifndef FPC}@{$endif}@sqlite3_errcode),
  (n: 'sqlite3_errmsg'; d: {$ifndef FPC}@{$endif}@sqlite3_errmsg),
  (n: 'sqlite3_errmsg16'; d: {$ifndef FPC}@{$endif}@sqlite3_errmsg16),
  (n: 'sqlite3_prepare'; d: {$ifndef FPC}@{$endif}@sqlite3_prepare),
  (n: 'sqlite3_prepare16'; d: {$ifndef FPC}@{$endif}@sqlite3_prepare16),
  (n: 'sqlite3_bind_blob'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_blob),
  (n: 'sqlite3_bind_double'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_double),
  (n: 'sqlite3_bind_int'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_int),
  (n: 'sqlite3_bind_int64'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_int64),
  (n: 'sqlite3_bind_null'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_null),
  (n: 'sqlite3_bind_text'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_text),
  (n: 'sqlite3_bind_text16'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_text16),
  (n: 'sqlite3_bind_blob'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_blob),
  (n: 'sqlite3_bind_text'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_text),
  (n: 'sqlite3_bind_text16'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_text16),
  (n: 'sqlite3_bind_parameter_count'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_parameter_count),
  (n: 'sqlite3_bind_parameter_name'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_parameter_name),
  (n: 'sqlite3_bind_parameter_index'; d: {$ifndef FPC}@{$endif}@sqlite3_bind_parameter_index),
  (n: 'sqlite3_column_count'; d: {$ifndef FPC}@{$endif}@sqlite3_column_count),
  (n: 'sqlite3_column_name'; d: {$ifndef FPC}@{$endif}@sqlite3_column_name),
  (n: 'sqlite3_column_name16'; d: {$ifndef FPC}@{$endif}@sqlite3_column_name16),
  (n: 'sqlite3_column_decltype'; d: {$ifndef FPC}@{$endif}@sqlite3_column_decltype),
  (n: 'sqlite3_column_decltype16'; d: {$ifndef FPC}@{$endif}@sqlite3_column_decltype16),
  (n: 'sqlite3_step'; d: {$ifndef FPC}@{$endif}@sqlite3_step),
  (n: 'sqlite3_data_count'; d: {$ifndef FPC}@{$endif}@sqlite3_data_count),
  (n: 'sqlite3_column_blob'; d: {$ifndef FPC}@{$endif}@sqlite3_column_blob),
  (n: 'sqlite3_column_bytes'; d: {$ifndef FPC}@{$endif}@sqlite3_column_bytes),
  (n: 'sqlite3_column_bytes16'; d: {$ifndef FPC}@{$endif}@sqlite3_column_bytes16),
  (n: 'sqlite3_column_double'; d: {$ifndef FPC}@{$endif}@sqlite3_column_double),
  (n: 'sqlite3_column_int'; d: {$ifndef FPC}@{$endif}@sqlite3_column_int),
  (n: 'sqlite3_column_int64'; d: {$ifndef FPC}@{$endif}@sqlite3_column_int64),
  (n: 'sqlite3_column_text'; d: {$ifndef FPC}@{$endif}@sqlite3_column_text),
  (n: 'sqlite3_column_text16'; d: {$ifndef FPC}@{$endif}@sqlite3_column_text16),
  (n: 'sqlite3_column_type'; d: {$ifndef FPC}@{$endif}@sqlite3_column_type),
  (n: 'sqlite3_finalize'; d: {$ifndef FPC}@{$endif}@sqlite3_finalize),
  (n: 'sqlite3_reset'; d: {$ifndef FPC}@{$endif}@sqlite3_reset),
  (n: 'sqlite3_create_function'; d: {$ifndef FPC}@{$endif}@sqlite3_create_function),
  (n: 'sqlite3_create_function16'; d: {$ifndef FPC}@{$endif}@sqlite3_create_function16),
  (n: 'sqlite3_aggregate_count'; d: {$ifndef FPC}@{$endif}@sqlite3_aggregate_count),
  (n: 'sqlite3_value_blob'; d: {$ifndef FPC}@{$endif}@sqlite3_value_blob),
  (n: 'sqlite3_value_bytes'; d: {$ifndef FPC}@{$endif}@sqlite3_value_bytes),
  (n: 'sqlite3_value_bytes16'; d: {$ifndef FPC}@{$endif}@sqlite3_value_bytes16),
  (n: 'sqlite3_value_double'; d: {$ifndef FPC}@{$endif}@sqlite3_value_double),
  (n: 'sqlite3_value_int'; d: {$ifndef FPC}@{$endif}@sqlite3_value_int),
  (n: 'sqlite3_value_int64'; d: {$ifndef FPC}@{$endif}@sqlite3_value_int64),
  (n: 'sqlite3_value_text'; d: {$ifndef FPC}@{$endif}@sqlite3_value_text),
  (n: 'sqlite3_value_text16'; d: {$ifndef FPC}@{$endif}@sqlite3_value_text16),
  (n: 'sqlite3_value_text16le'; d: {$ifndef FPC}@{$endif}@sqlite3_value_text16le),
  (n: 'sqlite3_value_text16be'; d: {$ifndef FPC}@{$endif}@sqlite3_value_text16be),
  (n: 'sqlite3_value_type'; d: {$ifndef FPC}@{$endif}@sqlite3_value_type),
  (n: 'sqlite3_aggregate_context'; d: {$ifndef FPC}@{$endif}@sqlite3_aggregate_context),
  (n: 'sqlite3_user_data'; d: {$ifndef FPC}@{$endif}@sqlite3_user_data),
  (n: 'sqlite3_get_auxdata'; d: {$ifndef FPC}@{$endif}@sqlite3_get_auxdata),
  (n: 'sqlite3_set_auxdata'; d: {$ifndef FPC}@{$endif}@sqlite3_set_auxdata),
  (n: 'sqlite3_result_blob'; d: {$ifndef FPC}@{$endif}@sqlite3_result_blob),
  (n: 'sqlite3_result_double'; d: {$ifndef FPC}@{$endif}@sqlite3_result_double),
  (n: 'sqlite3_result_error'; d: {$ifndef FPC}@{$endif}@sqlite3_result_error),
  (n: 'sqlite3_result_error16'; d: {$ifndef FPC}@{$endif}@sqlite3_result_error16),
  (n: 'sqlite3_result_int'; d: {$ifndef FPC}@{$endif}@sqlite3_result_int),
  (n: 'sqlite3_result_int64'; d: {$ifndef FPC}@{$endif}@sqlite3_result_int64),
  (n: 'sqlite3_result_null'; d: {$ifndef FPC}@{$endif}@sqlite3_result_null),
  (n: 'sqlite3_result_text'; d: {$ifndef FPC}@{$endif}@sqlite3_result_text),
  (n: 'sqlite3_result_text16'; d: {$ifndef FPC}@{$endif}@sqlite3_result_text16),
  (n: 'sqlite3_result_text16le'; d: {$ifndef FPC}@{$endif}@sqlite3_result_text16le),
  (n: 'sqlite3_result_text16be'; d: {$ifndef FPC}@{$endif}@sqlite3_result_text16be),
  (n: 'sqlite3_result_value'; d: {$ifndef FPC}@{$endif}@sqlite3_result_value),
  (n: 'sqlite3_create_collation'; d: {$ifndef FPC}@{$endif}@sqlite3_create_collation),
  (n: 'sqlite3_create_collation16'; d: {$ifndef FPC}@{$endif}@sqlite3_create_collation16),
  (n: 'sqlite3_collation_needed'; d: {$ifndef FPC}@{$endif}@sqlite3_collation_needed),
  (n: 'sqlite3_collation_needed16'; d: {$ifndef FPC}@{$endif}@sqlite3_collation_needed16),
  (n: 'sqlite3_libversion'; d: {$ifndef FPC}@{$endif}@sqlite3_libversion),
//  (n: 'sqlite3_version'; d: {$ifndef FPC}@{$endif}@sqlite3_version),
  (n: 'sqlite3_libversion_number'; d: {$ifndef FPC}@{$endif}@sqlite3_libversion_number),
  (n: 'sqlite3_clear_bindings'; d: {$ifndef FPC}@{$endif}@sqlite3_clear_bindings)
 );
 errormessage = 'Can not load Sqlite3 library. ';
begin
 initializedynlib(libinfo,sonames,sqlite3lib,funcs,[],errormessage);
end;

procedure releasesqlite3;
begin
 releasedynlib(libinfo);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
{$else}
procedure initialisesqlite3;
begin
 //dummy
end;

procedure releasesqlite3;
begin
 //dummy
end;
 
{$endif} //mse_sqlite3static
end.
