unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseevent,mseforms,msegraphics,msemenus,msestat,db,msedb,
 sysutils,msedataedits,msedbedit,mseedit,msegraphutils,msegrids,
 msesimplewidgets,msestrings,msetypes,msewidgetgrid,msewidgets,msestatfile,
 msedatabase,msebufdataset,msesqldb,msqldb,msesqlite3conn;

type
 tmainfo = class(tmseform)
   tactivator1: tactivator;
   tdbnavigator1: tdbnavigator;
   tdbstringgrid1: tdbstringgrid;
   tfacecomp1: tfacecomp;
   tmsedatasource1: tmsedatasource;
   tmsesqlquery1: tmsesqlquery;
   tmsesqltransaction1: tmsesqltransaction;
   tsqlite3connection1: tsqlite3connection;
   tstatfile1: tstatfile;
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
