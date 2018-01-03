unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$codepage utf8}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msedispwidgets,msegraphedits,msesimplewidgets;

type
 tmainfo = class(tmseform)
   disp1: tstringdisp;
   disp2: tstringdisp;
   default: tbutton;
   deutsch: tbutton;
   francais: tbutton;
   procedure formonloaded(const sender: TObject);
   procedure defaultexe(const sender: TObject);
   procedure deutschexe(const sender: TObject);
   procedure francaisexe(const sender: TObject);
  protected
   procedure updatedisp;
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm,msei18nutils,msestrings;

resourcestring
 rs1 = 'This is the first resource text.';
 rs2 = 'This is the second resource text.';

procedure tmainfo.formonloaded(const sender: TObject);
begin
 updatedisp;
end;

procedure tmainfo.updatedisp;
begin
 disp1.value:= utf8tostring(rs1);
 disp2.value:= utf8tostring(rs2);
end;

procedure tmainfo.defaultexe(const sender: TObject);
begin
 loadlangunit('');
end;

procedure tmainfo.deutschexe(const sender: TObject);
begin
 loadlangunit('i18ndemo_de');
end;

procedure tmainfo.francaisexe(const sender: TObject);
begin
 loadlangunit('i18ndemo_fr');
end;

end.
