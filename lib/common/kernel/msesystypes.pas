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
 msetypes,sysutils;
type
 {$ifndef FPC}
 tlibhandle = thandle;
 {$endif}
 
 {$if (fpc_fullversion >= 030204) and defined(cpu64) and defined(mswindows)}
 threadty = qword;
 {$else}
 {$if (fpc_fullversion >= 030200)}
 {$if defined(cpu64) and defined(mswindows)}
   threadty = Longword;
 {$else}
   threadty = ptruint;
 {$endif}
 {$else}
 threadty = ptruint;
 {$endif}
 {$endif}

 procidty = ptrint;
 pprocidty = ^procidty;
 procidarty = array of procidty; //same item size as winidarty!
 prochandlety = type ptrint;
 pprochandlety = ^prochandlety;

 {$ifdef usesdl}
 mutexty = pointer;
 {$else}
 mutexty = array[0..9] of pointer;
 {$endif}
 semty = array[0..7] of pointer;
 psemty = ^semty;
 condty = array[0..31] of pointer;

 syserrorty = (sye_ok,sye_lasterror,sye_extendederror,sye_busy,sye_dirstream,
                sye_network,sye_write,sye_read,
                sye_thread,sye_mutex,sye_semaphore,sye_cond,sye_timeout,
                sye_copyfile,sye_createdir,sye_noconsole,sye_notimplemented,
                sye_sockaddr,sye_socket,sye_isdir
               );

 ecrashstatfile = class(exception)
 end;

const
 invalidprocid = -1;
 invalidprochandle = -1;
 invalidfilehandle = -1;

implementation
end.
