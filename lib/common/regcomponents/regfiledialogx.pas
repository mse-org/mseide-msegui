unit regfiledialogx;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msedesignintf,msefiledialogx,regfiledialogx_bmp;

procedure register;
begin
 registercomponents('FileDialogX',[tfiledialogx,tfilenameeditx,tremotefilenameeditx]);
 registercomponenttabhints(['FileDialogX'],['User extended file dialogs']);
end;

initialization
 register;
end.
