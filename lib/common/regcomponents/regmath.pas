{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regmath;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msefft,msedesignintf;
 
procedure register;
begin
 registercomponents('Math',[tfft]);
 registercomponenttabhints(['Math'],['Experimental Mathematical Components']);
end;

initialization
 register;
end.
