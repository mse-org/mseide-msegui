{
  This file is created by H2Pas, and thereafter heavily edited to make it
  readable and dynamically loadable.

  The goal was not to be complete, but to make it work and maintainable.

  The mysql_com.h, mysql.h and some other files are merged together into this
  one file.

  Automatically converted by H2Pas 1.0.0 from mysql_com.h / mysql.h
  The following command line parameters were used:
    -p
    -D
    -l
    mysqlclient
    mysql_com.h / mysql.h

}
{$MODE objfpc}
{$MACRO on}

interface

uses
{$IFDEF LinkDynamically}
     Dynlibs, sysutils,
{$ENDIF}
     ctypes;

{$IFDEF Unix}
  {$DEFINE extdecl:=cdecl}
  const
    mysqllib = 'libmysqlclient.so';
{$ENDIF}
{$IFDEF Win32}
  {$DEFINE extdecl:=stdcall}
  const
    mysqllib = 'libmysql.dll';
{$ENDIF}

{$IFDEF mysql50}
  {$DEFINE mysql41}
{$ENDIF mysql50}

{$PACKRECORDS C}

  { Copyright (C) 2000-2003 MySQL AB
  
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.
  
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
  
     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  }

    type
       my_bool = byte;
       Pmy_bool  = ^my_bool;

       PVIO = Pointer;

       Pgptr = ^gptr;
       gptr = ^char;

       Pmy_socket = ^my_socket;
       my_socket = longint;
       
       pppchar = ^ppchar;
       PPByte     = ^PByte;

