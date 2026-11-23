unit xkbcommon;
{ Minimal Free Pascal binding of libxkbcommon for the MSEgui pure Wayland
  backend: keymap from the compositor, key state, keysyms, utf8 text. }
{$mode objfpc}{$h+}
{$packrecords c}

interface
uses
 ctypes;

const
 xkblib = 'xkbcommon';

 XKB_CONTEXT_NO_FLAGS = 0;
 XKB_KEYMAP_FORMAT_TEXT_V1 = 1;
 XKB_KEYMAP_COMPILE_NO_FLAGS = 0;

 XKB_STATE_MODS_DEPRESSED = 1;
 XKB_STATE_MODS_LATCHED = 2;
 XKB_STATE_MODS_LOCKED = 4;
 XKB_STATE_MODS_EFFECTIVE = 8;

 XKB_MOD_NAME_SHIFT = 'Shift';
 XKB_MOD_NAME_CAPS = 'Lock';
 XKB_MOD_NAME_CTRL = 'Control';
 XKB_MOD_NAME_ALT = 'Mod1';
 XKB_MOD_NAME_NUM = 'Mod2';
 XKB_MOD_NAME_LOGO = 'Mod4';

 XKB_KEY_NoSymbol = 0;

type
 pxkb_context = pointer;
 pxkb_keymap = pointer;
 pxkb_state = pointer;
 xkb_keysym_t = cuint32;
 xkb_keycode_t = cuint32;

function xkb_context_new(flags: cint): pxkb_context; cdecl; external xkblib;
procedure xkb_context_unref(context: pxkb_context); cdecl; external xkblib;

function xkb_keymap_new_from_string(context: pxkb_context; astring: pchar;
                      format: cint; flags: cint): pxkb_keymap; cdecl;
                                                   external xkblib;
procedure xkb_keymap_unref(keymap: pxkb_keymap); cdecl; external xkblib;
function xkb_keymap_key_repeats(keymap: pxkb_keymap;
                      key: xkb_keycode_t): cint; cdecl; external xkblib;

function xkb_state_new(keymap: pxkb_keymap): pxkb_state; cdecl;
                                                   external xkblib;
procedure xkb_state_unref(state: pxkb_state); cdecl; external xkblib;
function xkb_state_update_mask(state: pxkb_state; depressed_mods,
                      latched_mods,locked_mods: cuint32; depressed_layout,
                      latched_layout,locked_layout: cuint32): cint; cdecl;
                                                   external xkblib;
function xkb_state_key_get_one_sym(state: pxkb_state;
                      key: xkb_keycode_t): xkb_keysym_t; cdecl;
                                                   external xkblib;
function xkb_state_key_get_utf8(state: pxkb_state; key: xkb_keycode_t;
                      buffer: pchar; size: csize_t): cint; cdecl;
                                                   external xkblib;
function xkb_state_mod_name_is_active(state: pxkb_state; name: pchar;
                      atype: cint): cint; cdecl; external xkblib;

function xkb_keysym_get_name(keysym: xkb_keysym_t; buffer: pchar;
                      size: csize_t): cint; cdecl; external xkblib;

//Wayland key codes are evdev codes, xkb key codes are evdev + 8
function evdevtoxkb(const evdevkey: cuint32): xkb_keycode_t;
function keysymname(const keysym: xkb_keysym_t): string;
function keyutf8(const state: pxkb_state; const evdevkey: cuint32): string;

implementation

function evdevtoxkb(const evdevkey: cuint32): xkb_keycode_t;
begin
 result:= evdevkey + 8;
end;

function keysymname(const keysym: xkb_keysym_t): string;
var
 buf: array[0..63] of char;
begin
 buf[0]:= #0;
 xkb_keysym_get_name(keysym,@buf[0],sizeof(buf));
 result:= pchar(@buf[0]);
end;

function keyutf8(const state: pxkb_state; const evdevkey: cuint32): string;
var
 buf: array[0..31] of char;
begin
 buf[0]:= #0;
 xkb_state_key_get_utf8(state,evdevtoxkb(evdevkey),@buf[0],sizeof(buf));
 result:= pchar(@buf[0]);
end;

end.
