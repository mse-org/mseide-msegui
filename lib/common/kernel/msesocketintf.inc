{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
function soc_getaddrerrortext(aerror: integer): string;
function soc_geterrortext(aerror: integer): string;

function soc_open(const kind: socketkindty; const nonblock: boolean;
                                    out handle: integer): syserrorty;
function soc_shutdown(const handle: integer;
                   const kind: socketshutdownkindty): syserrorty;
function soc_close(const handle: integer): syserrorty;
function soc_connect(const handle: integer;
                           const addr: socketaddrty; const timeoutms: integer): syserrorty;
function soc_bind(const handle: integer;
                                   const addr: socketaddrty): syserrorty;
function soc_listen(const handle: integer;
                                   const maxconnections: integer): syserrorty;
function soc_accept(const handle: integer; const nonblock: boolean; out conn: integer;
                       out addr: socketaddrty; const timeoutms: integer): syserrorty;
function soc_urltoaddr(var addr: socketaddrty): syserrorty;
function soc_getaddr(const addr: socketaddrty): string;
                   //address bytes
function soc_getport(const addr: socketaddrty): integer;
function soc_setnonblock(const handle: integer;
                                     const nonblock: boolean): syserrorty;
function soc_read(const fd: longint; const buf: pointer;
                        const nbytes: longword; out readbytes: integer;
                        const timeoutms: integer): syserrorty;
                 //atimeoutms < 0 -> nonblocked,
                 //result = 0 -> no data, < 0 - error
function soc_write(const fd: longint; buf: pointer;
                        nbytes: longword; out writebytes: integer;
                        const timeoutms: integer): syserrorty;
function soc_setrxtimeout(const handle: integer; const ms: integer): syserrorty;
function soc_settxtimeout(const handle: integer; const ms: integer): syserrorty;

function soc_poll(const handle: integer; const kind: pollkindsty;
                            const timeoutms: longword;
                            out pollres: pollkindsty): syserrorty;
                             //0 -> no timeout
                             //for blocking mode


