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
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesysenv,msesplitter,
 msesimplewidgets,msewidgets,msegraphedits,mseifiglob,msetypes,msedataedits,
 mseedit,msegrids,msestrings,msewidgetgrid,msememodialog,msestatfile;

const
 sysenvmanagereditorstatname =  'sysenvmanagereditor.sta';

type
 tmsesysenvmanagereditorfo = class(tmseform)
   la2: tlayouter;
   tlayouter2: tlayouter;
   ok: tbutton;
   cancel: tbutton;
   grid: twidgetgrid;
   kinded: tenumtypeedit;
   nameed: tstringedit;
   aliased: tmemodialogedit;
   envdefined: tbooleanedit;
   statdefined: tbooleanedit;
   setdefined: tbooleanedit;
   argopt: tbooleanedit;
   filenames: tbooleanedit;
   statoverride: tbooleanedit;
   stataddval: tbooleanedit;
   integer: tbooleanedit;
   initvalueed: tmemodialogedit;
   statfile1: tstatfile;
   procedure kindedinit(const sender: tenumtypeedit);
 end;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;

implementation
uses
 msesysenvmanagereditor_mfm;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;
var
 ar1: argumentdefarty;
 ar2: stringararty;
 int1: integer;
begin
 try
  defstoarguments(asysenvmanager.defs,ar1,ar2);
 except
  application.handleexception;
 end;
 with tmsesysenvmanagereditorfo.create(nil) do begin
  grid.rowcount:= length(ar1);
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    kinded[int1]:= ord(kind);
    nameed[int1]:= name;
    aliased[int1]:= concatstrings(ar2[int1]);
    envdefined.gridvaluebitmask[int1]:= longword(flags);
    initvalueed[int1]:= initvalue;
   end;
  end;
  result:= show(ml_application);
 end;
end;

procedure tmsesysenvmanagereditorfo.kindedinit(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(argumentkindty);
end;

end.
