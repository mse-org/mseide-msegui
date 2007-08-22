unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseevent,mseforms,msegraphics,msemenus,msestat,ZConnection,
 db,msedb,msezeos,sysutils,msedataedits,msedbedit,mseedit,msegraphutils,
 msegrids,msesimplewidgets,msestrings,msetypes,msewidgetgrid,msewidgets,
 msestatfile;

type
 tmainfo = class(tmseform)
   tdbnavigator1: tdbnavigator;
   tdbstringgrid1: tdbstringgrid;
   tfacecomp1: tfacecomp;
   tmsedatasource1: tmsedatasource;
   tmsezquery1: tmsezquery;
   tstatfile1: tstatfile;
   TZConnection1: TZConnection;
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
