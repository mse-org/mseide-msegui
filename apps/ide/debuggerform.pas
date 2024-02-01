{ MSEide Copyright (c) 1999-2006 by Martin Schreiber

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
unit debuggerform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
msetoolbar, msegui,mseclasses,mseforms;

type
 tdebuggerfo = class(tdockform)
  gdbtoolbar : ttoolbar;
   procedure oncreat(const sender: TObject);
  end;

var
 debuggerfo: tdebuggerfo;
implementation
uses
actionsmodule, debuggerform_mfm; 

procedure tdebuggerfo.oncreat(const sender: TObject);
begin
{$if defined(netbsd) or defined(darwin)}
gdbtoolbar.buttons[1].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[2].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[3].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[4].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[5].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[7].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[8].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[10].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[11].imagelist := actionsmo.buttonicons_nomask;
gdbtoolbar.buttons[12].imagelist := actionsmo.buttonicons_nomask;
{$endif} 
end;

end.
