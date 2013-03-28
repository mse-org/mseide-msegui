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
   mandatory: tbooleanedit;
   helped: tmemodialogedit;
   procedure kindedinit(const sender: tenumtypeedit);
 end;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;

implementation
uses
 msesysenvmanagereditor_mfm,typinfo;

function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;
var
 ar1: sysenvdefarty;
 int1: integer;
begin
 ar1:= asysenvmanager.defs;
 with tmsesysenvmanagereditorfo.create(nil) do begin
  grid.rowcount:= length(ar1);
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    kinded[int1]:= ord(kind);
    nameed[int1]:= name;
    aliased[int1]:= concatstrings(anames,' ','"');
    envdefined.gridvaluebitmask[int1]:= longword(flags);
    initvalueed[int1]:= initvalue;
   end;
  end;
  result:= show(ml_application);
  if result = mr_ok then begin
   ar1:= nil; //init with zero
   setlength(ar1,grid.datarowhigh+1);
   for int1:= 0 to high(ar1) do begin
    with ar1[int1] do begin
     kind:= argumentkindty(kinded[int1]);
     name:= nameed[int1];
     splitstringquoted(aliased[int1],anames);
     flags:= argumentflagsty(envdefined.gridvaluebitmask[int1]);
     initvalue:= initvalueed[int1];
     help:= helped[int1];
    end;
   end;
   asysenvmanager.defs:= ar1;
  end;
 end;
end;

{
function editsysenvmanager(asysenvmanager: tsysenvmanager): modalresultty;
var
 ar1: argumentdefarty;
 ar2: stringararty;
 int1: integer;
 ar3,ar4: stringarty;
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
  if result = mr_ok then begin
   setlength(ar4,5);
   setlength(ar3,grid.datarowhigh+1);
   for int1:= 0 to high(ar3) do begin
    ar4[0]:= getenumname(typeinfo(argumentkindty),kinded[int1]);
    ar4[1]:= nameed[int1];
    ar4[2]:= aliased[int1];
    ar4[3]:= settostring(ptypeinfo(typeinfo(argumentflagsty)),
                        envdefined.gridvaluebitmask[int1],false);
    ar4[4]:= initvalueed[int1];
    ar3[int1]:= concatstrings(ar4,',','"');
   end;
   asysenvmanager.defs:= string(concatstrings(ar3,lineend));
  end;
 end;
end;
}
procedure tmsesysenvmanagereditorfo.kindedinit(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(argumentkindty);
end;

end.