{  ------------ Start of declaration in "mysql_com.h"   ---------------------  }

  {
  ** Common definition between mysql server & client
   }

  { Field/table name length  }

  const
     NAME_LEN = 64;
     HOSTNAME_LENGTH = 60;
     USERNAME_LENGTH = 16;
     SERVER_VERSION_LENGTH = 60;
     SQLSTATE_LENGTH = 5;
     LOCAL_HOST = 'localhost';
     LOCAL_HOST_NAMEDPIPE = '.';

  const
     MYSQL_NAMEDPIPE = 'MySQL';
     MYSQL_SERVICENAME = 'MySQL';

  type
     enum_server_command = (COM_SLEEP,COM_QUIT,COM_INIT_DB,COM_QUERY,
       COM_FIELD_LIST,COM_CREATE_DB,COM_DROP_DB,
       COM_REFRESH,COM_SHUTDOWN,COM_STATISTICS,
       COM_PROCESS_INFO,COM_CONNECT,COM_PROCESS_KILL,
       COM_DEBUG,COM_PING,COM_TIME,COM_DELAYED_INSERT,
       COM_CHANGE_USER,COM_BINLOG_DUMP,COM_TABLE_DUMP,
       COM_CONNECT_OUT,COM_REGISTER_SLAVE,
{$IFDEF mysql50}
       COM_STMT_PREPARE, COM_STMT_EXECUTE, COM_STMT_SEND_LONG_DATA, COM_STMT_CLOSE,
       COM_STMT_RESET, COM_SET_OPTION, COM_STMT_FETCH,
{$ELSE}
  {$IFDEF mysql41}
       COM_PREPARE,COM_EXECUTE,COM_LONG_DATA,COM_CLOSE_STMT,
       COM_RESET_STMT,COM_SET_OPTION,
  {$ENDIF}
{$ENDIF}
       COM_END
       );

  {
    Length of random string sent by server on handshake; this is also length of
    obfuscated password, recieved from client
   }

  const
     SCRAMBLE_LENGTH = 20;
     SCRAMBLE_LENGTH_323 = 8;

  { length of password stored in the db: new passwords are preceeded with '*'  }

     SCRAMBLED_PASSWORD_CHAR_LENGTH = SCRAMBLE_LENGTH*2+1;
     SCRAMBLED_PASSWORD_CHAR_LENGTH_323 = SCRAMBLE_LENGTH_323*2;


       NOT_NULL_FLAG = 1;       //  Field can't be NULL
       PRI_KEY_FLAG = 2;        //  Field is part of a primary key
       UNIQUE_KEY_FLAG = 4;     //  Field is part of a unique key
       MULTIPLE_KEY_FLAG = 8;   //  Field is part of a key
       BLOB_FLAG = 16;          //  Field is a blob
       UNSIGNED_FLAG = 32;      //  Field is unsigned
       ZEROFILL_FLAG = 64;      //  Field is zerofill
       BINARY_FLAG = 128;       //  Field is binary

    { The following are only sent to new clients  }

       ENUM_FLAG = 256;            // field is an enum
       AUTO_INCREMENT_FLAG = 512;  // field is a autoincrement field
       TIMESTAMP_FLAG = 1024;      // Field is a timestamp
       SET_FLAG = 2048;            // field is a set
{$IFDEF mysql50}
       NO_DEFAULT_VALUE_FLAG=4096; // Field doesn't have default value
{$ENDIF}
       NUM_FLAG = 32768;           // Field is num (for clients)
       PART_KEY_FLAG = 16384;      // Intern; Part of some key
       GROUP_FLAG = 32768;         // Intern: Group field
       UNIQUE_FLAG = 65536;        // Intern: Used by sql_yacc
       BINCMP_FLAG = 131072;       // Intern: Used by sql_yacc

       REFRESH_GRANT = 1;          // Refresh grant tables
       REFRESH_LOG = 2;            // Start on new log file
       REFRESH_TABLES = 4;         // close all tables
       REFRESH_HOSTS = 8;          // Flush host cache
       REFRESH_STATUS = 16;        // Flush status variables
       REFRESH_THREADS = 32;       // Flush thread cache
       REFRESH_SLAVE = 64;         // Reset master info and restart slave thread
       REFRESH_MASTER = 128;       // Remove all bin logs in the index and truncate the index

    { The following can't be set with mysql_refresh()  }
       REFRESH_READ_LOCK = 16384;          // Lock tables for read
       REFRESH_FAST = 32768;               // Intern flag
       REFRESH_QUERY_CACHE = 65536;        // RESET (remove all queries) from query cache
       REFRESH_QUERY_CACHE_FREE = $20000;  // pack query cache

       REFRESH_DES_KEY_FILE = $40000;
       REFRESH_USER_RESOURCES = $80000;

       CLIENT_LONG_PASSWORD = 1;           // new more secure passwords
       CLIENT_FOUND_ROWS = 2;              // Found instead of affected rows
       CLIENT_LONG_FLAG = 4;               // Get all column flags
       CLIENT_CONNECT_WITH_DB = 8;         // One can specify db on connect
       CLIENT_NO_SCHEMA = 16;              // Don't allow database.table.column
       CLIENT_COMPRESS = 32;               // Can use compression protocol
       CLIENT_ODBC = 64;                   // Odbc client
       CLIENT_LOCAL_FILES = 128;           // Can use LOAD DATA LOCAL
       CLIENT_IGNORE_SPACE = 256;          // Ignore spaces before '('
       CLIENT_PROTOCOL_41 = 512;           // New 4.1 protocol
       CLIENT_INTERACTIVE = 1024;          // This is an interactive client
       CLIENT_SSL = 2048;                  // Switch to SSL after handshake
       CLIENT_IGNORE_SIGPIPE = 4096;       // IGNORE sigpipes
       CLIENT_TRANSACTIONS = 8192;         // Client knows about transactions
       CLIENT_RESERVED = 16384;            // Old flag for 4.1 protocol
       CLIENT_SECURE_CONNECTION = 32768;   // New 4.1 authentication
       CLIENT_MULTI_STATEMENTS = 65536;    // Enable/disable multi-stmt support
       CLIENT_MULTI_RESULTS = 131072;      // Enable/disable multi-results
       CLIENT_REMEMBER_OPTIONS : cardinal = 1 shl 31;


       SERVER_STATUS_IN_TRANS = 1;         // Transaction has started
       SERVER_STATUS_AUTOCOMMIT = 2;       // Server in auto_commit mode
       SERVER_STATUS_MORE_RESULTS = 4;     // More results on server
       SERVER_MORE_RESULTS_EXISTS = 8;     // Multi query - next query exists
       SERVER_QUERY_NO_GOOD_INDEX_USED = 16;
       SERVER_QUERY_NO_INDEX_USED = 32;
{$IFDEF mysql50}
    { The server was able to fulfill the clients request and opened a
      read-only non-scrollable cursor for a query. This flag comes
      in reply to COM_STMT_EXECUTE and COM_STMT_FETCH commands. }
       SERVER_STATUS_CURSOR_EXISTS = 64;
    { This flag is sent when a read-only cursor is exhausted, in reply to
      COM_STMT_FETCH command. }
       SERVER_STATUS_LAST_ROW_SENT = 128;
{$ENDIF}
       SERVER_STATUS_DB_DROPPED = 256;     // A database was dropped
{$IFDEF mysql50}
       SERVER_STATUS_NO_BACKSLASH_ESCAPES = 512;
{$ENDIF}

{$IFDEF mysql41}
       MYSQL_ERRMSG_SIZE = 512;
{$ELSE}
       MYSQL_ERRMSG_SIZE = 200;
{$ENDIF}
       NET_READ_TIMEOUT = 30;              // Timeout on read
       NET_WRITE_TIMEOUT = 60;             // Timeout on write
       NET_WAIT_TIMEOUT	= 8*60*60;         // Wait for new query
{$IFDEF mysql50}
       ONLY_KILL_QUERY = 1;
{$ENDIF}


    const
       MAX_TINYINT_WIDTH = 3;           // Max width for a TINY w.o. sign
       MAX_SMALLINT_WIDTH = 5;          // Max width for a SHORT w.o. sign
       MAX_MEDIUMINT_WIDTH = 8;         // Max width for a INT24 w.o. sign
       MAX_INT_WIDTH = 10;              // Max width for a LONG w.o. sign
       MAX_BIGINT_WIDTH = 20;           // Max width for a LONGLONG
       MAX_CHAR_WIDTH = 255;            // Max length for a CHAR colum
       MAX_BLOB_WIDTH = 8192;           // Default width for blob

    type
       Pst_net = ^st_net;
       st_net = record
{ $if !defined(CHECK_EMBEDDED_DIFFERENCES) || !defined(EMBEDDED_LIBRARY)}
            vio : PVio;
            buff : Pbyte;
            buff_end : Pbyte;
            write_pos : Pbyte;
            read_pos : Pbyte;
            fd : my_socket;     // For Perl DBI/dbd
            max_packet : dword;
            max_packet_size : dword;
{$IFNDEF mysql41}
            last_errno : dword;
{$ENDIF}
            pkt_nr : dword;
            compress_pkt_nr : dword;
            write_timeout : dword;
            read_timeout : dword;
            retry_count : dword;
            fcntl : longint;
{$IFNDEF mysql41}
            last_error : array[0..(MYSQL_ERRMSG_SIZE)-1] of char;
            error : byte;
            return_errno : my_bool;
{$ENDIF}
            compress : my_bool;
    {   The following variable is set if we are doing several queries in one
        command ( as in LOAD TABLE ... FROM MASTER ),
        and do not want to confuse the client with OK at the wrong time }
            remain_in_buf : dword;
            length : dword;
            buf_length : dword;
            where_b : dword;
            return_status : Pdword;
            reading_or_writing : byte;
            save_char : char;
            no_send_ok : my_bool;     // For SPs and other things that do multiple stmts
{$IFDEF mysql50}
            no_send_eof : my_bool;    // For SPs' first version read-only cursors
            no_send_error : my_bool;  // Set if OK packet is already sent, and
                                      // we do not need to send error messages
{$ENDIF}
    {   Pointer to query object in query cache, do not equal NULL (0) for
        queries in cache that have not stored its results yet }
{ $endif}
{$IFDEF mysql41}
            last_error : array[0..(MYSQL_ERRMSG_SIZE)-1] of char;
            sqlstate : array[0..(SQLSTATE_LENGTH+1)-1] of char;
            last_errno : dword;
            error : byte;
{$ENDIF}
            query_cache_query : gptr;
{$IFDEF mysql41}
            report_error : my_bool;   // We should report error (we have unreported error)
            return_errno : my_bool;
{$ENDIF}
         end;
       NET = st_net;
       PNET = ^NET;

    const
       packet_error : culong = not(0);

    type
       enum_field_types = (MYSQL_TYPE_DECIMAL,MYSQL_TYPE_TINY,
         MYSQL_TYPE_SHORT,MYSQL_TYPE_LONG,MYSQL_TYPE_FLOAT,
         MYSQL_TYPE_DOUBLE,MYSQL_TYPE_NULL,
         MYSQL_TYPE_TIMESTAMP,MYSQL_TYPE_LONGLONG,
         MYSQL_TYPE_INT24,MYSQL_TYPE_DATE,MYSQL_TYPE_TIME,
         MYSQL_TYPE_DATETIME,MYSQL_TYPE_YEAR,
         MYSQL_TYPE_NEWDATE,
{$IFDEF mysql50}
         MYSQL_TYPE_VARCHAR, MYSQL_TYPE_BIT, MYSQL_TYPE_NEWDECIMAL=246,
{$ENDIF}
         MYSQL_TYPE_ENUM := 247,
         MYSQL_TYPE_SET := 248,MYSQL_TYPE_TINY_BLOB := 249,
         MYSQL_TYPE_MEDIUM_BLOB := 250,MYSQL_TYPE_LONG_BLOB := 251,
         MYSQL_TYPE_BLOB := 252,MYSQL_TYPE_VAR_STRING := 253,
         MYSQL_TYPE_STRING := 254,MYSQL_TYPE_GEOMETRY := 255
         );

    { For backward compatibility  }

    const
       CLIENT_MULTI_QUERIES = CLIENT_MULTI_STATEMENTS;
       FIELD_TYPE_DECIMAL = MYSQL_TYPE_DECIMAL;
{$IFDEF mysql50}
       FIELD_TYPE_NEWDECIMAL = MYSQL_TYPE_NEWDECIMAL;
{$ENDIF}
       FIELD_TYPE_TINY = MYSQL_TYPE_TINY;
       FIELD_TYPE_SHORT = MYSQL_TYPE_SHORT;
       FIELD_TYPE_LONG = MYSQL_TYPE_LONG;
       FIELD_TYPE_FLOAT = MYSQL_TYPE_FLOAT;
       FIELD_TYPE_DOUBLE = MYSQL_TYPE_DOUBLE;
       FIELD_TYPE_NULL = MYSQL_TYPE_NULL;
       FIELD_TYPE_TIMESTAMP = MYSQL_TYPE_TIMESTAMP;
       FIELD_TYPE_LONGLONG = MYSQL_TYPE_LONGLONG;
       FIELD_TYPE_INT24 = MYSQL_TYPE_INT24;
       FIELD_TYPE_DATE = MYSQL_TYPE_DATE;
       FIELD_TYPE_TIME = MYSQL_TYPE_TIME;
       FIELD_TYPE_DATETIME = MYSQL_TYPE_DATETIME;
       FIELD_TYPE_YEAR = MYSQL_TYPE_YEAR;
       FIELD_TYPE_NEWDATE = MYSQL_TYPE_NEWDATE;
       FIELD_TYPE_ENUM = MYSQL_TYPE_ENUM;
       FIELD_TYPE_SET = MYSQL_TYPE_SET;
       FIELD_TYPE_TINY_BLOB = MYSQL_TYPE_TINY_BLOB;
       FIELD_TYPE_MEDIUM_BLOB = MYSQL_TYPE_MEDIUM_BLOB;
       FIELD_TYPE_LONG_BLOB = MYSQL_TYPE_LONG_BLOB;
       FIELD_TYPE_BLOB = MYSQL_TYPE_BLOB;
       FIELD_TYPE_VAR_STRING = MYSQL_TYPE_VAR_STRING;
       FIELD_TYPE_STRING = MYSQL_TYPE_STRING;
       FIELD_TYPE_CHAR = MYSQL_TYPE_TINY;
       FIELD_TYPE_INTERVAL = MYSQL_TYPE_ENUM;
       FIELD_TYPE_GEOMETRY = MYSQL_TYPE_GEOMETRY;
{$IFDEF mysql50}
       FIELD_TYPE_BIT = MYSQL_TYPE_BIT;
{$ENDIF}
    { Shutdown/kill enums and constants  }
    { Bits for THD::killable.  }
       MYSQL_SHUTDOWN_KILLABLE_CONNECT    : byte = 1 shl 0;
       MYSQL_SHUTDOWN_KILLABLE_TRANS      : byte = 1 shl 1;
       MYSQL_SHUTDOWN_KILLABLE_LOCK_TABLE : byte = 1 shl 2;
       MYSQL_SHUTDOWN_KILLABLE_UPDATE     : byte = 1 shl 3;


    {   We want levels to be in growing order of hardness (because we use number
        comparisons). Note that DEFAULT does not respect the growing property, but
        it's ok.  }
    type
       mysql_enum_shutdown_level = (SHUTDOWN_DEFAULT := 0,
         SHUTDOWN_WAIT_CONNECTIONS := 1, //MYSQL_SHUTDOWN_KILLABLE_CONNECT,     // wait for existing connections to finish
         SHUTDOWN_WAIT_TRANSACTIONS := 2, //MYSQL_SHUTDOWN_KILLABLE_TRANS,      // wait for existing trans to finish
         SHUTDOWN_WAIT_UPDATES := 8, //MYSQL_SHUTDOWN_KILLABLE_UPDATE,          // wait for existing updates to finish (=> no partial MyISAM update)
         SHUTDOWN_WAIT_ALL_BUFFERS := 16, //MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1,// flush InnoDB buffers and other storage engines' buffers
         SHUTDOWN_WAIT_CRITICAL_BUFFERS := 17, //(MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1)+1, // don't flush InnoDB buffers, flush other storage engines' buffers
    { Now the 2 levels of the KILL command  }
{ $if MYSQL_VERSION_ID >= 50000}
         KILL_QUERY := 254,
{ $endif}
         KILL_CONNECTION := 255
         );

{$IFDEF mysql50}
       enum_cursor_type = (CURSOR_TYPE_NO_CURSOR := 0,CURSOR_TYPE_READ_ONLY := 1,
         CURSOR_TYPE_FOR_UPDATE := 2,CURSOR_TYPE_SCROLLABLE := 4
         );
{$ENDIF}

    { options for mysql_set_option  }
       enum_mysql_set_option = (MYSQL_OPTION_MULTI_STATEMENTS_ON,
         MYSQL_OPTION_MULTI_STATEMENTS_OFF
         );

    function net_new_transaction(net : st_net) : st_net;

{$IFNDEF LinkDynamically}
    function my_net_init(net:PNET; vio:PVio):my_bool;cdecl;external mysqllib name 'my_net_init';
    procedure my_net_local_init(net:PNET);cdecl;external mysqllib name 'my_net_local_init';
    procedure net_end(net:PNET);cdecl;external mysqllib name 'net_end';
    procedure net_clear(net:PNET);cdecl;external mysqllib name 'net_clear';
    function net_realloc(net:PNET; length:dword):my_bool;cdecl;external mysqllib name 'net_realloc';
    function net_flush(net:PNET):my_bool;cdecl;external mysqllib name 'net_flush';
    function my_net_write(net:PNET; packet:Pchar; len:dword):my_bool;cdecl;external mysqllib name 'my_net_write';
    function net_write_command(net:PNET; command:byte; header:Pchar; head_len:dword; packet:Pchar;
               len:dword):my_bool;cdecl;external mysqllib name 'net_write_command';
    function net_real_write(net:PNET; packet:Pchar; len:dword):longint;cdecl;external mysqllib name 'net_real_write';
    function my_net_read(net:PNET):dword;cdecl;external mysqllib name 'my_net_read';
{$ENDIF}
    { The following function is not meant for normal usage
      Currently it's used internally by manager.c  }

    type
       Psockaddr = ^sockaddr;
       sockaddr = record
           // undefined structure
         end;
{$IFNDEF LinkDynamically}
    function my_connect(s:my_socket; name:Psockaddr; namelen:dword; timeout:dword):longint;cdecl;external mysqllib name 'my_connect';
{$ENDIF}

    type
       Prand_struct = ^rand_struct;
       rand_struct = record
            seed1 : dword;
            seed2 : dword;
            max_value : dword;
            max_value_dbl : double;
         end;

    { The following is for user defined functions  }
{$IFDEF mysql50}
       Item_result = (STRING_RESULT,REAL_RESULT,INT_RESULT,
         ROW_RESULT);
{$ELSE}
       Item_result = (STRING_RESULT := 0,REAL_RESULT,INT_RESULT,
         ROW_RESULT,DECIMAL_RESULT);
{$ENDIF}
       PItem_result = ^Item_result;

       Pst_udf_args = ^st_udf_args;
       st_udf_args = record
            arg_count : dword;           // Number of arguments
            arg_type : PItem_result;     // Pointer to item_results
            args : ^Pchar;               // Pointer to item_results
            lengths : Pdword;            // Length of string arguments
            maybe_null : Pchar;          // Length of string arguments
{$IFDEF mysql50}
            attributes : ^pchar;         // Pointer to attribute name
            attribute_lengths : ^dword;  // Length of attribute arguments
{$ENDIF}
         end;
       UDF_ARGS = st_udf_args;
       PUDF_ARGS = ^UDF_ARGS;

    { This holds information about the result  }

       Pst_udf_init = ^st_udf_init;
       st_udf_init = record
            maybe_null : my_bool;        // 1 if function can return NULL
            decimals : dword;            // for real functions
            max_length : dword;          // For string functions
            ptr : Pchar;                 // free pointer for function data
            const_item : my_bool;        // free pointer for function data
         end;
       UDF_INIT = st_udf_init;
       PUDF_INIT = ^UDF_INIT;

    { Constants when using compression  }
    const
       NET_HEADER_SIZE = 4;              // standard header size
       COMP_HEADER_SIZE = 3;             // compression header extra size

    { Prototypes to password functions  }

    { These functions are used for authentication by client and server and
      implemented in sql/password.c     }
{$IFNDEF LinkDynamically}
    procedure randominit(_para1:Prand_struct; seed1:dword; seed2:dword);cdecl;external mysqllib name 'randominit';
    function my_rnd(_para1:Prand_struct):double;cdecl;external mysqllib name 'my_rnd';
    procedure create_random_string(fto:Pchar; length:dword; rand_st:Prand_struct);cdecl;external mysqllib name 'create_random_string';
    procedure hash_password(fto:Pdword; password:Pchar; password_len:dword);cdecl;external mysqllib name 'hash_password';
    procedure make_scrambled_password_323(fto:Pchar; password:Pchar);cdecl;external mysqllib name 'make_scrambled_password_323';
    procedure scramble_323(fto:Pchar; message:Pchar; password:Pchar);cdecl;external mysqllib name 'scramble_323';
    function check_scramble_323(_para1:Pchar; message:Pchar; salt:Pdword):my_bool;cdecl;external mysqllib name 'check_scramble_323';
    procedure get_salt_from_password_323(res:Pdword; password:Pchar);cdecl;external mysqllib name 'get_salt_from_password_323';
    procedure make_password_from_salt_323(fto:Pchar; salt:Pdword);cdecl;external mysqllib name 'make_password_from_salt_323';
{$IFDEF mysql50}
    function octet2hex(fto:Pchar; str:Pchar; len:dword):pchar;cdecl;external mysqllib name 'octet2hex';
{$ENDIF}
    procedure make_scrambled_password(fto:Pchar; password:Pchar);cdecl;external mysqllib name 'make_scrambled_password';
    procedure scramble(fto:Pchar; message:Pchar; password:Pchar);cdecl;external mysqllib name 'scramble';
    function check_scramble(reply:Pchar; message:Pchar; hash_stage2:Pbyte):my_bool;cdecl;external mysqllib name 'check_scramble';
    procedure get_salt_from_password(res:Pbyte; password:Pchar);cdecl;external mysqllib name 'get_salt_from_password';
    procedure make_password_from_salt(fto:Pchar; hash_stage2:Pbyte);cdecl;external mysqllib name 'make_password_from_salt';
    { end of password.c  }

    function get_tty_password(opt_message:Pchar):Pchar;cdecl;external mysqllib name 'get_tty_password';
    function mysql_errno_to_sqlstate(mysql_errno:dword):Pchar;cdecl;external mysqllib name 'mysql_errno_to_sqlstate';

    { Some other useful functions  }
{$IFDEF mysql50}
    function modify_defaults_file(file_location:Pchar; option:Pchar; option_value:Pchar; section_name:Pchar; remove_option:longint):longint;cdecl;external mysqllib name 'load_defaults';
{$ENDIF}

    function load_defaults(conf_file:Pchar; groups:PPchar; argc:Plongint; argv:PPPchar):longint;cdecl;external mysqllib name 'load_defaults';
    function my_init:my_bool;cdecl;external mysqllib name 'my_init';
    function my_thread_init:my_bool;cdecl;external mysqllib name 'my_thread_init';
    procedure my_thread_end;cdecl;external mysqllib name 'my_thread_end';
{$ELSE}
    var
      my_init : function :my_bool;cdecl;
      my_thread_init : function :my_bool;cdecl;
      my_thread_end : procedure ;cdecl;
{$ENDIF}

{$ifdef _global_h}
{$IFNDEF LinkDynamically}
    function net_field_length(packet:PPuchar):culong;extdecl;external mysqllib name 'net_field_length_ll';
    function net_field_length_ll(packet:PPuchar):my_ulonglong;cdecl;external mysqllib name 'net_field_length_ll';
    function net_store_length(pkg:Pchar; length:ulonglong):Pchar;cdecl;external mysqllib name 'net_store_length';
{$ENDIF}
{$endif}

    const
       NULL_LENGTH : dword = not(0); // For net_store_length

    const
       MYSQL_STMT_HEADER = 4;
       MYSQL_LONG_DATA_HEADER = 6;

{  ------------ Stop of declaration in "mysql_com.h"   -----------------------  }

{ $include "mysql_time.h"}
{ $include "mysql_version.h"}
{ $include "typelib.h"}
{ $include "my_list.h" /* for LISTs used in 'MYSQL' and 'MYSQL_STMT' */}

{$IFNDEF LinkDynamically}
      var
         mysql_port : dword;cvar;external;
         mysql_unix_port : Pchar;cvar;external;
{$ENDIF}

      const
         CLIENT_NET_READ_TIMEOUT = 365*24*3600;     // Timeout on read
         CLIENT_NET_WRITE_TIMEOUT = 365*24*3600;    // Timeout on write
      
{$ifdef NETWARE}
(** unsupported pragma#pragma pack(push, 8)		/* 8 byte alignment */*)
{$endif}

    type
       Pst_mysql_field = ^st_mysql_field;
       st_mysql_field = record
            name : Pchar;             // Name of column
{$IFDEF mysql41}
            org_name : Pchar;         // Original column name, if an alias
{$ENDIF}
            table : Pchar;            // Table of column if column was a field
            org_table : Pchar;        // Org table name, if table was an alias
            db : Pchar;               // Database for table
{$IFDEF mysql41}
            catalog : Pchar;          // Catalog for table
{$ENDIF}
            def : Pchar;              // Default value (set by mysql_list_fields)
            length : dword;           // Width of column (create length)
            max_length : dword;       // Max width for selected set
{$IFDEF mysql41}
            name_length : dword;
            org_name_length : dword;
            table_length : dword;
            org_table_length : dword;
            db_length : dword;
            catalog_length : dword;
            def_length : dword;
{$ENDIF}
            flags : dword;            // Div flags
            decimals : dword;         // Number of decimals in field
{$IFDEF mysql41}
            charsetnr : dword;        // Character set
{$ENDIF}
            ftype : enum_field_types; // Type of field. See mysql_com.h for types
         end;
       MYSQL_FIELD = st_mysql_field;
       PMYSQL_FIELD = ^MYSQL_FIELD;

       PMYSQL_ROW = ^MYSQL_ROW;       // return data as array of strings
       MYSQL_ROW = ppchar;

       PMYSQL_FIELD_OFFSET = ^MYSQL_FIELD_OFFSET;     // offset to current field
       MYSQL_FIELD_OFFSET = dword;

    function IS_PRI_KEY(n : longint) : boolean;
    function IS_NOT_NULL(n : longint) : boolean;
    function IS_BLOB(n : longint) : boolean;
    function IS_NUM(t : enum_field_types) : boolean;
    function INTERNAL_NUM_FIELD(f : Pst_mysql_field) : boolean;
    function IS_NUM_FIELD(f : Pst_mysql_field) : boolean;

    type
{$if defined(NO_CLIENT_LONG_LONG)}
       my_ulonglong = dword;
{$elseif defined(mswindows)}
       my_ulonglong = int64;
{$else}
       my_ulonglong = qword;
{$endif}
       Pmy_ulonglong = ^my_ulonglong;

    const
       MYSQL_COUNT_ERROR = not (my_ulonglong(0));

    type
       Pst_mysql_rows = ^st_mysql_rows;
       st_mysql_rows = record
            next : Pst_mysql_rows;                    // list of rows
            data : MYSQL_ROW;
{$IFDEF mysql41}
            length : dword;
{$ENDIF}
         end;
       MYSQL_ROWS = st_mysql_rows;
       PMYSQL_ROWS = ^MYSQL_ROWS;

       PMYSQL_ROW_OFFSET = ^MYSQL_ROW_OFFSET;         // offset to current row
       MYSQL_ROW_OFFSET = MYSQL_ROWS;

{  ------------ Start of declaration in "my_alloc.h"     --------------------  }
{ $include "my_alloc.h"}

  const
     ALLOC_MAX_BLOCK_TO_DROP = 4096;
     ALLOC_MAX_BLOCK_USAGE_BEFORE_DROP = 10;

 { struct for once_alloc (block)  }
  type
     Pst_used_mem = ^st_used_mem;
     st_used_mem = record
          next : Pst_used_mem;   // Next block in use
          left : dword;          // memory left in block
          size : dword;          // size of block
       end;
     USED_MEM = st_used_mem;
     PUSED_MEM = ^USED_MEM;


     Pst_mem_root = ^st_mem_root;
     st_mem_root = record
          free : PUSED_MEM;      // blocks with free memory in it
          used : PUSED_MEM;      // blocks almost without free memory
          pre_alloc : PUSED_MEM; // preallocated block
          min_malloc : dword;    // if block have less memory it will be put in 'used' list
          block_size : dword;    // initial block size
          block_num : dword;     // allocated blocks counter
  {    first free block in queue test counter (if it exceed
       MAX_BLOCK_USAGE_BEFORE_DROP block will be dropped in 'used' list)     }
          first_block_usage : dword;
          error_handler : procedure ;cdecl;
       end;
     MEM_ROOT = st_mem_root;
     PMEM_ROOT = ^MEM_ROOT;

{  ------------ Stop of declaration in "my_alloc.h"    ----------------------  }

    type
       Pst_mysql_data = ^st_mysql_data;
       st_mysql_data = record
            rows : my_ulonglong;
            fields : dword;
            data : PMYSQL_ROWS;
            alloc : MEM_ROOT;
{ $if !defined(CHECK_EMBEDDED_DIFFERENCES) || defined(EMBEDDED_LIBRARY)}
{$IFDEF mysql41}
            prev_ptr : ^PMYSQL_ROWS;
{$ENDIF}
{ $endif}
         end;
         
       MYSQL_DATA = st_mysql_data;
       PMYSQL_DATA = ^MYSQL_DATA;
       mysql_option = (MYSQL_OPT_CONNECT_TIMEOUT,MYSQL_OPT_COMPRESS,
         MYSQL_OPT_NAMED_PIPE,MYSQL_INIT_COMMAND,
         MYSQL_READ_DEFAULT_FILE,MYSQL_READ_DEFAULT_GROUP,
         MYSQL_SET_CHARSET_DIR,MYSQL_SET_CHARSET_NAME,
         MYSQL_OPT_LOCAL_INFILE,MYSQL_OPT_PROTOCOL,
         MYSQL_SHARED_MEMORY_BASE_NAME,MYSQL_OPT_READ_TIMEOUT,
         MYSQL_OPT_WRITE_TIMEOUT,MYSQL_OPT_USE_RESULT,
         MYSQL_OPT_USE_REMOTE_CONNECTION,MYSQL_OPT_USE_EMBEDDED_CONNECTION,
         MYSQL_OPT_GUESS_CONNECTION,MYSQL_SET_CLIENT_IP,
         MYSQL_SECURE_AUTH
{$IFDEF MYSQL50}
         ,MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT
{$ENDIF}
         );

    const
       MAX_MYSQL_MANAGER_ERR = 256;
       MAX_MYSQL_MANAGER_MSG = 256;
       MANAGER_OK = 200;
       MANAGER_INFO = 250;
       MANAGER_ACCESS = 401;
       MANAGER_CLIENT_ERR = 450;
       MANAGER_INTERNAL_ERR = 500;

    type
       st_dynamic_array = record
            buffer : ^char;
            elements : cuint;
            max_element : cuint;
            alloc_increment : cuint;
            size_of_element : cuint;
         end;
       DYNAMIC_ARRAY = st_dynamic_array;
       Pst_dynamic_array = ^st_dynamic_array;

       Pst_mysql_options = ^st_mysql_options;
       st_mysql_options = record
            connect_timeout : dword;
{$IFNDEF mysql41}
            client_flag : dword;
            port : dword;
{$ELSE}
            read_timeout : dword;
            write_timeout : dword;
{$ENDIF}
{$IFDEF mysql41}
            port : dword;
            protocol : dword;
            client_flag : dword;
{$ENDIF}
            host : Pchar;
{$IFNDEF mysql41}
            init_command: Pchar;
{$ENDIF}
            user : Pchar;
            password : Pchar;
            unix_socket : Pchar;
            db : Pchar;
{$IFDEF mysql41}
            init_commands : Pst_dynamic_array;
{$ENDIF}
            my_cnf_file : Pchar;
            my_cnf_group : Pchar;
            charset_dir : Pchar;
            charset_name : Pchar;
            ssl_key : Pchar;                 // PEM key file
            ssl_cert : Pchar;                // PEM cert file
            ssl_ca : Pchar;                  // PEM CA file
            ssl_capath : Pchar;              // PEM directory of CA-s?
            ssl_cipher : Pchar;              // cipher to use
{$IFDEF mysql41}
            shared_memory_base_name : Pchar;
{$ENDIF}
            max_allowed_packet : dword;
            use_ssl : my_bool;               // if to use SSL or not
            compress : my_bool;
            named_pipe : my_bool;
    {  On connect, find out the replication role of the server, and
       establish connections to all the peers  }
            rpl_probe : my_bool;
    {  Each call to mysql_real_query() will parse it to tell if it is a read
       or a write, and direct it to the slave or the master      }
            rpl_parse : my_bool;
    {  If set, never read from a master, only from slave, when doing
       a read that is replication-aware    }
            no_master_reads : my_bool;
{ $if !defined(CHECK_EMBEDDED_DIFFERENCES) || defined(EMBEDDED_LIBRARY)}
{$IFDEF mysql41}
            separate_thread : my_bool;
{ $endif}
            methods_to_use : mysql_option;
            client_ip : Pchar;
            secure_auth : my_bool;           // Refuse client connecting to server if it uses old (pre-4.1.1) protocol
{$IFDEF mysql50}
            report_data_truncation : my_bool;// 0 - never report, 1 - always report (default)
{$ENDIF}
    { function pointers for local infile support  }
            local_infile_init : function (_para1:Ppointer; _para2:Pchar; _para3:pointer):longint;cdecl;
            local_infile_read : function (_para1:pointer; _para2:Pchar; _para3:dword):longint;
            local_infile_end : procedure (_para1:pointer);
            local_infile_error : function (_para1:pointer; _para2:Pchar; _para3:dword):longint;
            local_infile_userdata : pointer;
{$ENDIF}
         end;

       mysql_status = (MYSQL_STATUS_READY,MYSQL_STATUS_GET_RESULT,
         MYSQL_STATUS_USE_RESULT);

       mysql_protocol_type = (MYSQL_PROTOCOL_DEFAULT,MYSQL_PROTOCOL_TCP,
         MYSQL_PROTOCOL_SOCKET,MYSQL_PROTOCOL_PIPE,
         MYSQL_PROTOCOL_MEMORY);

    { There are three types of queries - the ones that have to go to
      the master, the ones that go to a slave, and the adminstrative
      type which must happen on the pivot connectioin     }
       mysql_rpl_type = (MYSQL_RPL_MASTER,MYSQL_RPL_SLAVE,MYSQL_RPL_ADMIN
         );

       charset_info_st = record
            number : cuint;
            primary_number : cuint;
            binary_number : cuint;
            state : cuint;
            csname : ^char;
            name : ^char;
            comment : ^char;
            tailoring : ^char;
            ftype : ^cuchar;
            to_lower : ^cuchar;
            to_upper : ^cuchar;
            sort_order : ^cuchar;
            contractions : ^cuint16;
            sort_order_big : ^pword;
            tab_to_uni : ^cuint16;
            tab_from_uni : pointer; // was ^MY_UNI_IDX
            state_map : ^cuchar;
            ident_map : ^cuchar;
            strxfrm_multiply : cuint;
            mbminlen : cuint;
            mbmaxlen : cuint;
            min_sort_char : cuint16;
            max_sort_char : cuint16;
            escape_with_backslash_is_dangerous : my_bool;
            cset : pointer; // was ^MY_CHARSET_HANDLER
            coll : pointer; // was ^MY_COLLATION_HANDLER;
         end;
       CHARSET_INFO = charset_info_st;
       Pcharset_info_st = ^charset_info_st;

{$IFDEF mysql50}
       Pcharacter_set = ^character_set;
       character_set = record
            number : dword;
            state : dword;
            csname : Pchar;
            name : Pchar;
            comment : Pchar;
            dir : Pchar;
            mbminlen : dword;
            mbmaxlen : dword;
         end;
       MY_CHARSET_INFO = character_set;
       PMY_CHARSET_INFO = ^MY_CHARSET_INFO;
{$ENDIF}

       Pst_mysql_methods = ^st_mysql_methods;

       Pst_mysql = ^st_mysql;
       st_mysql = record
            net : NET;                   // Communication parameters
            connector_fd : gptr;         // ConnectorFd for SSL
            host : Pchar;
            user : Pchar;
            passwd : Pchar;
            unix_socket : Pchar;
            server_version : Pchar;
            host_info : Pchar;
            info : Pchar;
            db : Pchar;
            charset : Pcharset_info_st;
            fields : PMYSQL_FIELD;
            field_alloc : MEM_ROOT;
            affected_rows : my_ulonglong;
            insert_id : my_ulonglong;    // id if insert on table with NEXTNR
            extra_info : my_ulonglong;   // Used by mysqlshow, not used by mysql 5.0 and up
            thread_id : dword;           // Id for connection in server
            packet_length : dword;
            port : dword;
            client_flag : dword;
            server_capabilities : dword;
            protocol_version : dword;
            field_count : dword;
            server_status : dword;
            server_language : dword;
            warning_count : dword;
            options : st_mysql_options;
            status : mysql_status;
            free_me : my_bool;           // If free in mysql_close
            reconnect : my_bool;         // set to 1 if automatic reconnect
            scramble : array[0..(SCRAMBLE_LENGTH+1)-1] of char;  // session-wide random string
    {  Set if this is the original connection, not a master or a slave we have
       added though mysql_rpl_probe() or mysql_set_master()/ mysql_add_slave()      }
            rpl_pivot : my_bool;
    {   Pointers to the master, and the next slave connections, points to
        itself if lone connection.       }
            master : Pst_mysql;
            next_slave : Pst_mysql;
            last_used_slave : Pst_mysql; // needed for round-robin slave pick
            last_used_con : Pst_mysql;   // needed for send/read/store/use result to work correctly with replication
{$IFDEF mysql41}
            stmts : Pointer;             // was PList, list of all statements
            methods : Pst_mysql_methods;
            thd : pointer;
    {   Points to boolean flag in MYSQL_RES  or MYSQL_STMT. We set this flag
        from mysql_stmt_close if close had to cancel result set of this object.       }
            unbuffered_fetch_owner : Pmy_bool;
{$ENDIF}
         end;
       MYSQL = st_mysql;
       PMYSQL = ^MYSQL;


       Pst_mysql_res = ^st_mysql_res;
       st_mysql_res = record
            row_count : my_ulonglong;
            fields : PMYSQL_FIELD;
            data : PMYSQL_DATA;
            data_cursor : PMYSQL_ROWS;
            lengths : Pdword;            // column lengths of current row
            handle : PMYSQL;             // for unbuffered reads
            field_alloc : MEM_ROOT;
            field_count : dword;
            current_field : dword;
            row : MYSQL_ROW;             // If unbuffered read
            current_row : MYSQL_ROW;     // buffer to current row
            eof : my_bool;               // Used by mysql_fetch_row
{$IFDEF mysql41}
            unbuffered_fetch_cancelled : my_bool;  // mysql_stmt_close() had to cancel this result

            methods : Pst_mysql_methods;
{$ENDIF}
         end;
       MYSQL_RES = st_mysql_res;
       PMYSQL_RES = ^MYSQL_RES;

       Pst_mysql_stmt = ^st_mysql_stmt;
       PMYSQL_STMT = ^MYSQL_STMT;

       st_mysql_methods = record
            read_query_result : function (mysql:PMYSQL):my_bool;cdecl;
            advanced_command : function (mysql:PMYSQL; command:enum_server_command; header:Pchar; header_length:dword; arg:Pchar;
                         arg_length:dword; skip_check:my_bool):my_bool;
            read_rows : function (mysql:PMYSQL; mysql_fields:PMYSQL_FIELD; fields:dword):PMYSQL_DATA;
            use_result : function (mysql:PMYSQL):PMYSQL_RES;
            fetch_lengths : procedure (fto:Pdword; column:MYSQL_ROW; field_count:dword);
            flush_use_result : procedure (mysql:PMYSQL);
{ $if !defined(MYSQL_SERVER) || defined(EMBEDDED_LIBRARY)}
            list_fields : function (mysql:PMYSQL):PMYSQL_FIELD;
            read_prepare_result : function (mysql:PMYSQL; stmt:PMYSQL_STMT):my_bool;
            stmt_execute : function (stmt:PMYSQL_STMT):longint;
            read_binary_rows : function (stmt:PMYSQL_STMT):longint;
            unbuffered_fetch : function (mysql:PMYSQL; row:PPchar):longint;
            free_embedded_thd : procedure (mysql:PMYSQL);
            read_statistics : function (mysql:PMYSQL):Pchar;
            next_result : function (mysql:PMYSQL):my_bool;
            read_change_user_result : function (mysql:PMYSQL; buff:Pchar; passwd:Pchar):longint;
{ $endif}
         end;
       MYSQL_METHODS = st_mysql_methods;
       PMYSQL_METHODS = ^MYSQL_METHODS;


       Pst_mysql_manager = ^st_mysql_manager;
       st_mysql_manager = record
            net : NET;
            host : Pchar;
            user : Pchar;
            passwd : Pchar;
            port : dword;
            free_me : my_bool;
            eof : my_bool;
            cmd_status : longint;
            last_errno : longint;
            net_buf : Pchar;
            net_buf_pos : Pchar;
            net_data_end : Pchar;
            net_buf_size : longint;
            last_error : array[0..(MAX_MYSQL_MANAGER_ERR)-1] of char;
         end;
       MYSQL_MANAGER = st_mysql_manager;
       PMYSQL_MANAGER = ^MYSQL_MANAGER;

       Pst_mysql_parameters = ^st_mysql_parameters;
       st_mysql_parameters = record
            p_max_allowed_packet : Pdword;
            p_net_buffer_length : Pdword;
         end;
       MYSQL_PARAMETERS = st_mysql_parameters;
       PMYSQL_PARAMETERS = ^MYSQL_PARAMETERS;

    { The following definitions are added for the enhanced
      client-server protocol }

    { statement state  }

       enum_mysql_stmt_state = (MYSQL_STMT_INIT_DONE := 1,MYSQL_STMT_PREPARE_DONE,
         MYSQL_STMT_EXECUTE_DONE,MYSQL_STMT_FETCH_DONE
         );

    {
      Note: this info is from the mysql-5.0 version:
    
      This structure is used to define bind information, and
      internally by the client library.
      Public members with their descriptions are listed below
      (conventionally `On input' refers to the binds given to
      mysql_stmt_bind_param, `On output' refers to the binds given
      to mysql_stmt_bind_result):

      buffer_type    - One of the MYSQL_* types, used to describe
                       the host language type of buffer.
                       On output: if column type is different from
                       buffer_type, column value is automatically converted
                       to buffer_type before it is stored in the buffer.
      buffer         - On input: points to the buffer with input data.
                       On output: points to the buffer capable to store
                       output data.
                       The type of memory pointed by buffer must correspond
                       to buffer_type. See the correspondence table in
                       the comment to mysql_stmt_bind_param.

      The two above members are mandatory for any kind of bind.

      buffer_length  - the length of the buffer. You don't have to set
                       it for any fixed length buffer: float, double,
                       int, etc. It must be set however for variable-length
                       types, such as BLOBs or STRINGs.

      length         - On input: in case when lengths of input values
                       are different for each execute, you can set this to
                       point at a variable containining value length. This
                       way the value length can be different in each execute.
                       If length is not NULL, buffer_length is not used.
                       Note, length can even point at buffer_length if
                       you keep bind structures around while fetching:
                       this way you can change buffer_length before
                       each execution, everything will work ok.
                       On output: if length is set, mysql_stmt_fetch will
                       write column length into it.

      is_null        - On input: points to a boolean variable that should
                       be set to TRUE for NULL values.
                       This member is useful only if your data may be
                       NULL in some but not all cases.
                       If your data is never NULL, is_null should be set to 0.
                       If your data is always NULL, set buffer_type
                       to MYSQL_TYPE_NULL, and is_null will not be used.

      is_unsigned    - On input: used to signify that values provided for one
                       of numeric types are unsigned.
                       On output describes signedness of the output buffer.
                       If, taking into account is_unsigned flag, column data
                       is out of range of the output buffer, data for this column
                       is regarded truncated. Note that this has no correspondence
                       to the sign of result set column, if you need to find it out
                       use mysql_stmt_result_metadata.
      error          - where to write a truncation error if it is present.
                       possible error value is:
                       0  no truncation
                       1  value is out of range or buffer is too small

      Please note that MYSQL_BIND also has internals members.
    }
       Pst_mysql_bind = ^st_mysql_bind;
       st_mysql_bind = record
            length : Pdword;                // output length pointer
            is_null : Pmy_bool;             // Pointer to null indicator
            buffer : pointer;               // buffer to get/put data
{$IFDEF mysql50}
            error: pmy_bool;                // set this if you want to track data truncations happened during fetch
{$ENDIF}
            buffer_type : enum_field_types; // buffer type
            buffer_length : dword;          // buffer length, must be set for str/binary
    { Following are for internal use. Set by mysql_stmt_bind_param  }
{$IFNDEF mysql50}
            inter_buffer : Pbyte;           // for the current data position
{$ELSE}
            row_ptr : PByte;                // for the current data position
{$ENDIF}
            offset : dword;                 // offset position for char/binary fetch
{$IFNDEF mysql50}
            internal_length : dword;        //  Used if length is 0
{$ELSE}
            length_value : dword;           //  Used if length is 0
{$ENDIF}
            param_number : dword;           // For null count and error messages
            pack_length : dword;            // Internal length for packed data
{$IFDEF mysql50}
            error_value : pmy_bool;         // used if error is 0
{$ENDIF}
            is_unsigned : my_bool;          // set if integer type is unsigned
            long_data_used : my_bool;       // If used with mysql_send_long_data
{$IFNDEF mysql50}
            internal_is_null : my_bool;     // Used if is_null is 0
{$ELSE}
            is_null_value : my_bool;        // Used if is_null is 0
{$ENDIF}
            store_param_func : procedure (net:PNET; param:Pst_mysql_bind);cdecl;
            fetch_result : procedure (_para1:Pst_mysql_bind; _para2:PMYSQL_FIELD; row:PPbyte);
            skip_result : procedure (_para1:Pst_mysql_bind; _para2:PMYSQL_FIELD; row:PPbyte);
         end;
       MYSQL_BIND = st_mysql_bind;
       PMYSQL_BIND = ^MYSQL_BIND;

    { statement handler  }
       st_mysql_stmt = record
            mem_root : MEM_ROOT;            // root allocations
//            list : LIST;                    // list to keep track of all stmts
            mysql : PMYSQL;                 // connection handle
            params : PMYSQL_BIND;           // input parameters
            bind : PMYSQL_BIND;             // input parameters
            fields : PMYSQL_FIELD;          // result set metadata
            result : MYSQL_DATA;            // cached result set
            data_cursor : PMYSQL_ROWS;      // current row in cached result
            affected_rows : my_ulonglong;   // copy of mysql->affected_rows after statement execution
            insert_id : my_ulonglong;       // copy of mysql->insert_id
    {   mysql_stmt_fetch() calls this function to fetch one row (it's different
        for buffered, unbuffered and cursor fetch).       }
            read_row_func : function (stmt:Pst_mysql_stmt; row:PPbyte):longint;cdecl;
            stmt_id : dword;                // Id for prepared statement
{$IFDEF mysql50}
            flags : dword;                  // i.e. type of cursor to open
            prefetch_rows : dword;          // number of rows per one COM_FETCH
            server_status : dword;          // Copied from mysql->server_status after execute/fetch to know
                                            // server-side cursor status for this statement.
{$ENDIF}
            last_errno : dword;             // error code
            param_count : dword;            // input parameter count
            field_count : dword;            // number of columns in result set
            state : enum_mysql_stmt_state;  // statement state
            last_error : array[0..(MYSQL_ERRMSG_SIZE)-1] of char;  // error message
            sqlstate : array[0..(SQLSTATE_LENGTH+1)-1] of char;
            send_types_to_server : my_bool; // Types of input parameters should be sent to server
            bind_param_done : my_bool;      // input buffers were supplied
{$IFNDEF mysql50}
            bind_result_done : my_bool;     // output buffers were supplied
{$ELSE}
            bind_result_done : byte;        // output buffers were supplied
{$ENDIF}

            unbuffered_fetch_cancelled : my_bool;   // mysql_stmt_close() had to cancel this result
    {   Is set to true if we need to calculate field->max_length for
        metadata fields when doing mysql_stmt_store_result.       }
            update_max_length : my_bool;
         end;
       MYSQL_STMT = st_mysql_stmt;
    {   When doing mysql_stmt_store_result calculate max_length attribute
        of statement metadata. This is to be consistent with the old API,
        where this was done automatically.
        In the new API we do that only by request because it slows down
        mysql_stmt_store_result sufficiently.       }
       enum_stmt_attr_type = (STMT_ATTR_UPDATE_MAX_LENGTH
{$IFDEF mysql50}
                              ,STMT_ATTR_CURSOR_TYPE,  // unsigned long with combination of cursor flags (read only, for update, etc)
                              STMT_ATTR_PREFETCH_ROWS // Amount of rows to retrieve from server per one fetch if using cursors.
                                                      // Accepts unsigned long attribute in the range 1 - ulong_max
{$ENDIF}
                             );


//#define max_allowed_packet (*mysql_get_parameters()->p_max_allowed_packet)
//#define net_buffer_length (*mysql_get_parameters()->p_net_buffer_length)

{$IFNDEF LinkDynamically}
    { Set up and bring down the server; to ensure that applications will
      work when linked against either the standard client library or the
      embedded server library, these functions should be called.     }
    function mysql_server_init(argc:longint; argv:PPchar; groups:PPchar):longint;cdecl;external mysqllib name 'mysql_server_init';
    procedure mysql_server_end;cdecl;external mysqllib name 'mysql_server_end';

    { mysql_server_init/end need to be called when using libmysqld or
      libmysqlclient (exactly, mysql_server_init() is called by mysql_init() so
      you don't need to call it explicitely; but you need to call
      mysql_server_end() to free memory). The names are a bit misleading
      (mysql_SERVER* to be used when using libmysqlCLIENT). So we add more general
      names which suit well whether you're using libmysqld or libmysqlclient. We
      intend to promote these aliases over the mysql_server* ones.     }

    function mysql_library_init(argc:longint; argv:PPchar; groups:PPchar):longint;cdecl;external mysqllib name 'mysql_server_init';
    procedure mysql_library_end;cdecl;external mysqllib name 'mysql_server_end';

    function mysql_get_parameters:PMYSQL_PARAMETERS;extdecl;external mysqllib name 'mysql_get_parameters';

    { Set up and bring down a thread; these function should be called
      for each thread in an application which opens at least one MySQL
      connection.  All uses of the connection(s) should be between these
      function calls.     }
    function mysql_thread_init:my_bool;extdecl;external mysqllib name 'mysql_thread_init';
    procedure mysql_thread_end;extdecl;external mysqllib name 'mysql_thread_end';
    { Functions to get information from the MYSQL and MYSQL_RES structures
      Should definitely be used if one uses shared libraries.     }
    function mysql_num_rows(res:PMYSQL_RES):my_ulonglong;extdecl;external mysqllib name 'mysql_num_rows';
    function mysql_num_fields(res:PMYSQL_RES):dword;extdecl;external mysqllib name 'mysql_num_fields';
    function mysql_eof(res:PMYSQL_RES):my_bool;extdecl;external mysqllib name 'mysql_eof';
    function mysql_fetch_field_direct(res:PMYSQL_RES; fieldnr:dword):PMYSQL_FIELD;extdecl;external mysqllib name 'mysql_fetch_field_direct';
    function mysql_fetch_fields(res:PMYSQL_RES):PMYSQL_FIELD;extdecl;external mysqllib name 'mysql_fetch_fields';
    function mysql_row_tell(res:PMYSQL_RES):MYSQL_ROW_OFFSET;extdecl;external mysqllib name 'mysql_row_tell';
    function mysql_field_tell(res:PMYSQL_RES):MYSQL_FIELD_OFFSET;extdecl;external mysqllib name 'mysql_field_tell';
    function mysql_field_count(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_field_count';
    function mysql_affected_rows(mysql:PMYSQL):my_ulonglong;extdecl;external mysqllib name 'mysql_affected_rows';
    function mysql_insert_id(mysql:PMYSQL):my_ulonglong;extdecl;external mysqllib name 'mysql_insert_id';
    function mysql_errno(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_errno';
    function mysql_error(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_error';
    function mysql_sqlstate(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_sqlstate';
    function mysql_warning_count(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_warning_count';
    function mysql_info(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_info';
    function mysql_thread_id(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_thread_id';
    function mysql_character_set_name(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_character_set_name';
    function mysql_set_character_set(mysql:PMYSQL; csname:Pchar):longint;extdecl;external mysqllib name 'mysql_set_character_set';
    function mysql_init(mysql:PMYSQL):PMYSQL;extdecl;external mysqllib name 'mysql_init';
    function mysql_ssl_set(mysql:PMYSQL; key:Pchar; cert:Pchar; ca:Pchar; capath:Pchar;
               cipher:Pchar):my_bool;extdecl;external mysqllib name 'mysql_ssl_set';
    function mysql_change_user(mysql:PMYSQL; user:Pchar; passwd:Pchar; db:Pchar):my_bool;extdecl;external mysqllib name 'mysql_change_user';
    function mysql_real_connect(mysql:PMYSQL; host:Pchar; user:Pchar; passwd:Pchar; db:Pchar;
               port:dword; unix_socket:Pchar; clientflag:dword):PMYSQL;extdecl;external mysqllib name 'mysql_real_connect';
    function mysql_select_db(mysql:PMYSQL; db:Pchar):longint;extdecl;external mysqllib name 'mysql_select_db';
    function mysql_query(mysql:PMYSQL; q:Pchar):longint;extdecl;external mysqllib name 'mysql_query';
    function mysql_send_query(mysql:PMYSQL; q:Pchar; length:dword):longint;extdecl;external mysqllib name 'mysql_send_query';
    function mysql_real_query(mysql:PMYSQL; q:Pchar; length:dword):longint;extdecl;external mysqllib name 'mysql_real_query';
    function mysql_store_result(mysql:PMYSQL):PMYSQL_RES;extdecl;external mysqllib name 'mysql_store_result';
    function mysql_use_result(mysql:PMYSQL):PMYSQL_RES;extdecl;external mysqllib name 'mysql_use_result';

{$ELSE}

    var
      mysql_server_init: function (argc:longint; argv:PPchar; groups:PPchar):longint;cdecl;
      mysql_server_end: procedure ;cdecl;
      mysql_library_init: function (argc:longint; argv:PPchar; groups:PPchar):longint;cdecl;
      mysql_library_end: procedure ;cdecl;
      mysql_num_rows: function (res:PMYSQL_RES):my_ulonglong;extdecl;
      mysql_num_fields: function (res:PMYSQL_RES):dword;extdecl;
      mysql_eof: function (res:PMYSQL_RES):my_bool;extdecl;
      mysql_fetch_field_direct: function (res:PMYSQL_RES; fieldnr:dword):PMYSQL_FIELD;extdecl;
      mysql_fetch_fields: function (res:PMYSQL_RES):PMYSQL_FIELD;extdecl;
      mysql_row_tell: function (res:PMYSQL_RES):MYSQL_ROW_OFFSET;extdecl;
      mysql_field_tell: function (res:PMYSQL_RES):MYSQL_FIELD_OFFSET;extdecl;
      mysql_field_count: function (mysql:PMYSQL):dword;extdecl;
      mysql_affected_rows: function (mysql:PMYSQL):my_ulonglong;extdecl;
      mysql_insert_id: function (mysql:PMYSQL):my_ulonglong;extdecl;
      mysql_errno: function (mysql:PMYSQL):dword;extdecl;
      mysql_error: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_sqlstate: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_warning_count: function (mysql:PMYSQL):dword;extdecl;
      mysql_info: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_thread_id: function (mysql:PMYSQL):dword;extdecl;
      mysql_character_set_name: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_set_character_set: function (mysql:PMYSQL; csname:Pchar):longint;extdecl;
      mysql_init: function (mysql:PMYSQL):PMYSQL;extdecl;
      mysql_ssl_set: function (mysql:PMYSQL; key:Pchar; cert:Pchar; ca:Pchar; capath:Pchar;
                 cipher:Pchar):my_bool;extdecl;
      mysql_change_user: function (mysql:PMYSQL; user:Pchar; passwd:Pchar; db:Pchar):my_bool;extdecl;
      mysql_real_connect: function (mysql:PMYSQL; host:Pchar; user:Pchar; passwd:Pchar; db:Pchar;
                 port:dword; unix_socket:Pchar; clientflag:dword):PMYSQL;extdecl;
      mysql_select_db: function (mysql:PMYSQL; db:Pchar):longint;extdecl;
      mysql_query: function (mysql:PMYSQL; q:Pchar):longint;extdecl;
      mysql_send_query: function (mysql:PMYSQL; q:Pchar; length:dword):longint;extdecl;
      mysql_real_query: function (mysql:PMYSQL; q:Pchar; length:dword):longint;extdecl;
      mysql_store_result: function (mysql:PMYSQL):PMYSQL_RES;extdecl;
      mysql_use_result: function (mysql:PMYSQL):PMYSQL_RES;extdecl;
{$ENDIF}

{$IFNDEF LinkDynamically}
    { perform query on master  }
    function mysql_master_query(mysql:PMYSQL; q:Pchar; length:dword):my_bool;extdecl;external mysqllib name 'mysql_master_query';
    function mysql_master_send_query(mysql:PMYSQL; q:Pchar; length:dword):my_bool;extdecl;external mysqllib name 'mysql_master_send_query';

    { perform query on slave  }
    function mysql_slave_query(mysql:PMYSQL; q:Pchar; length:dword):my_bool;extdecl;external mysqllib name 'mysql_slave_query';
    function mysql_slave_send_query(mysql:PMYSQL; q:Pchar; length:dword):my_bool;extdecl;external mysqllib name 'mysql_slave_send_query';
{$IFDEF mysql50}
    procedure mysql_get_character_set_info(mysql : PMYSQL; charset : PMY_CHARSET_INFO);extdecl;external mysqllib name 'mysql_get_character_set_info';
{$ENDIF}
{$ENDIF}

    { local infile support  }

    const
       LOCAL_INFILE_ERROR_LEN = 512;

{$IFNDEF LinkDynamically}
{    procedure mysql_set_local_infile_handler(mysql:PMYSQL; local_infile_init:function (_para1:Ppointer; _para2:Pchar; _para3:pointer):longint; local_infile_read:function (_para1:pointer; _para2:Pchar; _para3:dword):longint; local_infile_end:procedure (_pa
                _para6:pointer);cdecl;external mysqllib name 'mysql_set_local_infile_handler';}
    procedure mysql_set_local_infile_default(mysql:PMYSQL);cdecl;external mysqllib name 'mysql_set_local_infile_default';

    { enable/disable parsing of all queries to decide if they go on master or
      slave     }
    procedure mysql_enable_rpl_parse(mysql:PMYSQL);extdecl;external mysqllib name 'mysql_enable_rpl_parse';
    procedure mysql_disable_rpl_parse(mysql:PMYSQL);extdecl;external mysqllib name 'mysql_disable_rpl_parse';

    { get the value of the parse flag  }
    function mysql_rpl_parse_enabled(mysql:PMYSQL):longint;extdecl;external mysqllib name 'mysql_rpl_parse_enabled';

    {  enable/disable reads from master  }
    procedure mysql_enable_reads_from_master(mysql:PMYSQL);extdecl;external mysqllib name 'mysql_enable_reads_from_master';
    procedure mysql_disable_reads_from_master(mysql:PMYSQL);extdecl;external mysqllib name 'mysql_disable_reads_from_master';

    { get the value of the master read flag  }
    function mysql_reads_from_master_enabled(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_reads_from_master_enabled';

    function mysql_rpl_query_type(q : pchar;len : longint):mysql_rpl_type;extdecl;external mysqllib name 'mysql_rpl_query_type';

    { discover the master and its slaves  }
    function mysql_rpl_probe(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_rpl_probe';

    { set the master, close/free the old one, if it is not a pivot  }
    function mysql_set_master(mysql:PMYSQL; host:Pchar; port:dword; user:Pchar; passwd:Pchar):longint;extdecl;external mysqllib name 'mysql_set_master';
    function mysql_add_slave(mysql:PMYSQL; host:Pchar; port:dword; user:Pchar; passwd:Pchar):longint;extdecl;external mysqllib name 'mysql_add_slave';
    function mysql_shutdown(mysql:PMYSQL; shutdown_level:mysql_enum_shutdown_level):longint;extdecl;external mysqllib name 'mysql_shutdown';
    function mysql_dump_debug_info(mysql:PMYSQL):longint;extdecl;external mysqllib name 'mysql_dump_debug_info';
    function mysql_refresh(mysql:PMYSQL; refresh_options:dword):longint;extdecl;external mysqllib name 'mysql_refresh';
    function mysql_kill(mysql:PMYSQL; pid:dword):longint;extdecl;external mysqllib name 'mysql_kill';
    function mysql_set_server_option(mysql:PMYSQL; option:enum_mysql_set_option):longint;extdecl;external mysqllib name 'mysql_set_server_option';
    function mysql_ping(mysql:PMYSQL):longint;extdecl;external mysqllib name 'mysql_ping';
    function mysql_stat(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_stat';
    function mysql_get_server_info(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_get_server_info';
    function mysql_get_client_info:Pchar;extdecl;external mysqllib name 'mysql_get_client_info';
    function mysql_get_client_version:dword;extdecl;external mysqllib name 'mysql_get_client_version';
    function mysql_get_host_info(mysql:PMYSQL):Pchar;extdecl;external mysqllib name 'mysql_get_host_info';
    function mysql_get_server_version(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_get_server_version';
    function mysql_get_proto_info(mysql:PMYSQL):dword;extdecl;external mysqllib name 'mysql_get_proto_info';
    function mysql_list_dbs(mysql:PMYSQL; wild:Pchar):PMYSQL_RES;extdecl;external mysqllib name 'mysql_list_dbs';

    function mysql_list_tables(mysql:PMYSQL; wild:Pchar):PMYSQL_RES;extdecl;external mysqllib name 'mysql_list_tables';
    function mysql_list_processes(mysql:PMYSQL):PMYSQL_RES;extdecl;external mysqllib name 'mysql_list_processes';
    function mysql_options(mysql:PMYSQL; option:mysql_option; arg:Pchar):longint;extdecl;external mysqllib name 'mysql_options';
    procedure mysql_free_result(result:PMYSQL_RES);extdecl;external mysqllib name 'mysql_free_result';
    procedure mysql_data_seek(result:PMYSQL_RES; offset:my_ulonglong);extdecl;external mysqllib name 'mysql_data_seek';
    function mysql_row_seek(result:PMYSQL_RES; offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET;extdecl;external mysqllib name 'mysql_row_seek';
    function mysql_field_seek(result:PMYSQL_RES; offset:MYSQL_FIELD_OFFSET):MYSQL_FIELD_OFFSET;extdecl;external mysqllib name 'mysql_field_seek';
    function mysql_fetch_row(result:PMYSQL_RES):MYSQL_ROW;extdecl;external mysqllib name 'mysql_fetch_row';
    function mysql_fetch_lengths(result:PMYSQL_RES):Pdword;extdecl;external mysqllib name 'mysql_fetch_lengths';
    function mysql_fetch_field(result:PMYSQL_RES):PMYSQL_FIELD;extdecl;external mysqllib name 'mysql_fetch_field';
    function mysql_list_fields(mysql:PMYSQL; table:Pchar; wild:Pchar):PMYSQL_RES;extdecl;external mysqllib name 'mysql_list_fields';
    function mysql_escape_string(fto:Pchar; from:Pchar; from_length:dword):dword;extdecl;external mysqllib name 'mysql_escape_string';
    function mysql_hex_string(fto:Pchar; from:Pchar; from_length:dword):dword;extdecl;external mysqllib name 'mysql_hex_string';
    function mysql_real_escape_string(mysql:PMYSQL; fto:Pchar; from:Pchar; length:dword):dword;extdecl;external mysqllib name 'mysql_real_escape_string';
    procedure mysql_debug(debug:Pchar);extdecl;external mysqllib name 'mysql_debug';
{    function mysql_odbc_escape_string(mysql:PMYSQL; fto:Pchar; to_length:dword; from:Pchar; from_length:dword;
               param:pointer; extend_buffer:function (_para1:pointer; to:Pchar; length:Pdword):Pchar):Pchar;extdecl;external mysqllib name 'mysql_odbc_escape_string';}
    procedure myodbc_remove_escape(mysql:PMYSQL; name:Pchar);extdecl;external mysqllib name 'myodbc_remove_escape';
    function mysql_thread_safe:dword;extdecl;external mysqllib name 'mysql_thread_safe';
    function mysql_embedded:my_bool;extdecl;external mysqllib name 'mysql_embedded';
    function mysql_manager_init(con:PMYSQL_MANAGER):PMYSQL_MANAGER;extdecl;external mysqllib name 'mysql_manager_init';
    function mysql_manager_connect(con:PMYSQL_MANAGER; host:Pchar; user:Pchar; passwd:Pchar; port:dword):PMYSQL_MANAGER;extdecl;external mysqllib name 'mysql_manager_connect';
    procedure mysql_manager_close(con:PMYSQL_MANAGER);extdecl;external mysqllib name 'mysql_manager_close';
    function mysql_manager_command(con:PMYSQL_MANAGER; cmd:Pchar; cmd_len:longint):longint;extdecl;external mysqllib name 'mysql_manager_command';
    function mysql_manager_fetch_line(con:PMYSQL_MANAGER; res_buf:Pchar; res_buf_size:longint):longint;extdecl;external mysqllib name 'mysql_manager_fetch_line';
    function mysql_read_query_result(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_read_query_result';

    function mysql_stmt_init(mysql:PMYSQL):PMYSQL_STMT;extdecl;external mysqllib name 'mysql_stmt_init';
    function mysql_stmt_prepare(stmt:PMYSQL_STMT; query:Pchar; length:dword):longint;extdecl;external mysqllib name 'mysql_stmt_prepare';
    function mysql_stmt_execute(stmt:PMYSQL_STMT):longint;extdecl;external mysqllib name 'mysql_stmt_execute';
    function mysql_stmt_fetch(stmt:PMYSQL_STMT):longint;extdecl;external mysqllib name 'mysql_stmt_fetch';
    function mysql_stmt_fetch_column(stmt:PMYSQL_STMT; bind:PMYSQL_BIND; column:dword; offset:dword):longint;extdecl;external mysqllib name 'mysql_stmt_fetch_column';
    function mysql_stmt_store_result(stmt:PMYSQL_STMT):longint;extdecl;external mysqllib name 'mysql_stmt_store_result';
    function mysql_stmt_param_count(stmt:PMYSQL_STMT):dword;extdecl;external mysqllib name 'mysql_stmt_param_count';
    function mysql_stmt_attr_set(stmt:PMYSQL_STMT; attr_type:enum_stmt_attr_type; attr:pointer):my_bool;extdecl;external mysqllib name 'mysql_stmt_attr_set';
    function mysql_stmt_attr_get(stmt:PMYSQL_STMT; attr_type:enum_stmt_attr_type; attr:pointer):my_bool;extdecl;external mysqllib name 'mysql_stmt_attr_get';
    function mysql_stmt_bind_param(stmt:PMYSQL_STMT; bnd:PMYSQL_BIND):my_bool;extdecl;external mysqllib name 'mysql_stmt_bind_param';
    function mysql_stmt_bind_result(stmt:PMYSQL_STMT; bnd:PMYSQL_BIND):my_bool;extdecl;external mysqllib name 'mysql_stmt_bind_result';
    function mysql_stmt_close(stmt:PMYSQL_STMT):my_bool;extdecl;external mysqllib name 'mysql_stmt_close';
    function mysql_stmt_reset(stmt:PMYSQL_STMT):my_bool;extdecl;external mysqllib name 'mysql_stmt_reset';
    function mysql_stmt_free_result(stmt:PMYSQL_STMT):my_bool;extdecl;external mysqllib name 'mysql_stmt_free_result';
    function mysql_stmt_send_long_data(stmt:PMYSQL_STMT; param_number:dword; data:Pchar; length:dword):my_bool;extdecl;external mysqllib name 'mysql_stmt_send_long_data';
    function mysql_stmt_result_metadata(stmt:PMYSQL_STMT):PMYSQL_RES;extdecl;external mysqllib name 'mysql_stmt_result_metadata';
    function mysql_stmt_param_metadata(stmt:PMYSQL_STMT):PMYSQL_RES;extdecl;external mysqllib name 'mysql_stmt_param_metadata';
    function mysql_stmt_errno(stmt:PMYSQL_STMT):dword;extdecl;external mysqllib name 'mysql_stmt_errno';
    function mysql_stmt_error(stmt:PMYSQL_STMT):Pchar;extdecl;external mysqllib name 'mysql_stmt_error';
    function mysql_stmt_sqlstate(stmt:PMYSQL_STMT):Pchar;extdecl;external mysqllib name 'mysql_stmt_sqlstate';
    function mysql_stmt_row_seek(stmt:PMYSQL_STMT; offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET;extdecl;external mysqllib name 'mysql_stmt_row_seek';
    function mysql_stmt_row_tell(stmt:PMYSQL_STMT):MYSQL_ROW_OFFSET;extdecl;external mysqllib name 'mysql_stmt_row_tell';
    procedure mysql_stmt_data_seek(stmt:PMYSQL_STMT; offset:my_ulonglong);extdecl;external mysqllib name 'mysql_stmt_data_seek';
    function mysql_stmt_num_rows(stmt:PMYSQL_STMT):my_ulonglong;extdecl;external mysqllib name 'mysql_stmt_num_rows';
    function mysql_stmt_affected_rows(stmt:PMYSQL_STMT):my_ulonglong;extdecl;external mysqllib name 'mysql_stmt_affected_rows';
    function mysql_stmt_insert_id(stmt:PMYSQL_STMT):my_ulonglong;extdecl;external mysqllib name 'mysql_stmt_insert_id';
    function mysql_stmt_field_count(stmt:PMYSQL_STMT):dword;extdecl;external mysqllib name 'mysql_stmt_field_count';

    function mysql_commit(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_commit';
    function mysql_rollback(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_rollback';
    function mysql_autocommit(mysql:PMYSQL; auto_mode:my_bool):my_bool;extdecl;external mysqllib name 'mysql_autocommit';
    function mysql_more_results(mysql:PMYSQL):my_bool;extdecl;external mysqllib name 'mysql_more_results';
    function mysql_next_result(mysql:PMYSQL):longint;extdecl;external mysqllib name 'mysql_next_result';
    procedure mysql_close(sock:PMYSQL);extdecl;external mysqllib name 'mysql_close';

{$ELSE}
    var
      mysql_shutdown: function (mysql:PMYSQL; shutdown_level:mysql_enum_shutdown_level):longint;extdecl;
      mysql_dump_debug_info: function (mysql:PMYSQL):longint;extdecl;
      mysql_refresh: function (mysql:PMYSQL; refresh_options:dword):longint;extdecl;
      mysql_kill: function (mysql:PMYSQL; pid:dword):longint;extdecl;
      mysql_set_server_option: function (mysql:PMYSQL; option:enum_mysql_set_option):longint;extdecl;
      mysql_ping: function (mysql:PMYSQL):longint;extdecl;
      mysql_stat: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_get_server_info: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_get_client_info: function :Pchar;extdecl;
      mysql_get_client_version: function :dword;extdecl;
      mysql_get_host_info: function (mysql:PMYSQL):Pchar;extdecl;
      mysql_get_server_version: function (mysql:PMYSQL):dword;extdecl;
      mysql_get_proto_info: function (mysql:PMYSQL):dword;extdecl;
      mysql_list_dbs: function (mysql:PMYSQL; wild:Pchar):PMYSQL_RES;extdecl;

      mysql_list_tables: function (mysql:PMYSQL; wild:Pchar):PMYSQL_RES;extdecl;
      mysql_list_processes: function (mysql:PMYSQL):PMYSQL_RES;extdecl;
      mysql_options: function (mysql:PMYSQL; option:mysql_option; arg:Pchar):longint;extdecl;
      mysql_free_result: procedure (result:PMYSQL_RES);extdecl;
      mysql_data_seek: procedure (result:PMYSQL_RES; offset:my_ulonglong);extdecl;
      mysql_row_seek: function (result:PMYSQL_RES; offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET;extdecl;
      mysql_field_seek: function (result:PMYSQL_RES; offset:MYSQL_FIELD_OFFSET):MYSQL_FIELD_OFFSET;extdecl;
      mysql_fetch_row: function (result:PMYSQL_RES):MYSQL_ROW;extdecl;
      mysql_fetch_lengths: function (result:PMYSQL_RES):Pdword;extdecl;
      mysql_fetch_field: function (result:PMYSQL_RES):PMYSQL_FIELD;extdecl;
      mysql_list_fields: function (mysql:PMYSQL; table:Pchar; wild:Pchar):PMYSQL_RES;extdecl;
      mysql_escape_string: function (fto:Pchar; from:Pchar; from_length:dword):dword;extdecl;
      mysql_hex_string: function (fto:Pchar; from:Pchar; from_length:dword):dword;extdecl;
      mysql_real_escape_string: function (mysql:PMYSQL; fto:Pchar; from:Pchar; length:dword):dword;extdecl;
      mysql_debug: procedure (debug:Pchar);extdecl;

      mysql_rollback: function (mysql:PMYSQL):my_bool;extdecl;
      mysql_autocommit: function (mysql:PMYSQL; auto_mode:my_bool):my_bool;extdecl;
      mysql_commit: function (mysql:PMYSQL):my_bool;extdecl;
      mysql_more_results: function (mysql:PMYSQL):my_bool;extdecl;
      mysql_next_result: function (mysql:PMYSQL):longint;extdecl;
      mysql_close: procedure (sock:PMYSQL);extdecl;

      mysql_stmt_init: function (mysql:PMYSQL):PMYSQL_STMT;extdecl;
      mysql_stmt_prepare: function (stmt:PMYSQL_STMT; query:Pchar; length:dword):longint;extdecl;
      mysql_stmt_execute: function (stmt:PMYSQL_STMT):longint;extdecl;
      mysql_stmt_fetch: function (stmt:PMYSQL_STMT):longint;extdecl;
      mysql_stmt_fetch_column: function (stmt:PMYSQL_STMT; bind:PMYSQL_BIND; column:dword; offset:dword):longint;extdecl;
      mysql_stmt_store_result: function (stmt:PMYSQL_STMT):longint;extdecl;
      mysql_stmt_param_count: function (stmt:PMYSQL_STMT):dword;extdecl;
      mysql_stmt_attr_set: function (stmt:PMYSQL_STMT; attr_type:enum_stmt_attr_type; attr:pointer):my_bool;extdecl;
      mysql_stmt_attr_get: function (stmt:PMYSQL_STMT; attr_type:enum_stmt_attr_type; attr:pointer):my_bool;extdecl;
      mysql_stmt_bind_param: function (stmt:PMYSQL_STMT; bnd:PMYSQL_BIND):my_bool;extdecl;
      mysql_stmt_bind_result: function (stmt:PMYSQL_STMT; bnd:PMYSQL_BIND):my_bool;extdecl;
      mysql_stmt_close: function (stmt:PMYSQL_STMT):my_bool;extdecl;
      mysql_stmt_reset: function (stmt:PMYSQL_STMT):my_bool;extdecl;
      mysql_stmt_free_result: function (stmt:PMYSQL_STMT):my_bool;extdecl;
      mysql_stmt_send_long_data: function (stmt:PMYSQL_STMT; param_number:dword; data:Pchar; length:dword):my_bool;extdecl;
      mysql_stmt_result_metadata: function (stmt:PMYSQL_STMT):PMYSQL_RES;extdecl;
      mysql_stmt_param_metadata: function (stmt:PMYSQL_STMT):PMYSQL_RES;extdecl;
      mysql_stmt_errno: function (stmt:PMYSQL_STMT):dword;extdecl;
      mysql_stmt_error: function (stmt:PMYSQL_STMT):Pchar;extdecl;
      mysql_stmt_sqlstate: function (stmt:PMYSQL_STMT):Pchar;extdecl;
      mysql_stmt_row_seek: function (stmt:PMYSQL_STMT; offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET;extdecl;
      mysql_stmt_row_tell: function (stmt:PMYSQL_STMT):MYSQL_ROW_OFFSET;extdecl;
      mysql_stmt_data_seek: procedure (stmt:PMYSQL_STMT; offset:my_ulonglong);extdecl;
      mysql_stmt_num_rows: function (stmt:PMYSQL_STMT):my_ulonglong;extdecl;
      mysql_stmt_affected_rows: function (stmt:PMYSQL_STMT):my_ulonglong;extdecl;
      mysql_stmt_insert_id: function (stmt:PMYSQL_STMT):my_ulonglong;extdecl;
      mysql_stmt_field_count: function (stmt:PMYSQL_STMT):dword;extdecl;

{$ENDIF}


    { status return codes  }

    const
       MYSQL_NO_DATA = 100;
       MYSQL_DATA_TRUNCATED  = 101;

    function mysql_reload(mysql : PMySQL) : longint;

{$IFNDEF LinkDynamically}
{$ifdef USE_OLD_FUNCTIONS}
    function mysql_connect(mysql:PMYSQL; host:Pchar; user:Pchar; passwd:Pchar):PMYSQL;extdecl;external External_library name 'mysql_connect';
    function mysql_create_db(mysql:PMYSQL; DB:Pchar):longint;extdecl;external External_library name 'mysql_create_db';
    function mysql_drop_db(mysql:PMYSQL; DB:Pchar):longint;extdecl;external External_library name 'mysql_drop_db';
    function mysql_reload(mysql : PMySQL) : longint;
{$endif}
{$endif}

{$define HAVE_MYSQL_REAL_CONNECT}    
    { The following functions are mainly exported because of mysqlbinlog;
      They are not for general usage     }

    function simple_command(mysql,command,arg,length,skip_check : longint) : longint;
{$IFNDEF LinkDynamically}
    function net_safe_read(mysql:PMYSQL):dword;cdecl;external mysqllib name 'net_safe_read';
{$ENDIF}

{$ifdef NETWARE}
(** unsupported pragma#pragma pack(pop)		/* restore alignment */*)
{$endif}

{$IFDEF LinkDynamically}
Function InitialiseMysql(Const LibraryName : String) : Integer;
Function InitialiseMysql : Integer;
Procedure ReleaseMysql;

var MysqlLibraryHandle : TLibHandle;
{$ENDIF}

implementation

{$IFDEF LinkDynamically}

ResourceString
  SErrAlreadyLoaded = 'MySQL interface already initialized from library %s.';
  SLoadFailed       = 'Can not load MySQL library "%s". Please check your installation.';
  
var 
  RefCount : integer;
  LoadedLibrary : String;

Function InitialiseMysql : Integer;

begin
  // Use Default library
  Result:=InitialiseMySQL(Mysqllib);
end;


Function InitialiseMysql(Const LibraryName : String) : Integer;


begin
  if (RefCount=0) then
    begin
    MysqlLibraryHandle := loadlibrary(LibraryName);
    if (MysqlLibraryHandle=nilhandle) then
      begin
      Raise EInOutError.CreateFmt(SLoadFailed,[LibraryName]);
      end;
    Inc(RefCount);  
    LoadedLibrary:=LibraryName;
// Only the procedure that are given in the c-library documentation are loaded, to
// avoid problems with 'incomplete' libraries
    pointer(my_init) := GetProcedureAddress(MysqlLibraryHandle,'my_init');
    pointer(my_thread_init) := GetProcedureAddress(MysqlLibraryHandle,'my_thread_init');
    pointer(my_thread_end) := GetProcedureAddress(MysqlLibraryHandle,'my_thread_end');

    pointer(mysql_affected_rows) := GetProcedureAddress(MysqlLibraryHandle,'mysql_affected_rows');
    pointer(mysql_autocommit) := GetProcedureAddress(MysqlLibraryHandle,'mysql_autocommit');
    pointer(mysql_change_user) := GetProcedureAddress(MysqlLibraryHandle,'mysql_change_user');
//    pointer(mysql_charset_name) := GetProcedureAddress(MysqlLibraryHandle,'mysql_charset_name');
    pointer(mysql_close) := GetProcedureAddress(MysqlLibraryHandle,'mysql_close');
    pointer(mysql_commit) := GetProcedureAddress(MysqlLibraryHandle,'mysql_commit');
//    pointer(mysql_connect) := GetProcedureAddress(MysqlLibraryHandle,'mysql_connect');
//    pointer(mysql_create_db) := GetProcedureAddress(MysqlLibraryHandle,'mysql_create_db');
    pointer(mysql_data_seek) := GetProcedureAddress(MysqlLibraryHandle,'mysql_data_seek');
//    pointer(mysql_drop_db) := GetProcedureAddress(MysqlLibraryHandle,'mysql_drop_db');
    pointer(mysql_debug) := GetProcedureAddress(MysqlLibraryHandle,'mysql_debug');
    pointer(mysql_dump_debug_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_dump_debug_info');
    pointer(mysql_eof) := GetProcedureAddress(MysqlLibraryHandle,'mysql_eof');
    pointer(mysql_errno) := GetProcedureAddress(MysqlLibraryHandle,'mysql_errno');
    pointer(mysql_error) := GetProcedureAddress(MysqlLibraryHandle,'mysql_error');
    pointer(mysql_escape_string) := GetProcedureAddress(MysqlLibraryHandle,'mysql_escape_string');
    pointer(mysql_fetch_field) := GetProcedureAddress(MysqlLibraryHandle,'mysql_fetch_field');
    pointer(mysql_fetch_field_direct) := GetProcedureAddress(MysqlLibraryHandle,'mysql_fetch_field_direct');
    pointer(mysql_fetch_fields) := GetProcedureAddress(MysqlLibraryHandle,'mysql_fetch_fields');
    pointer(mysql_fetch_lengths) := GetProcedureAddress(MysqlLibraryHandle,'mysql_fetch_lengths');
    pointer(mysql_fetch_row) := GetProcedureAddress(MysqlLibraryHandle,'mysql_fetch_row');
    pointer(mysql_field_seek) := GetProcedureAddress(MysqlLibraryHandle,'mysql_field_seek');
    pointer(mysql_field_count) := GetProcedureAddress(MysqlLibraryHandle,'mysql_field_count');
    pointer(mysql_field_tell) := GetProcedureAddress(MysqlLibraryHandle,'mysql_field_tell');
    pointer(mysql_free_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_free_result');
    pointer(mysql_get_client_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_client_info');
    pointer(mysql_get_client_version) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_client_version');
    pointer(mysql_get_host_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_host_info');
    pointer(mysql_get_server_version) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_server_version');
    pointer(mysql_get_proto_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_proto_info');
    pointer(mysql_get_server_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_get_server_info');
    pointer(mysql_info) := GetProcedureAddress(MysqlLibraryHandle,'mysql_info');
    pointer(mysql_init) := GetProcedureAddress(MysqlLibraryHandle,'mysql_init');
    pointer(mysql_insert_id) := GetProcedureAddress(MysqlLibraryHandle,'mysql_insert_id');
    pointer(mysql_kill) := GetProcedureAddress(MysqlLibraryHandle,'mysql_kill');
    pointer(mysql_library_end) := GetProcedureAddress(MysqlLibraryHandle,'mysql_server_end');
    pointer(mysql_library_init) := GetProcedureAddress(MysqlLibraryHandle,'mysql_server_init');
    pointer(mysql_list_dbs) := GetProcedureAddress(MysqlLibraryHandle,'mysql_list_dbs');
    pointer(mysql_list_fields) := GetProcedureAddress(MysqlLibraryHandle,'mysql_list_fields');
    pointer(mysql_list_processes) := GetProcedureAddress(MysqlLibraryHandle,'mysql_list_processes');
    pointer(mysql_list_tables) := GetProcedureAddress(MysqlLibraryHandle,'mysql_list_tables');
    pointer(mysql_more_results) := GetProcedureAddress(MysqlLibraryHandle,'mysql_more_results');
    pointer(mysql_next_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_next_result');
    pointer(mysql_num_fields) := GetProcedureAddress(MysqlLibraryHandle,'mysql_num_fields');
    pointer(mysql_num_rows) := GetProcedureAddress(MysqlLibraryHandle,'mysql_num_rows');
    pointer(mysql_options) := GetProcedureAddress(MysqlLibraryHandle,'mysql_options');
    pointer(mysql_ping) := GetProcedureAddress(MysqlLibraryHandle,'mysql_ping');
    pointer(mysql_query) := GetProcedureAddress(MysqlLibraryHandle,'mysql_query');
    pointer(mysql_real_connect) := GetProcedureAddress(MysqlLibraryHandle,'mysql_real_connect');
    pointer(mysql_real_escape_string) := GetProcedureAddress(MysqlLibraryHandle,'mysql_real_escape_String');
    pointer(mysql_real_query) := GetProcedureAddress(MysqlLibraryHandle,'mysql_real_query');
    pointer(mysql_refresh) := GetProcedureAddress(MysqlLibraryHandle,'mysql_refresh');
//    pointer(mysql_reload) := GetProcedureAddress(MysqlLibraryHandle,'mysql_reload');
    pointer(mysql_rollback) := GetProcedureAddress(MysqlLibraryHandle,'mysql_rollback');
    pointer(mysql_row_seek) := GetProcedureAddress(MysqlLibraryHandle,'mysql_row_seek');
    pointer(mysql_row_tell) := GetProcedureAddress(MysqlLibraryHandle,'mysql_row_tell');
    pointer(mysql_select_db) := GetProcedureAddress(MysqlLibraryHandle,'mysql_select_db');
    pointer(mysql_server_end) := GetProcedureAddress(MysqlLibraryHandle,'mysql_server_end');
    pointer(mysql_server_init) := GetProcedureAddress(MysqlLibraryHandle,'mysql_server_init');
    pointer(mysql_set_server_option) := GetProcedureAddress(MysqlLibraryHandle,'mysql_set_server_option');
    pointer(mysql_sqlstate) := GetProcedureAddress(MysqlLibraryHandle,'mysql_sqlstate');
    pointer(mysql_shutdown) := GetProcedureAddress(MysqlLibraryHandle,'mysql_shutdown');
    pointer(mysql_stat) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stat');
    pointer(mysql_store_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_store_result');
    pointer(mysql_thread_id) := GetProcedureAddress(MysqlLibraryHandle,'mysql_thread_id');
//    pointer(mysql_thread_save) := GetProcedureAddress(MysqlLibraryHandle,'mysql_thread_save');
    pointer(mysql_use_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_use_result');
    pointer(mysql_warning_count) := GetProcedureAddress(MysqlLibraryHandle,'mysql_warning_count');
    pointer(mysql_stmt_init) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_init');
    pointer(mysql_stmt_prepare) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_prepare');
    pointer(mysql_stmt_execute) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_execute');
    pointer(mysql_stmt_fetch) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_fetch');
    pointer(mysql_stmt_fetch_column) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_fetch_column');
    pointer(mysql_stmt_store_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_store_result');
    pointer(mysql_stmt_param_count) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_param_count');
    pointer(mysql_stmt_attr_set) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_attr_set');
    pointer(mysql_stmt_attr_get) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_attr_get');
    pointer(mysql_stmt_bind_param) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_bind_param');
    pointer(mysql_stmt_bind_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_bind_result');
    pointer(mysql_stmt_close) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_close');
    pointer(mysql_stmt_reset) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_reset');
    pointer(mysql_stmt_free_result) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_free_result');
    pointer(mysql_stmt_send_long_data) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_send_long_data');
    pointer(mysql_stmt_result_metadata) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_result_metadata');
    pointer(mysql_stmt_param_metadata) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_param_metadata');
    pointer(mysql_stmt_errno) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_errno');
    pointer(mysql_stmt_error) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_error');
    pointer(mysql_stmt_sqlstate) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_sqlstate');
    pointer(mysql_stmt_row_seek) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_row_seek');
    pointer(mysql_stmt_row_tell) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_row_tell');
    pointer(mysql_stmt_data_seek) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_data_seek');
    pointer(mysql_stmt_num_rows) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_num_rows');
    pointer(mysql_stmt_affected_rows) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_affected_rows');
    pointer(mysql_stmt_insert_id) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_insert_id');
    pointer(mysql_stmt_field_count) := GetProcedureAddress(MysqlLibraryHandle,'mysql_stmt_field_count');
    end
  else
    If (LibraryName<>LoadedLibrary) then
      Raise EInOUtError.CreateFmt(SErrAlreadyLoaded,[LoadedLibrary]);
  Result:=RefCount;  
end;

Procedure ReleaseMysql;

begin
  if RefCount> 1 then
    Dec(RefCount)
  else if UnloadLibrary(MysqlLibraryHandle) then 
    begin
    Dec(RefCount);
    LoadedLibrary:='';
    MySqlLibraryHandle:= NilHandle;
    end;
end;

{$ENDIF}
    function net_new_transaction(net : st_net) : st_net;
    begin
      net.pkt_nr := 0;
      result := net;
    end;

    function IS_PRI_KEY(n : longint) : boolean;
    begin
      IS_PRI_KEY:=(n and PRI_KEY_FLAG)<>0;
    end;

    function IS_NOT_NULL(n : longint) : boolean;
    begin
     IS_NOT_NULL:=(n and NOT_NULL_FLAG)<>0;
    end;

    function IS_BLOB(n : longint) : boolean;
    begin
     IS_BLOB:=(n and BLOB_FLAG)<>0;
    end;

    function IS_NUM_FIELD(f : pst_mysql_field) : boolean;
    begin
       IS_NUM_FIELD:=((f^.flags) and NUM_FLAG)<>0;
    end;

    function IS_NUM(t : enum_field_types) : boolean;
    begin
{$IFDEF mysql50}
      IS_NUM := (t <= FIELD_TYPE_INT24) or (t=FIELD_TYPE_YEAR) or (t=FIELD_TYPE_NEWDECIMAL);
{$ELSE}
      IS_NUM := (t <= FIELD_TYPE_INT24) or (t=FIELD_TYPE_YEAR);
{$ENDIF}
    end;

    function INTERNAL_NUM_FIELD(f : Pst_mysql_field) : boolean;
    begin
      INTERNAL_NUM_FIELD := (f^.ftype <= FIELD_TYPE_INT24) and ((f^.ftype <> FIELD_TYPE_TIMESTAMP)
      or (f^.length = 14) or (f^.length=8)) or (f^.ftype=FIELD_TYPE_YEAR);
    end;

    function mysql_reload(mysql : PMySQL) : longint;
    begin
      mysql_reload:=mysql_refresh(mysql,REFRESH_GRANT);
    end;

    function simple_command(mysql,command,arg,length,skip_check : longint) : longint;
    begin
      //simple_command:=mysql^.(methods^.advanced_command)(mysqlcommandNullS0arglengthskip_check);
      result := -1;
    end;


end.
