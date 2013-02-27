{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslbio;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;

const
  // These are the 'types' of BIOs
  BIO_TYPE_NONE = $0000;
  BIO_TYPE_MEM = $0001 or $0400;
  BIO_TYPE_FILE = $0002 or $0400;

  BIO_TYPE_FD = $0004 or $0400 or $0100;
  BIO_TYPE_SOCKET = $0005 or $0400 or $0100;
  BIO_TYPE_NULL = $0006 or $0400;
  BIO_TYPE_SSL = $0007 or $0200;
  BIO_TYPE_MD = $0008 or $0200;  // passive filter
  BIO_TYPE_BUFFER = $0009 or $0200;  // filter
  BIO_TYPE_CIPHER = $00010 or $0200;  // filter
  BIO_TYPE_BASE64 = $00011 or $0200;  // filter
  BIO_TYPE_CONNECT = $00012 or $0400 or $0100;  // socket - connect
  BIO_TYPE_ACCEPT = $00013 or $0400 or $0100;  // socket for accept
  BIO_TYPE_PROXY_CLIENT = $00014 or $0200;  // client proxy BIO
  BIO_TYPE_PROXY_SERVER = $00015 or $0200;  // server proxy BIO
  BIO_TYPE_NBIO_TEST = $00016 or $0200;  // server proxy BIO
  BIO_TYPE_NULL_FILTER = $00017 or $0200;
  BIO_TYPE_BER = $00018 or $0200;  // BER -> bin filter
  BIO_TYPE_BIO = $00019 or $0400;  // (half a; BIO pair
  BIO_TYPE_LINEBUFFER = $00020 or $0200;  // filter

  BIO_TYPE_DESCRIPTOR = $0100;  // socket, fd, connect or accept
  BIO_TYPE_FILTER= $0200;
  BIO_TYPE_SOURCE_SINK = $0400;

  // BIO ops constants
  // BIO_FILENAME_READ|BIO_CLOSE to open or close on free.
  // BIO_set_fp(in,stdin,BIO_NOCLOSE);
  BIO_NOCLOSE = $00;
  BIO_CLOSE = $01;
  BIO_FP_READ = $02;
  BIO_FP_WRITE = $04;
  BIO_FP_APPEND = $08;
  BIO_FP_TEXT = $10;

  BIO_C_SET_FD = 104;
  BIO_C_GET_FD = 105;
  BIO_C_SET_FILENAME = 108;
  BIO_CTRL_RESET = 1;  // opt - rewind/zero etc
  BIO_CTRL_EOF = 2;  // opt - are we at the eof
  BIO_CTRL_INFO = 3;  // opt - extra tit-bits
  BIO_CTRL_SET = 4;  // man - set the 'IO' type
  BIO_CTRL_GET = 5;  // man - get the 'IO' type
  BIO_CTRL_PUSH = 6;  // opt - internal, used to signify change
  BIO_CTRL_POP = 7;  // opt - internal, used to signify change
  BIO_CTRL_GET_CLOSE = 8;  // man - set the 'close' on free
  BIO_CTRL_SET_CLOSE = 9;  // man - set the 'close' on free
  BIO_CTRL_PENDING_C = 10;  // opt - is their more data buffered
  BIO_CTRL_FLUSH = 11;  // opt - 'flush' buffered output
  BIO_CTRL_DUP = 12;  // man - extra stuff for 'duped' BIO
  BIO_CTRL_WPENDING = 13;  // opt - number of bytes still to write

  BIO_C_GET_MD_CTX = 120;
{  
type
  PBIO_METHOD = SslPtr;
  PBIO = SslPtr;
} 
var
 // BIO functions
 BIO_new: function(b: PBIO_METHOD): PBIO; cdecl;
 BIO_new_fd: function(fd: cint; close_flag: cint): PBIO; cdecl;
 BIO_new_file: function(const filename: PCharacter;
                                    const mode: PCharacter): pBIO; cdecl;
 BIO_free_all: procedure(b: PBIO); cdecl;
 BIO_s_mem: function(): PBIO_METHOD; cdecl;
 BIO_s_fd: function: pBIO_METHOD; cdecl;
 BIO_s_file: function: pBIO_METHOD; cdecl;
 BIO_ctrl_pending: function(b: PBIO): cint; cdecl;
 BIO_read: function(b: PBIO; Buf: pbyte; Len: cint): cint; cdecl;
 BIO_write: function(b: PBIO; Buf: pbyte; Len: cint): cint; cdecl;
 d2i_PKCS12_bio: function(b:PBIO; Pkcs12: SslPtr): SslPtr; cdecl;
 BIO_set: function(a: pBIO; _type: pBIO_METHOD): cint; cdecl;
 BIO_free: function(a: pBIO): cint; cdecl;
 BIO_vfree: procedure(a: pBIO); cdecl;
 BIO_push: function(b: pBIO; append: pBIO): pBIO; cdecl;
 BIO_pop: function(b: pBIO): pBIO; cdecl;
 BIO_ctrl: function(bp: pBIO; cmd: cint; larg: clong;
                                        parg: Pointer): clong; cdecl;
 BIO_int_ctrl: function(bp: pBIO; cmd: cint; larg: clong;
                                             iarg: cint): clong; cdecl;
 BIO_gets: function(b: pBIO; buf: PCharacter; size: cint): cint; cdecl;
 BIO_puts: function(b: pBIO; const buf: PCharacter): cint; cdecl;
 BIO_f_base64: function: pBIO_METHOD; cdecl;

//optional todo: these are probably macros
 BIO_set_mem_eof_return: procedure(b: pBIO; v: cint); cdecl;
 BIO_set_mem_buf: procedure(b: pBIO; bm: pBUF_MEM; c: cint); cdecl;
 BIO_get_mem_ptr: procedure(b: pBIO; var pp: pBUF_MEM); cdecl;
 BIO_new_mem_buf: function(buf: pointer; len: cint): pBIO; cdecl;
 
function BIO_flush(b: pBIO): cint;
function BIO_get_mem_data(b: pBIO; var pp: PCharacter): clong;
function BIO_get_md_ctx(bp: pBIO; mdcp: Pointer): clong;
function BIO_reset(bp: pBIO): cint;
function BIO_eof(bp: pBIO): cint;
function BIO_set_close(bp: pBIO; c: cint): cint;
function BIO_get_close(bp: pBIO): cint;
function BIO_pending(bp: pBIO): cint;
function BIO_wpending(bp: pBIO): cint;
function BIO_read_filename(bp: pBIO; filename: PCharacter): cint;
function BIO_write_filename(bp: pBIO; filename: PCharacter): cint;
function BIO_append_filename(bp: pBIO; filename: PCharacter): cint;
function BIO_rw_filename(bp: pBIO; filename: PCharacter): cint;
function BIO_set_fd(bp: pBIO; fd: cint; c: cint): clong;
function BIO_get_fd(bp: pBIO; var c: cint): cint;


implementation
uses
 {$ifdef FPC}dynlibs,{$endif}msedynload;
 
function BIO_flush(b: pBIO): cint;
begin
  result := BIO_ctrl(b, BIO_CTRL_FLUSH, 0, nil);
end;

function BIO_get_mem_data(b: pBIO; var pp: PCharacter): clong;
begin
  result := BIO_ctrl(b, BIO_CTRL_INFO, 0, @pp);
end;

function BIO_get_md_ctx(bp: pBIO; mdcp: Pointer): clong;
begin
  result := BIO_ctrl(bp, BIO_C_GET_MD_CTX, 0, mdcp);
end;

function BIO_reset(bp: pBIO): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_RESET, 0, nil);
end;

