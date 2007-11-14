{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
function soc_getsockaddrerrortext(aerror: integer): string;

function soc_opensocket(const kind: socketkindty; const nonblock: boolean;
                                    out handle: integer): syserrorty;
function soc_shutdownsocket(const handle: integer;
                   const kind: socketshutdownkindty): syserrorty;
function soc_closesocket(const handle: integer): syserrorty;
function soc_connectsocket(const handle: integer; 
                           const addr: socketaddrty; const timeoutms: integer): syserrorty;
function soc_bindsocket(const handle: integer;
                                   const addr: socketaddrty): syserrorty;
function soc_listen(const handle: integer;
                                   const maxconnections: integer): syserrorty;
function soc_accept(const handle: integer; const nonblock: boolean; out conn: integer;
                       out addr: socketaddrty; const timeoutms: integer): syserrorty;
function soc_urltoaddr(var addr: socketaddrty): syserrorty;
function soc_getsockaddr(const addr: socketaddrty): string;
                   //address bytes
function soc_getsockport(const addr: socketaddrty): integer;
function soc_setnonblocksocket(const handle: integer;
                                     const nonblock: boolean): syserrorty;
function soc_readsocket(const fd: longint; const buf: pointer;
                        const nbytes: longword; out readbytes: integer;
                        const timeoutms: integer): syserrorty;
                 //atimeoutms < 0 -> nonblocked,
                 //result = 0 -> no data, < 0 - error
function soc_setsockrxtimeout(const handle: integer; const ms: integer): syserrorty;
function soc_setsocktxtimeout(const handle: integer; const ms: integer): syserrorty;

function soc_poll(const handle: integer; const kind: pollkindsty;
                            const timeoutms: longword): syserrorty;
                             //0 -> no timeout
                             //for blocking mode


