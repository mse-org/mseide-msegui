program podemo;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC} {$ifdef unix}cthreads, {$endif} {$endif}
///////////////////////////////////////////
{$ifdef mse_dynpo}
{$include FormScanner.init}
{$endif}
///////////////////////////////////////////
  msegui,
  gettext,
  form_conflang;

begin
  Gettext.GetLanguageIDs(MSELang, MSEFallbackLang);
  application.createform (tconflangfo, conflangfo);

///////////////////////////////////////////
{$ifdef mse_dynpo}
  ListFormItems;
{$endif}
///////////////////////////////////////////

  application.run;
end.

