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

 idbusclient = interface(iobjectlink)
 end;
 idbusresponse = interface(idbusclient)
  procedure replyed(const serial: card32; const amessage: pdbusmessage);
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
 
type
 messageeventty = procedure(const amessage: pdbusmessage; var handled: boolean) of object;
 
 idbuscontroller = interface;
 idbusobject = interface(inullinterface)
  function getinstance: tobject;
  procedure registeritems(const sender: idbuscontroller);
  function getpath(): string;
//  procedure unregisteritems(const sender: idbuscontroller);
 end;
 idbuscontroller = interface(inullinterface)
  procedure registerobject(const sender: idbusobject);
  procedure unregisterobject(const sender: idbusobject);
  procedure registeritem(const apath: string; const ahandler: messageeventty);
 end;
 
 tdbusobject = class(tobject,idbusobject)
  protected
   fcontroller: idbuscontroller;
    //idbusobject
   function getinstance(): tobject;
   procedure registeritems(const sender: idbuscontroller) virtual;
   function getpath(): string virtual;
//   procedure unregisteritems(const sender: idbuscontroller) virtual;
  public
   constructor create(const acontroller: idbuscontroller = nil);
   destructor destroy(); override;
 end;
  
var
 dbuslasterror: string;
 
function dbusconnect(): boolean; //true if ok
procedure dbusdisconnect();
function dbusid(): string;
function dbusname(): string;

