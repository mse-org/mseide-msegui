{ MSEide Copyright (c) 2017 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit menusdesign;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 msemenus,msemenuwidgets,msegui,mclasses,mseclasses,formdesigner,
 objectinspector,msearrayutils,msetypes,mseformatstr;

procedure domenuexe(const sender: tmenuitem);
var
 f1: tformdesignerfo;
 ar1: msestringarty;
 item1: tmenuitem;
begin
 f1:= getdesignform(sender.owner);
 if f1 <> nil then begin
  f1.clearselection();
  f1.selectcomponent(sender.owner);
  item1:= sender;
  ar1:= nil; //compiler warning
  insertitem(ar1,0,'menu');
  while item1.parentmenu <> nil do begin
   insertitem(ar1,1,'submenu.count');
   insertitem(ar1,2,'Item '+inttostrmse(item1.index));
   item1:= item1.parentmenu;
  end;
  if objectinspectorfo.selectprop(ar1,0,true) then begin
   objectinspectorfo.asyncactivate();
  end;
 end;
end;

initialization
 menuexehandlerdesign:= @domenuexe;
end.
