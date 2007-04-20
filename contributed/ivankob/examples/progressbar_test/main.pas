unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,mseguithread;

type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   thrTask: tthreadcomp;
   procedure taskexec(const sender: TObject);
   procedure taskexecute(const sender: tthreadcomp);
   procedure taskfinished(const sender: tthreadcomp);
 end;
var
 mainfo: tmainfo;

implementation

uses
 main_mfm,
 sysutils,
 barform
;

procedure tmainfo.taskexec(const sender: TObject);
begin
  application.createform(tbarfo, barfo);
  barfo.show(true);
end;

procedure tmainfo.taskexecute(const sender: tthreadcomp);
var
 i: integer;
const
 cnt = 5;
begin
 for i:= 1 to cnt  do begin
  barfo.bar.value:= i/cnt;
  sleep(300);
 end;
end;

procedure tmainfo.taskfinished(const sender: tthreadcomp);
begin
  barfo.release;
  barfo:= nil;
end;

end.
