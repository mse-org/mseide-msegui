unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
 main_mfm,msei18nutils;

resourcestring
 rs1 = 'This is the first resource text.';
 rs2 = 'This is the second resource text.';

procedure tmainfo.formonloaded(const sender: TObject);
begin
 updatedisp;
end;

procedure tmainfo.updatedisp;
begin
 disp1.value:= rs1;
 disp2.value:= rs2;
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
