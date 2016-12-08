{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbus;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msectypes,msetypes,msestrings;

{$packrecords c}

const
{$ifdef mswindows}
 {$define wincall}  //depends on compiler?
 dbuslib: array[0..0] of filenamety = ('libdbus.dll');
{$else}
 dbuslib: array[0..0] of filenamety = ('libdbus-1.so');
{$endif}

type
 dbus_int64_t = int64;
 dbus_uint64_t = uint64;
 dbus_int32_t = int32;
 dbus_uint32_t = uint32;
 dbus_int16_t = int16;
 dbus_uint16_t = uint16;
 size_t = uint32;
 dbus_unichar_t = dbus_uint32_t;
 dbus_bool_t = dbus_uint32_t;
 pdbus_bool_t = ^dbus_bool_t;
 va_list = record end;
 pva_list = ^va_list;

//**
// * Indicates the status of incoming data on a #DBusConnection. This determines whether
// * dbus_connection_dispatch() needs to be called.
// */
 DBusDispatchStatus = (
  DBUS_DISPATCH_DATA_REMAINS,  //**< There is more data to potentially convert to messages. */
  DBUS_DISPATCH_COMPLETE,      //**< All currently available data has been processed. */
  DBUS_DISPATCH_NEED_MEMORY    //**< More memory is needed to continue. */
 );

const

//* Types of message */

//** This value is never a valid message type, see dbus_message_get_type() */
 DBUS_MESSAGE_TYPE_INVALID =       0;
//** Message type of a method call message, see dbus_message_get_type() */
 DBUS_MESSAGE_TYPE_METHOD_CALL =   1;
//** Message type of a method return message, see dbus_message_get_type() */
 DBUS_MESSAGE_TYPE_METHOD_RETURN = 2;
//** Message type of an error reply message, see dbus_message_get_type() */
 DBUS_MESSAGE_TYPE_ERROR =         3;
//** Message type of a signal message, see dbus_message_get_type() */
 DBUS_MESSAGE_TYPE_SIGNAL =        4;

 DBUS_NUM_MESSAGE_TYPES =          5;

//** Type code that is never equal to a legitimate type code */
 DBUS_TYPE_INVALID = cint(0);
///** #DBUS_TYPE_INVALID as a string literal instead of a int literal */
 DBUS_TYPE_INVALID_AS_STRING = cchar(#0);

//* Primitive types */
//** Type code marking an 8-bit unsigned integer */
 DBUS_TYPE_BYTE = cint('y');
//** #DBUS_TYPE_BYTE as a string literal instead of a int literal */
 DBUS_TYPE_BYTE_AS_STRING = 'y';
//** Type code marking a boolean */
 DBUS_TYPE_BOOLEAN = cint('b');
//** #DBUS_TYPE_BOOLEAN as a string literal instead of a int literal */
 DBUS_TYPE_BOOLEAN_AS_STRING = 'b';
//** Type code marking a 16-bit signed integer */
 DBUS_TYPE_INT16 = cint('n');
//** #DBUS_TYPE_INT16 as a string literal instead of a int literal */
 DBUS_TYPE_INT16_AS_STRING = 'n';
//** Type code marking a 16-bit unsigned integer */
 DBUS_TYPE_UINT16 = cint('q');
//** #DBUS_TYPE_UINT16 as a string literal instead of a int literal */
 DBUS_TYPE_UINT16_AS_STRING = 'q';
//** Type code marking a 32-bit signed integer */
 DBUS_TYPE_INT32 = cint('i');
//** #DBUS_TYPE_INT32 as a string literal instead of a int literal */
 DBUS_TYPE_INT32_AS_STRING = 'i';
//** Type code marking a 32-bit unsigned integer */
 DBUS_TYPE_UINT32 = cint('u');
//** #DBUS_TYPE_UINT32 as a string literal instead of a int literal */
 DBUS_TYPE_UINT32_AS_STRING = 'u';
//** Type code marking a 64-bit signed integer */
 DBUS_TYPE_INT64 = cint('x');
//** #DBUS_TYPE_INT64 as a string literal instead of a int literal */
 DBUS_TYPE_INT64_AS_STRING = 'x';
//** Type code marking a 64-bit unsigned integer */
 DBUS_TYPE_UINT64 = cint('t');
//** #DBUS_TYPE_UINT64 as a string literal instead of a int literal */
 DBUS_TYPE_UINT64_AS_STRING = 't';
//** Type code marking an 8-byte double in IEEE 754 format */
 DBUS_TYPE_DOUBLE = cint('d');
//** #DBUS_TYPE_DOUBLE as a string literal instead of a int literal */
 DBUS_TYPE_DOUBLE_AS_STRING = 'd';
//** Type code marking a UTF-8 encoded, nul-terminated Unicode string */
 DBUS_TYPE_STRING = cint('s');
//** #DBUS_TYPE_STRING as a string literal instead of a int literal */
 DBUS_TYPE_STRING_AS_STRING = 's';
//** Type code marking a D-Bus object path */
 DBUS_TYPE_OBJECT_PATH = cint('o');
//** #DBUS_TYPE_OBJECT_PATH as a string literal instead of a int literal */
 DBUS_TYPE_OBJECT_PATH_AS_STRING = 'o';
//** Type code marking a D-Bus type signature */
 DBUS_TYPE_SIGNATURE = cint('g');
//** #DBUS_TYPE_SIGNATURE as a string literal instead of a int literal */
 DBUS_TYPE_SIGNATURE_AS_STRING = 'g';
//** Type code marking a unix file descriptor */
 DBUS_TYPE_UNIX_FD = cint('h');
//** #DBUS_TYPE_UNIX_FD as a string literal instead of a int literal */
 DBUS_TYPE_UNIX_FD_AS_STRING = 'h';

//* Compound types */
//** Type code marking a D-Bus array type */
 DBUS_TYPE_ARRAY = cint('a');
//** #DBUS_TYPE_ARRAY as a string literal instead of a int literal */
 DBUS_TYPE_ARRAY_AS_STRING = 'a';
//** Type code marking a D-Bus variant type */
 DBUS_TYPE_VARIANT = cint('v');
//** #DBUS_TYPE_VARIANT as a string literal instead of a int literal */
 DBUS_TYPE_VARIANT_AS_STRING = 'v';

//** STRUCT and DICT_ENTRY are sort of special since their codes can't
// * appear in a type string, instead
// * DBUS_STRUCT_BEGIN_CHAR/DBUS_DICT_ENTRY_BEGIN_CHAR have to appear
// */
//** Type code used to represent a struct; however, this type code does not appear
// * in type signatures, instead #DBUS_STRUCT_BEGIN_CHAR and #DBUS_STRUCT_END_CHAR will
// * appear in a signature.
// */
 DBUS_TYPE_STRUCT = cint('r');
//** #DBUS_TYPE_STRUCT as a string literal instead of a int literal */
 DBUS_TYPE_STRUCT_AS_STRING = 'r';
//** Type code used to represent a dict entry; however, this type code does not appear
// * in type signatures, instead #DBUS_DICT_ENTRY_BEGIN_CHAR and #DBUS_DICT_ENTRY_END_CHAR will
// * appear in a signature.
// */
 DBUS_TYPE_DICT_ENTRY = cint('e');
//** #DBUS_TYPE_DICT_ENTRY as a string literal instead of a int literal */
 DBUS_TYPE_DICT_ENTRY_AS_STRING = 'e';

//* Owner flags */
 DBUS_NAME_FLAG_ALLOW_REPLACEMENT = $1;
  //**< Allow another service to become the primary owner if requested */
 DBUS_NAME_FLAG_REPLACE_EXISTING =  $2;
  //**< Request to replace the current primary owner */
 DBUS_NAME_FLAG_DO_NOT_QUEUE =      $4;
  //**< If we can not become the primary owner do not place us in the queue */

//* Replies to request for a name */
 DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER = 1;
  //**< Service has become the primary owner of the requested name */
 DBUS_REQUEST_NAME_REPLY_IN_QUEUE =      2;
  //**< Service could not become the primary owner and has been placed in the queue */
 DBUS_REQUEST_NAME_REPLY_EXISTS =        3;
  //**< Service is already in the queue */
 DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER = 4;
  //**< Service is already the primary owner */

 DBUS_TIMEOUT_INFINITE = cint($7fffffff);
 DBUS_TIMEOUT_USE_DEFAULT = cint(-1);

 DBUS_WATCH_READABLE = 1 shl 0; //**< As in POLLIN */
 DBUS_WATCH_WRITABLE = 1 shl 1; //**< As in POLLOUT */
 DBUS_WATCH_ERROR    = 1 shl 2; //**< As in POLLERR (can't watch for
                                // *   this, but can be present in
                                // *   current state passed to
                                // *   dbus_watch_handle()).
                                // */
  DBUS_WATCH_HANGUP   = 1 shl 3;  //**< As in POLLHUP (can't watch for
                                 //*   it, but can be present in current
                                 //*   state passed to
                                 //*   dbus_watch_handle()).
                                 //*/
  //* Internal to libdbus, there is also _DBUS_WATCH_NVAL in dbus-watch.h */ 
  
type
 DBusError = record
  name: pcchar;    //**< public error name field */
  message: pcchar; //**< public error message field */
  dummy: cuint;
//  unsigned int dummy1 : 1; /**< placeholder */
//  unsigned int dummy2 : 1; /**< placeholder */
//  unsigned int dummy3 : 1; /**< placeholder */
//  unsigned int dummy4 : 1; /**< placeholder */
//  unsigned int dummy5 : 1; /**< placeholder */
  padding1: pointer; {< placeholder }
 end;
 pDBusError = ^DBusError;

 DBusMessageIter = record
  dummy1: pointer;        //**< Don't use this */
  dummy2: pointer;        //**< Don't use this */
  dummy3: dbus_uint32_t;  //**< Don't use this */
  dummy4: cint;           //**< Don't use this */
  dummy5: cint;           //**< Don't use this */
  dummy6: cint;           //**< Don't use this */
  dummy7: cint;           //**< Don't use this */
  dummy8: cint;           //**< Don't use this */
  dummy9: cint;           //**< Don't use this */
  dummy10: cint;          //**< Don't use this */
  dummy11: cint;          //**< Don't use this */
  pad1: cint;             //**< Don't use this */
  pad2: cint;             //**< Don't use this */
  pad3: pointer;          //**< Don't use this */
 end;
 pDBusMessageIter = ^DBusMessageIter;

 DBusConnection = record end;
 pDBusConnection = ^DBusConnection;
 DBusMessage = record end;
 pDBusMessage = ^DBusMessage;
 DBusWatch = record end;
 pDBusWatch = ^DBusWatch;
 DBusTimeout = record end;
 pDBusTimeout = ^DBusTimeout;
 DBusPendingCall = record end;
 pDBusPendingCall = ^DBusPendingCall;
 ppDBusPendingCall = ^pDBusPendingCall;

//**
//* Results that a message handler can return.
//*/
DBusHandlerResult = (
 DBUS_HANDLER_RESULT_HANDLED,         
   //**< Message has had its effect - no need to run more handlers. */ 
 DBUS_HANDLER_RESULT_NOT_YET_HANDLED, 
   //**< Message has not had any effect - see if other handlers want it. */
 DBUS_HANDLER_RESULT_NEED_MEMORY      
   //**< Need more memory in order to return #DBUS_HANDLER_RESULT_HANDLED or 
   //#DBUS_HANDLER_RESULT_NOT_YET_HANDLED.
   // Please try again later with more memory. */
);

///**
// * Called when a message needs to be handled. The result indicates whether or
// * not more handlers should be run. Set with dbus_connection_add_filter().
// */
 DBusHandleMessageFunction = 
   function(connection: pDBusConnection; message: pDBusMessage;
                                         user_data: pointer): DBusHandlerResult
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
//**
//* Called when a message is sent to a registered object path. Found in
//* #DBusObjectPathVTable which is registered with dbus_connection_register_object_path()
//* or dbus_connection_register_fallback().
//*/
 DBusObjectPathMessageFunction = 
   function(connection: pDBusConnection; message: pDBusMessage;
                                 user_data: pointer): DBusHandlerResult
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
//**
//* Called when a #DBusObjectPathVTable is unregistered (or its connection is freed).
//* Found in #DBusObjectPathVTable.
//*/
 DBusObjectPathUnregisterFunction = procedure(connection: pDBusConnection;
                                                      user_data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 DBusObjectPathVTable = record
  unregister_function: DBusObjectPathUnregisterFunction; 
                          //**< Function to unregister this handler */
  message_function: DBusObjectPathMessageFunction; 
                          //**< Function to handle messages */
  
  dbus_internal_pad1: pointer; //**< Reserved for future expansion */
  dbus_internal_pad2: pointer; //**< Reserved for future expansion */
  dbus_internal_pad3: pointer; //**< Reserved for future expansion */
  dbus_internal_pad4: pointer; //**< Reserved for future expansion */
 end;
 pDBusObjectPathVTable = ^DBusObjectPathVTable;
 
 DBusBusType = (
  DBUS_BUS_SESSION,    //**< The login session bus */
  DBUS_BUS_SYSTEM,     //**< The systemwide bus */
  DBUS_BUS_STARTER     //**< The bus that started us, if any */
 );

 DBusFreeFunction = procedure(memory: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

//** Called when libdbus needs a new watch to be monitored by the main
//* loop. Returns #FALSE if it lacks enough memory to add the
//* watch. Set by dbus_connection_set_watch_functions() or
//* dbus_server_set_watch_functions().
//*/
 DBusAddWatchFunction = function(watch: pDBusWatch;
                                           data: pointer): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
                                                  
//** Called when dbus_watch_get_enabled() may return a different value
//*  than it did before.  Set by dbus_connection_set_watch_functions()
//*  or dbus_server_set_watch_functions().
//*/
 DBusWatchToggledFunction = procedure(watch: pDBusWatch; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

//** Called when libdbus no longer needs a watch to be monitored by the
//* main loop. Set by dbus_connection_set_watch_functions() or
//* dbus_server_set_watch_functions().
//*/
 DBusRemoveWatchFunction = procedure(watch: pDBusWatch; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

//** Called when libdbus needs a new timeout to be monitored by the main
//* loop. Returns #FALSE if it lacks enough memory to add the
//* watch. Set by dbus_connection_set_timeout_functions() or
//* dbus_server_set_timeout_functions().
//*/
 DBusAddTimeoutFunction = function(timeout: pDBusTimeout;
                                            data: pointer): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

//** Called when dbus_timeout_get_enabled() may return a different
//* value than it did before.
//* Set by dbus_connection_set_timeout_functions() or
//* dbus_server_set_timeout_functions().
//*/
 DBusTimeoutToggledFunction = procedure(timeout: pDBusTimeout; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
//** Called when libdbus no longer needs a timeout to be monitored by the
//* main loop. Set by dbus_connection_set_timeout_functions() or
//* dbus_server_set_timeout_functions().
//*/
 DBusRemoveTimeoutFunction = procedure(timeout: pDBusTimeout; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

//**
//* Called when a pending call now has a reply available. Set with
//* dbus_pending_call_set_notify().
//*/
 DBusPendingCallNotifyFunction =  procedure(pending: pDBusPendingCall; 
                                                     user_data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 
var
 dbus_bus_get:
   function(type_: DBusBusType; error: PDBusError): PDBusConnection
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_bus_get_private: 
   function(type_: DBusBusType; error: PDBusError): PDBusConnection
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_close: procedure(connection: pDBusConnection)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_shutdown: procedure()
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_connection_set_watch_functions:
   function(connection: pDBusConnection; add_function: DBusAddWatchFunction;
             remove_function: DBusRemoveWatchFunction;
             toggled_function: DBusWatchToggledFunction;
             data: pointer;
             free_data_function: DBusFreeFunction): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_set_timeout_functions:
   function(connection: pDBusConnection; add_function: DBusAddTimeoutFunction;
             remove_function: DBusRemoveTimeoutFunction;
             toggled_function: DBusTimeoutToggledFunction;
             data: pointer;
             free_data_function: DBusFreeFunction): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_connection_add_filter:
   function(connection: pDBusConnection; function_: DBusHandleMessageFunction;
         user_data: pointer; free_data_function: DBusFreeFunction): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_remove_filter:
   procedure(connection: pDBusConnection;
              function_: DBusHandleMessageFunction; user_data: pointer);
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_try_register_object_path:
   function(cionnection: pDBusConnection; path: pchar; 
                        vtable: pDBusObjectPathVTable;
                       user_data: pointer; error: pDBusError): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_unregister_object_path:
   function(connection: pDBusConnection; path: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_try_register_fallback:
   function(connection: pDBusConnection; path: pcchar;
               vtable: pDBusObjectPathVTable; user_data: pointer;
                                        error: pDBusError): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_watch_get_unix_fd: function(watch: pDBusWatch): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_get_socket: function(watch: pDBusWatch): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_get_flags: function(watch: pDBusWatch): cuint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_get_data: function(watch: pDBusWatch): pointer
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_set_data: procedure(watch: pDBusWatch; data: pointer;
                                     free_data_function: DBusFreeFunction)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_handle: function(watch: pDBusWatch; flags: cuint): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_watch_get_enabled: function(watch: pDBusWatch): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_timeout_get_interval: function(timeout: pDBusTimeout): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_get_data: function(timeout: pDBusTimeout): pointer
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_set_data: procedure(timeout: pDBusTimeout; data: pointer;
                                       free_data_function: DBusFreeFunction)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_handle: function(timeout: pDBusTimeout): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_get_enabled: function(timeout: pDBusTimeout): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_needs_restart: function(timeout: pDBusTimeout): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_timeout_restarted: procedure(timeout: pDBusTimeout)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_error_init: procedure(error: pDBusError)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_error_free: procedure(error: pDBusError)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_error_is_set: function(error: pDBusError): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_set_exit_on_disconnect: 
   procedure(connection: pDBusConnection; exit_on_disconnect: dbus_bool_t) 
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_bus_get_unique_name: function(connection: pDBusConnection): pcchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_bus_request_name: 
   function(connection: PDBusConnection; name: pcchar; flags: cuint;
                                           error: pDBusError): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_new_method_call:
   function(bus_name: pcchar; path: pcchar; iface: pcchar;
                                         method: pcchar): pDBusMessage
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_message_unref: procedure(message: pDBusMessage)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_type: function(message: pDBusMessage): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_path: function(message:pDBusMessage;
                                          object_path: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_path: function(message: pDBusMessage): pcchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_interface: 
   function(message: pDBusMessage; iface: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_interface: function(message: pDBusMessage): pcchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_member: 
   function(message: pDBusMessage; member: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_member: function(message: pDBusMessage): pcchar;
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_error_name:
   function(message: pDBusMessage; name: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_error_name: 
   function(message: pDBusMessage): pcchar;
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_destination:
   function(message: pDBusMessage; destination: pchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_destination: function(message: pDBusMessage): pchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_sender:
   function(msessage: pDBusMessage; sender: pcchar): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_sender: function (message: pDBusMessage): pcchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_signature: function(message: pDBusMessage): pchar
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_set_no_reply: 
   procedure(message: pDBusMessage; no_reply: dbus_bool_t)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_get_no_reply: function(message: pDBusMessage): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_message_iter_init_append: 
   procedure(message: pDBusMessage; iter: pDBusMessageIter)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_init: 
   function(message: pDBusMessage; iter: pDBusMessageIter): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_append_args_valist:
   function (message: pDBusMessage; first_arg_type: cint;
                                            var_args: pva_list): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_append_basic:
   function(iter: pDBusMessageIter; type_: cint; value: pointer): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_message_iter_next: function (iter: pDBusMessageIter): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_get_arg_type: function (iter: pDBusMessageIter): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_get_basic: procedure (iter: pDBusMessageIter; value: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_open_container:
   function(iter: pDBusMessageIter; type_: cint;
                       const contained_signature: pcchar; 
                                 sub: pDBusMessageIter): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_close_container:
   function(iter: pDBusMessageIter; sub: pDBusMessageIter): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_abandon_container: 
   procedure(iter: pDBusMessageIter; sub: pDBusMessageIter);
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_message_iter_recurse: 
   procedure (iter: pDBusMessageIter; sub: pDBusMessageIter)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_get_element_type: function (iter: pDBusMessageIter): cint
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_message_iter_get_fixed_array:
   procedure (iter: pDBusMessageIter; value: pointer; n_elements: pcint)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_connection_send_with_reply_and_block:
   function(connection: pDBusConnection; message: pDBusMessage;
              timeout_milliseconds: cint; error: pDBusError): pDBusMessage
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_send_with_reply:
   function(connection: pDBusConnection; message: pDBusMessage;
                           pending_return:  ppDBusPendingCall; 
                                   timeout_milliseconds: cint): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_flush: procedure(connection: pDBusConnection)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_connection_dispatch:
   function(connection: pDBusConnection): DBusDispatchStatus
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

 dbus_pending_call_unref: procedure(pending: pDBusPendingCall)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_pending_call_set_notify:
   function(pending: pDBusPendingCall;
             function_: DBusPendingCallNotifyFunction;
             user_data: pointer; free_user_data: DBusFreeFunction): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
 dbus_pending_call_steal_reply: 
   function(pending: pDBusPendingCall): pDBusMessage
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};

procedure initializedbus(const sonames: array of filenamety;
                                          const onlyonce: boolean = false);
                                     //[] = default
procedure releasedbus();

implementation
uses
 msedynload,sysutils;
var 
 libinfo: dynlibinfoty;

procedure inidbus();
begin
end;

procedure finidbus();
begin
end;

procedure initializedbus(const sonames: array of filenamety; //[] = default
                                         const onlyonce: boolean = false);                                   
const
 funcs: array[0..69] of funcinfoty = (
  (n: 'dbus_bus_get'; d: @dbus_bus_get),                         // 0
  (n: 'dbus_bus_get_private'; d: @dbus_bus_get_private),         // 1
  (n: 'dbus_connection_close'; d: @dbus_connection_close),       // 2
  (n: 'dbus_shutdown'; d: @dbus_shutdown),                       // 3
  (n: 'dbus_connection_set_watch_functions';
           d: @dbus_connection_set_watch_functions),             // 4
  (n: 'dbus_connection_set_timeout_functions';
           d: @dbus_connection_set_timeout_functions),           // 5
  (n: 'dbus_connection_add_filter';
           d: @dbus_connection_add_filter),                      // 6
  (n: 'dbus_connection_remove_filter';
           d: @dbus_connection_remove_filter),                   // 7
  (n: 'dbus_connection_try_register_object_path'; 
           d: @dbus_connection_try_register_object_path),        // 8
  (n: 'dbus_connection_try_register_fallback';
           d: @dbus_connection_try_register_fallback),           // 9
  (n: 'dbus_connection_unregister_object_path';
           d: @dbus_connection_unregister_object_path),          //10
  (n: 'dbus_watch_get_unix_fd'; d: @dbus_watch_get_unix_fd),     //11
  (n: 'dbus_watch_get_socket'; d: @dbus_watch_get_socket),       //12
  (n: 'dbus_watch_get_flags'; d: @dbus_watch_get_flags),         //13
  (n: 'dbus_watch_get_data'; d: @dbus_watch_get_data),           //14
  (n: 'dbus_watch_set_data'; d: @dbus_watch_set_data),           //15
  (n: 'dbus_watch_handle'; d: @dbus_watch_handle),               //16
  (n: 'dbus_watch_get_enabled'; d: @dbus_watch_get_enabled),     //17

  (n: 'dbus_timeout_get_interval'; 
           d: @dbus_timeout_get_interval),                       //18
  (n: 'dbus_timeout_get_data'; d: @dbus_timeout_get_data),       //19
  (n: 'dbus_timeout_set_data'; d: @dbus_timeout_set_data),       //20
  (n: 'dbus_timeout_handle'; d: @dbus_timeout_handle),           //21
  (n: 'dbus_timeout_get_enabled'; d: @dbus_timeout_get_enabled), //22
  (n: 'dbus_timeout_needs_restart';
           d: @dbus_timeout_needs_restart),                      //23
  (n: 'dbus_timeout_restarted'; d: @dbus_timeout_restarted),     //24

  (n: 'dbus_error_init'; d: @dbus_error_init),                   //25
  (n: 'dbus_error_free'; d: @dbus_error_free),                   //26
  (n: 'dbus_error_is_set'; d: @dbus_error_is_set),               //27
  (n: 'dbus_connection_set_exit_on_disconnect';
           d: @dbus_connection_set_exit_on_disconnect),          //28
  (n: 'dbus_bus_get_unique_name'; d: @dbus_bus_get_unique_name), //29
  (n: 'dbus_bus_request_name'; d: @dbus_bus_request_name),       //30
  (n: 'dbus_message_new_method_call'; 
           d: @dbus_message_new_method_call),                    //31
  (n: 'dbus_message_get_type'; d: @dbus_message_get_type),       //32
  (n: 'dbus_message_set_path'; d: @dbus_message_set_path),       //33
  (n: 'dbus_message_get_path'; d: @dbus_message_get_path),       //34
  (n: 'dbus_message_set_interface'; 
           d: @dbus_message_set_interface),                      //35
  (n: 'dbus_message_get_interface';
           d: @dbus_message_get_interface),                      //36
  (n: 'dbus_message_set_member'; d: @dbus_message_set_member),   //37
  (n: 'dbus_message_get_member'; d: @dbus_message_get_member),   //38
  (n: 'dbus_message_set_error_name';
           d: @dbus_message_set_error_name),                     //39
  (n: 'dbus_message_get_error_name';
           d: @dbus_message_get_error_name),                     //40
  (n: 'dbus_message_set_destination';
           d: @dbus_message_set_destination),                    //41
  (n: 'dbus_message_get_destination';
           d: @dbus_message_get_destination),                    //42
  (n: 'dbus_message_set_sender'; d: @dbus_message_set_sender),   //43
  (n: 'dbus_message_set_sender'; d: @dbus_message_set_sender),   //44
  (n: 'dbus_message_get_sender'; d: @dbus_message_get_sender),   //45
  (n: 'dbus_message_get_signature';
           d: @dbus_message_get_signature),                      //46
  (n: 'dbus_message_set_no_reply';
           d: @dbus_message_set_no_reply),                       //47
  (n: 'dbus_message_get_no_reply';
           d: @dbus_message_get_no_reply),                       //48

  (n: 'dbus_message_unref'; d: @dbus_message_unref),             //49
  (n: 'dbus_message_iter_init_append';
           d: @dbus_message_iter_init_append),                   //50
  (n: 'dbus_message_iter_init'; d: @dbus_message_iter_init),     //51
  (n: 'dbus_message_append_args_valist'; 
           d: @dbus_message_append_args_valist),                 //52
  (n: 'dbus_message_iter_append_basic';
           d: @dbus_message_iter_append_basic),                  //53
  (n: 'dbus_message_iter_next'; d: @dbus_message_iter_next),     //54
  (n: 'dbus_message_iter_get_arg_type';
           d: @dbus_message_iter_get_arg_type),                  //55
  (n: 'dbus_message_iter_get_basic';
           d: @dbus_message_iter_get_basic),                     //56
  (n: 'dbus_message_iter_open_container'; 
           d: @dbus_message_iter_open_container),                //57
  (n: 'dbus_message_iter_close_container'; 
           d: @dbus_message_iter_close_container),               //58
  (n: 'dbus_message_iter_abandon_container'; 
           d: @dbus_message_iter_abandon_container),             //59
  (n: 'dbus_message_iter_recurse'; 
           d: @dbus_message_iter_recurse),                       //60
  (n: 'dbus_message_iter_get_element_type';
           d: @dbus_message_iter_get_element_type),              //61
  (n: 'dbus_message_iter_get_fixed_array';
           d: @dbus_message_iter_get_fixed_array),               //62
  (n: 'dbus_connection_send_with_reply_and_block';
           d: @dbus_connection_send_with_reply_and_block),       //63
  (n: 'dbus_connection_send_with_reply'; 
           d: @dbus_connection_send_with_reply),                 //64
  (n: 'dbus_connection_flush'; d: @dbus_connection_flush),       //65
  (n: 'dbus_connection_dispatch'; d: @dbus_connection_dispatch), //66
  (n: 'dbus_pending_call_unref'; d: @dbus_pending_call_unref),   //67
  (n: 'dbus_pending_call_set_notify';
           d: @dbus_pending_call_set_notify),                    //68
  (n: 'dbus_pending_call_steal_reply'; 
           d: @dbus_pending_call_steal_reply)                    //69
 );

{
  (n: ''; d: @),//
}

 errormessage = 'Can not load D-Bus library. ';

begin
 if not onlyonce or (libinfo.refcount = 0) then begin
  initializedynlib(libinfo,sonames,dbuslib,funcs,[],errormessage,@inidbus);
 end;
end;

procedure releasedbus();
begin
 releasedynlib(libinfo,@finidbus);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
