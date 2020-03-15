unit main;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 msegui,mseclasses,mseforms,msesimplewidgets;

type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   procedure exitonexecute(const sender: TObject);
 end;

var
 mainfo: tmainfo;

implementation
uses
 main_mfm;

procedure tmainfo.exitonexecute(const sender: TObject);
begin
 application.terminated:= true;
end;

end.
