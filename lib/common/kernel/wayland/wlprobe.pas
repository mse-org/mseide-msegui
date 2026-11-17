program wlprobe;
{ Test of the Wayland bindings: connects, lists the globals of the compositor
  (like wayland-info), binds wl_compositor, creates and destroys a surface
  and checks that the compositor reports no protocol error.
  Run it with WAYLAND_DISPLAY=wayland-1 ./wlprobe }
{$mode objfpc}{$h+}

uses
 ctypes,waylandbase,waylandcore;

var
 compositor: pointer;
 count: integer;

procedure onglobal(data: pointer; registry: pointer; name: cuint32;
                         iface: pchar; version: cuint32); cdecl;
begin
 inc(count);
 writeln('global ',name:3,'  ',iface,' v',version);
 if string(iface) = 'wl_compositor' then begin
  if version > 4 then begin
   version:= 4;
  end;
  compositor:= wl_registry_bind(registry,name,@wl_compositor_interface,version);
 end;
end;

procedure onglobalremove(data: pointer; registry: pointer;
                                                  name: cuint32); cdecl;
begin
end;

var
 display,registry,surface: pointer;
 listener: twl_registry_listener;
 err: integer;

begin
 compositor:= nil;
 count:= 0;
 display:= wl_display_connect(nil);
 if display = nil then begin
  writeln('cannot connect, is WAYLAND_DISPLAY set and the compositor running?');
  halt(1);
 end;
 registry:= wl_display_get_registry(display);
 fillchar(listener,sizeof(listener),0);
 listener.global:= @onglobal;
 listener.global_remove:= @onglobalremove;
 wl_registry_add_listener(registry,@listener,nil);
 if wl_display_roundtrip(display) < 0 then begin
  writeln('FAIL roundtrip 1');
  halt(1);
 end;
 writeln(count,' globals');
 if compositor = nil then begin
  writeln('FAIL no wl_compositor');
  halt(1);
 end;
 surface:= wl_compositor_create_surface(compositor);
 if surface = nil then begin
  writeln('FAIL create_surface');
  halt(1);
 end;
 writeln('surface created, id ',wl_proxy_get_id(surface));
 wl_surface_destroy(surface);
 if wl_display_roundtrip(display) < 0 then begin
  writeln('FAIL roundtrip 2, protocol error ',wl_display_get_error(display));
  halt(1);
 end;
 err:= wl_display_get_error(display);
 if err <> 0 then begin
  writeln('FAIL display error ',err);
  halt(1);
 end;
 writeln('ok: bindings work (requests, events, new_id, destructor)');
 wl_display_disconnect(display);
end.