function BIO_eof(bp: pBIO): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_EOF, 0, nil);
end;

function BIO_set_close(bp: pBIO; c: cint): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_SET_CLOSE, c, nil);
end;

function BIO_get_close(bp: pBIO): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_GET_CLOSE, 0, nil);
end;

function BIO_pending(bp: pBIO): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_PENDING_C, 0, nil);
end;

function BIO_wpending(bp: pBIO): cint;
begin
  result := BIO_ctrl(bp, BIO_CTRL_WPENDING, 0, nil);
end;

function BIO_read_filename(bp: pBIO; filename: PCharacter): cint;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or
                                                   BIO_FP_READ, filename);
end;

function BIO_write_filename(bp: pBIO; filename: PCharacter): cint;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or
                                                  BIO_FP_WRITE, filename);
end;

function BIO_append_filename(bp: pBIO; filename: PCharacter): cint;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or 
                                                  BIO_FP_APPEND, filename);
end;

function BIO_rw_filename(bp: pBIO; filename: PCharacter): cint;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or BIO_FP_READ or
                                                     BIO_FP_WRITE, filename);
end;

function BIO_set_fd(bp: pBIO; fd: cint; c: cint): clong;
begin
 result:= bio_int_ctrl(bp,bio_c_set_fd,c,fd);
