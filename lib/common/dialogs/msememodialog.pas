unit msememodialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,msestrings,
 msetypes,msestatfile,msesimplewidgets,msewidgets,msedialog;
 
type

 tmemodialogedit = class(tcustomdialogstringed)
  protected
   function execute(var avalue: msestring): boolean; override;
 end;
 
 tmsememodialogfo = class(tmseform)
   memo: tmemoedit;
   tstatfile1: tstatfile;
   tbutton1: tbutton;
   tbutton2: tbutton;
 end;
 
function memodialog(var avalue: msestring): modalresultty;
 
implementation
uses
 msememodialog_mfm;
 
function memodialog(var avalue: msestring): modalresultty;
var
 dia1: tmsememodialogfo;
begin
 dia1:= tmsememodialogfo.create(nil);
 try
  dia1.memo.value:= avalue;
  result:= dia1.show(true);
  if result = mr_ok then begin
   avalue:= dia1.memo.value;
  end;
 finally
  dia1.free;
 end;
end;

{ tmemodialogedit }

function tmemodialogedit.execute(var avalue: msestring): boolean;
begin
 result:= memodialog(avalue) = mr_ok;
end;

end.