function dbuscallmethod(const returnedto: idbusresponse; var serial: card32;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok
function dbusreadmessage(const amessage: pdbusmessage;
               const resulttypes: array of dbusdataty;
               const results: array of pointer): boolean; //true if ok
function dbuscallmethod(const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const resulttypes: array of dbusdataty;
               const results: array of pointer;
               const timeout: int32 = -1): boolean; //blocking, true if ok
               
{$ifdef mse_dumpdbus}
function dbusdumpmessage(const amessage: pdbusmessage): string;
{$endif}

implementation
uses
 msestrings,msesysintf,msearrayutils,msesys,mseguiintf,msetimer,
 msefloattostr,mseapplication;

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
  serial: card32;
  link: idbusresponse;
 end;
 ppendinginfoty = ^pendinginfoty;

 linkinfoty = record
  link: idbusclient;
  pending: pdbuspendingcall;
 end;
 plinkinfoty = ^linkinfoty;
 
 objinfoty = record
  obj: idbusobject;
  path: pointer; //string
  items: pointer; //stringarty
 end;
 pobjinfoty = ^objinfoty;
 
 itemkindty = (dbk_watch,dbk_timeout,dbk_pending,dbk_link,dbk_obj);
 
 dbusinfoty = record
  case kind: itemkindty of
   dbk_watch: (watch: watchinfoty);
   dbk_timeout: (timeout: timeoutinfoty);
   dbk_pending: (pending: pendinginfoty);
   dbk_link: (link: linkinfoty);
   dbk_obj: (obj: objinfoty);
 end;
 pdbusinfoty = ^dbusinfoty;
 dbusitemty = record
  key: pointer;
  data: dbusinfoty;
 end;
 pdbusitemty = ^dbusitemty;

 tdbuscontroller = class;
 
 tdbusitemhashdatalist = class(tpointerhashdatalist,iobjectlink)
  private
   fwatches: card32arty;
   funlinking: boolean;
   fserial: card32;
  protected
   fowner: tdbuscontroller;
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
   constructor create(const aowner: tdbuscontroller);
   function addwatch(const key: pdbuswatch): pwatchinfoty;
   function addlink(const alink: idbusclient;
                            const apending: pdbuspendingcall): plinkinfoty;
   function addpending(const apending: pdbuspendingcall;
                               const alink: idbusresponse;
                               var aserial: card32): ppendinginfoty;
   function addobject(const aobj: idbusobject): pobjinfoty;
//   function addpending(const aitem: pdbuspendingcall): ppendinginfoty;
//   procedure freeitems();
   procedure handlewatches();
 end;
  
 tdbuscontroller = class(tobject,idbuscontroller)
  private
   fconn: pdbusconnection;
   ferr: dbuserror;
   fbusid: string;
   fbusname: string;
   fitems: tdbusitemhashdatalist;
   fregisteringobj: pobjinfoty;
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
   procedure raisedbuserror();
   procedure doidle(var again: boolean);
   procedure dopendingcallback(pending: pDBusPendingCall; user_data: pointer);
   function setupmessage(const bus_name,path,iface,method: string;
                             const paramtypes: array of dbusdataty;
                             const params: array of pointer): pdbusmessage;
   procedure dounregisterobj(const aobj: pobjinfoty);
   procedure doregisteritems(const aobj: pobjinfoty);
   procedure dounregisteritems(const aobj: pobjinfoty);
   procedure unregisteritem(const apath: string);
   procedure rootfallback(const amessage: pdbusmessage; var handled: boolean);
   procedure registerobjects();
   procedure unregisterobjects();
   procedure registerfallback(const apath: string; 
                                        const ahandler: messageeventty);
   
    //idbuscontroller
   procedure registerobject(const sender: idbusobject);
   procedure unregisterobject(const sender: idbusobject);
   procedure registeritem(const apath: string; const ahandler: messageeventty);
  public
   constructor create();
   destructor destroy(); override;
   function connected: boolean;
   function dbuscallmethod(const returnedto: idbusresponse; var aserial: card32;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok
   function dbuscallmethod(const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const resulttypes: array of dbusdataty;
               const results: array of pointer;
               const timeout: int32 = -1): boolean; //blocking, true if ok
   function readmessage(const amessage: pdbusmessage;
               const resulttypes: array of dbusdataty;
               const results: array of pointer): boolean;
                                  //true if ok
 end;
 
var
// conn: pdbusconnection;
// ferr: dbuserror;
// busid: string;
// busname: string;
 fdbc: tdbuscontroller;
 dbuslibinited: boolean;
 
procedure initdbuslib();
begin
 if not dbuslibinited then begin
  initializedbus([]);
  dbuslibinited:= true;
 end;
end;

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

function dbuscontroller(): tdbuscontroller;
begin
 if fdbc = nil then begin
  fdbc:= tdbuscontroller.create;
 end;
 result:= fdbc;
end;

function dbusconnect(): boolean; //true if ok
begin
 result:= dbuscontroller.connect();
end;

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

function dbuscallmethod(const returnedto: idbusresponse; var serial: card32;
               const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean; //true if ok
begin
 result:= false;
 if checkconnect() then begin
  result:= fdbc.dbuscallmethod(returnedto,serial,bus_name,path,iface,method,
                                            paramtypes,params,timeout);
 end;
end;

{$ifdef mse_dumpdbus}
function dbusdumpmessage(const amessage: pdbusmessage): string;
var
 level: int32;
 
 function nilstr(const astr: pcchar): string;
 begin
  if astr = nil then begin
   result:= 'NIL';
  end
  else begin
   result:= string(astr);
  end;
 end; //nilstr
 
 function dumptype(const t: int32): string;
 begin
  case t of
   DBUS_TYPE_INVALID: result:= '';
   DBUS_TYPE_BYTE: result:= 'BYTE';
   DBUS_TYPE_BOOLEAN: result:= 'BOOLEAN';
   DBUS_TYPE_INT16: result:= 'INT16';
   DBUS_TYPE_UINT16: result:= 'UINT16';
   DBUS_TYPE_INT32: result:= 'INT32';
   DBUS_TYPE_UINT32: result:= 'UINT32';
   DBUS_TYPE_INT64: result:= 'INT64';
   DBUS_TYPE_UINT64: result:= 'UINT64';
   DBUS_TYPE_DOUBLE: result:= 'DOUBLE';
   DBUS_TYPE_STRING: result:= 'STRING';
   DBUS_TYPE_OBJECT_PATH: result:= 'OBJECT_PATH';
   DBUS_TYPE_SIGNATURE: result:= 'SIGNATURE';
   DBUS_TYPE_UNIX_FD: result:= 'UNIX_FD';
   DBUS_TYPE_ARRAY: result:= 'ARRAY';
   DBUS_TYPE_VARIANT: result:= 'VARIANT';
   DBUS_TYPE_STRUCT: result:= 'STRUCT';
   DBUS_TYPE_DICT_ENTRY: result:= 'DICT_ENTRY';
  end;
 end;

 function dumpdata(const t: int32; iterpo: pdbusmessageiter): string;
 var
  b1: byte;
  bool1: dbus_bool_t;
  i16: int16;
  c16: card16;
  i32: int32;
  c32: card32;
  i64: int64;
  c64: card64;
  f64: flo64;
  pc1: pcchar;
  
 begin
  result:= '';
  case t of
   DBUS_TYPE_INVALID: begin end;
   DBUS_TYPE_BYTE: begin
    dbus_message_iter_get_basic(iterpo,@b1);
    result:= inttostr(b1);
   end;
   DBUS_TYPE_BOOLEAN: begin
    dbus_message_iter_get_basic(iterpo,@bool1);
    result:= inttostr(bool1);
   end;
   DBUS_TYPE_INT16: begin;
    dbus_message_iter_get_basic(iterpo,@i16);
    result:= inttostr(i16);
   end; 
   DBUS_TYPE_UINT16: begin
    dbus_message_iter_get_basic(iterpo,@c16);
    result:= inttostr(c16);
   end;
   DBUS_TYPE_INT32: begin
    dbus_message_iter_get_basic(iterpo,@i32);
    result:= inttostr(i32);
   end;
   DBUS_TYPE_UINT32: begin
    dbus_message_iter_get_basic(iterpo,@c32);
    result:= inttostr(c32);
   end;
   DBUS_TYPE_INT64: begin
    dbus_message_iter_get_basic(iterpo,@i64);
    result:= inttostr(i64);
   end;
   DBUS_TYPE_UINT64: begin
    dbus_message_iter_get_basic(iterpo,@c64);
    result:= inttostr(c64);
   end;
   DBUS_TYPE_DOUBLE: begin
    dbus_message_iter_get_basic(iterpo,@f64);
    result:= string(doubletostring(f64,-1));
   end;
   DBUS_TYPE_STRING,
   DBUS_TYPE_OBJECT_PATH,
   DBUS_TYPE_SIGNATURE: begin
    dbus_message_iter_get_basic(iterpo,@pc1);
    result:= '"'+string(pc1)+'"';
   end;
   DBUS_TYPE_UNIX_FD: begin end;
   DBUS_TYPE_ARRAY:  begin end;
   DBUS_TYPE_VARIANT:  begin end;
   DBUS_TYPE_STRUCT:  begin end;
   DBUS_TYPE_DICT_ENTRY:  begin end;
  end;
 end;
 
 function readvalue(var aiter: dbusmessageiter): string;
 var
  i1,i2: int32;
  iter2,iter3: dbusmessageiter;
  iterpo: pdbusmessageiter;
  first: boolean;
  s1,s2: string;
 label
  endlab;  
 begin
  inc(level);
  s2:= charstring(' ',level);
  result:= s2;
  iterpo:= @aiter;
  i1:= dbus_message_iter_get_arg_type(iterpo);
  if i1 = DBUS_TYPE_INVALID then begin
   goto endlab;
  end;
  if i1 = DBUS_TYPE_VARIANT then begin
   dbus_message_iter_recurse(@aiter,@iter3);   
   iterpo:= @iter3;
   i1:= dbus_message_iter_get_arg_type(iterpo); //nested variants?
  end;
  case i1 of
   DBUS_TYPE_ARRAY: begin
    i2:= dbus_message_iter_get_element_type(iterpo);
    dbus_message_iter_recurse(iterpo,@iter2);
    result:= dumptype(i2)+'[';
    first:= true;
    while dbus_message_iter_get_arg_type(@iter2) <> DBUS_TYPE_INVALID do begin
     s1:= readvalue(iter2);
     if s1 = '' then begin
      if not first then begin
       setlength(result,length(result)-1); //remove last comma
      end;
      result:= result+']';
      break;
     end
     else begin
      result:= result+s1+',';
     end;
     first:= false;
    end;
   end; //array
// DBUS_TYPE_VARIANT, //todo
// DBUS_TYPE_STRUCT,
// DBUS_TYPE_DICT_ENTRY
   else begin
    result:= result+dumptype(i1)+' '+dumpdata(i1,iterpo);
   end;     
  end;
  dbus_message_iter_next(@aiter);
  
endlab:
  if result <> s2 then begin
   result:= result+lineend;
  end
  else begin
   result:= '';
  end;
 end;//readvalue

var
 iter1: dbusmessageiter;
 s1: string;

begin
 level:= 0;
 result:= '*';
 if amessage = nil then begin
  result:= result+'NIL';
 end
 else begin
  dbus_message_iter_init(amessage,@iter1);
  case dbus_message_get_type(amessage) of
   DBUS_MESSAGE_TYPE_INVALID: begin
    result:= result+'INVALID';
   end;
   DBUS_MESSAGE_TYPE_METHOD_CALL: begin
    result:= result+'METHODCALL';
   end;
   DBUS_MESSAGE_TYPE_METHOD_RETURN: begin
    result:= result+'METHOD_RETURN';
   end;
   DBUS_MESSAGE_TYPE_ERROR: begin
    result:= result+'ERROR';
   end;
   DBUS_MESSAGE_TYPE_SIGNAL: begin
    result:= result+'SIGNAL';
   end;
  end;
  result:= result+' '+nilstr(dbus_message_get_destination(amessage))+' '+
                      nilstr(dbus_message_get_path(amessage))+' '+
                      nilstr(dbus_message_get_interface(amessage))+' '+
                      nilstr(dbus_message_get_member(amessage))+' '+lineend;
  repeat
   s1:= readvalue(iter1);
   result:= result+s1;
  until s1 = '';
 end;
end;
{$endif} 

function dbusreadmessage(const amessage: pdbusmessage;
               const resulttypes: array of dbusdataty;
               const results: array of pointer): boolean; //true if ok
begin
 result:= false;
 if checkconnect() then begin
  result:= fdbc.readmessage(amessage,resulttypes,results);
 end;
end;

function dbuscallmethod(const bus_name,path,iface,method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const resulttypes: array of dbusdataty;
               const results: array of pointer;
               const timeout: int32 = -1): boolean; //blocking, true if ok
begin
 result:= false;
 if checkconnect() then begin
  result:= fdbc.dbuscallmethod(bus_name,path,iface,method,paramtypes,params,
                                            resulttypes,results,timeout);
 end;
end;

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

procedure pendingcallback(pending: pDBusPendingCall; user_data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 if fdbc <> nil then begin
{$ifdef mse_debugdbus}
  writeln('**pendingcallback');
{$endif}
  fdbc.dopendingcallback(pending,user_data);
 end;
end;

procedure pollcallback(const aflags: pollflagsty; const adata: pointer);
begin
 if fdbc <> nil then begin
  fdbc.fitems.dopollcallback(aflags,adata);
 end;
end;

{ tdbusitemhashdatalist }

constructor tdbusitemhashdatalist.create(const aowner: tdbuscontroller);
begin
 fowner:= aowner;
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
 additem(fwatches,getdataoffset(result));
 with result^ do begin
  flags:= [];
  watch:= key;
 end;
end;

function tdbusitemhashdatalist.addlink(const alink: idbusclient;
                            const apending: pdbuspendingcall): plinkinfoty;
var
 p1: pdbusinfoty;
begin
 p1:= add(alink);
 p1^.kind:= dbk_link;
 alink.link(iobjectlink(pchar(alink)+1),iobjectlink(self));
                      //create backlink
 result:= @p1^.link;
 with result^ do begin
  link:= alink;
  pending:= apending;
 end;
end;

function tdbusitemhashdatalist.addpending(const apending: pdbuspendingcall;
                const alink: idbusresponse;
                               var aserial: card32): ppendinginfoty;
var
 p1: pdbusinfoty;
begin
 p1:= add(apending);
 p1^.kind:= dbk_pending;
 result:= @p1^.pending;
 with result^ do begin
  pending:= apending;
  link:= alink;
  inc(fserial);
  if fserial = 0 then begin
   inc(fserial);
  end;
  serial:= fserial;
  aserial:= serial;
 end;
end;

function tdbusitemhashdatalist.addobject(
                                 const aobj: idbusobject): pobjinfoty;
var
 p1: pdbusinfoty;
begin
 p1:= add(aobj);
 p1^.kind:= dbk_obj;
 result:= @p1^.obj;
 with result^ do begin
  obj:= aobj;
  path:= nil;
  items:= nil;
 end;
end;

procedure tdbusitemhashdatalist.finalizeitem(var aitemdata);
var
 p1: pdbusinfoty;
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
    if data.link.pending <> nil then begin
     p1:= find(data.link.pending);
     if (p1 <> nil) and (p1^.kind = dbk_pending) then begin
      p1^.pending.link:= nil;
     end;
    end;
   end;
   dbk_pending: begin
    if data.pending.link <> nil then begin
     p1:= find(data.pending.link);
     if (p1 <> nil) and (p1^.kind = dbk_link) then begin
      p1^.link.pending:= nil;
     end;
    end;
   end;
   dbk_obj: begin
    fowner.dounregisterobj(@data.obj);
    with data.obj do begin
     string(path):= '';
     stringarty(items):= nil;
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
{$ifdef mse_debugdbus}
  if p1^.watch.flags <> aflags then begin
   writeln('**dopollcallback:',int32(aflags));
  end;
{$endif}
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
 fitems:= tdbusitemhashdatalist.create(self);
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

function tdbuscontroller.setupmessage(const bus_name,path,iface,method: string;
                             const paramtypes: array of dbusdataty;
                             const params: array of pointer): pdbusmessage;

var
 pte: pdbusdataty;
 m1: pdbusmessage;

 
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
 pde: ppointer;
 iter1: dbusmessageiter;
 pt: pdbusdataty;
 pd: ppointer;

label
 errorlab,oklab;

begin
 m1:= dbus_message_new_method_call(pointer(bus_name),pchar(path),
                                              pointer(iface),pchar(method));
 if m1 = nil then begin
  outofmemory();
 end
 else begin
  dbus_message_iter_init_append(m1,@iter1);
  pt:= @paramtypes[0];
  pte:= pt + length(paramtypes);
  pd:= @params[0];
  pde:= pd + length(params);
  while pd < pde do begin
   if not writevalue(iter1,pt,pd) then begin
    goto errorlab;
   end;
  end;
  goto oklab;
  if pt <> pte then begin
   error('dbuscallmethod() paramtypes and params count do not match');
   goto errorlab;
  end;
errorlab:
  dbus_message_unref(m1);
  m1:= nil;
 end;
oklab:
 result:= m1;
end;

type
 callbackinfoty = record
  handler: messageeventty;
 end;
 pcallbackinfoty = ^callbackinfoty;

function objectpathhandlertrampoline(connection: pDBusConnection;
       message: pDBusMessage; user_data: pointer): DBusHandlerResult
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
var
 b1: boolean;
begin
 with pcallbackinfoty(user_data)^ do begin
  b1:= false;
  handler(message,b1);
  if b1 then begin
   result:= DBUS_HANDLER_RESULT_HANDLED;
   dbus_message_unref(message);
  end
  else begin
   result:= DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
  end;
 end;
end;

procedure unregisterobjectpath(connection: pDBusConnection;
                                                      user_data: pointer)
                                    {$ifdef wincall}stdcall{$else}cdecl{$endif};
begin
 freemem(user_data);
end;

const
 dbuscallbackvtable: DBusObjectPathVTable = (
  unregister_function: @unregisterobjectpath; 
  message_function: @objectpathhandlertrampoline; 
  dbus_internal_pad1: nil;
  dbus_internal_pad2: nil;
  dbus_internal_pad3: nil;
  dbus_internal_pad4: nil;
 );


procedure tdbuscontroller.registerfallback(const apath: string;
               const ahandler: messageeventty);
var
 p1: pcallbackinfoty;
begin
 p1:= getmem(sizeof(callbackinfoty));
 if dbus_connection_try_register_fallback(fconn,
              pchar(apath),
              @dbuscallbackvtable,p1,err) <> 0 then begin
  with p1^ do begin
   handler:= ahandler;
  end;
 end
 else begin
  freemem(p1);
  raisedbuserror();
 end;
end;
 
procedure tdbuscontroller.registeritem(const apath: string;
                                           const ahandler: messageeventty);
var
 p1: pcallbackinfoty;
 s1: string;
begin
 p1:= getmem(sizeof(callbackinfoty));
 with fregisteringobj^ do begin
  s1:= pchar(string(path)+'/'+apath);
  if dbus_connection_try_register_object_path(fconn,
               pchar(s1),
               @dbuscallbackvtable,p1,err) <> 0 then begin
   with p1^ do begin
    handler:= ahandler;
   end;
   additem(stringarty(items),apath);
  end
  else begin
   freemem(p1);
   raisedbuserror();
  end;
 end;
end;

procedure tdbuscontroller.doregisteritems(const aobj: pobjinfoty);
begin
 fregisteringobj:= aobj;
 try
  aobj^.obj.registeritems(idbuscontroller(self));
 finally
  fregisteringobj:= nil;
 end;
end;

procedure tdbuscontroller.dounregisteritems(const aobj: pobjinfoty);
var
 p1,pe: pstring;
 s1,s2: string;
begin
 p1:= aobj^.items;
 s1:= string(aobj^.path)+'/';
 pe:= p1 + length(stringarty(aobj^.items));
 while p1 < pe do begin
  s2:= s1+p1^;
  dbus_connection_unregister_object_path(fconn,pchar(s2));
  inc(p1);
 end;
end;

procedure tdbuscontroller.unregisteritem(const apath: string);
begin
 dbus_connection_unregister_object_path(fconn,pchar(apath));
end;

procedure tdbuscontroller.rootfallback(
              const amessage: pdbusmessage; var handled: boolean);
begin
{$ifdef mse_dumpdbus}
 write(dbusdumpmessage(amessage));
{$endif}
end;

procedure tdbuscontroller.registerobjects();
var
 i1: int32;
 p1: pdbusitemty;
begin
 registerfallback('/',@rootfallback);
 for i1:= 0 to fitems.count - 1 do begin
  p1:= pointer(fitems.next());
  if p1^.data.kind = dbk_obj then begin
   doregisteritems(@p1^.data.obj);
  end;
 end;
end;

procedure tdbuscontroller.unregisterobjects();
begin
 unregisteritem('/');
end;

procedure tdbuscontroller.dounregisterobj(const aobj: pobjinfoty);
begin
 if fconn <> nil then begin
  dounregisteritems(aobj);
 end;
end;

procedure tdbuscontroller.registerobject(const sender: idbusobject);
var
 p1: pobjinfoty;
begin
 p1:= fitems.addobject(sender);
 with p1^ do begin
  string(path):= sender.getpath();
 end;
 if connected then begin
  doregisteritems(p1);
 end;
end;

procedure tdbuscontroller.unregisterobject(const sender: idbusobject);
begin
 fitems.delete(sender);
end;

function tdbuscontroller.dbuscallmethod(const returnedto: idbusresponse;
               var aserial: card32;
               const bus_name: string; const path: string; const iface: string;
               const method: string; const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const timeout: int32 = -1): boolean;

var
 pend1: pdbuspendingcall;
 m1: pdbusmessage;
 
label
 errorlab;
begin
 result:= false;
 if checkconnect() then begin
  m1:= setupmessage(bus_name,path,iface,method,paramtypes,params);
  if m1 <> nil then begin
   result:= dbus_connection_send_with_reply(fconn,m1,@pend1,timeout) <> 0;
   if not result then begin
    outofmemory();
    goto errorlab;
   end;
   fitems.addlink(returnedto,pend1);
   fitems.addpending(pend1,returnedto,aserial);
   dbus_pending_call_set_notify(pend1,@pendingcallback,nil,nil);
errorlab:
   dbus_message_unref(m1);
  end;
 end;
end;

function tdbuscontroller.dbuscallmethod(const bus_name: string;
               const path: string; const iface: string; const method: string;
               const paramtypes: array of dbusdataty;
               const params: array of pointer;
               const resulttypes: array of dbusdataty;
               const results: array of pointer;
               const timeout: int32 = -1): boolean;
var
 m1,m2: pdbusmessage;
 
label
 errorlab;
begin
 result:= false;
 if checkconnect() then begin
  m1:= setupmessage(bus_name,path,iface,method,paramtypes,params);
  if m1 <> nil then begin
   m2:= dbus_connection_send_with_reply_and_block(fconn,m1,timeout,err());
   if m2 = nil then begin
    checkok();
   end
   else begin
    result:= readmessage(m2,resulttypes,results);
    dbus_message_unref(m2);
   end;
errorlab:
   dbus_message_unref(m1);
  end;
 end;
end;

function tdbuscontroller.readmessage(const amessage: pdbusmessage;
               const resulttypes: array of dbusdataty;
               const results: array of pointer): boolean; 
                                     //true if ok
var
 pte: pdbusdataty;

 function readvalue(var aiter: dbusmessageiter; 
                                 var pt: pdbusdataty; var pd: ppointer): boolean;
 var
  i1,i2,i3: int32;
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
 pde: ppointer;
 pt: pdbusdataty;
 pd: ppointer;
 s1: string;
 p1: pointer;
 t1: dbusdataty;

label
 errorlab;
begin
 result:= false;
 if checkconnect() then begin
  if amessage = nil then begin
   error('NIL message');
   goto errorlab;
  end
  else begin
   dbus_message_iter_init(amessage,@iter1);

   if dbus_message_get_type(amessage) = DBUS_MESSAGE_TYPE_ERROR then begin
    p1:= @s1;
    pd:= @p1;
    t1:= dbt_string;
    pt:= @t1;
    pte:= pt+1;
    if readvalue(iter1,pt,pd) then begin
     error(s1);
    end;
    goto errorlab;
   end;

   pt:= @resulttypes[0];
   pte:= pt + length(resulttypes);
   pd:= @results[0];
   pde:= pd + length(results);
   while pd < pde do begin
    if not readvalue(iter1,pt,pd) then begin
     goto errorlab;
    end;
   end;
   if dbus_message_iter_get_arg_type(@iter1) <> DBUS_TYPE_INVALID then begin
    error('dbuscallmethod() wrong returned param count');
    goto errorlab;
   end;
   if pt <> pte then begin
    error('dbuscallmethod() resulttypes and results count do not match');
    goto errorlab;
   end;
   result:= true;
  end;
errorlab:
 end;
end;
 

function tdbuscontroller.connect: boolean;
var
 i1,i2: int32;
 s1,s2: string;
begin
 if fconn <> nil then begin
  result:= true;
  exit;
 end;
 result:= false;
 try
  initdbuslib();
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
   registerobjects();
   result:= true;
  end;
 except
  on e: exception do begin
   dbuslasterror:= e.message;
  end;
 end;
end;

procedure tdbuscontroller.disconnect();
begin
 if fconn <> nil then begin
  unregisterobjects();
  dbus_connection_close(fconn);
  fitems.clear();
  if not applicationdestroyed() then  begin
   application.unregisteronidle(@doidle);
  end;
  err(); //free ferr
  dbus_shutdown();
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
{$ifdef mse_debugdbus}
  writeln('**dotimer');
{$endif}
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

procedure tdbuscontroller.raisedbuserror();
begin
 if not checkok() then begin
  raiseerror(dbuslasterror);
 end;
end;

procedure tdbuscontroller.doidle(var again: boolean);
begin
 if fconn <> nil then begin
{$ifdef mse_debugdbus}
  writeln('**doidle');
{$endif}
  fitems.handlewatches();
  repeat
  until dbus_connection_dispatch(fconn) <> DBUS_DISPATCH_DATA_REMAINS;
  dbus_connection_flush(fconn);
 end;
end;

procedure tdbuscontroller.dopendingcallback(pending: pDBusPendingCall;
               user_data: pointer);
var
 m1: pdbusmessage;
begin
 m1:= dbus_pending_call_steal_reply(pending);
 with fitems.findpending(pending)^ do begin
  if link <> nil then begin
   link.replyed(serial,m1);
   fitems.delete(link);
  end;
  fitems.delete(pending);
 end;
 if m1 <> nil then begin
  dbus_message_unref(m1);
 end;
 dbus_pending_call_unref(pending);
end;

{
procedure tdbuscontroller.dofreependingcallback(memory: pointer);
begin
 removeitem(pointerarty(fpendings),memory);
 freemem(memory);
end;
}
{ tdbusobject }

constructor tdbusobject.create(const acontroller: idbuscontroller);
begin
 fcontroller:= acontroller;
 if fcontroller = nil then begin
  fcontroller:= idbuscontroller(dbuscontroller);
 end;
 inherited create;
 fcontroller.registerobject(idbusobject(self));
end;

destructor tdbusobject.destroy();
begin
 if fcontroller <> nil then begin
  fcontroller.unregisterobject(idbusobject(self));
 end;
 inherited;
end;

function tdbusobject.getinstance(): tobject;
begin
 result:= self;
end;

procedure tdbusobject.registeritems(const sender: idbuscontroller);
begin
 //dummy
end;

function tdbusobject.getpath(): string;
begin
 result:= '';
end;
{
procedure tdbusobject.unregisteritems(const sender: idbuscontroller);
begin
 //dummy
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
