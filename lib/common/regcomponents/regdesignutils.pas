{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regdesignutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msegdbutils,classes,msedesignintf,msesyntaxedit,msesyntaxpainter,regdesignutils_bmp;

procedure Register;
begin
 registercomponents('Design',[tgdbmi,tsyntaxedit,tsyntaxpainter]);
 registercomponenttabhints(['Design'],['Design Utils']);
end;

initialization
 register;
end.
