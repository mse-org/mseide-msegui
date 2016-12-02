{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbusinterface;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}

{$ifdef mswindows}
 {$define wincall} //depends on compiler?
{$endif}

interface
uses
 mseglob,msectypes,msedbus,msetypes,mseclasses,mseevent,msehash,sysutils;
type
 dbusdataty = (
  dbt_INVALID,
  dbt_BYTE,
  dbt_BOOLEAN,
  dbt_INT16,
  dbt_UINT16,
  dbt_INT32,
  dbt_UINT32,
  dbt_INT64,
  dbt_UINT64,
  dbt_DOUBLE,
  dbt_STRING,
  dbt_OBJECT_PATH,
  dbt_SIGNATURE,
  dbt_UNIX_FD,
  dbt_ARRAY,
  dbt_VARIANT,
  dbt_STRUCT,
  dbt_DICT_ENTRY
 );
 pdbusdataty = ^dbusdataty;
 
 edbus = class(exception)
 end;

const
 datasizes: array[dbusdataty] of int32 = (
  0,                 //dbt_INVALID,
  sizeof(byte),      //dbt_BYTE,
  sizeof(boolean),   //dbt_BOOLEAN,
  sizeof(int16),     //dbt_INT16,
  sizeof(card16),    //dbt_UINT16,
  sizeof(int32),     //dbt_INT32,
  sizeof(card32),    //dbt_UINT32,
  sizeof(int64),     //dbt_INT64,
  sizeof(card64),    //dbt_UINT64,
  sizeof(flo64),     //dbt_DOUBLE,
  sizeof(ansistring),//dbt_STRING,
  sizeof(ansistring),//dbt_OBJECT_PATH,
  sizeof(ansistring),//dbt_SIGNATURE,
  0,                 //dbt_UNIX_FD,
  0,                 //dbt_ARRAY,
  0,                 //dbt_VARIANT,
  0,                 //dbt_STRUCT,
  0                  //dbt_DICT_ENTRY
 );

var
 arraytypes: array[dbusdataty] of pdynarraytypeinfo;
const
 dbusdatacodes: array[dbusdataty] of cint = (
  DBUS_TYPE_INVALID,
  DBUS_TYPE_BYTE,
  DBUS_TYPE_BOOLEAN,
  DBUS_TYPE_INT16,
  DBUS_TYPE_UINT16,
  DBUS_TYPE_INT32,
  DBUS_TYPE_UINT32,
  DBUS_TYPE_INT64,
  DBUS_TYPE_UINT64,
  DBUS_TYPE_DOUBLE,
  DBUS_TYPE_STRING,
  DBUS_TYPE_OBJECT_PATH,
  DBUS_TYPE_SIGNATURE,
  DBUS_TYPE_UNIX_FD,
  DBUS_TYPE_ARRAY,
  DBUS_TYPE_VARIANT,
  DBUS_TYPE_STRUCT,
  DBUS_TYPE_DICT_ENTRY
 );

 dbusdatastrings: array[dbusdataty] of string = (
  DBUS_TYPE_INVALID_AS_STRING,
  DBUS_TYPE_BYTE_AS_STRING,
  DBUS_TYPE_BOOLEAN_AS_STRING,
  DBUS_TYPE_INT16_AS_STRING,
  DBUS_TYPE_UINT16_AS_STRING,
  DBUS_TYPE_INT32_AS_STRING,
  DBUS_TYPE_UINT32_AS_STRING,
  DBUS_TYPE_INT64_AS_STRING,
  DBUS_TYPE_UINT64_AS_STRING,
  DBUS_TYPE_DOUBLE_AS_STRING,
  DBUS_TYPE_STRING_AS_STRING,
  DBUS_TYPE_OBJECT_PATH_AS_STRING,
  DBUS_TYPE_SIGNATURE_AS_STRING,
  DBUS_TYPE_UNIX_FD_AS_STRING,
  DBUS_TYPE_ARRAY_AS_STRING,
  DBUS_TYPE_VARIANT_AS_STRING,
  DBUS_TYPE_STRUCT_AS_STRING,
  DBUS_TYPE_DICT_ENTRY_AS_STRING
 );
 
var
 dbuslasterror: string;
 
function dbusconnect(): boolean; //true if ok
procedure dbusdisconnect();
function dbusid(): string;
function dbusname(): string;

