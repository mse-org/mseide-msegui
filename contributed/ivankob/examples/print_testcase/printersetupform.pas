unit printersetupform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,msegraphedits,msefiledialog,
 msedataedits;

type
 tprintersetupfo = class(tmseform)
   breGDI: tbooleaneditradio;
   breNoPreview: tbooleaneditradio;
   brePS: tbooleaneditradio;
   brEpson: tbooleaneditradio;
   breUsePreview: tbooleaneditradio;
   brIBM: tbooleaneditradio;
   brPCL: tbooleaneditradio;
   btnCancel: tbutton;
   btnOk: tbutton;
   grpPreviewMode: tgroupbox;
   grpPrinterType: tgroupbox;
   grpPrintWay: tgroupbox;
   kseQuality: tkeystringedit;
   kseDialogProgram: tkeystringedit;
   seQueueName: tstringedit;
   procedure nopreviewentered(const sender: TObject);
   procedure usepreviewentered(const sender: TObject);
   procedure queuenamecheck(const sender: tdataedit; const quiet: Boolean;
                   var accept: Boolean);
   procedure qualityinit(const sender: tcustomkeystringedit);
 end;

var
 printersetupfo: tprintersetupfo
;

implementation

uses
 printersetupform_mfm,
 dmprint 
;
 
procedure tprintersetupfo.nopreviewentered(const sender: TObject);
begin
  seQueueName.enabled:= (sender as tbooleaneditradio).value;
  kseQuality.enabled:= (sender as tbooleaneditradio).value;
  grpPrinterType.enabled:= (sender as tbooleaneditradio).value;
end;

procedure tprintersetupfo.usepreviewentered(const sender: TObject);
begin
  kseDialogProgram.enabled:= (sender as tbooleaneditradio).value;
end;

procedure tprintersetupfo.queuenamecheck(const sender: tdataedit;
               const quiet: Boolean; var accept: Boolean);
begin
 if not dmprint.queuenamecheck(seQueueName.editor.text) then accept:= false;
end;

procedure tprintersetupfo.qualityinit(const sender: tcustomkeystringedit);
var
 i: integer;
begin
 i:= brIBM.checkedtag;
 (sender as tkeystringedit).dropdown.valuecol:= brIBM.checkedtag;
end;


end.
