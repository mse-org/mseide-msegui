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
 mseifiglob,mseclasses,msetypes,msegridsglob,mseguiglob,msegraphutils;
type

 ificelleventinfoty = record
  cell: gridcoordty;
  grid: tobject;
  case eventkind: celleventkindty of
   cek_exit,cek_enter,cek_focusedcellchanged:
    (cellbefore,newcell: gridcoordty; selectaction: focuscellactionty);
   cek_select:
    (selected: boolean; accept: boolean);
   cek_mousemove,cek_mousepark,cek_firstmousepark,
   cek_buttonpress,cek_buttonrelease:
    (zone: cellzonety; mouseeventinfopo: pmouseeventinfoty;
                           gridmousepos: pointty);
   cek_keydown,cek_keyup:
    (keyeventinfopo: pkeyeventinfoty);
 end;

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
