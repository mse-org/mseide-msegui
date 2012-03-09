{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesystypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;
type
 {$ifndef FPC}
 tlibhandle = thandle;
 {$endif}
 threadty = ptruint;
 procidty = ptrint;
 pprocidty = ^procidty;
 procidarty = array of procidty; //same item size as winidarty!
 prochandlety = type ptrint;

 mutexty = array[0..9] of pointer;
 semty = array[0..7] of pointer;
 psemty = ^semty;
 condty = array[0..31] of pointer;

 syserrorty = (sye_ok,sye_lasterror,sye_extendederror,sye_busy,sye_dirstream,
                sye_network,
                sye_thread,sye_mutex,sye_semaphore,sye_cond,sye_timeout,
                sye_copyfile,sye_createdir,sye_noconsole,sye_notimplemented,
                sye_sockaddr,sye_socket,sye_isdir
               );
const
 invalidprocid = -1;
 invalidprochandle = -1;
 invalidfilehandle = -1;

implementation
end.
