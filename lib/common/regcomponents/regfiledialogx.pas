unit regfiledialogx;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 ideu24_bmp,msedesignintf,msefiledialogx;

procedure register;
begin
 registercomponents('DialogX',[tfiledialogx]);
 registercomponenttabhints(['DialogX'],['User extended dialogs']);
end;

initialization
 register;
end.
