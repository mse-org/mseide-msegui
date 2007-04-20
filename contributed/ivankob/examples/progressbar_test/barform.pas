unit barform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msegraphedits;

type
 tbarfo = class(tmseform)
   bar: tprogressbar;
   procedure barformcreate(const sender: TObject);
   procedure barfodestroy(const sender: TObject);
 end;

var
 barfo: tbarfo;

implementation

uses
 barform_mfm,
 main
;

procedure tbarfo.barformcreate(const sender: TObject);
begin
 mainfo.thrTask.run;
end;

procedure tbarfo.barfodestroy(const sender: TObject);
begin
 mainfo.thrTask.terminate;
end;


end.
