unit waylandbase;
{ Runtime part of the Wayland client bindings for MSEgui (pure Wayland
  backend). Imports libwayland-client and libwayland-cursor, defines the
  types used by the units generated with wl2pas.py from the protocol XML
  files. Objects are plain pointers (pwl_proxy). }
{$mode objfpc}{$h+}
{$packrecords c}

interface
uses
 ctypes;

const
 wlclientlib = 'wayland-client';
 wlcursorlib = 'wayland-cursor';
 WL_MARSHAL_FLAG_DESTROY = 1;

type
 pwl_proxy = pointer;
 pwl_display = pointer;

 pwl_interface = ^twl_interface;
 ppwl_interface = ^pwl_interface;
 pwl_message = ^twl_message;

 twl_message = record
  name: pchar;
  signature: pchar;
  types: ppwl_interface;
 end;

 twl_interface = record
  name: pchar;
  version: cint;
  method_count: cint;
  methods: pwl_message;
  event_count: cint;
  events: pwl_message;
 end;

 pwl_array = ^twl_array;
 twl_array = record
  size: csize_t;
  alloc: csize_t;
  data: pointer;
 end;

 //libwayland-cursor
 pwl_cursor_theme = pointer;
 pwl_cursor_image = ^twl_cursor_image;
 ppwl_cursor_image = ^pwl_cursor_image;
 twl_cursor_image = record
  width: cuint32;
  height: cuint32;
  hotspot_x: cuint32;
  hotspot_y: cuint32;
  delay: cuint32;
 end;
 pwl_cursor = ^twl_cursor;
 twl_cursor = record
  image_count: cuint;
  images: ppwl_cursor_image;
  name: pchar;
 end;

//display connection
function wl_display_connect(name: pchar): pwl_display; cdecl;
                                     external wlclientlib;
procedure wl_display_disconnect(display: pwl_display); cdecl;
                                     external wlclientlib;
function wl_display_get_fd(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_dispatch(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_dispatch_pending(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_flush(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_roundtrip(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_prepare_read(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
function wl_display_read_events(display: pwl_display): cint; cdecl;
                                     external wlclientlib;
procedure wl_display_cancel_read(display: pwl_display); cdecl;
                                     external wlclientlib;
function wl_display_get_error(display: pwl_display): cint; cdecl;
                                     external wlclientlib;

//proxies
function wl_proxy_add_listener(proxy: pwl_proxy; listener: pointer;
                      data: pointer): cint; cdecl; external wlclientlib;
procedure wl_proxy_destroy(proxy: pwl_proxy); cdecl; external wlclientlib;
procedure wl_proxy_set_user_data(proxy: pwl_proxy; data: pointer); cdecl;
                                     external wlclientlib;
function wl_proxy_get_user_data(proxy: pwl_proxy): pointer; cdecl;
                                     external wlclientlib;
function wl_proxy_get_version(proxy: pwl_proxy): cuint32; cdecl;
                                     external wlclientlib;
function wl_proxy_get_id(proxy: pwl_proxy): cuint32; cdecl;
                                     external wlclientlib;
function wl_proxy_marshal_flags(proxy: pwl_proxy; opcode: cuint32;
                      iface: pwl_interface; version: cuint32;
                      flags: cuint32): pointer; cdecl; varargs;
                                     external wlclientlib;

//cursor
function wl_cursor_theme_load(name: pchar; size: cint;
                      shm: pointer): pwl_cursor_theme; cdecl;
                                     external wlcursorlib;
procedure wl_cursor_theme_destroy(theme: pwl_cursor_theme); cdecl;
                                     external wlcursorlib;
function wl_cursor_theme_get_cursor(theme: pwl_cursor_theme;
                      name: pchar): pwl_cursor; cdecl; external wlcursorlib;
function wl_cursor_image_get_buffer(image: pwl_cursor_image): pointer; cdecl;
                                     external wlcursorlib;

//used by the generated units to fill the interface tables
procedure wl_setmessage(var msg: twl_message; const aname,asignature: pchar;
                                                 atypes: ppwl_interface);
procedure wl_setinterface(var iface: twl_interface; const aname: pchar;
                      aversion: cint; amethodcount: cint; amethods: pwl_message;
                      aeventcount: cint; aevents: pwl_message);

//libwayland aborts the client when an event arrives for which the listener
//slot is nil, so listeners must be filled with this before the real handlers
//are set (the generated <interface>_noop_listener procedures do that).
procedure wl_fillnoop(var listener; const size: integer);

//wl_fixed_t = signed 24.8 fixed point
function wl_fixed_to_double(const value: cint32): double;
function wl_fixed_to_int(const value: cint32): integer;
function wl_fixed_from_int(const value: integer): cint32;
function wl_fixed_from_double(const value: double): cint32;

implementation

procedure wl_setmessage(var msg: twl_message; const aname,asignature: pchar;
                                                 atypes: ppwl_interface);
begin
 msg.name:= aname;
 msg.signature:= asignature;
 msg.types:= atypes;
end;

procedure wl_setinterface(var iface: twl_interface; const aname: pchar;
                      aversion: cint; amethodcount: cint; amethods: pwl_message;
                      aeventcount: cint; aevents: pwl_message);
begin
 iface.name:= aname;
 iface.version:= aversion;
 iface.method_count:= amethodcount;
 iface.methods:= amethods;
 iface.event_count:= aeventcount;
 iface.events:= aevents;
end;

procedure wl_noop; cdecl;
begin
 //cdecl: the caller cleans up its arguments, so ignoring them is safe
end;

procedure wl_fillnoop(var listener; const size: integer);
var
 i: integer;
 po: ppointer;
begin
 po:= @listener;
 for i:= 0 to size div sizeof(pointer) - 1 do begin
  po^:= @wl_noop;
  inc(po);
 end;
end;

function wl_fixed_to_double(const value: cint32): double;
begin
 result:= value / 256.0;
end;

function wl_fixed_to_int(const value: cint32): integer;
begin
 result:= value div 256;
end;

function wl_fixed_from_int(const value: integer): cint32;
begin
 result:= value * 256;
end;

function wl_fixed_from_double(const value: double): cint32;
begin
 result:= round(value * 256.0);
end;

end.
