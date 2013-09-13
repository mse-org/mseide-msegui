{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetriaglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphutils,msegraphics;
type
 trianglety = array[0..2] of pointty;
 ptrianglety = ^trianglety;

 triainfoty = record
  xftlinewidth: integer;
//  xftlinewidthsquare: integer;
  xftdashes: dashesstringty;
  capstyle: capstylety;
  joinstyle: joinstylety;
  zerowidth: boolean;
 end;
 
 triagcty = record
  case integer of
   0: (d: triainfoty;);
   1: (_bufferspace: gcpty;);
 end;
 
implementation
end.
