{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseificompglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 mseifiglob,mseclasses;
type
 iifilink = interface(iificlient)
                        ['{29DE5F47-87D3-408A-8BAB-1DDE945938F1}']
  function getobjectlinker: tobjectlinker;
 end;

 iifigridlink = interface(iifilink)
 end;

 iifigridserver = interface(iifiserver)
 end;
   
implementation
end.
