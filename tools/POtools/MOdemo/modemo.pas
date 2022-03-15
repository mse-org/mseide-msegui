program modemo;

// by Sieghard 2022

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC} {$ifdef unix}cthreads, {$endif} {$endif}
  msegui,
  gettext,
  form_conflang;

begin
  Gettext.GetLanguageIDs(MSELang, MSEFallbackLang);
  application.createform(tconflangfo, conflangfo);
  application.run;
end.

