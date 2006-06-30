unit messagesform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,mseterminal,msewidgetgrid,mseguithread;

type
 tmessagesfo = class(tmseform)
   messages: tterminal;
   twidgetgrid1: twidgetgrid;
   procedure formclosquery(const sender: tcustommseform; var amodalresult: modalresultty);
  public
   running: boolean;
 end;
var
 messagesfo: tmessagesfo;
implementation
uses
 messagesform_mfm;

procedure tmessagesfo.formclosquery(const sender: tcustommseform;
        var amodalresult: modalresultty);
begin
 if running then begin
  amodalresult:= mr_none;
 end;
end;

end.