end;

function BIO_get_fd(bp: pBIO; var c: cint): cint;
begin
 result:= bio_ctrl(bp,bio_c_get_fd,0,@c);
end;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..19] of funcinfoty = (
   (n: 'BIO_new'; d: {$ifndef FPC}@{$endif}@BIO_new),
   (n: 'BIO_new_fd'; d: {$ifndef FPC}@{$endif}@BIO_new_fd),
   (n: 'BIO_free_all'; d: {$ifndef FPC}@{$endif}@BIO_free_all),
   (n: 'BIO_s_mem'; d: {$ifndef FPC}@{$endif}@BIO_s_mem),
   (n: 'BIO_ctrl_pending'; d: {$ifndef FPC}@{$endif}@BIO_ctrl_pending),
   (n: 'BIO_read'; d: {$ifndef FPC}@{$endif}@BIO_read),
   (n: 'BIO_write'; d: {$ifndef FPC}@{$endif}@BIO_write),
   (n: 'd2i_PKCS12_bio'; d: {$ifndef FPC}@{$endif}@d2i_PKCS12_bio),
   (n: 'BIO_new_file'; d: {$ifndef FPC}@{$endif}@BIO_new_file),
   (n: 'BIO_set'; d: {$ifndef FPC}@{$endif}@BIO_set),
   (n: 'BIO_free'; d: {$ifndef FPC}@{$endif}@BIO_free),
   (n: 'BIO_vfree'; d: {$ifndef FPC}@{$endif}@BIO_vfree),
   (n: 'BIO_push'; d: {$ifndef FPC}@{$endif}@BIO_push),
   (n: 'BIO_pop'; d: {$ifndef FPC}@{$endif}@BIO_pop),
   (n: 'BIO_ctrl'; d: {$ifndef FPC}@{$endif}@BIO_ctrl),
   (n: 'BIO_gets'; d: {$ifndef FPC}@{$endif}@BIO_gets),
   (n: 'BIO_puts'; d: {$ifndef FPC}@{$endif}@BIO_puts),
   (n: 'BIO_f_base64'; d: {$ifndef FPC}@{$endif}@BIO_f_base64),
   (n: 'BIO_s_fd'; d: {$ifndef FPC}@{$endif}@BIO_s_fd),
   (n: 'BIO_s_file'; d: {$ifndef FPC}@{$endif}@BIO_s_file)
  );
 funcsopt: array[0..3] of funcinfoty = (
   (n: 'BIO_set_mem_eof_return'; d: {$ifndef FPC}@{$endif}@BIO_set_mem_eof_return),
   (n: 'BIO_set_mem_buf'; d: {$ifndef FPC}@{$endif}@BIO_set_mem_buf),
   (n: 'BIO_get_mem_ptr'; d: {$ifndef FPC}@{$endif}@BIO_get_mem_ptr),
   (n: 'BIO_new_mem_buf'; d: {$ifndef FPC}@{$endif}@BIO_new_mem_buf)
  );
   
begin
 getprocaddresses(info,funcs);
 getprocaddresses(info,funcsopt,true);
end;

initialization
 regopensslinit(@init);
end.
