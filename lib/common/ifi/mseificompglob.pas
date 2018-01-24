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
 mseglob,mseifiglob,mseclasses,msetypes,msegridsglob,mseguiglob,msegraphutils,
 typinfo,msedatalist,mseapplication,mseinterfaces;

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

 iifilink = interface(iificlient)[miid_iifilink]
  function getifilinkkind: ptypeinfo;
  function getobjectlinker: tobjectlinker;
 end;

 iifiexeclink = interface(iifilink)[miid_iifiexeclink]
  procedure execute(const force: boolean = false);
 end;

 iififormlink = interface(iifilink)[miid_iififormlink]
  procedure setmodalresult(const avalue: modalresultty);
 end;

 iifidialoglink = interface(iifilink)[miid_iifidialoglink]
  function showdialog(out adialog: tactcomponent): modalresultty;
 end;
   
 iifidatalink = interface(iifilink)[miid_iifidatalink]
  procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
  function getgriddata: tdatalist;
  function getvalueprop: ppropinfo;
  procedure updatereadonlystate;
 end;
 
 iifigridlink = interface(iifilink)[miid_iifigridlink]
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
