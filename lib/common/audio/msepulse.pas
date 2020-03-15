{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepulse;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes{msestrings},msepulseglob,msectypes;

const
{$ifdef mswindows}
 pulsesimplelib: array[0..0] of filenamety = ('libpulse-0.dll');
{$else}
 pulsesimplelib: array[0..1] of filenamety =
                  ('libpulse.so.0','libpulse.so');
{$endif}

var
//** Return a human readable error message for the specified numeric error code */
 pa_strerror: function(error: cint): pchar; cdecl;

procedure initializepulse(const sonames: array of filenamety);
                                           //[] = default
procedure releasepulse;

implementation
uses
 msedynload,sysutils,msesys;

var
 libinfo: dynlibinfoty;

procedure initializepulse(const sonames: array of filenamety); //[] = default
const
 funcs: array[0..0] of funcinfoty = (
   (n: 'pa_strerror'; d: {$ifndef FPC}@{$endif}@pa_strerror)          //0
   );
 errormessage = 'Can not load Pulseaudio simple library. ';
begin
 initializedynlib(libinfo,sonames,pulsesimplelib,funcs,[],errormessage);
end;

procedure releasepulse;
begin
 releasedynlib(libinfo);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