function dbuscallmethod(const returnedto: ievent;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok

implementation
uses
 msestrings,msesysintf,msearrayutils,msesys,mseguiintf,msetimer,
 mseapplication;

const
 msebusname = 'mse.msegui.app';

type
 watchinfoty = record
  flags: pollflagsty;
  id: int32;
  watch: pdbuswatch;
 end;
 pwatchinfoty = ^watchinfoty;

 timeoutinfoty = record
  timeout: pdbustimeout;
  timer: tsimpletimer;
 end;
 ptimeoutinfoty = ^timeoutinfoty;

 pendinginfoty = record
  pending: pdbuspendingcall;
 end;
 ppendinginfoty = ^pendinginfoty;

 linkinfoty = record
  link: ievent;
 end;
 plinkinfoty = ^linkinfoty;
 itemkindty = (dbk_watch,dbk_timeout,dbk_pending,dbk_link);
 
 dbusinfoty = record
  case kind: itemkindty of
   dbk_watch: (watch: watchinfoty);
   dbk_timeout: (timeout: timeoutinfoty);
   dbk_pending: (pending: pendinginfoty);
   dbk_link: (link: linkinfoty);
 end;
 pdbusinfoty = ^dbusinfoty;
 dbusitemty = record
  key: pointer;
  data: dbusinfoty;
 end;
 pdbusitemty = ^dbusitemty;

 tdbusitemhashdatalist = class(tpointerhashdatalist,iobjectlink)
  private
   fwatches: card32arty;
   funlinking: boolean;
  protected
   procedure finalizeitem(var aitemdata) override;
   procedure dopollcallback(const aflags: pollflagsty; const adata: pointer);
   function findwatch(const key: pdbuswatch): pwatchinfoty;
   function findtimeout(const key: pdbustimeout): ptimeoutinfoty;
   function findpending(const key: pdbuspendingcall): ppendinginfoty;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                         ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
                //source = 1 -> dest destroyed
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  public
   constructor create();
   function addwatch(const key: pdbuswatch): pwatchinfoty;
   function addlink(const alink: ievent): plinkinfoty;
//   function addpending(const aitem: pdbuspendingcall): ppendinginfoty;
//   procedure freeitems();
   procedure handlewatches();
 end;
  
 tdbuscontroller = class(tobject)
  private
   fconn: pdbusconnection;
   ferr: dbuserror;
   fbusid: string;
   fbusname: string;
   fitems: tdbusitemhashdatalist;
//   fwatches: array of pwatchinfoty;
//   ftimeouts: array of ptimeoutinfoty;
//   fpendings: array of ppendinfoty;
  protected
   function connect: boolean;
   procedure disconnect();
   function doaddwatch(const awatch: pdbuswatch): int32;
   procedure dowatchtoggled(const awatch: pdbuswatch);
   procedure doremovewatch(const awatch: pdbuswatch);
   function doaddtimeout(const atimeout: pdbustimeout): int32;
   procedure dotimeouttoggled(const atimeout: pdbustimeout);
   procedure doremovetimeout(const atimeout: pdbustimeout);
   procedure updatewatch(const awatch: pdbuswatch);
   procedure updatetimeout(const atimeout: pdbustimeout);
   procedure dotimer(const sender: tobject);
   function err(): pdbuserror;
   function checkok(): boolean;
   procedure doidle(var again: boolean);
   procedure dopendingcallback(pending: pDBusPendingCall; user_data: pointer);
//   procedure dofreependingcallback(memory: pointer);
//   procedure dopollcallback(const aflags: pollflagsty; const adata: pointer);
   procedure addpending(const apending: pdbuspendingcall);

  public
   constructor create();
   destructor destroy(); override;
   function connected: boolean;
   function dbuscallmethod(const returnedto: ievent;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok
 end;
 
var
// conn: pdbusconnection;
// ferr: dbuserror;
// busid: string;
// busname: string;
 fdbc: tdbuscontroller;

procedure raiseerror(const message: string);
begin
 raise edbus.create(message);
end;

procedure error(const message: string);
begin
 dbuslasterror:= message;
end;

procedure outofmemory();
begin
 error('Out of memory');
end;

function checkconnect(): boolean;
begin
 result:= (fdbc <> nil) and fdbc.connected;
end;

(*
function checkconnect(): boolean; //true if ok
begin
 result:= conn <> nil; //todo: try reconnect
 if not result then begin
  error('DBus not active');
 end;
end;
*)
{
function err(): pdbuserror;
begin
 if dbus_error_is_set(@ferr) <> 0 then begin
  dbus_error_free(@ferr);
 end;
 result:= @ferr;
end;

function checkok(): boolean;
begin
 result:= dbus_error_is_set(@ferr) = 0;
 if not result then begin
  dbuslasterror:= ferr.message;
 end;
end;
}
(*
function dbusconnect(): boolean; //true if ok
var
 i1,i2: int32;
 s1,s2: string;
begin
 if conn <> nil then begin
  result:= true;
 end;
 result:= false;
 try
  initializedbus([]);
  dbus_error_init(@ferr);
  conn:= dbus_bus_get_private(dbus_bus_session,err);
  if conn = nil then begin
   checkok();
  end
  else begin
   dbus_connection_set_exit_on_disconnect(conn,0);
   busid:= dbus_bus_get_unique_name(conn);
   s1:= msebusname+'-'+inttostr(sys_getpid())+'-';
   i1:= 0;
   repeat
    s2:= s1+inttostr(i1);
    i2:= dbus_bus_request_name(conn,pchar(s2),
                                 DBUS_NAME_FLAG_DO_NOT_QUEUE,err());
    inc(i1);
    if (i1 > 100) or (i2 < 0)  then begin
     dbusdisconnect();
     exit;
    end;
   until (i2 = DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER) or
           (i2 = DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER); //should not happen
   busname:= s2;
   result:= true;
  end;
 except
  on e: exception do begin
   dbuslasterror:= e.message;
  end;
 end;
end;
*)
function dbusconnect(): boolean; //true if ok
begin
 if fdbc = nil then begin
  fdbc:= tdbuscontroller.create;
 end;
 result:= fdbc.connect();
end;
(*
procedure dbusdisconnect();
begin
 if conn <> nil then begin
  err(); //free ferr
  dbus_connection_close(conn);
  conn:= nil;
  busid:= '';
  busname:= '';
 end;
 releasedbus();
end;
*)

procedure dbusdisconnect();
begin
 if fdbc <> nil then begin
  fdbc.disconnect();
 end;
end;

function dbusid(): string;
begin
 result:= '';
 if checkconnect() then begin
  result:= fdbc.fbusid;
 end;
end;

function dbusname(): string;
begin
 result:= '';
 if checkconnect() then begin
  result:= fdbc.fbusname;
 end;
end;

function dbuscallmethod(const returnedto: ievent;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok
begin
 result:= false;
 if checkconnect() then begin
  result:= fdbc.dbuscallmethod(returnedto,bus_name,path,iface,method,
                                            paramtypes,params,timeout);
 end;
end;

(*
function dbuscallmethod(const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const resulttypes: array of dbusdataty;
               const results: array of pointer; 
               const timeout: int32 = -1): boolean; //true if ok
var
 m1,m2: pdbusmessage;
 pte: pdbusdataty;
 pde: ppointer;

 function writevalue(var iter: dbusmessageiter;
                             var pt: pdbusdataty; var pd: ppointer): boolean;
 var
  p1,pe: pointer;
  p2: ppointer;
  p3: pdbusdataty;
  bool1: dbus_bool_t;
  pc1: pcchar;
  iter2: dbusmessageiter;
  i1,i2: int32;
 label
  oklab;
 begin
  result:= false;
  if pt >= pte then begin
   error('dbuscallmethod() paramtypes and params count do not match');
   exit;
  end;
  p1:= pd^;
  case pt^ of
// dbt_INVALID,
   dbt_BYTE: begin
    p1:= @bool1;
    bool1:= 0;
    if pboolean(pd)^ then begin
     bool1:= 1;
    end;
   end;
   dbt_BOOLEAN: begin
   end;
   dbt_INT16: begin
   end;
   dbt_UINT16: begin
   end;
   dbt_INT32: begin
   end;
   dbt_UINT32: begin
   end;
   dbt_INT64: begin
   end;
   dbt_UINT64: begin
   end;
   dbt_DOUBLE: begin
   end;
   dbt_STRING,dbt_OBJECT_PATH,dbt_SIGNATURE: begin
    p1:= @pc1;
    pc1:= pchar(pansistring(pd^)^);
   end;
   
// dbt_UNIX_FD,
   dbt_ARRAY: begin
    inc(pt);
    if pt >= pte then begin
     error('dbuscallmethod() paramtypes and params count do not match');
     exit;
    end;
    p1:= pd^; //pointer to var
    i1:= datasizes[pt^];
    if i1 = 0 then begin
     error('dbuscallmethod() array item type not yet supported');
     exit;
    end;
    if dbus_message_iter_open_container(@iter,dbusdatacodes[dbt_array],
                          pchar(dbusdatastrings[pt^]),@iter2) = 0 then begin
                     //todo: construct valid signature for nested container
     outofmemory();
     exit;
    end;
    p1:= ppointer(p1)^; //dynamic array
    i2:= dynarraylength(p1);
    if p1 <> nil then begin
     pe:= p1 + i1 * i2;
     while p1 < pe do begin
      p2:= @p1; //restore
      p3:= pt;  //restore
      if not writevalue(iter2,p3,p2) then begin
       dbus_message_iter_abandon_container(@iter,@iter2);
       exit;
      end;
      inc(p1,i1);
     end;
    end;
    if dbus_message_iter_close_container(@iter,@iter2) = 0 then begin
     outofmemory();
     exit;
    end;
    goto oklab;
   end;
// dbt_VARIANT,
// dbt_STRUCT,
// dbt_DICT_ENTRY
   else begin
    result:= false;
    error('dbuscallmethod() paramtype not yet supported');
    exit;
   end;
  end;

  if dbus_message_iter_append_basic(@iter,
                                 dbusdatacodes[pt^],p1) = 0 then begin
   outofmemory();
   exit;
  end;
 oklab:
  inc(pt);
  inc(pd);
  result:= true;
 end;//writevalue

 function readvalue(var aiter: dbusmessageiter; 
                                 var pt: pdbusdataty; var pd: ppointer): boolean;
 var
  i1,i2,i3,i4: int32;
  si1: sizeint;
  p1,p2: pointer;
  p3: pdbusdataty;
  p4: ppointer;
  bool1: dbus_bool_t;
  pc1: pcchar;
  isstring: boolean;
  typ1: pdynarraytypeinfo;
  t1: dbusdataty;
  iter2,iter3: dbusmessageiter;
  iterpo: pdbusmessageiter;
  
 label
  oklab;
 begin
  result:= false;
  if pt >= pte then begin
   error('dbuscallmethod() resulttypes and results count do not match');
   exit;
  end;
  iterpo:= @aiter;
  i1:= dbus_message_iter_get_arg_type(iterpo);
  if i1 = DBUS_TYPE_INVALID then begin
   error('dbuscallmethod() returned param count:'+
                   inttostr(pd - ppointer(@results[0]))+
                              ' expected:'+inttostr(length(results)));
   exit;
  end;
  if i1 = DBUS_TYPE_VARIANT then begin
   dbus_message_iter_recurse(@aiter,@iter3);   
   iterpo:= @iter3;
   i1:= dbus_message_iter_get_arg_type(iterpo); //nested variants?
  end;
  if i1 <> dbusdatacodes[pt^] then begin
   error('dbuscallmethod() returned param does not match:'+inttostr(i1)+
            ' expected:'+inttostr(dbusdatacodes[pt^]));
   exit;
  end;
  isstring:= false;
  p1:= pd^;
  case i1 of
// DBUS_TYPE_INVALID,
   DBUS_TYPE_BYTE: begin
   end;
   DBUS_TYPE_BOOLEAN: begin
    p1:= @bool1;
   end;
   DBUS_TYPE_INT16: begin
   end;
   DBUS_TYPE_UINT16: begin
   end;
   DBUS_TYPE_INT32: begin
   end;
   DBUS_TYPE_UINT32: begin
   end;
   DBUS_TYPE_INT64: begin
   end;
   DBUS_TYPE_UINT64: begin
   end;
   DBUS_TYPE_DOUBLE: begin
   end;
   DBUS_TYPE_STRING,DBUS_TYPE_OBJECT_PATH,DBUS_TYPE_SIGNATURE: begin
    isstring:= true;
    p1:= @pc1;
   end;
   
// DBUS_TYPE_UNIX_FD,
   DBUS_TYPE_ARRAY: begin
    inc(pt);
    if pt >= pte then begin
     error('dbuscallmethod() returntypes and returns count do not match');
     exit;
    end;
    i1:= datasizes[pt^];
    if i1 = 0 then begin
     error('dbuscallmethod() array item type not yet supported');
     exit;
    end;
    i2:= dbus_message_iter_get_element_type(iterpo);
    if i2 <> dbusdatacodes[pt^] then begin
     error('dbuscallmethod() returned array item type does not match');
     exit;
    end;
    p1:= pd^; //pointer to var
    t1:= pt^;
    typ1:= arraytypes[t1];
    i3:= 0;
    dbus_message_iter_recurse(iterpo,@iter2);
    while dbus_message_iter_get_arg_type(@iter2) <> DBUS_TYPE_INVALID do begin
     additem(p1^,typ1,i3);
     p2:= ppointer(p1)^ + i1*(i3-1); //data pointer in array
     p4:= @p2;
     p3:= @t1;
     if not readvalue(iter2,p3,p4) then begin
      exit;
     end;
    end;
    si1:= i3;
    dynarraysetlength(ppointer(p1)^,typ1,1,@si1);
    goto oklab;
   end; //array
// DBUS_TYPE_VARIANT,
// DBUS_TYPE_STRUCT,
// DBUS_TYPE_DICT_ENTRY
   else begin
    error('dbuscallmethod() invalid returned value');
    exit;
   end;     
  end;
  dbus_message_iter_get_basic(iterpo,p1);
  p1:= pd^;
  if isstring then begin
   if pc1 = nil then begin
    pansistring(p1)^:= '';
   end
   else begin
    pansistring(p1)^:= ansistring(pc1);
   end;
  end
  else begin
   if i1 = DBUS_TYPE_BOOLEAN then begin
    pboolean(p1)^:= bool1 <> 0;
   end;
  end;
 oklab:
  dbus_message_iter_next(@aiter);
  inc(pt);
  inc(pd);
  result:= true;
 end;//readvalue
 
var
 iter1: dbusmessageiter;
// iter2: dbusmessageiter;
 i1,i2: int32;
 do1: double;
 p1: pointer;
 pc1: pchar;
 dbuty: dbusdataty;
 s1: string;
 bool1: dbus_bool_t;
 isstring: boolean;
 pt: pdbusdataty;
 pd: ppointer;
label
 errorlab,errorlab1;
begin
 result:= false;
 if checkconnect() then begin
  m1:= dbus_message_new_method_call(pointer(bus_name),pchar(path),
                                               pointer(iface),pchar(method));
  if m1 = nil then begin
   outofmemory();
   exit;
  end
  else begin
   dbus_message_iter_init_append(m1,@iter1);
   pt:= @paramtypes[0];
   pte:= pt + length(paramtypes);
   pd:= @params[0];
   pde:= pd + length(params);
   while pd < pde do begin
    writevalue(iter1,pt,pd);
   end;
   if pt <> pte then begin
    error('dbuscallmethod() paramtypes and params count do not match');
    goto errorlab;
   end;
   m2:= dbus_connection_send_with_reply_and_block(conn,m1,timeout,err);
   if m2 = nil then begin
    checkok();
   end
   else begin
//    if dbus_message_iter_init(m2,@iter1) = 0 then begin
//     outofmemory();
//     goto errorlab1;
//    end;
    dbus_message_iter_init(m2,@iter1);
    pt:= @resulttypes[0];
    pte:= pt + length(resulttypes);
    pd:= @results[0];
    pde:= pd + length(results);
    while pd < pde do begin
     if not readvalue(iter1,pt,pd) then begin
      goto errorlab1;
     end;
    end;
    if dbus_message_iter_get_arg_type(@iter1) <> DBUS_TYPE_INVALID then begin
     error('dbuscallmethod() wrong returned param count');
     goto errorlab1;
    end;
    if pt <> pte then begin
     error('dbuscallmethod() resulttypes and results count do not match');
     goto errorlab1;
    end;
errorlab1:
    dbus_message_unref(m2);
   end;
errorlab:
   dbus_message_unref(m1);
  end;
 end;
end;
*)
(*
function dbuscallmethod(const bus_name,path,iface,method: string;
               const params: array of const;
               const resulttypes: array of dbusdataty;
               const results: array of pointer; 
               const timeout: int32 = -1): boolean; //true if ok
var
 m1,m2: pdbusmessage;
 iter1: dbusmessageiter;
 i1,i2: int32;
 do1: double;
 p1: pointer;
 pc1: pchar;
 dbuty: dbusdataty;
 s1: string;
 bool1: dbus_bool_t;
 isstring: boolean;
label
 errorlab,errorlab1;
begin
 result:= false;
 if high(resulttypes) <> high(results) then begin
  error('dbuscallmethod() resulttypes and results count must be equal');
  exit;
 end;
 if checkconnect() then begin
  m1:= dbus_message_new_method_call(pointer(bus_name),pchar(path),
                                               pointer(iface),pchar(method));
  if m1 = nil then begin
   outofmemory();
   exit;
  end
  else begin
   dbus_message_iter_init_append(m1,@iter1);
   for i1:= 0 to high(params) do begin
    with tvarrec(params[i1]) do begin
     case vtype of
      vtInteger: begin 
       dbuty:= dbt_int32;
       p1:= @vinteger;
      end;
      vtBoolean: begin 
       dbuty:= dbt_boolean;
       i2:= 0;
       if vboolean then begin
        i2:= 1;
       end;
       p1:= @i2;
      end;
      vtChar: begin 
       dbuty:= dbt_byte;
       p1:= @vchar;
      end;
      vtExtended: begin 
       dbuty:= dbt_double;
       do1:= vextended^;
       p1:= @do1;
      end;
      vtString: begin 
       dbuty:= dbt_string;
       if vstring^ = '' then begin
        pc1:= pchar('')
       end
       else begin
        pc1:= @vstring^[1];
       end;
       p1:= @pc1;
      end;
//      vtPointer
      vtPChar: begin 
       dbuty:= dbt_string;
       p1:= @vpchar;
      end;
//      vtObject
//      vtClass
      vtWideChar: begin 
       dbuty:= dbt_string;
       s1:= stringtoutf8(vwidechar);
       p1:= pchar(s1);
      end;
      vtPWideChar: begin 
       dbuty:= dbt_string;
       s1:= stringtoutf8(vpwidechar);
       pc1:= pchar(s1); 
       p1:= @pc1;
      end;
      vtAnsiString: begin 
       dbuty:= dbt_string;
       pc1:= pchar(string(vansistring));
       p1:= @pc1;
      end;
      vtCurrency: begin 
       dbuty:= dbt_double;
       do1:= vcurrency^;
       p1:= @do1;
      end;
//      vtVariant
//      vtInterface
      vtWideString: begin 
       dbuty:= dbt_string;
       s1:= stringtoutf8(widestring(vwidestring));
       pc1:= pchar(s1);
       p1:= @pc1;
      end;
      vtInt64: begin 
       dbuty:= dbt_int64;
       p1:= vint64;
      end;
      vtQWord: begin 
       dbuty:= dbt_uint64;
       p1:= vqword;
      end;
      vtUnicodeString: begin 
       dbuty:= dbt_string;
       s1:= stringtoutf8(unicodestring(vunicodestring));
       pc1:= pchar(s1);
       p1:= @pc1;
      end;
      else begin
       error('dbuscallmethod() invalid parameter');
       goto errorlab;
      end;
     end;
    end;
    if dbus_message_iter_append_basic(@iter1,
                                   dbusdatacodes[dbuty],p1) = 0 then begin
     outofmemory();
     goto errorlab;
    end;
   end;
   m2:= dbus_connection_send_with_reply_and_block(conn,m1,timeout,err);
   if m2 = nil then begin
    checkok();
   end
   else begin
    if dbus_message_iter_init(m2,@iter1) <> 0 then begin
     i1:= 0;
     while true do begin
      i2:= dbus_message_iter_get_arg_type(@iter1);
      if i2 = DBUS_TYPE_INVALID then begin
       result:= i1 = length(results);
       if not result then begin
        error('dbuscallmethod() returned param count:'+inttostr(i1)+
                                  ' expected:'+inttostr(length(results)));
       end;
       break;
      end;
      if i1 > high(results) then begin
       error('dbuscallmethod() wrong returned param count');
       goto errorlab1;
      end;
      if i2 <> dbusdatacodes[resulttypes[i1]] then begin
       error('dbuscallmethod() returned param does not match:'+inttostr(i2)+
                ' expected:'+inttostr(dbusdatacodes[resulttypes[i1]]));
       goto errorlab1;
      end;
      isstring:= false;
      p1:= results[i1];
      case i2 of
//       DBUS_TYPE_INVALID,
       DBUS_TYPE_BYTE: begin
        p1:= @bool1;
       end;
       DBUS_TYPE_BOOLEAN: begin
       end;
       DBUS_TYPE_INT16: begin
       end;
       DBUS_TYPE_UINT16: begin
       end;
       DBUS_TYPE_INT32: begin
       end;
       DBUS_TYPE_UINT32: begin
       end;
       DBUS_TYPE_INT64: begin
       end;
       DBUS_TYPE_UINT64: begin
       end;
       DBUS_TYPE_DOUBLE: begin
       end;
       DBUS_TYPE_STRING,DBUS_TYPE_OBJECT_PATH,DBUS_TYPE_SIGNATURE: begin
        isstring:= true;
        p1:= @pc1;
       end;
       
//       DBUS_TYPE_UNIX_FD,
//       DBUS_TYPE_ARRAY,
//       DBUS_TYPE_VARIANT,
//       DBUS_TYPE_STRUCT,
//       DBUS_TYPE_DICT_ENTRY
       else begin
        error('dbuscallmethod() invalid returned value');
        goto errorlab1;
       end;     
      end;
      dbus_message_iter_get_basic(@iter1,p1);
      p1:= results[i1];
      if isstring then begin
       if pc1 = nil then begin
        pansistring(p1)^:= '';
       end
       else begin
        pansistring(p1)^:= ansistring(pc1);
       end;
      end
      else begin
       if i1 = DBUS_TYPE_BYTE then begin
        pboolean(p1)^:= bool1 <> 0;
       end;
      end;
      dbus_message_iter_next(@iter1);
      inc(i1);
     end;
    end;
errorlab1:
    dbus_message_unref(m2);
   end;
errorlab:
   dbus_message_unref(m1);
  end;
 end;
end;
*)

function addwatch(watch: pDBusWatch; data: pointer): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 result:= tdbuscontroller(data).doaddwatch(watch);
end;

procedure watchtoggled(watch: pDBusWatch; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 tdbuscontroller(data).dowatchtoggled(watch);
end;

procedure removewatch(watch: pDBusWatch; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 tdbuscontroller(data).doremovewatch(watch);
end;
(*
procedure freewatch(memory: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 if memory <> nil then begin
  freemem(memory);
 end;
end;
*)
function addtimeout(timeout: pDBusTimeout; data: pointer): dbus_bool_t
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 result:= tdbuscontroller(data).doaddtimeout(timeout);
end;

procedure timeouttoggled(timeout: pDBusTimeout; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 tdbuscontroller(data).dotimeouttoggled(timeout);
end;

procedure removetimeout(timeout: pDBusTimeout; data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 tdbuscontroller(data).doremovetimeout(timeout);
end;
(*
procedure freetimeout(memory: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 tsimpletimer(memory).free();
end;
*)
procedure pendingcallback(pending: pDBusPendingCall; user_data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 if fdbc <> nil then begin
  fdbc.dopendingcallback(pending,user_data);
 end;
end;
(*
procedure freependingcallback(memory: pointer);
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 if fdbc <> nil then begin
  fdbc.dofreependingcallback(memory);
 end;
end;
*)
procedure pollcallback(const aflags: pollflagsty; const adata: pointer);
begin
 if fdbc <> nil then begin
  fdbc.fitems.dopollcallback(aflags,adata);
 end;
end;

{ tdbusitemhashdatalist }

constructor tdbusitemhashdatalist.create();
begin
 inherited create(sizeof(dbusitemty));
 include(fstate,hls_needsfinalize);
end;

function tdbusitemhashdatalist.addwatch(const key: pdbuswatch): pwatchinfoty;
var
 p1: pdbusinfoty;
begin
 p1:= add(key);
 p1^.kind:= dbk_watch;
 result:= @p1^.watch;
 result^.flags:= [];
 result^.watch:= key;
 additem(fwatches,getdataoffset(result));
end;

function tdbusitemhashdatalist.addlink(const alink: ievent): plinkinfoty;
var
 p1: pdbusinfoty;
begin
 p1:= add(alink);
 p1^.kind:= dbk_link;
 result:= @p1^.link;
 result^.link:= alink;
 alink.link(iobjectlink(pchar(alink)+1),iobjectlink(self));
                      //create backlink
end;

procedure tdbusitemhashdatalist.finalizeitem(var aitemdata);
begin
 with dbusitemty(aitemdata) do begin
  case data.kind of
   dbk_watch: begin
    gui_removepollfd(data.watch.id);
    removeitem(integerarty(fwatches),getdataoffset(@data.watch));
   end;
   dbk_timeout: begin
    data.timeout.timer.free;
   end;
   dbk_link: begin
    if not funlinking then begin
     data.link.link.unlink(iobjectlink(pchar(iobjectlink(self))+1),
                                                          data.link.link);
                       //remove backlink
    end;
   end;
  end;
 end;
end;

procedure tdbusitemhashdatalist.dopollcallback(const aflags: pollflagsty;
               const adata: pointer);
var
 p1: pdbusinfoty;
begin
 p1:= find(adata);
 if (p1 <> nil) and (p1^.kind = dbk_watch) then begin //throw no exception
  p1^.watch.flags:= p1^.watch.flags + aflags;
 end;
end;

function tdbusitemhashdatalist.findwatch(const key: pdbuswatch): pwatchinfoty;
begin
 result:= find(key);
 if result = nil then begin
  raiseerror('Watch not found');
 end;
 if pdbusinfoty(pointer(result))^.kind <> dbk_watch then begin
  raiseerror('Invalid watch');
 end;
 result:= @pdbusinfoty(pointer(result))^.watch;
end;

function tdbusitemhashdatalist.findtimeout(
              const key: pdbustimeout): ptimeoutinfoty;
begin
 result:= find(key);
 if result = nil then begin
  raiseerror('Timeout not found');
 end;
 if pdbusinfoty(pointer(result))^.kind <> dbk_timeout then begin
  raiseerror('Invalid timeout');
 end;
 result:= @pdbusinfoty(pointer(result))^.timeout;
end;

function tdbusitemhashdatalist.findpending(
                              const key: pdbuspendingcall): ppendinginfoty;
begin
 result:= find(key);
 if result = nil then begin
  raiseerror('Pendingcall not found');
 end;
 if pdbusinfoty(pointer(result))^.kind <> dbk_pending then begin
  raiseerror('Invalid pendingcall');
 end;
 result:= @pdbusinfoty(pointer(result))^.pending;
end;

procedure tdbusitemhashdatalist.link(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
begin
 //dummy
end;

procedure tdbusitemhashdatalist.unlink(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil);
begin
 if not odd(ptruint(source)) then begin //full link
  delete(source);
 end;
end;

procedure tdbusitemhashdatalist.objevent(const sender: iobjectlink;
               const event: objecteventty);
begin
 if event = oe_destroyed then begin
  funlinking:= true;
  delete(sender);
  funlinking:= false;
 end;
end;

function tdbusitemhashdatalist.getinstance: tobject;
begin
 result:= self;
end;

{
function tdbusitemhashdatalist.addpending(
                          const aitem: pdbuspendingcall): ppendinginfoty;
begin
end;
}
{
procedure tdbusitemhashdatalist.freeitems();
var
 i1: int32;
 p1: pdbusitemty;
begin
 last();
 for i1:= 0 to count-1 do begin
  p1:= pointer(next());
 end;
end;
}
const
 watchflags: array[pollflagty] of card32 = (
  DBUS_WATCH_READABLE, //pf_in,  //POLLIN =   $001;
  0,                   //pf_pri, //POLLPRI =  $002;
  DBUS_WATCH_WRITABLE, //pf_out, //POLLOUT =  $004;
  DBUS_WATCH_ERROR,    //pf_err, //POLLERR =  $008;
  DBUS_WATCH_HANGUP,   //pf_hup, //POLLHUP =  $010;
  0                    //pf_nval //POLLNVAL = $020;
 );
 
procedure tdbusitemhashdatalist.handlewatches();
var
 i1: int32;
 c1: card32;
 f1: pollflagty;
begin
 for i1:= 0 to high(fwatches) do begin
  with pwatchinfoty(getdatapo(fwatches[i1]))^ do begin
   if flags <> [] then begin
    c1:= 0;
    for f1:= low(f1) to high(f1) do begin
     if f1 in flags then begin
      c1:= c1 or watchflags[f1];
     end;
    end;
    dbus_watch_handle(watch,c1);
   end;
  end;
 end; 
end;

{ tdbuscontroller }

constructor tdbuscontroller.create();
begin
 fitems:= tdbusitemhashdatalist.create();
 inherited;
end;

destructor tdbuscontroller.destroy();
begin
 disconnect();
 inherited;
 fitems.free();
end;

function tdbuscontroller.connected: boolean;
begin
 result:= fconn <> nil;
end;

function tdbuscontroller.dbuscallmethod(const returnedto: ievent;
               const bus_name: string; const path: string; const iface: string;
               const method: string; const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean;
var
 m1,m2: pdbusmessage;
 pte: pdbusdataty;
 pde: ppointer;

 function writevalue(var iter: dbusmessageiter;
                             var pt: pdbusdataty; var pd: ppointer): boolean;
 var
  p1,pe: pointer;
  p2: ppointer;
  p3: pdbusdataty;
  bool1: dbus_bool_t;
  pc1: pcchar;
  iter2: dbusmessageiter;
  i1,i2: int32;
 label
  oklab;
 begin
  result:= false;
  if pt >= pte then begin
   error('dbuscallmethod() paramtypes and params count do not match');
   exit;
  end;
  p1:= pd^;
  case pt^ of
// dbt_INVALID,
   dbt_BYTE: begin
    p1:= @bool1;
    bool1:= 0;
    if pboolean(pd)^ then begin
     bool1:= 1;
    end;
   end;
   dbt_BOOLEAN: begin
   end;
   dbt_INT16: begin
   end;
   dbt_UINT16: begin
   end;
   dbt_INT32: begin
   end;
   dbt_UINT32: begin
   end;
   dbt_INT64: begin
   end;
   dbt_UINT64: begin
   end;
   dbt_DOUBLE: begin
   end;
   dbt_STRING,dbt_OBJECT_PATH,dbt_SIGNATURE: begin
    p1:= @pc1;
    pc1:= pchar(pansistring(pd^)^);
   end;
   
// dbt_UNIX_FD,
   dbt_ARRAY: begin
    inc(pt);
    if pt >= pte then begin
     error('dbuscallmethod() paramtypes and params count do not match');
     exit;
    end;
    p1:= pd^; //pointer to var
    i1:= datasizes[pt^];
    if i1 = 0 then begin
     error('dbuscallmethod() array item type not yet supported');
     exit;
    end;
    if dbus_message_iter_open_container(@iter,dbusdatacodes[dbt_array],
                          pchar(dbusdatastrings[pt^]),@iter2) = 0 then begin
                     //todo: construct valid signature for nested container
     outofmemory();
     exit;
    end;
    p1:= ppointer(p1)^; //dynamic array
    i2:= dynarraylength(p1);
    if p1 <> nil then begin
     pe:= p1 + i1 * i2;
     while p1 < pe do begin
      p2:= @p1; //restore
      p3:= pt;  //restore
      if not writevalue(iter2,p3,p2) then begin
       dbus_message_iter_abandon_container(@iter,@iter2);
       exit;
      end;
      inc(p1,i1);
     end;
    end;
    if dbus_message_iter_close_container(@iter,@iter2) = 0 then begin
     outofmemory();
     exit;
    end;
    goto oklab;
   end;
// dbt_VARIANT,
// dbt_STRUCT,
// dbt_DICT_ENTRY
   else begin
    result:= false;
    error('dbuscallmethod() paramtype not yet supported');
    exit;
   end;
  end;

  if dbus_message_iter_append_basic(@iter,
                                 dbusdatacodes[pt^],p1) = 0 then begin
   outofmemory();
   exit;
  end;
 oklab:
  inc(pt);
  inc(pd);
  result:= true;
 end;//writevalue

var
 iter1: dbusmessageiter;
// iter2: dbusmessageiter;
 i1,i2: int32;
 do1: double;
 p1: pointer;
 pc1: pchar;
 dbuty: dbusdataty;
 s1: string;
 bool1: dbus_bool_t;
 isstring: boolean;
 pt: pdbusdataty;
 pd: ppointer;
 pend1: pdbuspendingcall;
 pendinfo1: ppendinginfoty;
 
label
 errorlab;
begin
 result:= false;
 if checkconnect() then begin
  m1:= dbus_message_new_method_call(pointer(bus_name),pchar(path),
                                               pointer(iface),pchar(method));
  if m1 = nil then begin
   outofmemory();
   exit;
  end
  else begin
   dbus_message_iter_init_append(m1,@iter1);
   pt:= @paramtypes[0];
   pte:= pt + length(paramtypes);
   pd:= @params[0];
   pde:= pd + length(params);
   while pd < pde do begin
    writevalue(iter1,pt,pd);
   end;
   if pt <> pte then begin
    error('dbuscallmethod() paramtypes and params count do not match');
    goto errorlab;
   end;
   result:= dbus_connection_send_with_reply(fconn,m1,@pend1,timeout) <> 0;
   fitems.addlink(returnedto);
//fitems.delete(returnedto);
   if not result then begin
    outofmemory();
    goto errorlab;
   end;
   addpending(pend1);
//   getmem(pendinfo1,sizeof(pendinfoty));
//   additem(pointerarty(fpendings),pendinfo1);
//   pendinfo1^.pending:= pend1;
   dbus_pending_call_set_notify(pend1,@pendingcallback,nil,nil);
   
errorlab:
   dbus_message_unref(m1);
  end;
 end;
end;

function tdbuscontroller.connect: boolean;
var
 i1,i2: int32;
 s1,s2: string;
begin
 if fconn <> nil then begin
  result:= true;
 end;
 result:= false;
 try
  initializedbus([]);
  dbus_error_init(@ferr);
  fconn:= dbus_bus_get_private(dbus_bus_session,err);
  if fconn = nil then begin
   checkok();
  end
  else begin
   dbus_connection_set_exit_on_disconnect(fconn,0);
   fbusid:= dbus_bus_get_unique_name(fconn);
   s1:= msebusname+'-'+inttostr(sys_getpid())+'-';
   i1:= 0;
   repeat
    s2:= s1+inttostr(i1);
    i2:= dbus_bus_request_name(fconn,pchar(s2),
                                 DBUS_NAME_FLAG_DO_NOT_QUEUE,err());
    inc(i1);
    if (i1 > 100) or (i2 < 0)  then begin
     disconnect();
     exit;
    end;
   until (i2 = DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER) or
           (i2 = DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER); //should not happen
   fbusname:= s2;

    //start asynchronous message handling
   dbus_connection_set_watch_functions(fconn,@addwatch,@removewatch,
                                       @watchtoggled,self,nil);
   dbus_connection_set_timeout_functions(fconn,@addtimeout,@removetimeout,
                                         @timeouttoggled,self,nil);
   application.registeronidle(@doidle);
   result:= true;
  end;
 except
  on e: exception do begin
   dbuslasterror:= e.message;
  end;
 end;
end;

procedure tdbuscontroller.disconnect();
var
 i1: int32;
begin
 if fconn <> nil then begin
  dbus_connection_close(fconn);
  fitems.clear();
{
  while true do begin
   i1:= high(fpendings);
   if i1 < 0 then begin
    break;
   end;
   dbus_pending_call_unref(fpendings[i1]^.pending);
  end;
}
  if not applicationdestroyed() then  begin
   application.unregisteronidle(@doidle);
  end;
  err(); //free ferr
  dbus_shutdown();
//  dbus_connection_close(fconn);
  fconn:= nil;
  fbusid:= '';
  fbusname:= '';
  releasedbus();
 end;
end;

function tdbuscontroller.doaddwatch(const awatch: pdbuswatch): int32;
var
 i1,i2: int32;
 fla1: pollflagsty;
 p1: pwatchinfoty;
begin
 result:= 0;
 i2:= dbus_watch_get_unix_fd(awatch);
 if i2 > 0 then begin
  fla1:= [];
  i1:= dbus_watch_get_flags(awatch);
  if i1 and DBUS_WATCH_READABLE <> 0 then begin
   include(fla1,pf_in);
  end;
  if i1 and DBUS_WATCH_WRITABLE <> 0 then begin
   include(fla1,pf_out);
  end;
  p1:= fitems.addwatch(awatch);
  gui_addpollfd(p1^.id,i2,fla1,@pollcallback,awatch);
  updatewatch(awatch);
  result:= 1;
 end;
end;

procedure tdbuscontroller.updatewatch(const awatch: pdbuswatch);
begin
 with fitems.findwatch(awatch)^ do begin
  gui_setpollfdactive(id,dbus_watch_get_enabled(awatch) <> 0);
 end;
end;

procedure tdbuscontroller.dowatchtoggled(const awatch: pdbuswatch);
begin
 updatewatch(awatch);
end;

procedure tdbuscontroller.doremovewatch(const awatch: pdbuswatch);
//var
// p1: pwatchinfoty;
begin
 fitems.delete(awatch);
{
 p1:= dbus_watch_get_data(awatch);
 gui_removepollfd(p1^.id);
 removeitem(pointerarty(fwatches),p1);
}
end;

procedure tdbuscontroller.updatetimeout(const atimeout: pdbustimeout);
var
 i1: int32;
 b1: boolean;
begin
 with fitems.findtimeout(atimeout)^.timer do begin
  b1:= dbus_timeout_get_enabled(atimeout) <> 0;
  i1:= dbus_timeout_get_interval(atimeout)*1000;
  if b1 then begin
   if i1 <> interval then begin
    interval:= i1;
    enabled:= true;
   end;
  end
  else begin
   enabled:= false;
   interval:= i1;
  end;
 end;
end;

function tdbuscontroller.doaddtimeout(const atimeout: pdbustimeout): int32;
var
 meth1: notifyeventty;
begin
 meth1:= @dotimer;
 tmethod(meth1).data:= atimeout;
 with pdbusinfoty(fitems.add(atimeout))^ do begin
  kind:= dbk_timeout;
  with timeout do begin
   timer:= tsimpletimer.create(0,meth1);
  end;
 end;
// dbus_timeout_set_data(atimeout,ti1,@freetimeout);
 updatetimeout(atimeout);
 result:= 1;
end;

procedure tdbuscontroller.dotimeouttoggled(const atimeout: pdbustimeout);
begin
 updatetimeout(atimeout);
end;

procedure tdbuscontroller.doremovetimeout(const atimeout: pdbustimeout);
begin
 fitems.delete(atimeout);
end;

procedure tdbuscontroller.dotimer(const sender: tobject);
var
 timeout1: pdbustimeout;
begin
 timeout1:= pdbustimeout(pointer(self));
 dbus_timeout_handle(timeout1);
end;

function tdbuscontroller.err(): pdbuserror;
begin
 if dbus_error_is_set(@ferr) <> 0 then begin
  dbus_error_free(@ferr);
 end;
 result:= @ferr;
end;

function tdbuscontroller.checkok(): boolean;
begin
 result:= dbus_error_is_set(@ferr) = 0;
 if not result then begin
  dbuslasterror:= ferr.message;
 end;
end;

procedure tdbuscontroller.doidle(var again: boolean);
begin
 if fconn <> nil then begin
  fitems.handlewatches();
  repeat
  until dbus_connection_dispatch(fconn) <> DBUS_DISPATCH_DATA_REMAINS;
  dbus_connection_flush(fconn);
 end;
end;

procedure tdbuscontroller.dopendingcallback(pending: pDBusPendingCall;
               user_data: pointer);
begin
end;

procedure tdbuscontroller.addpending(const apending: pdbuspendingcall);
begin
 with pdbusinfoty(fitems.add(apending))^ do begin
  kind:= dbk_pending;
  with pending do begin
  end;
 end;
end;

{
procedure tdbuscontroller.dofreependingcallback(memory: pointer);
begin
 removeitem(pointerarty(fpendings),memory);
 freemem(memory);
end;
}
initialization
 arraytypes[dbt_INVALID]:= nil;
 arraytypes[dbt_BYTE]:= typeinfo(bytearty);
 arraytypes[dbt_BOOLEAN]:= typeinfo(booleanarty);
 arraytypes[dbt_INT16]:= typeinfo(int16arty);
 arraytypes[dbt_UINT16]:= typeinfo(card16arty);
 arraytypes[dbt_INT32]:= typeinfo(int32arty);
 arraytypes[dbt_UINT32]:= typeinfo(card32arty);
 arraytypes[dbt_INT64]:= typeinfo(int64arty);
 arraytypes[dbt_UINT64]:=  typeinfo(card64arty);
 arraytypes[dbt_DOUBLE]:= typeinfo(flo64arty);
 arraytypes[dbt_STRING]:= typeinfo(ansistringarty);
 arraytypes[dbt_OBJECT_PATH]:= typeinfo(ansistringarty);
 arraytypes[dbt_SIGNATURE]:= typeinfo(ansistringarty);
 arraytypes[dbt_UNIX_FD]:= nil;
 arraytypes[dbt_ARRAY]:= nil;
 arraytypes[dbt_VARIANT]:= nil;
 arraytypes[dbt_STRUCT]:= nil;
 arraytypes[dbt_DICT_ENTRY]:= nil;
finalization
 freeandnil(fdbc);
end.
