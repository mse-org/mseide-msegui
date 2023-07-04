unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes, msepointer,sysutils, mseglob, mseguiglob, mseguiintf, mseapplication,
 msestat, msemenus,msegui,msegraphics, msegraphutils, mseevent, mseclasses,
 msewidgets, mseforms,msesimplewidgets, msetimer, msedispwidgets, mserichstring;

type
 tmainfo = class(tmainform)
   tlabel1: tlabel;
   ttimer1: ttimer;
   procedure ontim(const sender: TObject);
   procedure onclos(const sender: TObject);
 end;
 
var
 mainfo: tmainfo;
  
implementation
uses
 main_mfm;
 
procedure tmainfo.ontim(const sender: TObject);
begin
 TLabel1.Caption:=DateTimeToStr(Now);
end;

procedure tmainfo.onclos(const sender: TObject);
begin
close;
end;

end.
