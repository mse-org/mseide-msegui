{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysenvmanagereditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesysenv;

type
 tmsesysenvmanagereditorfo = class(tmseform)
 end;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;

implementation
uses
 msesysenvmanagereditor_mfm;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;
begin
end;

end.
