unit reportik;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegui,mseclasses,msereport,msememds,msedb,msesimplewidgets,msesqldb,
 msedbgraphics;

type
 treportikre = class(treport)
   tbandarea1: tbandarea;
   bandData: trecordband;
   bandHeader: trecordband;
   tlabel1: tlabel;
   trecordband1: trecordband;
   bandFooter: trecordband;
   treportpage1: treportpage;
   treppagenumdisp1: treppagenumdisp;
   trepprintdatedisp1: trepprintdatedisp;
   procedure beforerender(const sender: TObject);
   procedure datarender(const sender: tcustomrecordband; var empty: Boolean);
   procedure footerrender(const sender: tcustomrecordband; var empty: Boolean);
 end;

var
 reportikre: treportikre;

implementation

uses
 reportik_mfm,
 main, //qry
 sysutils // floattostrf
;

var
 stuff_sum: double;
 
procedure treportikre.beforerender(const sender: TObject);
begin
 stuff_sum:= 0;
end;


procedure treportikre.datarender(const sender: tcustomrecordband;
               var empty: Boolean);
begin
 if not empty then
  stuff_sum:= stuff_sum + mainfo.fldFloatStuff.asfloat;
end;

procedure treportikre.footerrender(const sender: tcustomrecordband;
               var empty: Boolean);
begin
 with sender do begin
  tabs[1].value:= #8721' resistance = ' + floattostrf(stuff_sum,ffNumber,2,2);
 end;
end;

end.
