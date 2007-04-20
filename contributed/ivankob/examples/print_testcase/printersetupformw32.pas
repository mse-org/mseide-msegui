unit printersetupformw32;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 msegui,mseclasses,mseforms,msesimplewidgets,msegraphedits,msefiledialog,
 msedataedits,msedispwidgets;

type
 tprintersetupformw32fo = class(tmseform)
   brePS: tbooleaneditradio;
   fneGSVPath: tfilenameedit;
   grpPrinterType: tgroupbox;
   grpPrintWay: tgroupbox;
   breGDI: tbooleaneditradio;
   grpPreviewMode: tgroupbox;
   breUsePreview: tbooleaneditradio;
   breNoPreview: tbooleaneditradio;
   btnOk: tbutton;
   btnCancel: tbutton;
   seQueueName: tstringedit;
   sdCommanSystem: tstringdisp;
   sdQuality: tstringdisp;
   procedure previewmodechanged(const sender: TObject);
   procedure printernamecheck(const sender: tdataedit; const quiet: Boolean;
                   var accept: Boolean);
 end;
 
var
 printersetupformw32fo: tprintersetupformw32fo;

implementation

uses
 printersetupformw32_mfm,
 dmprint
; 

procedure tprintersetupformw32fo.previewmodechanged(const sender: TObject);
begin
  seQueueName.enabled:= (sender as tbooleaneditradio).value;
  sdQuality.enabled:= (sender as tbooleaneditradio).value;
  grpPrinterType.enabled:= (sender as tbooleaneditradio).value;
end;


procedure tprintersetupformw32fo.printernamecheck(const sender: tdataedit;
               const quiet: Boolean; var accept: Boolean);
begin
 if not dmprint.queuenamecheck(seQueueName.editor.text) then accept:= false;
end;


end.
