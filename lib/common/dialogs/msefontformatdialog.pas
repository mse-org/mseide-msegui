{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefontformatdialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 mserichstring;
type
 tmsefontformatdialogfo = class(tmseform)
 end;
 
function editfontformat(const avalue: formatinfoarty; 
                                    const start,count: int32): formatinfoarty;

implementation
uses
 msefontformatdialog_mfm;

function editfontformat(const avalue: formatinfoarty; 
                                    const start,count: int32): formatinfoarty;
begin
end;

end.
