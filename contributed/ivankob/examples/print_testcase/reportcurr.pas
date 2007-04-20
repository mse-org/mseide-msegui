unit reportcurr;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegui,mseclasses,msereport,msesimplewidgets,msedbgraphics,msedbdispwidgets;

type
 treportcurrre = class(treport)
   bgAll: tbandgroup;
   dbdiPhoto: tdbdataimage;
   rbLongText: trecordband;
   rbPhoto: trecordband;
   rbStuff: trecordband;
   trecordband1: trecordband;
   treportpage1: treportpage;
   trepprintdatedisp1: trepprintdatedisp;
   trepspacer2: trepspacer;
 end;

var
 reportcurrre: treportcurrre;

implementation

uses
 reportcurr_mfm;
end.
