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
 mseifiglob,mseclasses,msetypes,msegridsglob,mseguiglob,msegraphutils,
 typinfo,msedatalist;

type
 ificelleventinfoty = record //same layout as celleventinfoty
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
  function getifilinkkind: ptypeinfo;
  function getobjectlinker: tobjectlinker;
 end;

 iifiexeclink = interface(iifilink) ['{6B4FDC33-D151-46A4-B72B-083D55A18A67}']
  procedure execute;
 end;
 
 iifidatalink = interface(iifilink) ['{FC6BF316-8347-4CAC-ABB7-FB171E14F52B}']
  procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
  function getgriddata: tdatalist;
  function getvalueprop: ppropinfo;
  procedure updatereadonlystate;
 end;
 
 iifigridlink = interface(iifilink)
  function appendrow(const checkautoappend: boolean = false): integer;
  function getrowstate: tcustomrowstatelist;
  procedure rowchanged(const arow: integer);
  procedure rowstatechanged(const arow: integer);
  procedure layoutchanged;
  function canclose1: boolean;
 end;

 iifigridserver = interface(iifiserver)
  
 end;
   
implementation
end.
